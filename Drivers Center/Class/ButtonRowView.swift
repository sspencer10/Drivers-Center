import SwiftUI

struct ButtonRowView: View {
    var body: some View {
        HStack(spacing: 16) {
            CustomButton(iconName: "car.fill", label: "3 min", color: .blue)
            CustomButton(iconName: "phone.fill", label: "Call", color: .black)
            CustomButton(iconName: "safari", label: "Website", color: .black)
        }
        .padding()
        .background(Color(UIColor.systemBackground))
    }
}

struct CustomButton: View {
    let iconName: String
    let label: String
    let color: Color

    var body: some View {
        Button(action: {
            // Add your action here
        }) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundColor(color == .blue ? .white : .primary)
                Text(label)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color == .blue ? .white : .primary)
            }
            .frame(width: 70, height: 70)
            .background(color)
            .cornerRadius(12)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct ContentView: View {
    var body: some View {
        ButtonRowView()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.dark) // Adjust for light/dark mode
    }
}