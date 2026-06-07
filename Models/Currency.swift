import Foundation
import SwiftData

@Model
final class Currency: Identifiable {
    @Attribute(.unique) var id: UUID
    @Attribute(.unique) var code: String
    var name: String
    var symbol: String
    var isDefault: Bool
    var isActive: Bool

    init(
        id: UUID = UUID(),
        code: String,
        name: String,
        symbol: String,
        isDefault: Bool = false,
        isActive: Bool = true
    ) {
        self.id = id
        self.code = code.uppercased()
        self.name = name
        self.symbol = symbol
        self.isDefault = isDefault
        self.isActive = isActive
    }
}
