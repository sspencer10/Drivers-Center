import MediaPlayer
import MusicKit

class AutoplayManager: ObservableObject {
    private var musicPlayer = MPMusicPlayerController.systemMusicPlayer

    init() {
        startObservingNowPlaying()
    }

    // Start observing now playing item changes
    private func startObservingNowPlaying() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(nowPlayingItemDidChange),
            name: .MPMusicPlayerControllerNowPlayingItemDidChange,
            object: musicPlayer
        )
        musicPlayer.beginGeneratingPlaybackNotifications()
    }

    // Handle changes to the now playing item
    @objc private func nowPlayingItemDidChange() {
        guard let nowPlayingItem = musicPlayer.nowPlayingItem else { return }
        if isLastItemInQueue(nowPlayingItem) {
            extendPlaybackQueue()
        }
    }

    // Check if the now playing item is the last in the queue
    private func isLastItemInQueue(_ nowPlayingItem: MPMediaItem) -> Bool {
        guard let queue = musicPlayer.nowPlayingQueueDescriptor as? MPMusicPlayerStoreQueueDescriptor else { return false }
        let lastStoreID = queue.storeIDs.last
        return nowPlayingItem.persistentID == lastStoreID
    }

    // Extend the playback queue by appending more songs
    private func extendPlaybackQueue() {
        Task {
            do {
                // Fetch additional songs (e.g., related songs or a curated list)
                let additionalSongs = try await fetchRelatedSongs()
                let additionalStoreIDs = additionalSongs.map { $0.id.rawValue }

                // Append the songs to the current queue
                let newQueueDescriptor = MPMusicPlayerStoreQueueDescriptor(storeIDs: additionalStoreIDs)
                musicPlayer.append(newQueueDescriptor)
                print("Extended playback queue with additional songs.")
            } catch {
                print("Failed to extend playback queue: \(error.localizedDescription)")
            }
        }
    }

    // Fetch related songs (customize this logic as needed)
    private func fetchRelatedSongs() async throws -> [MusicKit.Song] {
        let searchRequest = MusicCatalogSearchRequest(
            term: "Related Songs", // Replace with actual logic
            types: [MusicKit.Song.self]
        )
        searchRequest.limit = 5
        let searchResponse = try await searchRequest.response()
        return Array(searchResponse.songs)
    }

    // Stop observing when the instance is deallocated
    deinit {
        NotificationCenter.default.removeObserver(self)
        musicPlayer.endGeneratingPlaybackNotifications()
    }
}