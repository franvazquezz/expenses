import Foundation

final class IncomeFormViewModel: ObservableObject {
    @Published var amountText: String
    @Published var currency: String
    @Published var convertedAmountText: String
    @Published var baseCurrency: String
    @Published var date: Date
    @Published var category: String
    @Published var incomeDescription: String
    @Published var note: String

    init(income: Income? = nil) {
        amountText = income.map { Self.amountFormatter.string(from: NSNumber(value: $0.originalAmount)) ?? "\($0.originalAmount)" } ?? ""
        currency = income?.originalCurrency ?? CurrencyOptions.defaultCurrency
        convertedAmountText = income.map { Self.amountFormatter.string(from: NSNumber(value: $0.convertedAmount)) ?? "\($0.convertedAmount)" } ?? ""
        baseCurrency = income?.baseCurrency ?? CurrencyOptions.defaultCurrency
        date = income?.date ?? Date()
        category = income?.category ?? IncomeCategories.defaultCategory
        incomeDescription = income?.incomeDescription ?? ""
        note = income?.note ?? ""
    }

    var parsedAmount: Double? {
        parseAmount(amountText)
    }

    var parsedConvertedAmount: Double? {
        parseAmount(convertedAmountText)
    }

    var canSave: Bool {
        parsedAmount != nil &&
        parsedConvertedAmount != nil &&
        !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        !currency.isEmpty &&
        !baseCurrency.isEmpty
    }

    var needsConversion: Bool {
        currency != baseCurrency
    }

    func setDefaultCurrencyIfNeeded(_ defaultCurrency: String) {
        guard amountText.isEmpty else {
            return
        }

        currency = defaultCurrency
        baseCurrency = defaultCurrency
        convertedAmountText = amountText
    }

    func updateConversion(using rates: [ExchangeRate]) {
        guard let amount = parsedAmount else {
            convertedAmountText = ""
            return
        }

        guard let convertedAmount = ExchangeRateViewModel.convertedAmount(
            amount: amount,
            from: currency,
            to: baseCurrency,
            rates: rates
        ) else {
            return
        }

        convertedAmountText = Self.amountFormatter.string(from: NSNumber(value: convertedAmount)) ?? "\(convertedAmount)"
    }

    func makeIncome() -> Income? {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return nil
        }

        return Income(
            amount: amount,
            currency: currency,
            convertedAmount: convertedAmount,
            baseCurrency: baseCurrency,
            date: date,
            category: category,
            incomeDescription: cleaned(incomeDescription),
            note: cleaned(note)
        )
    }

    func update(_ income: Income) {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return
        }

        income.originalAmount = amount
        income.originalCurrency = currency
        income.convertedAmount = convertedAmount
        income.baseCurrency = baseCurrency
        income.date = date
        income.category = category
        income.incomeDescription = cleaned(incomeDescription)
        income.note = cleaned(note)
    }

    private func cleaned(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseAmount(_ value: String) -> Double? {
        let normalizedAmount = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(normalizedAmount), amount > 0 else {
            return nil
        }

        return amount
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}

enum IncomeCategories {
    static let all = [
        "Sueldo",
        "Freelance",
        "Ventas",
        "Otros"
    ]

    static let defaultCategory = "Sueldo"
}
