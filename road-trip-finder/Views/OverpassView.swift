//
//  OverpassView.swift
//  road-trip-finder
//
//  Created by Alexandru-Vitali Crutoi on 18/06/2026.
//

import SwiftUI

struct OverpassView: View {
    @State private var user = User.shared
    private let client = OvpClient()
    @State private var response: String = ""
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 20) {
            Button("Get Api Call") {
                isLoading = true
                response = ""
                Task.detached(priority: .userInitiated) {
                    do {
                        let result = try await client.query(
                            lat: user.latitude, lon: user.longitude, radiusKm: 5)
                        await MainActor.run {
                            response = result
                            isLoading = false
                        }
                    } catch {
                        await MainActor.run {
                            response = "Error: \(error.localizedDescription)"
                            isLoading = false
                        }
                    }
                }
            }
            .disabled(isLoading)
            if isLoading {
                ProgressView("Loading…")
            } else {
                Text(response.isEmpty ? "Waiting" : response)
                    .textSelection(.enabled)
                    .font(.system(.body, design: .monospaced))
            }
        }
        .padding()
    }
}
