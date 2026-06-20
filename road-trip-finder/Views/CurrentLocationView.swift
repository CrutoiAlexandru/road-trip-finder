import CoreLocation
import SwiftUI

struct CurrentLocationView: View {
    @State private var user = User.shared
    @State private var locationsHandler = LocationHandler.shared

    var body: some View {
        HStack(spacing: 20) {
            if locationsHandler.lastLocation != nil {
                Text(verbatim: user.latitude.map { String($0) } ?? "Unknown latitude")
                Text(verbatim: user.longitude.map { String($0) } ?? "Unknown longitude")
                Text(verbatim: user.speedKmh.map { String($0) } ?? "Unknown speed")
                Text(verbatim: user.altitude.map { String($0) } ?? "Unknown altitude")
            } else {
                Text("Waiting for location...")
            }
        }
        .padding()
        .task {
            locationsHandler.startLocationUpdates()
        }
    }
}
