import Speech
import AVFoundation

class SpeechRecognizer: NSObject {
    
    public static let shared = SpeechRecognizer()
    
    @Published var recognizedText: String = ""
    
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private var silenceTimer: Timer?
    private var timeoutTask: DispatchWorkItem?

    var onRecognitionComplete: ((String?) -> Void)?
    var onError: ((Error?) -> Void)?
    private var lastNonEmptyPartialResult: String = "" // Store the last non-empty partial result
    
    override private init() {} // ✅ Private initializer to enforce singleton pattern

    func startRecognition() {
        timeoutTask?.cancel() // Cancel any existing timeout task
        silenceTimer?.invalidate() // Invalidate any existing silence timer

        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            onError?(NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition is not available."]))
            return
        }

        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            onError?(NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request."]))
            return
        }

        recognitionRequest.shouldReportPartialResults = true

        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }

            if let error = error {
                print("Recognition error: \(error.localizedDescription)")
                self.stopRecognition()
                self.onError?(error)
                return
            }

            if let result = result {
                let partialText = result.bestTranscription.formattedString.trimmingCharacters(in: .whitespacesAndNewlines)
                print("Partial result: \(partialText)")

                // Update last non-empty partial result
                if !partialText.isEmpty {
                    self.lastNonEmptyPartialResult = partialText
                    self.recognizedText = partialText
                }

                // Reset silence timer on new partial results
                self.resetSilenceTimer()
            }
        }

        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }

        do {
            audioEngine.prepare()
            try audioEngine.start()
            print("Audio engine started. Listening for speech...")
        } catch {
            print("Audio engine start error: \(error.localizedDescription)")
            onError?(error)
            return
        }

        // Set up a final fallback timeout
        setupTimeout()
    }

    func stopRecognition() {
        timeoutTask?.cancel() // Cancel any active timeout
        silenceTimer?.invalidate() // Stop the silence timer

        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)

        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil

        print("Speech recognition stopped.")

        // Use the last non-empty partial result as the final recognized text
        if !lastNonEmptyPartialResult.isEmpty {
            print("Final result from partial: \(lastNonEmptyPartialResult)")
            onRecognitionComplete?(lastNonEmptyPartialResult)
        } else {
            print("No valid input received. Please try again.")
            onRecognitionComplete?(nil)
        }
    }

    private func setupTimeout() {
        timeoutTask = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            print("Timeout reached. Stopping recognition.")
            self.stopRecognition()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeoutTask!)
    }

    private func resetSilenceTimer() {
        silenceTimer?.invalidate() // Stop the previous timer

        // Start a new timer to detect silence (e.g., 2 seconds)
        silenceTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            guard let self = self else { return }
            print("Silence detected. Stopping recognition.")
            self.stopRecognition()
        }
    }
}
