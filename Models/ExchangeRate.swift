import Foundation
import SwiftData

@Model
final class ExchangeRate: Identifiable {
    @Attribute(.unique) var id: UUID
    var fromCurrency: String
    var toCurrency: String
    var rate: Double
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        fromCurrency: String,
        toCurrency: String,
        rate: Double,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.fromCurrency = fromCurrency.uppercased()
        self.toCurrency = toCurrency.uppercased()
        self.rate = rate
        self.updatedAt = updatedAt
    }
}
