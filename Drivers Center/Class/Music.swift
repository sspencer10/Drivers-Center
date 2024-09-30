//
//  Music.swift
//  Drivers Center
//
//  Created by Steven Spencer on 9/4/24.
//

import SwiftUI
import MediaPlayer
import Foundation

class Music: ObservableObject {
    @StateObject var carPlay = LocationManager.shared
    @StateObject var tm = TemplateManager()
    @Published var nowPlayingArtist: String = ""
    @Published var nowPlayingTitle: String = ""
    @State var showSheet: Bool = false
    @State var carPlay2: Bool = false
    @State var authorized: Bool = false
    @State var checked: Bool = false
    @Published var artworkUrl: String = ""
    @Published var artist: String = "Unknown Artist"
    @Published var title: String = "Unknown Track"
    
    var musicPlayer = MPMusicPlayerController.systemMusicPlayer
    
    init() {
        getArt(completion: {_ in})
    }

    
    func getAuthorized(completion: @escaping (Bool) -> Void) {
        MPMediaLibrary.requestAuthorization { status in
            if status == .authorized {
                print("authorized")
                UserDefaults.standard.set(true, forKey: "authorized")
                UserDefaults.standard.set(true, forKey: "checked")
                self.getArt(completion: {_ in})
                completion(true)
            } else {
                print("not authorized")
                UserDefaults.standard.set(false, forKey: "authorized")
                completion(false)
            }
            
        }
    }
    
    func getArt(completion: @escaping (String) -> Void) {
        if UserDefaults.standard.bool(forKey: "checked") && UserDefaults.standard.bool(forKey: "authorized") {
            print("checked and authorized")
            let apiKey = "79b260aa0969db26482727d2748f4e16"
            if musicPlayer.nowPlayingItem != nil {
                
            
                getNowPlayingArtist(completion: {x in
                    self.artist = x
                    
                    self.getNowPlayingTitle(completion: {track in
                        self.title = track
                        
                        let urlString = "https://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=\(apiKey)&artist=\(self.artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&track=\(self.title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&format=json"
                        
                        guard let url = URL(string: urlString) else {
                            print("Artwork Invalid URL")
                            return
                        }
                        
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            guard let data = data, error == nil else {
                                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                   let track = json["track"] as? [String: Any],
                                   let album = track["album"] as? [String: Any],
                                   let images = album["image"] as? [[String: Any]] {
                                    if let imageUrl = images.first(where: { $0["size"] as? String == "extralarge" })?["#text"] as? String {
                                        print("Album Art URL: \(imageUrl)")
                                        DispatchQueue.main.async {
                                            self.artworkUrl = imageUrl
                                            UserDefaults.standard.set(imageUrl, forKey: "artUrl")
                                            completion(imageUrl)
                                        }
                                    } else {
                                        let xx = "https://rightdevllc.com/images/592590040.png"
                                        UserDefaults.standard.set(xx, forKey: "artUrl")
                                        print("Album art not found")
                                        completion(xx)
                                    }
                                }
                            } catch {
                                print("Failed to parse JSON: \(error.localizedDescription)")
                                let xx = "https://rightdevllc.com/images/592590040.png"
                                UserDefaults.standard.set(xx, forKey: "artUrl")
                                print("Album art not found")
                                completion(xx)
                            }
                        }
                        task.resume()
                    })
                })
            } else {
                artist = "Unknown Artist"
                title = "Unknown Title"
                artworkUrl = "https://rightdevllc.com/images/592590040.png"
            }
            
        }
    }
    
    func getArt2(artist: String, title: String, completion: @escaping (String) -> Void) {
            let apiKey = "79b260aa0969db26482727d2748f4e16"
                        let urlString = "https://ws.audioscrobbler.com/2.0/?method=track.getInfo&api_key=\(apiKey)&artist=\(artist.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&track=\(title.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&format=json"
                        
                        guard let url = URL(string: urlString) else {
                            print("Artwork Invalid URL")
                            return
                        }
                        
                        let task = URLSession.shared.dataTask(with: url) { data, response, error in
                            guard let data = data, error == nil else {
                                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                                return
                            }
                            
                            do {
                                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                                   let track = json["track"] as? [String: Any],
                                   let album = track["album"] as? [String: Any],
                                   let images = album["image"] as? [[String: Any]] {
                                    if let imageUrl = images.first(where: { $0["size"] as? String == "extralarge" })?["#text"] as? String {
                                        print("Album Art URL: \(imageUrl)")
                                        DispatchQueue.main.async {
                                            self.artworkUrl = imageUrl
                                            UserDefaults.standard.set(imageUrl, forKey: "artUrl")
                                            completion(imageUrl)
                                        }
                                    } else {
                                        print("Album art not found")
                                        let xx = "https://rightdevllc.com/images/592590040.png"
                                        UserDefaults.standard.set(xx, forKey: "artUrl")
                                        completion(xx)
                                    }
                                }
                            } catch {
                                print("Failed to parse JSON: \(error.localizedDescription)")
                                self.artworkUrl = "https://rightdevllc.com/images/592590040.png"
                                let xx = "https://rightdevllc.com/images/592590040.png"
                                UserDefaults.standard.set(xx, forKey: "artUrl")
                                completion(self.artworkUrl)
                            }
                        }
                        task.resume()
        }
    
    
    func getNowPlayingTitle(completion: @escaping (String) -> Void) {
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            nowPlayingTitle = nowPlayingItem.title ?? "Unknown Title"
            print("Title: \(nowPlayingTitle)")
            completion(nowPlayingTitle)
        } else {
            nowPlayingTitle = "Not Playing"
            completion(nowPlayingTitle)
        }
    }
    
    func getNowPlayingArtist(completion: @escaping (String) -> Void) {
        if let nowPlayingItem = musicPlayer.nowPlayingItem {
            nowPlayingArtist = nowPlayingItem.artist ?? "Unknown Artist"
            print("Artist: \(nowPlayingArtist)")
            completion(nowPlayingArtist)
        } else {
            nowPlayingArtist = "Not Playing"
            completion(nowPlayingArtist)
        }
    }
}
