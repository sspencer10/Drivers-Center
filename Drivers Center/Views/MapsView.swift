//
//  NavigationMapView.swift
//  Drivers Center
//
//  Created by Steven Spencer on 1/30/25.
//

import SwiftUI
import MapKit
import CoreLocation
import Combine
import UIKit

// MARK: - Google Places Models

struct GooglePlacesResponse: Decodable {
    let results: [GooglePlace]
    let status: String
    let next_page_token: String?  // For pagination
}

struct GooglePlace: Decodable {
    let name: String
    let vicinity: String
    let types: [String]
    let geometry: Geometry
    let place_id: String  // For fetching details later
}

struct Geometry: Decodable {
    let location: GoogleLocation
}

struct GoogleLocation: Decodable {
    let lat: Double
    let lng: Double
}

// Helper: Map Google Place type (String) to MKPointOfInterestCategory
func mapGoogleTypeToPOICategory(_ type: String) -> MKPointOfInterestCategory? {
    switch type {
    case "accounting": return .bank
    case "airport": return .airport
    case "amusement_park": return .amusementPark
    case "aquarium": return .aquarium
    case "art_gallery": return .store // Closest fit
    case "atm": return .atm
    case "bakery": return .bakery
    case "bank": return .bank
    case "bar": return .nightlife
    case "beauty_salon": return .spa
    case "bicycle_store": return .store
    case "book_store": return .store
    case "bowling_alley": return .store // Closest fit
    case "bus_station": return .publicTransport
    case "cafe": return .cafe
    case "campground": return .campground
    case "car_dealer": return .carRental // Closest fit
    case "car_rental": return .carRental
    case "car_repair": return .gasStation // Closest fit
    case "car_wash": return .gasStation // Closest fit
    case "casino": return .store
    case "cemetery": return .park // No cemetery category
    case "church": return .store // Closest fit for religious buildings
    case "city_hall": return .store // Closest fit for government buildings
    case "clothing_store": return .store
    case "convenience_store": return .store
    case "courthouse": return .postOffice
    case "dentist": return .hospital
    case "department_store": return .store
    case "doctor": return .hospital
    case "drugstore": return .pharmacy
    case "electrician": return .store // Closest fit
    case "electronics_store": return .store
    case "embassy": return .store // Closest fit
    case "fire_station": return .fireStation
    case "florist": return .store
    case "funeral_home": return .store // Closest fit
    case "furniture_store": return .store
    case "gas_station": return .gasStation
    case "gym": return .fitnessCenter
    case "hair_care": return .store // Closest fit
    case "hardware_store": return .store
    case "hindu_temple": return .school
    case "home_goods_store": return .store
    case "hospital": return .hospital
    case "insurance_agency": return .store // Closest fit
    case "jewelry_store": return .store
    case "laundry": return .store
    case "lawyer": return .store // Closest fit
    case "library": return .library
    case "light_rail_station": return .publicTransport
    case "liquor_store": return .store
    case "local_government_office": return .store // Closest fit
    case "locksmith": return .store
    case "lodging": return .hotel
    case "meal_delivery": return .restaurant
    case "meal_takeaway": return .restaurant
    case "mosque": return .school
    case "movie_rental": return .store
    case "movie_theater": return .movieTheater
    case "moving_company": return .store
    case "museum": return .museum
    case "night_club": return .nightlife
    case "painter": return .store
    case "park": return .park
    case "parking": return .parking
    case "pet_store": return .store
    case "pharmacy": return .pharmacy
    case "physiotherapist": return .hospital
    case "plumber": return .store
    case "police": return .police
    case "post_office": return .postOffice
    case "primary_school": return .school
    case "real_estate_agency": return .store // Closest fit
    case "restaurant": return .restaurant
    case "roofing_contractor": return .store
    case "rv_park": return .campground
    case "school": return .school
    case "secondary_school": return .school
    case "shoe_store": return .store
    case "shopping_mall": return .store
    case "spa": return .spa
    case "stadium": return .stadium
    case "storage": return .store
    case "store": return .store
    case "subway_station": return .publicTransport
    case "supermarket": return .foodMarket
    case "synagogue": return .school
    case "taxi_stand": return .publicTransport
    case "tourist_attraction": return .museum
    case "train_station": return .publicTransport
    case "transit_station": return .publicTransport
    case "travel_agency": return .store // Closest fit
    case "university": return .university
    case "veterinary_care": return .hospital
    case "zoo": return .zoo
    default: return nil
    }
}

// MARK: - KeyboardResponder
final class KeyboardResponder: ObservableObject {
    @Published var currentHeight: CGFloat = 0
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .compactMap { notification -> CGFloat? in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    return keyboardFrame.height
                }
                return nil
            }
            .merge(with:
                NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in CGFloat(0) }
            )
            .receive(on: RunLoop.main)
            .sink { [weak self] height in
                self?.currentHeight = height
            }
            .store(in: &cancellables)
    }
}

// MARK: - MapsView
struct MapsView: View {
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    @State var showSpeedometer: Bool = false
    @Binding var addressTitle: String
    @State private var centerCoordinate = CLLocationCoordinate2D(latitude: LocationManager.shared.latitude, longitude: LocationManager.shared.longitude)

    
    @State private var mapType: MKMapType = .standard
    
    var body: some View {
        ZStack {
            // RouteMapView uses our custom map implementation.
            RouteMapView(centerCoordinate: $centerCoordinate, routeCoordinates: locationManager.routeCoordinates, mapType: mapType)
                .edgesIgnoringSafeArea(.all)
            HStack {
                Spacer()
                VStack {
                    // Back to my location button overlay
                    Button(action: {
                        // Call a method on LocationManager to re-center the map.
                        // You need to implement this method, for example by posting a notification that your map's coordinator observes.
                        LocationManager.shared.centerMapToUserLocation()
                        LocationManager.shared.setTrackingMode()
                    }) {
                        Image(systemName: "location")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                    }
                    .frame(width: 45, height: 45)
                    .background(Color.black.opacity(0.8))
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    //.padding()
                    .padding(.horizontal, 5)
                    .padding(.vertical, 15)
                    
                    if !addressSearchViewModel.showNavView3 {
                        Button(action: {
                            mapType = (mapType == .standard) ? .hybrid : .standard
                        }) {
                            Image(systemName: mapType == .standard ? "map" : "map.fill")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                        }
                        .frame(width: 45, height: 45)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                        //.padding()
                        .padding(.horizontal, 5)
                        .padding(.vertical, 15)
                        
                        Button(action: {
                            showSpeedometer.toggle()
                        }) {
                            Image(systemName: "gauge.with.dots.needle.33percent")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 25, height: 25)
                        }
                        .frame(width: 45, height: 45)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 3)
                        //.padding()
                        .padding(.horizontal, 5)
                        .padding(.vertical, 15)
                    }
                    Spacer()
                }
                .padding(.top, 60)
            }
            
            VStack {
                Spacer()
                HStack {
                    if showSpeedometer {
                        SpeedometerView(
                            lm: LocationManager.shared,
                            coveredRadius: 230,
                            maxValue: 120,
                            steperSplit: 10,
                            size: 135
                        )
                        .padding()
                    }
                    Spacer()
                }
                
                if addressSearchViewModel.showNavView2 {
                    NavigationSearchViewHelper(
                        viewModel: locationManager,
                        addressSearchViewModel: addressSearchViewModel,
                        mapType: $mapType
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: true)
                }
                
                if addressSearchViewModel.showNavView {
                    NavigationSearchView(
                        viewModel: locationManager,
                        addressSearchViewModel: addressSearchViewModel,
                        mapType: $mapType
                    )
                    .transition(.move(edge: .bottom))
                    .animation(.spring(), value: true)
                }
            }
            .statusBar(hidden: true)
        }
        .onAppear {
            addressSearchViewModel.showNavView = true
            addressSearchViewModel.showNavView2 = false
        }
        .onDisappear {
            addressSearchViewModel.showNavView = false
            addressSearchViewModel.showNavView2 = false
        }
    }
}

// MARK: - NavigationSearchViewHelper
struct NavigationSearchViewHelper: View {
    
    @FocusState private var isSearchFocused: Bool
    @ObservedObject var viewModel: LocationManager
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    @State private var currentStep: String = "No step available"
    @State private var remainingSteps: [String] = []
    @State private var dist: Double = 0.0
    @State private var searchText = ""
    @State var shouldDismiss: Bool = false
    @State var cntr: Int = 0
    @State var showSpeedometer: Bool = false
    @State var max: CGFloat = 45
    
    @Binding var mapType: MKMapType
    
    private var fullScreenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    var body: some View {
        HStack {
            if showSpeedometer {
                SpeedometerView(
                    lm: LocationManager.shared,
                    coveredRadius: 230,
                    maxValue: 120,
                    steperSplit: 10,
                    size: 135
                )
                .padding()
            }
            Spacer()
            VStack {

            }
        }
        ZStack(alignment: .bottom) {
            VStack {
                if viewModel.currentStep.isEmpty {
                    Capsule()
                        .frame(width: 40, height: 5)
                        .foregroundColor(.gray)
                } else {
                    Text("In \(formatDistance(viewModel.disToCurrentStep)) \(viewModel.currentStep)")
                        .padding()
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: 45.0)
            .background(Color(.systemBackground))
            .clipShape(RoundedCornerShape(radius: 16, corners: [.topLeft, .topRight]))
            .onTapGesture {
                withAnimation {
                    addressSearchViewModel.sheetHeight = fullScreenHeight * 0.30
                }
            }
            .gesture(
                DragGesture()
                    .onEnded { value in
                        addressSearchViewModel.showNavView2 = false
                        addressSearchViewModel.showNavView = true
                        withAnimation {
                            addressSearchViewModel.sheetHeight = fullScreenHeight * 0.30
                        }
                    }
            )
        }
        .frame(alignment: .bottom)
    }
}

// MARK: - NavigationSearchView
struct NavigationSearchView: View {
    @FocusState private var isSearchFocused: Bool
    @ObservedObject var viewModel: LocationManager
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    @State private var currentStep: String = "No step available"
    @State private var remainingSteps: [String] = []
    @State private var dist: Double = 0.0
    @State private var searchText = ""
    @State var shouldDismiss: Bool = false
    @State var cntr: Int = 0
    @Binding var mapType: MKMapType
    @State var partialHeight: CGFloat = 0.30
    @State var fullOpenHeight: CGFloat = 0.75
    @State var searchHeight: CGFloat = 0.65
    @State var showSpeedometer: Bool = false
    
    private var fullScreenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    
    @ObservedObject private var keyboardResponder = KeyboardResponder()
    
    var body: some View {
        Spacer()
        HStack {
            if showSpeedometer {
                SpeedometerView(
                    lm: LocationManager.shared,
                    coveredRadius: 230,
                    maxValue: 120,
                    steperSplit: 10,
                    size: 135
                )
                .padding()
            }
            Spacer()
            VStack {
                if addressSearchViewModel.showNavView4 {
                    Button(action: {
                        mapType = (mapType == .standard) ? .hybrid : .standard
                    }) {
                        Image(systemName: mapType == .standard ? "map" : "map.fill")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                    }
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .padding()
                    
                    Button(action: {
                        showSpeedometer.toggle()
                    }) {
                        Image(systemName: "gauge.with.dots.needle.33percent")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 25, height: 25)
                    }
                    .frame(width: 40, height: 40)
                    .background(Color.white)
                    .clipShape(Circle())
                    .shadow(radius: 3)
                    .padding()
                }
            }
        }
        ZStack(alignment: .bottom) {
            Color.clear
            ZStack(alignment: .top) {
                Capsule()
                    .frame(width: 40, height: 5)
                    .foregroundColor(.gray)
                    .padding(.top, 15)
                
                if currentStep.isEmpty {
                    AddressSearchView(
                        addressSearchViewModel: addressSearchViewModel,
                        locMan: viewModel,
                        searchText: $searchText
                    )
                    .focused($isSearchFocused)
                    
                    Divider()
                } else {
                    VStack {
                        Text("\(addressSearchViewModel.selectedAddress ?? "")")
                            .font(.headline)
                        Text("Arrive at \(LocationManager.shared.futureTime ?? "")")
                            .font(.subheadline)
                            .padding(.top, 5)
                        if currentStep.isEmpty {
                            Text("No current step available").italic()
                        } else {
                            Text("In \(formatDistance(dist)) \(currentStep)")
                                .padding()
                                .multilineTextAlignment(.center)
                        }
                        Divider()
                        
                        Button(action: {
                            endNavigation()
                        }) {
                            Text("End Navigation")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(8)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    .padding(.top, 50)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: addressSearchViewModel.sheetHeight)
            .clipped()
            .background(Color(.systemBackground))
            .clipShape(RoundedCornerShape(radius: 16, corners: [.topLeft, .topRight]))
            .shadow(radius: 10)
            .padding(.bottom, -5)
            .gesture(
                DragGesture()
                    .onEnded { value in
                        if value.translation.height > 70 {
                            if addressSearchViewModel.sheetHeight == fullScreenHeight * 0.01 {
                                if addressSearchViewModel.selectedCoordinate == nil && !LocationManager.shared.isNav {
                                    withAnimation {
                                        addressSearchViewModel.sheetHeight = fullScreenHeight * 0.2
                                    }
                                } else {
                                    withAnimation {
                                        addressSearchViewModel.sheetHeight = fullScreenHeight * partialHeight
                                    }
                                }
                                addressSearchViewModel.showNavView2 = false
                            } else if addressSearchViewModel.sheetHeight == fullScreenHeight * 0.20 {
                                withAnimation {
                                    addressSearchViewModel.showNavView = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        addressSearchViewModel.showNavView2 = true
                                    }
                                }
                            } else if addressSearchViewModel.sheetHeight == fullScreenHeight * partialHeight {
                                withAnimation {
                                    addressSearchViewModel.showNavView = false
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    withAnimation {
                                        addressSearchViewModel.showNavView2 = true
                                    }
                                }
                            } else {
                                if addressSearchViewModel.selectedCoordinate == nil && !LocationManager.shared.isNav {
                                    withAnimation {
                                        addressSearchViewModel.sheetHeight = fullScreenHeight * 0.2
                                    }
                                } else {
                                    withAnimation {
                                        addressSearchViewModel.sheetHeight = fullScreenHeight * partialHeight
                                    }
                                }
                                addressSearchViewModel.showNavView2 = false
                            }
                        } else {
                            if addressSearchViewModel.sheetHeight == fullScreenHeight * 0.01 {
                                if addressSearchViewModel.selectedCoordinate == nil && !LocationManager.shared.isNav {
                                    withAnimation {
                                        addressSearchViewModel.sheetHeight = fullScreenHeight * 0.2
                                    }
                                } else {
                                    withAnimation {
                                        addressSearchViewModel.sheetHeight = fullScreenHeight * partialHeight
                                    }
                                }
                                addressSearchViewModel.showNavView2 = false
                            } else if addressSearchViewModel.sheetHeight == fullScreenHeight * 0.20 {
                                withAnimation {
                                    addressSearchViewModel.sheetHeight = fullScreenHeight * fullOpenHeight
                                }
                                addressSearchViewModel.showNavView2 = false
                            } else if addressSearchViewModel.sheetHeight == fullScreenHeight * partialHeight {
                                withAnimation {
                                    addressSearchViewModel.sheetHeight = fullScreenHeight * fullOpenHeight
                                }
                                addressSearchViewModel.showNavView2 = false
                            } else {
                                withAnimation {
                                    addressSearchViewModel.sheetHeight = fullScreenHeight * fullOpenHeight
                                }
                                addressSearchViewModel.showNavView2 = false
                            }
                        }
                    }
            )
        }
        .onAppear {
            if addressSearchViewModel.selectedCoordinate == nil && !LocationManager.shared.isNav {
                withAnimation {
                    addressSearchViewModel.sheetHeight = fullScreenHeight * 0.2
                }
            } else {
                withAnimation {
                    addressSearchViewModel.sheetHeight = fullScreenHeight * partialHeight
                }
            }
            initializeState()
        }
        .onChange(of: isSearchFocused) {
            if isSearchFocused {
                withAnimation {
                    addressSearchViewModel.sheetHeight = fullScreenHeight * searchHeight
                }
            }
        }
        .onChange(of: addressSearchViewModel.sheetHeight) {
            if addressSearchViewModel.sheetHeight == 5.0 {
                withAnimation {
                    addressSearchViewModel.showNavView = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    addressSearchViewModel.showNavView2 = true
                }
            }
        }
        .onChange(of: viewModel.currentStep) {
            currentStep = viewModel.currentStep
        }
        .onChange(of: viewModel.remainingSteps) {
            remainingSteps = viewModel.remainingSteps
        }
        .onChange(of: viewModel.disToCurrentStep) {
            dist = viewModel.disToCurrentStep
        }
        .onChange(of: LocationManager.shared.isNav) {
            if addressSearchViewModel.selectedCoordinate == nil && !LocationManager.shared.isNav {
                partialHeight = 0.2
            } else {
                partialHeight = 0.3
            }
        }
        .onReceive(SpeechRecognizer.shared.$recognizedText) { newText in
            self.searchText = newText
        }
    }
    
    private func initializeState() {
        DispatchQueue.main.async {
            currentStep = viewModel.currentStep
            remainingSteps = viewModel.remainingSteps
            dist = viewModel.disToCurrentStep
            print("mymap - test - Current step: \(currentStep)")
            print("mymap - test - Remaining steps: \(remainingSteps)")
            print("mymap - test - Distance to next step: \(dist)")
        }
    }
    
    private func endNavigation() {
        print("mymap - test - Ending navigation")
        viewModel.endNavigation()
        currentStep = "No step available"
        remainingSteps = []
        dist = 0.0
        searchText = ""
        
    }
}

// MARK: - RouteMapView (UIKit MKMapView Implementation Using Google Places)
struct RouteMapView: UIViewRepresentable {
    @Binding var centerCoordinate: CLLocationCoordinate2D
    private let distanceThreshold: CLLocationDistance = 1000 // Meters
    var routeCoordinates: [CLLocationCoordinate2D]
    var mapType: MKMapType = .standard
    @State var allAnnotations: [MKAnnotation] = []

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.pointOfInterestFilter = .excludingAll
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .none
        
        if let userLocation = LocationManager.shared.lm.location?.coordinate {
            let region = MKCoordinateRegion(center: userLocation,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            mapView.setRegion(region, animated: false)
        }
        
        // Add long-press gesture recognizer
          let longPressRecognizer = UILongPressGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleLongPress(_:)))
          mapView.addGestureRecognizer(longPressRecognizer)
        
        // Perform a wide Google Places search and store annotations.
        let currentZoom = mapView.region.span.latitudeDelta
        if currentZoom < 0.07 {
            print("zoom - inital search")
            context.coordinator.performWideSearch(in: mapView, significant: false)
        }
        context.coordinator.mapView = mapView
        
        return mapView
    }
    
    func updateUIView(_ uiView: MKMapView, context: Context) {
        
        print("updateuiview")
        let currentCenter = uiView.centerCoordinate
        let currentZoom = uiView.region.span.latitudeDelta

    
        // Only update the map if the center has moved significantly
        let distance = CLLocation(latitude: centerCoordinate.latitude, longitude: centerCoordinate.longitude)
            .distance(from: CLLocation(latitude: currentCenter.latitude, longitude: currentCenter.longitude))

        if distance > distanceThreshold {
            if currentZoom < 0.07 {
                print("zoom - updateUIView")
                Coordinator(self).performWideSearch(in: uiView, significant: true)
            }
        }
        
        uiView.mapType = mapType
        
        if LocationManager.shared.isNav {
            uiView.userTrackingMode = .followWithHeading
        } else {
            LocationManager.shared.updateMapCamera(for: uiView)
            uiView.userTrackingMode = .none
        }
        
        //print("Current latitudeDelta: \(currentZoom)")
    
        if !routeCoordinates.isEmpty {
            let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
            uiView.addOverlay(polyline)
        } else {
            print("mymap - No route coordinates available. Skipping polyline addition.")
            for overlay in uiView.overlays {
                if let polyline = overlay as? MKPolyline {
                    // Optionally, check if this is the polyline you're interested in
                    uiView.removeOverlay(polyline)
                }
            }
        }
        
        
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    

}

// MARK: - Coordinator (Using Google Places for Wide Search & Progressive Filtering)
extension RouteMapView {
    class Coordinator: NSObject, MKMapViewDelegate {
        var lastFetchedCenter: CLLocation?
        let fetchThreshold: Double = 5000.0
        let updateThreshold: Double = 500.0
        var parent: RouteMapView
        private var lastCenterCoordinate: CLLocationCoordinate2D?
        weak var mapView: MKMapView?
        // Store all annotations from the wide Google Places search.
        var allAnnotations: [MKAnnotation] = []
        var previousDelta: Double = 0.0
        var coordinate: CLLocationCoordinate2D?
        
        init(_ parent: RouteMapView) {
            self.parent = parent
            self.lastCenterCoordinate = parent.centerCoordinate
            super.init()
            NotificationCenter.default.addObserver(self, selector: #selector(centerMap(_:)), name: .centerMapToUserLocation, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(trackingMode(_:)), name: .setTrackingMode, object: nil)
            LocationManager.shared.updateMapCameraCallback = { [weak self] in
                if let mapView = self?.mapView, LocationManager.shared.isNav {
                    //LocationManager.shared.updateMapCamera(for: mapView)
                }
            }
        }
        
        // Handle long press gesture
        @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
            guard let mapView = gesture.view as? MKMapView else { return }
            
            if gesture.state == .began { // Only trigger on gesture start
                let touchPoint = gesture.location(in: mapView) // Get the point on the map
                let coordinate = mapView.convert(touchPoint, toCoordinateFrom: mapView) // Convert to coordinate
                
                print("Long press detected at: \(coordinate.latitude), \(coordinate.longitude)")
                
                DispatchQueue.main.async {
                    self.parent.centerCoordinate = coordinate // Update SwiftUI binding
                    let span = mapView.region.span
                    if span.latitudeDelta < 0.07 {
                        print("zoom - handleLongPress")
                        self.performWideSearch(in: mapView, significant: true)
                    }
                }
            }
        }
        
        @objc func centerMap(_ notification: Notification) {
            guard let location = notification.object as? CLLocation, let mapView = self.mapView else { return }
            DispatchQueue.main.async {
                let region = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
                mapView.setRegion(region, animated: true)
            }
        }
        
        @objc func trackingMode(_ notification: Notification) {
            guard let _ = notification.object as? CLLocation, let mapView = self.mapView else { return }
            DispatchQueue.main.async {
                print("tracking mode")
                mapView.userTrackingMode = .followWithHeading
            }
        }
        
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            let newCenter2 = mapView.centerCoordinate

            // Calculate distance moved
            let distance = CLLocation(latitude: lastCenterCoordinate?.latitude ?? newCenter2.latitude,
                                      longitude: lastCenterCoordinate?.longitude ?? newCenter2.longitude)
                .distance(from: CLLocation(latitude: newCenter2.latitude, longitude: newCenter2.longitude))

            if distance > parent.distanceThreshold {
                print("Map center moved \(distance) meters, updating SwiftUI state")
                DispatchQueue.main.async {
                    self.parent.centerCoordinate = newCenter2 // Triggers `updateUIView`
                }
                lastCenterCoordinate = newCenter2
            }
            
            let currentZoom = mapView.region.span.latitudeDelta
            let newCenter = CLLocation(latitude: mapView.region.center.latitude,
                                       longitude: mapView.region.center.longitude)
            print("Region changed: latitudeDelta is \(currentZoom)")

            // Check if the new center is significantly different from the last fetch.
            if let lastCenter = lastFetchedCenter {
                let distance = newCenter.distance(from: lastCenter)
                print("Distance from last fetched center: \(distance) meters")
                if distance > fetchThreshold {
                    // Significant change – refetch places for the new region.
                    lastFetchedCenter = newCenter
                    print("Significant change detected. Refetching places.")
                    if currentZoom < 0.07 {
                        print("zoom - regionDidChangeAnimated")
                        performWideSearch(in: mapView, significant: true)
                    }
                } else if distance > updateThreshold {
                    updateDisplayedAnnotations(on: mapView)

                } else {
                    if currentZoom != previousDelta {
                        //                                                                                                                                                                                                    updateDisplayedAnnotations(on: mapView)
                    } else {
                        // Not enough change – just update filtering.
                        print("Not enough change")
                    }
                }
            } else {
                // No previous fetch – save the current center and fetch.
                lastFetchedCenter = newCenter
                print("No previous fetch. Performing initial fetch.")
                if currentZoom < 0.07 {
                    print("zoom - regionDidChangeAnimated2")
                    performWideSearch(in: mapView, significant: true)
                }
            }
        }
        
        // MARK: - Overlay Renderer
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else { return MKOverlayRenderer() }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5
            return renderer
        }
        
        // MARK: - Annotation View
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKUserLocation {
                return nil
            }
            let identifier = "BusinessAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView
            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                annotationView?.isUserInteractionEnabled = true
            } else {
                annotationView?.annotation = annotation
                annotationView?.setNeedsLayout()
            }
            var desiredColor = UIColor.systemGreen
            if let title = annotation.title ?? "" {
                let lowerTitle = title.lowercased()
                if lowerTitle.contains("hospital") {
                    desiredColor = UIColor.red
                } else if lowerTitle.contains("gas") {
                    desiredColor = UIColor.orange
                } else if lowerTitle.contains("restaurant") || lowerTitle.contains("mcdonald") {
                    desiredColor = UIColor.blue
                } else if lowerTitle.contains("tire") {
                    desiredColor = UIColor.purple
                } else if lowerTitle.contains("store") {
                    desiredColor = UIColor.brown
                } else if lowerTitle.contains("cafe") {
                    desiredColor = UIColor.systemTeal
                } else if lowerTitle.contains("bank") {
                    desiredColor = UIColor.systemIndigo
                } else if lowerTitle.contains("pharmacy") {
                    desiredColor = UIColor.systemPink
                } else if lowerTitle.contains("airport") {
                    desiredColor = UIColor.systemOrange
                } else if lowerTitle.contains("school") {
                    desiredColor = UIColor.systemBlue
                } else if lowerTitle.contains("police") {
                    desiredColor = UIColor.systemBlue.withAlphaComponent(0.8)
                } else if lowerTitle.contains("post office") {
                    desiredColor = UIColor.darkGray
                } else if lowerTitle.contains("baseball") {
                    desiredColor = UIColor.systemGreen
                } else if lowerTitle.contains("hotel") {
                    desiredColor = UIColor.systemPurple
                } else if lowerTitle.contains("stadium") {
                    desiredColor = UIColor.systemYellow
                }
            }
            annotationView?.pinColor = desiredColor
            let systemImageName = "mappin.circle.fill"
            if let image = UIImage(systemName: systemImageName) {
                let tintedImage = image.withTintColor(desiredColor, renderingMode: .alwaysOriginal)
                let resizedImage = resizeImage(image: tintedImage, targetSize: CGSize(width: 20, height: 20))
                annotationView?.image = resizedImage
            }
            return annotationView
        }
        
        // MARK: - didSelect
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            guard let customAnnotation = view.annotation as? CustomPointAnnotation,
                  let placeID = customAnnotation.placeID else { return }
                    
                    // Update the selected coordinate from the annotation's coordinate.
                    AddressSearchViewModel.shared.selectedCoordinate = customAnnotation.coordinate

                    // Then fetch the full details using Google.
                    GooglePlacesService.shared.fetchPlaceDetails(for: placeID) { details in
                        DispatchQueue.main.async {
                            if let details = details {
                                print("Fetched details: \(details)")
                                AddressSearchViewModel.shared.showNavView2 = false
                                AddressSearchViewModel.shared.showNavView = true
                                AddressSearchViewModel.shared.sheetHeight = UIScreen.main.bounds.height * 0.75
                                AddressSearchViewModel.shared.showThePlaceDetails(place: details)
                            } else {
                                print("No details found for placeID: \(placeID)")
                            }
                        }
                    }
        }
        
        func coordinateToMeters(_ coordinate: CLLocationCoordinate2D) -> (x: Double, y: Double) {
            let latMeters = coordinate.latitude * 111000.0
            let lonMeters = coordinate.longitude * 111000.0 * cos(coordinate.latitude * .pi / 180.0)
            return (lonMeters, latMeters)
        }
        
        // MARK: - Progressive Filtering Based on Zoom Level
        func updateDisplayedAnnotations(on mapView: MKMapView) {

            let currentZoom = mapView.region.span.latitudeDelta
            
            // --- Dynamic Filtering Based on Zoom Level ---
            let filteredAnnotations: [MKAnnotation]
            
            if currentZoom > 0.07 {
                // Beyond 0.07: show no annotations.
                filteredAnnotations = []
            } else {
                filteredAnnotations = allAnnotations
            }
            
            print("Zoom level \(currentZoom)")
            
            // --- Density Filtering: Limit to 3 annotations per city block ---
            let cellSize: Double = 100.0
            var gridCounts: [String: Int] = [:]
            var densityFilteredAnnotations: [MKAnnotation] = []
            
            for annotation in filteredAnnotations {
                let (xMeters, yMeters) = coordinateToMeters(annotation.coordinate)
                let cellX = Int(xMeters / cellSize)
                let cellY = Int(yMeters / cellSize)
                let cellKey = "\(cellX)-\(cellY)"
                let countInCell = gridCounts[cellKey] ?? 0
                if countInCell < 3 {
                    densityFilteredAnnotations.append(annotation)
                    gridCounts[cellKey] = countInCell + 1
                }
            }
            
            // --- Sorting and Limiting ---
            let coordinate: CLLocationCoordinate2D?
            coordinate = mapView.centerCoordinate
            let mapCenter = CLLocation(latitude: coordinate?.latitude ?? 42.0, longitude: coordinate?.longitude ?? -91.0)
            
            let sortedAnnotations = densityFilteredAnnotations.sorted { annotation1, annotation2 in
                let loc1 = CLLocation(latitude: annotation1.coordinate.latitude, longitude: annotation1.coordinate.longitude)
                let loc2 = CLLocation(latitude: annotation2.coordinate.latitude, longitude: annotation2.coordinate.longitude)
                return mapCenter.distance(from: loc1) < mapCenter.distance(from: loc2)
            }
                let annotationsToDisplay = Array(sortedAnnotations.prefix(20))
                let currentAnnotations = Array(mapView.annotations).filter { !($0 is MKUserLocation) }
            withAnimation {
                mapView.removeAnnotations(currentAnnotations)
                mapView.addAnnotations(annotationsToDisplay)
            }
        }
        
        // MARK: - Google Places Wide Search with Pagination
        func performWideSearch(in mapView: MKMapView, significant: Bool) {
            var coordinate: CLLocationCoordinate2D?
            coordinate = mapView.centerCoordinate
            let radius: Double = 2500
            print("Performing Google Places wide search at coordinate: \(coordinate ?? CLLocationCoordinate2D(latitude: LocationManager.shared.latitude, longitude: LocationManager.shared.longitude)), radius: \(radius)")
            
            // Fetch annotations in the background **without removing existing ones yet**
            performGooglePlacesSearch(near: coordinate ?? CLLocationCoordinate2D(latitude: LocationManager.shared.latitude, longitude: LocationManager.shared.longitude), radius: radius) { newAnnotations in
                DispatchQueue.main.async {
                    // Only update when new annotations are fully ready
                    self.allAnnotations = newAnnotations
                    let customAnnotations = Array(mapView.annotations).filter { !($0 is MKUserLocation) }
                    print(customAnnotations)
                    self.updateDisplayedAnnotations(on: mapView)
                }
            }
        }
        // Google Places search function with pagination.
        func performGooglePlacesSearch(near coordinate: CLLocationCoordinate2D, radius: Double = 1000, completion: @escaping ([CustomPointAnnotation]) -> Void) {
            //let excludedTypes: [String] = [] // Specify the types you want to include
            var apiKey: String {
                guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
                      let secrets = NSDictionary(contentsOfFile: filePath),
                      let token = secrets["GooglePlacesAPIKey"] as? String,
                      !token.isEmpty else {
                    fatalError("GooglePlacesAPIKey not set in Secrets.plist")
                }
                return token
            }
            var allAnnotations: [CustomPointAnnotation] = []
            
            func fetchPage(urlString: String) {
                guard let url = URL(string: urlString) else {
                    completion(allAnnotations)
                    return
                }
                print("Google places search url: \(urlString)")
                URLSession.shared.dataTask(with: url) { data, response, error in
                    if let error = error {
                        print("Google Places error: \(error.localizedDescription)")
                        DispatchQueue.main.async { completion(allAnnotations) }
                        return
                    }
                    guard let data = data else {
                        DispatchQueue.main.async { completion(allAnnotations) }
                        return
                    }
                    do {
                        let placesResponse = try JSONDecoder().decode(GooglePlacesResponse.self, from: data)
                        print("google places search raw data: \(placesResponse)")

                        for place in placesResponse.results {

                                    let annotation = CustomPointAnnotation()
                                    
                                    annotation.coordinate = CLLocationCoordinate2D(latitude: place.geometry.location.lat, longitude: place.geometry.location.lng)
                                    annotation.title = place.name
                                    annotation.subtitle = place.vicinity
                                    // Loop over all types to assign a category.
                                    var mappedCategory: MKPointOfInterestCategory? = nil
                                    for type in place.types {
                                        if let cat = mapGoogleTypeToPOICategory(type) {
                                            mappedCategory = cat
                                            break
                                        }
                                    }
                                    if mappedCategory == nil {
                                        mappedCategory = .stadium // Default category if none mapped.
                                    }
                                    annotation.category = mappedCategory
                                    // Store the place ID.
                                    annotation.placeID = place.place_id
                                    
                                    allAnnotations.append(annotation)
                                }
                        /*
                            }
                        }
                         */
                        
                        if let nextPageToken = placesResponse.next_page_token {
                            // Google requires a delay before next_page_token is active.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                let nextUrlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=\(nextPageToken)&key=\(apiKey)"
                                fetchPage(urlString: nextUrlString)
                            }
                        } else {
                            DispatchQueue.main.async {
                                completion(allAnnotations)
                            }
                        }
                    } catch {
                        print("Error decoding Google Places: \(error)")
                        DispatchQueue.main.async { completion(allAnnotations) }
                    }
                }.resume()
            }
            
            let initialUrlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=\(coordinate.latitude),\(coordinate.longitude)&radius=\(radius)&types=&key=\(apiKey)"
            fetchPage(urlString: initialUrlString)
        }
        
        // MARK: - Image Resizing Helper
        func resizeImage(image: UIImage?, targetSize: CGSize) -> UIImage? {
            guard let image = image else { return nil }
            let size = image.size
            let widthRatio  = targetSize.width  / size.width
            let heightRatio = targetSize.height / size.height
            let scaleFactor = min(widthRatio, heightRatio)
            let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
            let renderer = UIGraphicsImageRenderer(size: newSize)
            let newImage = renderer.image { _ in
                image.draw(in: CGRect(origin: .zero, size: newSize))
            }
            return newImage
        }
    }
}

// MARK: - RoundedCornerShape
struct RoundedCornerShape: Shape {
    var radius: CGFloat
    var corners: UIRectCorner
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - MapsView_Previews
struct MapsView_Previews: PreviewProvider {
    @State static var addressTitle: String = ""
    @State static var showNavView: Bool = true
    static var previews: some View {
        MapsView(locationManager: LocationManager.shared,
                 addressSearchViewModel: AddressSearchViewModel.shared,
                 addressTitle: $addressTitle)
    }
}

extension Notification.Name {
    static let locationManagerDidUpdateLocation = Notification.Name("locationManagerDidUpdateLocation")
}
