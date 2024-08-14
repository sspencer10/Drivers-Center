//
//  Drivers_CenterApp.swift
//  Drivers Center
//
//  Created by Steven Spencer on 8/12/24.
//
import SwiftUI
import CarPlay
import MapKit

@main
struct ContentView: App {
    //@Environment(\.scenePhase) var scenePhase
    @State var carPlay = TemplateManager()
    var body: some Scene {
        WindowGroup {
                MainView()
                   // .environment(\.managedObjectContext, PersistenceController().container.viewContext)
            

        }

    }
}
