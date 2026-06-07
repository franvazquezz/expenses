import Foundation

final class ExpenseFormViewModel: ObservableObject {
    @Published var amountText: String
    @Published var currency: String
    @Published var date: Date
    @Published var category: String
    @Published var expenseDescription: String
    @Published var note: String
    @Published var paymentMethod: String
    @Published var tagsText: String

    init(expense: Expense? = nil) {
        amountText = expense.map { Self.amountFormatter.string(from: NSNumber(value: $0.amount)) ?? "\($0.amount)" } ?? ""
        currency = expense?.currency ?? CurrencyOptions.defaultCurrency
        date = expense?.date ?? Date()
        category = expense?.category ?? ExpenseCategories.defaultCategory
        expenseDescription = expense?.expenseDescription ?? ""
        note = expense?.note ?? ""
        paymentMethod = expense?.paymentMethod ?? ""
        tagsText = expense?.tags.joined(separator: ", ") ?? ""
    }

    var parsedAmount: Double? {
        let normalizedAmount = amountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(normalizedAmount), amount > 0 else {
            return nil
        }

        return amount
    }

    var canSave: Bool {
        parsedAmount != nil && !category.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func makeExpense() -> Expense? {
        guard let amount = parsedAmount else {
            return nil
        }

        return Expense(
            amount: amount,
            currency: currency,
            date: date,
            category: category,
            expenseDescription: cleaned(expenseDescription),
            note: cleaned(note),
            paymentMethod: cleaned(paymentMethod),
            tags: tags
        )
    }

    func update(_ expense: Expense) {
        guard let amount = parsedAmount else {
            return
        }

        expense.amount = amount
        expense.currency = currency
        expense.date = date
        expense.category = category
        expense.expenseDescription = cleaned(expenseDescription)
        expense.note = cleaned(note)
        expense.paymentMethod = cleaned(paymentMethod)
        expense.tags = tags
    }

    private func cleaned(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
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
    static let all = ["ARS", "USD", "EUR", "BRL", "CLP", "UYU"]
    static let defaultCurrency = "USD"
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
