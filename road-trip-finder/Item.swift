//
//  Item.swift
//  road-trip-finder
//
//  Created by Alexandru-Vitali Crutoi on 13/06/2026.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
