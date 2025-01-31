import SwiftUI
import MusicKit

struct AlbumArtworkView: View {
    let albumId: String  // Use the album identifier directly
    @State private var artworkImage: UIImage?

    var body: some View {
        if let image = artworkImage {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipped()
        } else {
            // Placeholder while loading
            ProgressView()
                .onAppear {
                    Task {
                        await fetchAlbumArtwork()
                    }
                }
        }
    }

    private func fetchAlbumArtwork() async {
        do {
            // Create a request for the Album
            let request = MusicCatalogResourceRequest<Album>(matching: \.id, equalTo: albumId)
            let response = try await request.response()

            // Check if there are items in the response
            if let albumItem = response.items.first {
                // Load the artwork
                if let artwork = albumItem.artwork {
                    let image = try await artwork.loadImage()
                    DispatchQueue.main.async {
                        self.artworkImage = image
                    }
                } else {
                    print("No artwork found for this album")
                }
            } else {
                print("Album not found")
            }
        } catch {
            print("Error fetching album artwork: \(error)")
        }
    }
}