import SwiftUI
import MapKit

struct MapsView2: View {
    @ObservedObject var loc: LocationManager
    @ObservedObject var carPlay: MediaItemViewModel
    @State private var trackingMode: MKUserTrackingMode = .followWithHeading
    @State var x: Double = 32.0
    
    init(loc: LocationManager, carPlay: MediaItemViewModel) {
        self.loc = loc
        self.carPlay = carPlay
    }

    var body: some View {
        ZStack {
            CustomMapView(trackingMode: $trackingMode, x: $x)
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Menu {
                        Button("None") {
                            trackingMode = .none
                        }
                        Button("Follow") {
                            trackingMode = .follow
                        }
                        Button("Follow with Heading") {
                            trackingMode = .followWithHeading
                        }
                    } label: {
                        Image(systemName: "location.circle")
                            .resizable()
                            .frame(width: 44, height: 44)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 3)
                            .padding()
                    }
                }
            }
        }
        .onChange(of: loc.speed) { newValue, _ in
            if newValue > x + 2 || newValue < x - 2 {
                x = newValue
            }
        }
    }
}

struct CustomMapView: UIViewRepresentable {
    @Binding var trackingMode: MKUserTrackingMode
    @Binding var x: Double // Bind the zoom-determining variable

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.isRotateEnabled = true // Allow map rotation
        mapView.userTrackingMode = .followWithHeading // Default mode
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        // Calculate the desired zoom level based on x
        let span: MKCoordinateSpan
        if x <= 35 {
            span = MKCoordinateSpan(latitudeDelta: 0.003, longitudeDelta: 0.003) // Closest zoom
        } else if x <= 50 {
            span = MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005) // Medium zoom
        } else {
            span = MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01) // Farther zoom
        }
        print(span)

        // Update the map's camera instead of resetting userTrackingMode
        if let userLocation = uiView.userLocation.location {
            let camera = MKMapCamera(
                lookingAtCenter: userLocation.coordinate,
                fromDistance: 1000 / x, // Adjust zoom dynamically
                pitch: 0,
                heading: uiView.camera.heading // Maintain current heading
            )
            uiView.setCamera(camera, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        // Add MKMapViewDelegate methods if needed
    }
}

struct MapsView_Previews: PreviewProvider {
    static var previews: some View {
        MapsView(locationManager: LocationManager.shared)
    }
}
