import SwiftUI

struct ContentView: View {
    @State private var isSheetPresented = false

    var body: some View {
        Button("Show Sheet") {
            isSheetPresented.toggle()
        }
        .sheet(isPresented: $isSheetPresented) {
            VStack {
                Text("This is the sheet content.")
                Button("Dismiss") {
                    isSheetPresented = false
                }
            }
            .presentationDetents([.height(200), .medium]) // Adjusts height to show 25% initially
            .presentationDragIndicator(.visible)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}