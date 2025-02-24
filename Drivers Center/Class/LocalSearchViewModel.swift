//
//  LocalSearchViewModel.swift
//  Drivers Center
//
//  Created by Steven Spencer on 2/9/25.
//

import SwiftUI
import MapKit

class LocalSearchViewModel: NSObject, ObservableObject {
    @Published var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    @Published var suggestions: [MKLocalSearchCompletion] = []

    private var completer: MKLocalSearchCompleter
    private var search: MKLocalSearch?

    override init() {
        completer = MKLocalSearchCompleter()
        completer.resultTypes = [.address, .pointOfInterest]
        super.init()
        completer.delegate = self
    }

    func fetchPlace(for suggestion: MKLocalSearchCompletion, completion: @escaping (PlaceDetails?) -> Void) {
        // This initializer automatically sets up the query and the place identifier.
        let request = MKLocalSearch.Request(completion: suggestion)
        request.resultTypes = [.pointOfInterest]

        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                print("Error fetching place details: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let mapItem = response?.mapItems.first else {
                print("No place details found.")
                completion(nil)
                return
            }

            // Create PlaceDetails from the mapItem
            let placeDetails = PlaceDetails(mapItem: mapItem)
            completion(placeDetails)
        }
    }
}

extension LocalSearchViewModel: MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.suggestions = completer.results
        }
    }
}
