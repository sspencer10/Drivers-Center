import MapKit
import SwiftUI

struct SpeedometerView: View {

    @StateObject var lm: LocationManager

    let coveredRadius: Double
    let maxValue: Int
    let steperSplit: Int

    private var tickCount: Int {
        return maxValue / steperSplit
    }

    func colorMix(percent: Int) -> Color {
        //let p = Double(percent)
        //let tempG = (100.0 - p) / 100
        //let g: Double = tempG < 0 ? 0 : tempG
        //let tempR = 1 + (p - 100.0) / 100.0
        //let r: Double = tempR < 0 ? 0 : tempR
        //return Color(red: r, green: g, blue: 0)
        return Color.cyan
    }

    func tick(at tick: Int, totalTicks: Int) -> some View {
        let percent = (tick * 100) / totalTicks
        let startAngle = coveredRadius / 2 * -1.015
        let stepper = coveredRadius / Double(totalTicks)
        let rotation = Angle.degrees(startAngle + stepper * Double(tick))
        return VStack {
            Rectangle()
                .fill(colorMix(percent: percent))
                .frame(
                    width: tick % 2 == 0 ? 5 : 3,  // Big tick for even, small for odd
                    height: tick % 2 == 0 ? 20 : 10)
            Spacer()
        }
        .rotationEffect(rotation)
    }

    func label(at tick: Int, totalTicks: Int) -> some View {
        let percent = (tick * 100) / totalTicks
        let lvalue = tick * steperSplit
        let startAngle = coveredRadius / 2 * -1.79
        let stepper = coveredRadius / Double(totalTicks * 2)
        let rotation = Angle.degrees(startAngle + stepper * Double(tick * 2))
        let radius = 112.0  // Inside the arc

        return Text("\(lvalue)")
            .font(.system(size: 17, weight: .bold)).italic()
            .foregroundColor(colorMix(percent: percent))
            .rotationEffect(.zero)  // Keep text straight
            .offset(
                x: radius * cos(rotation.radians),
                y: radius * sin(rotation.radians))
    }

    var body: some View {
        ZStack {  // Draw ticks
            ForEach(0..<21) { tick in
                self.tick(
                    at: tick,
                    totalTicks: self.tickCount * 2)
            }

            // Draw labels
            ForEach(0..<11) { tick in
                self.label(
                    at: tick,
                    totalTicks: self.tickCount)
            }
            VStack {
                // Add needle
                NeedleView(
                    value: lm.speed,
                    maxValue: Double(maxValue),
                    coveredRadius: coveredRadius
                )
                .padding()
            }
            VStack {
                Text(String(format: "%.0f", lm.speed))
                    .padding(.top, 120)
                    .font(.system(size: 38, weight: .bold))
                    .foregroundColor(Color.cyan)
                Text("MPH")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(Color.red)
            }

        }
        .frame(width: 320, height: 320, alignment: .center)
        .background(Color.black)  // Match the dark background
        .clipShape(Circle())  // Optional: Circular clipping

        .onChange(of: lm.speed) {
            print("speed: \(lm.speed)")
        }
    }
}
struct NeedleView: View {
    let value: Double
    let maxValue: Double
    let coveredRadius: Double

    func colorMix2(percent: Int) -> Color {
        return Color.red
    }

    var body: some View {
        ZStack {
            // Needle
            Rectangle()
                .fill(colorMix2(percent: 99))
                .frame(width: 3, height: 120)
                .offset(y: -60)  // Center the rotation
                .rotationEffect(needleRotation)
                .animation(.easeInOut(duration: 0.5), value: value)  // Add animation here

            // Center circle
            Circle()
                .fill(Color(.blue))
                .frame(width: 30, height: 30)
        }
    }

    private var needleRotation: Angle {
        let percent = value / maxValue
        let startAngle = coveredRadius / 2 * -1.015
        return Angle.degrees(startAngle + coveredRadius * percent)
    }
}

struct GaugeView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedometerView(
            lm: LocationManager.shared, coveredRadius: 230, maxValue: 100,
            steperSplit: 10)
    }
}
