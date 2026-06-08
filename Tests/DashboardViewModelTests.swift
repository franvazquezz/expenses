import XCTest
@testable import expenses

final class DashboardViewModelTests: XCTestCase {
    func testTotalsAreGroupedByCurrency() {
        let viewModel = DashboardViewModel()
        let today = Date()
        let expenses = [
            Expense(amount: 100, currency: "USD", convertedAmount: 140000, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 50, currency: "ARS", convertedAmount: 50, baseCurrency: "ARS", date: today, category: "Transporte"),
            Expense(amount: 10, currency: "EUR", convertedAmount: 16000, baseCurrency: "ARS", date: today, category: "Ocio")
        ]

        let totals = viewModel.totalsThisMonth(from: expenses)

        XCTAssertEqual(totals.first { $0.currency == "ARS" }?.total, 156050)
    }

    func testLatestExpensesAreSortedByDateDescending() {
        let viewModel = DashboardViewModel()
        let calendar = Calendar.current
        let older = Expense(amount: 10, currency: "USD", date: calendar.date(byAdding: .day, value: -2, to: Date())!, category: "Comida")
        let newer = Expense(amount: 20, currency: "USD", date: Date(), category: "Comida")

        let latest = viewModel.latestExpenses(from: [older, newer])

        XCTAssertEqual(latest.first?.amount, 20)
    }

    func testTopCategoriesGroupsByCategoryAndCurrency() {
        let viewModel = DashboardViewModel()
        let today = Date()
        let expenses = [
            Expense(amount: 100, currency: "USD", convertedAmount: 140000, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 40, currency: "ARS", convertedAmount: 40, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 20, currency: "EUR", convertedAmount: 32000, baseCurrency: "ARS", date: today, category: "Comida")
        ]

        let categories = viewModel.topCategories(from: expenses)

        XCTAssertEqual(categories.first?.category, "Comida")
        XCTAssertEqual(categories.first?.currency, "ARS")
        XCTAssertEqual(categories.first?.total, 172040)
    }

    func testBalanceSubtractsExpensesFromIncomesByBaseCurrency() {
        let viewModel = DashboardViewModel()
        let today = Date()
        let incomes = [
            Income(amount: 1000, currency: "USD", convertedAmount: 1400000, baseCurrency: "ARS", date: today, category: "Sueldo")
        ]
        let expenses = [
            Expense(amount: 100, currency: "USD", convertedAmount: 140000, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 50000, currency: "ARS", convertedAmount: 50000, baseCurrency: "ARS", date: today, category: "Servicios")
        ]

        let balance = viewModel.balanceThisMonth(expenses: expenses, incomes: incomes)

        XCTAssertEqual(balance.first { $0.currency == "ARS" }?.total, 1210000)
    }

    func testDashboardIgnoresPendingMovementsInTotals() {
        let viewModel = DashboardViewModel()
        let today = Date()
        let incomes = [
            Income(amount: 1000, currency: "ARS", convertedAmount: 1000, baseCurrency: "ARS", date: today, category: "Sueldo"),
            Income(amount: 500, currency: "ARS", convertedAmount: 500, baseCurrency: "ARS", date: today, category: "Sueldo", isConfirmed: false)
        ]
        let expenses = [
            Expense(amount: 100, currency: "ARS", convertedAmount: 100, baseCurrency: "ARS", date: today, category: "Comida"),
            Expense(amount: 50, currency: "ARS", convertedAmount: 50, baseCurrency: "ARS", date: today, category: "Comida", isConfirmed: false)
        ]

        let balance = viewModel.balanceThisMonth(expenses: expenses, incomes: incomes)

        XCTAssertEqual(viewModel.expenseTotalsThisMonth(from: expenses).first { $0.currency == "ARS" }?.total, 100)
        XCTAssertEqual(viewModel.incomeTotalsThisMonth(from: incomes).first { $0.currency == "ARS" }?.total, 1000)
        XCTAssertEqual(balance.first { $0.currency == "ARS" }?.total, 900)
    }

    func testMonthlyMovementTotalsGroupByMonthAndCurrency() {
        let viewModel = DashboardViewModel()
        let calendar = Calendar.current
        let currentMonth = Date()
        let previousMonth = calendar.date(byAdding: .month, value: -1, to: currentMonth)!
        let incomes = [
            Income(amount: 1000, currency: "ARS", convertedAmount: 1000, baseCurrency: "ARS", date: previousMonth, category: "Sueldo"),
            Income(amount: 2000, currency: "ARS", convertedAmount: 2000, baseCurrency: "ARS", date: currentMonth, category: "Sueldo")
        ]
        let expenses = [
            Expense(amount: 300, currency: "ARS", convertedAmount: 300, baseCurrency: "ARS", date: previousMonth, category: "Comida"),
            Expense(amount: 500, currency: "ARS", convertedAmount: 500, baseCurrency: "ARS", date: currentMonth, category: "Comida")
        ]

        let totals = viewModel.monthlyMovementTotals(expenses: expenses, incomes: incomes, monthsBack: 2)

        XCTAssertEqual(totals.count, 2)
        XCTAssertEqual(totals.first?.expenseTotal, 300)
        XCTAssertEqual(totals.first?.incomeTotal, 1000)
        XCTAssertEqual(totals.first?.balance, 700)
        XCTAssertEqual(totals.last?.expenseTotal, 500)
        XCTAssertEqual(totals.last?.incomeTotal, 2000)
        XCTAssertEqual(totals.last?.balance, 1500)
    }

    func testPaymentMethodTotalsGroupByMethodAndCurrency() {
        let viewModel = DashboardViewModel()
        let today = Date()
        let expenses = [
            Expense(amount: 100, currency: "ARS", convertedAmount: 100, baseCurrency: "ARS", date: today, category: "Comida", paymentMethod: "Efectivo"),
            Expense(amount: 50, currency: "ARS", convertedAmount: 50, baseCurrency: "ARS", date: today, category: "Transporte", paymentMethod: "Efectivo"),
            Expense(amount: 20, currency: "USD", convertedAmount: 28000, baseCurrency: "ARS", date: today, category: "Ocio", paymentMethod: "Tarjeta")
        ]

        let totals = viewModel.paymentMethodTotals(from: expenses)

        XCTAssertEqual(totals.first { $0.paymentMethod == "Efectivo" }?.total, 150)
        XCTAssertEqual(totals.first { $0.paymentMethod == "Tarjeta" }?.total, 28000)
        XCTAssertEqual(totals.first { $0.paymentMethod == "Tarjeta" }?.currency, "ARS")
    }
}
