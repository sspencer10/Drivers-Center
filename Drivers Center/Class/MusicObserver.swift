import SwiftUI
import MediaPlayer
import CarPlay

class MediaItemViewModel: ObservableObject {
    @Published var artworkImage: UIImage?
    @Published var title: String = "Unknown Title"
    @Published var artist: String = "Unknown Artist"
    @Published var mediaItems: [MPMediaItem] = [] // Store media items as an array
    @Published var playlists: [MPMediaPlaylist] = []

    var musicPlayer: MPMusicPlayerController?

    init() {
        self.musicPlayer = MPMusicPlayerController.systemMusicPlayer
        // Observe changes to the nowPlayingItem
        NotificationCenter.default.addObserver(self, selector: #selector(nowPlayingItemDidChange), name: .MPMusicPlayerControllerNowPlayingItemDidChange, object: musicPlayer)
        musicPlayer?.beginGeneratingPlaybackNotifications()
        updateCurrentMediaItem()
        fetchMediaItems { items in
            self.mediaItems = items
        }
    }

    // Called when the now playing item changes
    @objc private func nowPlayingItemDidChange() {
        updateCurrentMediaItem()
    }

    // Fetch playlists from the media library
    func fetchPlaylists() -> [MPMediaPlaylist] {
        let playlistsQuery = MPMediaQuery.playlists()
        return playlistsQuery.collections as? [MPMediaPlaylist] ?? []
    }

    // Play a playlist, starting at a specific song if provided
    func playPlaylist(_ playlist: MPMediaPlaylist, startingAt song: MPMediaItem? = nil) {
        musicPlayer?.setQueue(with: playlist)
        
        if let song = song {
            musicPlayer?.nowPlayingItem = song
        }

        musicPlayer?.play()
    }

    // Update the now playing media item's metadata
    func updateCurrentMediaItem(){
        if let mediaItem = musicPlayer?.nowPlayingItem {
            self.title = mediaItem.title ?? "Unknown Title"
            self.artist = mediaItem.artist ?? "Unknown Artist"

            // Update the artwork if available
            if let artwork = mediaItem.artwork {
                let imageSize = CGSize(width: 100, height: 100)
                self.artworkImage = artwork.image(at: imageSize)
            } else {
                self.artworkImage = nil
            }
        } else {
            // Reset to default values if no item is playing
            self.title = "Unknown Title"
            self.artist = "Unknown Artist"
            self.artworkImage = nil
        }
    }

    // Fetch media items (e.g., songs) from the media library
    func fetchMediaItems(completion: @escaping ([MPMediaItem]) -> Void) {
        let query = MPMediaQuery.songs() // Fetch all songs
        if let items = query.items {
            completion(items)
            self.mediaItems = items // Store fetched media items
        } else {
            print("No media items found.")
            completion([]) // Return an empty array if no media items are found
        }
    }

    deinit {
        // Stop observing changes when the ViewModel is deallocated
        musicPlayer?.endGeneratingPlaybackNotifications()
        NotificationCenter.default.removeObserver(self)
    }
}
