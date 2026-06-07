import XCTest
@testable import expenses

final class ExpenseFormViewModelTests: XCTestCase {
    func testParsesCommaDecimalAmountAndCreatesExpense() {
        let viewModel = ExpenseFormViewModel()
        viewModel.amountText = "123,45"
        viewModel.currency = "ARS"
        viewModel.category = "Comida"
        viewModel.expenseDescription = "Almuerzo"
        viewModel.note = "  menu ejecutivo  "
        viewModel.paymentMethod = "Efectivo"
        viewModel.tagsText = " trabajo, comida,  "

        let expense = viewModel.makeExpense()

        XCTAssertEqual(expense?.amount, 123.45)
        XCTAssertEqual(expense?.currency, "ARS")
        XCTAssertEqual(expense?.category, "Comida")
        XCTAssertEqual(expense?.expenseDescription, "Almuerzo")
        XCTAssertEqual(expense?.note, "menu ejecutivo")
        XCTAssertEqual(expense?.paymentMethod, "Efectivo")
        XCTAssertEqual(expense?.tags, ["trabajo", "comida"])
    }

    func testRejectsZeroOrInvalidAmounts() {
        let viewModel = ExpenseFormViewModel()

        viewModel.amountText = "0"
        XCTAssertFalse(viewModel.canSave)

        viewModel.amountText = "abc"
        XCTAssertFalse(viewModel.canSave)

        viewModel.amountText = "10"
        XCTAssertTrue(viewModel.canSave)
    }

    func testUpdatesExistingExpense() {
        let expense = Expense(amount: 20, currency: "USD", date: Date(), category: "Otros")
        let viewModel = ExpenseFormViewModel(expense: expense)

        viewModel.amountText = "30"
        viewModel.currency = "EUR"
        viewModel.category = "Transporte"
        viewModel.expenseDescription = "Taxi"
        viewModel.tagsText = "viaje"
        viewModel.update(expense)

        XCTAssertEqual(expense.amount, 30)
        XCTAssertEqual(expense.currency, "EUR")
        XCTAssertEqual(expense.category, "Transporte")
        XCTAssertEqual(expense.expenseDescription, "Taxi")
        XCTAssertEqual(expense.tags, ["viaje"])
    }
}
