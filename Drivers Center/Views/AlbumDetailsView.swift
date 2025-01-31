import SwiftUI
import MusicKit
import MediaPlayer

struct AlbumDetailsView: View {
    @State private var artworkImage: UIImage?
    @State private var tracks: [MusicKit.Song] = []
    @State private var isLoading: Bool = true

    var albumTitle: String
    var albumArtist: String
    var releaseDate: Date?
    var artworkURL: URL?
    var playTrack: (MusicKit.Song) -> Void

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .onAppear {
                        // Simulate a loading delay if fetching is asynchronous
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isLoading = false
                        }
                    }
            } else {
                // Album Artwork
                if let artworkImage = artworkImage {
                    Image(uiImage: artworkImage)
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8)
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, 20)
                } else if let artworkURL = artworkURL {
                    AsyncImage(url: artworkURL) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .cornerRadius(8)
                                .frame(maxWidth: .infinity)
                                .padding(.horizontal, 20)
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(.gray)
                                .scaledToFit()
                                .padding(.horizontal, 20)
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    ProgressView()
                }

                // Album Details
                VStack(spacing: 8) {
                    Text(albumTitle)
                        .font(.headline)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)

                    Text("by \(albumArtist)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    if let releaseDate = releaseDate {
                        Text("Released: \(formatReleaseDate(releaseDate))")
                            .font(.footnote)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 16)

                // Tracks List
                if !tracks.isEmpty {
                    List(tracks, id: \.id) { track in
                        HStack {
                            VStack(alignment: .leading) {
                                Text(track.title)
                                    .font(.headline)
                                    .lineLimit(1)
                                Text(track.artistName)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                    .lineLimit(1)
                            }
                            Spacer()
                            Button(action: {
                                playTrack(track)
                            }) {
                                Image(systemName: "play.circle")
                                    .resizable()
                                    .frame(width: 30, height: 30)
                                    .foregroundColor(.blue)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    .listStyle(PlainListStyle())
                } else {
                    Text("No tracks available")
                        .foregroundColor(.secondary)
                        .padding()
                }
            }
        }
        .padding()
        .navigationTitle("Album Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    // Helper to format release date
    private func formatReleaseDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}