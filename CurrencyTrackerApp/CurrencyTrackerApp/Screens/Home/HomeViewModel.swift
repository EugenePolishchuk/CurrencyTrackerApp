//
//  HomeViewModel.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//
import Foundation
import Combine
import Network

@MainActor
class HomeViewModel: ObservableObject {
    @Published private(set) var selectedCurrencies: [Currency] = []
    @Published private(set) var rates: [String: Decimal] = [:]
    @Published var lastUpdated: Date?
    @Published var errorMessage: String?
    @Published var isLoading: Bool = false
    @Published var isFirstLoad: Bool = true

    private let service: CurrencyAPIServiceProtocol
    private var timerCancellable: AnyCancellable?
    private let monitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    private enum Keys {
        static let selectedCurrencies = "SelectedCurrencies"
    }

    init(service: CurrencyAPIServiceProtocol = CurrencyAPIService()) {
        self.service = service
        loadSelectedCurrencies()
        observeNetworkChanges()
        startAutoUpdate()
        Task { await fetchRates() }
    }

    // MARK: - Auto Update Timer

    func startAutoUpdate() {
        timerCancellable = Timer.publish(every: 5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { await self?.fetchRates() }
            }
    }

    // MARK: - Network Monitoring

    private func observeNetworkChanges() {
        monitor.pathUpdateHandler = { [weak self] path in
            guard let self else { return }
            Task { @MainActor in
                if path.status == .satisfied {
                    self.errorMessage = nil
                    await self.fetchRates()
                } else {
                    self.errorMessage = "You're offline. Displaying last known exchange rates."
                }
            }
        }
        monitor.start(queue: monitorQueue)
    }

    private var isOnline: Bool {
        monitor.currentPath.status == .satisfied
    }

    // MARK: - Fetch Rates

    func fetchRates() async {
        guard !selectedCurrencies.isEmpty else {
            isFirstLoad = false
            return
        }

        isLoading = true
        defer {
            isLoading = false
            isFirstLoad = false
        }

        do {
            let exchange = try await service.fetchExchangeRates()
            let selectedCodes = Set(selectedCurrencies.map(\.code))
            rates = exchange.rates.filter { selectedCodes.contains($0.key) }
            if monitor.currentPath.status == .satisfied {
                lastUpdated = Date()
            } else {
                lastUpdated = Date(timeIntervalSince1970: exchange.timestamp)
            }
            errorMessage = isOnline ? nil : "You're offline. Showing last known rates."
        } catch {
            errorMessage = "Failed to fetch rates. Showing last known data if available."
        }
    }

    // MARK: - Currency Management

    func addCurrency(_ currency: Currency) {
        guard !selectedCurrencies.contains(currency) else { return }
        selectedCurrencies.append(currency)
        saveSelectedCurrencies()
        Task { await fetchRates() }
    }

    func removeCurrency(at offsets: IndexSet) {
        selectedCurrencies.remove(atOffsets: offsets)
        saveSelectedCurrencies()
    }

    func removeCurrency(_ currency: Currency) {
        if let index = selectedCurrencies.firstIndex(of: currency) {
            selectedCurrencies.remove(at: index)
            saveSelectedCurrencies()
        }
    }

    // MARK: - Persistence

    private func loadSelectedCurrencies() {
        if let data = UserDefaults.standard.data(forKey: Keys.selectedCurrencies),
           let saved = try? JSONDecoder().decode([Currency].self, from: data) {
            selectedCurrencies = saved
        } else {
            selectedCurrencies = [
                Currency(code: "AED", name: "United Arab Emirates Dirham"),
                Currency(code: "BTC", name: "Bitcoin"),
                Currency(code: "EUR", name: "Euro"),
                Currency(code: "CHF", name: "Swiss Franc"),
                Currency(code: "JPY", name: "Japanese Yen"),
                Currency(code: "QAR", name: "Qatari Rial"),
                Currency(code: "SEK", name: "Swedish Krona"),
                Currency(code: "UAH", name: "Ukrainian Hryvnia")
            ]
        }
    }

    private func saveSelectedCurrencies() {
        if let data = try? JSONEncoder().encode(selectedCurrencies) {
            UserDefaults.standard.set(data, forKey: Keys.selectedCurrencies)
        }
    }
}
