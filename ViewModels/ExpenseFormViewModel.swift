import Foundation

final class ExpenseFormViewModel: ObservableObject {
    @Published var amountText: String
    @Published var currency: String
    @Published var convertedAmountText: String
    @Published var baseCurrency: String
    @Published var date: Date
    @Published var category: String
    @Published var expenseDescription: String
    @Published var note: String
    @Published var paymentMethod: String
    @Published var tagsText: String
    @Published var accountID: UUID?

    init(expense: Expense? = nil) {
        amountText = expense.map { Self.amountFormatter.string(from: NSNumber(value: $0.originalAmount)) ?? "\($0.originalAmount)" } ?? ""
        currency = expense?.originalCurrency ?? CurrencyOptions.defaultCurrency
        convertedAmountText = expense.map { Self.amountFormatter.string(from: NSNumber(value: $0.convertedAmount)) ?? "\($0.convertedAmount)" } ?? ""
        baseCurrency = expense?.baseCurrency ?? CurrencyOptions.defaultCurrency
        date = expense?.date ?? Date()
        category = expense?.category ?? ExpenseCategories.defaultCategory
        expenseDescription = expense?.expenseDescription ?? ""
        note = expense?.note ?? ""
        paymentMethod = expense?.paymentMethod ?? ""
        tagsText = expense?.tags.joined(separator: ", ") ?? ""
        accountID = expense?.accountID
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

    var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
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

    func makeExpense() -> Expense? {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return nil
        }

        return Expense(
            amount: amount,
            currency: currency,
            convertedAmount: convertedAmount,
            baseCurrency: baseCurrency,
            date: date,
            category: category,
            expenseDescription: cleaned(expenseDescription),
            note: cleaned(note),
            paymentMethod: cleaned(paymentMethod),
            tags: tags,
            accountID: accountID
        )
    }

    func update(_ expense: Expense) {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return
        }

        expense.originalAmount = amount
        expense.originalCurrency = currency
        expense.convertedAmount = convertedAmount
        expense.baseCurrency = baseCurrency
        expense.date = date
        expense.category = category
        expense.expenseDescription = cleaned(expenseDescription)
        expense.note = cleaned(note)
        expense.paymentMethod = cleaned(paymentMethod)
        expense.tags = tags
        expense.accountID = accountID
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

enum ExpenseCategories {
    static let all = [
        "Comida",
        "Transporte",
        "Hogar",
        "Servicios",
        "Salud",
        "Ocio",
        "Educacion",
        "Trabajo",
        "Otros"
    ]

    static let defaultCategory = "Comida"
}

enum CurrencyOptions {
    static let all = ["ARS", "USD", "EUR"]
    static let defaultCurrency = "ARS"
}

enum PaymentMethodOptions {
    static let all = [
        "Efectivo",
        "Tarjeta de debito",
        "Tarjeta de credito",
        "Transferencia",
        "Billetera virtual"
    ]
}
