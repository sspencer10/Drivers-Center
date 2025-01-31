import SwiftUI

struct SimpleSlider: View {
    var body: some View {
        ZStack(alignment: .leading) {
            // Track (the bar)
            Rectangle()
                .fill(Color.gray.opacity(0.5)) // Track background color
                .frame(height: 4) // Height of the track
                .cornerRadius(2)

            // Thumb (the circle)
            Circle()
                .fill(Color.gray) // Thumb color
                .frame(width: 9, height: 9) // Thumb size
                .offset(y: 0) // Adjust vertically to center on the track
                .padding(.leading, -6) // Align thumb to the very start of the track
        }
        .frame(height: 20) // Overall height of the slider container
    }
}
