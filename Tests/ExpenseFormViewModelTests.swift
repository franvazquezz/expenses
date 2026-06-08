import XCTest
@testable import expenses

final class ExpenseFormViewModelTests: XCTestCase {
    func testParsesCommaDecimalAmountAndCreatesExpense() {
        let viewModel = ExpenseFormViewModel()
        viewModel.amountText = "123,45"
        viewModel.currency = "ARS"
        viewModel.baseCurrency = "ARS"
        viewModel.updateConversion(using: [])
        viewModel.category = "Comida"
        viewModel.expenseDescription = "Almuerzo"
        viewModel.note = "  menu ejecutivo  "
        viewModel.paymentMethod = "Efectivo"
        viewModel.tagsText = " trabajo, comida,  "
        viewModel.accountID = UUID()

        let expense = viewModel.makeExpense()

        XCTAssertEqual(expense?.amount, 123.45)
        XCTAssertEqual(expense?.originalAmount, 123.45)
        XCTAssertEqual(expense?.originalCurrency, "ARS")
        XCTAssertEqual(expense?.convertedAmount, 123.45)
        XCTAssertEqual(expense?.baseCurrency, "ARS")
        XCTAssertEqual(expense?.category, "Comida")
        XCTAssertEqual(expense?.expenseDescription, "Almuerzo")
        XCTAssertEqual(expense?.note, "menu ejecutivo")
        XCTAssertEqual(expense?.paymentMethod, "Efectivo")
        XCTAssertEqual(expense?.tags, ["trabajo", "comida"])
        XCTAssertEqual(expense?.accountID, viewModel.accountID)
    }

    func testRejectsZeroOrInvalidAmounts() {
        let viewModel = ExpenseFormViewModel()

        viewModel.amountText = "0"
        XCTAssertFalse(viewModel.canSave)

        viewModel.amountText = "abc"
        XCTAssertFalse(viewModel.canSave)

        viewModel.amountText = "10"
        viewModel.baseCurrency = viewModel.currency
        viewModel.updateConversion(using: [])
        XCTAssertTrue(viewModel.canSave)
    }

    func testUpdatesExistingExpense() {
        let expense = Expense(amount: 20, currency: "USD", date: Date(), category: "Otros")
        let viewModel = ExpenseFormViewModel(expense: expense)

        viewModel.amountText = "30"
        viewModel.currency = "EUR"
        viewModel.baseCurrency = "ARS"
        viewModel.updateConversion(using: [ExchangeRate(fromCurrency: "EUR", toCurrency: "ARS", rate: 1600)])
        viewModel.category = "Transporte"
        viewModel.expenseDescription = "Taxi"
        viewModel.tagsText = "viaje"
        viewModel.update(expense)

        XCTAssertEqual(expense.originalAmount, 30)
        XCTAssertEqual(expense.originalCurrency, "EUR")
        XCTAssertEqual(expense.convertedAmount, 48000)
        XCTAssertEqual(expense.baseCurrency, "ARS")
        XCTAssertEqual(expense.category, "Transporte")
        XCTAssertEqual(expense.expenseDescription, "Taxi")
        XCTAssertEqual(expense.tags, ["viaje"])
    }

    func testCalculatesConvertedAmountUsingManualExchangeRate() {
        let viewModel = ExpenseFormViewModel()
        viewModel.amountText = "100"
        viewModel.currency = "USD"
        viewModel.baseCurrency = "ARS"

        viewModel.updateConversion(using: [
            ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400)
        ])

        XCTAssertEqual(viewModel.parsedConvertedAmount, 140000)
    }

    func testCalculatesConvertedAmountUsingInverseRate() {
        let viewModel = ExpenseFormViewModel()
        viewModel.amountText = "140000"
        viewModel.currency = "ARS"
        viewModel.baseCurrency = "USD"

        viewModel.updateConversion(using: [
            ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400)
        ])

        XCTAssertEqual(viewModel.parsedConvertedAmount, 100)
    }
}
