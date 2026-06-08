import XCTest
@testable import expenses

final class AccountImpactServiceTests: XCTestCase {
    func testExpenseImpactReducesMatchingAccountBalanceAndCanBeReverted() {
        let account = Account(name: "Efectivo", type: .asset, category: "Efectivo", currency: "ARS", balance: 1000)
        let expense = Expense(
            amount: 250,
            currency: "ARS",
            date: Date(),
            category: "Comida",
            accountID: account.id
        )

        AccountImpactService.applyExpense(expense, to: [account])
        XCTAssertEqual(account.balance, 750)

        AccountImpactService.revertExpense(expense, in: [account])
        XCTAssertEqual(account.balance, 1000)
    }

    func testIncomeImpactIncreasesMatchingAccountBalanceAndCanBeReverted() {
        let account = Account(name: "Banco", type: .asset, category: "Cuenta bancaria", currency: "USD", balance: 100)
        let income = Income(
            amount: 50,
            currency: "USD",
            date: Date(),
            category: "Freelance",
            accountID: account.id
        )

        AccountImpactService.applyIncome(income, to: [account])
        XCTAssertEqual(account.balance, 150)

        AccountImpactService.revertIncome(income, in: [account])
        XCTAssertEqual(account.balance, 100)
    }

    func testImpactIgnoresPendingOrDifferentCurrencyMovements() {
        let account = Account(name: "Banco", type: .asset, category: "Cuenta bancaria", currency: "ARS", balance: 1000)
        let pendingExpense = Expense(
            amount: 200,
            currency: "ARS",
            date: Date(),
            category: "Comida",
            isConfirmed: false,
            accountID: account.id
        )
        let usdIncome = Income(
            amount: 50,
            currency: "USD",
            date: Date(),
            category: "Freelance",
            accountID: account.id
        )

        AccountImpactService.applyExpense(pendingExpense, to: [account])
        AccountImpactService.applyIncome(usdIncome, to: [account])

        XCTAssertEqual(account.balance, 1000)
    }
}
