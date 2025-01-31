import SwiftUI

struct CustomSheetMenu: View {
    @State private var showSheet = false

    var body: some View {
        VStack {
            Button(action: {
                showSheet.toggle()
            }) {
                Text("Show Menu")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .sheet(isPresented: $showSheet) {
            MenuSheet(
                onViewPlaylists: {
                    print("View Playlists tapped")
                    // Add your custom action here
                },
                onViewAlbums: {
                    print("View Albums tapped")
                    // Add your custom action here
                },
                onViewSongs: {
                    print("View Songs tapped")
                    // Add your custom action here
                }
            )
        }
    }
}

struct MenuSheet: View {
    let onViewPlaylists: () -> Void
    let onViewAlbums: () -> Void
    let onViewSongs: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Menu")
                .font(.headline)
                .padding()

            Divider()

            Button(action: {
                onViewPlaylists()
                dismiss()
            }) {
                Text("View Playlists")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }

            Button(action: {
                onViewAlbums()
                dismiss()
            }) {
                Text("View Albums")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }

            Button(action: {
                onViewSongs()
                dismiss()
            }) {
                Text("View Songs")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }

            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .cornerRadius(16)
    }
}