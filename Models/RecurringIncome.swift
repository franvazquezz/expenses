import Foundation
import SwiftData

@Model
final class RecurringIncome: Identifiable {
    var name: String
    var originalAmount: Double
    var originalCurrency: String
    var convertedAmount: Double
    var baseCurrency: String
    var category: String
    var incomeDescription: String
    var note: String
    var periodRawValue: String
    var startDate: Date
    var nextRunDate: Date
    var isActive: Bool

    var period: RecurrencePeriod {
        get { RecurrencePeriod(rawValue: periodRawValue) ?? .monthly }
        set { periodRawValue = newValue.rawValue }
    }

    init(
        name: String,
        amount: Double,
        currency: String = "ARS",
        convertedAmount: Double? = nil,
        baseCurrency: String? = nil,
        category: String,
        incomeDescription: String = "",
        note: String = "",
        period: RecurrencePeriod = .monthly,
        startDate: Date = Date(),
        nextRunDate: Date? = nil,
        isActive: Bool = true
    ) {
        self.name = name
        self.originalAmount = amount
        self.originalCurrency = currency
        self.convertedAmount = convertedAmount ?? amount
        self.baseCurrency = baseCurrency ?? currency
        self.category = category
        self.incomeDescription = incomeDescription
        self.note = note
        self.periodRawValue = period.rawValue
        self.startDate = startDate
        self.nextRunDate = nextRunDate ?? startDate
        self.isActive = isActive
    }
}
