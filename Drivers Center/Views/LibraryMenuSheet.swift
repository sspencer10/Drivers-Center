import SwiftUI

struct LibraryMenuSheet: View {
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("Library")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .padding(.top, 20)

            Spacer()

            VStack(spacing: 16) {
                Button(action: {
                    // Action for Playlists
                }) {
                    HStack {
                        Text("Playlists")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }

                Button(action: {
                    // Action for Albums
                }) {
                    HStack {
                        Text("Albums")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }

                Button(action: {
                    // Action for Songs
                }) {
                    HStack {
                        Text("Songs")
                            .font(.headline)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)

            Spacer()

            Button("Dismiss") {
                dismiss()
            }
            .font(.headline)
            .foregroundColor(.blue)
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
}

struct LibraryMenuSheet_Previews: PreviewProvider {
    static var previews: some View {
        LibraryMenuSheet()
    }
}