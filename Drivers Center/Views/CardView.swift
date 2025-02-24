import SwiftUI

struct CardView<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            content
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(uiColor: .secondarySystemBackground)) // Better contrast in dark mode
        )
        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3) // Stronger shadow
        .padding(.horizontal)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            CardView {
                Text("Light Mode Card")
                    .font(.headline)
                Text("This card stands out in light mode.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .preferredColorScheme(.light)

            CardView {
                Text("Dark Mode Card")
                    .font(.headline)
                Text("This card is now visible in dark mode!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .preferredColorScheme(.dark)
        }
        .previewLayout(.sizeThatFits)
    }
}
