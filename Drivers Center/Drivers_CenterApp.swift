import AppIntents
import CoreLocation
import Intents
import MediaPlayer
import MessageUI
import MusicKit
import StoreKit
import SwiftUI

@main
struct YourApp: App {

    @Environment(\.scenePhase) var scenePhase
    @StateObject var locationManager: LocationManager
    @StateObject var weatherViewModel: WeatherViewModel
    @StateObject var templateManager: TemplateManager
    @StateObject var mediaItemViewModel: MediaItemViewModel
    @StateObject var addressSearchViewModel: AddressSearchViewModel
    
    init() {
        
        let sharedLocationManager = LocationManager.shared
        let sharedWeatherViewModel = WeatherViewModel.shared
        let sharedTemplateManager = TemplateManager.shared
        let sharedMediaItemViewModel = MediaItemViewModel.shared
        let sharedAddressSearchViewModel = AddressSearchViewModel.shared

        _locationManager = StateObject(wrappedValue: sharedLocationManager)
        _weatherViewModel = StateObject(wrappedValue: sharedWeatherViewModel)
        _templateManager = StateObject(wrappedValue: sharedTemplateManager)
        _mediaItemViewModel = StateObject(wrappedValue: sharedMediaItemViewModel)
        _addressSearchViewModel = StateObject(wrappedValue: sharedAddressSearchViewModel)
    }

    var body: some Scene {
        WindowGroup {
            MainView(
                locationManager: locationManager,
                tm: templateManager,
                weatherViewModel: weatherViewModel,
                mediaItemViewModel: mediaItemViewModel,
                addressSearchViewModel: addressSearchViewModel
            )
            .onChange(of: scenePhase) {
                switch scenePhase {
                case .active:
                    locationManager.lm.startUpdatingLocation()
                    locationManager.lm.startUpdatingHeading()
                    locationManager.configureLocationUpdates(for: "navigation")
                    UserDefaults.standard.set(false, forKey: "isInBackground")
                    print("App is active")
                    if mediaItemViewModel.songArray.count == 0 {
                        if templateManager.isCarPlay {
                            CarPlayObserver.shared.setCarPlay(true)
                        } else {
                            CarPlayObserver.shared.setCarPlay(false)
                        }
                    }
                    if locationManager.lm.authorizationStatus == .authorizedWhenInUse {
                        print("ask for always")
                        locationManager.lm.requestAlwaysAuthorization()
                    } else {
                        print("wont ask")
                    }
                    requestNotificationAuthorization()
                case .inactive:
                    print("App is inactive")
                    if (!mediaItemViewModel.isCarPlay)
                        && (mediaItemViewModel.bypassed)
                    {
                        mediaItemViewModel.byPass()
                    }
                case .background:
                    if !locationManager.isNav {
                        locationManager.configureLocationUpdates(for: "background")
                        if !templateManager.isCarPlay {
                            locationManager.lm.stopUpdatingLocation()
                            locationManager.lm.stopUpdatingHeading()
                        }
                    }
                    UserDefaults.standard.set(true, forKey: "isInBackground")
          
                    print("App is in background")
                default:
                    break
                }
            }
            
        }
    }

    enum LocationError: Error {
        case unableToGetLocation
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

}
