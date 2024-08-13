import AppIntents
import SwiftUI

@available(iOS 17.0, *)
struct SendPresetMessageIntent: AppIntent {
    static var title: LocalizedStringResource = "Send Preset Message"

    // Define any parameters your shortcut needs
    @Parameter(title: "Recipient")
    var recipient: String
    
    @Parameter(title: "Message")
    var message: String

    // The method that will be executed when the shortcut runs
    func perform() async throws -> some IntentResult {
        message = "Location"
        // Code to send a message
        if let url = URL(string: "sms:\(recipient)&body=\(message)") {
           await UIApplication.shared.open(url)
        }
        return .result()
    }
}


