import CoreLocation
import Foundation
import SwiftData

@Observable
@MainActor
class User {
    static let shared = User()

    var latitude: Double?
    var longitude: Double?
    var altitude: Double?
    var speed: Double?
    var speedKmh: Double? {
        speed.map { $0 * 3.6 }
    }

    private init() {}
}
