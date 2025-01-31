import SwiftUI
import MusicKit

struct AddToPlaylistView: View {
    @State private var authorizationStatus = MusicAuthorization.currentStatus
    
    // Example IDs
    //  - In a real app, you’d query the user’s library for the playlist ID.
    //  - For the song, you might get its MusicItemID from a catalog search or metadata.
    private let playlistID = MusicItemID("pl.u-EXAMPLE123")  // The user’s playlist ID
    private let songID     = MusicItemID("i.EXAMPLE_SONGID") // The catalog/library song ID

    var body: some View {
        VStack {
            Text("Add Song to Playlist")
            Button("Add to Playlist") {
                Task {
                    await addSongToPlaylist()
                }
            }
        }
        .onAppear {
            Task {
                authorizationStatus = await MusicAuthorization.request()
            }
        }
    }

    func addSongToPlaylist() async {
        guard authorizationStatus == .authorized else {
            print("Not authorized to access Apple Music.")
            return
        }

        do {
            // We’re adding a single song here; you can pass an array of MusicItemIDs
            try await MusicLibrary.shared.add([songID], to: playlistID)
            print("Successfully added song to playlist!")
        } catch {
            print("Failed to add song to playlist: \(error)")
        }
    }
}