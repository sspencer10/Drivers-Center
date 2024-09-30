//
//  SendLocationIntent.swift
//  Drivers Center
//
//  Created by Steven Spencer on 8/16/24.
//

import Foundation
import AppIntents

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
struct SendLocationIntent: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "SendLocationIntentIntent"

    static var title: LocalizedStringResource = "Send Location Intent"
    static var description = IntentDescription("Desc")

    @Parameter(title: "Recipient")
    var Recipient: String?

    static var parameterSummary: some ParameterSummary {
        Summary("Get recipient phone number") {
            \.$Recipient
        }
    }

    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$Recipient)) { Recipient in
            DisplayRepresentation(
                title: "Get recipient phone number",
                subtitle: ""
            )
        }
    }

    func perform() async throws -> some IntentResult {
        // TODO: Place your refactored intent handler code here.
        return .result()
    }
}

@available(iOS 16.0, macOS 13.0, watchOS 9.0, tvOS 16.0, *)
fileprivate extension IntentDialog {
    static var RecipientParameterPrompt: Self {
        "To whom?"
    }
    static func RecipientParameterDisambiguationIntro(count: Int, Recipient: String) -> Self {
        "There are \(count) options matching ‘\(Recipient)’."
    }
    static func RecipientParameterConfirmation(Recipient: String) -> Self {
        "Just to confirm, you wanted ‘\(Recipient)’?"
    }
    static var responseSuccess: Self {
        "To whom?"
    }
}

