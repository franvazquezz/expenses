import XCTest
@testable import expenses

final class RecurringIncomeViewModelTests: XCTestCase {
    func testCreatesRecurringIncomeWithConvertedAmount() {
        let viewModel = RecurringIncomeViewModel()
        viewModel.name = "Sueldo"
        viewModel.amountText = "1000"
        viewModel.currency = "USD"
        viewModel.baseCurrency = "ARS"
        viewModel.category = "Sueldo"
        viewModel.incomeDescription = "Trabajo"
        viewModel.updateConversion(using: [
            ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400)
        ])

        let recurringIncome = viewModel.makeRecurringIncome()

        XCTAssertEqual(recurringIncome?.name, "Sueldo")
        XCTAssertEqual(recurringIncome?.originalAmount, 1000)
        XCTAssertEqual(recurringIncome?.originalCurrency, "USD")
        XCTAssertEqual(recurringIncome?.convertedAmount, 1400000)
        XCTAssertEqual(recurringIncome?.baseCurrency, "ARS")
        XCTAssertEqual(recurringIncome?.category, "Sueldo")
        XCTAssertEqual(recurringIncome?.incomeDescription, "Trabajo")
    }

    func testGeneratesDueIncomesAndAdvancesNextRunDate() {
        let calendar = Calendar(identifier: .gregorian)
        let startDate = DateComponents(calendar: calendar, year: 2026, month: 1, day: 5).date!
        let today = DateComponents(calendar: calendar, year: 2026, month: 3, day: 10).date!
        let recurringIncome = RecurringIncome(
            name: "Sueldo",
            amount: 1000,
            currency: "USD",
            convertedAmount: 1400000,
            baseCurrency: "ARS",
            category: "Sueldo",
            period: .monthly,
            startDate: startDate,
            nextRunDate: startDate
        )

        let result = RecurringIncomeViewModel.generatedIncomes(
            for: recurringIncome,
            through: today,
            calendar: calendar
        )

        XCTAssertEqual(result.createdIncomes.count, 3)
        XCTAssertEqual(result.createdIncomes.first?.incomeDescription, "Sueldo")
        XCTAssertEqual(result.createdIncomes.first?.convertedAmount, 1400000)
        XCTAssertEqual(result.createdIncomes.first?.isConfirmed, false)
        XCTAssertEqual(result.nextRunDate, DateComponents(calendar: calendar, year: 2026, month: 4, day: 5).date)
    }

    func testInactiveRecurringIncomeDoesNotGenerateIncomes() {
        let recurringIncome = RecurringIncome(
            name: "Freelance",
            amount: 500,
            category: "Freelance",
            isActive: false
        )

        let result = RecurringIncomeViewModel.generatedIncomes(for: recurringIncome)

        XCTAssertTrue(result.createdIncomes.isEmpty)
        XCTAssertEqual(result.nextRunDate, recurringIncome.nextRunDate)
    }
}
