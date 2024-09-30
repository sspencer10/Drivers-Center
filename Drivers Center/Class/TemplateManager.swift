import UIKit
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
    
    @Published var currentTime: String = ""
    
    @AppStorage("gps_location", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var gps_location: String = ""
    @AppStorage("today_min", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var today_min: Double = 60.0
    @AppStorage("today_max", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var today_max: Double = 70.0
    @AppStorage("current_f", store: UserDefaults(suiteName: "group.DBJQ6YJG82.com.rightdevllc.CarSample2")) var current_f: Double = 0.0
    
    @State var wvm = WeatherViewModel.shared
    @State var musicPlayer = MPMusicPlayerController.systemMusicPlayer
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
    private var timer: Timer?
    private var currentOffset = 0
    private let batchSize = 11
    let albumBatchSize = 10
    let playlistBatchSize = 10
    
    weak var delegate: MyDelegate?
    
    var isCarPlay: Bool = false
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
    var lm = LocationManager.shared
    var listTemplate: CPTemplate!
    var cc = CurlCommands()
    var artImg: UIImage?
    var playlists: [MPMediaPlaylist] = []
    var previousType: String = ""
    var artUrl: String = "https://rightdevllc.com/images/592590040.png"
    var url: URL!
    var url2: URL!
    var myTimer: Timer?
    var myTimer2: Timer?
    var myTimer3: Timer?
    
    let configuration = UIImage.SymbolConfiguration.init(pointSize: 10)

    override init() {
        super.init()
    }

    //Called when CarPlay connects.
    func connect(_ interfaceController: CPInterfaceController, scene: CPTemplateApplicationScene) {
        
        carplayInterfaceController = interfaceController
        carplayScene = scene
        carplayInterfaceController!.delegate = self
        sessionConfiguration = CPSessionConfiguration(delegate: self)
        isCarPlay = true
        startCarPlayTimer()
        startCPTimer()
        lm.carplayStart()
        startTimer()
        
        Task {
            wvm.fetchText()
            await  wvm.fetchWeather()
        }
        
        let viewModel = MediaItemViewModel()
        self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: viewModel.artworkImage, completion: {x in
            let carPlayTemplate = x
            self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
        })
    }
    
    //Called when CarPlay disconnects.
    func disconnect() {
        stopCarPlayTimer()
        carplayScene = nil
        print("updating isCarPlay to false")
        isCarPlay = false
        UserDefaults.standard.setValue(false, forKey: "isCarPlay")
        lm.carplayStop()
    }
    
    // Start the timer
    func startCarPlayTimer() {
        myTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            self.updateTemplate()
        }
    }
    
    func startCPTimer() {
        myTimer2 = Timer.scheduledTimer(withTimeInterval: 4.0, repeats: true) { timer in
            self.updateTemplate2()
        }
    }
    
    // Stop the timer
    func stopCarPlayTimer() {
        myTimer?.invalidate()
        myTimer = nil
        myTimer2?.invalidate()
        myTimer2 = nil
    }
    
    func startTimer() {
        print("start timer")
        timer?.invalidate() // Invalidate any existing timer
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.updateTime()
        }
        timer?.fire()
    }
    
    func updateTime() {
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        currentTime = formatter.string(from: Date())
        print("Function executed at \(currentTime)")
        wvm.fetchText()
        // get weather
        Task {
            await wvm.fetchWeather()
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
            musicPlayer.pause()
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
    
    func loadNextPage(for mediaCollection: MPMediaItemCollection) {
        loadMoreSongs(for: mediaCollection, offset: currentOffset, batchSize: batchSize) { [weak self] newSongs in
            guard let self = self else { return }

            if let currentListTemplate = self.carplayInterfaceController?.topTemplate as? CPListTemplate,
               let currentSection = currentListTemplate.sections.first {

                var allItems = currentSection.items as? [CPListItem] ?? []

                // Remove the "Load More" item if it exists
                if let lastItem = allItems.last, lastItem.text == "Load More..." {
                    allItems.removeLast()
                }
                allItems.removeAll()
                // Add new songs to the list
                for song in newSongs {
                    let listItem = CPListItem(text: song.title ?? "Unknown Title", detailText: song.artist)
                    if let artwork = song.artwork {
                        let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
                        let artworkImage = artwork.image(at: imageSize)
                        listItem.setImage(artworkImage)
                    }
                    // Add the custom handler for new songs when tapped
                    listItem.handler = { [weak self] _, _ in
                        // Play the selected song
                        self?.playMediaCollection(mediaCollection, startingAt: song)

                        // Run your custom code when the song is tapped
                        self?.currentOffset = 0
                        let viewModel = MediaItemViewModel()
                        self?.ListTemplate(title: song.title ?? viewModel.title, artist: song.artist ?? viewModel.artist, art: viewModel.artworkImage, completion: { x in
                            let carPlayTemplate = x
                            self?.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                        })
                    }

                    allItems.append(listItem)
                }

                // Add the "Load More" item again if more songs are still available
                if self.currentOffset < mediaCollection.items.count - 1 {
                    let loadMoreItem = CPListItem(text: "Load More...", detailText: nil)
                    loadMoreItem.handler = { [weak self] _, _ in
                        self?.loadNextPage(for: mediaCollection)
                    }
                    allItems.append(loadMoreItem)
                } else {
                   let backItem = CPListItem(text: "Back", detailText: nil)
                    backItem.setImage(UIImage(systemName: "arrow.left"))
                    backItem.handler = { [weak self] _, _ in
                        self?.currentOffset = 0
                        let viewModel = MediaItemViewModel()
                        self?.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: viewModel.artworkImage, completion: { x in
                            let carPlayTemplate = x
                            self?.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                        })
                    }
                    allItems.append(backItem)
                }
                

                let newSection = CPListSection(items: allItems)
                let updatedTemplate = CPListTemplate(title: currentListTemplate.title, sections: [newSection])

                // Set the root template with the updated section
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
            self.lm.UpdateAllowed(x: false, completion: { x in
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
            self.lm.UpdateAllowed(x: false, completion: { x in
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

        // Load songs from the media collection
        loadMoreSongs(for: mediaCollection, offset: currentOffset, batchSize: batchSize) { [weak self] songs in
            guard let self = self else { return }

            // Add all the songs that were loaded
            for song in songs {
                let listItem = CPListItem(text: song.title ?? "Unknown Title", detailText: song.artist)
                if let artwork = song.artwork {
                    let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
                    let artworkImage = artwork.image(at: imageSize)
                    listItem.setImage(artworkImage)
                }
                // Add custom handler to run when a song is tapped
                listItem.handler = { [weak self] _, _ in
                    // Play the selected song
                    self?.playMediaCollection(mediaCollection, startingAt: song)

                    // Run your custom code when the song is tapped
                    if let artwork = song.artwork {
                        let imageSize = CGSize(width: 100, height: 100) // Specify the size you want
                        let artworkImage = artwork.image(at: imageSize)
                        // Now you can use artworkImage (which will be a UIImage) in your UI
                        self?.currentOffset = 0
                        let viewModel = MediaItemViewModel()
                        self?.ListTemplate(title: song.title ?? viewModel.title, artist: song.artist ?? viewModel.artist, art: artworkImage, completion: { x in
                            let carPlayTemplate = x
                            self?.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                        })
                    } else {
                        self?.currentOffset = 0
                        let viewModel = MediaItemViewModel()
                        self?.ListTemplate(title: song.title ?? viewModel.title, artist: song.artist ?? viewModel.artist, art: viewModel.artworkImage, completion: { x in
                            let carPlayTemplate = x
                            self?.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                        })
                    }
                }

                songItems.append(listItem)
            }

            // Add the "Load More" item if more songs are available to load
            if self.currentOffset < mediaCollection.items.count {
                let loadMoreItem = CPListItem(text: "Load More...", detailText: nil)
                loadMoreItem.handler = { [weak self] _, _ in
                    self?.loadNextPage(for: mediaCollection)
                }
                songItems.append(loadMoreItem)
            }

            // Prepare the title for the template
            let collectionTitle = title ?? mediaCollection.representativeItem?.albumTitle ?? "Songs"

            // Create a new section with the updated list of songs
            let section = CPListSection(items: songItems)

            // Set the root template with the new section to force CarPlay to refresh
            let listTemplate = CPListTemplate(title: collectionTitle, sections: [section])
            self.carplayInterfaceController!.setRootTemplate(listTemplate, animated: true, completion: nil)
        }
    }
    
    func ListTemplate(title: String, artist: String, art: UIImage?, completion: @escaping (CPListTemplate) -> Void) {
        var listItems: [CPListItem] = []
        // Iterate over each MPMediaItem in the mediaItems array
        let title3 = title
        let artist3 = artist
        var listItem3: CPListItem?

        listItem3 = CPListItem(text: title3, detailText: artist3)
        if art != nil {
            listItem3?.setImage(art)
        }
        
        listItems.append(listItem3 ?? CPListItem(text: "", detailText: ""))
        
        let img = UIImage(named: "\(dayName(forCode: wvm.is_day) ?? "day")/\(imageName(forCode: wvm.code) ?? "113")")
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
        let listItem = CPListItem(text: String(format: "%.1f MPH", self.lm.speed), detailText: self.lm.directionString)
        listItem.setImage(UIImage(named: "speed"))
        listItem.userInfo = "1"
        
        // List Item 2
        let listItem2 = CPListItem(text: ("\(String(self.wvm.temp))"), detailText: ("\(String(format: "%.0f", self.wvm.today_min))°/\(String(format: "%.0f", self.wvm.today_max))°"))
        listItem2.setImage(img_resized)
        listItem2.userInfo = "2"
        openWeather(listItem: listItem2)
        
        // List Item 4
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
    
    func gridTemplate(completion: @escaping (CPGridTemplate) -> Void) {
        lm.UpdateAllowed(x: false, completion: { x in })
        // Create grid buttons
        let gridButton1 = CPGridButton(titleVariants: ["Dashboard"], image: UIImage(systemName: "car.side")!) {_ in
            let viewModel = MediaItemViewModel()
            self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: viewModel.artworkImage, completion: {x in
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
            
        let gridButton4 = CPGridButton(titleVariants: ["Playlists"], image: UIImage(systemName: "text.line.first.and.arrowtriangle.forward")!) {_ in
            self.fetchPlaylists()
        }
        
        let gridButton5 = CPGridButton(titleVariants: ["Albums"], image: UIImage(systemName: "music.house")!) {_ in
            self.fetchAlbums()
        }
            
        // Create Grid Template with the buttons
        let gridTemplate = CPGridTemplate(title: "Main Menu", gridButtons: [gridButton5, gridButton4, gridButton3, gridButton2, gridButton1])
        
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
    

        
        
    func downloadImage(from artUrlString: String, completion: @escaping (UIImage?) -> Void) {
        if let url = URL(string: artUrlString) {
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil)
                    return
                }
                completion(UIImage(data: data))
            }.resume()
        }
    }
    
    // CPInterfaceControllerDelegate method
    func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        isCarPlay = true
        var type: String = ""
        if aTemplate is CPGridTemplate {
            type = "grid"
            lm.UpdateAllowed(x: false, completion: { x in
                if type != self.previousType {
                    print("type: \(type)")
                    self.previousType = type
                    print("allow updates: \(self.lm.UpdateAllowed())")
                }
            })
        } else if aTemplate is CPListTemplate {
            type = "list"
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.lm.UpdateAllowed(x: true, completion: { x in
                    if type != self.previousType {
                        print("type: \(type)")
                        self.previousType = type
                        print("allow updates: \(self.lm.UpdateAllowed())")
                    }
                })            }
        } else if aTemplate is CPInformationTemplate {
            type = "info"
            lm.UpdateAllowed(x: false, completion: { x in
                if type != self.previousType {
                    print("type: \(type)")
                    self.previousType = type
                    print("allow updates: \(self.lm.UpdateAllowed())")
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
            self.lm.UpdateAllowed(x: false, completion: { x in
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
            if self.musicPlayer.playbackState == .playing {
                self.musicPlayer.pause()
            } else {
                self.musicPlayer.play()
            }
        }
    }
    
    func buttonTemp(listItem: CPListItem) {
        listItem.handler = { item, completion in
            print("grid")
            self.lm.UpdateAllowed(x: false, completion: { x in
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

            let ok = CPAlertAction(title: "OK", style: .default) { _ in
                let viewModel = MediaItemViewModel()
                self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: viewModel.artworkImage, completion: {x in
                    let carPlayTemplate = x
                    self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
                })
            }
            
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
                let viewModel = MediaItemViewModel()
                self.ListTemplate(title: viewModel.title, artist: viewModel.artist, art: viewModel.artworkImage, completion: {x in
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
        }
    }
    
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
    
    
func updateTemplate() {
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
    let urlString = "comgooglemaps://?center=\(lm.latitude),\(lm.longitude)&zoom=14&views=traffic"
    url = URL(string: urlString)
    
    // update radar url
    let radarString = "myradar://"
    url2 = URL(string: radarString)
    
    if templateTitle == "" && templateType == CPListTemplate.self {
        let viewModel = MediaItemViewModel()
        ListTemplate(title: viewModel.title, artist: viewModel.artist, art: viewModel.artworkImage, completion: {x in
            let carPlayTemplate = x
            self.carplayInterfaceController!.setRootTemplate(carPlayTemplate, animated: true, completion: nil)
        })
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
            let lat: Double = lm.latitude
            //21.228124
            let lon: Double = lm.longitude
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
            let lat: Double = lm.latitude
            //21.228124
            let lon: Double = lm.longitude
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
                    let center = CLLocationCoordinate2D(latitude: lm.latitude, longitude: lm.longitude)
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
