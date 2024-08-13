//
//  ContentView.swift
//  Speedometer
//
//  Created by Ashish Langhe on 12/13/21.
//

import SwiftUI
//import CarPlay
import MapKit

@main
struct ContentView: App {
    @Environment(\.scenePhase) var scenePhase
    @State var carPlay = TemplateManager()
    var body: some Scene {
        WindowGroup {
            if (carPlay.isCarPlay) {
                NotMainView()
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .background {
                            print("App in background")
                        } else if newPhase == .active {
                            print("App is active")
                        } else {
                            print("App is inactive")

                        }
                    }
            } else {
                MainView()
                    .onChange(of: scenePhase) { oldPhase, newPhase in
                        if newPhase == .background {
                            print("App in background")
                        } else if newPhase == .active {
                            print("App is active")
                        } else {
                            print("App is inactive")

                        }
                    }
            }
          
        }

    }
}






