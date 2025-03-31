

import Foundation
import MapKit

protocol LocationSearchServiceDelegate: AnyObject {
    func didUpdateResults(_ results: [MKLocalSearchCompletion])
}

class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    
    weak var delegate: LocationSearchServiceDelegate?
    
    private var searchCompleter = MKLocalSearchCompleter()
    private var searchResults: [MKLocalSearchCompletion] = []
    
    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func updateSearchQuery(_ query: String) {
        searchCompleter.queryFragment = query
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        delegate?.didUpdateResults(searchResults)
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Search error: \(error.localizedDescription)")
    }
}
