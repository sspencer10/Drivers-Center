import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MyDelegate {
    // Public static shared instance
    public static var shared = LocationManager()
    
    @Published var speed: Double = 0.0
    @Published var altitude: Double = 0.0
    @Published var heading: Double = 0.0
    @Published var latitude: Double = 42.1646
    @Published var longitude: Double = -92.0186
    @Published var degrees: Double = 0.0
    @Published var directionString: String = "N"
    @Published var isCP: Bool = false
    @Published var firstRun: Bool
    @Published var updateAllowed: Bool = false
    
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

    func carplayStart() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
        locationManager.startMonitoringSignificantLocationChanges()
    
    }
    
    func carplayStop() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingLocation()
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }
    
    // Method to start updating location
    func startUpdatingLocation() {
        print("start updating location func")
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingHeading()
        locationManager.startUpdatingLocation()
    }

    // Method to stop updating location
    func stopUpdatingLocation() {
        locationManager.stopUpdatingLocation()
        locationManager.stopUpdatingHeading()
    }
    
    func startSignificant() {
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.startMonitoringSignificantLocationChanges()
    }
    
    func stopSignificant() {
        locationManager.allowsBackgroundLocationUpdates = false
        locationManager.stopMonitoringSignificantLocationChanges()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        degrees =  -1.0 * newHeading.trueHeading
        //print("degrees: \(degrees)")
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
            
            directionString = getDirection(deg: heading)
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
            //print ("speed: \(speed), altitude: \(altitude), direction: \(getDirection(deg: heading)), latitude: \(latitude), longitude: \(longitude)")

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
        var dirString = ""
         if (heading > 0 && heading <= n) {
             dirString = "North"
         } else if (heading > 22.5 && heading <= ne) {
             dirString = "North East"
         } else if (heading > 22.5 && heading <= e) {
             dirString = "East"
         } else if (heading > 22.5 && heading <= se) {
             dirString = "South East"
         } else if (heading > 22.5 && heading <= s) {
             dirString = "South"
         } else if (heading > 22.5 && heading <= sw) {
             dirString = "South West"
         } else if (heading > 22.5 && heading <= w) {
             dirString = "West"
         } else if (heading > 22.5 && heading <= nw) {
             dirString = "North West"
         } else {
             dirString = "North"
         }
         return dirString
     }
    
    func UpdateAllowed(x: Bool, completion: @escaping (Bool) -> Void) {
        DispatchQueue.main.async {

            self.updateAllowed = x
            completion(x)

        }
        
    }
    
    func UpdateAllowed() -> Bool {
        return updateAllowed
    }

}
