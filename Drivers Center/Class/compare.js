const fs = require('fs');
const readline = require('readline');
const { diffLines } = require('diff');

/**
 * Extracts a Swift function from a file based on its name by scanning line-by-line.
 * This approach ignores 'private' and handles multi-line function signatures.
 *
 * @param {string} filePath - The path to the Swift file.
 * @param {string} functionName - The name of the Swift function (e.g., "checkForDeviation").
 * @returns {string|null} The extracted function code, or null if not found.
 */
function extractSwiftFunction(filePath, functionName) {
    const fileContent = fs.readFileSync(filePath, 'utf8');
    const lines = fileContent.split(/\r?\n/);

    let foundStart = false;
    let openBraces = 0;
    let functionStartIndex = -1;
    let functionEndIndex = -1;

    // Regex to detect the start of the function by name only.
    // e.g. `func checkForDeviation(` or `private func checkForDeviation(`
    const functionPattern = new RegExp(`^(?:private\\s+)?func\\s+${functionName}\\s*\\(`);

    for (let i = 0; i < lines.length; i++) {
        const currentLine = lines[i];
        const trimmedLine = currentLine.trim();

        // If we haven't found the function yet, look for its start.
        if (!foundStart) {
            if (functionPattern.test(trimmedLine)) {
                // Found the start line of the function
                foundStart = true;
                functionStartIndex = i;

                // Count braces on this line
                const opens = (trimmedLine.match(/{/g) || []).length;
                const closes = (trimmedLine.match(/}/g) || []).length;
                openBraces += (opens - closes);

                // If braces matched up on the same line, it might be a one-liner
                if (openBraces === 0) {
                    functionEndIndex = i;
                    break;
                }
            }
        } else {
            // We found the start; keep counting braces until they match up.
            const opens = (trimmedLine.match(/{/g) || []).length;
            const closes = (trimmedLine.match(/}/g) || []).length;
            openBraces += (opens - closes);

            if (openBraces === 0) {
                functionEndIndex = i;
                break;
            }
        }
    }

    if (functionStartIndex === -1) {
        console.error(`\x1b[31mFunction "${functionName}" not found in ${filePath}\x1b[0m`);
        return null;
    }
    if (functionEndIndex === -1) {
        console.error(`\x1b[31mFunction "${functionName}" was never closed with a '}'.\x1b[0m`);
        return null;
    }

    // Join all lines that make up the function definition and body
    return lines.slice(functionStartIndex, functionEndIndex + 1).join('\n');
}

/**
 * Produces a side-by-side diff of the original and updated code in the console.
 * Lines removed appear in the left column (red), lines added appear in the right column (green).
 * Common lines appear in both columns.
 *
 * @param {string} original - Original function code
 * @param {string} updated - Updated function code
 */
function sideBySideDiff(original, updated) {
    const parts = diffLines(original, updated);

    const leftLines = [];
    const rightLines = [];

    // Build two parallel arrays of lines
    parts.forEach(part => {
        // Split the part's text into individual lines
        let lines = part.value.split('\n');
        // Remove any trailing blank line from the split
        if (lines[lines.length - 1].trim() === '') {
            lines.pop();
        }

        if (part.added) {
            // Lines only exist in updated (right side)
            lines.forEach(line => {
                leftLines.push(''); // blank in the left column
                rightLines.push(`\x1b[32m+ ${line}\x1b[0m`); // green line
            });
        } else if (part.removed) {
            // Lines only exist in original (left side)
            lines.forEach(line => {
                leftLines.push(`\x1b[31m- ${line}\x1b[0m`); // red line
                rightLines.push(''); // blank in the right column
            });
        } else {
            // Common lines
            lines.forEach(line => {
                leftLines.push(`  ${line}`);
                rightLines.push(`  ${line}`);
            });
        }
    });

    // Print the side-by-side lines
    // Adjust colWidth to your preference (80 might be too wide or too narrow).
    // If your terminal wraps lines, consider piping to `less -S` or adjusting colWidth.
    const colWidth = 60;

    const rows = Math.max(leftLines.length, rightLines.length);
    for (let i = 0; i < rows; i++) {
        const leftText = leftLines[i] || '';
        const rightText = rightLines[i] || '';

        // Pad or slice to fit colWidth
        const leftCol = leftText.padEnd(colWidth).slice(0, colWidth);
        const rightCol = rightText.padEnd(colWidth).slice(0, colWidth);

        // Print them with a separator
        console.log(leftCol + ' | ' + rightCol);
    }
}

/**
 * Compares the extracted Swift function to the updated version in a side-by-side format.
 *
 * @param {string} filePath - The path to the Swift file.
 * @param {string} functionName - The name of the Swift function to extract and compare.
 * @param {string} updatedFunction - The updated code for the Swift function.
 */
function compareSwiftFunction(filePath, functionName, updatedFunction) {
    const originalFunction = extractSwiftFunction(filePath, functionName);
    if (!originalFunction) return;  // Error already logged

    console.log(`\n\x1b[34mSide-by-side diff for function "${functionName}":\x1b[0m`);
    sideBySideDiff(originalFunction.trim(), updatedFunction.trim());
}

/**
 * Function to prompt user for inputs interactively:
 *  1. Path of Swift file
 *  2. Function name
 *  3. Updated function code (multi-line, ends with "END")
 */
function promptUser() {
    const rl = readline.createInterface({
        input: process.stdin,
        output: process.stdout
    });

    rl.question("\nEnter the path of the Swift file: ", filePath => {
        // Clean up quotes if user pasted them
        filePath = filePath.trim().replace(/^"(.*)"$/, '$1').replace(/^'(.*)'$/, '$1');

        console.log(`\x1b[33mChecking file at: "${filePath}"...\x1b[0m`);
        if (!fs.existsSync(filePath)) {
            console.error("\x1b[31mError: File does not exist. Please check the path.\x1b[0m");
            rl.close();
            return;
        }

        rl.question("\nEnter the function name to compare (e.g., checkForDeviation): ", functionName => {
            console.log("\nEnter the updated function code. Type 'END' on a new line to finish:");
            let updatedFunction = '';

            rl.on('line', line => {
                if (line.trim() === 'END') {
                    rl.close();
                    compareSwiftFunction(filePath, functionName, updatedFunction.trim());
                } else {
                    updatedFunction += line + '\n';
                }
            });
        });
    });
}

// Start the interactive prompt
promptUser();
