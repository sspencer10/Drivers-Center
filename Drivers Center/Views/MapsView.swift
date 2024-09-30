//
//  Speedometer.swift
//  Speedometer
//
//  Created by Steven Spencer on 6/22/24.
//
import SwiftUI
import MapKit
struct MapsView: View {
    @StateObject var carPlay: TemplateManager
    
    private let minValue = 0.0
    private let maxValue = 120.0
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State var carPlay2: Bool = false

    var body: some View {
        
        if !(carPlay2) {
            GeometryReader { geom in
                ZStack {
                    VStack {
                        
                        VStack {
                            
                            Map(position: $position) {
                                //UserAnnotation()
                            }
                            .tint(.red)
                            .mapControls {
                                MapUserLocationButton()
                                MapCompass()
                            }
                        }
                        .padding(.bottom, 80)
                    }
                    
                }
            }
            .onChange(of: carPlay.isCarPlay) {
                if carPlay.isCarPlay {
                    carPlay2 = true
                } else {
                    carPlay2 = false
                }
            }
        } else {
            ZStack {
                Color.black // Set the entire background to black
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Text("CarPlay is Active")
                        .font(.system(size: 24)) // Set font size to 24 points
                }
        }
        .foregroundColor(.white)
    }
    }
}
struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        
        MapsView(carPlay: TemplateManager())
    }
}


