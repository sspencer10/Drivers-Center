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

    var body: some View {
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
    }
}
struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        
        MapsView(carPlay: TemplateManager())
    }
}


