import UIKit
import MusicKit
import SwiftUI
import CarPlay
import MapKit
import Foundation
import Combine
import CoreLocation
import Intents
import MediaPlayer
import Combine


// Define a protocol
protocol MyDelegate: AnyObject {
    func didUpdateValue(_ newValue: Bool)
}

class TemplateManager: NSObject, ObservableObject, CPInterfaceControllerDelegate, CPSessionConfigurationDelegate  {
    
    public static var shared = TemplateManager()

    
    @Published var currentTime: String = ""
    
    @AppStorage("gps_location", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var gps_location: String = ""
    @AppStorage("today_min", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var today_min: Double = 60.0
    @AppStorage("today_max", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var today_max: Double = 70.0
    @AppStorage("current_f", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var current_f: Double = 0.0

    //@ObservedObject var wvm: WeatherViewModel
    var mediaClass = MediaItemViewModel.shared
    @State var nowPlayingArtist: String?
    @State var nowPlayingTitle: String?
    @State var currentTemplate: String?
    @State var updateAllowed: Bool?
    @State var title2: String = ""
    @State var doorStatus: String?
    @State var lightStatus: String?
    @State var doorStatus2: Bool = false
    @State var myCnt: Int = 0
    
    private var cancellables = Set<AnyCancellable>()
    //private var timer: Timer?
    private var currentOffset = 0
    private let batchSize = 10
    private let batchSize2 = 10
    let albumBatchSize = 10
    let playlistBatchSize = 10
    
    weak var delegate: MyDelegate?
    
    @Published var isCarPlay: Bool = false
    var window: UIWindow?
    var enableCarPlay: Bool = true
    var carplayInterfaceController: CPInterfaceController?
    var sessionConfiguration: CPSessionConfiguration!
    var tabTemplates = [CPTemplate]()
    var sections: [CPListSection]?
    var sections2: [CPListSection]?
    var carplayScene: CPTemplateApplicationScene?
    var addressString: String = ""
    var counter: Int = 0
    
    var listTemplate: CPTemplate!
    var cc = CurlCommands()
    var artImg: UIImage?
    var playlists: [MPMediaPlaylist] = []
    var previousType: String = ""
    var url: URL!
    var url2: URL!
    var isAlternateDetailText = false
    var updateCounter = 0
    var textA: String = ""
    var textB: String = ""
    private let speechRecognizer = SpeechRecognizer()
    private let speechRecognizer2 = SpeechRecognizer()
    private var musicPlayer: MPMusicPlayerController
    //var myTimer: Timer?
    //var myTimer2: Timer?
    //var myTimer3: Timer?
    var cnt: Int = .zero

    
    let configuration = UIImage.SymbolConfiguration.init(pointSize: 10)

    private override init() {
        musicPlayer = MediaItemViewModel.shared.musicPlayer
        super.init()
        self.setupVoiceSearch()
        self.setupVoiceSearch2()
        //self.musicPlayer = MPMusicPlayerController.systemMusicPlayer
        self.musicPlayer = MPMusicPlayerController.applicationQueuePlayer
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemDidChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        LocationManager.shared.$speed
            .sink { [weak self] newSpeed in
                if self?.isCarPlay == false { return }
                self?.updateTemplate(with: newSpeed)
            }
            .store(in: &cancellables)
    }
    
    var artUrl: String = "https://rightdevllc.com/images/592590040.png"

    //Called when CarPlay connects.
    func connect(_ interfaceController: CPInterfaceController, scene: CPTemplateApplicationScene) {
        
        carplayInterfaceController = interfaceController
        carplayScene = scene
        carplayInterfaceController!.delegate = self
        sessionConfiguration = CPSessionConfiguration(delegate: self)
        isCarPlay = true
        CarPlayObserver.shared.setCarPlay(true)
        //startCarPlayTimer()
        //startCPTimer()
        //startTimer()
        print("test 44 - \(LocationManager.shared.latitude)")
        
        Task {
            WeatherViewModel.shared.fetchText()
            WeatherViewModel.shared.fetchWeather()
        }
        
        let viewModel = MediaItemViewModel.shared
        let _ = fetchImage4(from: mediaClass.newArt?.absoluteString ?? "")
        Task {
            let img = await getSong()
            self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: img, speedo: self.getSpeedo(), detailedText: LocationManager.shared.eta, completion: {x in
                let carPlayTemplate = x
                self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
            })
            
        }
    }
    
    //Called when CarPlay disconnects.
    func disconnect() {
        //stopCarPlayTimer()
        carplayScene = nil
        print("updating isCarPlay to false")
        isCarPlay = false
        CarPlayObserver.shared.setCarPlay(false)
    }
    
    func setupVoiceSearch2() {
        print("voice search init")
        speechRecognizer2.onRecognitionComplete = { [weak self] recognizedText in
            print("Recognized text: \(recognizedText ?? "No text recognized")")
            guard let self = self else { return }

            if let query = recognizedText {
                print("Recognized text: \(query)")
                
                // Trigger the search with the recognized text
                Task {
                    do {
                        let _ = try await self.promptForSearchQuery2(with: query)
                        // Go home
                        let viewModel = MediaItemViewModel.shared
                        let _ = self.fetchImage4(from: self.mediaClass.newArt?.absoluteString ?? "")
                        Task {
                            let img = await self.getSong()
                            self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: img, speedo: self.getSpeedo(), detailedText: LocationManager.shared.eta, completion: {x in
                                let carPlayTemplate = x
                                self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                            })
                            //self.presentSearchResults(results: results)
                        }
                    } catch {
                        print("Error during search: \(error)")
                    }
                }
            } else {
                // Handle no input case
                print("No input received. Please try again.")
            }
        }

        speechRecognizer2.onError = { error in
            print("Speech recognition error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }
    
    func setupVoiceSearch() {
        print("voice search init")
        speechRecognizer.onRecognitionComplete = { [weak self] recognizedText in
            print("Recognized text: \(recognizedText ?? "No text recognized")")
            guard let self = self else { return }

            if let query = recognizedText {
                print("Recognized text: \(query)")
                
                // Trigger the search with the recognized text
                Task {
                    do {
                        let results = try await self.promptForSearchQuery(with: query)
                        self.presentSearchResults(results: results)
                    } catch {
                        print("Error during search: \(error)")
                    }
                }
            } else {
                // Handle no input case
                print("No input received. Please try again.")
            }
        }

        speechRecognizer.onError = { error in
            print("Speech recognition error: \(error?.localizedDescription ?? "Unknown error")")
        }
    }

    func startVoiceSearch() {
        speechRecognizer.startRecognition()
    }
    
    func startVoiceSearch2() {
        speechRecognizer2.startRecognition()
    }
    
    func promptForSearchQuery2(with recognizedText: String) async throws {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = recognizedText

        let search = MKLocalSearch(request: searchRequest)

        do {
            // Perform the search asynchronously
            let response = try await search.start()

            // Extract the first map item's coordinate
            guard let coordinate = response.mapItems.first?.placemark.coordinate else {
                print("test - No coordinate found for \(recognizedText)")
                return
            }

            // Perform UI updates on the main thread
            await MainActor.run {
                LocationManager.shared.startNavigation(to: coordinate)
                print("test - Selected address: \(recognizedText), Coordinate: \(coordinate)")
            }

        } catch {
            // Handle errors
            print("test - Error fetching coordinates: \(error.localizedDescription)")
            throw error
        }
    }
    
    func promptForSearchQuery(with recognizedText: String) async throws -> [SongWithArtwork] {
        
        let simulatedQuery = recognizedText

        // Step 1: Fetch songs using MusicKit
        let songs = try await MediaItemViewModel.shared.searchSongs(q: simulatedQuery)

        // Step 2: Fetch artwork for each song asynchronously
        var results: [SongWithArtwork] = []
        for song in songs {
            let artworkURL = song.artwork?.url(width: 500, height: 500)?.absoluteString
            let artwork = artworkURL != nil ? await fetchImage(from: artworkURL!) : UIImage(systemName: "music.note")
            results.append(SongWithArtwork(song: song, artwork: artwork))
        }

        return results
    }
    
    func fetchImage(from urlString: String) async -> UIImage? {
        guard let url = URL(string: urlString) else { return nil }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return UIImage(data: data)
        } catch {
            print("Error fetching image: \(error)")
            return nil
        }
    }

    
    func presentSearchResults(results: [SongWithArtwork]) {
        var listItems = results.map { result in
            let song = result.song
            let artwork = result.artwork ?? UIImage(systemName: "music.note")
            let item = CPListItem(text: song.title, detailText: song.artistName)
            item.setImage(artwork)
            item.handler = { _, completion in
                Task {
                    do {
                        try await MediaItemViewModel.shared.playSelectedSong(song)
                        let viewModel = MediaItemViewModel.shared
                        Task {
                            let img = await self.getSong()
                            self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: img, speedo: "", detailedText: LocationManager.shared.eta, completion: {x in
                                let carPlayTemplate = x
                                self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                            })
                            print("Playing song: \(song.title) by \(song.artistName)")
                        }
                    } catch {
                        print("Error playing song: \(error)")
                    }
                    completion()
                }
                
            }
            return item
        }

        // Create the Back button
        let backButtonItem = CPListItem(text: "Back", detailText: nil)
        backButtonItem.setImage(UIImage(systemName: "arrowshape.left.circle")!)
        backButtonItem.handler = { [weak self] _, completion in
            guard let self = self else { return }
            self.gridTemplate { gridTemplate in
                self.carplayInterfaceController?.setRootTemplate(gridTemplate, animated: true, completion: nil)
            }
            completion()
        }

        // Prepend the Back button to the list items
        listItems.insert(backButtonItem, at: 0)

        let section = CPListSection(items: listItems)
        let listTemplate = CPListTemplate(title: "Search Results", sections: [section])

        // Push the search results template to CarPlay
        carplayInterfaceController?.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    func presentSearchResults2(for query: String) {
        Task {
            do {
                // Fetch songs using your MediaItemViewModel
                let songs = try await MediaItemViewModel.shared.searchSongs(q: query)

                // Map the results to CPListItems
                let listItems = songs.map { song in
                    let item = CPListItem(text: song.title, detailText: song.artistName)
                    let imgurl = song.artwork?.url(width: 500, height: 500)
                    let img = fetchImage4(from: imgurl?.absoluteString ?? "")
                    item.setImage(img ?? UIImage(systemName: "music.note"))
                    item.handler = { _, completion in
                        Task {
                            do {
                                try await MediaItemViewModel.shared.playSelectedSong(song)
                                let viewModel = MediaItemViewModel.shared
                                Task {
                                    let img = await self.getSong()
                                    self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: img, speedo: self.getSpeedo(), detailedText: LocationManager.shared.eta, completion: {x in
                                        let carPlayTemplate = x
                                        self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                                    })
                                    print("Playing: \(song.title) by \(song.artistName)")
                                }
                            } catch {
                                print("Error playing song: \(error)")
                            }
                            completion()
                        }
                    }
                    return item
                }

                // Create a list section with the results
                let section = CPListSection(items: listItems)
                let listTemplate = CPListTemplate(title: "Search Results", sections: [section])

                // Push the search results template to CarPlay
                carplayInterfaceController?.setRootTemplate(listTemplate, animated: true, completion: nil)
            } catch {
                print("Error fetching search results: \(error)")
            }
        }
    }
    
    
    func playSong(named songName: String) {
        print("Attempting to play: \(songName)")
        
        // Implement playback logic using MusicKit or your media player
       // MediaItemViewModel.shared.playSelectedSong(<#T##song: Song##Song#>)
    }
    
    func updateTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        currentTime = formatter.string(from: Date())
        print("Function executed at \(currentTime)")
        WeatherViewModel.shared.fetchText()
        // get weather
        Task {
            WeatherViewModel.shared.fetchWeather()
        }
    }
    
    private func showSpinnerTemplate() -> CPTemplate {
        // Create a placeholder image (optional, or use a valid UIImage if available)
        guard let placeholderImage = UIImage(systemName: "hourglass") else { return CPGridTemplate(title: "", gridButtons: [])  }
        
        // Create CPGridItem with placeholder text and optional image
        let spinnerItem = CPGridButton(titleVariants: ["Loading..."], image: placeholderImage)
        
        // Create a CPGridTemplate with a single item
        let gridTemplate = CPGridTemplate(title: "Loading...", gridButtons: [spinnerItem])
        // Create Grid Template with the buttons
        
        return gridTemplate
    }
    
    private func showSpinnerTemplate2() -> CPTemplate {
        // Create a placeholder image (optional, or use a valid UIImage if available)
        guard let placeholderImage = UIImage(systemName: "hourglass") else { return CPGridTemplate(title: "", gridButtons: [])  }
        
        // Create CPGridItem with placeholder text and optional image
        let spinnerItem = CPGridButton(titleVariants: ["Wait..."], image: placeholderImage)
        
        // Create a CPGridTemplate with a single item
        let gridTemplate = CPGridTemplate(title: "Wait...", gridButtons: [spinnerItem])
        // Create Grid Template with the buttons
        
        return gridTemplate
    }
    
    func playMediaCollection(_ mediaCollection: MPMediaItemCollection, startingAt song: MPMediaItem?) {
        musicPlayer.setQueue(with: mediaCollection)
        
        if let song = song {
            musicPlayer.nowPlayingItem = song
        }
        if musicPlayer.playbackState == .paused {
            musicPlayer.play()
        } else {
            musicPlayer.play()
        }
    }

    func loadNextPage(for mediaCollection: MPMediaItemCollection) {
        loadMoreSongs(for: mediaCollection, offset: currentOffset, batchSize: 9) { [weak self] newSongs in
            guard let self = self else { return }

            if let currentListTemplate = self.carplayInterfaceController?.topTemplate as? CPListTemplate,
               let currentSection = currentListTemplate.sections.first {
                // Safely cast items to [CPListItem]
                var allItems = currentSection.items.compactMap { $0 as? CPListItem }

                // Add the Back button
                let backButtonItem = CPListItem(text: "Back", detailText: nil)
                backButtonItem.setImage(UIImage(systemName: "arrowshape.left.circle", withConfiguration: self.configuration)!)
                backButtonItem.handler = { [weak self] _, _ in
                    self?.currentOffset = 0
                    self?.gridTemplate { gridTemplate in
                        self?.carplayInterfaceController?.setRootTemplate(gridTemplate, animated: true, completion: nil)
                    }
                }
                if !allItems.contains(where: { $0.text == "Back" }) {
                    allItems.insert(backButtonItem, at: 0)
                }

                // Remove the existing "Load More..." button
                allItems.removeAll { $0.text == "Load More..." }

                // Add new songs to the list
                for song in newSongs {
                    let listItem = CPListItem(text: song.title ?? "Unknown Title", detailText: song.artist)
                    if let artwork = song.artwork {
                        listItem.setImage(artwork.image(at: CGSize(width: 100, height: 100)))
                    }
                    listItem.handler = { [weak self] _, _ in
                        guard let self = self else { return }
                        let mediaCollection = MPMediaItemCollection(items: [song])
                        self.playMediaCollection(mediaCollection, startingAt: song)
                    }
                    allItems.append(listItem)
                }

                // Add the "Load More..." button if more songs are available
                if self.currentOffset < mediaCollection.items.count {
                    let loadMoreItem = CPListItem(text: "Load More...", detailText: nil)
                    loadMoreItem.handler = { [weak self] _, _ in
                        self?.loadNextPage(for: mediaCollection)
                    }
                    allItems.append(loadMoreItem)
                }

                // Update the section and template
                let updatedSection = CPListSection(items: allItems)
                let updatedTemplate = CPListTemplate(title: currentListTemplate.title, sections: [updatedSection])
                self.carplayInterfaceController?.setRootTemplate(updatedTemplate, animated: true, completion: nil)
            }
        }
    }
    
    func resizeImage(_ image: UIImage, targetSize: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: targetSize)
        let resizedImage = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
        return resizedImage
    }
        
    func fetchAlbums() {
        let query = MPMediaQuery.albums()
        let albums = query.collections ?? []
        DispatchQueue.main.async {
            self.loadNextAlbumPage(albums: albums)
        }
    }
    

// Helper functions for loading albums in batches

func loadMoreAlbums(albums: [MPMediaItemCollection], offset: Int, batchSize: Int, completion: @escaping ([MPMediaItemCollection]) -> Void) {
    let nextBatch = Array(albums[offset..<min(offset + albumBatchSize, albums.count)])
    currentOffset += nextBatch.count
    completion(nextBatch)
}

func loadNextAlbumPage(albums: [MPMediaItemCollection]) {
    var albumItems: [CPListItem] = []
    print("albums count: \(albums.count)")
    let listItemHead = CPListItem(text: "Back", detailText: "")
    listItemHead.setImage(UIImage(systemName: "arrowshape.left.circle", withConfiguration: self.configuration)!)
    listItemHead.userInfo = "1"
    listItemHead.handler = { item, completion in
        self.currentOffset = 0
        LocationManager.shared.UpdateAllowed(x: false, completion: { x in
                var grid: CPGridTemplate!
                self.gridTemplate(completion: { x in
                    grid = x
                    // Set the root template to the tab bar template
                    self.carplayInterfaceController!.setRootTemplate(grid, animated: true, completion: nil)
                })
            })
        }
    
    for album in albums {
        let albumTitle = album.representativeItem?.albumTitle ?? "Unknown Album"
        let albumArtist = album.representativeItem?.albumArtist ?? "Unknown Artist"
        let listItem = CPListItem(text: albumTitle, detailText: albumArtist)
        if let artwork = album.representativeItem?.artwork {
            let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
            let artworkImage = artwork.image(at: imageSize)
            listItem.setImage(artworkImage)
        }
        listItem.handler = { [weak self] _, _ in
            // No need to pass a custom title, album's title will be used
            self?.currentOffset = 0
            self?.showSongsTemplate(for: album)
        }
        albumItems.append(listItem)
    }
    
    let back = CPListSection(items: [listItemHead])
    let section = CPListSection(items: albumItems)
    let listTemplate = CPListTemplate(title: "Albums", sections: [back, section])
    
    self.carplayInterfaceController!.setRootTemplate(listTemplate, animated: true, completion: nil)
    loadMoreAlbums(albums: albums, offset: currentOffset, batchSize: albumBatchSize) { [weak self] newAlbums in
        guard let self = self else { return }

        // Logic to add the new albums to the existing template
        if let currentListTemplate = self.carplayInterfaceController?.topTemplate as? CPListTemplate,
           let currentSection = currentListTemplate.sections.first {
            
            var allItems = currentSection.items as? [CPListItem] ?? []
            
            // Remove the "Load More" button if it exists
            if let lastItem = allItems.last, lastItem.text == "Load More..." {
                allItems.removeLast()
            }

            // Add new albums to the list
            for album in newAlbums {
                let albumTitle = album.representativeItem?.albumTitle ?? "Unknown Album"
                let albumArtist = album.representativeItem?.albumArtist ?? "Unknown Artist"
                let listItem = CPListItem(text: albumTitle, detailText: albumArtist)
                if let artwork = album.representativeItem?.artwork {
                    let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
                    let artworkImage = artwork.image(at: imageSize)
                    listItem.setImage(artworkImage)
                }
                listItem.handler = { [weak self] _, _ in
                    self?.currentOffset = 0
                    self?.showSongsTemplate(for: album) // Display the songs in the album
                }
                allItems.append(listItem)
            }

            // Add the "Load More" button again if more albums are still available
            if self.currentOffset < albums.count {
                let loadMoreItem = CPListItem(text: "Load More...", detailText: nil)
                loadMoreItem.handler = { [weak self] _, _ in
                    self?.loadNextAlbumPage(albums: albums)
                }
                allItems.append(loadMoreItem)
            }

            // Update the template
            let newSection = CPListSection(items: allItems)
            currentListTemplate.updateSections([newSection])
        }
    }
}

    

    func fetchPlaylists() {
        let query = MPMediaQuery.playlists()
        let myplaylists = query.collections as? [MPMediaPlaylist] ?? []
        
        DispatchQueue.main.async {
            self.loadNextPlaylistPage(playlists: myplaylists)
        }
    }
    


// Helper functions for loading playlists in batches
func loadMorePlaylists(playlists: [MPMediaItemCollection], offset: Int, playlistBatchSize: Int, completion: @escaping ([MPMediaItemCollection]) -> Void) {
    let nextBatch = Array(playlists[offset..<min(offset + playlistBatchSize, playlists.count)])
    currentOffset += nextBatch.count
    completion(nextBatch)
}

func loadNextPlaylistPage(playlists: [MPMediaItemCollection]) {
    var playlistItems: [CPListItem] = []
    
    let listItemHead = CPListItem(text: "Back", detailText: "")
    listItemHead.setImage(UIImage(systemName: "arrowshape.left.circle", withConfiguration: self.configuration)!)
    listItemHead.userInfo = "1"
    listItemHead.handler = { item, completion in
        self.currentOffset = 0
        LocationManager.shared.UpdateAllowed(x: false, completion: { x in
                var grid: CPGridTemplate!
                self.gridTemplate(completion: { x in
                    grid = x
                    // Set the root template to the tab bar template
                    self.carplayInterfaceController!.setRootTemplate(grid, animated: true, completion: nil)
                })
            })
        }
    
    for playlist in playlists {
        let playlistName = (playlist as? MPMediaPlaylist)?.name ?? "Unknown Playlist"
        let listItem = CPListItem(text: playlistName, detailText: "\(playlist.count) songs")
        if let artwork = playlist.representativeItem?.artwork {
            let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
            let artworkImage = artwork.image(at: imageSize)
            listItem.setImage(artworkImage)
        }
        listItem.handler = { [weak self] _, _ in
            // No need to pass a custom title, album's title will be used
            self?.currentOffset = 0
            self?.showSongsTemplate(for: playlist, title: playlistName)
        }
        playlistItems.append(listItem)
    }
    
    let back = CPListSection(items: [listItemHead])
    let section = CPListSection(items: playlistItems)
    let listTemplate = CPListTemplate(title: "Playlists", sections: [back, section])
    
    self.carplayInterfaceController!.setRootTemplate(listTemplate, animated: true, completion: nil)
    loadMorePlaylists(playlists: playlists, offset: currentOffset, playlistBatchSize: playlistBatchSize) { [weak self] newPlaylists in
        guard let self = self else { return }

        // Logic to add the new playlists to the existing template
        if let currentListTemplate = self.carplayInterfaceController?.topTemplate as? CPListTemplate,
           let currentSection = currentListTemplate.sections.first {
            
            var allItems = currentSection.items as? [CPListItem] ?? []

            // Remove the "Load More" button if it exists
            if let lastItem = allItems.last, lastItem.text == "Load More..." {
                allItems.removeLast()
            }

            // Add new playlists to the list
            for playlist in newPlaylists {
                let playlistName = (playlist as? MPMediaPlaylist)?.name ?? "Unknown Playlist"
                let listItem = CPListItem(text: playlistName, detailText: "\(playlist.count) songs")
                if let artwork = playlist.representativeItem?.artwork {
                    let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
                    let artworkImage = artwork.image(at: imageSize)
                    listItem.setImage(artworkImage)
                }
                listItem.handler = { [weak self] _, _ in
                    self?.currentOffset = 0
                    self?.showSongsTemplate(for: playlist, title: playlistName)
                }
                allItems.append(listItem)
            }

            // Add the "Load More" button again if more playlists are still available
            if self.currentOffset < playlists.count {
                let loadMoreItem = CPListItem(text: "Load More...", detailText: nil)
                loadMoreItem.handler = { [weak self] _, _ in
                    self?.loadNextPlaylistPage(playlists: playlists)
                }
                allItems.append(loadMoreItem)
            }

            // Update the template
            let newSection = CPListSection(items: allItems)
            currentListTemplate.updateSections([newSection])
        }
    }
}
    func loadMoreSongs(for mediaCollection: MPMediaItemCollection, offset: Int, batchSize: Int, completion: @escaping ([MPMediaItem]) -> Void) {
        let mediaItems = mediaCollection.items
        let totalSongs = mediaItems.count
        
        print("Total Songs: \(totalSongs)")
        print("Current Offset: \(offset)")
        
        // Ensure that the offset is within bounds of the mediaItems array.
        guard offset < totalSongs else {
            print("No more songs to load.")
            completion([])
            return
        }

        // Calculate the range safely, ensuring we don't exceed the total item count.
        let nextBatch = Array(mediaItems[offset..<min(offset + batchSize, totalSongs)])
        
        print("Next Batch Count: \(nextBatch.count)")
        print("min \(min(offset + batchSize, totalSongs))")
        print("offset: \(offset)")
        print("Total Songs: \(totalSongs)")

        // Return the batch of songs.
        completion(nextBatch)

        // Update the currentOffset after loading the batch.
        currentOffset += nextBatch.count
    }
    
    func showPlaylistsTemplate(playlists: [MPMediaItemCollection]) {
        var playlistItems: [CPListItem] = []
        
        let listItemHead = CPListItem(text: "Back", detailText: "")
        listItemHead.setImage(UIImage(systemName: "arrowshape.left.circle", withConfiguration: self.configuration)!)
        listItemHead.userInfo = "1"
        Back(listItem: listItemHead)
        
        for playlist in playlists {
            let playlistName = (playlist as? MPMediaPlaylist)?.name ?? "Unknown Playlist"
            let listItem = CPListItem(text: playlistName, detailText: "\(playlist.count) songs")
            if let artwork = playlist.representativeItem?.artwork {
                let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
                let artworkImage = artwork.image(at: imageSize)
                listItem.setImage(artworkImage)
            }
            listItem.handler = { [weak self] _, _ in
                // No need to pass a custom title, album's title will be used
                self?.showSongsTemplate(for: playlist, title: playlistName)
            }
            playlistItems.append(listItem)
        }
        
        let back = CPListSection(items: [listItemHead])
        let section = CPListSection(items: playlistItems)
        let listTemplate = CPListTemplate(title: "Playlists", sections: [back, section])
        
        self.carplayInterfaceController!.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    func showSongsTemplate(for mediaCollection: MPMediaItemCollection, title: String? = nil) {
        var songItems: [CPListItem] = []

        // Back button
        let backButtonItem = CPListItem(text: "Back", detailText: nil)
        backButtonItem.setImage(UIImage(systemName: "arrowshape.left.circle", withConfiguration: configuration)!)
        backButtonItem.handler = { [weak self] _, completion in
            guard let self = self else { return }
            self.currentOffset = 0
            LocationManager.shared.UpdateAllowed(x: false) { _ in
                self.gridTemplate { grid in
                    self.carplayInterfaceController?.setRootTemplate(grid, animated: true, completion: nil)
                }
            }
            completion()
        }

        // Load songs in batches based on batchSize
        loadMoreSongs(for: mediaCollection, offset: currentOffset, batchSize: batchSize) { [weak self] songs in
            guard let self = self else { return }

            // Add only the batch-sized songs to the template
            for song in songs {
                let listItem = CPListItem(text: song.title ?? "Unknown Title", detailText: song.artist)
                if let artwork = song.artwork {
                    listItem.setImage(artwork.image(at: CGSize(width: 100, height: 100)))
                }
                listItem.handler = { [weak self] _, _ in
                    guard let self = self else { return }
                    let mediaCollection = MPMediaItemCollection(items: [song])
                    self.playMediaCollection(mediaCollection, startingAt: song)
                }
                songItems.append(listItem)
            }

            // Add "Load More..." button if there are more songs to load
            if self.currentOffset < mediaCollection.items.count {
                let loadMoreItem = CPListItem(text: "Load More...", detailText: nil)
                loadMoreItem.handler = { [weak self] _, _ in
                    guard let self = self else { return }
                    self.loadNextPage(for: mediaCollection)
                }
                songItems.append(loadMoreItem)
            }

            // Update the template
            let backSection = CPListSection(items: [backButtonItem])
            let songsSection = CPListSection(items: songItems)
            let listTemplate = CPListTemplate(title: title ?? "Songs", sections: [backSection, songsSection])
            self.carplayInterfaceController?.setRootTemplate(listTemplate, animated: true, completion: nil)
        }
    }

   
    func showSongsTemplate(for mediaQuery: MPMediaQuery, title: String? = nil) {
        var songItems: [CPListItem] = []

        // Create a "Back" button item
        let backButtonItem = CPListItem(text: "Back", detailText: nil)
        backButtonItem.setImage(
            UIImage(systemName: "arrowshape.left.circle",
                    withConfiguration: self.configuration)!
        )
        backButtonItem.handler = { [weak self] _, completion in
            guard let self = self else { return }
            self.currentOffset = 0
            LocationManager.shared.UpdateAllowed(x: false, completion: { _ in
                self.gridTemplate { grid in
                    self.carplayInterfaceController?.setRootTemplate(grid, animated: true, completion: nil)
                }
            })
            completion()
        }

        // Retrieve all songs from the query
        guard let mediaItems = mediaQuery.items, !mediaItems.isEmpty else {
            print("No songs available")
            return
        }

        // Load the initial batch of songs
        let mediaCollection = MPMediaItemCollection(items: mediaItems)
        loadMoreSongs(for: mediaCollection, offset: currentOffset, batchSize: 9) { [weak self] songs in
            guard let self = self else { return }

            // Populate list items for each song in the batch
            for song in songs {
                let listItem = CPListItem(
                    text: song.title ?? "Unknown Title",
                    detailText: song.artist
                )
                if let artwork = song.artwork {
                    let imageSize = CGSize(width: 100, height: 100)
                    listItem.setImage(artwork.image(at: imageSize))
                }
                listItem.handler = { [weak self] _, _ in
                    guard let self = self else { return }
                    // Wrap the song in an MPMediaItemCollection
                    let mediaCollection = MPMediaItemCollection(items: [song])
                    self.playMediaCollection(mediaCollection, startingAt: song)

                    // Reset offset for the new list
                    self.currentOffset = 0
                    let viewModel = MediaItemViewModel.shared
                    Task {
                        let img = await self.getSong()
                        self.ListTemplate(
                            title: song.title ?? viewModel.title,
                            artist: song.artist ?? viewModel.artist,
                            art: img,
                            speedo: self.getSpeedo(),
                            detailedText: ""
                        ) { carPlayTemplate in
                            self.carplayInterfaceController?.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                        }
                    }
                }
                songItems.append(listItem)
            }
            
            // If there's more to load, append a "Load More" item
            if self.currentOffset < mediaItems.count {
                let loadMoreItem = CPListItem(text: "Load More...", detailText: nil)
                loadMoreItem.handler = { [weak self] _, _ in
                    guard let self = self else { return }
                    // Wrap mediaItems in MPMediaItemCollection
                    let mediaCollection = MPMediaItemCollection(items: mediaItems)
                    self.loadNextPage(for: mediaCollection)
                }
                songItems.append(loadMoreItem)
            }

            // Create sections for the back button and songs
            let backSection = CPListSection(items: [backButtonItem])
            let songsSection = CPListSection(items: songItems)

            let collectionTitle = title ?? "Songs"

            // Present the list template
            let listTemplate = CPListTemplate(
                title: collectionTitle,
                sections: [backSection, songsSection]
            )
            self.carplayInterfaceController?.setRootTemplate(listTemplate, animated: true, completion: nil)
        }
    }
    

    
    
    
    func getImageFromUserDefaults(key: String) -> UIImage? {
        if let imageData = UserDefaults.standard.data(forKey: key) {
            return UIImage(data: imageData)
        }
        return nil
    }
    
    func getSpeedo() -> String {
        if LocationManager.shared.speed < 20.0 {
            print("speed-0")
            return "speed0"
        } else if LocationManager.shared.speed < 42 {
            print("speed-30")
            return "speed30"
        } else if LocationManager.shared.speed < 62 {
            print("speed-50")
            return "speed50"
        } else if LocationManager.shared.speed < 78 {
            print("speed-70")
            return "speed70"
        } else if LocationManager.shared.speed >= 87 {
            print("speed-100")
            return "speed100"
        } else {
            print("speed-0-0")
            return "speed0"
        }
    }
    

    // Fetch a song by store ID
    func fetchSongMetadata(storeID: String) async throws -> SongMetadata? {
        // Create a MusicCatalogResourceRequest for a specific song
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(storeID))

        do {
            // Perform the request
            let response = try await request.response()

            // Get the first song (if available)
            guard let song = response.items.first else {
                print("No song found with store ID \(storeID).")
                return nil
            }

            // Extract metadata from the song
            let metadata = SongMetadata(
                title: song.title,
                artist: song.artistName,
                album: song.albumTitle ?? "Unknown Album",
                genre: song.genreNames.first ?? "Unknown Genre",
                artworkURL: song.artwork?.url(width: 500, height: 500)
            )

            return metadata

        } catch {
            print("Error fetching song metadata: \(error.localizedDescription)")
            throw error
        }
    }
    
    func getSong() async -> UIImage {
        do {
            let id = musicPlayer.nowPlayingItem?.playbackStoreID
            if let metadata = try await fetchSongMetadata(storeID: id ?? "") {
                print("Title: \(metadata.title)")
                print("Artist: \(metadata.artist)")
                print("Album: \(metadata.album)")
                print("Genre: \(metadata.genre)")
                if let artworkURL = metadata.artworkURL {
                    print("Artwork URL: \(artworkURL)")
                    guard let image = await fetchImage(from: artworkURL.absoluteString) else {
                        return UIImage(named: "music")!
                    }
                    return image
                } else {
                    return UIImage(named: "music")!
                }
            } else {
                return UIImage(named: "music")!
            }
        } catch {
            print("Failed to fetch metadata: \(error)")
            return UIImage(named: "music")!
        }
        
    }
    
    func fetchImage2(from urlString: String) async throws -> UIImage {
        // Ensure the string can be converted to a valid URL
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        do {
            // Fetch the image data from the URL
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Convert the data into a UIImage
            guard let image = UIImage(data: data) else {
                throw NSError(domain: "ImageError", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid image data."])
            }
            
            return image
        } catch {
            throw error
        }
    }
    
    func setupListTemplate() async {
        let listTemplate = await CPListTemplate(title: "My List", sections: [createListSection()])
        carplayInterfaceController?.setRootTemplate(listTemplate, animated: true, completion: nil)
    }
    
    private func createListSection() async -> CPListSection {
        var items: [CPListItem] = []
        let img = await getSong()
        // Create a list item for the now playing song
        if let nowPlayingItem = MPMusicPlayerController.applicationMusicPlayer.nowPlayingItem {
            let nowPlayingTitle = nowPlayingItem.title ?? "Unknown Title"
            let nowPlayingArtist = nowPlayingItem.artist ?? "Unknown Artist"
            //let artwork = nowPlayingItem.artwork?.image(at: CGSize(width: 100, height: 100))
            
            let nowPlayingListItem = CPListItem(text: nowPlayingTitle, detailText: nowPlayingArtist)
           
            // Use the UIImage directly for the item imgag
            nowPlayingListItem.setImage(img) // Assuming image it's most likely a UIImage
           
            items.append(nowPlayingListItem)
        }
        
        // Add additional non-music related items here
        let otherItem = CPListItem(text: "Other Item 1", detailText: "Detail 1")
        items.append(otherItem)
        
        return CPListSection(items: items)
    }
    
    func ListTemplate(title: String, artist: String, art: UIImage?, speedo: String, detailedText: String, completion: @escaping (CPListTemplate) -> Void) {
        print("test2 - speedo: \(speedo)")
        var listItems: [CPListItem] = []
        // Iterate over each MPMediaItem in the mediaItems array
        let title3 = title
        let artist3 = artist
        var listItem3: CPListItem?

        listItem3 = CPListItem(text: title3, detailText: artist3)
        
        if let img = art {
            listItem3?.setImage(img)
        }
        
        listItems.append(listItem3 ?? CPListItem(text: "", detailText: ""))
        
        let img = UIImage(named: "\(dayName(forCode: WeatherViewModel.shared.is_day) ?? "day")/\(imageName(forCode: WeatherViewModel.shared.code) ?? "113")")
        let img_resized = resizeImage(img ?? UIImage(named: "day/113")!, targetSize: CGSize(width: 44, height: 44)) // Adjust size as needed
        let _ = UIImage(systemName: "line.3.horizontal", withConfiguration: self.configuration)!
        let _ = UIImage.SymbolConfiguration(pointSize: 30, weight: .regular) // Adjust pointSize and weight as needed
        
        musicHandler(listItem: listItem3 ?? CPListItem(text: "", detailText: ""))
        
        // List Item Header
        let listItemHead = CPListItem(text: "   Menu", detailText: "")
        listItemHead.setImage(UIImage(named: "menu"))
        listItemHead.userInfo = "1"
        Back(listItem: listItemHead)
        
        // List Item 1
        let listItem = CPListItem(text: String(format: "%.1f MPH", LocationManager.shared.speed), detailText: LocationManager.shared.directionString)
        listItem.setImage(UIImage(named: "\(speedo)"))
        listItem.userInfo = "1"
        
        // List Item 2
        let listItem2 = CPListItem(text: ("\(String(WeatherViewModel.shared.temp))"), detailText: ("\(String(format: "%.0f", WeatherViewModel.shared.today_min))°/\(String(format: "%.0f", WeatherViewModel.shared.today_max))°"))
        listItem2.setImage(img_resized)
        listItem2.userInfo = "2"
        openWeather(listItem: listItem2)
        
        // List Item 4
        if !LocationManager.shared.currentStep.isEmpty {
            let listItem4 = CPListItem(text: "In \(formatDistance(LocationManager.shared.disToCurrentStep)) \(LocationManager.shared.currentStep)", detailText: detailedText)
           
            listItem4.setImage(UIImage(named: "map")!)
            listItem4.userInfo = "4"
            searchHandlerForItem(listItem: listItem4)

            // List Sections
            sections = [CPListSection(items: [listItemHead, listItem, listItem2, listItem3 ?? CPListItem(text: "", detailText: ""), listItem4])]
            
            // List Template
            let template = CPListTemplate(title: "", sections: self.sections!)
            template.tabImage = UIImage(systemName: "speedometer")
            // Initialize the scroller
            let _ = "In \(formatDistance(LocationManager.shared.disToCurrentStep)) \(LocationManager.shared.currentStep)"

            completion(template)
            
        } else {
            let listItem4 = CPListItem(text: self.addressString, detailText: "Location")
            listItem4.setImage(UIImage(named: "map")!)
            listItem4.userInfo = "4"
            searchHandlerForItem(listItem: listItem4)
            // List Sections
            sections = [CPListSection(items: [listItemHead, listItem, listItem2, listItem3 ?? CPListItem(text: "", detailText: ""), listItem4])]
            
            // List Template
            let template = CPListTemplate(title: "", sections: self.sections!)
            template.tabImage = UIImage(systemName: "speedometer")
            completion(template)
        }
        

    }
    
    func fetchAlbumFromCatalog(title: String, artist: String, completion: @escaping (Album?) -> Void) {
        Task {
            do {
                let request = MusicCatalogSearchRequest(term: "\(title) \(artist)", types: [Album.self])
                let response = try await request.response()
                if let album = response.albums.first {
                    completion(album)
                } else {
                    print("Album not found in catalog.")
                    completion(nil)
                }
            } catch {
                print("Error performing catalog search: \(error)")
                completion(nil)
            }
        }
    }
    
    
    func dayName(forCode code: Int) -> String? {
        switch code {
                case 0: return "night"
                case 1: return "day"
                default: return nil
        }
    }
    
    func truncateString(_ string: String, toLength length: Int = 30) -> String {
        if string.count > length {
            let index = string.index(string.startIndex, offsetBy: length - 3)
            return String(string[..<index]) + "..."
        } else {
            return string
        }
    }
    
    
    func fetchImage(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        guard let url = URL(string: urlString) else {
            completion(nil) // Invalid URL
            return
        }

        // Perform the image fetch asynchronously
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Failed to fetch image: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let data = data, let image = UIImage(data: data) else {
                completion(nil) // Unable to parse image data
                return
            }

            DispatchQueue.main.async {
                completion(image) // Return the image to the main thread
            }
        }.resume()
    }
    
    func gridTemplate(completion: @escaping (CPGridTemplate) -> Void) {
        LocationManager.shared.UpdateAllowed(x: false, completion: { x in })
        // Create grid buttons
        Task {
            let img = await getSong()
            
            let gridButton1 = CPGridButton(titleVariants: ["Dashboard"], image: UIImage(systemName: "car.side")!) {_ in
                self.ListTemplate(title: MediaItemViewModel.shared.title, artist: MediaItemViewModel.shared.artist, art: img, speedo: self.getSpeedo(), detailedText: LocationManager.shared.eta, completion: {x in
                    let carPlayTemplate = x
                    self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                })
                
                print("Option 1 selected")
            }
            
            let gridButton2 = CPGridButton(titleVariants: ["Garage Door"], image: UIImage(systemName: "door.garage.double.bay.closed")!) {_ in
                print("Option 2 selected")
                self.informationTemplate(completion: {x in
                    self.carplayInterfaceController!.setRootTemplate(x, animated: true, completion: nil)
                })
            }
            
            let gridButton3 = CPGridButton(titleVariants: ["Outside Lighting"], image: UIImage(systemName: "lightbulb.2")!) {_ in
                self.informationTemplate2(completion: {x in
                    self.carplayInterfaceController!.setRootTemplate(x, animated: true, completion: nil)
                })
            }
            
            let gridButton4 = CPGridButton(titleVariants: ["Playlists"], image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward")!) { [weak self] _ in
                guard let self = self else { return }
                self.fetchPlaylists()
                Task {
                    //await self.setupListTemplate()
                }
                print("NO")
            }
            
            let gridButton5 = CPGridButton(titleVariants: ["Albums"], image: UIImage(systemName: "music.house")!) { [weak self] _ in
                guard let self = self else { return }
                self.fetchAlbums()
                Task {
                    //await self.setupListTemplate()
                }
                
            }
            
            let songsTemplate = CPGridButton(titleVariants: ["Songs"], image: UIImage(systemName: "music.note.list")!) { [weak self] _ in
                guard let self = self else { return }
                
                // Fetch all songs from the media query
                let query = MPMediaQuery.songs()
                self.showSongsTemplate(for: query, title: "Songs")
            }
            
            // Create Grid Template with the buttons
            let gridTemplate = CPGridTemplate(title: "Main Menu", gridButtons: [songsTemplate, gridButton5, gridButton4, gridButton3, gridButton2, gridButton1])
            
            completion(gridTemplate)
            //})
        }
    }
    
    func gridTemplate2(completion: @escaping (CPGridTemplate) -> Void) {
        LocationManager.shared.UpdateAllowed(x: false, completion: { x in })
        // Create grid buttons
        let gridButton22 = CPGridButton(titleVariants: [""], image: UIImage(systemName: "playpause.fill")!) {_ in
            print("play/pause")
            let state = MediaItemViewModel.shared.musicPlayer.playbackState
            if state == .playing {
                MediaItemViewModel.shared.musicPlayer.pause()
            } else {
                MediaItemViewModel.shared.musicPlayer.play()
            }
        }
        
        let gridButton11 = CPGridButton(titleVariants: [""], image: UIImage(systemName: "backward.fill")!) {_ in
            print("back")
            MediaItemViewModel.shared.musicPlayer.skipToPreviousItem()
            
        }
            
        let gridButton33 = CPGridButton(titleVariants: [""], image: UIImage(systemName: "forward.fill")!) {_ in
            MediaItemViewModel.shared.musicPlayer.skipToNextItem()
        }
        let gridButton44 = CPGridButton(titleVariants: ["Search"], image: UIImage(systemName: "magnifyingglass")!) {_ in
            self.presentCarPlayGrid()
            self.startVoiceSearch()
        }
        
        let gridButton3 = CPGridButton(titleVariants: ["    "], image: UIImage(named: "clear")!) {_ in
            
        }
        
        let gridButton3_3 = CPGridButton(titleVariants: ["    "], image: UIImage(named: "clear")!) {_ in
            
        }
        
        let gridButton4_4 = CPGridButton(titleVariants: ["    "], image: UIImage(named: "clear")!) {_ in
            
        }
            
        // Create Grid Template with the buttons
        let gridTemplate = CPGridTemplate(title: "Music", gridButtons: [gridButton4_4, gridButton11, gridButton3, gridButton22, gridButton3_3, gridButton33, gridButton44])
        
        completion(gridTemplate)
        //})
    }
    
        
    func getLightStatus(completion: @escaping (String) -> Void) {
        CurlCommands().getOutsideLightState(completion: { x in
            let rawStatus = self.extractState(from: "\(x)") ?? ""
            var status = ""
            if rawStatus == "off" {
                status = "Off"
            } else {
                status = "On"
            }
            completion(status)
        })
    }
    
    func getGarageStatus(completion: @escaping (String) -> Void) {
        CurlCommands().getOverheadDoorState(completion: { x in
            let rawStatus = self.extractState(from: "\(x)") ?? ""
            var status = ""
            if rawStatus == "off" {
                status = "Closed"
            } else {
                status = "Open"
            }
            //print(rawStatus)
            completion(status)
        })
    }
        
    func extractState(from jsonString: String) -> String? {
        // Convert the JSON string to Data
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("Error: Unable to convert JSON string to Data")
            return nil
        }
        
        do {
            // Parse the JSON data into a dictionary
            if let jsonObject = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
                // Access the "state" key in the dictionary
                if let state = jsonObject["state"] as? String {
                    return state
                } else {
                    print("Error: 'state' key not found or not a string")
                    return nil
                }
            }
        } catch {
            print("Error: Failed to parse JSON - \(error)")
            return nil
        }
        
        return nil
    }
    

    func createCarPlayGridTemplate(withTitle title: String, microphoneAction: @escaping () -> Void, cancelAction: @escaping () -> Void) -> CPGridTemplate {
        // Create the microphone grid item
        let microphoneItem = CPGridButton(titleVariants: [""], image: UIImage(named: "red_microphone")!) {_ in
            microphoneAction()
        }

        // Create the cancel grid item
        let _ = CPGridButton(titleVariants: ["Cancel"], image: UIImage(systemName: "xmark.circle")!) {_ in
            cancelAction()
        }

        // Create and return the grid template
        let gridTemplate = CPGridTemplate(title: title, gridButtons: [microphoneItem])
        return gridTemplate
    }
    
    func presentCarPlayGrid() {

        let gridTemplate = createCarPlayGridTemplate(
            withTitle: "Voice Input",
            microphoneAction: {
                print("Microphone tapped.")
            },
            cancelAction: {
                print("Cancel tapped.")
            }
        )

        carplayInterfaceController!.setRootTemplate(gridTemplate, animated: true, completion: nil)
    }
    
    func informationTemplate(completion: @escaping (CPTemplate) -> Void) {
        getGarageStatus(completion: { doorStatus in
            
            // action 1 button text
            var actionTitle: String = ""
            if doorStatus == "Closed" {
                actionTitle = "Open Door"
            } else {
                actionTitle = "Close Door"
            }
            
            // template title
            let title = "Control Garage Door"
            
            // Information Items
            let item1 = CPInformationItem(title: "Garage Door", detail: "Main Door")
            let item2 = CPInformationItem(title: "Status", detail: doorStatus)
            
            // Action Button
            let action1 = CPTextButton(title: actionTitle, textStyle: .confirm) { _ in
                CurlCommands().toggleGarageDoor(completion: { x in
                    print("action - Parsed JSON: \(x)")
                    self.carplayInterfaceController!.setRootTemplate(self.showSpinnerTemplate(), animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                        self?.informationTemplate(completion: {x in
                            self?.carplayInterfaceController!.setRootTemplate(x, animated: true, completion: nil)
                        })
                    }
                })
            }
            
            // cancel button
            let action2 = CPTextButton(title: "Cancel", textStyle: .cancel) { _ in
                print("action2")
                var grid: CPGridTemplate!
                self.gridTemplate(completion: { x in
                    grid = x
                    self.carplayInterfaceController!.setRootTemplate(grid, animated: true, completion: nil)
                })
            }
            
            // create the template
            let infoTemplate = CPInformationTemplate(title: title, layout: .leading, items: [item1, item2], actions: [action1, action2])
            infoTemplate.actions = [action1, action2]
            
            completion(infoTemplate)
        })
    }
    
    func informationTemplate2(completion: @escaping (CPTemplate) -> Void) {
        getLightStatus(completion: { lightStatus in
            
            // action 1 button text
            var actionTitle: String = ""
            var futureStatus = ""
            if lightStatus == "On" {
                actionTitle = "Turn Off"
                futureStatus = "off"
            } else {
                actionTitle = "Turn On"
                futureStatus = "on"
            }
            
            // template title
            let title = "Control Outdoor Lighting"
            
            // Information Items
            let item1 = CPInformationItem(title: "Device", detail: "Driveway Lights")
            let item2 = CPInformationItem(title: "Status", detail: lightStatus)
            
            // Action Button
            let action1 = CPTextButton(title: actionTitle, textStyle: .confirm) { _ in
                CurlCommands().toggleOutdoorLight(state: futureStatus, completion: { x in
                    print("action - Parsed JSON: \(x)")
                    self.carplayInterfaceController!.setRootTemplate(self.showSpinnerTemplate2(), animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                        self?.informationTemplate2(completion: {x in
                            self?.carplayInterfaceController!.setRootTemplate(x, animated: true, completion: nil)
                        })
                    }
                })
            }
            
            // cancel button
            let action2 = CPTextButton(title: "Cancel", textStyle: .cancel) { _ in
                print("action2")
                var grid: CPGridTemplate!
                self.gridTemplate(completion: { x in
                    grid = x
                    self.carplayInterfaceController!.setRootTemplate(grid, animated: true, completion: nil)
                })
            }
            
            // create the template
            let infoTemplate = CPInformationTemplate(title: title, layout: .leading, items: [item1, item2], actions: [action1, action2])
            infoTemplate.actions = [action1, action2]
            
            completion(infoTemplate)
        })
    }
    
        func fetchImage3(from urlString: String, completion: @escaping (UIImage?) -> Void) {
            print("test2 - fetch image")
            let artwork = musicPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 3000, height: 3000))
            completion(artwork)
        }
    
    func fetchImage4(from urlString: String) -> UIImage? {
        print("test2 - fetch image4")
        let artwork = MediaItemViewModel.shared.musicPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 4000, height: 4000))
        return artwork
    }
    
    
    func fetchImage() async throws -> (String) {
        do {
            let x = try await mediaClass.getID(songTitle: mediaClass.title, artistName: mediaClass.artist)
            return x
        } catch {
            print("error")
            return ""
        }
    }

    func fetchImage2(from urlString: String, completion: @escaping (UIImage?) -> Void) {
        let cacheKey = NSString(string: urlString)
        
        // Check if the image is already cached
        if let cachedImage = ImageCache.shared.object(forKey: cacheKey) {
            print("Using cached image")
            completion(cachedImage)
            return
        }
        
        // If not cached, download the image
        guard let url = URL(string: urlString) else {
            print("Invalid URL")
            completion(nil)
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("Error fetching image: \(error.localizedDescription)")
                completion(nil)
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                print("Failed to decode image data")
                completion(nil)
                return
            }
            
            // Cache the downloaded image
            ImageCache.shared.setObject(image, forKey: cacheKey)
            print("Image cached")
            
            completion(image)
        }.resume()
    }
    
    // CPInterfaceControllerDelegate method
    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        isCarPlay = true
        var type: String = ""
        if aTemplate is CPGridTemplate {
            type = "grid"
            LocationManager.shared.UpdateAllowed(x: false, completion: { x in
                if type != self.previousType {
                    print("type: \(type)")
                    self.previousType = type
                    print("allow updates: \(LocationManager.shared.UpdateAllowed())")
                }
            })
        } else if aTemplate is CPListTemplate {
            type = "list"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                LocationManager.shared.UpdateAllowed(x: true, completion: { x in
                    if type != self.previousType {
                        print("type: \(type)")
                        self.previousType = type
                        print("allow updates: \(LocationManager.shared.UpdateAllowed())")
                    }
                })            }
        } else if aTemplate is CPInformationTemplate {
            type = "info"
            LocationManager.shared.UpdateAllowed(x: false, completion: { x in
                if type != self.previousType {
                    print("type: \(type)")
                    self.previousType = type
                    print("allow updates: \(LocationManager.shared.UpdateAllowed())")
                }
            })
            if doorStatus == "open" {
                title2 = "Close Door"
            } else {
                title2 = "Open Door"
            }
        }
        if type != previousType {
            print("type: \(type)")
            previousType = type
            print("isCarPlay: \(isCarPlay)")
        }
    }
    
    func getInitLightButtonState() -> String {
        var title3: String = ""
        if self.lightStatus == "Off" {
            title3 = "Turn Off"
        } else if self.lightStatus == "On" {
            title3 = "Turn On"
        } else {
            self.lightStatus = "On"
            title3 = "Turn On"
        }
        let lightStat: String = lightStatus ?? "Off"
        print("light status title: \(lightStat)")
        return title3
    }
    
    func getInitLightState() -> String {
        var lightStat: String = ""
        if self.lightStatus == "On" {
            lightStat = "On"
        } else if self.lightStatus == "Off" {
            lightStat = "Off"
        } else {
            lightStat = "Off"
            self.lightStatus = "Off"
        }
        
        print("light status title: \(lightStat)")
        return lightStat
    }
    
    func getInitButtonState() -> String {
        var title3: String = ""
        if self.doorStatus == "Open" {
            title3 = "Close Door"
        } else if self.lightStatus == "Closed" {
            self.doorStatus = "Closed"
            title3 = "Open Door"
        } else {
            self.doorStatus = "Closed"
            title3 = "Open Door"
        }
        let doorStat: String = self.doorStatus ?? "Closed"
        print("door status title: \(doorStat)")
        return title3
    }
    
    func getInitDoorState() -> String {
        var doorStat: String = ""
        if self.doorStatus == "Open" {
            doorStat = "Open"
            self.doorStatus = "Open"
        } else if self.doorStatus == "Closed" {
            doorStat = "Closed"
            self.doorStatus = "Closed"
        } else {
            doorStat = "Closed"
            self.doorStatus = "Closed"
        }
        
        print("door status title: \(doorStat)")
        return doorStat
    }
    
    func Back(listItem: CPListItem) {
        listItem.handler = { item, completion in
            LocationManager.shared.UpdateAllowed(x: false, completion: { x in
                var grid: CPGridTemplate!
                self.gridTemplate(completion: { x in
                    grid = x
                    // Set the root template to the tab bar template
                    self.carplayInterfaceController!.setRootTemplate(grid, animated: true, completion: nil)
                })
            })
        }
    }
    
        
    
    
    func sessionConfiguration(_ sessionConfiguration: CPSessionConfiguration, limitedUserInterfacesChanged limitedUserInterfaces: CPLimitableUserInterface) {
        
    }
    
}
extension TemplateManager {
    

        
    func controlGarage(listItem: CPListItem) {
        listItem.handler = { item, completion in
            self.carplayScene?.open(URL(string: "https://geo.itunes.apple.com/?app=music")!, options: nil, completionHandler: nil)
        }
    }

    func musicHandler(listItem: CPListItem) {
        listItem.handler = { item, completion in
            self.gridTemplate2(completion: { x in
                self.carplayInterfaceController!.pushTemplate(x, animated: true, completion: nil)
            })
            completion()
        }
    }
    
    func buttonTemp(listItem: CPListItem) {
        listItem.handler = { item, completion in
            print("grid")
            LocationManager.shared.UpdateAllowed(x: false, completion: { x in
                var grid: CPGridTemplate!
                self.gridTemplate(completion: { x in
                    grid = x
                    // Set the root template to the tab bar template
                    self.carplayInterfaceController!.pushTemplate(grid, animated: true, completion: nil)
                })
            })
        }
    }
    
    func searchHandlerForItem(listItem: CPListItem) {
        listItem.handler = { item, completion in
            self.presentCarPlayGrid()
            self.startVoiceSearch2()
        }
    }
        //listItem.handler = { item, completion in
        //listItem.handler = { item, completion in
        // Your closure code here
        
        /*
         let ok = CPAlertAction(title: "OK", style: .default) { _ in
         let art = fetchImage4(from: mediaClass.newArt?.absoluteString?)
         self.ListTemplate(title: mediaClass.title, artist: mediaClass.artist, art: art, completion: {x in
         let carPlayTemplate = x
         self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
         })
         }
         */
        /*
         let alert2 = CPActionSheetTemplate(
         title: "Complete Action In",
         message: "The Drivers Center Phone App",
         actions: [ok]
         )
         
         let sendLocation = CPAlertAction(title: "Send Location", style: .default) { _ in
         //self.sendLocation()
         DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
         self.carplayInterfaceController!.presentTemplate(alert2, animated: true, completion: nil)
         }
         }
         
         let showMaps = CPAlertAction(title: "Open Google Maps", style: .default) { _ in
         self.carplayScene?.open(self.url, options: nil, completionHandler: nil)
         }
         let cancel = CPAlertAction(title: "Cancel", style: .default) { _ in
         let viewModel = MediaItemViewModel.shared
         self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: viewModel.newArt?.absoluteString ?? "", completion: {x in
         let carPlayTemplate = x
         self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
         })
         }
         let alert = CPActionSheetTemplate(
         title: "Choose an Option",
         message: "Or Cancel Request",
         actions: [sendLocation, showMaps, cancel]
         )
         self.carplayInterfaceController!.presentTemplate(alert, animated: true, completion: nil)
         completion()
         
         
         */
    
    func openWeather(listItem: CPListItem) {
        listItem.handler = { item, completion in
            // opens map url
            self.carplayScene?.open(self.url2, options: nil, completionHandler: nil)
            completion()
        }
    }
    
    func updateTemplate2() {

        let currentTemplate: CPTemplate = self.carplayInterfaceController!.topTemplate ?? CPTemplate()
        let templateType = type(of: currentTemplate)
        let templateTitle = getCurrentTemplateTitle(template: currentTemplate)
        let searchString = "Loading"
        let searchString2 = "Wait"
        
        if (templateTitle.contains(searchString) && templateType == CPInformationTemplate.self) {
            print("please wait")

        } else if (templateTitle.contains(searchString2) && templateType == CPInformationTemplate.self) {
            print("plaese wait...")
 
        } else {

            if templateTitle == "Control Outdoor Lighting" {
                informationTemplate2(completion: { x in
                    self.carplayInterfaceController!.setRootTemplate(x, animated: false, completion: nil)
                })
            } else if templateTitle == "Control Garage Door" {
                informationTemplate(completion: { x in
                    self.carplayInterfaceController!.setRootTemplate(x, animated: false, completion: nil)
                })
            } else {
                //print("")
            }

        }
    }
    func startObservingNowPlaying() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingItemDidChange),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: musicPlayer
        )
        musicPlayer.beginGeneratingPlaybackNotifications()
    }
    
    @objc private func nowPlayingItemDidChange() {
        cnt = 0
    }
    
    func updateTemplate(with speed: Double) {

            print("updating Template")
            let currentTemplate: CPTemplate = self.carplayInterfaceController!.topTemplate ?? CPTemplate()
            let templateType = type(of: currentTemplate)
            let templateTitle = getCurrentTemplateTitle(template: currentTemplate)
            //print("templateType: \(templateType)")
            
            var tempCounter: Int = 0
            // get address
            if (counter == 0) {
                tempCounter += 1
                counter += 1
                getAddressFromLatLon()
                
            } else {
                tempCounter = 0
                counter = 0
            }
            
            // update location url
            let urlString = "comgooglemaps://?center=\(LocationManager.shared.latitude),\(LocationManager.shared.longitude)&zoom=14&views=traffic"
            url = URL(string: urlString)
            
            // update radar url
            let radarString = "myradar://"
            url2 = URL(string: radarString)
            
            if templateTitle == "" && templateType == CPListTemplate.self {
                _ = MediaItemViewModel.shared
                _ = self.fetchImage4(from: self.mediaClass.newArt?.absoluteString ?? "")
                Task {
                    let img = await getSong()
                    self.ListTemplate(title: musicPlayer.nowPlayingItem?.title ?? "", artist: musicPlayer.nowPlayingItem?.artist ?? "" , art: img, speedo: self.getSpeedo(), detailedText: LocationManager.shared.eta, completion: {x in
                        let carPlayTemplate = x
                        self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                    })
                    
                    
                    
                    
                }
            }
        

    }

    
    func imageName(forCode code: Int) -> String? {
        switch code {
                case 1000: return "113"
                case 1003: return "116"
                case 1006: return "119"
                case 1009: return "122"
                case 1030: return "143"
                case 1063: return "176"
                case 1066: return "179"
                case 1069: return "182"
                case 1072: return "185"
                case 1087: return "200"
                case 1114: return "227"
                case 1117: return "230"
                case 1135: return "248"
                case 1147: return "260"
                case 1150: return "263"
                case 1153: return "266"
                case 1168: return "281"
                case 1171: return "284"
                case 1180: return "293"
                case 1183: return "296"
                case 1186: return "299"
                case 1189: return "302"
                case 1192: return "305"
                case 1195: return "308"
                case 1198: return "311"
                case 1201: return "314"
                case 1204: return "317"
                case 1207: return "320"
                case 1210: return "323"
                case 1213: return "326"
                case 1216: return "329"
                case 1219: return "332"
                case 1222: return "335"
                case 1225: return "338"
                case 1237: return "350"
                case 1240: return "353"
                case 1243: return "356"
                case 1246: return "359"
                case 1249: return "362"
                case 1252: return "365"
                case 1255: return "368"
                case 1258: return "371"
                case 1261: return "374"
                case 1264: return "377"
                case 1273: return "386"
                case 1276: return "389"
                case 1279: return "392"
                case 1282: return "395"
                default: return nil
                }
    }
    


    
    
    func getCurrentTemplateTitle(template: CPTemplate) -> String {
        // Check if the template is a CPListTemplate
        if let infoTemplate = template as? CPInformationTemplate {
            return infoTemplate.title
        }
        
        if let listTemplate = template as? CPListTemplate {
            return listTemplate.title ?? "no updates"
        }
        
        if let gridTemplate = template as? CPGridTemplate {
            return gridTemplate.title
        }
        
        
        return "noUpdates"
    }

        func getAddressFromLatLon() {
            
            var center : CLLocationCoordinate2D = CLLocationCoordinate2D()
            let lat: Double = LocationManager.shared.latitude
            //21.228124
            let lon: Double = LocationManager.shared.longitude
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
            let lat: Double = LocationManager.shared.latitude
            //21.228124
            let lon: Double = LocationManager.shared.longitude
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
                    let center = CLLocationCoordinate2D(latitude: LocationManager.shared.latitude, longitude: LocationManager.shared.longitude)
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

class SpinnerViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.center = view.center
        spinner.startAnimating()
        
        view.addSubview(spinner)
    }
}

extension TemplateManager: CPSearchTemplateDelegate {
    func searchTemplate(
        _ searchTemplate: CPSearchTemplate,
        updatedSearchText searchText: String,
        completionHandler: @escaping ([CPListItem]) -> Void
    ) {
        Task {
            do {
                // Use your view model to fetch songs based on the search text
                let songs = try await MediaItemViewModel.shared.searchSongs(q: searchText)

                // Map songs to CPListItems
                let listItems = songs.map { song in
                    let item = CPListItem(
                        text: song.title,
                        detailText: song.artistName
                    )
                    item.handler = { _, completion in
                        // Create a Task to handle async function calls
                        Task {
                            do {
                                try await MediaItemViewModel.shared.playSelectedSong(song)
                                print("Playing song: \(song.title) by \(song.artistName)")
                            } catch {
                                print("Error playing selected song: \(error)")
                            }
                            completion()
                        }
                    }
                    return item
                }

                // Pass the list items back to the search template
                completionHandler(listItems)
            } catch {
                print("Error fetching search results: \(error)")
                completionHandler([]) // Return an empty array in case of failure
            }
        }
    }

    func searchTemplate(
        _ searchTemplate: CPSearchTemplate,
        selectedResult item: CPListItem,
        completionHandler: @escaping () -> Void
    ) {
        // Handle selection of a search result if needed
        completionHandler()
    }
}


