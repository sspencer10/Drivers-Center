import CarPlay

class ListItemTextScroller {
    private var currentIndex = 0
    private let longText: String
    private weak var listTemplate: CPListTemplate?
    private let listItem: CPListItem
    private var timer: Timer?

    // Define a rough character limit for visible text
    private let visibleCharacterLimit = 25

    init(longText: String, listTemplate: CPListTemplate, listItem: CPListItem) {
        self.longText = longText
        self.listTemplate = listTemplate
        self.listItem = listItem
    }

    func startScrolling() {
        // Ensure the text is actually longer than the visible limit
        guard longText.count > visibleCharacterLimit else {
            print("Text fits within the visible limit; scrolling is not needed.")
            return
        }

        // Ensure we have a valid reference to the list template
        guard let listTemplate = listTemplate else { return }

        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            // Generate the substring to display
            let visibleText = self.currentSubstring()

            // Create a new CPListItem with the updated text
            let updatedListItem = CPListItem(text: visibleText, detailText: self.listItem.detailText)

            // Update the section in the template
            let section = CPListSection(items: [updatedListItem])
            listTemplate.updateSections([section])

            // Update the index for scrolling
            self.currentIndex += 1
            if self.currentIndex >= self.longText.count {
                self.currentIndex = 0 // Loop back to the start
            }
        }
    }

    func stopScrolling() {
        timer?.invalidate()
        timer = nil
    }

    private func currentSubstring() -> String {
        let start = longText.index(longText.startIndex, offsetBy: currentIndex)
        let end = longText.index(start, offsetBy: visibleCharacterLimit, limitedBy: longText.endIndex) ?? longText.endIndex
        return String(longText[start..<end])
    }
}
