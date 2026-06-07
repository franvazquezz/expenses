import XCTest
@testable import expenses

final class BudgetViewModelTests: XCTestCase {
    func testProgressCalculatesConsumedRemainingAndPercentage() {
        let date = Date()
        let budget = Budget(category: "Comida", amount: 300000, currency: "ARS", monthStart: date)
        let expense = Expense(
            amount: 100000,
            currency: "ARS",
            convertedAmount: 100000,
            baseCurrency: "ARS",
            date: date,
            category: "Comida"
        )

        let progress = BudgetViewModel.progress(
            for: [budget],
            expenses: [expense],
            month: MonthFilter(containing: date)
        )

        XCTAssertEqual(progress.first?.consumed, 100000)
        XCTAssertEqual(progress.first?.remaining, 200000)
        XCTAssertEqual(progress.first?.percentage ?? 0, 1.0 / 3.0, accuracy: 0.001)
    }

    func testProgressIgnoresDifferentCategoryCurrencyAndMonth() {
        let calendar = Calendar.current
        let date = Date()
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: date)!
        let budget = Budget(category: "Transporte", amount: 100000, currency: "ARS", monthStart: date)
        let expenses = [
            Expense(amount: 50000, currency: "ARS", convertedAmount: 50000, baseCurrency: "ARS", date: date, category: "Comida"),
            Expense(amount: 20, currency: "USD", convertedAmount: 28000, baseCurrency: "USD", date: date, category: "Transporte"),
            Expense(amount: 25000, currency: "ARS", convertedAmount: 25000, baseCurrency: "ARS", date: previousMonth, category: "Transporte")
        ]

        let progress = BudgetViewModel.progress(
            for: [budget],
            expenses: expenses,
            month: MonthFilter(containing: date)
        )

        XCTAssertEqual(progress.first?.consumed, 0)
        XCTAssertEqual(progress.first?.remaining, 100000)
        XCTAssertEqual(progress.first?.percentage, 0)
    }

    func testProgressCanIncludeInactiveBudgetsForManagementViews() {
        let date = Date()
        let inactiveBudget = Budget(
            category: "Ocio",
            amount: 150000,
            currency: "ARS",
            monthStart: date,
            isActive: false
        )

        let activeOnly = BudgetViewModel.progress(
            for: [inactiveBudget],
            expenses: [],
            month: MonthFilter(containing: date)
        )
        let includingInactive = BudgetViewModel.progress(
            for: [inactiveBudget],
            expenses: [],
            month: MonthFilter(containing: date),
            includeInactive: true
        )

        XCTAssertTrue(activeOnly.isEmpty)
        XCTAssertEqual(includingInactive.count, 1)
    }
}
