import SwiftUI
import MapKit

struct SpeedometerView: View {
    
    @StateObject var carPlay: LocationManager
    @StateObject var wvm: WeatherViewModel
    @StateObject var tm = TemplateManager()
    @State var carPlay2: Bool = false
    
    let minValue = 0.0
    let maxValue = 125.0
    
    var body: some View {
        if !(carPlay2) {
            /*
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
        */
            RetroSpeedometerView(lm: LocationManager.shared)

        .onAppear() {
            Task {
                await wvm.fetchWeather()
            }
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

