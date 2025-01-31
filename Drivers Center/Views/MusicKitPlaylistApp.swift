/*

import SwiftUI
import MusicKit

@main
struct MusicKitPlaylistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@MainActor
struct ContentView: View {
    @State private var search_q: String = ""
    @State private var isLoading = false
    @State private var message: String? = nil
    @State var songArray: [String] = []
    @State var plSongs: [Song] = []
    
    var body: some View {
        VStack(spacing: 20) {
            
            TextField("Add or Remove song (title artist)", text: $search_q)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if !search_q.isEmpty {
                    Task {
                        try await searchSong(q: search_q)
                    }
                }
            }) {
                Text("Add Song")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                if !search_q.isEmpty {
                    Task {
                        try await searchSongDelete(q: search_q)
                    }
                }
            }) {
                Text("Remove Song")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
            
            if isLoading {
                ProgressView("Processing...")
            }

        }
        .padding()
        .onAppear {
            Task {
               await getPlaylistSongs()
            }
        }
    }
    
    
    
    func addSongToPlaylist() async {
        message = nil
        isLoading = true
        do {
            try await requestAuthorization()
            let playlists = try await fetchUserPlaylists()
            if let _ = playlists.first(where: { $0.name == "My Awesome Playlist" }) {
            } else {
                let _ = try await createMyPlaylist()
            }
        } catch {
            if let musicError = error as? MusicError {
                message = musicError.localizedDescription
            } else {
                message = error.localizedDescription
            }
            print("Error: \(error.localizedDescription)")
        }
        isLoading = false
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

    func searchSong(q: String) async throws -> MusicKit.Song {
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
        songArray.append(songDetails)
        plSongs.append(song)
        search_q = ""

        Task {
            try await updatePlaylist()
        }
        return song
    }*/
    
    /*func searchSongDelete(q: String) async throws -> MusicKit.Song {
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
        songArray = songArray.filter { !$0.contains(song.title) }
        print("songArray: \(songArray)")
        
        plSongs = plSongs.filter {
            let title = $0.title
            return !title.contains(song.title)
        }
        search_q = ""

        Task {
            try await updatePlaylist()
        }
        return song
    }*/
    
   /* func isSongInLibraryPlaylist(title: String) -> Bool {
        if let found = songArray.first(where: { $0.contains(title) }) {
            return true
        } else {
            return false
        }
    }
    
    func createMyPlaylist() async throws -> Playlist {
        let playlistName = "My Awesome Playlist"
        let playlistDescription = "A playlist of my favorite tracks."
        let authorDisplayName = "Steve Spencer"
        
        do {
            let playlist = try await MusicLibrary.shared.createPlaylist(
                name: playlistName,
                description: playlistDescription,
                authorDisplayName: authorDisplayName
            )
            message = "Playlist '\(playlist.name)' created successfully!"
            return playlist
        } catch {
            throw MusicError.playlistCreationFailed(error.localizedDescription)
        }
    }
    

    
    func updatePlaylist() async throws {
        guard !songArray.isEmpty else {
            Task {
                try await createMyPlaylist()
            }
            return
        }
        
        var request = MusicLibraryRequest<Playlist>()
        request.filter(matching: \.name, equalTo: "My Awesome Playlist")
        let response = try await request.response()

        guard let playlist = response.items.first else {
            print("Playlist with name 'My Awesome Playlist' not found.")
            return
        }
        
        try await MusicLibrary.shared.edit(
            playlist,
            name: nil,
            description: nil,
            authorDisplayName: nil,
            items: plSongs
        )
        message = "Successfully added \(plSongs.count) songs to '\(playlist.name)'."
        print("Successfully added \(plSongs.count) songs to '\(playlist.id)'.")
    }
    
    @MainActor
    func getPlaylistSongs() async {
        do {
            var request = MusicLibraryRequest<Playlist>()
            request.filter(matching: \.name, equalTo: "My Awesome Playlist")
            let response = try await request.response()

            guard let playlist = response.items.first else {
                print("Playlist with name 'My Awesome Playlist' not found.")
                return
            }

            print("Curator Name: \(playlist.curatorName ?? "Unknown Curator")")
            print("Playlist Details: \(playlist)")

            let detailedPlaylist = try await playlist.with([.tracks])
            let tracks = detailedPlaylist.tracks ?? []

            print("Processing songs in playlist '\(playlist.name)'...")

            for track in tracks {
                switch track {
                case .song(let song):
                    let songDetails = "\(song.title) \(song.artistName)"
                    songArray.append(songDetails)
                    plSongs.append(song)
                default:
                    print("Unsupported track type in playlist.")
                }
            }

            print("Songs added to array: \(songArray)")
        } catch {
            print("An error occurred while refreshing the playlist: \(error)")
        }
    }
    
}

/// Custom errors for better error handling
enum MusicError: LocalizedError {
    case notAuthorized
    case playlistNotFound
    case songNotFound
    case playlistCreationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .notAuthorized:
            return "Not authorized to access Apple Music. Please grant permission in Settings."
        case .playlistNotFound:
            return "Playlist 'My Awesome Playlist' not found in your library."
        case .songNotFound:
            return "Song not found in the Apple Music catalog."
        case .playlistCreationFailed(let reason):
            return "Failed to create playlist: \(reason)"
        }
    }
}

    */

