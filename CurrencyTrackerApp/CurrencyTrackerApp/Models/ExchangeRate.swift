//
//  ExchangeRate.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//

import Foundation

struct ExchangeRate: Codable {
    let base: String
    let rates: [String: Decimal]
    let timestamp: TimeInterval
}
