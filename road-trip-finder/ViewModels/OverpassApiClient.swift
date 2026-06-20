//
//  OpenStreetMap.swift
//  road-trip-finder
//
//  Created by Alexandru-Vitali Crutoi on 15/06/2026.
//

import Foundation

enum AuthError: Error {
    case missingApiKey
}

struct OvpClient {
    private let apiUrl: String = "https://overpass-api.de/api/interpreter"
    // private var apiKey: String

    init() throws {
        //  guard let key = ProcessInfo.processInfo.environment["ORS_API_KEY"] else {
        //      throw AuthError.missingApiKey
        //  }

        //  self.apiKey = key
    }
}

extension OvpClient {
    func query(lat: Float64, lon: Float64, radiusKm: Float64) async throws -> String {
        // Build Overpass QL query
        let bbox = OvpHelper.getBbox(lat: lat, lon: lon, radiusKm: radiusKm)
        let q = Query(
            bbox: bbox,
            way: QueryWay(bbox: bbox),
            node: QueryNode(bbox: bbox),
            relation: QueryRelation(bbox: bbox)).format()
        guard let url = URL(string: apiUrl) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(
            "application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let bodyString = "data=" + q.encodeURIComponent()!
        request.httpBody = Data(bodyString.utf8)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              (200 ... 299).contains(httpResponse.statusCode)
        else {
            throw URLError(.badServerResponse)
        }

        return String(data: data, encoding: .utf8) ?? "Unable to decode response"
    }
}
