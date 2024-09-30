import Foundation
import SwiftUI

struct Marker: Hashable {
    let degrees: Double
    let label: String

    init(degrees: Double, label: String = "") {
        self.degrees = degrees
        self.label = label
    }

    func degreeText() -> String {
        return String(format: "%.0f", self.degrees)
    }

    static func markers() -> [Marker] {
        return [
            Marker(degrees: 0, label: "N"),
            Marker(degrees: 30),
            Marker(degrees: 60),
            Marker(degrees: 90, label: "E"),
            Marker(degrees: 120),
            Marker(degrees: 150),
            Marker(degrees: 180, label: "S"),
            Marker(degrees: 210),
            Marker(degrees: 240),
            Marker(degrees: 270, label: "W"),
            Marker(degrees: 300),
            Marker(degrees: 330)
        ]
    }
}

struct CompassMarkerView: View {
    let marker: Marker
    let compassDegress: Double

    var body: some View {
        VStack {
            Text(marker.degreeText())
                .fontWeight(.light)
                .rotationEffect(self.textAngle())
            
            Capsule()
                .frame(width: self.capsuleWidth(),
                       height: self.capsuleHeight())
                .foregroundColor(self.capsuleColor())
            
            Text(marker.label)
                .fontWeight(.bold)
                .rotationEffect(self.textAngle())
                .padding(.bottom, 180)
        }.rotationEffect(Angle(degrees: marker.degrees))
    }
    
    private func capsuleWidth() -> CGFloat {
        return self.marker.degrees == 0 ? 7 : 3
    }

    private func capsuleHeight() -> CGFloat {
        return self.marker.degrees == 0 ? 45 : 30
    }

    private func capsuleColor() -> Color {
        return self.marker.degrees == 0 ? .red : .gray
    }

    private func textAngle() -> Angle {
        return Angle(degrees: -self.compassDegress - self.marker.degrees)
    }
}

struct CompassView : View {
    @StateObject var carPlay = LocationManager.shared
    @StateObject var tm = TemplateManager()
    @State var carPlay2: Bool = false

    var body: some View {
            if !(carPlay2) {
                VStack {
                    
                    Capsule()
                        .frame(width: 5,
                               height: 50)
                    
                    ZStack {
                        ForEach(Marker.markers(), id: \.self) { marker in
                            CompassMarkerView(marker: marker,
                                              compassDegress: self.carPlay.degrees)
                        }
                    }
                    .frame(width: 300,
                           height: 300)
                    .rotationEffect(Angle(degrees: self.carPlay.degrees))
                    .statusBar(hidden: true)
                }
                .onChange(of: tm.isCarPlay) {
                    if tm.isCarPlay {
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

struct CompassView_Previews: PreviewProvider {
    static var previews: some View {
        CompassView(carPlay: LocationManager.shared)
    }
}
