import Foundation
import SwiftData

@Model
final class Expense {
    var originalAmount: Double
    var originalCurrency: String
    var convertedAmount: Double
    var baseCurrency: String
    var date: Date
    var category: String
    var expenseDescription: String
    var note: String
    var paymentMethod: String
    var tags: [String]
    var isConfirmed: Bool
    var accountID: UUID?

    var amount: Double {
        get { originalAmount }
        set {
            originalAmount = newValue
            convertedAmount = newValue
        }
    }

    var currency: String {
        get { originalCurrency }
        set { originalCurrency = newValue }
    }

    init(
        amount: Double,
        currency: String = "USD",
        convertedAmount: Double? = nil,
        baseCurrency: String? = nil,
        date: Date,
        category: String,
        expenseDescription: String = "",
        note: String = "",
        paymentMethod: String = "",
        tags: [String] = [],
        isConfirmed: Bool = true,
        accountID: UUID? = nil
    ) {
        self.originalAmount = amount
        self.originalCurrency = currency
        self.convertedAmount = convertedAmount ?? amount
        self.baseCurrency = baseCurrency ?? currency
        self.date = date
        self.category = category
        self.expenseDescription = expenseDescription
        self.note = note
        self.paymentMethod = paymentMethod
        self.tags = tags
        self.isConfirmed = isConfirmed
        self.accountID = accountID
    }
}
