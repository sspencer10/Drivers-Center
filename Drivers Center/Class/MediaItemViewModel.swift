import SwiftUI
import MediaPlayer
import MusicKit
import StoreKit

class MediaItemViewModel:  @unchecked Sendable, ObservableObject {
    public static var shared = MediaItemViewModel()
    @Published var artworkImage: UIImage?
    @Published var title: String = "Unknown Title"
    @Published var artist: String = "Unknown Artist"
    @Published var artwork: UIImage?
    @Published var mediaItems: [MPMediaItem] = []
    @Published var playlists: [MPMediaPlaylist] = []
    @Published var nowPlayingAlbumID: MPMediaEntityPersistentID?
    @Published var newArt: URL?
    @Published var newArt2: UIImage?
    @Published var isCarPlay: Bool = false
    @Published var bypassed: Bool = false
    @Published var favorites: Set<UInt64> = []
    @Published var systemVolume: Float = 0.0
    @Published var currentPlaybackTime: TimeInterval = 0
    @Published var totalPlaybackTime: TimeInterval = 0
    @Published var currentTimeString: String = "0:00"
    @Published var remainingTimeString: String = "-0:00"
    @Published var songArray: [String] = []
    @Published var plSongs: [Song] = []
    @Published var albumID: MusicItemID?
    @Published var album: Album?
    @Published var albums: [MPMediaItemCollection] = []
    @Published var songs: [MPMediaItem] = []
    
    var selectedSong: MusicKit.Song?
    var showSheet: Bool = false
    var showSearchSheet: Bool = false
    var showMenu: Bool = false
    var showAlbums: Bool = false
    var showSongs: Bool = false
    var showPlaylist: Bool = false
    var savedSong: String = ""
    var savedArtist: String = ""
    var searchFlag: Bool = false
    var genres: [String] = []
    var musicItemID: MusicItemID?
    var lastSongStoreID: String?
    let apiKey = "4fb73e8d151e5fe3fc9f1575af974a59"
    private let queueLock = DispatchQueue(label: "com.example.queueLock")
    
    private var currentQueue: [String] = [] // Track store IDs of the queue
    private var recentlyPlayedIDs: [String] = [] // Tracks recently played store IDs
    private let maxRecentlyPlayed = 15 // Adjust as needed
    private var currentMediaItemId: UInt64?
    private var cachedArtworkImage: UIImage?
    private var debounceTimer: Timer?
    private var progressUpdateTimer: Timer?

    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer


    private init() {
        requestAppleMusicPermissions()
        self.musicPlayer = MPMusicPlayerController.applicationQueuePlayer
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemDidChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(playerStateDidChange), name: .MPMusicPlayerControllerPlaybackStateDidChange, object: musicPlayer)
        
        musicPlayer.beginGeneratingPlaybackNotifications()
        updateCurrentMediaItem()
        fetchPlaylists()
        fetchMediaItems { items in
            self.mediaItems = items
        }
        startProgressUpdateTimer()
        Task {
            await musicInit()
        }
        startObservingNowPlaying()
        lastSongStoreID = UserDefaults.standard.string(forKey: "lastSongStoreID") ?? ""
        Task {
            let song = try await fetchSong(byStoreID: lastSongStoreID ?? "")
            guard let song = song else { return }
            try await playSelectedSong(song)
            musicPlayer.pause()
        }
    }
        
    func fetchSong(byStoreID storeID: String) async throws -> Song? {
        do {
            // Create a catalog request for a specific song using the store ID
            let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(storeID))
            
            // Perform the request
            let response = try await request.response()
            
            // Return the first song found (if any)
            return response.items.first
        } catch {
            print("Error fetching song: \(error)")
            return nil
        }
    }
    
    func musicInit() async {
        do {
            try await requestAuthorization()
            let playlists = try await fetchUserPlaylists()
            if let _ = playlists.first(where: { $0.name == "AAA" }) {
                print("test - playlist exists")
                await getPlaylistSongs()
            } else {
                print("test - playlist does not exist")
                let _ = try await createMyPlaylist()
            }
            
        } catch {
            if let _ = error as? MusicError {
            }
            print("Error: \(error.localizedDescription)")
        }
    }
    
    func fetchNowPlayingItemDetails() async throws -> MusicItem? {
        // Get the now-playing item from the system music player
        let player = MPMusicPlayerController.systemMusicPlayer
        guard let nowPlayingItem = player.nowPlayingItem else {
            throw NSError(domain: "NowPlayingError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No now-playing item found."])
        }
        
        // Retrieve the Apple Music catalog ID
        guard let catalogID = nowPlayingItem.value(forProperty: "playbackStoreID") as? String else {
            throw NSError(domain: "CatalogIDError", code: 2, userInfo: [NSLocalizedDescriptionKey: "The now-playing item does not have a valid catalog ID."])
        }
        
        let musicItemID = MusicItemID(catalogID)
        
        // Fetch the resource details (Assuming it's a song, as MPMediaItem does not directly indicate albums or playlists)
        return try await fetchSongDetails(catalogID: musicItemID)
    }
    
    private func fetchSongDetails(catalogID: MusicItemID) async throws -> Song {
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: catalogID)
        let response = try await request.response()
        guard let song = response.items.first else {
            throw NSError(domain: "SongDetailsError", code: 4, userInfo: [NSLocalizedDescriptionKey: "No song found with the given catalog ID."])
        }
        return song
    }
    
    func doThis() {
        Task {
            do {
                if let detailedItem = try await fetchNowPlayingItemDetails() {
                    if let song = detailedItem as? Song {
                        musicItemID = song.id
                        print("song details - Song Title: \(song.title)")
                        print("song details - Artist Name: \(song.artistName)")
                        print("song details - Album Name: \(song.albumTitle ?? "N/A")")
                        print("song details - Artist URL: \(song.artistURL?.absoluteString ?? "")")
                        print("song details - genreNames: \(song.genreNames)")
                        genres = song.genreNames
                        print("song details - albums: \(song.albums?.count ?? .zero)")
                        print("song details - musicVideos: \(song.musicVideos?.first?.url?.absoluteString ?? "")")
                        print("song details - previewAssets: \(song.previewAssets ?? [])")
                        print("song details - station url: \(song.station?.url?.absoluteString ?? "" )")
                    }
                } else {
                    print("No details found for the now-playing item.")
                }
            } catch {
                print("Error fetching details: \(error)")
            }
        }
        
    }
    
    func fetchAlbums() {
        let query = MPMediaQuery.albums()
        if let collections = query.collections {
            DispatchQueue.main.async {
                self.albums = collections
            }
        }
    }
    
    func fetchSongs() {
        let query = MPMediaQuery.songs()
        if let items = query.items {
            DispatchQueue.main.async {
                self.songs = items
            }
        }
    }
    
    // Playback State
    var playbackState: MPMusicPlaybackState {
        return musicPlayer.playbackState
    }
   
    // Update playback progress
    private func startProgressUpdateTimer() {
        progressUpdateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task {
                self?.updatePlaybackProgress()
            }
        }
    }
    
    func requestAppleMusicPermissions() {
        let status = MPMediaLibrary.authorizationStatus()
        if status == .notDetermined {
            MPMediaLibrary.requestAuthorization { newStatus in
                if newStatus != .authorized {
                    print("Apple Music access denied.")
                }
            }
        } else if status != .authorized {
            print("Apple Music access not granted.")
        }
    }
    
    func isSongInLibraryPlaylist(title: String) -> Bool {
        print("test - \(title)")
        let found = songArray.contains(where: { $0.contains(title) })
        return found
    }
    
    func searchSongDelete(q: String) async throws -> Bool {
        var searchRequest = MusicCatalogSearchRequest(
            term: "\(q)",
            types: [MusicKit.Song.self]
        )
        searchRequest.limit = 1

        let searchResponse = try await searchRequest.response()

        guard let song = searchResponse.songs.first else {
            throw MusicError.songNotFound
        }
        
        //let songDetails = "\(song.title) \(song.artistName)"
        Task {
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                
                self.songArray = self.songArray.filter { !$0.contains(song.title) }
                print("songArray: \(self.songArray)")
                
                
                self.plSongs = self.plSongs.filter {
                    let title = $0.title
                    return !title.contains(song.title)
                }
            }
            try await updatePlaylist()
        }

        return false
    }
    

    func searchSong(q: String) async throws -> Bool {
        var searchRequest = MusicCatalogSearchRequest(
            term: "\(q)",
            types: [MusicKit.Song.self]
        )
        searchRequest.limit = 1

        let searchResponse = try await searchRequest.response()

        guard let song = searchResponse.songs.first else {
            throw MusicError.songNotFound
        }
        let songDetails = "\(song.title) \(song.artistName)"
        print("add \(songDetails) to playlist")
        Task {
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                songArray.append(songDetails)
                plSongs.append(song)
                print("songArray \(songArray)")
                print("plSongs \(plSongs)")
            }
            try await updatePlaylist()
        }
        return true
    }
    
/*
    /// Finds an MPMediaItem in the user's library that matches the given MusicKit.Song
    func findMPMediaItem(for song: MusicKit.Song) -> MPMediaItem? {
        // Create a query for songs in the media library
        let query = MPMediaQuery.songs()
        
        // Filter the query by title and artist
        let titlePredicate = MPMediaPropertyPredicate(value: song.title, forProperty: MPMediaItemPropertyTitle, comparisonType: .contains)
        let artistPredicate = MPMediaPropertyPredicate(value: song.artistName, forProperty: MPMediaItemPropertyArtist, comparisonType: .contains)
        
        query.addFilterPredicate(titlePredicate)
        query.addFilterPredicate(artistPredicate)
        
        // Retrieve the matching items
        guard let items = query.items, !items.isEmpty else {
            print("No matching MPMediaItem found for \(song.title) by \(song.artistName)")
            return nil
        }
        
        // Return the first matching item
        return items.first
    }
    */
    func fetchPlaylist(by name: String) async -> MPMediaPlaylist? {
        // Create a query for playlists in the media library
        let query = MPMediaQuery.playlists()
        
        // Create a predicate to filter playlists by name
        let predicate = MPMediaPropertyPredicate(
            value: name,
            forProperty: MPMediaPlaylistPropertyName,
            comparisonType: .contains
        )
        
        query.addFilterPredicate(predicate)
        
        // Get the matching playlists
        guard let playlists = query.collections as? [MPMediaPlaylist] else {
            print("No playlists found.")
            return nil
        }
        
        // Return the first matching playlist
        return playlists.first
    }
    /*
    func playSong(_ song: MusicKit.Song) async throws -> Bool {
        
        let theSong = try await searchSong2(q: "\(song.title) \(song.artistName)")
        
        let playlist = await fetchPlaylist(by: "AAA")!
            
        //playPlaylist(playlist, startingAt: findMPMediaItem(for: theSong))
        musicPlayer.setQueue(with: playlist)
        let finalSong = findMPMediaItem(for: theSong)
        musicPlayer.nowPlayingItem = finalSong
        
        musicPlayer.play()
        updateCurrentMediaItem()
        
        
        return false
    }
     */
    func searchSongs(q: String) async throws -> [MusicKit.Song] {
        var searchRequest = MusicCatalogSearchRequest(
            term: q,
            types: [MusicKit.Song.self]
        )
        searchRequest.limit = 25 // Adjust the limit as needed

        let searchResponse = try await searchRequest.response()
        print("Search Response: \(searchResponse.songs)")

        // Convert MusicItemCollection<Song> to [Song]
        let songs = Array(searchResponse.songs)

        return songs
    }
    
    func searchSong2(q: String) async throws -> Song {
        var searchRequest = MusicCatalogSearchRequest(
            term: "\(q)",
            types: [MusicKit.Song.self]
        )
        searchRequest.limit = 1

        let searchResponse = try await searchRequest.response()

        guard let song = searchResponse.songs.first else {
            throw MusicError.songNotFound
        }
       // let songDetails = "\(song.title) \(song.artistName)"
        /*
        Task {
            await MainActor.run { [weak self] in
                guard let self = self else { return }
                songArray.append(songDetails)
                plSongs.append(song)
            }
            if let theSong = findMPMediaItem(for: song) {
                try await updatePlaylist2(song: theSong)
            }
        }
         */
        return song
    }
    
    func requestAuthorization() async throws {
        let status = await MusicAuthorization.request()
        guard status == .authorized else {
            throw MusicError.notAuthorized
        }
    }
    
    func fetchUserPlaylists() async throws -> [Playlist] {
        let playlistsRequest = MusicLibraryRequest<Playlist>()
        let playlistsResponse = try await playlistsRequest.response()
        return Array(playlistsResponse.items)
    }
    
    func playSelectedSong(_ song: MusicKit.Song) async throws {
        let songToPlay = try await searchSong2(q: "\(song.title) \(song.artistName)")
        let storeID = songToPlay.id.rawValue
        
        print("test421 - Playing selected song: \(song.title) by \(song.artistName), storeID: \(storeID)")

        currentQueue = [storeID]
        appendToRecentlyPlayedIDs([storeID])
        musicPlayer.setQueue(with: currentQueue)
        
        print("test421 - Initial queue set: \(currentQueue)")

        musicPlayer.play()
        disableRepeat()
        updateCurrentMediaItem()
        extendPlaybackQueue()
    }
    
    func playPlaylist(_ playlist: MPMediaPlaylist, startingAt song: MPMediaItem? = nil) {
        musicPlayer.setQueue(with: playlist)
        if let song = song {
            musicPlayer.nowPlayingItem = song
            print("set now playing song \(song)")
        } else {
            print("unable to set now playing song")
        }
        musicPlayer.play()
        updateCurrentMediaItem()
    }
    

    
    func createMyPlaylist() async throws -> Playlist {
        let status = await MusicAuthorization.request()
        guard status == .authorized else {
            throw MusicError.notAuthorized
        }
        print("test2 - Authorization granted.")
        let playlistName = "AAA"
        let playlistDescription = "A playlist of my favorite tracks."
        let authorDisplayName = "Steve Spencer"
        print("test2 - Attempting to create playlist with name: \(playlistName)")


        // Fetch existing playlists
        let existingPlaylists = try await fetchUserPlaylists()
        print("test2 - Retrieved \(existingPlaylists.count) playlists.")

        if let existingPlaylist = existingPlaylists.first(where: { $0.name == playlistName }) {
            print("test2 - Playlist already exists: \(existingPlaylist.id)")
            return existingPlaylist
        }
        print("playlist named \(playlistName) does not exist")

        // Attempt to create the playlist
        do {
            print("attempting to create playlist...")
            let playlist = try await MusicLibrary.shared.createPlaylist(
                name: playlistName,
                description: playlistDescription,
                authorDisplayName: authorDisplayName
            )
            print("test2 - Successfully created playlist: \(playlist.id)")
            return playlist
        } catch let error as MusicError {
            print("test2 - MusicError: \(error.localizedDescription)")
            throw MusicError.playlistCreationFailed(error.localizedDescription)
        } catch {
            print("test2 - Unexpected error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func updatePlaylist() async throws {
        
        var request = MusicLibraryRequest<Playlist>()
        request.filter(matching: \.name, equalTo: "AAA")
        let response = try await request.response()

        guard let playlist = response.items.first else {
            print("Playlist with name: 'AAA' not found.")
            return
        }
        
        try await MusicLibrary.shared.edit(
            playlist,
            name: nil,
            description: nil,
            authorDisplayName: nil,
            items: plSongs
        )
        print("Successfully added \(plSongs.count) songs to '\(playlist.id)'.")
        
         

         
    }
    
    func updatePlaylist2(song: MPMediaItem) async throws {
        
        var request = MusicLibraryRequest<Playlist>()
        request.filter(matching: \.name, equalTo: "AAA")
        let response = try await request.response()

        guard let playlist = response.items.first else {
            print("Playlist with name: 'AAA' not found.")
            return
        }
        
        try await MusicLibrary.shared.edit(
            playlist,
            name: nil,
            description: nil,
            authorDisplayName: nil,
            items: plSongs
        )
        print("Successfully added \(plSongs.count) songs to '\(playlist.id)'.")
        
        //musicPlayer.setQueue(with: playlist)
        //let finalSong = findMPMediaItem(for: theSong)
        musicPlayer.nowPlayingItem = song
        
        musicPlayer.play()
        updateCurrentMediaItem()
    }
    
    func getPlaylistSongs() async {
        do {
            var request = MusicLibraryRequest<Playlist>()
            request.filter(matching: \.name, equalTo: "AAA")
            let response = try await request.response()

            let playlist = response.items.first
            if playlist?.name != "AAA" {
                print("Playlist with name 'AAA' not found.")
                let _ = try await createMyPlaylist()
            }
            guard let playlist = playlist else { return }

            print("Curator Name: \(playlist.curatorName ?? "Unknown Curator")")
            print("Playlist Details: \(playlist)")

            let detailedPlaylist = try await playlist.with([.tracks])
            let tracks = detailedPlaylist.tracks ?? []

            print("Processing songs in playlist '\(playlist.name)'...")

            for track in tracks {
                switch track {
                case .song(let song):
                    let songDetails = "\(song.title) \(song.artistName)"
                    if !isSongInLibraryPlaylist(title: songDetails) {
                        Task {
                            await MainActor.run {
                                songArray.append(songDetails)
                                plSongs.append(song)
                            }
                        }
                    }
                default:
                    print("Unsupported track type in playlist.")
                }
            }

            print("Songs added to array: \(songArray)")
        } catch {
            print("An error occurred while refreshing the playlist: \(error)")
        }
    }

    private func updatePlaybackProgress() {
        let musicPlayer = self.musicPlayer
        guard let nowPlayingItem = musicPlayer.nowPlayingItem else {
            DispatchQueue.main.async {
                self.currentPlaybackTime = 0
                self.totalPlaybackTime = 0
                self.currentTimeString = "0:00"
                self.remainingTimeString = "-0:00"
            }
            return
        }
        DispatchQueue.main.async {
            self.currentPlaybackTime = musicPlayer.currentPlaybackTime
            self.totalPlaybackTime = nowPlayingItem.playbackDuration
            self.currentTimeString = self.formatTime(self.currentPlaybackTime)
            self.remainingTimeString = "-\(self.formatTime(self.totalPlaybackTime - self.currentPlaybackTime))"
        }
    }
    
    func fetchSystemVolume() {
        systemVolume = AVAudioSession.sharedInstance().outputVolume
    }
    
    func seek(to time: Float) {
        let musicPlayer = self.musicPlayer
        let newTime = TimeInterval(time) // Convert Float to TimeInterval (Double)
        
        // Ensure the new time is within the bounds of the total playback duration
        if newTime >= 0 && newTime <= totalPlaybackTime {
            musicPlayer.currentPlaybackTime = newTime
        } else {
            print("Seek time out of bounds: \(newTime)")
        }
    }

    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    // Stop the progress update timer
    deinit {
        progressUpdateTimer?.invalidate()
        musicPlayer.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }

    // Fetch album from catalog
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

    // Fetch album artwork and ID
    func getID2() {
        fetchAlbumFromCatalog(title: title, artist: artist) { album in
            if let album = album {
                print("Album found: \(album.title) by \(album.artistName)")
                let art = self.musicPlayer.nowPlayingItem?.artwork?.image(at: CGSize(width: 500, height: 500))
                if let artworkUrl = album.artwork?.url(width: 500, height: 500) {
                    print("Artwork URL: \(artworkUrl)")
                    DispatchQueue.main.async {
                        self.newArt = artworkUrl
                        self.newArt2 = art
                    }
                } else {
                    print("No artwork URL available.")
                }
            } else {
                print("Album not found in the catalog.")
            }
        }
    }
    
    func getID(
        songTitle: String,
        artistName: String/*, completion: @escaping ((URL?)) -> (Void)*/) async throws -> (String){
            let title = musicPlayer.nowPlayingItem?.title ?? "Unknown Song"
            let artist = musicPlayer.nowPlayingItem?.artist ?? "Unknown Artist"
            // --- STEP 1: Search for the Song by (songTitle, artistName) ---
            var songRequest = MusicCatalogSearchRequest(
                term: "\(title) \(artist)",
                types: [Song.self]
            )
            songRequest.limit = 25
            let songResponse = try await songRequest.response()
            
            // Naive match for the first Song that includes both strings
            guard let matchedSong = songResponse.songs.first(where: {
                $0.title.localizedCaseInsensitiveContains(title)
                && $0.artistName.localizedCaseInsensitiveContains(artist)
            }) else {
                print("No matching song found in Apple Music catalog.")
                return ""
            }
            
            // iOS 16's `Song` provides `albumTitle` and `artistName` as optional Strings.
            // Replace nil with "" to avoid optional-binding errors.
            let albumTitle = matchedSong.albumTitle ?? ""
            let albumArtist = matchedSong.artistName  // also a String? but we used it above, safe to keep going
            
            // If albumTitle or albumArtist is empty, we can’t search meaningfully
            guard !albumTitle.isEmpty, !albumArtist.isEmpty else {
                print("Song has no valid albumTitle or albumArtist.")
                return ""
            }
            
            // --- STEP 2: Search for the Album by (albumTitle, albumArtist) ---
            var albumRequest = MusicCatalogSearchRequest(
                term: "\(albumTitle) \(albumArtist)",
                types: [Album.self]
            )
            albumRequest.limit = 25
            print("albumRequest \(albumRequest)")
            let albumResponse = try await albumRequest.response()
            
            // Naive match for the album
            guard let matchedAlbum = albumResponse.albums.first(where: {
                $0.title.localizedCaseInsensitiveContains(albumTitle)
                && $0.artistName.localizedCaseInsensitiveContains(albumArtist)
            }) else {
                print("No matching album found in Apple Music catalog.")
                return ""
            }
            
            
            if let artworkUrl = matchedAlbum.artwork?.url(width: 500, height: 500) {
                DispatchQueue.main.async {
                    self.albumID = matchedAlbum.id
                    self.album = matchedAlbum
                    self.newArt = artworkUrl
                }
                return artworkUrl.absoluteString
            } else {
                return ""
            }
        }
            


    /// Adds an album to the user's Apple Music library using its `MusicItemID`.
    func addAlbumToLibrary() async throws {
        // 1) Fetch the Album object using the ID
        let album = try await fetchAlbumByID(albumID: albumID ?? "")
        
        // 2) Add the Album to the library
        try await MusicLibrary.shared.add(album)
    }

    /// Fetches an `Album` object from the Apple Music catalog by its `MusicItemID`.
    func fetchAlbumByID(albumID: MusicItemID) async throws -> Album {
        // Use `MusicCatalogResourceRequest` to fetch the album by its ID
        let request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: albumID)
        let response = try await request.response()
        
        // Ensure the response contains the album
        guard let album = response.items.first else {
            throw NSError(
                domain: "com.example.musicapp",
                code: 404,
                userInfo: [NSLocalizedDescriptionKey: "Album not found in Apple Music catalog."]
            )
        }
        
        return album
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

    func stopObservingNowPlaying() {
        NotificationCenter.default.removeObserver(self, name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: MPMusicPlayerController.systemMusicPlayer)
        MPMusicPlayerController.systemMusicPlayer.endGeneratingPlaybackNotifications()
    }

    // Fetch playlists
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

    // Fetch media items
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

    // Playback controls
    func play() {
        musicPlayer.play()
    }

    func pause() {
        musicPlayer.pause()
    }

    func skipToNextItem() {
        musicPlayer.skipToNextItem()
    }

    func skipToPreviousItem() {
        musicPlayer.skipToPreviousItem()
    }

    func byPass() {
        if isCarPlay {
            isCarPlay = false
            bypassed = true
        } else {
            isCarPlay = true
            bypassed = false
        }
    }

    // CarPlay start and stop
    func start() {
        print("isCarPlay=: true")
        isCarPlay = true
        //startObservingNowPlaying()
    }

    func stop() {
        print("isCarPlay: false")
        isCarPlay = false
        //stopObservingNowPlaying()
    }


    @objc private func playerStateDidChange() {
        debounceUpdate()
    }

    private func debounceUpdate() {
        debounceTimer?.invalidate()
        debounceTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false) { [weak self] _ in
            Task {
                try await self?.getID(songTitle: self?.musicPlayer.nowPlayingItem?.title ?? "", artistName: self?.musicPlayer.nowPlayingItem?.artist ?? "")
            }
            Task {
                self?.updateCurrentMediaItem()
            }
        }
    }

    func updateCurrentMediaItem() {
        guard let nowPlayingItem = musicPlayer.nowPlayingItem else { return }
        if nowPlayingItem.persistentID != currentMediaItemId {
            currentMediaItemId = nowPlayingItem.persistentID

            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.title = nowPlayingItem.title ?? "Unknown Title"
                self.artist = nowPlayingItem.artist ?? "Unknown Artist"
                self.totalPlaybackTime = nowPlayingItem.playbackDuration
                self.updateArtworkImage(for: nowPlayingItem)
            }
        }
    }

    private func updateArtworkImage(for mediaItem: MPMediaItem) {
        Task {
            let x = try await getID(songTitle: mediaItem.title ?? "", artistName: mediaItem.artist ?? "")
            print("img url: \(x)")
        }
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

    func getNowPlayingTitle(completion: @escaping (String) -> Void) {
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            let nowPlayingTitle = nowPlayingItem.title ?? "Unknown Title"
            completion(nowPlayingTitle)
        } else {
            completion("Not Playing")
        }
    }

    func getNowPlayingArtist(completion: @escaping (String) -> Void) {
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            let nowPlayingArtist = nowPlayingItem.artist ?? "Unknown Artist"
            completion(nowPlayingArtist)
        } else {
            completion("Not Playing")
        }
    }
    
    func disableRepeat() {
        musicPlayer.repeatMode = .none
        print("test - Repeat mode turned off.")
    }
    
    @objc private func nowPlayingItemDidChange() {
        disableRepeat()
        
        print("nowPlayingItemDidChange")
        debounceUpdate()
        
        guard let nowPlayingItem = musicPlayer.nowPlayingItem else {
            print("test - No now playing item detected.")
            return
        }

        let id = nowPlayingItem.playbackStoreID
        lastSongStoreID = id
        UserDefaults.standard.set(id, forKey: "lastSongStoreID")
        
        print("Now Playing ID: \(id)")
        print("test - Now playing item changed: \(nowPlayingItem.title ?? "(unknown)") by \(nowPlayingItem.artist ?? "(unknown)")")

        artwork = nowPlayingItem.artwork?.image(at: CGSize(width: 100, height: 100))

        recentlyPlayedIDs.append(id)
        if recentlyPlayedIDs.count > maxRecentlyPlayed {
            recentlyPlayedIDs.removeFirst()
        }

        if let index = currentQueue.firstIndex(of: id) {
            currentQueue.remove(at: index)
            print("Removed item with store ID \(id) from the queue.")
            
            let updatedQueueDescriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: currentQueue)
            musicPlayer.setQueue(with: updatedQueueDescriptor)
            print("Updated music player queue after removing item.")
        } else {
            print("Item with store ID: \(id) not found in the queue.")
        }

        if currentQueue.count <= 1 {
            print("Queue is empty or running low. Extending...")
            extendPlaybackQueue()
        }
    }
    // Check if the now playing item is the last in the tracked queue
    private func isLastItemInQueue(_ nowPlayingItem: MPMediaItem) -> Bool {
        guard let lastItemID = currentQueue.last else {
            print("test - Queue is empty, treating as last item.")
            return true
        }
        print("test - Checking if now playing ID: \(nowPlayingItem.playbackStoreID) matches last ID: \(lastItemID)")
        return nowPlayingItem.playbackStoreID == lastItemID
    }

    // Extend the playback queue by appending more songs
    private func extendPlaybackQueue() {
        Task {
            fetchSimilarTracks(artist: musicPlayer.nowPlayingItem?.artist ?? "Unknown Artist",
                               track: musicPlayer.nowPlayingItem?.title ?? "Unknown Song") { storeIDs in
                print("test422 - StoreIDs fetched: \(storeIDs)")
                print("test422 - Initial queue: \(self.currentQueue)")
                print("test422 - Recently played IDs: \(self.recentlyPlayedIDs)")

                // Check which songs are filtered out
                let uniqueNewIDs = storeIDs.filter { storeID in
                    let isInQueue = self.currentQueue.contains(storeID)
                    let isInRecentlyPlayed = self.recentlyPlayedIDs.contains(storeID)

                    if isInQueue {
                        print("test422 - Skipping \(storeID) (already in queue)")
                    }
                    if isInRecentlyPlayed {
                        print("test422 - Skipping \(storeID) (already in recently played)")
                    }

                    return !isInQueue && !isInRecentlyPlayed
                }

                print("test422 - Unique new IDs after filtering: \(uniqueNewIDs.count)")
                print("test422 - Unique new IDs: \(uniqueNewIDs)")

                if uniqueNewIDs.isEmpty {
                    print("test422 - No unique tracks found, retrying with fetchSimilarTracks2...")
                    self.fetchSimilarTracks2(artist: self.musicPlayer.nowPlayingItem?.artist ?? "Unknown Artist",
                                             track: self.musicPlayer.nowPlayingItem?.title ?? "Unknown Song") { fallbackStoreIDs in
                        self.processFetchedTracks(fallbackStoreIDs)
                    }
                } else {
                    self.processFetchedTracks(uniqueNewIDs)
                }
            }
        }
    }
    
    func fetchSimilarTracks2(artist: String, track: String, completion: @escaping ([String]) -> Void) {
        let cleanTitle = removeParentheses(from: track)
        let cleanArtist = removeParentheses(from: artist)

        let urlString = "https://ws.audioscrobbler.com/2.0/?method=tag.gettoptracks&tag=westcoast%20rap&api_key=\(apiKey)&format=json&limit=1"
        
        print("test422 - Fetching similar tracks from URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("test422 - Invalid URL")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("test422 - Error fetching similar tracks: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = data else {
                print("test422 - No data received")
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                let topTracksResponse = try decoder.decode(TopTracksResponse.self, from: data)
                let tracks = topTracksResponse.tracks.track.map { [$0.artist.name: $0.name] }

                // Fetch StoreIDs for the new tracks
                Task {
                    let storeIDs = await self.fetchStoreIDs(for: tracks)
                    completion(storeIDs)
                }
            } catch {
                print("test422 - Error decoding JSON: \(error.localizedDescription)")
                completion([])
            }
        }

        task.resume()
    }
    
    private func processFetchedTracks(_ storeIDs: [String]) {
        if storeIDs.isEmpty {
            print("test422 - Warning: No unique tracks found after retrying.")
            return
        }

        print("test422 - Successfully fetched new tracks: \(storeIDs)")

        self.currentQueue.append(contentsOf: storeIDs)

        if self.recentlyPlayedIDs.count > self.maxRecentlyPlayed {
            self.recentlyPlayedIDs.removeFirst(self.recentlyPlayedIDs.count - self.maxRecentlyPlayed)
        }

        let newQueueDescriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
        self.musicPlayer.append(newQueueDescriptor)

        print("test422 - Extended playback queue successfully.")

        self.observeQueueProgress()
    }
    
    func appendToRecentlyPlayedIDs(_ newIDs: [String]) {
        queueLock.sync {
            self.recentlyPlayedIDs.append(contentsOf: newIDs)
            if self.recentlyPlayedIDs.count > self.maxRecentlyPlayed {
                self.recentlyPlayedIDs.removeFirst(self.recentlyPlayedIDs.count - self.maxRecentlyPlayed)
            }
        }
    }
    
    private func observeQueueProgress() {
        guard !currentQueue.isEmpty else {
            print("test421 - Queue is empty, fetching new songs.")
            extendPlaybackQueue()
            return
        }

        Task {
            while musicPlayer.playbackState == .playing || musicPlayer.playbackState == .paused {
                guard let nowPlayingItemID = musicPlayer.nowPlayingItem?.playbackStoreID else {
                    print("test421 - No now-playing item found.")
                    return
                }

                //print("test421 - Currently playing: \(nowPlayingItemID)")

                if nowPlayingItemID == currentQueue.last {
                    print("test421 - Playing last item in queue, extending queue...")
                    extendPlaybackQueue()
                    return
                }

                try await Task.sleep(nanoseconds: 1_000_000_000)
            }
        }
    }
    
    func removeParentheses(from input: String) -> String {
        // Use a regular expression to match parentheses and everything inside them
        let pattern = "\\s*\\([^)]*\\)"
        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let range = NSRange(input.startIndex..<input.endIndex, in: input)
            return regex.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "")
        }
        return input
    }

    func fetchSimilarTracks(artist: String, track: String, completion: @escaping ([String]) -> Void) {
        
        let cleanTitle = removeParentheses(from: track)
        let cleanArtist = removeParentheses(from: artist)

        // Change limit dynamically to get more varied songs
        let limit = Int.random(in: 10...20) // Fetch between 10 to 20 songs each time
        let encodedArtist = cleanArtist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cleanArtist
        let encodedTitle = cleanTitle.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? cleanTitle

        let urlString = "https://ws.audioscrobbler.com/2.0/?method=track.getsimilar&artist=\(encodedArtist)&track=\(encodedTitle)&api_key=\(apiKey)&format=json&limit=\(limit)"
        
        print("test422 - Fetching similar tracks from URL: \(urlString)")

        guard let url = URL(string: urlString) else {
            print("test422 - Invalid URL")
            completion([])
            return
        }

        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                print("test422 - Error fetching similar tracks: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = data else {
                print("test422 - No data received")
                completion([])
                return
            }

            do {
                let decoder = JSONDecoder()
                let similarTracksResponse = try decoder.decode(SimilarTracksResponse.self, from: data)
                let tracks = similarTracksResponse.similartracks.track.map { [$0.artist.name: $0.name] }

                // Fetch StoreIDs for the new tracks
                Task {
                    let storeIDs = await self.fetchStoreIDs(for: tracks)
                    completion(storeIDs)
                }
            } catch {
                print("test422 - Error decoding JSON: \(error.localizedDescription)")
                completion([])
            }
        }

        task.resume()
    }

    // Helper function to fetch storeIDs for a list of tracks
    func fetchStoreIDs(for tracks: [[String: String]]) async -> [String] {
        var storeIDs: [String] = []
        
        for track in tracks {
            if let artist = track.keys.first, let song = track[artist] {
                let searchRequest = MusicCatalogSearchRequest(term: "\(artist) \(song)", types: [Song.self])
                do {
                    let response = try await searchRequest.response()
                    let songs = response.songs
                    
                    // Prefer explicit tracks but fall back to the first available song
                    if let explicitSong = songs.first(where: { $0.contentRating == .explicit }) {
                        storeIDs.append(explicitSong.id.rawValue)
                    } else if let cleanSong = songs.first {
                        storeIDs.append(cleanSong.id.rawValue)
                    } else {
                        // If no song is found, add a placeholder or skip
                        print("No storeID found for \(song) by \(artist)")
                    }
                } catch {
                    print("Error fetching storeID for \(song) by \(artist): \(error.localizedDescription)")
                }
            }
        }
        
        return storeIDs
    }

    func setInitialQueue(with storeIDs: [String]) {
        currentQueue = storeIDs
        let queueDescriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: storeIDs)
        musicPlayer.setQueue(with: queueDescriptor)
        print("test - Initial queue set with: \(storeIDs)")
        observeQueueProgress() // Start monitoring the queue
    }

    
}

// Define a structure to hold track information
struct Track: Decodable {
    let name: String
    let artist: Artist
}

struct Artist: Decodable {
    let name: String
}

struct SimilarTracksResponse: Decodable {
    let similartracks: Tracks
}

struct Tracks: Decodable {
    let track: [Track]
}

struct TopTracksResponse: Decodable {
    let tracks: TrackContainer
}

struct TrackContainer: Decodable {
    let track: [Track]
}
