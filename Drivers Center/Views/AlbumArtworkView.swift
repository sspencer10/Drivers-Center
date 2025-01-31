import SwiftUI
import MusicKit
import MediaPlayer

struct AlbumArtworkView: View {
    @State private var artworkImage: UIImage?
    @ObservedObject var viewModel: MediaItemViewModel
    @State private var isLoading: Bool = true
    @State private var showAsyncImage: Bool = true

    var body: some View {
        if isLoading {
            ProgressView()
                .onAppear {
                    viewModel.startObservingNowPlaying()
                    print("test3 - Loading started")
                    Task {
                        try await viewModel.getID(songTitle: viewModel.title, artistName: viewModel.artist) // Fetch the artwork URL or image
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isLoading = false
                        showAsyncImage = viewModel.newArt2 == nil // Fallback to AsyncImage if UIImage is not available
                    }
                }
            /*
        } else if !showAsyncImage, let newArt2 = viewModel.newArt2 {
            // Display UIImage if available
            Image(uiImage: newArt2)
                .resizable()
                .scaledToFit()
                .cornerRadius(8)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .onAppear {
                    print("test3 - uiimage")
                }
            */
        } else if let newArt = viewModel.newArt {
            // Fallback to AsyncImage
            AsyncImage(url: newArt) { phase in
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
                        .padding(.leading, 20)
                @unknown default:
                    EmptyView()
                }
            }
            .onAppear {
                print("test33 - Fallback to AsyncImage \(newArt)")
            }
            .frame(width: 400, height: 400) // Adjust size for your UI
        } else {
            // Handle case where neither UIImage nor URL is available
            ProgressView()
                .onAppear {
                    print("test333 - No artwork found")
                }
        }
    }
}
