import XCTest
@testable import expenses

final class RecurringExpenseViewModelTests: XCTestCase {
    func testNextRunDateAdvancesByPeriod() {
        let calendar = Calendar(identifier: .gregorian)
        let date = DateComponents(calendar: calendar, year: 2026, month: 6, day: 7).date!

        XCTAssertEqual(
            RecurringExpenseViewModel.nextRunDate(after: date, period: .weekly, calendar: calendar),
            DateComponents(calendar: calendar, year: 2026, month: 6, day: 14).date
        )
        XCTAssertEqual(
            RecurringExpenseViewModel.nextRunDate(after: date, period: .monthly, calendar: calendar),
            DateComponents(calendar: calendar, year: 2026, month: 7, day: 7).date
        )
        XCTAssertEqual(
            RecurringExpenseViewModel.nextRunDate(after: date, period: .yearly, calendar: calendar),
            DateComponents(calendar: calendar, year: 2027, month: 6, day: 7).date
        )
    }

    func testGeneratesDueExpensesAndAdvancesNextRunDate() {
        let calendar = Calendar(identifier: .gregorian)
        let startDate = DateComponents(calendar: calendar, year: 2026, month: 1, day: 1).date!
        let today = DateComponents(calendar: calendar, year: 2026, month: 3, day: 10).date!
        let recurringExpense = RecurringExpense(
            name: "Netflix",
            amount: 100,
            currency: "USD",
            convertedAmount: 140000,
            baseCurrency: "ARS",
            category: "Ocio",
            period: .monthly,
            startDate: startDate,
            nextRunDate: startDate
        )

        let result = RecurringExpenseViewModel.generatedExpenses(
            for: recurringExpense,
            through: today,
            calendar: calendar
        )

        XCTAssertEqual(result.createdExpenses.count, 3)
        XCTAssertEqual(result.createdExpenses.first?.expenseDescription, "Netflix")
        XCTAssertEqual(result.createdExpenses.first?.convertedAmount, 140000)
        XCTAssertEqual(result.nextRunDate, DateComponents(calendar: calendar, year: 2026, month: 4, day: 1).date)
    }

    func testInactiveRecurringExpenseDoesNotGenerateExpenses() {
        let recurringExpense = RecurringExpense(
            name: "Spotify",
            amount: 10,
            category: "Ocio",
            isActive: false
        )

        let result = RecurringExpenseViewModel.generatedExpenses(for: recurringExpense)

        XCTAssertTrue(result.createdExpenses.isEmpty)
        XCTAssertEqual(result.nextRunDate, recurringExpense.nextRunDate)
    }
}
