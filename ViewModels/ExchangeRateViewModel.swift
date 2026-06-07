import Foundation
import SwiftData

final class ExchangeRateViewModel: ObservableObject {
    @Published var fromCurrency: String
    @Published var toCurrency: String
    @Published var rateText: String

    init(rate: ExchangeRate? = nil, defaultBaseCurrency: String = "ARS") {
        fromCurrency = rate?.fromCurrency ?? "USD"
        toCurrency = rate?.toCurrency ?? defaultBaseCurrency
        rateText = rate.map { Self.rateFormatter.string(from: NSNumber(value: $0.rate)) ?? "\($0.rate)" } ?? ""
    }

    var parsedRate: Double? {
        Self.parseAmount(rateText)
    }

    var canSave: Bool {
        parsedRate != nil && fromCurrency != toCurrency
    }

    func makeExchangeRate() -> ExchangeRate? {
        guard let rate = parsedRate else {
            return nil
        }

        return ExchangeRate(fromCurrency: fromCurrency, toCurrency: toCurrency, rate: rate)
    }

    func update(_ exchangeRate: ExchangeRate) {
        guard let rate = parsedRate else {
            return
        }

        exchangeRate.fromCurrency = fromCurrency
        exchangeRate.toCurrency = toCurrency
        exchangeRate.rate = rate
        exchangeRate.updatedAt = Date()
    }

    static func seedInitialRatesIfNeeded(in modelContext: ModelContext, existingRates: [ExchangeRate]) {
        guard existingRates.isEmpty else {
            return
        }

        modelContext.insert(ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400))
        modelContext.insert(ExchangeRate(fromCurrency: "EUR", toCurrency: "ARS", rate: 1600))
    }

    static func conversionRate(from sourceCurrency: String, to targetCurrency: String, rates: [ExchangeRate]) -> Double? {
        let source = sourceCurrency.uppercased()
        let target = targetCurrency.uppercased()

        if source == target {
            return 1
        }

        if let directRate = rates.first(where: { $0.fromCurrency == source && $0.toCurrency == target }) {
            return directRate.rate
        }

        if let inverseRate = rates.first(where: { $0.fromCurrency == target && $0.toCurrency == source }),
           inverseRate.rate > 0 {
            return 1 / inverseRate.rate
        }

        return nil
    }

    static func convertedAmount(amount: Double, from sourceCurrency: String, to targetCurrency: String, rates: [ExchangeRate]) -> Double? {
        guard let rate = conversionRate(from: sourceCurrency, to: targetCurrency, rates: rates) else {
            return nil
        }

        return amount * rate
    }

    private static func parseAmount(_ value: String) -> Double? {
        let normalizedValue = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(normalizedValue), amount > 0 else {
            return nil
        }

        return amount
    }

    private static let rateFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 6
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}
