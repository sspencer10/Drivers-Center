//
//  RetroSpeedometerView2.swift
//  Drivers Center
//
//  Created by Steven Spencer on 1/14/25.
//


import SwiftUI

struct IsCarPlayView: View {
    @State private var tabSelection = 3
    @State var carplay: Bool = false
    @ObservedObject var locationManager: LocationManager
    @ObservedObject var tm: TemplateManager
    @ObservedObject var weatherViewModel: WeatherViewModel
    @ObservedObject var mediaItemViewModel: MediaItemViewModel
    @State var x: Bool = false
    
    var body: some View {
        VStack {
            Spacer()
            // App Icon
            Button(action: {
                mediaItemViewModel.byPass()
            }) {
                Image("loginImg")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 100, height: 100)
                    .padding()
            }
            
            Button(action: {
                mediaItemViewModel.byPass()
            }) {
                Text("CarPlay Active")
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color("almostWhite"))
            }
                Button(action: {
                    print("Tapped Prominent Button")
                    mediaItemViewModel.byPass()
                }) {
                    Text("Unlock App")
                        .font(.system(size: 22, weight: .bold))
                        .padding(.horizontal, 35)
                        .padding(.vertical, 5)
                }
                .buttonStyle(.borderedProminent)
                .tint(.blue)
                .frame(minWidth: 350, maxWidth: .infinity) // Make the button span the full width
                //.padding(.horizontal, 16) // Add padding from the edges
            
            
            Spacer()
        }
        .frame(minWidth: 350, maxWidth: .infinity) // Make the button
        //span the full width
        

    }
}

struct IsCarPlayView_Previews: PreviewProvider {
    static var previews: some View {
        IsCarPlayView(locationManager: LocationManager.shared, tm: TemplateManager.shared, weatherViewModel: WeatherViewModel.shared, mediaItemViewModel: MediaItemViewModel.shared)
    }
}
