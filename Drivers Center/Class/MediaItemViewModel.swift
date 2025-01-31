
import SwiftUI
import MediaPlayer
import MusicKit

// MARK: - MediaItemViewModel

class MediaItemViewModel: ObservableObject {
    
    public static var shared = MediaItemViewModel()

    
    @Published var artworkImage: UIImage?
    @Published var title: String = "Unknown Title"
    @Published var artist: String = "Unknown Artist"
    @Published var mediaItems: [MPMediaItem] = []
    @Published var playlists: [MPMediaPlaylist] = []
    @Published var nowPlayingAlbumID: MPMediaEntityPersistentID?
    @Published var newArt: URL?



    private var musicPlayer: MPMusicPlayerController?

    private var currentMediaItemId: UInt64?
    private var cachedArtworkImage: UIImage?
    private var debounceTimer: Timer?

    private init() {
        self.musicPlayer = MPMusicPlayerController.systemMusicPlayer
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemDidChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerStateDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
        
        musicPlayer?.beginGeneratingPlaybackNotifications()
        updateCurrentMediaItem()
        fetchPlaylists()
        fetchMediaItems { items in
            self.mediaItems = items
        }
        
        
    }

    var playbackState: MPMusicPlaybackState {
        return musicPlayer?.playbackState ?? .stopped
    }
    
    
    func getAuthorized(completion: @escaping (Bool) -> Void) {
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                print("authorized")
                UserDefaults.standard.set(true, forKey: "authorized")
                UserDefaults.standard.set(true, forKey: "checked")
                //self.getArt(completion: {_ in})
                completion(true)
            } else {
                print("not authorized")
                UserDefaults.standard.set(false, forKey: "authorized")
                completion(false)
            }
            
        }
    }

    func getNowPlayingTitle(completion: @escaping (String) -> Void) {
        if let nowPlayingItem = musicPlayer?.nowPlayingItem {
            let nowPlayingTitle = nowPlayingItem.title ?? "Unknown Title"
            print("Title: \(nowPlayingTitle)")
            completion(nowPlayingTitle)
        } else {
            let nowPlayingTitle = "Not Playing"
            completion(nowPlayingTitle)
        }
    }
    
    func getNowPlayingArtist(completion: @escaping (String) -> Void) {
        if let nowPlayingItem = musicPlayer?.nowPlayingItem {
            let nowPlayingArtist = nowPlayingItem.artist ?? "Unknown Artist"
            print("Artist: \(nowPlayingArtist)")
            completion(nowPlayingArtist)
        } else {
            let nowPlayingArtist = "Not Playing"
            completion(nowPlayingArtist)
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
    
    func getID() async {
        fetchAlbumFromCatalog(title: title, artist: artist) { album in
            if let album = album {
                print("Album found: \(album.title) by \(album.artistName)")
                if let artworkUrl = album.artwork?.url(width: 500, height: 500) {
                    print("Artwork URL: \(artworkUrl)")
                    self.newArt = artworkUrl
                } else {
                    print("No artwork URL available.")
                }
            } else {
                print("Album not found in the catalog.")
            }
        }
    }

     func startObservingNowPlaying() {
        // Add observer for now playing item changes
        NotificationCenter.default.addObserver(forName: .MPMusicPlayerControllerNowPlayingItemDidChange,
                                               object: MPMusicPlayerController.systemMusicPlayer,
                                               queue: .main) { _ in
            Task {
                await self.getID()
            }
        }

        // Start monitoring
        MPMusicPlayerController.systemMusicPlayer.beginGeneratingPlaybackNotifications()
    }

     func stopObservingNowPlaying() {
        // Remove observer when no longer needed
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: MPMusicPlayerController.systemMusicPlayer)

        // Stop monitoring
        MPMusicPlayerController.systemMusicPlayer.endGeneratingPlaybackNotifications()
    }
    
    func getNowPlayingAlbumID(completion: @escaping (MPMediaEntityPersistentID?) -> Void) {
        let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        if let albumID = nowPlayingItem?.albumPersistentID {
            completion(albumID)
        } else {
            print("No now-playing item or no album ID available.")
            completion(nil)
        }
    }

    func play() {
        musicPlayer?.play()
    }

    func pause() {
        musicPlayer?.pause()
    }

    func skipToNextItem() {
        musicPlayer?.skipToNextItem()
    }

    func skipToPreviousItem() {
        musicPlayer?.skipToPreviousItem()
    }

    func playPlaylist(_ playlist: MPMediaPlaylist, startingAt song: MPMediaItem? = nil) {
        musicPlayer?.setQueue(with: playlist)
        if let song = song {
            musicPlayer?.nowPlayingItem = song
        }
        musicPlayer?.play()
        updateCurrentMediaItem()
    }

    @objc private func nowPlayingItemDidChange() {
        debounceUpdate()
    }

    @objc private func playerStateDidChange() {
        debounceUpdate()
    }

    private func debounceUpdate() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            self?.updateCurrentMediaItem()
        }
    }

    private func updateCurrentMediaItem() {
        guard let nowPlayingItem = musicPlayer?.nowPlayingItem else { return }
        if nowPlayingItem.persistentID != currentMediaItemId {
            currentMediaItemId = nowPlayingItem.persistentID
            title = nowPlayingItem.title ?? "Unknown Title"
            artist = nowPlayingItem.artist ?? "Unknown Artist"
            updateArtworkImage(for: nowPlayingItem)
        }
    }

    private func updateArtworkImage(for mediaItem: MPMediaItem) {
        if let cachedImage = cachedArtworkImage, currentMediaItemId == mediaItem.persistentID {
            artworkImage = cachedImage
        } else {
            
            artworkImage = mediaItem.artwork?.image(at: CGSize(width: 3000, height: 3000))
            cachedArtworkImage = artworkImage
        }
    }

    private func resetMediaItem() {
        DispatchQueue.main.async {
            self.title = "Unknown Title"
            self.artist = "Unknown Artist"
            self.artworkImage = nil
            self.cachedArtworkImage = nil
            self.currentMediaItemId = nil
        }
    }

    func fetchPlaylists() {
        let playlistsQuery = MPMediaQuery.playlists()
        if let playlists = playlistsQuery.collections as? [MPMediaPlaylist] {
            DispatchQueue.main.async {
                self.playlists = playlists
            }
        } else {
            print("No playlists found.")
        }
    }

    func fetchMediaItems(completion: @escaping ([MPMediaItem]) -> Void) {
        let query = MPMediaQuery.songs()
        if let items = query.items {
            DispatchQueue.main.async {
                completion(items)
                self.mediaItems = items
            }
        } else {
            print("No media items found.")
            completion([])
        }
    }

    deinit {
        musicPlayer?.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }
}



// MARK: - ControlButton

struct ControlButton: View {
    let iconName: String
    let action: () -> Void

    var body: some View {
        if let uiImage = UIImage(systemName: iconName)?.withRenderingMode(.alwaysTemplate) {
            Button(action: action) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 50, height: 50)
                    .foregroundColor(Color("night"))
            }
        } else {
            Text("No Image Available")
        }
    }
}

// MARK: - PlaylistView

struct PlaylistView: View {
    @ObservedObject var viewModel: MediaItemViewModel
    
    var body: some View {
        NavigationView {
            List(viewModel.playlists, id: \.persistentID) { playlist in
                NavigationLink(destination: SongListView(playlist: playlist, viewModel: viewModel)) {
                    Text(playlist.name ?? "Unknown Playlist")
                        .padding()
                }
            }
            .navigationTitle("Playlists")
        }
    }
}

// MARK: - SongListView

struct SongListView: View {
    var playlist: MPMediaPlaylist
    @ObservedObject var viewModel: MediaItemViewModel
    
    var body: some View {
        List(playlist.items, id: \.persistentID) { song in
            Button(action: {
                viewModel.playPlaylist(playlist, startingAt: song)
            }) {
                VStack(alignment: .leading) {
                    Text(song.title ?? "Unknown Title")
                        .font(.headline)
                    Text(song.artist ?? "Unknown Artist")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .padding()
            }
        }
        .navigationTitle(playlist.name ?? "Songs")
    }
}


import MusicKit

extension MediaItemViewModel {
    
    
    func fetchAppleMusicArtwork(for albumID: String, completion: @escaping (UIImage?) -> Void) {
        // Perform a catalog search for the album using its ID
        Task {
            do {
                // Replace `albumID` with the Apple Music catalog ID format
                let request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: MusicItemID(albumID))
                let response = try await request.response()
                
                guard let album = response.items.first else {
                    print("Album not found")
                    completion(nil)
                    return
                }
                
                if let artworkURL = album.artwork?.url(width: 500, height: 500) {
                    // Download the artwork image
                    let imageData = try Data(contentsOf: artworkURL)
                    let image = UIImage(data: imageData)
                    completion(image)
                } else {
                    print("Artwork URL not available")
                    completion(nil)
                }
            } catch {
                print("Error fetching album artwork: \(error.localizedDescription)")
                completion(nil)
            }
        }
    }
}

class Media: ObservableObject {
    @Published var nowPlayingAlbumID: MPMediaEntityPersistentID?

    func getNowPlayingAlbumID(completion: @escaping (MPMediaEntityPersistentID?) -> Void) {
        let nowPlayingItem = MPMusicPlayerController.systemMusicPlayer.nowPlayingItem
        if let albumID = nowPlayingItem?.albumPersistentID {
            completion(albumID)
        } else {
            print("No now-playing item or no album ID available.")
            completion(nil)
        }
    }
}
