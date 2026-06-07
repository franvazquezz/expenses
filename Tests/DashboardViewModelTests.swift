import XCTest
@testable import expenses

final class DashboardViewModelTests: XCTestCase {
    func testTotalsAreGroupedByCurrency() {
        let viewModel = DashboardViewModel()
        let today = Date()
        let expenses = [
            Expense(amount: 100, currency: "USD", convertedAmount: 140000, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 50, currency: "ARS", convertedAmount: 50, baseCurrency: "ARS", date: today, category: "Transporte"),
            Expense(amount: 10, currency: "EUR", convertedAmount: 16000, baseCurrency: "ARS", date: today, category: "Ocio")
        ]

        let totals = viewModel.totalsThisMonth(from: expenses)

        XCTAssertEqual(totals.first { $0.currency == "ARS" }?.total, 156050)
    }

    func testLatestExpensesAreSortedByDateDescending() {
        let viewModel = DashboardViewModel()
        let calendar = Calendar.current
        let older = Expense(amount: 10, currency: "USD", date: calendar.date(byAdding: .day, value: -2, to: Date())!, category: "Comida")
        let newer = Expense(amount: 20, currency: "USD", date: Date(), category: "Comida")

        let latest = viewModel.latestExpenses(from: [older, newer])

        XCTAssertEqual(latest.first?.amount, 20)
    }

    func testTopCategoriesGroupsByCategoryAndCurrency() {
        let viewModel = DashboardViewModel()
        let today = Date()
        let expenses = [
            Expense(amount: 100, currency: "USD", convertedAmount: 140000, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 40, currency: "ARS", convertedAmount: 40, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 20, currency: "EUR", convertedAmount: 32000, baseCurrency: "ARS", date: today, category: "Comida")
        ]

        let categories = viewModel.topCategories(from: expenses)

        XCTAssertEqual(categories.first?.category, "Comida")
        XCTAssertEqual(categories.first?.currency, "ARS")
        XCTAssertEqual(categories.first?.total, 172040)
    }
}
