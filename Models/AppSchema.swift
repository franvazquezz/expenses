import Foundation
import SwiftData

enum ExpensesSchemaV1: VersionedSchema {
    static let versionIdentifier = Schema.Version(1, 0, 0)

    static var models: [any PersistentModel.Type] {
        [
            Expense.self,
            Income.self,
            Currency.self,
            ExchangeRate.self,
            Budget.self,
            RecurringExpense.self,
            RecurringIncome.self,
            Account.self,
            SavingsGoal.self,
            DailyReminderSettings.self
        ]
    }
}

enum ExpensesMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] {
        [
            ExpensesSchemaV1.self
        ]
    }

    static var stages: [MigrationStage] {
        []
    }
}
