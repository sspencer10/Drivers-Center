//
//  MusicView.swift
//  Drivers Center
//
//  Created by Steven Spencer on 9/4/24.
//
import SwiftUI
import MediaPlayer

struct MusicView: View {
    @ObservedObject var viewModel: MediaItemViewModel
    @State var showSheet:Bool = false
    var body: some View {
        VStack {
            if let uiImage = viewModel.artworkImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 300, height: 300)
            } else {
                Text("No artwork available")
                    .frame(width: 300, height: 300)
                    .background(Color.gray)
            }

            // Display the title and artist below the artwork
            Text(viewModel.title)
                .font(.headline)
                .padding(.top, 10)
            
            Text(viewModel.artist)
                .font(.subheadline)
                .foregroundColor(.secondary)
            HStack {
                Spacer()
                if let uiImage = UIImage(systemName: "arrowshape.left.circle")?.withRenderingMode(.alwaysTemplate)  {
                    Button(action: {
                        // Define the action to perform when the button is tapped
                        viewModel.musicPlayer?.skipToPreviousItem()
                    }) {
                        Image(uiImage: uiImage)
                            .resizable()    // Make the image resizable
                            .aspectRatio(contentMode: .fit)  // Maintain aspect ratio
                            .frame(width: 50, height: 50)  // Set the frame size
                            .foregroundColor(Color("night"))
                    }//.foregroundColor(Color("night"))
                        .tint(.white)
                } else {
                    Text("No Image Available")
                }
                Spacer()
                if let uiImage = UIImage(systemName: "playpause.circle")?.withRenderingMode(.alwaysTemplate)  {
                    Button(action: {
                        // Define the action to perform when the button is tapped
                        if viewModel.musicPlayer?.playbackState == .playing {
                            viewModel.musicPlayer?.pause()
                        } else {
                            viewModel.musicPlayer?.play()
                        }
                    }) {
                        Image(uiImage: uiImage)
                            .resizable()    // Make the image resizable
                            .aspectRatio(contentMode: .fit)  // Maintain aspect ratio
                            .frame(width: 50, height: 50)  // Set the frame size
                            .foregroundColor(Color("night"))
                    }
                } else {
                    Text("No Image Available")
                }
                Spacer()
                if let uiImage = UIImage(systemName: "arrowshape.right.circle")?.withRenderingMode(.alwaysTemplate)  {
                    Button(action: {
                        // Define the action to perform when the button is tapped
                        viewModel.musicPlayer?.skipToNextItem()
                    }) {
                        Image(uiImage: uiImage)
                            .resizable()    // Make the image resizable
                            .aspectRatio(contentMode: .fit)  // Maintain aspect ratio
                            .frame(width: 50, height: 50)  // Set the frame size
                            .foregroundColor(Color("night"))
                    }
                    
                } else {
                    Text("No Image Available")
                }
                Spacer()
            }.padding()
            
            if let uiImage = UIImage(systemName: "text.line.first.and.arrowtriangle.forward")?.withRenderingMode(.alwaysTemplate)  {
                Button(action: {
                    print("playlist")
                    // Define the action to perform when the button is tapped
                    showSheet = true
                }) {
                    Image(uiImage: uiImage)
                        .resizable()    // Make the image resizable
                        .aspectRatio(contentMode: .fit)  // Maintain aspect ratio
                        .frame(width: 50, height: 50)  // Set the frame size
                        .foregroundColor(Color("night"))
                }
                
            } else {
                Text("No Image Available")
            }
        }
        .sheet(isPresented: $showSheet) {
            PlaylistView()
        }
    }
}

struct PlaylistView: View {
    @ObservedObject var viewModel = MediaItemViewModel()
    
    var body: some View {
        NavigationView {
            List(viewModel.fetchPlaylists(), id: \.persistentID) { playlist in
                NavigationLink(destination: SongListView(playlist: playlist, viewModel: viewModel)) {
                    Text(playlist.name ?? "Unknown Playlist")
                        .padding()
                }
            }
            .navigationTitle("Playlists")
        }
    }
}



struct SongListView: View {
    var playlist: MPMediaPlaylist
    @ObservedObject var viewModel: MediaItemViewModel
    
    var body: some View {
        List(playlist.items, id: \.persistentID) { song in
            Button(action: {
                viewModel.playPlaylist(playlist, startingAt: song)
            }) {
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
        .navigationTitle(playlist.name ?? "Songs")
    }
}



struct MusicView_Previews: PreviewProvider {
    static var previews: some View {
        MusicView(viewModel: MediaItemViewModel())
    }
}
