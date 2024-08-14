import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MyDelegate {
    // Public static shared instance
    public static var shared = LocationManager()
    
    @Published var speed: Double = 0.0
    @Published var altitude: Double = 0.0
    @Published var heading: Double = 0.0
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var degrees: Double = 0.0
    @Published var directionString: String = "N"
    @Published var isCP: Bool = false
    @Published var firstRun: Bool
    
    // Private CLLocationManager instance
    private var locationManager: CLLocationManager
    
    // Private initializer to prevent creating new instances
    private override init() {
        UserDefaults.standard.setValue(false, forKey: "isCarPlay")
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.pausesLocationUpdatesAutomatically = true
        firstRun = true
        super.init()
        locationManager.delegate = self
        print("location init")
        startUpdatingLocation()
    }
    
    func didUpdateValue(_ newValue: Bool) {
        print("Value updated to \(newValue)")
        isCP = newValue
    }

    // Method to start updating location
    func startUpdatingLocation() {
        print("start updating location func")
        locationManager.requestWhenInUseAuthorization()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingHeading()
        //locationManager.startMonitoringSignificantLocationChanges()
        locationManager.startUpdatingLocation()
    }

    // Method to stop updating location
    func stopUpdatingLocation() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var _: [()] = locations.map {
            let initSpeed = ($0.speed * 2.23694)*10.rounded()/10
            if (initSpeed < 1) {
                speed = 0.0
            } else {
                speed = ($0.speed * 2.23694)*10.rounded()/10
            }
            altitude = ($0.altitude * 3.28084)*10.rounded()/10
            heading = $0.course
            latitude = ($0.coordinate.latitude)*100000.rounded()/100000
            longitude = ($0.coordinate.longitude)*100000.rounded()/100000
            if (firstRun) {
                firstRun = false
                Task {
                    let wvm = WeatherViewModel()
                    await wvm.fetchWeather()
                    wvm.showFirstView = false
                    wvm.showSecondView = true
                }
            }
            print ("speed: \(speed), altitude: \(altitude), direction: \(getDirection(deg: heading)), latitude: \(latitude), longitude: \(longitude)")

        }
    }

    // CLLocationManagerDelegate method - called on error
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func getDirection(deg: Double) -> String {
         let heading = deg
         //degrees = getCompass()
         let n = 22.5
         let ne = n + 45
         let e = ne + 45
         let se = e + 45
         let s = se + 45
         let sw = s + 45
         let w = sw + 45
         let nw = w + 45
         if (heading > 0 && heading <= n) {
             directionString = "North"
         } else if (heading > 22.5 && heading <= ne) {
             directionString = "North East"
         } else if (heading > 22.5 && heading <= e) {
             directionString = "East"
         } else if (heading > 22.5 && heading <= se) {
             directionString = "South East"
         } else if (heading > 22.5 && heading <= s) {
             directionString = "South"
         } else if (heading > 22.5 && heading <= sw) {
             directionString = "South West"
         } else if (heading > 22.5 && heading <= w) {
             directionString = "West"
         } else if (heading > 22.5 && heading <= nw) {
             directionString = "North West"
         } else {
             directionString = "North"
         }
         return directionString
     }

}
