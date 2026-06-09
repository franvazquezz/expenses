import Foundation
import SwiftData

@Model
final class DailyReminderSettings {
    @Attribute(.unique) var id: UUID
    var isEnabled: Bool
    var hour: Int
    var minute: Int
    var updatedAt: Date

    init(
        id: UUID = UUID(),
        isEnabled: Bool = false,
        hour: Int = 20,
        minute: Int = 0,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.isEnabled = isEnabled
        self.hour = hour
        self.minute = minute
        self.updatedAt = updatedAt
    }
}

