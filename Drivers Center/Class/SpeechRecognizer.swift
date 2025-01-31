import Foundation
import Speech
import AVFoundation

class SpeechRecognizer: NSObject {
    private let speechRecognizer = SFSpeechRecognizer()
    private let audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    
    var onRecognitionComplete: ((String) -> Void)?
    var onError: ((Error) -> Void)?
    
    func startRecognition() {
        guard let speechRecognizer = speechRecognizer, speechRecognizer.isAvailable else {
            onError?(NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Speech recognition is not available."]))
            return
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            onError?(NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unable to create recognition request."]))
            return
        }
        
        let inputNode = audioEngine.inputNode
        recognitionRequest.shouldReportPartialResults = true
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            guard let self = self else { return }
            
            if let error = error {
                self.stopRecognition()
                self.onError?(error)
                return
            }
            
            if let result = result, result.isFinal {
                self.stopRecognition()
                self.onRecognitionComplete?(result.bestTranscription.formattedString)
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { [weak self] buffer, _ in
            self?.recognitionRequest?.append(buffer)
        }
        
        do {
            audioEngine.prepare()
            try audioEngine.start()
            print("Speech recognition started.")
        } catch {
            onError?(error)
        }
    }
    
    func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
        print("Speech recognition stopped.")
    }
}