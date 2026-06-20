//
//  road_trip_finderApp.swift
//  road-trip-finder
//
//  Created by Alexandru-Vitali Crutoi on 13/06/2026.
//

import SwiftUI

@main
struct road_trip_finderApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate

    var body: some Scene {
        WindowGroup {
            CurrentLocationView()
            OverpassView()
        }
    }
}
