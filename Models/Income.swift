import Foundation
import SwiftData

@Model
final class Income {
    var originalAmount: Double
    var originalCurrency: String
    var convertedAmount: Double
    var baseCurrency: String
    var date: Date
    var category: String
    var incomeDescription: String
    var note: String

    init(
        amount: Double,
        currency: String = "ARS",
        convertedAmount: Double? = nil,
        baseCurrency: String? = nil,
        date: Date,
        category: String,
        incomeDescription: String = "",
        note: String = ""
    ) {
        self.originalAmount = amount
        self.originalCurrency = currency
        self.convertedAmount = convertedAmount ?? amount
        self.baseCurrency = baseCurrency ?? currency
        self.date = date
        self.category = category
        self.incomeDescription = incomeDescription
        self.note = note
    }
}
