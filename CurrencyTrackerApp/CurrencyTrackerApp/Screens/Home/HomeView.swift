//
//  HomeView.swift
//  CurrencyTrackerApp
//
//  Created by Yevhen on 08.04.2025.
//
import SwiftUI

struct HomeView: View {
    @EnvironmentObject var viewModel: HomeViewModel

    var body: some View {
        NavigationStack {
            if viewModel.isFirstLoad {
                VStack {
                    Spacer()
                    Image(systemName: "antenna.radiowaves.left.and.right")
                        .font(.system(size: 72))
                        .symbolEffect(.variableColor.iterative)
                    
                    Text("Loading...")
                    Spacer()
                }
                .navigationTitle("Exchange Rates")
            } else {
                VStack(spacing: 0) {
                    // Neutral error message (only when currencies exist)
                    if let error = viewModel.errorMessage,
                       !viewModel.selectedCurrencies.isEmpty {
                        Text(errorMessage(for: error))
                            .foregroundColor(.secondary)
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding([.horizontal, .top])
                        Spacer()
                    }

                    if viewModel.selectedCurrencies.isEmpty {
                        PlaceholderView(
                            text: "No currencies selected. Please tap the + button to add a currency."
                        )
                    } else {
                        VStack(spacing: 0) {
                            if let lastUpdated = viewModel.lastUpdated {
                                HStack {
                                    Text("Last updated: \(formattedDate(lastUpdated))")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .padding([.horizontal, .top])
                                    Spacer()
                                    if viewModel.isLoading {
                                        ProgressView()
                                            .scaleEffect(0.4)
                                        Spacer()
                                    }
                                }
                                .padding([.horizontal, .top], 8)
                                .background(Color(.systemBackground))
                            }

                            List {
                                ForEach(viewModel.selectedCurrencies) { currency in
                                    if let rate = viewModel.rates[currency.code] {
                                        HStack {
                                            Text("1 USD")
                                            Spacer()
                                            Text(rate.formattedRateString(code: currency.code))
                                                .bold()
                                        }
                                    } else {
                                        HStack {
                                            Text("1 USD")
                                            Spacer()
                                            Text("–- \(currency.code)")
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .onDelete(perform: viewModel.removeCurrency)
                            }
                            .refreshable {
                                await viewModel.fetchRates()
                            }
                        }
                    }
                }
                .navigationTitle("Exchange Rates")
                .toolbar {
                    NavigationLink(destination: AddAssetView()) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private func errorMessage(for error: String) -> String {
        if error.lowercased().contains("internet") {
            return "You're offline. Displaying last known exchange rates."
        } else {
            return error
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM HH:mm:ss"
        return formatter.string(from: date)
    }
}

// MARK: - Decimal Formatting Helper

extension Decimal {
    func formattedRateString(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = Locale.current

        if code.uppercased() == "BTC" {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 8
        } else {
            formatter.minimumFractionDigits = 2
            formatter.maximumFractionDigits = 2
        }

        let formatted = formatter.string(from: self as NSNumber) ?? "–"
        return "\(formatted) \(code)"
    }
}

extension NumberFormatter {
    static let currencyRate: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2  // 👈 force exactly 2 digits
        formatter.locale = Locale.current
        return formatter
    }()
}
