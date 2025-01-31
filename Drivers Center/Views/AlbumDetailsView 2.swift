//
//  AlbumDetailsView 2.swift
//  Drivers Center
//
//  Created by Steven Spencer on 1/29/25.
//


import SwiftUI
import MusicKit
import MediaPlayer


struct AlbumDetailsView2: View {
    @Environment(\.dismiss) private var dismiss
    @State private var artworkImage: UIImage?
    @State private var tracks: [MusicKit.Song] = []
    @State private var isLoading: Bool = true
    @State private var isTracksLoading: Bool = true
    @State var artworkURL: URL?
    @State var albumTitle: String?
    @State var albumArtist: String?
    @ObservedObject var viewModel = MediaItemViewModel.shared
    @State var releaseDate: Date?
    @State private var albumTracks: [MPMediaItem] = []
    @State private var albumSongs: [Song] = []
    @State var albumID: MPMediaEntityPersistentID
    @State var album: MPMediaItemCollection?

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if isLoading {
                        ProgressView()
                            .onAppear {
                                 album = getAlbumByPersistentID(persistentID: albumID)
                            }
                    } else {
                        if let album = getAlbumByPersistentID(persistentID: albumID),
                           let artwork = album.representativeItem?.artwork {
                            if let image = artwork.image(at: CGSize(width: 300, height: 300)) {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                                    .frame(width: 300, height: 300) // Set fixed size
                                    .padding(.horizontal, 20)
                            } else {
                                Image(uiImage: UIImage(named: "music")!)
                                    .resizable()
                                    .scaledToFit()
                                    .cornerRadius(8)
                                    .frame(width: 300, height: 300) // Set fixed size
                                    .padding(.horizontal, 20)
                            }
                            // Album Details
                            VStack(spacing: 8) {
                                Text(album.representativeItem?.albumTitle ?? "Unknown Title")
                                    .font(.headline)
                                    .lineLimit(2)
                                    .multilineTextAlignment(.center)
                                
                                Text("by \(album.representativeItem?.artist ?? "Unknown Artist")")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                HStack {
                                    
                                    Text("Released: \(formatReleaseDate(album.representativeItem?.releaseDate ?? .now))")
                                            .font(.footnote)
                                            .foregroundColor(.secondary)
                                }
                                .padding(.horizontal)
                                .padding(.top, 4)
                                
                                VStack {
                                    if isTracksLoading {
                                        ProgressView("Loading Album Tracks...")
                                            .onAppear {
                                                Task {
                                                    albumTracks = album.items
                                                    isTracksLoading = false
                                                }
                                            }
                                    } else if albumTracks.isEmpty {
                                        Text("No tracks found for the current album.")
                                            .foregroundColor(.secondary)
                                            .padding()
                                    } else {
                                        ForEach(albumTracks.indices, id: \.self) { index in
                                            let track = albumTracks[index]
                                            HStack {
                                                VStack(alignment: .leading) {
                                                    Text(track.title ?? "Unknown Title")
                                                        .font(.headline)
                                                    Text(track.artist ?? "Unknown Artist")
                                                        .font(.subheadline)
                                                        .foregroundColor(.secondary)
                                                }
                                                Spacer()
                                                Button(action: {
                                                    Task {
                                                        try await viewModel.playSelectedSong(mapMPMediaItemToSong(track)!)
                                                    }
                                                    DispatchQueue.main.async {
                                                        dismiss()
                                                        viewModel.showAlbums = false
                                                        viewModel.showMenu = false
                                                    }
                                                    DispatchQueue.main.async {
                                                        dismiss() // Dismiss the first sheet
                                                        dismiss() // Try dismissing again (if another sheet is open)
                                                        viewModel.showAlbums = false
                                                        viewModel.showMenu = false
                                                    }
                                                }) {
                                                    Image(systemName: "play.circle")
                                                        .resizable()
                                                        .frame(width: 30, height: 30)
                                                        .foregroundColor(.blue)
                                                }
                                            }
                                            .padding(.vertical, 4)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }


                            
                            .padding()
                        }
                        
                    }
                }
            }
            .navigationTitle("Album Details")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func getAlbumByPersistentID(persistentID: UInt64) -> MPMediaItemCollection? {
        print("id: \(persistentID)")
        let query = MPMediaQuery.albums()
        
        let predicate = MPMediaPropertyPredicate(
            value: NSNumber(value: persistentID),
            forProperty: MPMediaItemPropertyAlbumPersistentID,
            comparisonType: .equalTo
        )
        
        query.addFilterPredicate(predicate)
        
        guard let albums = query.collections, !albums.isEmpty else {
            print("Album not found")
            return nil
        }
        
        // Find the album with the most tracks
        let albumWithMostTracks = albums.max(by: { $0.items.count < $1.items.count })
        
        DispatchQueue.main.async {
            isLoading = false
        }
        
        return albumWithMostTracks
    }
    
    func playLocalTrack(_ track: MPMediaItem) {
        let persistentIDString = String(track.persistentID) // Convert to String
        viewModel.musicPlayer.setQueue(with: [persistentIDString]) // Use String representation
        viewModel.musicPlayer.nowPlayingItem = track
        viewModel.musicPlayer.play()
        viewModel.updateCurrentMediaItem()
    }

    func mapMPMediaItemToSong(_ item: MPMediaItem) async throws -> MusicKit.Song? {
        guard let title = item.title, let artist = item.artist else {
            return nil
        }

        var searchRequest = MusicCatalogSearchRequest(term: "\(title) \(artist)", types: [MusicKit.Song.self])
        searchRequest.limit = 1
        let searchResponse = try await searchRequest.response()
        return searchResponse.songs.first
    }

    func formatReleaseDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }

    func getAlbumReleaseDate(from musicPlayer: MPMusicPlayerController) -> Date? {
        guard let nowPlayingItem = musicPlayer.nowPlayingItem else { return nil }
        return nowPlayingItem.value(forProperty: MPMediaItemPropertyReleaseDate) as? Date
    }



    func playTrack(_ track: MPMediaItem) {
        let persistentIDString = String(track.persistentID)
        viewModel.musicPlayer.setQueue(with: [persistentIDString])
        viewModel.musicPlayer.nowPlayingItem = track
        viewModel.musicPlayer.play()
    
        viewModel.updateCurrentMediaItem()
    }
    
    /// Searches Apple Music for the given song, finds its album by name, then fetches all tracks on that album.
    /// This uses the iOS 16 MusicKit APIs available in Xcode 16.x.
    func fetchAlbumTracksFromSong(songTitle: String,
                                  artistName: String) async throws -> [Song] {
        
        // --- STEP 1: Search for the Song by (songTitle, artistName) ---
        var songRequest = MusicCatalogSearchRequest(
            term: "\(songTitle) \(artistName)",
            types: [Song.self]
        )
        songRequest.limit = 25
        let songResponse = try await songRequest.response()
        
        // Naive match for the first Song that includes both strings
        guard let matchedSong = songResponse.songs.first(where: {
            $0.title.localizedCaseInsensitiveContains(songTitle)
            && $0.artistName.localizedCaseInsensitiveContains(artistName)
        }) else {
            print("No matching song found in Apple Music catalog.")
            return []
        }
        
        // iOS 16's `Song` provides `albumTitle` and `artistName` as optional Strings.
        // Replace nil with "" to avoid optional-binding errors.
        let albumTitle = matchedSong.albumTitle ?? ""
        let albumArtist = matchedSong.artistName  // also a String? but we used it above, safe to keep going
        
        // If albumTitle or albumArtist is empty, we can’t search meaningfully
        guard !albumTitle.isEmpty, !albumArtist.isEmpty else {
            print("Song has no valid albumTitle or artistName.")
            return []
        }
        
        // --- STEP 2: Search for the Album by (albumTitle, albumArtist) ---
        var albumRequest = MusicCatalogSearchRequest(
            term: "\(albumTitle) \(albumArtist)",
            types: [Album.self]
        )
        albumRequest.limit = 25
        let albumResponse = try await albumRequest.response()
        
        // Naive match for the album
        guard let matchedAlbum = albumResponse.albums.first(where: {
            $0.title.localizedCaseInsensitiveContains(albumTitle)
            && $0.artistName.localizedCaseInsensitiveContains(albumArtist)
        }) else {
            print("No matching album found in Apple Music catalog.")
            return []
        }
        
        // --- STEP 3: Load the album’s .tracks relationship ---
        // In iOS 16, this is `MusicItemCollection<Track>?`.
        let albumWithTracks = try await matchedAlbum.with([.tracks])
        guard let trackCollection = albumWithTracks.tracks else {
            print("No tracks relationship on the album.")
            return []
        }
        
        // Each Track is an enum: .song(Song) or .musicVideo(MusicVideo).
        let songs = trackCollection.compactMap { track -> Song? in
            if case let .song(s) = track {
                return s
            }
            return nil
        }
        isTracksLoading = false
        return songs
    }
}
