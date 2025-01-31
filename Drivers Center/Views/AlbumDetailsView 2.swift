import SwiftUI
import MusicKit
import MediaPlayer


struct AlbumDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var artworkImage: UIImage?
    @State private var tracks: [MusicKit.Song] = []
    @State private var isLoading: Bool = true
    @State private var isTracksLoading: Bool = true
    @State var artworkURL: URL?
    @State var albumTitle: String?
    @State var albumArtist: String?
    @ObservedObject var viewModel: MediaItemViewModel
    @State var releaseDate: Date?
    @State private var albumTracks: [MPMediaItem] = []
    @State private var albumSongs: [Song] = []

    var body: some View {
        NavigationView {
            ScrollView {
                VStack {
                    if isLoading {
                        ProgressView()
                            .onAppear {
                                viewModel.startObservingNowPlaying()
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                    isLoading = false
                                }
                            }
                    } else {
                        // Album Artwork
                        if let artworkImage = viewModel.newArt2 {
                            Image(uiImage: artworkImage)
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                                .frame(width: 300, height: 300) // Set fixed size
                                .padding(.horizontal, 20)
                        } else if let artworkURL = viewModel.newArt {
                            AsyncImage(url: artworkURL) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFit()
                                        .cornerRadius(8)
                                        .frame(width: 300, height: 300) // Set fixed size
                                        .padding(.horizontal, 20)
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundColor(.gray)
                                        .frame(width: 300, height: 300) // Set fixed size
                                        .padding(.horizontal, 20)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        }

                        // Album Details
                        VStack(spacing: 8) {
                            Text(viewModel.musicPlayer.nowPlayingItem?.albumTitle ?? "Unknown Title")
                                .font(.headline)
                                .lineLimit(2)
                                .multilineTextAlignment(.center)

                            Text("by \(viewModel.musicPlayer.nowPlayingItem?.albumArtist ?? "Unknown Artist")")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            HStack {
                                if let releaseDate = getAlbumReleaseDate(from: viewModel.musicPlayer) {
                                    Text("Released: \(formatReleaseDate(releaseDate))")
                                        .font(.footnote)
                                        .foregroundColor(.secondary)
                                }
                                // Add Album to Library Button
                              Button(action: {
                                  Task {
                                      do {
                                          try await viewModel.addAlbumToLibrary()
                                          print("Album successfully added to library.")
                                      } catch {
                                          print("Error adding album to library: \(error.localizedDescription)")
                                      }
                                  }
                              }) {
                                  HStack {
                                      Image(systemName: "plus.circle")
                                          .resizable()
                                          .frame(width: 20, height: 20)
                                      Text("Add Album")
                                          .font(.subheadline)
                                  }
                                  .padding()
                              }
                              .buttonStyle(BorderlessButtonStyle())
                          }
                    }
                        .padding(.horizontal)
                        .padding(.top, 16)

                        // Tracks List
                        VStack {
                            if isTracksLoading {
                                ProgressView("Loading Album Tracks...")
                                    .onAppear {
                                        Task {
                                            albumSongs = try await fetchAlbumTracksFromSong(
                                                songTitle: viewModel.title,
                                                artistName: viewModel.artist
                                                //songTitle: "Gettin' It (feat. Parliament-Funkadelic)",
                                                //artistName: "Too $hort"
                                            )
                                        }
                                    }
                            } else if albumTracks.isEmpty && albumSongs.isEmpty {
                                Text("No tracks found for the current album.")
                                    .foregroundColor(.secondary)
                                    .padding()
                                    .onAppear {
                                        isTracksLoading = false
                                    }
                            } else {
                                if (!albumTracks.isEmpty) {
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
                                                dismiss()
                                            }) {
                                                Image(systemName: "play.circle")
                                                    .resizable()
                                                    .frame(width: 30, height: 30)
                                                    .foregroundColor(.blue)
                                            }
                                        }
                                        .padding(.vertical, 4)
                                    }
                                } else {
                                    
                                    ForEach(albumSongs, id: \.id) { track in
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text(track.title)
                                                    .font(.headline)
                                                Text(track.artistName) // Use artistName for Song
                                                    .font(.subheadline)
                                                    .foregroundColor(.secondary)
                                            }
                                            Spacer()
                                            Button(action: {
                                                Task {
                                                    do {
                                                        try await viewModel.playSelectedSong(track) // Directly play the Song
                                                    } catch {
                                                        print("Error playing track: \(error.localizedDescription)")
                                                    }
                                                }
                                                dismiss()
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
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Album Details")
            .navigationBarTitleDisplayMode(.inline)
        }
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
