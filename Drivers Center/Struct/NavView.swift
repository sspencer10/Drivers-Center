import SwiftUI
import MapKit
import CoreLocation
import Combine

struct NavView: View {
    @ObservedObject var viewModel: LocationManager
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    
    @State private var currentStep: String = "No step available"
    @State private var remainingSteps: [String] = []
    @State private var dist: Double = 0.0
    @State private var searchText = ""
    //@State private var selectedCoordinate: CLLocationCoordinate2D?

    var body: some View {
        VStack {
            if currentStep.isEmpty {
                // Address Search Section
                AddressSearchView(addressSearchViewModel: addressSearchViewModel, searchText: $searchText)
                
                Divider()
            } else {
                
                // End Navigation Button
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
                
                Divider()
            
                // Current Step and Remaining Steps Section
                NavigationStepsView(currentStep: $currentStep, remainingSteps: $remainingSteps, dist: $dist)
            }
        }
        .navigationBarHidden(true) // Hides `< More` button if present
        .onAppear {
            initializeState()
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
    }

    private func initializeState() {
        DispatchQueue.main.async {
            currentStep = viewModel.currentStep
            remainingSteps = viewModel.remainingSteps
            dist = viewModel.disToCurrentStep
            //selectedCoordinate = addressSearchViewModel.selectedCoordinate

            print("test - Current step: \(currentStep)")
            print("test - Remaining steps: \(remainingSteps)")
            print("test - Distance to next step: \(dist)")
        }
    }
    
    private func endNavigation() {
        print("test - Ending navigation")
        viewModel.endNavigation() // Call the new method to stop navigation
        currentStep = "No step available"
        remainingSteps = []
        dist = 0.0
        searchText = ""
    }
}

struct AddressSearchView: View {
    
    @ObservedObject var addressSearchViewModel: AddressSearchViewModel
    @Binding var searchText: String
    //@Binding var selectedCoordinate: CLLocationCoordinate2D?

    var body: some View {
        ZStack {
            // Transparent background to detect taps outside the TextField
            Color.clear
                .onTapGesture {
                    UIApplication.shared.dismissKeyboard()
                }
            
            VStack {
                // Search TextField
                TextField("Enter an address...", text: $searchText)
                    //.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color("darkerGray"))
                    .cornerRadius(20) // Round the corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("darkerGray"), lineWidth: 1) // Optional: Border
                    )
                    .padding(.top, 25)
                    .padding()
                    .onChange(of: searchText) {
                        if searchText.isEmpty {
                            print("test - Search text cleared")
                            AddressSearchViewModel.shared.clearSuggestions() // Clear suggestions when searchText is empty
                        } else {
                            print("test - Search text changed to '\(searchText)'")
                            DispatchQueue.main.async {
                                AddressSearchViewModel.shared.updateSearchResults(for: searchText)
                            }
                        }
                    }
                    .padding(.top, 15)

                

                // Suggestions List
                if !AddressSearchViewModel.shared.suggestions.isEmpty {
                    List(AddressSearchViewModel.shared.suggestions, id: \.title) { suggestion in
                        Button(action: {
                            if !suggestion.subtitle.isEmpty {
                                AddressSearchViewModel.shared.search(for: "\(suggestion.title) \(suggestion.subtitle)")
                                searchText = "\(suggestion.title) \(suggestion.subtitle)"
                                AddressSearchViewModel.shared.clearSuggestions()
                            } else {
                                AddressSearchViewModel.shared.search(for: suggestion.title)
                                searchText = "\(suggestion.title)"
                                AddressSearchViewModel.shared.clearSuggestions()
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

                // Start Navigation Button
                Button(action: {
                    UIApplication.shared.dismissKeyboard() // Hide the keyboard
                    if let coordinate = AddressSearchViewModel.shared.selectedCoordinate {
                        print("test - Starting navigation to coordinate: \(coordinate)")
                        LocationManager.shared.startNavigation(to: coordinate)
                    }
                }) {
                    Text("Start Navigation")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(addressSearchViewModel.selectedCoordinate != nil ? Color.blue : Color("darkerGray"))
                        .cornerRadius(20)
                }
                .padding()
                .disabled(addressSearchViewModel.selectedCoordinate == nil) // Disable if no coordinate selected
                Spacer()
                
            }
        }
    }
}

// MARK: - Navigation Steps Component
struct NavigationStepsView: View {
    @Binding var currentStep: String
    @Binding var remainingSteps: [String]
    @Binding var dist: Double

    var body: some View {
        VStack {
            Text("\(AddressSearchViewModel.shared.selectedAddress ?? "")")
                .font(.headline)
            Text("\(LocationManager.shared.eta) til Arrival")
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

            // Remaining Steps
            Text("Remaining Steps:")
                .font(.headline)
                .padding()
            if remainingSteps.isEmpty {
                Text("No remaining steps").italic()
            } else {
                List(remainingSteps, id: \.self) { step in
                    Text(step)
                }
            }
        }
    }

}

class AddressSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    
    public static var shared = AddressSearchViewModel()

    
    @Published var suggestions: [MKLocalSearchCompletion] = [] // Store MKLocalSearchCompletion
    @Published var selectedAddress: String?
    @Published var selectedCoordinate: CLLocationCoordinate2D?

    private var searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init()
        searchCompleter.resultTypes = .address
        searchCompleter.delegate = self
    }

    func updateSearchResults(for query: String) {
        guard !query.isEmpty else {
            suggestions = []
            return
        }
        searchCompleter.queryFragment = query
    }

    func clearSuggestions() {
        print("cleared suggestions")
        suggestions = []
    }

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
                self.selectedAddress = address
                self.selectedCoordinate = coordinate
                print("test - Selected address: \(address), Coordinate: \(coordinate)")
            }
        }
    }

    // MARK: - MKLocalSearchCompleterDelegate
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results // Store MKLocalSearchCompletion
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
