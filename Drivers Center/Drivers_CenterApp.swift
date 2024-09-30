import SwiftUI
import Intents
import AppIntents
import CoreLocation
import MessageUI


@main
struct YourApp: App {
    
    init() {
        // Configure SiriKit
        INPreferences.requestSiriAuthorization { status in
            // Handle the status of Siri authorization
        }
    }
    
    var body: some Scene {
        WindowGroup {
            MainView()
        }
    }
    
    enum LocationError: Error {
        case unableToGetLocation
    }
    
    private func requestSiriAuthorization() {
        INPreferences.requestSiriAuthorization { status in
            handleSiriAuthorizationStatus(status)
        }
    }
    
    func handleSiriAuthorizationStatus(_ status: INSiriAuthorizationStatus) {
        switch status {
        case .authorized:
            // Siri is authorized, proceed with Siri-related tasks
            print("Siri is authorized")
        case .denied:
            // Siri access was denied, show an alert or direct the user to settings
            print("Siri access was denied")
            self.showSiriAccessDeniedAlert()
        case .restricted:
            // Siri access is restricted, possibly due to parental controls
            print("Siri access is restricted")
        case .notDetermined:
            // Siri authorization status hasn't been determined yet
            print("Siri authorization status is not determined")
        @unknown default:
            // Handle any future cases or unexpected scenarios
            print("Unknown Siri authorization status")
        }
    }
    
    func showSiriAccessDeniedAlert() {
        DispatchQueue.main.async {
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootVC = windowScene.windows.first?.rootViewController {
                let alertController = UIAlertController(title: "Siri Access Denied",
                                                        message: "Please enable Siri in Settings to use this feature.",
                                                        preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Open Settings", style: .default) { _ in
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL, options: [:], completionHandler: nil)
                    }
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(settingsAction)
                alertController.addAction(cancelAction)
                rootVC.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func handleUserActivity(_ userActivity: NSUserActivity) {
        if userActivity.activityType == "com.yourApp.sendLocation" {
            // Handle the activity, e.g., trigger the intent or related action
            print("Handling send location user activity")
        }
    }
}

