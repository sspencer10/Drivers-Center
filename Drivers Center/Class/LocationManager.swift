//
//  LocationManager.swift
//  Drivers Center
//
//  Created by Steven Spencer on 8/12/24.

import UIKit
import SwiftUI
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate  {
    
    @Published var speed: Double = 0.0
    @Published var altitude: Double = 0.0
    @Published var heading: Double = 0.0
    @Published var latitude: Double = 0.0
    @Published var longitude: Double = 0.0
    @Published var degrees: Double = 0.0
    @Published var directionString: String = "N"
    
    let locationManager: CLLocationManager
    
    override init() {
        locationManager = CLLocationManager()
        super.init()
        locationManager.delegate = self
        setup()
        locationManager.delegate = self
    }
    
    func setup() {
        locationManager.delegate = self
        locationManager.desiredAccuracy=kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
        locationManager.delegate = self
    }
    
    // ### Get Data when it changes ### //
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        degrees =  -1.0 * newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations newLocations: [CLLocation]) {
        var _: [()] = newLocations.map {
            let initSpeed = ($0.speed * 2.23694)*10.rounded()/10
            if (initSpeed < 1) {
                speed = 0
            } else {
                speed = ($0.speed * 2.23694)*10.rounded()/10
            }
            
            altitude = ($0.altitude * 3.28084)*10.rounded()/10
            heading = $0.course
            latitude = ($0.coordinate.latitude)*100000.rounded()/100000
            longitude = ($0.coordinate.longitude)*100000.rounded()/100000
            
            print ("speed: \(speed), altitude: \(altitude), direction: \(getDirection(deg: heading)), latitude: \(latitude), longitude: \(longitude)")
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        if manager.authorizationStatus == .notDetermined || manager.authorizationStatus == .denied || manager.authorizationStatus == .restricted {
            manager.stopUpdatingLocation()
            manager.stopUpdatingHeading()
            manager.stopMonitoringSignificantLocationChanges()
        }
        
        if manager.authorizationStatus == .authorizedAlways || manager.authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("error 1: \(error)")
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

