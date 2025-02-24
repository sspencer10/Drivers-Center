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
        .background(Color(.systemBackground)) // Adapts to light/dark mode
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        .padding(.horizontal)
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView {
            Text("This is a CardView")
                .font(.headline)
            Text("You can add any content inside.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .previewLayout(.sizeThatFits)
    }
}