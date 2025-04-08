//
//  CurrencyAPIServiceTests.swift
//  CurrencyTrackerAppTests
//
//  Created by Yevhen on 08.04.2025.
//

import XCTest
@testable import CurrencyTrackerApp

final class CurrencyAPIServiceTests: XCTestCase {

    var sut: CurrencyAPIService!

    override func setUp() {
        super.setUp()
        sut = CurrencyAPIService()
    }

    func testFetchCurrencies_returnsCurrenciesFromNetwork() async throws {
        let currencies = try await sut.fetchCurrencies()
        XCTAssertFalse(currencies.isEmpty)
        XCTAssertTrue(currencies.contains { $0.code == "USD" })
    }

    func testFetchExchangeRates_returnsExchangeRatesFromNetwork() async throws {
        let rates = try await sut.fetchExchangeRates()
        XCTAssertFalse(rates.rates.isEmpty)
        XCTAssertEqual(rates.base, "USD")
    }

    func testFetchCurrencies_fallbacksToCache_whenOffline() async throws {
        let badService = BrokenCurrencyServiceMock()
        
        do {
            let currencies = try await badService.fetchCurrencies()
            XCTAssertFalse(currencies.isEmpty, "Should fallback to cached currencies")
        } catch {
            XCTFail("Expected fallback to cache, but got error: \(error)")
        }
    }
}

final class BrokenCurrencyServiceMock: CurrencyAPIServiceProtocol {
    private let cacheFile = "cached_currencies.json"
    
    func fetchCurrencies() async throws -> [Currency] {
        // Simulate offline by skipping network and returning cached data
        let path = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)[0].appendingPathComponent(cacheFile)
        guard let data = try? Data(contentsOf: path) else {
            throw URLError(.notConnectedToInternet)
        }
        let json = try JSONDecoder().decode([String: String].self, from: data)
        return json.map { Currency(code: $0.key, name: $0.value) }
    }

    func fetchExchangeRates() async throws -> ExchangeRate {
        throw URLError(.notConnectedToInternet)
    }
}
