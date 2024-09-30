import SwiftUI

struct RetroSpeedometerView: View {
    @StateObject var lm: LocationManager
    
    var body: some View {

        ZStack {
            VStack {
                Spacer()
                Text("\(lm.speed, specifier: "%.1f") mph")
                    .font(.system(size: 30, weight: .bold))
                    //.foregroundColor(.white)
                    //.padding(.bottom, 30)
                Spacer()
                Spacer()
                Spacer()
                Spacer()
            }
            // Background Circle
            Circle()
                .fill(LinearGradient(gradient: Gradient(colors: [Color("darkGray2"), Color("medGray"), Color("ltGray")]), startPoint: .top, endPoint: .bottom))
                .frame(width: 330, height: 330)
                .shadow(radius: 10)
            
            // Dial Markers
            ForEach(0..<11) { i in
                VStack {
                    Text("\(i * 10)")  // Updated to reflect 100 max speed
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                        .rotationEffect(Angle.degrees(-Double(i) * 30 - 210)) // Compensates for rotation
                    Spacer()
                }
                .rotationEffect(Angle.degrees(Double(i) * 30)) // Rotate each marker
                //.offset(y: -140) // Commented out to allow markers to position naturally
            }
            .frame(width: 300, height: 300)
            .rotationEffect(Angle.degrees(210)) // Rotate the entire marker set to start at 230 degrees
            
            // Needle
            Rectangle()
                .fill(Color.red)
                .frame(width: 2, height: 100)
                .offset(y: -50)
                .rotationEffect(Angle.degrees(lm.speed * 3.0 + 210))  // Adjusted multiplier for 100 km/h max
                .animation(.easeInOut(duration: 0.5), value: lm.speed)
            
            // Center Circle
            Circle()
                .fill(Color.red)
                .frame(width: 15, height: 15)
            

        }

    }
}

struct RetroSpeedometerView_Previews: PreviewProvider {
    static var previews: some View {
        RetroSpeedometerView(lm: LocationManager.shared)
    }
}
