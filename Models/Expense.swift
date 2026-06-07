import Foundation
import SwiftData

@Model
final class Expense {
    var amount: Double
    var currency: String
    var date: Date
    var category: String
    var expenseDescription: String
    var note: String
    var paymentMethod: String
    var tags: [String]

    init(
        amount: Double,
        currency: String = "USD",
        date: Date,
        category: String,
        expenseDescription: String = "",
        note: String = "",
        paymentMethod: String = "",
        tags: [String] = []
    ) {
        self.amount = amount
        self.currency = currency
        self.date = date
        self.category = category
        self.expenseDescription = expenseDescription
        self.note = note
        self.paymentMethod = paymentMethod
        self.tags = tags
    }
}
