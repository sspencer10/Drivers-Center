import CoreLocation
import Foundation
import MapKit
import SwiftUI
import UIKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MyDelegate {
    // Public static shared instance
    public static var shared = Drivers_Center.LocationManager()
    
    @Published var routeCoordinates: [CLLocationCoordinate2D] = []
    @Published var speed: Double = 0.0
    @Published var altitude: Double = 0.0
    @Published var heading: Double = 0.0
    @Published var latitude: Double = 42.1646
    @Published var longitude: Double = -92.0186
    @Published var degrees: Double = 0.0
    @Published var disToCurrentStep: Double = 0.0
    @Published var totalDist: Double = -0.0
    @Published var directionString: String = "N"
    @Published var isCP: Bool = false
    @Published var firstRun: Bool = false
    @Published var isNav: Bool = false
    @Published var updateAllowed: Bool = false
    @Published var directionsText: String = ""
    @Published var currentStep: String = ""
    @Published var remainingSteps: [String] = []
    @Published var eta: String = "Unknown ETA" // Added Estimated Time of Arrival
    
    private var destinationCoordinate: CLLocationCoordinate2D?
    private var route: MKRoute?
    private var currentStepIndex = 0
    private let deviationThreshold: CLLocationDistance = 50 // 50 meters
    
    private let headingThreshold: Double = 15.0 // Heading deviation threshold
    private let maxDeviationThreshold: CLLocationDistance = 100 // Maximum deviation
    private var lastStepUpdateTime: Date = .distantPast
    private let stepUpdateCooldown: TimeInterval = 1.0 // Cooldown for step updates
    private var lastRecalculationTime: Date = .distantPast
    private let recalculationCooldown: TimeInterval = 3.0 // Cooldown period for recalculation
    
    private let stepUpdateThreshold: CLLocationDistance = 7.5 // Distance to update to the next step
    private let missedTurnThreshold: CLLocationDistance = 30.0 // Distance to recalculate route after a missed turn
    private var previousDistanceToStep: Double = .greatestFiniteMagnitude
    
    let lm: CLLocationManager
    
    
    // MARK: Initialization and Configuration
    
    // Private initializer to prevent creating new instances
    private override init() {
        UserDefaults.standard.setValue(false, forKey: "isCarPlay")
        lm = CLLocationManager()
        super.init()
        lm.delegate = self
        lm.requestWhenInUseAuthorization()
        lm.startUpdatingHeading()
        lm.startUpdatingLocation()
        lm.distanceFilter = 5.0
        lm.headingFilter = 1.0
        lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
        
    }
    
    func configureLocationUpdates(for mode: String) {
        switch mode {
        case "navigation":
            lm.distanceFilter = 5.0 // Frequent updates for speed and navigation
            lm.headingFilter = 1.0 // Accurate heading updates
        case "background":
            lm.distanceFilter = 50.0 // Less frequent updates to save battery
            lm.headingFilter = 10.0 // Only significant heading changes
        default:
            lm.distanceFilter = kCLDistanceFilterNone // Default behavior
            lm.headingFilter = kCLHeadingFilterNone
        }
        print("Location updates configured: mode = \(mode), distanceFilter = \(lm.distanceFilter), headingFilter = \(lm.headingFilter)")
    }
    
    
    func startUpdatingLocation() {
        lm.activityType = .automotiveNavigation
        lm.allowsBackgroundLocationUpdates = true // Enable background updates
        lm.pausesLocationUpdatesAutomatically = false // Prevent pausing updates
    }
    
    
    func forceLocationUpdate() {
        guard let currentLocation = lm.location else {
            print("🚨 Error: Current location is unavailable.")
            return
        }
        
        // Manually trigger location handling
        locationManager(lm, didUpdateLocations: [currentLocation])
        print("test420 - ✅ Forced location update: (\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude))")
    }
    
    
    // MARK: - Delegate methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("not determined")
            break
        case .authorizedWhenInUse:
            UserDefaults.standard.set(true, forKey: "whenInUse")
            print("whenInUse")
            break
        case .authorizedAlways:
            print("Always")
            break
        case .restricted:
            print("restricted")
            lm.stopUpdatingLocation()
            lm.stopMonitoringSignificantLocationChanges()
            break
        case .denied:
            print("denied")
            lm.stopUpdatingLocation()
            lm.stopMonitoringSignificantLocationChanges()
            break
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        degrees = -1.0 * newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        var _: [()] = locations.map {
            let initSpeed = ($0.speed * 2.23694) * 10.rounded() / 10
            if initSpeed < 1 {
                speed = 0.0
            } else {
                speed = ($0.speed * 2.23694) * 10.rounded() / 10
            }
            altitude = ($0.altitude * 3.28084) * 10.rounded() / 10
            heading = $0.course
            
            directionString = getDirection(deg: heading)
            latitude = ($0.coordinate.latitude) * 100000.rounded() / 100000
            longitude = ($0.coordinate.longitude) * 100000.rounded() / 100000
            if firstRun {
                firstRun = false
                WeatherViewModel.shared.fetchWeather()
                WeatherViewModel.shared.showFirstView = false
                WeatherViewModel.shared.showSecondView = true
            }
            guard let currentLocation = locations.last?.coordinate else {
                return
            }
            guard let destination = destinationCoordinate else { return }
            if route == nil {
                // Only calculate the route once, when navigation starts
                print("route was nil, calculating new route")
                getDirections(from: currentLocation, to: destination)
            } else {
                print("checking for deviation")
                checkForDeviation(from: currentLocation)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    
    // MARK: - Navigation Logic
    
    func startNavigation(to destination: CLLocationCoordinate2D) {
        isNav = true
        configureLocationUpdates(for: "navigation")
        forceLocationUpdate()
        destinationCoordinate = destination
        print("Start navigation to \(destination)")
        startUpdatingLocation()
    }
    
    func endNavigation() {
        isNav = false
        print("test - Navigation ended")
        destinationCoordinate = nil
        route = nil
        currentStep = ""
        remainingSteps = []
        disToCurrentStep = 0.0
        totalDist = 0.0
       // lm.stopUpdatingLocation()
    }
    
    private func checkForDeviation(from currentLocation: CLLocationCoordinate2D) {
        guard let route = route else {
            print("🚨 Error: No route available!")
            return
        }

        let steps = route.steps
        guard currentStepIndex < steps.count else {
            print("🚨 Error: No steps remaining! Checking deviation on last step.")

            // Recalculate route if deviating on the last step
            if shouldRecalculateRoute() {
                print("🚨 User deviated on the last step. Recalculating route...")
                getDirections(from: currentLocation, to: destinationCoordinate!)
            }
            return
        }

        let currentStepLocation = CLLocation(latitude: steps[currentStepIndex].polyline.coordinate.latitude,
                                             longitude: steps[currentStepIndex].polyline.coordinate.longitude)
        let distanceToCurrentStep = CLLocation(latitude: currentLocation.latitude,
                                               longitude: currentLocation.longitude).distance(from: currentStepLocation)

        // Always update the distance to the current step
        disToCurrentStep = distanceToCurrentStep
        print("✅ Distance to current step: \(formatDistance(disToCurrentStep)) meters")

        // Check if the user is moving further away from the current step
        let distanceDifference = distanceToCurrentStep - previousDistanceToStep
        if distanceDifference > 25 { // Trigger recalculation if distance increases significantly
            print("🚨 Moving away from the current step! Distance increased by \(formatDistance(distanceDifference)) meters.")
            if shouldRecalculateRoute() {
                print("🚨 Recalculating route due to wrong direction!")
                getDirections(from: currentLocation, to: destinationCoordinate!)
                return
            }
        }

        // Standard missed turn logic
        if distanceToCurrentStep > missedTurnThreshold {
            print("🚨 Missed turn detected! Recalculating route...")
            if shouldRecalculateRoute() {
                getDirections(from: currentLocation, to: destinationCoordinate!)
                return
            }
        }

        // Update previous distance for the next check
        previousDistanceToStep = distanceToCurrentStep

        // Heading deviation logic
        let targetBearing = calculateBearing(from: currentLocation, to: currentStepLocation.coordinate)
        if let currentHeading = lm.heading?.trueHeading {
            if !isHeadingCorrect(currentHeading: currentHeading, targetBearing: targetBearing, threshold: headingThreshold) {
                // Determine if user is heading towards or away from the target
                if isHeadingTowardsTarget(currentHeading: currentHeading, targetBearing: targetBearing) {
                    print("✅ User is heading towards the target.")
                    updateCurrentStep(for: currentLocation)
                } else {
                    print("🚨 User is heading away from the target. Recalculating route...")
                    getDirections(from: currentLocation, to: destinationCoordinate!)
                }
            }
        }
    }

    private func trackFinalDestination(_ currentLocation: CLLocationCoordinate2D) {
        guard let destination = destinationCoordinate else {
            print("Error: No destination available!")
            return
        }
        
        let destinationLocation = CLLocation(latitude: destination.latitude, longitude: destination.longitude)
        let distanceToDestination = CLLocation(latitude: currentLocation.latitude,
                                               longitude: currentLocation.longitude).distance(from: destinationLocation)
        
        // 🚀 **Ensure `disToCurrentStep` keeps updating**
        disToCurrentStep = distanceToDestination
        print("Distance to final destination: \(formatDistance(disToCurrentStep))")
        
        if distanceToDestination <= stepUpdateThreshold {
            print("Destination reached!")
            endNavigation()
        }
    }
    
    
    // MARK: Route Calculation
    
    func getDirections(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        guard CLLocationCoordinate2DIsValid(source) && CLLocationCoordinate2DIsValid(destination) else {
            print("🚨 Error: Invalid source or destination coordinates! Aborting getDirections()")
            return
        }
        
        let sourcePlacemark = MKPlacemark(coordinate: source)
        let destinationPlacemark = MKPlacemark(coordinate: destination)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: sourcePlacemark)
        request.destination = MKMapItem(placemark: destinationPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] response, error in
            guard let self = self, let response = response, let route = response.routes.first, error == nil else {
                print("🚨 Error calculating directions: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.route = route
                self.totalDist = route.distance
                self.remainingSteps = route.steps.map { $0.instructions }.filter { !$0.isEmpty }
                self.currentStep = self.remainingSteps.first ?? "Start navigation"
                self.eta = self.formatETA(seconds: route.expectedTravelTime)
                
                // 🚀 **Extract and store polyline coordinates**
                self.routeCoordinates = route.polyline.coordinates
                print("✅ Route calculated with \(self.routeCoordinates.count) points.")
                
                // 🚀 **Log route coordinates for debugging**
                if let firstPoint = self.routeCoordinates.first {
                    print("First coordinate: (\(firstPoint.latitude), \(firstPoint.longitude))")
                } else {
                    print("🚨 Route coordinates are empty!")
                }
                
                // 🚀 **Log all steps to verify accuracy**
                for (index, step) in route.steps.enumerated() {
                    print("Step \(index): \(step.instructions) at (\(step.polyline.coordinate.latitude), \(step.polyline.coordinate.longitude))")
                }
                
                // 🚀 **Ensure we start at the correct step**
                self.currentStepIndex = 0
                self.updateCurrentStep(for: source)
            }
        }
    }
    
    private func updateCurrentStep(for currentLocation: CLLocationCoordinate2D) {
        guard let route = route else {
            print("🚨 Error: No route available!")
            return
        }

        let steps = route.steps
        guard currentStepIndex >= 0, currentStepIndex < steps.count else {
            print("🚨 Error: Current step index (\(currentStepIndex)) is out of bounds.")
            return
        }

        // Get the current step's location
        let currentStepLocation = CLLocation(latitude: steps[currentStepIndex].polyline.coordinate.latitude,
                                             longitude: steps[currentStepIndex].polyline.coordinate.longitude)

        // Calculate the snapped location on the route
        let snappedLocation = getClosestPointOnRoute(to: currentLocation, route: route)

        // Calculate distance from the snapped location to the current step
        let snappedDistanceToCurrentStep = CLLocation(latitude: snappedLocation.latitude,
                                                      longitude: snappedLocation.longitude).distance(from: currentStepLocation)

        // Ignore sudden jumps in distance (e.g., >50 meters in one update)
        if abs(snappedDistanceToCurrentStep - previousDistanceToStep) > 50 {
            print("⚠️ Ignoring sudden distance jump: \(snappedDistanceToCurrentStep) meters")
        } else {
            // Smooth the distance calculation to reduce spikes
            let smoothedDistance = (previousDistanceToStep * 0.8) + (snappedDistanceToCurrentStep * 0.2)
            disToCurrentStep = smoothedDistance
            previousDistanceToStep = snappedDistanceToCurrentStep
            print("✅ Smoothed Distance to Current Step: \(formatDistance(disToCurrentStep))")
        }

        // Log step and location details for debugging
        print("Step \(currentStepIndex) is at (\(steps[currentStepIndex].polyline.coordinate.latitude), \(steps[currentStepIndex].polyline.coordinate.longitude))")
        print("Current location: (\(currentLocation.latitude), \(currentLocation.longitude))")

        // Check if the user has reached the current step
        if disToCurrentStep <= stepUpdateThreshold {
            currentStepIndex += 1
            scheduleLocalNotification()

            if currentStepIndex < steps.count {
                let nextStepLocation = CLLocation(latitude: steps[currentStepIndex].polyline.coordinate.latitude,
                                                  longitude: steps[currentStepIndex].polyline.coordinate.longitude)
                disToCurrentStep = CLLocation(latitude: currentLocation.latitude,
                                              longitude: currentLocation.longitude).distance(from: nextStepLocation)

                remainingSteps = steps[currentStepIndex...].map { $0.instructions }.filter { !$0.isEmpty }
                currentStep = remainingSteps.first ?? "No remaining steps"
                print("✅ Updated to step \(currentStepIndex): '\(currentStep)' at distance \(formatDistance(disToCurrentStep))")
            } else {
                print("🚀 Final step reached. Switching to destination tracking...")
                trackFinalDestination(currentLocation)
            }
        }
    }
    
    private func getClosestPointOnRoute(to location: CLLocationCoordinate2D, route: MKRoute) -> CLLocationCoordinate2D {
        let polyline = route.polyline
        let closestPoint = polyline.coordinates.min(by: { point1, point2 in
            let loc = CLLocation(latitude: location.latitude, longitude: location.longitude)
            return loc.distance(from: CLLocation(latitude: point1.latitude, longitude: point1.longitude)) <
                loc.distance(from: CLLocation(latitude: point2.latitude, longitude: point2.longitude))
        })
        return closestPoint ?? location
    }
    
    private func findClosestStep(to currentLocation: CLLocation) -> (index: Int, distance: Double)? {
        guard let route = route else {
            print("Error: No route available!")
            return nil
        }
        
        var closestIndex: Int? = nil
        var closestDistance: Double = .greatestFiniteMagnitude
        
        for (index, step) in route.steps.enumerated() {
            let stepLocation = CLLocation(latitude: step.polyline.coordinate.latitude,
                                          longitude: step.polyline.coordinate.longitude)
            let distanceToStep = currentLocation.distance(from: stepLocation)
            
            if distanceToStep < closestDistance {
                closestDistance = distanceToStep
                closestIndex = index
            }
        }
        
        guard let closestIndex = closestIndex else { return nil }
        return (closestIndex, closestDistance)
    }
    
    
    // MARK: Notification Management
    
    func scheduleLocalNotification() {
        let appStatusHelper = AppStatusHelper()
        if appStatusHelper.isAppInBackground() {
            print("The app is in the background.")
            
            let notificationCenter = UNUserNotificationCenter.current()
            
            // Create the notification content
            let content = UNMutableNotificationContent()
            content.title = "In \(formatDistance(disToCurrentStep))"
            content.body = "\(currentStep)"
            content.sound = .default
            
            // Set a trigger (e.g., 5 seconds from now)
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            
            // Create a unique identifier for the notification
            let identifier = UUID().uuidString
            
            // Create the request
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            // Add the notification request to the notification center
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled with ID: \(identifier)")
                }
            }
        }
    }
    
    
    // MARK: Helpers and Utilities
    
    func getDirection(deg: Double) -> String {
        let heading = deg
        let n = 22.5
        let ne = n + 45
        let e = ne + 45
        let se = e + 45
        let s = se + 45
        let sw = s + 45
        let w = sw + 45
        let nw = w + 45
        var dirString = ""
        if heading > 0 && heading <= n {
            dirString = "North"
        } else if heading > 22.5 && heading <= ne {
            dirString = "North East"
        } else if heading > 22.5 && heading <= e {
            dirString = "East"
        } else if heading > 22.5 && heading <= se {
            dirString = "South East"
        } else if heading > 22.5 && heading <= s {
            dirString = "South"
        } else if heading > 22.5 && heading <= sw {
            dirString = "South West"
        } else if heading > 22.5 && heading <= w {
            dirString = "West"
        } else if heading > 22.5 && heading <= nw {
            dirString = "North West"
        } else {
            dirString = "North"
        }
        return dirString
    }

    private func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let startLat = start.latitude.radians
        let startLon = start.longitude.radians
        let endLat = end.latitude.radians
        let endLon = end.longitude.radians
        
        let dLon = endLon - startLon
        let y = sin(dLon) * cos(endLat)
        let x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLon)
        let bearing = atan2(y, x).degrees
        return (bearing + 360).truncatingRemainder(dividingBy: 360) // Normalize to 0–360
    }
    
    func formatETA(seconds: TimeInterval) -> String {
        let minutes = Int(seconds / 60)
        let hours = minutes / 60
        let remainingMinutes = minutes % 60
        return hours > 0 ? "\(hours) hr \(remainingMinutes) min" : "\(remainingMinutes) min"
    }
    
    private func isHeadingCorrect(currentHeading: Double, targetBearing: Double, threshold: Double = 30.0) -> Bool {
        let difference = abs(currentHeading - targetBearing)
        return difference <= threshold || difference >= (360 - threshold)
    }
    
    
    private func shouldRecalculateRoute() -> Bool {
        let now = Date()
        let dynamicCooldown: TimeInterval = speed > 30 ? 2.0 : (speed > 10 ? 3.0 : 5.0) // Adjust cooldown based on speed

        if now.timeIntervalSince(lastRecalculationTime) > dynamicCooldown {
            lastRecalculationTime = now
            return true
        }
        return false
    }
    
    func isHeadingTowardsTarget(currentHeading: Double, targetBearing: Double) -> Bool {
        // Calculate the angular difference
        let difference = angularDifference(from: currentHeading, to: targetBearing)
        
        // If the angular difference is less than 90 degrees, the user is heading towards the target
        return abs(difference) <= 90
    }
    
    func angularDifference(from heading1: Double, to heading2: Double) -> Double {
        // Normalize the angles to the range [0, 360)
        let normalizedHeading1 = heading1.truncatingRemainder(dividingBy: 360)
        let normalizedHeading2 = heading2.truncatingRemainder(dividingBy: 360)
        
        // Calculate the shortest angular difference
        let difference = normalizedHeading2 - normalizedHeading1
        return (difference + 540).truncatingRemainder(dividingBy: 360) - 180
    }
    
    
    // MARK: App-Specific Logic
    
    func didUpdateValue(_ newValue: Bool) {
        print("Value updated to \(newValue)")
        isCP = newValue
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
    
    func updateMapHeading(for mapView: MKMapView) {
        guard let userLocation = lm.location else {
            print("test420 - 🚨 Error: User location unavailable.")
            return
        }
        
        // Fallback to compass heading if course is invalid
        let heading = userLocation.course.isNaN || userLocation.course < 0
        ? lm.heading?.trueHeading ?? 0.0 // Use compass heading
        : userLocation.course
        
        let camera = MKMapCamera()
        camera.centerCoordinate = userLocation.coordinate
        camera.heading = heading // Rotate map to user's heading
        camera.pitch = 45.0 // Optional tilt for perspective
        
        DispatchQueue.main.async {
            mapView.setCamera(camera, animated: true)
            print("test420 - ✅ Map heading updated: \(heading)°")
        }
    }
    
    func updateMapZoom(for mapView: MKMapView) {
        let speedThresholds: [(speed: Double, zoom: Double)] = [
            (0, 0.005),   // Stopped: Closest zoom
            (10, 0.01),   // Slow
            (30, 0.02),   // City driving
            (60, 0.05),   // Highway
            (80, 0.08)    // High-speed zoom out
        ]
        
        // Ensure speed is non-negative and adjust for stationary
        let currentSpeed = max(speed, 0)
        let targetZoom = speedThresholds.last(where: { currentSpeed >= $0.speed })?.zoom ?? 0.01
        
        DispatchQueue.main.async {
            var region = mapView.region
            region.span = MKCoordinateSpan(latitudeDelta: targetZoom, longitudeDelta: targetZoom)
            mapView.setRegion(region, animated: true)
            print("test420 - ✅ Map zoom updated: Speed = \(currentSpeed) mph, Zoom = \(targetZoom)")
        }
    }
    

    
    func centerOnUser() {
        guard let userLocation = lm.location?.coordinate else {
            print("🚨 Error: User location is not available!")
            return
        }
        
        DispatchQueue.main.async {
            self.latitude = userLocation.latitude
            self.longitude = userLocation.longitude
            print("✅ Centering map on user at (\(self.latitude), \(self.longitude))")
        }
    }
}


// MARK: Extensions

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

extension Double {
    var radians: Double { self * .pi / 180 }
    var degrees: Double { self * 180 / .pi }
    var degreesToRadians: Double { self * .pi / 180 }
}
