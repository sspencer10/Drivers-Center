import SwiftUI
import MapKit

struct SpeedometerView: View {
    @StateObject var lm: LocationManager
    @State var backgroundColor: Color = .black.opacity(1.0)
    @State var numberColor: Color = .mint.opacity(1.0)
    @State var numberColor2: Color = .teal


    let coveredRadius: Double
    let maxValue: Int       // Now set to 120 when you initialize this view.
    let steperSplit: Int
    let size: CGFloat       // Dynamic size parameter

    // Compute the number of major steps. For maxValue=120 and steperSplit=10, this is 12.
    private var tickCount: Int {
        return maxValue / steperSplit
    }

    func colorMix(percent: Int) -> Color {
        // Your color mixing logic – in this case it always returns cyan.
        return Color(numberColor)
    }

    func tick(at tick: Int, totalTicks: Int, size: CGFloat) -> some View {
        // Calculate a percentage for color mixing purposes (if needed)
        let percent = (tick * 100) / totalTicks
        // Determine the starting angle for the ticks. (This value is taken from your original logic.)
        let startAngle = coveredRadius / 2 * -1.015
        // Each tick occupies an equal portion of the arc.
        let stepper = coveredRadius / Double(totalTicks)
        let rotation = Angle.degrees(startAngle + stepper * Double(tick))
        
        return VStack {
            Rectangle()
                .fill(colorMix(percent: percent))
                .frame(
                    width: tick % 2 == 0 ? size * 0.015 : size * 0.01, // Larger width for major ticks.
                    height: tick % 2 == 0 ? size * 0.0625 : size * 0.03125 // And scaled height.
                )
            Spacer()
        }
        .rotationEffect(rotation)
    }

    func label(at tick: Int, totalTicks: Int, size: CGFloat) -> some View {
        // Calculate a percentage value (if needed for styling).
        let percent = (tick * 100) / totalTicks
        // The label's numeric value is the tick number multiplied by steperSplit.
        let lvalue = tick * steperSplit
        
        // Adjust the label placement along the arc.
        let startAngle = coveredRadius / 2 * -1.79
        let stepper = coveredRadius / Double(totalTicks * 2)
        let rotation = Angle.degrees(startAngle + stepper * Double(tick * 2))
        let radius = size * 0.35 // Radius for the label placement
        
        return Text("\(lvalue)")
            .font(.system(size: size * 0.05, weight: .bold)).italic()
            .foregroundColor(colorMix(percent: percent))
            .rotationEffect(.zero) // Keep text horizontal
            .offset(
                x: radius * cos(rotation.radians),
                y: radius * sin(rotation.radians)
            )
    }

    var body: some View {
        ZStack {
            // Draw ticks.
            // Instead of hardcoding 21 ticks (for 100 mph), we now calculate:
            // For tickCount major steps, we have (tickCount * 2 + 1) ticks.
            ForEach(0 ..< (tickCount * 2 + 1), id: \.self) { tick in
                self.tick(at: tick, totalTicks: tickCount * 2, size: size)
            }

            // Draw labels.
            // Instead of hardcoding 11 labels (0 through 10), we use tickCount+1.
            ForEach(0 ..< (tickCount + 1), id: \.self) { tick in
                self.label(at: tick, totalTicks: tickCount, size: size)
            }

            // Draw the needle.
            VStack {
                NeedleView(
                    value: lm.speed,
                    maxValue: Double(maxValue),
                    coveredRadius: coveredRadius,
                    size: size,
                    numberColor: $numberColor
                )
                .padding()
            }

            // Display the current speed and unit.
            VStack {
                Text(" ")
                Text(" ")
                
                Text(String(format: "%.0f", lm.speed))
                    .padding(.top, size * 0.375)
                    .font(.system(size: size * 0.12, weight: .bold))
                    .foregroundColor(Color(numberColor))
                Text("MPH")
                    .font(.system(size: size * 0.0375, weight: .bold))
                    .foregroundColor(Color.red)
            }
        }
        .frame(width: size, height: size, alignment: .center) // Use dynamic size
        .background(Color(backgroundColor))
        .clipShape(Circle())
        .onChange(of: lm.speed) {
            print("speed: \(lm.speed)")
        }
    }
}

struct NeedleView: View {
    let value: Double
    let maxValue: Double
    let coveredRadius: Double
    let size: CGFloat
    @Binding var numberColor: Color

    func colorMix2(percent: Int) -> Color {
        // Your needle color logic.
        return Color.red
    }

    var body: some View {
        ZStack {
            Rectangle()
                .fill(colorMix2(percent: 99))
                .frame(width: size * 0.009, height: size * 0.375)
                .offset(y: -size * 0.1875) // Center the rotation pivot
                .rotationEffect(needleRotation)
                .animation(.easeInOut(duration: 0.5), value: value)

            Circle()
                .fill(Color(numberColor))
                .frame(width: size * 0.09375, height: size * 0.09375)
        }
    }

    private var needleRotation: Angle {
        // Compute the fraction of the maximum speed.
        let percent = value / maxValue
        let startAngle = coveredRadius / 2 * -1.015
        // The needle rotates along the same arc as the ticks.
        return Angle.degrees(startAngle + coveredRadius * percent)
    }
}

struct GaugeView_Previews: PreviewProvider {
    static var previews: some View {
        SpeedometerView(
            lm: LocationManager.shared,
            coveredRadius: 230,
            maxValue: 120,    // Set maxValue to 120 here.
            steperSplit: 10,
            size: 320         // Preview size
        )
    }
}
