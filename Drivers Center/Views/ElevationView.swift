
import SwiftUI
import AppIntents


struct ElevationView: View {
    @StateObject var carPlay: LocationManager

    @State var val: Float = 32.0
    @State var MinMax: (min: Float, max: Float) = (0, 1000)
    @State var showSheet: Bool = false
    
    var body: some View {
        VStack {
            Image(.mountains)
                .scaleEffect(3)
                .tint(.red)
                .onTapGesture {
                    showSheet = true
                }
                .sheet(isPresented: $showSheet) {
                    VStack {
                        if #available(iOS 17.0, *) {
                            Text("Sheet")
                            .padding()
                        } else {
                            Text("Shortcuts require iOS 17 or later.")
                        }
                    }
                }
            Text("\n\n\(String(format: "%.1f", carPlay.altitude)) FT")
                .font(.title)
        }
    }
}
