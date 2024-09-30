
import SwiftUI
import AppIntents
import MediaPlayer
import Foundation



struct ElevationView: View {
    @StateObject var carPlay: LocationManager
    @StateObject var tm = TemplateManager()
    @StateObject var music: Music
    @State var val: Float = 32.0
    @State var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    @State var nowPlayingArtist: String = ""
    @State var nowPlayingTitle: String = ""
    @State var MinMax: (min: Float, max: Float) = (0, 1000)
    @State var showSheet: Bool = false
    @State var carPlay2: Bool = false
    @State var authorized: Bool = false
    @State var checked: Bool = false
    @State var artworkUrl: String = ""
    @State var test: String = "Test"
    var uiImage: UIImage?
    //@StateObject private var musicObserver = MusicObserver()

    
    
    var body: some View {
        
        
        if !(carPlay2) {
            VStack {
                Image(.mountains)
                    .scaleEffect(3)
                    .tint(.red)
                    .onTapGesture {
                        showSheet = true
                    }
                    .sheet(isPresented: $showSheet) {

                        VStack {
                            let imageUrl = URL(string: music.artworkUrl)
                            if let imageUrl = imageUrl {
                                AsyncImage(url: imageUrl) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView() // Placeholder while loading
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .foregroundColor(.gray)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                .frame(width: 200, height: 200)
                            } else {
                                let imageUrl = URL(string: "https://rightdevllc.com/images/592590040.png")
                                if let imageUrl = imageUrl {
                                    AsyncImage(url: imageUrl) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView() // Placeholder while loading
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.gray)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                    .frame(width: 200, height: 200)
                                }
                            }
                            Text(music.title)
                            Text(music.artist)
                            HStack {
                                if let uiImage = UIImage(systemName: "arrowshape.left.circle") {
                                    Button(action: {
                                        // Define the action to perform when the button is tapped
                                        self.musicPlayer.skipToPreviousItem()
                                    }) {
                                        Image(uiImage: uiImage)
                                            .resizable()    // Make the image resizable
                                            .aspectRatio(contentMode: .fit)  // Maintain aspect ratio
                                            .frame(width: 75, height: 75)  // Set the frame size
                                    }
                                    .buttonStyle(PlainButtonStyle())  // Optional: Remove default button styles (like highlighting)
                                } else {
                                    Text("No Image Available")
                                }
                                
                                if let uiImage = UIImage(systemName: "playpause.circle") {
                                    Button(action: {
                                        // Define the action to perform when the button is tapped
                                        if self.musicPlayer.playbackState == .playing {
                                            self.musicPlayer.pause()
                                        } else {
                                            self.musicPlayer.play()
                                        }
                                    }) {
                                        Image(uiImage: uiImage)
                                            .resizable()    // Make the image resizable
                                            .aspectRatio(contentMode: .fit)  // Maintain aspect ratio
                                            .frame(width: 75, height: 75)  // Set the frame size
                                    }
                                    .buttonStyle(PlainButtonStyle())  // Optional: Remove default button styles (like highlighting)
                                } else {
                                    Text("No Image Available")
                                }
                                
                                if let uiImage = UIImage(systemName: "arrowshape.right.circle") {
                                    Button(action: {
                                        // Define the action to perform when the button is tapped
                                        self.musicPlayer.skipToNextItem()
                                    }) {
                                        Image(uiImage: uiImage)
                                            .resizable()    // Make the image resizable
                                            .aspectRatio(contentMode: .fit)  // Maintain aspect ratio
                                            .frame(width: 75, height: 75)  // Set the frame size
                                    }
                                    .buttonStyle(PlainButtonStyle())  // Optional: Remove default button styles (like highlighting)
                                } else {
                                    Text("No Image Available")
                                }
                            }
          
                        }
                    }
                Text("\n\n\(String(format: "%.1f", carPlay.altitude)) FT")
                    .font(.title)
            }
            /*
            .onChange(of: musicObserver.title) {
                music.getArt(completion: {x in
                        test = x
                })
            }
             */
            .onChange(of: tm.isCarPlay) {
                if tm.isCarPlay {
                    carPlay2 = true
                } else {
                    carPlay2 = false
                }
            }
            
            .onAppear {
                music.getArt(completion: {x in
                    test = x
                })
            }
        } else {
            ZStack {
                Color.black // Set the entire background to black
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("CarPlay is Active")
                        .font(.system(size: 24)) // Set font size to 24 points
                }
                .foregroundColor(.white)
            }
            
        }
        
    }
    
}
struct ElevationView_Previews: PreviewProvider {
    static var previews: some View {
        ElevationView(carPlay: LocationManager.shared, music: Music())
    }
}
