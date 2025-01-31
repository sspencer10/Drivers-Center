import Foundation
import CoreLocation
import Combine
import SwiftUI

//

class LocationManager2: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    public static var shared = CLLocationManager()
    
    let manager: CLLocationManager
    @Published var permission: Bool = false
    @Published var ask: Bool
    @Published var permish: Bool?
    @Published var lat: Double?
    @Published var lon: Double?
    @Published var locationString: String = "42.1673839, -92.0156213"
    @Published var showFirst:Bool = true
    //@Published var location: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 42.1673839, longitude: -92.0156213)
    @AppStorage("gps_location", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var gps_location: String = "42.1673839, -92.0156213"
    @AppStorage("latitude", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var latitude: Double = 0.0
    @AppStorage("longitude", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.weather")) var longitude: Double = 0.0

    @Published var locationNew: CLLocationCoordinate2D?
    var bg: Bool = false
    private let interval: TimeInterval = 5 * 60 // 5 minutes in seconds
    private let lastRunKey = "updateTimer"
    
    var x: Bool?
    

    override init() {
        manager = CLLocationManager()
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            ask = false
        } else {
            ask = true
        }
        super.init()
        manager.delegate = self
        manager.desiredAccuracy=kCLLocationAccuracyKilometer
        manager.distanceFilter = 10
        
    }
    
    func showPermissionView(completion: @escaping (Bool) -> Void) {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            completion(true)
        } else {
            completion(false)
        }
    }
    
    func canRun() -> Bool {
        let lastRun = UserDefaults.standard.double(forKey: lastRunKey)
        let now = Date().timeIntervalSince1970
        return now - lastRun > interval
    }
    

    func startTrackingLocation() {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            bg = false
            manager.startUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
        }
    }
    
    func startTrackingSignificantLocation() {
        let status = manager.authorizationStatus
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            manager.stopUpdatingLocation()
            bg = true
            manager.startMonitoringSignificantLocationChanges()
        }
    }
    
    func stopTrackingLocation() {
        manager.stopUpdatingLocation()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        var _: [()] = newLocations.map {
            locationNew = CLLocationCoordinate2D(latitude: $0.coordinate.latitude, longitude: $0.coordinate.longitude)
            gps_location = "\(locationNew?.latitude ?? 42.1673839), \(locationNew?.longitude ?? -92.0156213)"
            locationString = gps_location
            lat = locationNew?.latitude ?? 42.1673839
            lon = locationNew?.longitude ?? -92.0156213
            latitude = locationNew?.latitude ?? 42.1673839
            longitude = locationNew?.longitude ?? -92.0156213
            updateLocation()
            if !bg {
                stopTrackingLocation()
            }
        }
    }
    

    func distanceBetweenCoordinates(from coordinate1: String, to coordinate2: String) -> Double {
        // Convert coordinate strings to CLLocationCoordinate2D
        let coordinate1Components = coordinate1.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces))! }
        let coordinate2Components = coordinate2.split(separator: ",").map { Double($0.trimmingCharacters(in: .whitespaces))! }

        let location1 = CLLocation(latitude: coordinate1Components[0], longitude: coordinate1Components[1])
        let location2 = CLLocation(latitude: coordinate2Components[0], longitude: coordinate2Components[1])
        
        // Calculate the distance between two locations
        let distanceInMeters = location1.distance(from: location2)
        
        // Return the distance in kilometers
        return distanceInMeters / 1000.0
    }

    func updateLocation() {
        if canRun() {
            //print("updating location")
            gps_location = "\(locationNew?.latitude ?? 42.1673839), \(locationNew?.longitude ?? -92.0156213)"
            print("gps location: \(gps_location)")
            locationString = gps_location
            UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: lastRunKey)
            //print(WeatherViewModel().fetchWeather(filter: 5, location: "current"))
        }
    }
    
    func startTimer(duration: TimeInterval) {
        //print("timer - started")
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.x = true
            //print("timer - finished")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            ask = true
            //manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            ask = true
            permission = true
            //manager.startUpdatingLocation()
            permish = true
            UserDefaults.standard.set(true, forKey: "whenInUse")
            //manager.requestAlwaysAuthorization()
            break
        case .authorizedAlways:
            ask = false
            permission = true
            //manager.startMonitoringSignificantLocationChanges()
            //manager.startUpdatingLocation()
            break
        case .restricted:
            ask = false
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
            break
        case .denied:
            ask = false
            manager.stopUpdatingLocation()
            manager.stopMonitoringSignificantLocationChanges()
            break
        default:
            break
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //print("locationManager error")
        //print("error: \(error)")
    }
}


