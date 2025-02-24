import SwiftUI
import MediaPlayer
import MusicKit

struct PermissionsView: View {
    @State var text: String = "Location permission is needed for both the weather and navigation features of the app"
    @State var buttonText: String = "Set Location Permission"
    @State var cnt: Int = 0
    @ObservedObject var locMan: LocationManager
    var body: some View {
        VStack {
            Text(" ")
            Text(" ")
            
            Image("loginImg")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
                .padding()
            
            Text(" ")
            Text(" ")
            
            CardView {
                Text(text)
                    .font(.headline)
                    .padding()
                
                
                
                Button(action: {
                    if cnt == 0 {
                        locMan.lm.requestWhenInUseAuthorization()
                        cnt += 1
                    } else if cnt == 1 {
                        requestNotificationAuthorization()
                        cnt += 1
                    } else if cnt == 2 {
                        requestAppleMusicPermissions()
                        
                        cnt += 1
                    } else if cnt > 2 {
                        MediaItemViewModel.shared.redo()
                        text = ""
                        buttonText = "Done"
                        UserDefaults.standard.set(true, forKey: "onboarded")
                    }
                }) {
                    Text("\(buttonText)")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.green)
                        .cornerRadius(8)
                }
                .padding()
            }
            
            Spacer()
        
        }
        .onChange(of: cnt) {
            if cnt == 1 {
                text = "We need permission to send you notifications about upcoming turns and severe weather"
                buttonText = "Notification Permission"
            } else if cnt == 2 {
                text = "We need permission to access your Apple Music library for the music features of the app. An active Apple Music subscription is required."
                buttonText = "Apple Music Permission"
            } else if cnt > 2 {
                text = ""
                buttonText = "Done"
            }
        }
 
    }
    func requestNotificationAuthorization() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Error requesting notification authorization: \(error)")
            }
            print("Notification permission granted: \(granted)")
        }
    }
    
    func requestAppleMusicPermissions() {
        let status = MPMediaLibrary.authorizationStatus()
        if status == .notDetermined {
            MPMediaLibrary.requestAuthorization { newStatus in
                if newStatus != .authorized {
                    print("Apple Music access denied.")
                }
            }
        } else if status != .authorized {
            print("Apple Music access not granted.")
        }
    }

}



