import SwiftUI

struct LibraryMenuSheet: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: MediaItemViewModel
    @Binding var showSheet: Bool
    
    var body: some View {
        NavigationStack { // ✅ Enables nested navigation
            VStack(spacing: 0) {
                Text("Library")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top, 25) // Increased top padding
                    .padding(.bottom, 25)
                
                // Library Options
                VStack(spacing: 0) {
                    NavigationLink(destination: PlaylistView(viewModel: viewModel, showSheet: $viewModel.showPlaylist)) {
                        LibraryMenuItem(icon: "playlist", text: "Playlists")
                    }
                    Divider().background(Color.gray)

                    NavigationLink(destination: AlbumsView(viewModel: viewModel, showSheet: $viewModel.showAlbums)) {
                        LibraryMenuItem(icon: "albums", text: "Albums")
                    }
                    Divider().background(Color.gray)

                    NavigationLink(destination: SongsView(viewModel: viewModel, showSheet: $viewModel.showSongs)) {
                        LibraryMenuItem(icon: "songs", text: "Songs")
                    }
                    Divider().background(Color.gray)

                    NavigationLink(destination: MusicSearch(viewModel: viewModel, isPresented: $viewModel.showSearchSheet, onSelectSong: { song in
                        viewModel.selectedSong = song
                        Task {
                            try await viewModel.playSelectedSong(song) // Start playback of selected song
                        }
                    })) {
                        LibraryMenuItem(icon: "search", text: "Search")
                    }
                }
                .padding(.horizontal)
                .onAppear {
                    viewModel.fetchSongs()
                    viewModel.fetchAlbums()
                }

                Spacer()

                Button("Dismiss") {
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
        }
    }
}

// 🔹 Updated LibraryMenuItem with direct NavigationLink
struct LibraryMenuItem: View {
    var icon: String // Image name from Assets.xcassets
    var text: String

    var body: some View {
        HStack {
            Image(icon)
                .resizable()
                .frame(width: 70, height: 70)
                .scaledToFit()
                .cornerRadius(10)
            
            Text(text)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.leading, 12)
            
            Spacer()

            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color.gray.opacity(0.2))
    }
}
