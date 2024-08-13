import SwiftUI
import MapKit

struct SpeedometerView: View {
    
    @StateObject var carPlay: LocationManager
    
    let minValue = 0.0
    let maxValue = 120.0
    
    var body: some View {
        
        VStack {
            
                Gauge(value: carPlay.speed, in: minValue...maxValue) {
                    Text("MPH")
                }
                currentValueLabel: {
                    Text("\(carPlay.speed, specifier: "%.1f")")
                }
                .scaleEffect(4)
                .gaugeStyle(.accessoryCircular)
                .tint(.red)
                .frame(width: 400, height: 200, alignment: .center)
            }
        .onAppear() {
            
        }
    }
}
struct SpeedometerView_Previews: PreviewProvider {
    static var previews: some View {
        
        SpeedometerView(carPlay: LocationManager())
    }
}
