import UIKit
import SwiftUI
import CarPlay
import MapKit
import Foundation
import Combine
import CoreLocation

// Define a protocol
protocol MyDelegate: AnyObject {
    func didUpdateValue(_ newValue: Bool)
}

class TemplateManager: NSObject, ObservableObject, CPInterfaceControllerDelegate, CPSessionConfigurationDelegate   {
    
    weak var delegate: MyDelegate?
    
    @Published var currentTime: String = ""
    @Published var isCarPlay: Bool = false
    
    private var timer: Timer?
    
    var enableCarPlay: Bool = true
    var carplayInterfaceController: CPInterfaceController?
    var sessionConfiguration: CPSessionConfiguration!
    var tabTemplates = [CPTemplate]()
    var sections: [CPListSection]?
    var sections2: [CPListSection]?
    var carplayScene: CPTemplateApplicationScene?
    
    // data variables as strings
    var altitudeString: String = "-- FT"
    var latString: String = "42.1673839"
    var lonString: String = "-92.0156213"
    var locationString: String = "42.1673839, -92.0156213"
    var locString: String?
    var speedString: String = "0.0"
    var directionString: String = "--"
    var addressString: String = ""
    var counter: Int = 0
    var lm: LocationManager
    var wvm: WeatherViewModel
    
    @AppStorage("gps_location", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var gps_location: String = ""
    @AppStorage("today_min", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var today_min: Double = 60.0
    @AppStorage("today_max", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var today_max: Double = 70.0
    @AppStorage("current_f", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var current_f: Double = 0.0
    
    var url: URL!
    var myTimer: Timer?
    
    override init() {
        lm = LocationManager.shared
        wvm = WeatherViewModel.shared
        super.init()
        startTimer()
    }
    
    func connect(_ interfaceController: CPInterfaceController, scene: CPTemplateApplicationScene) {
        if enableCarPlay {
            carplayInterfaceController = interfaceController
            carplayScene = scene
            carplayInterfaceController!.delegate = self
            sessionConfiguration = CPSessionConfiguration(delegate: self)
            isCarPlay = true
            startCarPlayTimer()
        }

        
        Task {
            await  wvm.fetchWeather()
            
        }
        if enableCarPlay {
            let listItem = CPListItem(text: String(format: "%.1f", lm.speed, " MPH"), detailText: directionString)
            listItem.setImage(UIImage(systemName: "speedometer")!)
            
            let listItem2 = CPListItem(text: ("\(String(wvm.temp))"), detailText: ("\(String(format: "%.0f", self.today_min))°/\(String(format: "%.0f", self.today_max))°"))
            listItem2.setImage(UIImage(systemName: "thermometer.sun")!)
            
            let listItem3 = CPListItem(text: ("\(altitudeString)"), detailText: "Altitude")
            listItem3.setImage(UIImage(systemName: "mountain.2.circle")!)
            
            let listItem4 = CPListItem(text: locationString, detailText: "Location")
            listItem4.setImage(UIImage(systemName: "map.circle")!)
            searchHandlerForItem(listItem: listItem4)
            
            self.carplayInterfaceController!.delegate = self
            
            self.carplayInterfaceController!.setRootTemplate(CPListTemplate(title: "CarPlay Dashboard", sections: [CPListSection(items: [listItem, listItem2, listItem3, listItem4])]), animated: true, completion: nil)
        }
    }
    
    
    
    /// Called when CarPlay disconnects.
    func disconnect() {
        stopCarPlayTimer()
        carplayScene = nil
        print("updating isCarPlay to false")
        isCarPlay = false
        UserDefaults.standard.setValue(false, forKey: "isCarPlay")
        lm.stopUpdatingLocation()
    }
    
    // Start the timer
    func startCarPlayTimer() {
        myTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updateTemplate()
        }
    }

    // Stop the timer
    func stopCarPlayTimer() {
        myTimer?.invalidate()
        myTimer = nil
    }
    
    func startTimer() {
        print("start timer")
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 15, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
        timer?.fire()
    }
    
    func updateTime() {
        print("timer fired function")
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        currentTime = formatter.string(from: Date())
        print("Function executed at \(currentTime)")
        wvm.fetchText()
    }
    
}
    
//extension TemplateManager: CPSessionConfigurationDelegate {
    func sessionConfiguration(_ sessionConfiguration: CPSessionConfiguration, limitedUserInterfacesChanged limitedUserInterfaces: CPLimitableUserInterface) {
        
    }
//}

extension TemplateManager {
    /// Starts a search with the title of the list item.
    ///
    
        func searchHandlerForItem(listItem: CPListItem) {
            listItem.handler = { item, completion in
                // opens map url
                self.carplayScene?.open(self.url, options: nil, completionHandler: nil)
                completion()
            }
        }
    
    
    func myTemplate() -> CPListTemplate {
        Task {
            await wvm.fetchWeather()
        }
        //if let weather = weatherViewModel.weather {
            
            let listItem = CPListItem(text: String(format: "%.1f", lm.speed, " MPH"), detailText: directionString)
            listItem.setImage(UIImage(systemName: "speedometer")!)
            listItem.userInfo = "1"
            
        let listItem2 = CPListItem(text: ("\(String(wvm.temp))"), detailText: ("\(String(format: "%.0f", self.today_min))°/\(String(format: "%.0f", self.today_max))°"))
            listItem2.setImage(UIImage(systemName: "thermometer.sun")!)
            listItem2.userInfo = "2"
            
            let listItem3 = CPListItem(text: ("\(altitudeString) FT"), detailText: "Altitude")
            listItem3.setImage(UIImage(systemName: "mountain.2.circle")!)
            listItem3.userInfo = "3"
            
            let listItem4 = CPListItem(text: locationString, detailText: "Location")
            listItem4.setImage(UIImage(systemName: "map.circle")!)
            listItem4.userInfo = "4"
            searchHandlerForItem(listItem: listItem4)
            
            sections = [CPListSection(items: [listItem, listItem2, listItem3, listItem4])]
            
            let template = CPListTemplate(title: "CarPlay Dashboard", sections: sections!)
            template.tabImage = UIImage(systemName: "speedometer")
            
            return template

    }
        
        func updateTemplate() {
            if (counter == 0) {
                counter += 1
                getAddressFromLatLon()
            } else {
                counter = 0
            }
            Task {
                await wvm.fetchWeather()
            }
            //weatherViewModel.fetchWeather(for: ationString)
            //if let weather = weatherViewModel.weather {
            
            let urlString = "comgooglemaps://?center=\(lm.latitude),\(lm.longitude)&zoom=14&views=traffic"
            url = URL(string: urlString)
            
            let listItem = CPListItem(text: String(format: "%.1f", lm.speed, " MPH"), detailText: lm.directionString)
            listItem.setImage(UIImage(systemName: "speedometer")!)
            listItem.userInfo = "1"
        
            let listItem2 = CPListItem(text: ("\(String(wvm.temp))"), detailText: ("\(String(format: "%.0f", wvm.today_min))°/\(String(format: "%.0f", wvm.today_max))°"))
            listItem2.setImage(UIImage(systemName: "thermometer.sun")!)
            listItem2.userInfo = "2"
            
            let listItem3 = CPListItem(text: ("\(altitudeString)"), detailText: "Altitude")
            listItem3.setImage(UIImage(systemName: "mountain.2.circle")!)
            listItem3.userInfo = "3"
            
            let listItem4 = CPListItem(text: addressString, detailText: "Location")
            listItem4.setImage(UIImage(systemName: "map.circle")!)
            listItem4.userInfo = "4"
            searchHandlerForItem(listItem: listItem4)
            
            
            self.carplayInterfaceController!.setRootTemplate(CPListTemplate(title: "CarPlay Dashboard", sections: [CPListSection(items: [listItem, listItem2, listItem3, listItem4])]), animated: false, completion: nil)
        }
        
        func getAddressFromLatLon() {
            
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = lm.latitude
            //21.228124
            let lon: Double = lm.longitude
            //72.833770
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon
            
            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
            
            ceo.reverseGeocodeLocation(loc, completionHandler:
                                        {(placemarks, error) in
                if (error?.localizedDescription != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                } else {
                    
                    let pm = placemarks! as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        
                        self.addressString = ""
                        if pm.subLocality != nil {
                            self.addressString = self.addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            self.addressString = self.addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            self.addressString = self.addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            self.addressString = self.addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            self.addressString = self.addressString + pm.postalCode! + " "
                        }
                    }
                }
            })
        }
        
        func getAddress() -> String {
            
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = lm.latitude
            //21.228124
            let lon: Double = lm.longitude
            //72.833770
            let ceo: CLGeocoder = CLGeocoder()
            center.latitude = lat
            center.longitude = lon
            
            let loc: CLLocation = CLLocation(latitude:center.latitude, longitude: center.longitude)
            
            ceo.reverseGeocodeLocation(loc, completionHandler:
                                        {(placemarks, error) in
                if (error?.localizedDescription != nil) {
                    print("reverse geodcode fail: \(error!.localizedDescription)")
                } else {
                    
                    let pm = placemarks! as [CLPlacemark]
                    
                    if pm.count > 0 {
                        let pm = placemarks![0]
                        
                        self.addressString = ""
                        if pm.subLocality != nil {
                            self.addressString = self.addressString + pm.subLocality! + ", "
                        }
                        if pm.thoroughfare != nil {
                            self.addressString = self.addressString + pm.thoroughfare! + ", "
                        }
                        if pm.locality != nil {
                            self.addressString = self.addressString + pm.locality! + ", "
                        }
                        if pm.country != nil {
                            self.addressString = self.addressString + pm.country! + ", "
                        }
                        if pm.postalCode != nil {
                            self.addressString = self.addressString + pm.postalCode! + " "
                        }
                    }
                }
            })
            return self.addressString
        }
        
        func initPos() {
            if #available(iOS 17.0, *) {
                MyVariables.initialPosition = {
                    let center = CLLocationCoordinate2D(latitude: lm.latitude, longitude: lm.longitude)
                    let span = MKCoordinateSpan(latitudeDelta: 0.2, longitudeDelta: 0.2)
                    let region = MKCoordinateRegion(center: center, span: span)
                    return .region(region)
                }()
            }
        }
    }

    extension Binding {
        func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
            Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
        }
    }

