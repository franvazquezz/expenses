import SwiftData
import SwiftUI

@main
struct expensesApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(for: [Expense.self, Income.self, Currency.self, ExchangeRate.self, Budget.self, RecurringExpense.self, RecurringIncome.self, Account.self])
    }
}
