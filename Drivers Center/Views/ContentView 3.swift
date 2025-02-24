struct ContentView: View {
    @State private var showCustomSheet = false

    var body: some View {
        ZStack {
            // Sheet view (or any custom background view)
            if showCustomSheet {
                CustomSheetView()
                    // Optionally add a transition or animation
                    .transition(.move(edge: .bottom))
                    // Ensure this is behind the TabView by giving it a lower zIndex
                    .zIndex(0)
            }
            
            // TabView is defined above the sheet in the ZStack so it appears on top
            TabView {
                FirstTabView()
                    .tabItem {
                        Label("First", systemImage: "house")
                    }
                SecondTabView()
                    .tabItem {
                        Label("Second", systemImage: "star")
                    }
            }
            // Give the TabView a higher zIndex
            .zIndex(1)
        }
        .edgesIgnoringSafeArea(.all)
        // For demonstration, toggle the sheet when tapping anywhere
        .onTapGesture {
            withAnimation {
                showCustomSheet.toggle()
            }
        }
    }
}

struct CustomSheetView: View {
    var body: some View {
        // Customize your “sheet” appearance here.
        Rectangle()
            .fill(Color.blue.opacity(0.3))
            .frame(height: 300)
            .cornerRadius(20)
            .padding()
    }
}