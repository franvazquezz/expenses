import XCTest
@testable import expenses

final class AdvancedFeaturesViewModelTests: XCTestCase {
    func testSavingsGoalProgressCalculatesRemainingAndPercentage() {
        let goal = SavingsGoal(
            name: "Vacaciones",
            targetAmount: 1000,
            currentAmount: 250,
            currency: "USD"
        )

        let progress = SavingsGoalViewModel.progress(for: [goal])

        XCTAssertEqual(progress.first?.remaining, 750)
        XCTAssertEqual(progress.first?.percentage, 0.25)
        XCTAssertEqual(progress.first?.percentageText, "25%")
    }

    func testBudgetAlertsIncludeOnlyExceededBudgets() {
        let date = Date()
        let budget = Budget(category: "Comida", amount: 1000, currency: "ARS", monthStart: date)
        let expenses = [
            Expense(amount: 1200, currency: "ARS", convertedAmount: 1200, baseCurrency: "ARS", date: date, category: "Comida"),
            Expense(amount: 5000, currency: "ARS", convertedAmount: 5000, baseCurrency: "ARS", date: date, category: "Ocio")
        ]

        let alerts = AdvancedFeaturesViewModel.budgetAlerts(
            budgets: [budget],
            expenses: expenses,
            month: MonthFilter(containing: date)
        )

        XCTAssertEqual(alerts.count, 1)
        XCTAssertEqual(alerts.first?.progress.budget.category, "Comida")
    }

    func testUnusualExpenseAlertsUseHistoricalAverageByCategoryAndCurrency() {
        let calendar = Calendar.current
        let currentDate = Date()
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let twoMonthsAgo = calendar.date(byAdding: .month, value: -2, to: currentDate)!
        let expenses = [
            Expense(amount: 100, currency: "ARS", convertedAmount: 100, baseCurrency: "ARS", date: previousMonth, category: "Comida"),
            Expense(amount: 120, currency: "ARS", convertedAmount: 120, baseCurrency: "ARS", date: twoMonthsAgo, category: "Comida"),
            Expense(amount: 300, currency: "ARS", convertedAmount: 300, baseCurrency: "ARS", date: currentDate, category: "Comida"),
            Expense(amount: 400, currency: "USD", convertedAmount: 400, baseCurrency: "USD", date: currentDate, category: "Comida")
        ]

        let alerts = AdvancedFeaturesViewModel.unusualExpenseAlerts(
            expenses: expenses,
            currentMonth: MonthFilter(containing: currentDate),
            multiplier: 2
        )

        XCTAssertEqual(alerts.count, 1)
        XCTAssertEqual(alerts.first?.expense.baseCurrency, "ARS")
        XCTAssertEqual(alerts.first?.averageAmount ?? 0, 110, accuracy: 0.001)
    }

    func testMonthlyComparisonSeparatesCurrentAndPreviousMonthByCurrency() {
        let calendar = Calendar.current
        let currentDate = Date()
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        let expenses = [
            Expense(amount: 500, currency: "ARS", convertedAmount: 500, baseCurrency: "ARS", date: currentDate, category: "Comida"),
            Expense(amount: 300, currency: "ARS", convertedAmount: 300, baseCurrency: "ARS", date: previousMonth, category: "Comida")
        ]
        let incomes = [
            Income(amount: 1000, currency: "ARS", convertedAmount: 1000, baseCurrency: "ARS", date: currentDate, category: "Sueldo"),
            Income(amount: 900, currency: "ARS", convertedAmount: 900, baseCurrency: "ARS", date: previousMonth, category: "Sueldo")
        ]

        let comparison = AdvancedFeaturesViewModel.monthlyComparison(
            expenses: expenses,
            incomes: incomes,
            month: MonthFilter(containing: currentDate)
        )

        XCTAssertEqual(comparison.count, 1)
        XCTAssertEqual(comparison.first?.currentMonthExpenseTotal, 500)
        XCTAssertEqual(comparison.first?.previousMonthExpenseTotal, 300)
        XCTAssertEqual(comparison.first?.currentMonthIncomeTotal, 1000)
        XCTAssertEqual(comparison.first?.previousMonthIncomeTotal, 900)
        XCTAssertEqual(comparison.first?.balanceDifference, -100)
    }
}

