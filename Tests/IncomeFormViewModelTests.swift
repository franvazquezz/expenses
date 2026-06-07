import XCTest
@testable import expenses

final class IncomeFormViewModelTests: XCTestCase {
    func testCreatesIncomeWithConvertedAmount() {
        let viewModel = IncomeFormViewModel()
        viewModel.amountText = "100"
        viewModel.currency = "USD"
        viewModel.baseCurrency = "ARS"
        viewModel.category = "Freelance"
        viewModel.incomeDescription = "Proyecto"
        viewModel.updateConversion(using: [
            ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400)
        ])

        let income = viewModel.makeIncome()

        XCTAssertEqual(income?.originalAmount, 100)
        XCTAssertEqual(income?.originalCurrency, "USD")
        XCTAssertEqual(income?.convertedAmount, 140000)
        XCTAssertEqual(income?.baseCurrency, "ARS")
        XCTAssertEqual(income?.category, "Freelance")
        XCTAssertEqual(income?.incomeDescription, "Proyecto")
    }

    func testRejectsInvalidIncomeAmount() {
        let viewModel = IncomeFormViewModel()

        viewModel.amountText = "0"
        XCTAssertFalse(viewModel.canSave)

        viewModel.amountText = "abc"
        XCTAssertFalse(viewModel.canSave)
    }
}
