//
//  MusicKitPlaylistApp 2.swift
//  Drivers Center
//
//  Created by Steven Spencer on 1/18/25.
//

import SwiftUI
import MusicKit

@MainActor
struct MusicSearch: View {
    @ObservedObject var viewModel: MediaItemViewModel
    @Binding var isPresented: Bool
    var onSelectSong: (MusicKit.Song) -> Void

    @State private var searchQuery: String = ""
    @State private var isLoading: Bool = false
    @State private var songs: [MusicKit.Song] = []
    @State private var errorMessage: String? = nil
    @State var recentSearches: [String] = []

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                TextField("Search for music...", text: $searchQuery)
                    //.textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .background(Color("darkerGray"))
                    .cornerRadius(20) // Round the corners
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color("darkerGray"), lineWidth: 1) // Optional: Border
                    )
                    .padding(.top, 25)
                    .padding()
                    .onSubmit {
                        search() // Also trigger search when "Return" key is pressed
                    }
                
                Button(action: {
                    search()
                }) {
                    Text("Search")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(20)
                }
                .padding(.horizontal)
                .disabled(isLoading || searchQuery.isEmpty)
                
                if isLoading {
                    ProgressView("Searching...")
                }
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding(.top)
                }
                
                if !songs.isEmpty {
                    SongsListView(
                        songs: songs,
                        viewModel: viewModel,
                        isPresented: $isPresented,
                        onSelectSong: onSelectSong
                    )
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.inline) // Ensures the title is displayed
        }
    }
    func search() {
        if !searchQuery.isEmpty {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            if recentSearches.count < 5 {
                recentSearches.append(searchQuery)
            } else {
                recentSearches.removeFirst()
                recentSearches.append(searchQuery)
            }
            Task {
                isLoading = true
                do {
                    songs = try await viewModel.searchSongs(q: searchQuery)
                    errorMessage = nil
                } catch {
                    errorMessage = "No results found."
                }
                isLoading = false
            }
        }
    }
}

@MainActor
struct SongsListView: View {
    var songs: [MusicKit.Song]
    @ObservedObject var viewModel: MediaItemViewModel
    @Binding var isPresented: Bool
    var onSelectSong: (MusicKit.Song) -> Void

    var body: some View {
        List(songs, id: \.id) { song in
            Button(action: {
                onSelectSong(song) // Pass the selected song back
                isPresented = false // Dismiss the sheet
            }) {
                HStack {
                    if let artwork = song.artwork,
                       let artworkURL = artwork.url(width: 70, height: 70) {
                        AsyncImage(url: artworkURL) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 50, height: 50)
                            case .success(let image):
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            case .failure:
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(width: 50, height: 50)
                                    .cornerRadius(8)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 50, height: 50)
                            .cornerRadius(8)
                    }
                    VStack(alignment: .leading) {
                        Text(song.title)
                            .font(.headline)
                            .lineLimit(1)
                        Text(song.artistName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()

                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("Songs")
    }
}
