import Foundation
import SwiftData

struct CurrencySeed {
    let code: String
    let name: String
    let symbol: String
    let isDefault: Bool
}

final class CurrencyViewModel: ObservableObject {
    @Published var code = ""
    @Published var name = ""
    @Published var symbol = ""
    @Published var isDefault = false

    static let initialCurrencies = [
        CurrencySeed(code: "ARS", name: "Peso Argentino", symbol: "$", isDefault: true),
        CurrencySeed(code: "USD", name: "Dolar Estadounidense", symbol: "US$", isDefault: false),
        CurrencySeed(code: "EUR", name: "Euro", symbol: "EUR", isDefault: false)
    ]

    init(currency: Currency? = nil) {
        code = currency?.code ?? ""
        name = currency?.name ?? ""
        symbol = currency?.symbol ?? ""
        isDefault = currency?.isDefault ?? false
    }

    var normalizedCode: String {
        code.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    }

    var canSave: Bool {
        !normalizedCode.isEmpty &&
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !symbol.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func makeCurrency() -> Currency? {
        guard canSave else {
            return nil
        }

        return Currency(
            code: normalizedCode,
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            symbol: symbol.trimmingCharacters(in: .whitespacesAndNewlines),
            isDefault: isDefault
        )
    }

    func update(_ currency: Currency) {
        guard canSave else {
            return
        }

        currency.code = normalizedCode
        currency.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        currency.symbol = symbol.trimmingCharacters(in: .whitespacesAndNewlines)
        currency.isDefault = isDefault
    }

    static func seedInitialCurrenciesIfNeeded(in modelContext: ModelContext, existingCurrencies: [Currency]) {
        guard existingCurrencies.isEmpty else {
            ensureSingleDefaultCurrency(existingCurrencies)
            return
        }

        initialCurrencies.forEach { seed in
            modelContext.insert(
                Currency(
                    code: seed.code,
                    name: seed.name,
                    symbol: seed.symbol,
                    isDefault: seed.isDefault
                )
            )
        }
    }

    static func activeCurrencies(from currencies: [Currency]) -> [Currency] {
        currencies
            .filter(\.isActive)
            .sorted { $0.code < $1.code }
    }

    static func defaultCurrencyCode(from currencies: [Currency]) -> String {
        currencies.first(where: { $0.isDefault && $0.isActive })?.code ??
        currencies.first(where: \.isActive)?.code ??
        "ARS"
    }

    static func setDefault(_ currency: Currency, in currencies: [Currency]) {
        currencies.forEach { $0.isDefault = false }
        currency.isActive = true
        currency.isDefault = true
    }

    static func deactivate(_ currency: Currency, in currencies: [Currency]) {
        currency.isActive = false

        if currency.isDefault {
            currency.isDefault = false
            if let replacement = currencies.first(where: { $0.isActive && $0.id != currency.id }) {
                replacement.isDefault = true
            }
        }
    }

    private static func ensureSingleDefaultCurrency(_ currencies: [Currency]) {
        let activeCurrencies = currencies.filter(\.isActive)
        let defaults = activeCurrencies.filter(\.isDefault)

        if defaults.isEmpty {
            activeCurrencies.first?.isDefault = true
            return
        }

        defaults.dropFirst().forEach { $0.isDefault = false }
    }
}
