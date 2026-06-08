import XCTest
@testable import expenses

final class IncomeListViewModelTests: XCTestCase {
    func testFiltersByMonthCategorySearchCurrencyAndStatus() {
        let today = Date()
        let accountID = UUID()
        let matchingIncome = Income(
            amount: 100,
            currency: "USD",
            convertedAmount: 140000,
            baseCurrency: "ARS",
            date: today,
            category: "Freelance",
            incomeDescription: "Proyecto mobile",
            note: "Cliente A",
            isConfirmed: false,
            accountID: accountID
        )
        let otherIncome = Income(
            amount: 200,
            currency: "ARS",
            date: today,
            category: "Sueldo",
            incomeDescription: "Empresa"
        )

        let viewModel = IncomeListViewModel()
        viewModel.selectedMonth = MonthFilter(containing: today)
        viewModel.selectedCategory = "Freelance"
        viewModel.searchText = "mobile"
        viewModel.selectedCurrency = "USD"
        viewModel.selectedStatus = .pending
        viewModel.selectedAccountID = accountID

        let result = viewModel.filteredIncomes(from: [matchingIncome, otherIncome])

        XCTAssertEqual(result.map(\.incomeDescription), ["Proyecto mobile"])
    }

    func testResetFiltersRestoresDefaultValues() {
        let viewModel = IncomeListViewModel()
        viewModel.searchText = "abc"
        viewModel.selectedCategory = "Freelance"
        viewModel.selectedCurrency = "USD"
        viewModel.selectedStatus = .pending
        viewModel.selectedAccountID = UUID()

        viewModel.resetFilters()

        XCTAssertTrue(viewModel.searchText.isEmpty)
        XCTAssertEqual(viewModel.selectedCategory, "Todas")
        XCTAssertEqual(viewModel.selectedCurrency, "Todas")
        XCTAssertEqual(viewModel.selectedStatus, .all)
        XCTAssertNil(viewModel.selectedAccountID)
    }
}
