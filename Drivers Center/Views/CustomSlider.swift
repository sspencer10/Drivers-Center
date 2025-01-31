import SwiftUI

struct CustomSlider: View {
    @Binding var value: Double
    var range: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            
            // Slider Track
            Rectangle()
                .fill(Color.gray.opacity(0.5))
                .frame(height: 4)
                .cornerRadius(2)
                .overlay(
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * width, height: 4)
                        .cornerRadius(2)
                )
                .gesture(
                    DragGesture()
                        .onChanged { gesture in
                            let newValue = Double(gesture.location.x / width) * (range.upperBound - range.lowerBound) + range.lowerBound
                            value = min(max(newValue, range.lowerBound), range.upperBound)
                        }
                )
                .padding(.horizontal)
        }
        .frame(height: 30) // Adjust the height as needed
    }
}

struct ContentView: View {
    @State private var sliderValue: Double = 50 // Example initial value
    
    var body: some View {
        VStack {
            CustomSlider(value: $sliderValue, range: 0...100)
            Text("Value: \(sliderValue, specifier: "%.2f")")
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}