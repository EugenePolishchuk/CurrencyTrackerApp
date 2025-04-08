//
//  CurrencyAPIService.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//

import Foundation

protocol CurrencyAPIServiceProtocol {
    func fetchCurrencies() async throws -> [Currency]
    func fetchExchangeRates() async throws -> ExchangeRate
}

final class CurrencyAPIService: CurrencyAPIServiceProtocol {
    private let appId = "f17a54551f7e467090cfc8624fa4e60b"
    private let currenciesFile = "cached_currencies.json"
    private let ratesFile = "cached_rates.json"

    private func cacheURL(for fileName: String) -> URL {
        FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }

    func fetchCurrencies() async throws -> [Currency] {
        let urlString = "https://openexchangerates.org/api/currencies.json"
        var components = URLComponents(string: urlString)!
        components.queryItems = [URLQueryItem(name: "app_id", value: appId)]

        do {
            let (data, response) = try await URLSession.shared.data(from: components.url!)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            try data.write(to: cacheURL(for: currenciesFile))
            let json = try JSONDecoder().decode([String: String].self, from: data)
            return json.map { Currency(code: $0.key, name: $0.value) }.sorted { $0.code < $1.code }
        } catch {
            let path = cacheURL(for: currenciesFile)
            guard let data = try? Data(contentsOf: path) else { throw error }
            let json = try JSONDecoder().decode([String: String].self, from: data)
            return json.map { Currency(code: $0.key, name: $0.value) }.sorted { $0.code < $1.code }
        }
    }

    func fetchExchangeRates() async throws -> ExchangeRate {
        let urlString = "https://openexchangerates.org/api/latest.json"
        var components = URLComponents(string: urlString)!
        components.queryItems = [
            URLQueryItem(name: "app_id", value: appId)
        ]

        do {
            let (data, response) = try await URLSession.shared.data(from: components.url!)
            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                throw URLError(.badServerResponse)
            }
            try data.write(to: cacheURL(for: ratesFile))
            return try JSONDecoder().decode(ExchangeRate.self, from: data)
        } catch {
            let path = cacheURL(for: ratesFile)
            guard let data = try? Data(contentsOf: path) else { throw error }
            return try JSONDecoder().decode(ExchangeRate.self, from: data)
        }
    }
}
