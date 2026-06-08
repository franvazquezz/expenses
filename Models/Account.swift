import Foundation
import SwiftData

enum AccountType: String, CaseIterable, Codable {
    case asset
    case liability

    var title: String {
        switch self {
        case .asset:
            "Activo"
        case .liability:
            "Pasivo"
        }
    }
}

enum AccountCategoryOptions {
    static let assetCategories = [
        "Efectivo",
        "Cuenta bancaria",
        "Billetera virtual",
        "Inversion",
        "Cripto",
        "Otro"
    ]

    static let liabilityCategories = [
        "Tarjeta de credito",
        "Prestamo",
        "Deuda",
        "Otro"
    ]

    static func categories(for type: AccountType) -> [String] {
        switch type {
        case .asset:
            assetCategories
        case .liability:
            liabilityCategories
        }
    }
}

@Model
final class Account {
    @Attribute(.unique) var id: UUID
    var name: String
    var institution: String
    var typeRawValue: String
    var category: String
    var currency: String
    var balance: Double
    var note: String
    var isActive: Bool
    var updatedAt: Date

    var type: AccountType {
        get { AccountType(rawValue: typeRawValue) ?? .asset }
        set { typeRawValue = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        name: String,
        institution: String = "",
        type: AccountType,
        category: String,
        currency: String,
        balance: Double,
        note: String = "",
        isActive: Bool = true,
        updatedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.institution = institution
        self.typeRawValue = type.rawValue
        self.category = category
        self.currency = currency
        self.balance = balance
        self.note = note
        self.isActive = isActive
        self.updatedAt = updatedAt
    }
}
