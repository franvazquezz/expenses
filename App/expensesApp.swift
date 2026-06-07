import SwiftData
import SwiftUI

@main
struct expensesApp: App {
    var body: some Scene {
        WindowGroup {
            DashboardView()
        }
        .modelContainer(for: [Expense.self, Currency.self, ExchangeRate.self])
    }
}
