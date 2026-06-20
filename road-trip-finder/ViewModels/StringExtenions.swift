//
//  StringExtenions.swift
//  road-trip-finder
//
//  Created by Alexandru-Vitali Crutoi on 18/06/2026.
//

import Foundation

extension String {
    func encodeURIComponent() -> String? {
        var characterSet = CharacterSet.alphanumerics
        characterSet.insert(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_.!~*'()")
        return addingPercentEncoding(withAllowedCharacters: characterSet)
    }
}
