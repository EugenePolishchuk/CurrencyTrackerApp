//
//  Currency.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//

import Foundation

public struct Currency: Identifiable, Codable, Equatable, Hashable {
    public var id: String { code }
    let code: String
    let name: String
}
