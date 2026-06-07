import Foundation
import SwiftData

enum RecurrencePeriod: String, CaseIterable, Identifiable, Codable {
    case weekly
    case monthly
    case yearly

    var id: String { rawValue }

    var title: String {
        switch self {
        case .weekly:
            "Semanal"
        case .monthly:
            "Mensual"
        case .yearly:
            "Anual"
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .weekly:
            .weekOfYear
        case .monthly:
            .month
        case .yearly:
            .year
        }
    }
}

@Model
final class RecurringExpense: Identifiable {
    var name: String
    var originalAmount: Double
    var originalCurrency: String
    var convertedAmount: Double
    var baseCurrency: String
    var category: String
    var expenseDescription: String
    var note: String
    var paymentMethod: String
    var tags: [String]
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
        expenseDescription: String = "",
        note: String = "",
        paymentMethod: String = "",
        tags: [String] = [],
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
        self.expenseDescription = expenseDescription
        self.note = note
        self.paymentMethod = paymentMethod
        self.tags = tags
        self.periodRawValue = period.rawValue
        self.startDate = startDate
        self.nextRunDate = nextRunDate ?? startDate
        self.isActive = isActive
    }
}
