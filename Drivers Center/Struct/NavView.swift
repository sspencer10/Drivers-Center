import SwiftUI
import MapKit
import CoreLocation
import Combine

struct AddressSearchView: View {
    
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    @ObservedObject var locMan: LocationManager
    @Binding var searchText: String



    var body: some View {
        ZStack {
            // Transparent background to detect taps outside the TextField
            Color.clear
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            VStack {
                if addressSearchViewModel.selectedPlace == nil {
                    
                    // Search TextField
                    TextField("Enter an address...", text: $searchText)
                        .padding()
                        .background(Color("darkerGray"))
                        .cornerRadius(20) // Round the corners
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color("darkerGray"), lineWidth: 1) // Optional: Border
                        )
                        .padding(.top, 25)
                        .padding()
                        .onChange(of: searchText) { newValue, _ in
                            if newValue.isEmpty {
                                print("test - Search text cleared")
                                addressSearchViewModel.clearSuggestions() // Clear suggestions when searchText is empty
                            } else {
                                print("test - Search text changed to '\(newValue)'")
                                DispatchQueue.main.async {
                                    addressSearchViewModel.updateSearchResults(for: newValue)
                                }
                            }
                        }
                        .onChange(of: locMan.isNav) { newValue, _ in
                            if newValue {
                                addressSearchViewModel.selectedCoordinate = nil
                            }
                        }
                        .padding(.top, 15)
                }
                // Suggestions List
                if !addressSearchViewModel.suggestions.isEmpty {
                    List(AddressSearchViewModel.shared.suggestions, id: \.title) { suggestion in
                        Button(action: {
                            // Build a query string from the suggestion.
                            let query = suggestion.subtitle.isEmpty ? suggestion.title : "\(suggestion.title) \(suggestion.subtitle)"
                            
                            // Clear suggestions immediately.
                            addressSearchViewModel.clearSuggestions()
                            addressSearchViewModel.fetchApplePlaceDetails(for: query, completion: { item in
                                let name = item?.name?.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ", United States", with: "")
                                addressSearchViewModel.selectedAddress = name
                            })
                            // First, find the Google Place ID using the query.
                            GooglePlacesService.shared.findPlaceId(for: query) { placeID in
                                guard let placeID = placeID else {
                                    print("Failed to find a place ID for query: \(query)")
                                    return
                                }
                                // Once the placeID is retrieved, fetch the full details.
                                GooglePlacesService.shared.fetchPlaceDetails(for: placeID) { googleDetails in
                                    DispatchQueue.main.async {
                                        addressSearchViewModel.selectedPlace = googleDetails
                                        addressSearchViewModel.selectedCoordinate = googleDetails?.geometry
                                        addressSearchViewModel.showPlace = true
                                    }
                                }
                            }
                            
                            // Clear suggestions after a slight delay.
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
                                addressSearchViewModel.suggestions = []
                            }
                        }) {
                            VStack(alignment: .leading) {
                                Text(suggestion.title)
                                    .font(.headline)
                                if !suggestion.subtitle.isEmpty {
                                    Text(suggestion.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                        
                        }
                    }
                
                } else {
                    Text("").italic()
                }
                
                if addressSearchViewModel.showPlace {
                    // Display PlaceDetailsView with a proper fallback.
                    PlaceDetailsView(
                        addressSearchViewModel: addressSearchViewModel,
                        searchText: $searchText,
                        place: addressSearchViewModel.selectedPlace ?? PlaceDetails(mapItem: MKMapItem().self).self
                    )
                }


                Spacer()
            }
        }
    }
}

class AddressSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    public static var shared = AddressSearchViewModel()

    @Published var addressTitle: String = ""
    @Published var suggestions: [MKLocalSearchCompletion] = [] // Store MKLocalSearchCompletion
    @Published var selectedAddress: String?
    @Published var selectedCoordinate: CLLocationCoordinate2D?
    @Published var sheetHeight: CGFloat = 300
    @Published var selectedPlace: PlaceDetails?
    @Published var showPlace: Bool = false
    @Published var showNavView: Bool = true
    @Published var showNavView2: Bool = false
    @Published var showNavView3: Bool = false
    @Published var showNavView4: Bool = false


    private var searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init()
        searchCompleter.resultTypes = [.pointOfInterest, .address]
        searchCompleter.delegate = self
    }
    
    func updateSearchResults(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        
        // Bias search suggestions based on the user's current location if available.
        if let userLocation = LocationManager.shared.lm.location {
            let region = MKCoordinateRegion(center: userLocation.coordinate,
                                            latitudinalMeters: 1000,
                                            longitudinalMeters: 1000)
            searchCompleter.region = region
        }
        
        searchCompleter.queryFragment = query
    }
    
    func showThePlaceDetails(place: PlaceDetails) {
        selectedPlace = place
        showPlace = true
    }

    func clearSuggestions() {
        print("cleared suggestions")
        suggestions = []
    }

    /// Existing search function (if needed elsewhere)
    func search(for address: String) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = address

        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("test - Error fetching coordinates: \(error.localizedDescription)")
                return
            }

            guard let coordinate = response?.mapItems.first?.placemark.coordinate else {
                print("test - No coordinate found for \(address)")
                return
            }

            DispatchQueue.main.async {
                //self.selectedAddress = address
                self.selectedCoordinate = coordinate
                print("test - Selected address: \(address), Coordinate: \(coordinate)")
            }
        }
    }
 
    /// New function to fetch full place details from Apple.
    func fetchApplePlaceDetails(for query: String, completion: @escaping (MKMapItem?) -> Void) {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = query
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            if let error = error {
                print("Error fetching Apple place details: \(error.localizedDescription)")
                completion(nil)
                return
            }
            if let item = response?.mapItems.first {
                DispatchQueue.main.async {
                    //self.selectedAddress = query
                }
                completion(item)
            } else {
                completion(nil)
            }
        }
    }

    // MARK: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("test - Error updating suggestions: \(error.localizedDescription)")
    }
}

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - PlaceDetails Struct
// MARK: - PlaceDetails Struct
struct PlaceDetails: Identifiable {
    let id = UUID()
    let name: String
    let address: String?
    let vicinity: String?
    let geometry: CLLocationCoordinate2D?
    let phone: String?
    let website: URL?
    let hours: String?
    let placeID: String?
    let images: [URL]?
    
    // Existing initializer using MKMapItem (unused now).
    init(mapItem: MKMapItem) {
        self.name = mapItem.name ?? "Unknown Place"
        self.address = nil
        self.vicinity = nil
        self.geometry = nil
        self.phone = mapItem.phoneNumber
        self.website = mapItem.url
        self.hours = nil
        self.placeID = nil
        self.images = [
            URL(string: "https://example.com/image1.jpg"),
            URL(string: "https://example.com/image2.jpg")
        ].compactMap { $0 }
    }
    
    // New initializer for Google Place Details.
    init(name: String, address: String, vicinity: String?, geometry: CLLocationCoordinate2D, phone: String?, website: URL?, hours: String?, placeID: String?, images: [URL]?) {
        self.name = name
        self.address = address
        self.vicinity = vicinity
        self.geometry = geometry
        self.phone = phone
        self.website = website
        self.hours = hours
        self.placeID = placeID
        self.images = images
    }
}

// MARK: - PlaceDetailsView
struct PlaceDetailsView: View {
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    @State var eta: String = ""
    @Binding var searchText: String
    private var fullScreenHeight: CGFloat {
        UIScreen.main.bounds.height
    }
    let place: PlaceDetails

    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            Text(place.name)
                .font(.largeTitle)
                .bold()
                .padding(.horizontal)
                .padding(.top)
            
            HStack(alignment: .top, spacing: 8) {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.gray)
                    .font(.title3)
                Text(place.address ?? "")
                    .font(.body)
                    .foregroundColor(.gray)
                    .lineLimit(3)
            }
            .padding(.horizontal)
            
            HStack(spacing: 16) {
                if let coordinate = addressSearchViewModel.selectedCoordinate {
                    CustomButton(iconName: "car.fill", label: eta, color: .blue, labelColor: .white) {
                        print("nav button")
                        
                        LocationManager.shared.startNavigation(to: coordinate)
                        withAnimation {
                            addressSearchViewModel.sheetHeight = fullScreenHeight * 0.30
                            addressSearchViewModel.showNavView = false
                            addressSearchViewModel.showNavView2 = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            LocationManager.shared.startNavigation(to: coordinate)
                        }
                    }
                } else {
                    CustomButton(iconName: "car.fill", label: eta, color: .blue, labelColor: .white.opacity(0.3)) {
                        print("Error - no coordinate")
                    }
                }
                
                if let phone = place.phone {
                    CustomButton(iconName: "iphone.gen2", label: "Call", color: .gray, labelColor: .white) {
                        print("phone \(phone)")
                        if let phoneURL = URL(string: "tel://\(phone)") {
                            UIApplication.shared.open(phoneURL)
                        } else {
                            print("details error \(phone)")
                        }
                    }
                } else {
                    CustomButton(iconName: "iphone.gen2.slash", label: "Call", color: .gray.opacity(0.3), labelColor: .white.opacity(0.3)) {
                        print("Error - no phone")
                    }
                }
                
                if let website = place.website {
                    CustomButton(iconName: "network", label: "Website", color: .gray, labelColor: .white) {
                        print("website \(website)")
                        UIApplication.shared.open(website)
                    }
                } else {
                    CustomButton(iconName: "network.slash", label: "Website", color: .gray.opacity(0.3), labelColor: .white.opacity(0.3)) {
                        print("Error - no website")
                    }
                }
                
                CustomButton(iconName: "x.circle", label: "Close", color: .red, labelColor: .white) {
                    print("close")
                    AddressSearchViewModel.shared.showPlace = false
                    searchText = ""
                    addressSearchViewModel.clearSuggestions()
                    addressSearchViewModel.selectedPlace = nil
                    addressSearchViewModel.sheetHeight = fullScreenHeight * 0.20
                }
            }
            .padding()
            .onAppear {
                LocationManager.shared.calculateETA(to: AddressSearchViewModel.shared.selectedCoordinate ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0), completion: { x in
                    eta = LocationManager.shared.formatETA(seconds: x ?? .zero)
                })
            }
            ScrollView {
                if let businessHours = place.businessHours, !businessHours.isEmpty {
                    BusinessHoursIndicatorView(place: place)
                        .padding()
                }
                
                
                    
                
                VStack {
                    if let images = place.images, !images.isEmpty, let firstImage = images.first {
                        AsyncImage(url: firstImage) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 337.5, height: 225)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 337.5, height: 225)
                                    .cornerRadius(8)
                            case .failure:
                                Image(systemName: "photo")
                                    .frame(width: 337.5, height: 225)
                                    .background(Color.gray.opacity(0.2))
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .frame(height: 225)
                        .padding(.bottom, 125)
                    }
                }
                .padding()
            }
        }
        .padding()
        .navigationTitle("Place Details")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            UIApplication.shared.dismissKeyboard()
            searchText = ""
            addressSearchViewModel.clearSuggestions()
            addressSearchViewModel.sheetHeight = fullScreenHeight * 0.75
        }
    }
}

struct CustomButton: View {
    let iconName: String
    let label: String
    let color: Color
    let labelColor: Color
    let action: () -> Void

    var body: some View {
        // Wrap the action with a print statement.
        let wrappedAction = {
            print("Button with label \"\(label)\" tapped")
            action()
        }
        return Button(action: wrappedAction) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(labelColor)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(labelColor)
            }
            .frame(width: 70, height: 70)
            .background(color)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Google Places Service (Place Details)
class GooglePlacesService {
    static let shared = GooglePlacesService()
    private var apiKey: String {
        guard let filePath = Bundle.main.path(forResource: "Secrets", ofType: "plist"),
              let secrets = NSDictionary(contentsOfFile: filePath),
              let token = secrets["GooglePlacesAPIKey"] as? String,
              !token.isEmpty else {
            fatalError("GooglePlacesAPIKey not set in Secrets.plist")
        }
        return token
    }
    
    // Fetch Place Details solely from Google using the Place Details API.
    func fetchPlaceDetails(for placeID: String, completion: @escaping (PlaceDetails?) -> Void) {
        let fields = "geometry,formatted_address,formatted_phone_number,name,photos,website,opening_hours"
        let urlString = "https://maps.googleapis.com/maps/api/place/details/json?place_id=\(placeID)&fields=\(fields)&key=\(apiKey)"
        print("find details url: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Google Place Details error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let detailsResponse = try JSONDecoder().decode(GooglePlaceDetailsResponse.self, from: data)
                print("Google place details raw date: \(detailsResponse)")
                var hoursString: String? = nil
                if let openingHours = detailsResponse.result.opening_hours,
                   let weekdayText = openingHours.weekday_text {
                    hoursString = weekdayText.joined(separator: "\n")
                }
                var imageURLs: [URL] = []
                if let candidatePhotos = detailsResponse.result.photos {
                    for photo in candidatePhotos {
                        let photoReference = photo.photo_reference
                        let photoURLString = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(self.apiKey)"
                        if let photoURL = URL(string: photoURLString) {
                            imageURLs.append(photoURL)
                        }
                    }
                }
                // Convert the decoded geometry (GoogleLocation) into a CLLocationCoordinate2D.
                let coordinate: CLLocationCoordinate2D = {
                    if let loc = detailsResponse.result.geometry?.location {
                        return CLLocationCoordinate2D(latitude: loc.lat, longitude: loc.lng)
                    } else {
                        return CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0)
                    }
                }()
                let placeDetails = PlaceDetails(
                    name: detailsResponse.result.name ?? "Unknown Place",
                    address: detailsResponse.result.formatted_address ?? "",
                    vicinity: detailsResponse.result.formatted_address ?? "",
                    geometry: coordinate,
                    phone: detailsResponse.result.formatted_phone_number,
                    website: detailsResponse.result.website != nil ? URL(string: detailsResponse.result.website!) : nil,
                    hours: hoursString,
                    placeID: nil,
                    images: imageURLs
                )
                DispatchQueue.main.async {
                    AddressSearchViewModel.shared.selectedPlace = placeDetails
                    print("place coordinates: \(placeDetails.geometry ?? CLLocationCoordinate2D(latitude: 0.0, longitude: 0.0))")
                    print("Google Place Details structured data: \(placeDetails)")
                    completion(placeDetails)
                }
            } catch {
                print("Google Place Details decoding error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}

// MARK: - Google Places Response Models

struct GooglePlaceCandidate2: Codable {
    let place_id: String
}

struct GooglePlaceFindResponse2: Codable {
    let candidates: [GooglePlaceCandidate2]
    let status: String
}

struct GooglePlaceFindResponse: Codable {
    let candidates: [GooglePlaceCandidate]
    let status: String
}

struct GooglePlaceCandidate: Codable {
    let place_id: String
    let name: String
    let formatted_address: String
    let opening_hours: GooglePlaceOpeningHours?
    let photos: [GooglePlacePhoto]?
}

struct GooglePlaceOpeningHours: Codable {
    let weekday_text: [String]?
}

struct GooglePlacePhoto: Codable {
    let photo_reference: String
    let height: Int?
    let width: Int?
}



// MARK: - Google Place Details Response Models
struct GooglePlaceDetailsResponse: Codable {
    let result: GPDetailsResult
    let status: String
}

struct GPDetailsResult: Codable {
    let geometry: GPGeometry?
    let opening_hours: GPOpeningHours?
    let formatted_address: String?
    let formatted_phone_number: String?
    let name: String?
    let photos: [GPPhoto]?
    let website: String?
}

struct GPGeometry: Codable {
    let location: GPLocation
}

struct GPLocation: Codable {
    let lat: Double
    let lng: Double
}

struct GPOpeningHours: Codable {
    let weekday_text: [String]?
}

struct GPPhoto: Codable {
    let photo_reference: String
    let height: Int?
    let width: Int?
}

struct BusinessHour: Identifiable {
    let id = UUID()
    let day: String
    let openTime: DateComponents
    let closeTime: DateComponents
}


extension PlaceDetails {
    var businessHours: [BusinessHour]? {
        guard let hoursString = self.hours else { return nil }
        let weekdayText = hoursString.components(separatedBy: "\n")
        return PlaceDetails.parseBusinessHours(from: weekdayText)
    }
    
    static func parseBusinessHours(from weekdayText: [String]) -> [BusinessHour] {
        var businessHours: [BusinessHour] = []
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "h:mm a"
        timeFormatter.locale = Locale(identifier: "en_US_POSIX")
        for text in weekdayText {
            let parts = text.split(separator: ":", maxSplits: 1).map { $0.trimmingCharacters(in: .whitespaces) }
            guard parts.count == 2 else { continue }
            let day = parts[0]
            let timeSeparators = ["–", "-"]
            var times: [String] = []
            for separator in timeSeparators {
                if parts[1].contains(separator) {
                    times = parts[1].components(separatedBy: separator).map { $0.trimmingCharacters(in: .whitespaces) }
                    break
                }
            }
            guard times.count == 2,
                  let openDate = timeFormatter.date(from: times[0]),
                  let closeDate = timeFormatter.date(from: times[1]) else { continue }
            let calendar = Calendar.current
            let openComponents = calendar.dateComponents([.hour, .minute], from: openDate)
            let closeComponents = calendar.dateComponents([.hour, .minute], from: closeDate)
            let businessHour = BusinessHour(day: day, openTime: openComponents, closeTime: closeComponents)
            businessHours.append(businessHour)
        }
        return businessHours
    }
    
    func isCurrentlyOpen(at date: Date = Date(), calendar: Calendar = Calendar.current) -> Bool {
        guard let businessHours = self.businessHours else { return false }
        let weekdayNames = calendar.weekdaySymbols
        let currentWeekdayIndex = calendar.component(.weekday, from: date) - 1
        let currentWeekday = weekdayNames[currentWeekdayIndex]
        guard let todayHours = businessHours.first(where: { $0.day.caseInsensitiveCompare(currentWeekday) == .orderedSame }) else {
            return false
        }
        let currentComponents = calendar.dateComponents([.hour, .minute], from: date)
        guard let currentHour = currentComponents.hour, let currentMinute = currentComponents.minute else {
            return false
        }
        let currentMinutes = currentHour * 60 + currentMinute
        let openMinutes = (todayHours.openTime.hour ?? 0) * 60 + (todayHours.openTime.minute ?? 0)
        let closeMinutes = (todayHours.closeTime.hour ?? 0) * 60 + (todayHours.closeTime.minute ?? 0)
        return currentMinutes >= openMinutes && currentMinutes < closeMinutes
    }
}

extension GooglePlacesService {
    func findPlaceId(for query: String, completion: @escaping (String?) -> Void) {
        // URL-encode the query.
        guard let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            completion(nil)
            return
        }
        // Build the URL for the Find Place From Text request.
        let urlString = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=\(encodedQuery)&inputtype=textquery&fields=place_id&key=\(apiKey)"
        print("findPlaceID query url: \(urlString)")
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Find Place error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(nil) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(nil) }
                return
            }
            do {
                let response = try JSONDecoder().decode(GooglePlaceFindResponse2.self, from: data)
                // Return the place_id from the first candidate.
                let placeID = response.candidates.first?.place_id
                DispatchQueue.main.async {
                    completion(placeID)
                }
            } catch {
                print("Decoding find place error: \(error)")
                DispatchQueue.main.async { completion(nil) }
            }
        }.resume()
    }
}


