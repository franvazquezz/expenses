import XCTest
@testable import expenses

final class ExpenseListViewModelTests: XCTestCase {
    func testFiltersByMonthAndCategory() {
        let calendar = Calendar.current
        let today = Date()
        let lastMonth = calendar.date(byAdding: .month, value: -1, to: today)!
        let food = Expense(amount: 10, currency: "USD", date: today, category: "Comida")
        let transport = Expense(amount: 20, currency: "USD", date: today, category: "Transporte")
        let oldFood = Expense(amount: 30, currency: "USD", date: lastMonth, category: "Comida")

        let viewModel = ExpenseListViewModel()
        viewModel.selectedMonth = MonthFilter(containing: today)
        viewModel.selectedCategory = "Comida"

        let result = viewModel.filteredExpenses(from: [food, transport, oldFood])

        XCTAssertEqual(result.map(\.amount), [10])
    }

    func testFiltersBySearchTagCurrencyPaymentMethodAndStatus() {
        let today = Date()
        let accountID = UUID()
        let matchingExpense = Expense(
            amount: 10,
            currency: "USD",
            convertedAmount: 14000,
            baseCurrency: "ARS",
            date: today,
            category: "Servicios",
            expenseDescription: "Internet casa",
            note: "Factura mensual",
            paymentMethod: "Transferencia",
            tags: ["hogar"],
            isConfirmed: false,
            accountID: accountID
        )
        let otherExpense = Expense(
            amount: 20,
            currency: "ARS",
            date: today,
            category: "Comida",
            expenseDescription: "Supermercado",
            paymentMethod: "Efectivo",
            tags: ["compras"]
        )

        let viewModel = ExpenseListViewModel()
        viewModel.selectedMonth = MonthFilter(containing: today)
        viewModel.searchText = "internet"
        viewModel.selectedTag = "hogar"
        viewModel.selectedCurrency = "USD"
        viewModel.selectedPaymentMethod = "Transferencia"
        viewModel.selectedStatus = .pending
        viewModel.selectedAccountID = accountID

        let result = viewModel.filteredExpenses(from: [matchingExpense, otherExpense])

        XCTAssertEqual(result.map(\.expenseDescription), ["Internet casa"])
    }

    func testDuplicatesExpenseWithoutSharingIdentity() {
        let source = Expense(
            amount: 42,
            currency: "ARS",
            date: Date(),
            category: "Servicios",
            expenseDescription: "Internet",
            note: "Casa",
            paymentMethod: "Transferencia",
            tags: ["hogar"]
        )

        let duplicate = ExpenseListViewModel().duplicate(source)

        XCTAssertFalse(duplicate === source)
        XCTAssertEqual(duplicate.amount, source.amount)
        XCTAssertEqual(duplicate.originalCurrency, source.originalCurrency)
        XCTAssertEqual(duplicate.convertedAmount, source.convertedAmount)
        XCTAssertEqual(duplicate.baseCurrency, source.baseCurrency)
        XCTAssertEqual(duplicate.category, source.category)
        XCTAssertEqual(duplicate.expenseDescription, source.expenseDescription)
        XCTAssertEqual(duplicate.note, source.note)
        XCTAssertEqual(duplicate.paymentMethod, source.paymentMethod)
        XCTAssertEqual(duplicate.tags, source.tags)
        XCTAssertEqual(duplicate.accountID, source.accountID)
    }
}
