import CoreLocation
import Foundation
import MapKit
import SwiftUI
import UIKit

// MARK: - Protocol Declaration

/// A protocol for delegate callbacks from the LocationManager.
protocol MyDelegate2: AnyObject {
    func didUpdateValue(_ newValue: Bool)
    func UpdateAllowed(x: Bool, completion: @escaping (Bool) -> Void)
    func UpdateAllowed() -> Bool
}

// MARK: - LocationManager Class Declaration

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate, MyDelegate2 {
    
    // MARK: - Public Static Instance
    public static var shared = Drivers_Center.LocationManager()
    
    // MARK: - Published Properties (observed by the UI)
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
    @Published var myLocation: CLLocationCoordinate2D?
    @Published var directionsText: String = ""
    @Published var currentStep: String = ""
    @Published var remainingSteps: [String] = []
    @Published var eta: String = "Unknown ETA"
    @Published var rawETA: TimeInterval?
    @Published var futureTime: String?
    @Published var showNavView: Bool = false
    
    // MARK: - Private Properties
    var destinationCoordinate: CLLocationCoordinate2D?
    var route: MKRoute?
    private var currentStepIndex = 0
    
    // Tuning thresholds and constants:
    // - For steps: only consider recalc if the current step is short (<200 m)
    // - Use a threshold for advancing a step when within 7.5 m
    private let nearTurnDistanceThreshold: Double = 200.0
    private let missedTurnIncreaseThreshold: Double = 30.0
    private let stepUpdateThreshold: CLLocationDistance = 7.5
    
    // For final arrival detection, we use a higher threshold (e.g. 50 m)
    private let finalArrivalThreshold: Double = 50.0
    
    // Smoothing and recalc management
    private var previousDistanceToStep: Double = .greatestFiniteMagnitude
    private var lastKnownLocation: CLLocation?
    
    // For route recalculation: time and distance traveled since the last recalc
    private var lastRecalculationTime: Date = .distantPast
    private var distanceTraveledSinceLastRecalc: Double = 0.0
    
    // 3-strike rule: if distance hasn't decreased for this many updates, force a recalc.
    private var distanceNotDecreasingCount = 0
    private var incorrectHeading: Int = 0
    private let maxNotDecreasingUpdates = 3
    
    var updateMapCameraCallback: (() -> Void)?
    
    
    // Core location manager instance
    let lm: CLLocationManager

    // MARK: - Initialization and Configuration
    
    private override init() {
        UserDefaults.standard.setValue(false, forKey: "isCarPlay")
        lm = CLLocationManager()
        super.init()
        lm.delegate = self
        if UserDefaults.standard.bool(forKey: "onboarded") {
            lm.requestWhenInUseAuthorization()
        }
        lm.startUpdatingHeading()
        lm.startUpdatingLocation()
        lm.distanceFilter = 5.0
        lm.headingFilter = 1.0
        lm.desiredAccuracy = kCLLocationAccuracyBestForNavigation
    }
    
    func centerMapToUserLocation() {
        if let currentLocation = lm.location {
            // Post a notification with the current location as the object.
            NotificationCenter.default.post(name: .centerMapToUserLocation, object: currentLocation)
            print("Centering map to user location: \(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude)")
        } else {
            print("User location not available; cannot center map.")
        }
    }
    
    func setTrackingMode() {
        if let currentLocation = lm.location {
            // Post a notification
            NotificationCenter.default.post(name: .setTrackingMode, object: currentLocation)
        }
    }

    func calculateETA(to destinationCoordinate: CLLocationCoordinate2D, completion: @escaping (TimeInterval?) -> Void) {
        // Ensure you have a valid current location.
        guard let currentLocation = LocationManager.shared.lm.location else {
            completion(nil)
            return
        }
        
        // Create placemarks for the source and destination.
        let sourcePlacemark = MKPlacemark(coordinate: currentLocation.coordinate)
        let destinationPlacemark = MKPlacemark(coordinate: destinationCoordinate)
        
        // Create map items from the placemarks.
        let sourceMapItem = MKMapItem(placemark: sourcePlacemark)
        let destinationMapItem = MKMapItem(placemark: destinationPlacemark)
        
        // Create a directions request.
        let request = MKDirections.Request()
        request.source = sourceMapItem
        request.destination = destinationMapItem
        request.transportType = .automobile  // Adjust if you need walking, transit, etc.
        
        // Create an MKDirections instance and calculate ETA.
        let directions = MKDirections(request: request)
        directions.calculateETA { (response, error) in
            if let error = error {
                print("Error calculating ETA: \(error.localizedDescription)")
                completion(nil)
            } else if let response = response {
                // expectedTravelTime is given in seconds.
                completion(response.expectedTravelTime)
            } else {
                completion(nil)
            }
        }
    }
    /// Configures the location manager's update frequency based on the mode.
    func configureLocationUpdates(for mode: String) {
        switch mode {
        case "navigation":
            lm.distanceFilter = 5.0
            lm.headingFilter = 1.0
        case "background":
            lm.distanceFilter = 50.0
            lm.headingFilter = 10.0
        default:
            lm.distanceFilter = kCLDistanceFilterNone
            lm.headingFilter = kCLHeadingFilterNone
        }
        print("Location updates configured: mode = \(mode), distanceFilter = \(lm.distanceFilter), headingFilter = \(lm.headingFilter)")
    }
    
    func startUpdatingLocation() {
        lm.activityType = .automotiveNavigation
        lm.allowsBackgroundLocationUpdates = true
        lm.pausesLocationUpdatesAutomatically = false
    }
    
    func forceLocationUpdate() {
        guard let currentLocation = lm.location else {
            print("🚨 Error: Current location is unavailable.")
            return
        }
        locationManager(lm, didUpdateLocations: [currentLocation])
        print("test420 - ✅ Forced location update: (\(currentLocation.coordinate.latitude), \(currentLocation.coordinate.longitude))")
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            print("not determined")
        case .authorizedWhenInUse:
            UserDefaults.standard.set(true, forKey: "whenInUse")
            print("whenInUse")
        case .authorizedAlways:
            print("Always")
        case .restricted:
            print("restricted")
            lm.stopUpdatingLocation()
            lm.stopMonitoringSignificantLocationChanges()
        case .denied:
            print("denied")
            lm.stopUpdatingLocation()
            lm.stopMonitoringSignificantLocationChanges()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        degrees = -1.0 * newHeading.trueHeading
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for location in locations {
            let initSpeed = (location.speed * 2.23694).rounded(to: 1)
            if isNav {
                speed = initSpeed <= 3 ? 0.0 : initSpeed
            } else {
                speed = initSpeed <= 2 ? 0.0 : initSpeed
            }
            altitude = (location.altitude * 3.28084).rounded(to: 1)
            heading = location.course
            myLocation = location.coordinate
            directionString = getDirection(deg: heading)
            latitude  = location.coordinate.latitude.rounded(to: 5)
            longitude = location.coordinate.longitude.rounded(to: 5)
            
            if firstRun {
                firstRun = false
                WeatherViewModel.shared.fetchWeather()
                WeatherViewModel.shared.showFirstView = false
                WeatherViewModel.shared.showSecondView = true
            }
            
            withAnimation {
                updateMapCameraCallback?()
            }
            
            // Track distance traveled since last recalc.
            if let lastLoc = lastKnownLocation {
                let delta = location.distance(from: lastLoc)
                distanceTraveledSinceLastRecalc += delta
            }
        
            lastKnownLocation = location
            
            guard let destination = destinationCoordinate else { return }
            
            if route == nil {
                print("route was nil, calculating new route")
                getDirections(from: location.coordinate, to: destination)
            } else {
                print("checking for deviation")
                checkForDeviation(from: location.coordinate)
            }
        }
    }
    
    // MARK: - Navigation Control Methods
    
    /// Starts navigation to the given destination coordinate.
    func startNavigation(to destination: CLLocationCoordinate2D) {
        isNav = true
        configureLocationUpdates(for: "navigation")
        forceLocationUpdate()
        destinationCoordinate = destination
        print("Start navigation to \(destination)")
        startUpdatingLocation()
    }
    
    /// Ends navigation by resetting the route and related properties.
    func endNavigation() {
        isNav = false
        print("test - Navigation ended")
        NotificationCenter.default.post(name: .endNavigation, object: nil)
        destinationCoordinate = nil
        route = nil
        currentStep = ""
        remainingSteps = []
        disToCurrentStep = 0.0
        totalDist = 0.0
        routeCoordinates = []
    }
    
    // MARK: - Deviation Checking and Step Updating
    
    /// Checks if the user is deviating from the current step and handles recalc logic.
    private func checkForDeviation(from currentCoord: CLLocationCoordinate2D) {
        guard let route = route else { return }
        let steps = route.steps
        
        // 1) Compute the raw remaining distance along the current step.
        var rawDist = distanceRemainingOnStep(userCoord: currentCoord, step: steps[currentStepIndex])
        rawDist = clampDistance(rawDist)
        
        // Initialize previousDistanceToStep if needed.
        if previousDistanceToStep == .greatestFiniteMagnitude {
            previousDistanceToStep = rawDist
        }
        
        // 2) Override condition:
        // If the raw distance has increased by more than 350 m compared to the last update,
        // then force an immediate recalculation.
        if rawDist > previousDistanceToStep + 350.0 {
            print("🚨 Raw distance increased by more than 350 m (was \(previousDistanceToStep), now \(rawDist)). Forcing recalc.")
            if shouldRecalculateRoute(force: true) {
                getDirections(from: currentCoord, to: destinationCoordinate!)
            }
            return
        }
        
        // 3) Partial smoothing: if the jump (difference) is large (> 150 m), average the previous and new values.
        let jump = abs(rawDist - previousDistanceToStep)
        var dist = rawDist
        if jump > 150 {
            dist = (previousDistanceToStep + rawDist) / 2
            print("⚠️ Large jump. Partially smoothing => new dist = \(dist)")
            dist = clampDistance(dist)
        }
        
        // 4) Normal smoothing.
        let smoothedDist = (previousDistanceToStep * 0.8) + (dist * 0.2)
        let finalSmoothed = clampDistance(smoothedDist)
        disToCurrentStep = clampDistance((previousDistanceToStep * 0.8) + (dist * 0.2))

        
        // 5) Check if the distance isn’t decreasing.
        if finalSmoothed >= previousDistanceToStep {
            distanceNotDecreasingCount += 1
            print("Distance NOT decreasing. Count = \(distanceNotDecreasingCount)")
        } else {
            distanceNotDecreasingCount = 0
        }
        previousDistanceToStep = finalSmoothed
        print("✅ Distance to current step: \(formatDistance(finalSmoothed))")
        
        // 6) If on the final step, check final destination.
        if currentStepIndex >= (steps.count - 1) {
            trackFinalDestination(currentCoord)
            return
        }
        
        // 7) (Optional) Check if the current step’s instruction indicates arrival.
        let currentInstruction = steps[currentStepIndex].instructions.lowercased()
        if currentInstruction.contains("arrive") {
            print("Final 'arrive' instruction detected. Ending navigation.")
            endNavigation()
            return
        }
        
        // 8) 3-strike rule: if the distance hasn’t decreased for several updates, force a recalc.
        if distanceNotDecreasingCount >= maxNotDecreasingUpdates {
            print("🚨 Distance not decreasing for \(maxNotDecreasingUpdates) updates → Forcing recalc!")
            if shouldRecalculateRoute(force: true) {
                getDirections(from: currentCoord, to: destinationCoordinate!)
                return
            }
        }
        // 9) Heading check.

        // Get the full set of coordinates for the current step.
        let polylineCoordinates = steps[currentStepIndex].polyline.coordinates

        // Define a look-ahead distance of 300 meters.
        let lookAheadDistance: CLLocationDistance = 300.0

        // Calculate the total remaining distance in the step from the current coordinate.
        let distanceToEnd = calculateDistance(from: currentCoord, to: polylineCoordinates.last!)

        // Determine which coordinate to use as the target for our bearing calculation.
        let targetCoord: CLLocationCoordinate2D
        if distanceToEnd > lookAheadDistance {
            // Look ahead 300 meters along the polyline.
            targetCoord = targetCoordinate(from: currentCoord, along: polylineCoordinates, lookAheadDistance: lookAheadDistance)
        } else {
            // If there isn’t 300 meters left, fall back to the final coordinate.
            targetCoord = polylineCoordinates.last!
        }

        // Calculate the bearing from the current location to the target coordinate.
        let neededBearing = calculateBearing(from: currentCoord, to: targetCoord)

        if let currHeading = lm.heading?.trueHeading {
            if !isHeadingCorrect(currentHeading: currHeading, targetBearing: neededBearing, threshold: 30.0) {
                print("🚨 Heading check: not within threshold. is heading correct: \(isHeadingCorrect(currentHeading: currHeading, targetBearing: neededBearing, threshold: 30.0)), currentHeading: \(currHeading), neededBearing: \(neededBearing)")
                if isHeadingTowardsTarget(currentHeading: currHeading, targetBearing: neededBearing) {
                    incorrectHeading = 0
                    print("✅ Heading is still generally toward target; continuing step. isHeadingCorrect: \(isHeadingTowardsTarget(currentHeading: currHeading, targetBearing: neededBearing)), currentHeading: \(currHeading), neededBearing: \(neededBearing)")
                    updateCurrentStep(for: currentCoord)
                } else {
                    incorrectHeading += 1
                    if shouldRecalculateRoute(force: shouldForce()) {
                        getDirections(from: currentCoord, to: destinationCoordinate!)
                    }
                }
            } else {
                updateCurrentStep(for: currentCoord)
            }
        } else {
            updateCurrentStep(for: currentCoord)
        }
        /*
        // 9) Heading check.
        let stepEndCoord = steps[currentStepIndex].polyline.coordinates.last!
        let neededBearing = calculateBearing(from: currentCoord, to: stepEndCoord)
        
        if let currHeading = lm.heading?.trueHeading {
            
            
            if !isHeadingCorrect(currentHeading: currHeading, targetBearing: neededBearing, threshold: 30.0) {
                print("🚨 Heading check: not within threshold.  is heading correct: \(isHeadingCorrect(currentHeading: currHeading, targetBearing: neededBearing, threshold: 30.0)), currentHeading: \(currHeading), neededBearing: \(neededBearing)")
                if isHeadingTowardsTarget(currentHeading: currHeading, targetBearing: neededBearing) {
                    incorrectHeading = 0
                    print("✅ Heading is still generally toward target; continuing step. isHeadingCorrect: \(isHeadingTowardsTarget(currentHeading: currHeading, targetBearing: neededBearing)), currentHeading: \(currHeading), neededBearing: \(neededBearing)")
                    updateCurrentStep(for: currentCoord)
                } else {
                    incorrectHeading += 1
                    if shouldRecalculateRoute(force: shouldForce()) {
                        getDirections(from: currentCoord, to: destinationCoordinate!)
                    }
                }
            } else {
                updateCurrentStep(for: currentCoord)
            }
        } else {
            updateCurrentStep(for: currentCoord)
        }
        */
    }

    // Calculates the distance (in meters) between two coordinates.
    func calculateDistance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> CLLocationDistance {
        let loc1 = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let loc2 = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return loc1.distance(from: loc2)
    }

    // Given a polyline (an array of coordinates), this function returns the coordinate
    // that is exactly 'lookAheadDistance' meters along the polyline from 'currentCoord'.
    // If the polyline does not extend that far, it returns the last coordinate.
    func targetCoordinate(from currentCoord: CLLocationCoordinate2D,
                          along polyline: [CLLocationCoordinate2D],
                          lookAheadDistance: CLLocationDistance) -> CLLocationCoordinate2D {
        var accumulatedDistance: CLLocationDistance = 0.0
        var previousCoordinate = currentCoord

        // Iterate through the polyline coordinates.
        for coord in polyline {
            let segmentDistance = calculateDistance(from: previousCoordinate, to: coord)
            accumulatedDistance += segmentDistance

            // If we've reached (or exceeded) the look-ahead distance...
            if accumulatedDistance >= lookAheadDistance {
                // Determine how far into this segment the target lies.
                let overshoot = accumulatedDistance - lookAheadDistance
                let fraction = 1.0 - (overshoot / segmentDistance)
                let lat = previousCoordinate.latitude + (coord.latitude - previousCoordinate.latitude) * fraction
                let lon = previousCoordinate.longitude + (coord.longitude - previousCoordinate.longitude) * fraction
                return CLLocationCoordinate2D(latitude: lat, longitude: lon)
            }
            previousCoordinate = coord
        }
        // If the polyline is shorter than the look-ahead distance, return the last coordinate.
        return polyline.last ?? currentCoord
    }
    
    func shouldForce() -> Bool {
        if incorrectHeading > 3 {
            incorrectHeading = 0
            return true
        } else {
            return false
        }
    }
    
    /// Updates the current step’s distance and advances to the next step if within threshold.
    private func updateCurrentStep(for userCoord: CLLocationCoordinate2D) {
        guard let route = route else { return }
        let steps = route.steps
        guard currentStepIndex < steps.count else { return }
        
        var stepDist = distanceRemainingOnStep(userCoord: userCoord, step: steps[currentStepIndex])
        stepDist = clampDistance(stepDist)
        
        if previousDistanceToStep == .greatestFiniteMagnitude {
            previousDistanceToStep = stepDist
        }
        
        let jump = abs(stepDist - previousDistanceToStep)
        var dist = stepDist
        if jump > 50 {
            dist = (previousDistanceToStep + stepDist) / 2
            print("⚠️ Large jump in updateCurrentStep. Partial smoothing => \(dist)")
            dist = clampDistance(dist)
        }
        let smoothed = (previousDistanceToStep * 0.8) + (dist * 0.2)
        let finalSmoothed = clampDistance(smoothed)
        disToCurrentStep = finalSmoothed
        previousDistanceToStep = finalSmoothed
        
        print("✅ Smoothed Distance to Current Step: \(formatDistance(finalSmoothed))")
        
        // If within threshold, advance to the next step.
        if finalSmoothed <= stepUpdateThreshold {
            currentStepIndex += 1
            scheduleLocalNotification()
            
            if currentStepIndex < steps.count {
                remainingSteps = steps[currentStepIndex...].map { $0.instructions }.filter { !$0.isEmpty }
                currentStep = remainingSteps.first ?? "No remaining steps"
                
                var newDist = distanceRemainingOnStep(userCoord: userCoord, step: steps[currentStepIndex])
                newDist = clampDistance(newDist)
                disToCurrentStep = newDist
                previousDistanceToStep = newDist
                distanceNotDecreasingCount = 0
                
                print("✅ Advanced to step \(currentStepIndex). '\(currentStep)' dist=\(formatDistance(newDist))")
            } else {
                print("🚀 Final step reached. Tracking final destination.")
                trackFinalDestination(userCoord)
            }
        }
    }
    
    /// Checks the raw distance from the user to the destination and ends navigation if within threshold.
    private func trackFinalDestination(_ userCoord: CLLocationCoordinate2D) {
        guard let dest = destinationCoordinate else { return }
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        let destLoc = CLLocation(latitude: dest.latitude, longitude: dest.longitude)
        
        let dist = clampDistance(userLoc.distance(from: destLoc))
        disToCurrentStep = dist
        print("Distance to final destination: \(formatDistance(dist))")
        
        if dist <= finalArrivalThreshold {
            print("Destination reached!")
            endNavigation()
        }
    }
    
    // MARK: - Route Recalculation Logic
    
    /// Determines whether to recalc the route based on dynamic thresholds.
    /// If `force` is true, recalc immediately.
    private func shouldRecalculateRoute(force: Bool) -> Bool {
        if force {
            print("Forcing recalc, ignoring cooldowns.")
            lastRecalculationTime = Date()
            distanceTraveledSinceLastRecalc = 0.0
            return true
        }
        

        
        let (minTime, minDist) = dynamicRecalcThresholds(forSpeed: speed)
        let now = Date()
        let timeSince = now.timeIntervalSince(lastRecalculationTime)
        
        if timeSince < minTime {
            print("Skipping recalc: only \(timeSince)s since last recalc (need \(minTime)).")
            return false
        }
        if distanceTraveledSinceLastRecalc < minDist {
            print("Skipping recalc: traveled \(distanceTraveledSinceLastRecalc)m (need \(minDist)).")
            return false
        }
        
        lastRecalculationTime = now
        distanceTraveledSinceLastRecalc = 0.0
        return true
    }
    
    /// Returns dynamic time and distance thresholds for recalculation based on speed.
    private func dynamicRecalcThresholds(forSpeed speed: Double) -> (TimeInterval, Double) {
        switch speed {
        case 0..<15:
            return (3.0, 30.0)  // City: recalc every 3 sec or 30 m.
        case 15..<30:
            return (5.0, 70.0)
        default:
            return (8.0, 120.0)
        }
    }
    
    // MARK: - Route Calculation
    
    /// Calculates a new route from source to destination using MapKit.
    func getDirections(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        guard CLLocationCoordinate2DIsValid(source), CLLocationCoordinate2DIsValid(destination) else {
            print("🚨 Invalid coords. Aborting getDirections.")
            return
        }
        
        let request = MKDirections.Request()
        request.transportType = .automobile
        request.requestsAlternateRoutes = true
        
        // Use a dynamic lookahead coordinate based on speed.
        if let currHeading = lm.heading?.trueHeading, currHeading >= 0 {
            
            let minLookAheadDistance = 10.0
            
            let headingRad = currHeading * .pi / 180

            // Determine the expected bearing for the first step.
            var expectedBearing: Double
            if let route = route, !route.steps.isEmpty {
                let firstStepCoord = route.steps.first!.polyline.coordinates.first!
                expectedBearing = calculateBearing(from: source, to: firstStepCoord)
                // Adjust the expected bearing (reverse it) if needed.
                if expectedBearing < 180.0 {
                    expectedBearing += 180.0
                } else if expectedBearing > 180.0 {
                    expectedBearing -= 180.0
                } else {
                    expectedBearing = 0
                }
            } else {
                expectedBearing = currHeading  // fallback
            }
            
            let headingError = abs(angularDifference(from: currHeading, to: expectedBearing))
            
            print("🚨 current heading: \(currHeading) - Expected Bearing: \(expectedBearing)")
            print("🚨 heading error: \(headingError)")
            
            // Choose a lookahead distance based on speed and heading error.
            let lookAheadDist: Double
            if headingError > 150.0 {
                lookAheadDist = 0.0  // reverse offset if heading error is huge
                print("Large heading error (\(headingError)°); using reverse lookahead offset: \(lookAheadDist) m")
            } else {
                if speed <= 2 {
                    lookAheadDist = 5.0
                } else if speed <= 35 {
                    lookAheadDist = minLookAheadDistance  // e.g., 50 m (or your chosen minimum)
                } else if speed <= 54 {
                    lookAheadDist = 50.0
                } else {
                    lookAheadDist = 80.0
                }
            }
            
            let latOffset = (lookAheadDist / 111111.0) * cos(headingRad)
            let lonOffset = (lookAheadDist / (111111.0 * cos(source.latitude * .pi / 180))) * sin(headingRad)
            let lookaheadCoord = CLLocationCoordinate2D(
                latitude: source.latitude + latOffset,
                longitude: source.longitude + lonOffset
            )
            print("Using lookaheadCoord = \(lookaheadCoord) (heading error: \(headingError)°) for new route (heading=\(expectedBearing), speed=\(speed))")
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: lookaheadCoord))
        } else {
            request.source = MKMapItem(placemark: MKPlacemark(coordinate: source))
        }
        
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destination))
        
        let directions = MKDirections(request: request)
        directions.calculate { [weak self] (response, error) in
            guard let self = self else { return }
            
            if let error = error {
                print("🚨 Error calculating directions: \(error.localizedDescription)")
                return
            }
            
            guard let response = response, !response.routes.isEmpty else {
                print("🚨 No routes returned!")
                return
            }
            
            // Choose the appropriate route.
            // If 'incorrectHeading' is greater than 2 and there is an alternate route, choose the second one.
            let chosenRoute: MKRoute
            if self.incorrectHeading > 2, response.routes.count > 1 {
                chosenRoute = response.routes[1]
                print("Using second route because incorrectHeading (\(self.incorrectHeading)) > 2.")
            } else {
                chosenRoute = response.routes.first!
            }
            
            DispatchQueue.main.async {
                self.route = chosenRoute
                self.totalDist = chosenRoute.distance
                self.remainingSteps = chosenRoute.steps.map { $0.instructions }.filter { !$0.isEmpty }
                self.currentStep = self.remainingSteps.first ?? "Start navigation"
                self.eta = self.formatETA(seconds: chosenRoute.expectedTravelTime)
                self.futureTime = self.formatFutureTime(chosenRoute.expectedTravelTime)
                
                // (Your other ETA-related properties, if needed)
                
                self.routeCoordinates = chosenRoute.polyline.coordinates
                print("test420 - ✅ Route recalculated. \(self.routeCoordinates.count) polyline coords.")
                
                for (i, st) in chosenRoute.steps.enumerated() {
                    print("Step \(i): \(st.instructions) @(\(st.polyline.coordinate.latitude), \(st.polyline.coordinate.longitude))")
                }
                
                self.currentStepIndex = 0
                self.distanceNotDecreasingCount = 0
                self.previousDistanceToStep = .greatestFiniteMagnitude
                self.lastRecalculationTime = Date()
                self.distanceTraveledSinceLastRecalc = 0.0
                
                self.updateCurrentStep(for: source)
            }
        }
    }
    
    func formatFutureTime(_ timeInterval: TimeInterval) -> String {
        // Get the current date and time
        let now = Date()
        
        // Calculate the future time
        let futureDate = now.addingTimeInterval(timeInterval)
        
        // Create a DateFormatter
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a" // Format as 12-hour time with AM/PM
        formatter.amSymbol = "AM"
        formatter.pmSymbol = "PM"

        // Convert futureDate to string
        let formattedTime = formatter.string(from: futureDate)
        
        return formattedTime
    }
    
    // MARK: - Map Camera Update
    
    /// Updates the map camera using speed-based altitude and a coordinate offset so the blue dot is positioned lower on the screen.
    func updateMapCamera(for mapView: MKMapView) {
        // Define speed thresholds with corresponding camera altitudes (in meters)
        let speedThresholds: [(speed: Double, altitude: CLLocationDistance)] = [
            (0,   800),
            (10,  1800),
            (30,  3000),
            (60,  5000),
            (80,  7000)
        ]
        
        let currentSpeed = max(speed, 0)
        let targetAltitude = speedThresholds.last(where: { currentSpeed >= $0.speed })?.altitude ?? 3000
        let currentCourse = lm.location?.course ?? 0.0
        
        // Ensure we have a valid user coordinate.
        guard let userCoordinate = mapView.userLocation.location?.coordinate else {
            print("User location unavailable.")
            return
        }
        
        // Define an offset (in meters) for the camera center.
        // A negative offset (e.g., -100) moves the blue dot downward on the screen.
        let offsetDistance: CLLocationDistance = -20  // Adjust as needed.
        let offsetHeading = (currentCourse + 180).truncatingRemainder(dividingBy: 360)
        let adjustedCenter = coordinate(from: userCoordinate, offsetBy: offsetDistance, heading: offsetHeading)
        
        DispatchQueue.main.async {
            withAnimation {
                CATransaction.begin()
                CATransaction.setAnimationDuration(0.3)
                
                let cam = mapView.camera
                cam.centerCoordinate = adjustedCenter
                cam.altitude = targetAltitude
                cam.heading = currentCourse
                mapView.setCamera(cam, animated: true)
                
                CATransaction.commit()
            }
            print("Updated camera: Speed \(currentSpeed) mph, Altitude \(targetAltitude) m, Heading \(currentCourse)°")
        }
    }
    
    // MARK: - Coordinate Helper
    
    /// Returns a new coordinate by offsetting the given coordinate by a specified distance (in meters) in a given heading (degrees).
    func coordinate(from coordinate: CLLocationCoordinate2D, offsetBy distance: CLLocationDistance, heading: Double) -> CLLocationCoordinate2D {
        let earthRadius = 6378137.0  // Earth's radius in meters
        let angularDistance = distance / earthRadius
        let bearing = heading * .pi / 180  // Convert heading to radians
        let lat1 = coordinate.latitude * .pi / 180
        let lon1 = coordinate.longitude * .pi / 180
        
        let lat2 = asin(sin(lat1) * cos(angularDistance) + cos(lat1) * sin(angularDistance) * cos(bearing))
        let lon2 = lon1 + atan2(sin(bearing) * sin(angularDistance) * cos(lat1),
                                cos(angularDistance) - sin(lat1) * sin(lat2))
        
        return CLLocationCoordinate2D(latitude: lat2 * 180 / .pi, longitude: lon2 * 180 / .pi)
    }
    
    // MARK: - Distance Along Step Helpers
    
    /// Returns the remaining on‑road distance (in meters) from the user's coordinate to the end of the given step.
    private func distanceRemainingOnStep(userCoord: CLLocationCoordinate2D, step: MKRoute.Step) -> Double {
        let coords = step.polyline.coordinates
        guard coords.count > 1 else { return 0 }
        
        // Build cumulative distances along the polyline.
        var cumulative = [Double](repeating: 0.0, count: coords.count)
        for i in 1..<coords.count {
            let locA = CLLocation(latitude: coords[i-1].latitude, longitude: coords[i-1].longitude)
            let locB = CLLocation(latitude: coords[i].latitude, longitude: coords[i].longitude)
            cumulative[i] = cumulative[i-1] + locA.distance(from: locB)
        }
        let totalStepDistance = cumulative.last ?? 0.0
        
        // Determine how far along the polyline the user is.
        let userDist = distanceAlongPolyline(userCoord: userCoord, coords: coords, cumulative: cumulative)
        
        // A margin to prevent flickering to zero.
        let margin = 10.0
        if userDist >= totalStepDistance - margin {
            return margin
        } else {
            return totalStepDistance - userDist
        }
    }
    
    /// Returns how far along the polyline (in meters from the start) the user is.
    private func distanceAlongPolyline(userCoord: CLLocationCoordinate2D, coords: [CLLocationCoordinate2D], cumulative: [Double]) -> Double {
        let userLoc = CLLocation(latitude: userCoord.latitude, longitude: userCoord.longitude)
        var bestDist = Double.greatestFiniteMagnitude
        var bestIndex = 0
        var bestRatio: Double = 0.0
        
        // For each segment, determine the closest point.
        for i in 0..<(coords.count - 1) {
            let p1 = coords[i]
            let p2 = coords[i+1]
            let (dist, ratio) = userLoc.distanceAndRatioToLineSegment(start: p1, end: p2)
            if dist < bestDist {
                bestDist = dist
                bestIndex = i
                bestRatio = ratio
            }
        }
        
        let baseDistance = cumulative[bestIndex]
        let segLength = cumulative[bestIndex+1] - baseDistance
        return baseDistance + (bestRatio * segLength)
    }
    
    // MARK: - MyDelegate2 Methods
    
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
    
    // MARK: - Helper Methods
    
    /// Clamps a distance value to a reasonable range to avoid very large or infinite values.
    private func clampDistance(_ dist: Double) -> Double {
        guard dist.isFinite, dist >= 0 else { return 0 }
        let maxDist = 1_000_000.0
        return (dist > maxDist) ? maxDist : dist
    }
    
    /// Formats a distance value (in meters) into a human-readable string (e.g., in miles).
    func formatDistance(_ dist: Double) -> String {
        // For example, convert meters to miles (1 m = 0.000621371 mi)
        let miles = dist * 0.000621371
        return String(format: "%.1f mi", miles)
    }
    
    /// Formats an ETA (in seconds) into a human-readable string.
    func formatETA(seconds: TimeInterval) -> String {
        let mins = Int(seconds / 60)
        let hrs  = mins / 60
        let rem  = mins % 60
        return (hrs > 0) ? "\(hrs) hr \(rem) min" : "\(rem) min"
    }
    
    /// Returns a direction string (e.g., "North East") for a given degree.
    func getDirection(deg: Double) -> String {
        let heading = deg.truncatingRemainder(dividingBy: 360)
        switch heading {
        case 0..<22.5, 337.5..<360:
            return "North"
        case 22.5..<67.5:
            return "North East"
        case 67.5..<112.5:
            return "East"
        case 112.5..<157.5:
            return "South East"
        case 157.5..<202.5:
            return "South"
        case 202.5..<247.5:
            return "South West"
        case 247.5..<292.5:
            return "West"
        case 292.5..<337.5:
            return "North West"
        default:
            return "North"
        }
    }
    
    // MARK: - Heading Helper Methods
    
    /// Checks if the current heading is within a threshold (default 30°) of the target bearing.
    func isHeadingCorrect(currentHeading: Double, targetBearing: Double, threshold: Double = 30.0) -> Bool {
        let difference = abs(currentHeading - targetBearing)
        return difference <= threshold || difference >= (360 - threshold)
    }
    
    /// Returns true if the current heading is within ±90° of the target bearing.
    func isHeadingTowardsTarget(currentHeading: Double, targetBearing: Double) -> Bool {
        let diff = angularDifference(from: currentHeading, to: targetBearing)
        return abs(diff) <= 90
    }
    
    /// Computes the smallest angular difference between two headings.
    func angularDifference(from heading1: Double, to heading2: Double) -> Double {
        let h1 = heading1.truncatingRemainder(dividingBy: 360)
        let h2 = heading2.truncatingRemainder(dividingBy: 360)
        let d = h2 - h1
        return (d + 540).truncatingRemainder(dividingBy: 360) - 180
    }
    
    /// Calculates the bearing (in degrees) from one coordinate to another.
    func calculateBearing(from start: CLLocationCoordinate2D, to end: CLLocationCoordinate2D) -> Double {
        let startLat = start.latitude.radians
        let startLon = start.longitude.radians
        let endLat = end.latitude.radians
        let endLon = end.longitude.radians
        let dLon = endLon - startLon
        let y = sin(dLon) * cos(endLat)
        let x = cos(startLat) * sin(endLat) - sin(startLat) * cos(endLat) * cos(dLon)
        let bearing = atan2(y, x).degrees
        return (bearing + 360).truncatingRemainder(dividingBy: 360)
    }
    
    /// Centers the map on the user’s current location.
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


    // MARK: - Notification

    func scheduleLocalNotification() {
        let appStatusHelper = AppStatusHelper()
        if appStatusHelper.isAppInBackground() {
            print("The app is in the background.")
            let notificationCenter = UNUserNotificationCenter.current()
            
            let content = UNMutableNotificationContent()
            content.title = "In \(formatDistance(disToCurrentStep))"
            content.body = "\(currentStep)"
            
            content.sound = .default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let identifier = UUID().uuidString
            let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
            
            notificationCenter.add(request) { error in
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled with ID: \(identifier)")
                }
            }
        }
    }
}

// MARK: - MKPolyline Extension

extension MKPolyline {
    var coordinates: [CLLocationCoordinate2D] {
        var coords = [CLLocationCoordinate2D](repeating: kCLLocationCoordinate2DInvalid, count: pointCount)
        getCoordinates(&coords, range: NSRange(location: 0, length: pointCount))
        return coords
    }
}

// MARK: - Double Extension

extension Double {
    var radians: Double { self * .pi / 180 }
    var degrees: Double { self * 180 / .pi }
    
    func rounded(to places: Int) -> Double {
        let m = pow(10.0, Double(places))
        return (self * m).rounded() / m
    }
}

// MARK: - CLLocation Snapping Extension

extension CLLocation {
    /// Returns the distance and ratio (0..1) from the start-to-end line segment where the user is closest.
    func distanceAndRatioToLineSegment(start: CLLocationCoordinate2D, end: CLLocationCoordinate2D) -> (distance: Double, ratio: Double) {
        let startPoint = CGPoint(x: start.longitude, y: start.latitude)
        let endPoint = CGPoint(x: end.longitude, y: end.latitude)
        let userPoint = CGPoint(x: coordinate.longitude, y: coordinate.latitude)
        
        let segVec = CGPoint(x: endPoint.x - startPoint.x, y: endPoint.y - startPoint.y)
        let userVec = CGPoint(x: userPoint.x - startPoint.x, y: userPoint.y - startPoint.y)
        
        let segLenSq = segVec.x * segVec.x + segVec.y * segVec.y
        if segLenSq < 1e-9 {
            let dist = distance(from: CLLocation(latitude: start.latitude, longitude: start.longitude))
            return (dist, 0)
        }
        
        let proj = (userVec.x * segVec.x + userVec.y * segVec.y) / segLenSq
        let ratio = max(0.0, min(1.0, proj))
        
        let closestX = startPoint.x + ratio * segVec.x
        let closestY = startPoint.y + ratio * segVec.y
        
        let closestLoc = CLLocation(latitude: closestY, longitude: closestX)
        let dist = distance(from: closestLoc)
        return (dist, ratio)
    }
}
extension Notification.Name {
    static let centerMapToUserLocation = Notification.Name("centerMapToUserLocation")
    static let endNavigation = Notification.Name("endNavigation")
    static let setTrackingMode = Notification.Name("setTrackingMode")
}

