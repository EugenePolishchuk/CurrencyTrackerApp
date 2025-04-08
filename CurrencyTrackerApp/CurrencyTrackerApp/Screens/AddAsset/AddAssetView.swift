//
//  AddAssetView.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//
import SwiftUI

struct AddAssetView: View {
    @EnvironmentObject var homeViewModel: HomeViewModel
    @StateObject private var assetVM = AddAssetViewModel()
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            Group {
                let filtered = assetVM.filteredCurrencies(searchText: searchText)

                if filtered.isEmpty && !searchText.isEmpty {
                    // Empty search result view
                    VStack(spacing: 12) {
                        Spacer()

                        Image(systemName: "magnifyingglass.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .foregroundColor(.gray.opacity(0.4))

                        Text("No matching found. Try a different search")
                            .font(.body)
                            .foregroundColor(.secondary)

                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGroupedBackground))
                } else {
                    // Group currencies into sections
                    List {
                        let selected = filtered.filter { homeViewModel.selectedCurrencies.contains($0) }
                        let others = filtered.filter { !homeViewModel.selectedCurrencies.contains($0) }

                        if !selected.isEmpty {
                            Section(header: Text("Selected Assets")) {
                                ForEach(selected) { currency in
                                    currencyRow(for: currency, isSelected: true)
                                }
                            }
                        }

                        if !others.isEmpty {
                            Section(header: Text("Other Assets")) {
                                ForEach(others) { currency in
                                    currencyRow(for: currency, isSelected: false)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .searchable(text: $searchText)
            .navigationTitle("Add Asset")
            .task { await assetVM.fetchCurrencies() }
        }
    }

    @ViewBuilder
    private func currencyRow(for currency: Currency, isSelected: Bool) -> some View {
        Button {
            if isSelected {
                homeViewModel.removeCurrency(currency)
            } else {
                homeViewModel.addCurrency(currency)
            }
        } label: {
            HStack {
                Image(systemName: isSelected ? "checkmark.square" : "square")
                    .foregroundColor(.blue)

                VStack(alignment: .leading) {
                    Text(currency.code).bold()
                    Text(currency.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}


@MainActor
class AddAssetViewModel: ObservableObject {
    @Published private(set) var allCurrencies: [Currency] = []
    private let service: CurrencyAPIServiceProtocol

    init(service: CurrencyAPIServiceProtocol = CurrencyAPIService()) {
        self.service = service
    }

    func fetchCurrencies() async {
        do {
            allCurrencies = try await service.fetchCurrencies()
        } catch {
            allCurrencies = []
        }
    }

    func filteredCurrencies(searchText: String) -> [Currency] {
        guard !searchText.isEmpty else { return allCurrencies }
        return allCurrencies.filter {
            $0.code.localizedCaseInsensitiveContains(searchText) ||
            $0.name.localizedCaseInsensitiveContains(searchText)
        }
    }
}
