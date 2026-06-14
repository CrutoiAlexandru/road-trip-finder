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
        let locationsHandler = LocationsHandler.shared

        // If location updates were previously active, restart them after the background launch.
        if locationsHandler.updatesStarted {
            locationsHandler.startLocationUpdates()
        }
        // If a background activity session was previously active, reinstantiate it after the background launch.
        if locationsHandler.backgroundActivity {
            locationsHandler.backgroundActivity = true
        }
        return true
    }
}

// Shared state that manages the `CLLocationManager` and `CLBackgroundActivitySession`.
@Observable
@MainActor
class LocationsHandler {

    static let shared = LocationsHandler()  // Create a single, shared instance of the object.
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
                ? self.background = CLBackgroundActivitySession() : self.background?.invalidate()
            UserDefaults.standard.set(backgroundActivity, forKey: "BGActivitySessionStarted")
        }
    }

    private init() {
        self.manager = CLLocationManager()  // Creating a location manager instance is safe to call here in `MainActor`.
    }

    func startLocationUpdates() {
        if self.manager.authorizationStatus == .notDetermined {
            self.manager.requestWhenInUseAuthorization()
        }

        if locationUpdatesTask != nil {
            return
        }

        print("Starting location updates")
        self.updatesStarted = true
        locationUpdatesTask = Task {
            do {
                let updates = CLLocationUpdate.liveUpdates()
                for try await update in updates {
                    if !self.updatesStarted { break }  // End location updates by breaking out of the loop.
                    if let loc = update.location {
                        self.lastLocation = loc
                        User.globalUser.latitude = loc.coordinate.latitude
                        User.globalUser.longitude = loc.coordinate.longitude
                        User.globalUser.speed = loc.speed >= 0 ? loc.speed : nil
                        User.globalUser.altitude = loc.altitude
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

    func stopLocationUpdates() {
        print("Stopping location updates")
        self.updatesStarted = false
        self.locationUpdatesTask?.cancel()
        self.locationUpdatesTask = nil
    }
}
