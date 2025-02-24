//
//  ContentView 2.swift
//  Drivers Center
//
//  Created by Steven Spencer on 2/6/25.
//


import SwiftUI

struct ContentView2: View {
    @State private var isSheetPresented = true

    var body: some View {
        Button("Show Sheet") {
            isSheetPresented.toggle()
        }
        .sheet(isPresented: $isSheetPresented) {
            VStack {
                Text("This is the sheet content.")
                Button("Dismiss") {
                    isSheetPresented = false
                }
            }
            .presentationDetents([.height(200), .large]) // Adjusts height to show 25% initially
            .presentationDragIndicator(.visible)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView2()
    }
}
