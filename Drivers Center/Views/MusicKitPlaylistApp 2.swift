import SwiftUI
import MusicKit

@main
struct MusicKitPlaylistApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

@MainActor
struct ContentView: View {
    @State private var search_q: String = ""
    @State private var isLoading = false
    @State private var message: String? = nil
    @State var songArray: [String] = []
    @State var plSongs: [Song] = []
    
    var body: some View {
        VStack(spacing: 20) {
            
            TextField("Add or Remove song (title artist)", text: $search_q)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                if !search_q.isEmpty {
                    Task {
                        try await searchSong(q: search_q)
                    }
                }
            }) {
                Text("Add Song")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            
            Button(action: {
                if !search_q.isEmpty {
                    Task {
                        try await searchSongDelete(q: search_q)
                    }
                }
            }) {
                Text("Remove Song")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .disabled(isLoading)
            
            if isLoading {
                ProgressView("Processing...")
            }

        }
        .padding()
        .onAppear {
            Task {
               await getPlaylistSongs()
            }
        }
    }
    