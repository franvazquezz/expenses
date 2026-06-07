import Foundation
import SwiftData

@Model
final class Budget: Identifiable {
    var category: String
    var amount: Double
    var currency: String
    var monthStart: Date
    var isActive: Bool

    init(
        category: String,
        amount: Double,
        currency: String = "ARS",
        monthStart: Date = Date(),
        isActive: Bool = true
    ) {
        self.category = category
        self.amount = amount
        self.currency = currency
        self.monthStart = Calendar.current.startOfMonth(for: monthStart)
        self.isActive = isActive
    }
}

extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components) ?? date
    }
}
