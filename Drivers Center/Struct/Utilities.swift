import Foundation

func formatDistance(_ distanceInMeters: Double) -> String {
    let distance = Measurement(value: distanceInMeters, unit: UnitLength.meters)
    let formatter = MeasurementFormatter()
    formatter.unitOptions = .providedUnit
    formatter.unitStyle = .medium
    return formatter.string(from: distance)
}