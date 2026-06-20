import CoreLocation
import Foundation
import Observation
import SwiftUI
import UIKit

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        let locationsHandler = LocationHandler.shared

        if locationsHandler.updatesStarted {
            locationsHandler.startLocationUpdates()
        }

        if locationsHandler.backgroundActivity {
            locationsHandler.backgroundActivity = true
        }

        return true
    }
}

@Observable
@MainActor
class LocationHandler {
    static let shared = LocationHandler()

    private let manager: CLLocationManager
    private var background: CLBackgroundActivitySession?
    private var locationUpdatesTask: Task<Void, Never>?

    var lastLocation: CLLocation?
    var isStationary = false
    var count = 0

    var updatesStarted: Bool = UserDefaults.standard.bool(forKey: "liveUpdatesStarted") {
        didSet { UserDefaults.standard.set(updatesStarted, forKey: "liveUpdatesStarted") }
    }

    var backgroundActivity: Bool = UserDefaults.standard.bool(forKey: "BGActivitySessionStarted") {
        didSet {
            backgroundActivity
                ? background = CLBackgroundActivitySession() : background?.invalidate()
            UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
        }
    }

    private init() {
        manager = CLLocationManager()
    }
}

extension LocationHandler {
    func startLocationUpdates() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }

        if locationUpdatesTask != nil {
            return
        }

        print("Starting location updates")
        updatesStarted = true

        locationUpdatesTask = Task {
            do {
                let updates = CLLocationUpdate.liveUpdates()

                for try await update in updates {
                    if !self.updatesStarted { break }

                    if let loc = update.location {
                        self.lastLocation = loc

                        User.shared.latitude = loc.coordinate.latitude
                        User.shared.longitude = loc.coordinate.longitude
                        User.shared.speed = loc.speed >= 0 ? loc.speed : nil
                        User.shared.altitude = loc.altitude

                        self.isStationary = update.stationary
                        self.count += 1

                        print("Location \(self.count): \(loc)")
                    }
                }
            } catch {
                print("Could not start location updates")
            }
            self.locationUpdatesTask = nil
        }
    }
}

extension LocationHandler {
    func stopLocationUpdates() {
        print("Stopping location updates")
        updatesStarted = false
        locationUpdatesTask?.cancel()
        locationUpdatesTask = nil
    }
}
