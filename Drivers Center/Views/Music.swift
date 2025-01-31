import SwiftUI
import MediaPlayer
import AVKit
import MusicKit

struct MusicView: View {
    @ObservedObject var viewModel: MediaItemViewModel
    @State private var playerVolume: Float = 0.0
    @State var showSheet: Bool = false
    @State var showSearchSheet: Bool = false // New state for the MusicSearch sheet
    @State var x: Bool = false
    @State var isFave: Bool = false
    @State var color: Color = .black
    @State var onDetails: Bool = false
    @State var showMenu: Bool = false
    
    @State private var selectedSong: MusicKit.Song? // Holds the selected song for playback


    @Binding var carPlay: Bool

    @ObservedObject private var carPlayObserver = CarPlayObserver.shared

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // Album Artwork matches progress bar width
                AlbumArtworkView(viewModel: viewModel)
                    .scaledToFit()
                    .frame(width: 400, height: 400)
                    .padding(.horizontal, 20) // Aligns with progress slider width
                    .onTapGesture {
                        onDetails = true
                    }
                // Title, Artist, and Actions Row
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.title)
                            .font(.system(size: 18))
                            .fontWeight(.bold)

                        Text(viewModel.artist)
                            .font(.system(size: 15))
                            .foregroundColor(.secondary)
                    }
                    .onChange(of: viewModel.title) {
                        isFave = viewModel.isSongInLibraryPlaylist(title: viewModel.title)
                    }
                    .onAppear {
                        Task {
                            isFave = viewModel.isSongInLibraryPlaylist(title: viewModel.title)
                        }
                    }

                    Spacer()

                    // Favorite Button
                    Button(action: {
                        Task {
                            if isFave {
                                isFave = try await viewModel.searchSongDelete(q: "\(viewModel.title) \(viewModel.artist)")
                            } else {
                                isFave = try await viewModel.searchSong(q: "\(viewModel.title) \(viewModel.artist)")
                            }
                        }
                    }) {
                        Image(systemName: isFave ? "heart.fill" : "heart")
                            .foregroundColor(isFave ? .blue : .white)
                            .bold()
                    }
                    .frame(width: 46, height: 46)

                    // Search Button
                    Button(action: {
                        showSearchSheet = true // Open the MusicSearch sheet
                    }) {
                        Image(systemName: "magnifyingglass.circle")
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)

                    // Playlist Button
                    Button(action: {
                        viewModel.showMenu = true
                    }) {
                        Image(systemName: "list.bullet.circle")
                            .foregroundColor(.white)
                    }
                    .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)

                // Playback Progress
                VStack {
                    ProgressBarView(
                        currentPlaybackTime: $viewModel.currentPlaybackTime,
                        totalPlaybackTime: $viewModel.totalPlaybackTime
                    ) { newTime in
                        viewModel.seek(to: Float(newTime))
                    }

                    HStack {
                        Text(formatTime(viewModel.currentPlaybackTime))
                            .font(.caption)
                            .foregroundColor(.secondary)

                        Spacer()

                        Text(formatTime(viewModel.totalPlaybackTime - viewModel.currentPlaybackTime))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal, 20)

                // Playback Controls
                HStack {
                    Spacer()
                    ControlButton(iconName: "backward.fill") {
                        viewModel.skipToPreviousItem()
                    }
                    Spacer()
                    PlayButton(
                        iconName: viewModel.playbackState == .playing ? "pause.fill" : "play.fill"
                    ) {
                        if viewModel.playbackState == .playing {
                            viewModel.pause()
                        } else {
                            viewModel.play()
                        }
                    }
                    Spacer()
                    ControlButton(iconName: "forward.fill") {
                        viewModel.skipToNextItem()
                    }
                    Spacer()
                }
                .padding(.top, 5)

                // Volume Slider
                if carPlayObserver.carPlay {
                    SimpleSlider()
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                } else {
                    VolumeSlider()
                        .frame(height: 44)
                        .padding(.horizontal, 20)
                }

                Spacer()
            }
            .padding(.vertical, 30)
            .sheet(isPresented: $viewModel.showMenu) {
                LibraryMenuSheet(viewModel: viewModel, showSheet: $showSheet)
            }
            
            .sheet(isPresented: $showSearchSheet) {
                MusicSearch(
                    viewModel: viewModel,
                    isPresented: $showSearchSheet,
                    onSelectSong: { song in
                        selectedSong = song
                        Task {
                            try await viewModel.playSelectedSong(song) // Start playback of selected song
                        }
                    }
                )                    .preferredColorScheme(.dark)
            }
            
            .sheet(isPresented: $onDetails) {
                AlbumDetailsView(viewModel: viewModel)
                    .preferredColorScheme(.dark)
            }
            .onChange(of: carPlayObserver.carPlay) { newValue, _ in
                print("carPlay changed to: \(newValue)")
            }

        }
        .background(color.opacity(0.5).edgesIgnoringSafeArea(.all))
    }

    private func formatTime(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let seconds = Int(seconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
struct VolumeSlider: View {

    var body: some View {
        ZStack {
            // Actual volume control
            MPVolumeViewRepresentable()
                .accentColor(.gray)
                .frame(height: 20)
        }
    }
}

struct FakeSlider: View {

    var body: some View {
        ZStack {
            // Dummy slider for CarPlay
            Slider(value: .constant(0.0)) // Placeholder slider
                .accentColor(.gray)
                .frame(height: 20)
        }
    }
}

struct MPVolumeViewRepresentable: UIViewRepresentable {
    func makeUIView(context: Context) -> MPVolumeView {
        let volumeView = MPVolumeView()
        

        // Create a smaller thumb image
        let thumbImage = UIImage(systemName: "circle.fill")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
            .resized(to: CGSize(width: 10, height: 10)) // Resize the thumb

        // Set the custom thumb image
        volumeView.setVolumeThumbImage(thumbImage, for: .normal)
        volumeView.tintColor = .gray // Set the track color

        return volumeView
    }

    func updateUIView(_ uiView: MPVolumeView, context: Context) {
        // Ensure the custom thumb image persists on updates
        let thumbImage = UIImage(systemName: "circle.fill")?
            .withTintColor(.gray, renderingMode: .alwaysOriginal)
            .resized(to: CGSize(width: 10, height: 10))
        uiView.setVolumeThumbImage(thumbImage, for: .normal)
        uiView.tintColor = .gray
    }
}

extension UIImage {
    /// Resize an image to a specific size
    func resized(to size: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: .zero, size: size))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage ?? self
    }
}

struct RoutePicker: UIViewRepresentable {
    func makeUIView(context: Context) -> AVRoutePickerView {
        let routePickerView = AVRoutePickerView()
        routePickerView.tintColor = UIColor.white // Set the button color to white
        routePickerView.activeTintColor = UIColor.gray // Optional: Customize the active state color
        return routePickerView
    }

    func updateUIView(_ uiView: AVRoutePickerView, context: Context) {
        uiView.tintColor = UIColor.white // Ensure the tint color remains white
    }
}

struct ProgressBarView: View {
    @Binding var currentPlaybackTime: Double // Current playback time in seconds
    @Binding var totalPlaybackTime: Double // Total duration in seconds
    var onSeek: ((Double) -> Void)? // Closure for seeking playback

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background bar
                Capsule()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 4)

                // Progress bar
                Capsule()
                    .fill(Color.gray)
                    .frame(
                        width: {
                            guard totalPlaybackTime > 0, currentPlaybackTime >= 0 else { return 0 }
                            let ratio = currentPlaybackTime / totalPlaybackTime
                            let width = CGFloat(ratio) * geometry.size.width
                            return max(0, width.isFinite ? width : 0)
                        }(),
                        height: 4
                    )
            }
            .contentShape(Rectangle()) // Ensures the entire progress bar area is tappable
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let newTime = min(max(0, value.location.x / geometry.size.width), 1) * totalPlaybackTime
                        currentPlaybackTime = newTime
                    }
                    .onEnded { value in
                        let newTime = min(max(0, value.location.x / geometry.size.width), 1) * totalPlaybackTime
                        onSeek?(newTime) // Notify the parent view of the seek
                    }
            )
        }
        .frame(height: 20)
    }
}
struct ControlButton: View {
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: iconName)
                .font(.title)
                .foregroundColor(.primary)
                .padding()
        }
    }
}

struct PlayButton: View {
    let iconName: String
    let action: () -> Void

    var body: some View {
        Button(action: {
            print("Button tapped")
            action()
        }) {
            Image(systemName: iconName)
                .font(.system(size: 45))
                .foregroundColor(.primary)
                .padding()
                .onLongPressGesture {
                    print("Long press detected")
                    MediaItemViewModel.shared.musicPlayer.stop()
                    MediaItemViewModel.shared.musicPlayer.nowPlayingItem = nil
                    MediaItemViewModel.shared.musicPlayer.setQueue(with: [])
                    print("Media player stopped and queue cleared")
                }
        }
    }
}

struct SongsView: View {
    @ObservedObject var viewModel: MediaItemViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var showSheet: Bool

    var body: some View {
        NavigationView {
            List(viewModel.songs, id: \.persistentID) { song in
                HStack(spacing: 16) {
                    // Artwork
                    if let artwork = song.artwork?.image(at: CGSize(width: 4000, height: 4000)) {
                        Image(uiImage: artwork)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 70, height: 70)
                            .cornerRadius(8)
                            .overlay(Text("No Artwork").font(.caption))
                    }

                    // Song Details
                    VStack(alignment: .leading) {
                        Text(song.title ?? "Unknown Song")
                            .font(.headline)
                            .lineLimit(1)
                        Text(song.artist ?? "Unknown Artist")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)

                    Spacer()

                    // Play Button
                    Button(action: {
                        //viewModel.playSelectedSong(findMPMediaItem(song))
                       playSong(song)
                        DispatchQueue.main.async {
                            dismiss()
                            viewModel.showMenu = false
                        }
                        
                    }) {
                        Image(systemName: "play.circle")
                            .resizable()
                            .frame(width: 30, height: 30)
                            .foregroundColor(.blue)
                    }
                }
                .padding(.vertical, 8)
            }
            .navigationTitle("Songs")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Helper function to play a song
    func playSong(_ song: MPMediaItem) {
        
        let id = song.playbackStoreID

        viewModel.musicPlayer.setQueue(with: [id])
        viewModel.musicPlayer.nowPlayingItem = song
        viewModel.musicPlayer.play()
        viewModel.updateCurrentMediaItem()
        print("Unable to retrieve song persistent ID.")
        return
    }

    /// Helper function to get a UIImage from MPMediaItemArtwork
    func getImage(from artwork: MPMediaItemArtwork, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        return artwork.image(at: size)
    }
}

struct AlbumsView: View {
    @ObservedObject var viewModel: MediaItemViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var showSheet: Bool

    var body: some View {
        NavigationView {
            List(viewModel.albums, id: \.persistentID) { album in
                NavigationLink(destination: AlbumDetailsView2(viewModel: viewModel, albumID: album.persistentID)) {
                    HStack(spacing: 16) {
                        // Artwork
                        if let artwork = album.representativeItem?.artwork?.image(at: CGSize(width: 4000, height: 4000)) {
                            Image(uiImage: artwork)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)
                                .overlay(Text("No Artwork").font(.caption))
                        }

                        // Album Name and Details
                        VStack(alignment: .leading) {
                            Text(album.representativeItem?.albumTitle ?? "Unknown Album")
                                .font(.headline)
                                .lineLimit(1)
                            Text(album.representativeItem?.artist ?? "Unknown Artist")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.vertical, 8)
                }
                .onAppear {
                    let _ = viewModel.albums.first?.persistentID
                    //print("first album id = \(albumID ?? .zero)")
                }
            }
            .navigationTitle("Albums")
            .navigationBarTitleDisplayMode(.inline)
        }

    }

    /// Helper function to get a UIImage from MPMediaItemArtwork
    func getImage(from artwork: MPMediaItemArtwork, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {

        return artwork.image(at: size)
    }
}

struct PlaylistView: View {
    @ObservedObject var viewModel: MediaItemViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var showSheet: Bool

    var body: some View {
        NavigationView {
            List(viewModel.playlists, id: \.persistentID) { playlist in
                NavigationLink(destination: SongListView(playlist: playlist, showSheet: $showSheet, viewModel: viewModel)) {
                    HStack(spacing: 16) {
                        // Artwork
                        if let artwork = playlist.items.first?.artwork?.image(at: CGSize(width: 4000, height: 4000)) {
                            Image(uiImage: artwork)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)
                        } else {
                            Rectangle()
                                .fill(Color.gray.opacity(0.3))
                                .frame(width: 70, height: 70)
                                .cornerRadius(8)
                                .overlay(Text("No Artwork").font(.caption))
                        }

                        // Playlist Name
                        VStack(alignment: .leading) {
                            Text(playlist.name ?? "Unknown Playlist")
                                .font(.headline)
                                .lineLimit(1)
                            Text("\(playlist.items.count) Songs")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                    .padding(.vertical, 8)
                }
            }
            .navigationTitle("Playlists")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    /// Helper function to get a UIImage from MPMediaItemArtwork
    func getImage(from artwork: MPMediaItemArtwork, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        return artwork.image(at: size)
    }
}
struct SongListView: View {
    @Environment(\.dismiss) private var dismiss
    var playlist: MPMediaPlaylist
    @Binding var showSheet: Bool
    @ObservedObject var viewModel: MediaItemViewModel
    func getImage(from artwork: MPMediaItemArtwork, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage? {
        return artwork.image(at: size)
    }
    var body: some View {
        List(playlist.items, id: \.persistentID) { song in
            Button(action: {
                viewModel.playPlaylist(playlist, startingAt: song)
                DispatchQueue.main.async {
                    dismiss()
                    viewModel.showPlaylist = false
                    viewModel.showMenu = false
                }
            }) {
                VStack {
                    HStack {
                        if let playlistArt = song.artwork?.image(at: CGSize(width: 4000, height: 4000)) {
                                Image(uiImage: playlistArt)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(8)
                            } else {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 70, height: 70)
                                    .cornerRadius(8)
                                    .overlay(Text("No Artwork").font(.caption))
                            }
          
                        
                            VStack(alignment: .leading) {
                                Text(song.title ?? "Unknown Title")
                                    .font(.headline)
                                Text(song.artist ?? "Unknown Artist")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding()
                    }
                }
            }
            .navigationTitle(playlist.name ?? "Songs")
            .navigationBarTitleDisplayMode(.inline)
        }
        
    }
}

struct SongWithArtwork {
    let song: Song
    let artwork: UIImage?
}

struct SongMetadata {
    let title: String
    let artist: String
    let album: String
    let genre: String
    let artworkURL: URL?
}
