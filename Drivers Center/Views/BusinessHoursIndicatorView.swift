import SwiftUI

struct BusinessHoursIndicatorView: View {
    let place: PlaceDetails
    @State private var isExpanded: Bool = false
    
    var body: some View {
        DisclosureGroup(
            isExpanded: $isExpanded,
            content: {
                // Display each day's hours.
                if let businessHours = place.businessHours {
                    ForEach(businessHours) { hour in
                        HStack {
                            Text(hour.day)
                                .font(.subheadline)
                            Spacer()
                            Text("\(formattedTime(hour.openTime)) - \(formattedTime(hour.closeTime))")
                                .font(.subheadline)
                        }
                        .padding(.vertical, 2)
                    }
                } else {
                    Text("Hours not available")
                        .font(.subheadline)
                }
            },
            label: {
                HStack {
                    Text(place.isCurrentlyOpen() ? "Open" : "Closed")
                        .font(.headline)
                        .foregroundColor(place.isCurrentlyOpen() ? .green : .red)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 4)
            }
        )
        .padding()
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(8)
    }
    
    // Helper function to format DateComponents into a time string.
    private func formattedTime(_ components: DateComponents) -> String {
        let calendar = Calendar.current
        guard let date = calendar.date(from: components) else { return "N/A" }
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a"
        return formatter.string(from: date)
    }
}