import SwiftUI
import MusicKit
import MediaPlayer

@main
struct MusicKitPlaylistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var isAuthorized = false
    @State private var playlistStatus = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("MusicKit Playlist Creator")
                .font(.largeTitle)
                .padding()

            Button("Request Permissions") {
                Task {
                    await requestPermissions()
                }
            }

            Button("Create Playlist") {
                Task {
                    await createMyPlaylist()
                }
            }
            .disabled(!isAuthorized)

            Text(playlistStatus)
                .multilineTextAlignment(.center)
                .padding()
        }
        .padding()
    }

    // Step 1: Request Permissions
    func requestPermissions() async {
        let mediaStatus = MPMediaLibrary.authorizationStatus()
        if mediaStatus != .authorized {
            MPMediaLibrary.requestAuthorization { status in
                if status == .authorized {
                    print("Media library access granted.")
                } else {
                    print("Media library access denied.")
                }
            }
        }

        do {
            let musicStatus = await MusicAuthorization.request()
            switch musicStatus {
            case .authorized:
                isAuthorized = true
                playlistStatus = "Music authorization granted. You can now create a playlist."
            case .denied, .restricted:
                isAuthorized = false
                playlistStatus = "Music authorization denied. Unable to create a playlist."
            default:
                isAuthorized = false
                playlistStatus = "Music authorization not determined."
            }
        } catch {
            playlistStatus = "Error requesting permissions: \(error.localizedDescription)"
        }
    }

    // Step 2: Create Playlist
    func createMyPlaylist() async {
        let query = "Your favorite artist" // Replace with your search term
        let playlistName = "My Awesome Playlist"
        let playlistDescription = "A playlist of my favorite tracks."

        // Search for songs
        let tracks = await searchForTracks(query: query)
        let trackIDs = tracks.map { $0.id }

        // Create the playlist
        if !trackIDs.isEmpty {
            do {
                let playlist = MusicLibraryPlaylistCreationRequest(name: playlistName, description: playlistDescription, items: trackIDs)
                try await MusicLibrary.shared.createPlaylist(playlist)
                playlistStatus = "Playlist '\(playlistName)' created successfully!"
            } catch {
                playlistStatus = "Failed to create playlist: \(error.localizedDescription)"
            }
        } else {
            playlistStatus = "No tracks found to add to the playlist."
        }
    }

    // Step 3: Search for Tracks
    func searchForTracks(query: String) async -> [Song] {
        do {
            let searchRequest = MusicCatalogSearchRequest(term: query, types: [Song.self])
            let response = try await searchRequest.response()
            return response.songs
        } catch {
            playlistStatus = "Error searching for songs: \(error.localizedDescription)"
            return []
        }
    }
}