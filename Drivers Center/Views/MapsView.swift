//
//  NavigationMapView.swift
//  Drivers Center
//
//  Created by Steven Spencer on 1/30/25.
//

import SwiftUI
import MapKit

struct MapsView: View {
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        ZStack {
            RouteMapView(routeCoordinates: locationManager.routeCoordinates) // ✅ Full UIKit `MKMapView`
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        locationManager.centerOnUser()
                    }) {
                        Image(systemName: "location.fill")
                            .padding()
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding()
                }
            }
        }
    }
}

// ✅ Full UIKit `MKMapView` Implementation (No SwiftUI `Map`)
struct RouteMapView: UIViewRepresentable {
    var routeCoordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays) // ✅ Clear previous overlays before adding new one

        // 🚀 **Fix: Prevent Crashes by Checking for Empty Route Data**
        guard !routeCoordinates.isEmpty else { return }

        let polyline = MKPolyline(coordinates: routeCoordinates, count: routeCoordinates.count)
        uiView.addOverlay(polyline)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView

        init(_ parent: RouteMapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer()
            }
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 5
            return renderer
        }
    }
}
