import XCTest
@testable import expenses

final class AccountViewModelTests: XCTestCase {
    func testSummaryTotalsCalculatesAssetsLiabilitiesAndNetWorthByCurrency() {
        let accounts = [
            Account(name: "Efectivo", type: .asset, category: "Efectivo", currency: "ARS", balance: 100000),
            Account(name: "Banco", type: .asset, category: "Cuenta bancaria", currency: "ARS", balance: 300000),
            Account(name: "Tarjeta", type: .liability, category: "Tarjeta de credito", currency: "ARS", balance: 120000),
            Account(name: "Broker", type: .asset, category: "Inversion", currency: "USD", balance: 1000)
        ]

        let totals = AccountViewModel.summaryTotals(from: accounts)
        let arsTotal = totals.first { $0.currency == "ARS" }
        let usdTotal = totals.first { $0.currency == "USD" }

        XCTAssertEqual(arsTotal?.assets, 400000)
        XCTAssertEqual(arsTotal?.liabilities, 120000)
        XCTAssertEqual(arsTotal?.netWorth, 280000)
        XCTAssertEqual(usdTotal?.assets, 1000)
        XCTAssertEqual(usdTotal?.liabilities, 0)
        XCTAssertEqual(usdTotal?.netWorth, 1000)
    }

    func testSummaryTotalsIgnoresInactiveAccountsByDefault() {
        let accounts = [
            Account(name: "Activo", type: .asset, category: "Efectivo", currency: "ARS", balance: 100000),
            Account(name: "Inactivo", type: .asset, category: "Efectivo", currency: "ARS", balance: 50000, isActive: false)
        ]

        let activeOnly = AccountViewModel.summaryTotals(from: accounts)
        let includingInactive = AccountViewModel.summaryTotals(from: accounts, includeInactive: true)

        XCTAssertEqual(activeOnly.first?.assets, 100000)
        XCTAssertEqual(includingInactive.first?.assets, 150000)
    }

    func testMakeAccountRequiresNameAmountCategoryAndCurrency() {
        let viewModel = AccountViewModel()

        viewModel.name = "Mercado Pago"
        viewModel.type = .asset
        viewModel.category = "Billetera virtual"
        viewModel.currency = "ARS"
        viewModel.balanceText = "25000,50"

        let account = viewModel.makeAccount()

        XCTAssertTrue(viewModel.canSave)
        XCTAssertEqual(account?.name, "Mercado Pago")
        XCTAssertEqual(account?.balance ?? 0, 25000.50, accuracy: 0.001)
        XCTAssertEqual(account?.type, .asset)
    }

    func testUpdateRefreshesAccountFields() {
        let account = Account(name: "Vieja", type: .asset, category: "Efectivo", currency: "ARS", balance: 100)
        let viewModel = AccountViewModel(account: account)

        viewModel.name = "Visa"
        viewModel.institution = "Banco"
        viewModel.type = .liability
        viewModel.category = "Tarjeta de credito"
        viewModel.currency = "USD"
        viewModel.balanceText = "50"
        viewModel.note = "Cierre mensual"
        viewModel.isActive = false
        viewModel.update(account)

        XCTAssertEqual(account.name, "Visa")
        XCTAssertEqual(account.institution, "Banco")
        XCTAssertEqual(account.type, .liability)
        XCTAssertEqual(account.category, "Tarjeta de credito")
        XCTAssertEqual(account.currency, "USD")
        XCTAssertEqual(account.balance, 50)
        XCTAssertEqual(account.note, "Cierre mensual")
        XCTAssertFalse(account.isActive)
    }

    func testMovementSummariesCalculateIncomeExpensesAndNetFlowByAccount() {
        let account = Account(name: "Banco", type: .asset, category: "Cuenta bancaria", currency: "ARS", balance: 100000)
        let expense = Expense(amount: 20000, currency: "ARS", date: Date(), category: "Comida", accountID: account.id)
        let income = Income(amount: 50000, currency: "ARS", date: Date(), category: "Sueldo", accountID: account.id)

        let summaries = AccountViewModel.movementSummaries(
            accounts: [account],
            expenses: [expense],
            incomes: [income]
        )

        XCTAssertEqual(summaries.first?.expenseTotal, 20000)
        XCTAssertEqual(summaries.first?.incomeTotal, 50000)
        XCTAssertEqual(summaries.first?.netFlow, 30000)
    }

    func testMovementSummariesIgnorePendingDifferentCurrencyAndUnassignedMovements() {
        let account = Account(name: "Banco", type: .asset, category: "Cuenta bancaria", currency: "ARS", balance: 100000)
        let pendingExpense = Expense(
            amount: 20000,
            currency: "ARS",
            date: Date(),
            category: "Comida",
            isConfirmed: false,
            accountID: account.id
        )
        let usdExpense = Expense(amount: 10, currency: "USD", date: Date(), category: "Comida", accountID: account.id)
        let unassignedIncome = Income(amount: 50000, currency: "ARS", date: Date(), category: "Sueldo")

        let summaries = AccountViewModel.movementSummaries(
            accounts: [account],
            expenses: [pendingExpense, usdExpense],
            incomes: [unassignedIncome]
        )

        XCTAssertEqual(summaries.first?.expenseTotal, 0)
        XCTAssertEqual(summaries.first?.incomeTotal, 0)
        XCTAssertEqual(summaries.first?.netFlow, 0)
    }

    func testBaseCurrencyNetWorthConvertsWithManualRatesAndSubtractsLiabilities() {
        let accounts = [
            Account(name: "Efectivo", type: .asset, category: "Efectivo", currency: "ARS", balance: 100000),
            Account(name: "Broker", type: .asset, category: "Inversion", currency: "USD", balance: 100),
            Account(name: "Tarjeta", type: .liability, category: "Tarjeta de credito", currency: "USD", balance: 20)
        ]
        let rates = [
            ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400)
        ]

        let result = AccountViewModel.baseCurrencyNetWorth(
            accounts: accounts,
            baseCurrency: "ARS",
            rates: rates
        )

        XCTAssertEqual(result.total, 212000)
        XCTAssertTrue(result.missingCurrencies.isEmpty)
    }

    func testBaseCurrencyNetWorthReportsMissingCurrenciesWithoutSummingThem() {
        let accounts = [
            Account(name: "Efectivo", type: .asset, category: "Efectivo", currency: "ARS", balance: 100000),
            Account(name: "Euro", type: .asset, category: "Inversion", currency: "EUR", balance: 100)
        ]

        let result = AccountViewModel.baseCurrencyNetWorth(
            accounts: accounts,
            baseCurrency: "ARS",
            rates: []
        )

        XCTAssertEqual(result.total, 100000)
        XCTAssertEqual(result.missingCurrencies, ["EUR"])
    }
}
