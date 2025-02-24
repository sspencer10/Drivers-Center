class LocalSearchViewModel: ObservableObject {
    @Published var queryFragment: String = "" {
        didSet {
            completer.queryFragment = queryFragment
        }
    }
    @Published var suggestions: [MKLocalSearchCompletion] = []

    private var completer: MKLocalSearchCompleter
    private var search: MKLocalSearch?

    init() {
        completer = MKLocalSearchCompleter()
        completer.resultTypes = [.address, .pointOfInterest]
        completer.delegate = self
    }

    func fetchPlace(for suggestion: MKLocalSearchCompletion, completion: @escaping (PlaceDetails?) -> Void) {
        let request = MKLocalSearch.Request(completion: suggestion)
        search = MKLocalSearch(request: request)
        search?.start { response, error in
            guard let mapItem = response?.mapItems.first else {
                completion(nil)
                return
            }
            completion(PlaceDetails(mapItem: mapItem))
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