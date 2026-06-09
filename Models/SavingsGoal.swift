import Foundation
import SwiftData

@Model
final class SavingsGoal {
    @Attribute(.unique) var id: UUID
    var name: String
    var targetAmount: Double
    var currentAmount: Double
    var currency: String
    var targetDate: Date?
    var note: String
    var isActive: Bool
    var createdAt: Date
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        targetAmount: Double,
        currentAmount: Double = 0,
        currency: String = "ARS",
        targetDate: Date? = nil,
        note: String = "",
        isActive: Bool = true,
        createdAt: Date = Date(),
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self.currency = currency
        self.targetDate = targetDate
        self.note = note
        self.isActive = isActive
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

