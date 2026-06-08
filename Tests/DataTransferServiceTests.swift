import XCTest
@testable import expenses

final class DataTransferServiceTests: XCTestCase {
    func testExpenseCSVRoundTripPreservesFields() throws {
        let expense = Expense(
            amount: 100,
            currency: "USD",
            convertedAmount: 140000,
            baseCurrency: "ARS",
            date: Date(timeIntervalSince1970: 1_800_000_000),
            category: "Servicios",
            expenseDescription: "Internet, casa",
            note: "Factura \"junio\"",
            paymentMethod: "Transferencia",
            tags: ["hogar", "internet"],
            isConfirmed: false
        )

        let csv = DataTransferService.exportExpensesCSV([expense])
        let imported = try DataTransferService.importExpensesCSV(csv)

        XCTAssertEqual(imported.count, 1)
        XCTAssertEqual(imported.first?.originalAmount, 100)
        XCTAssertEqual(imported.first?.originalCurrency, "USD")
        XCTAssertEqual(imported.first?.convertedAmount, 140000)
        XCTAssertEqual(imported.first?.baseCurrency, "ARS")
        XCTAssertEqual(imported.first?.category, "Servicios")
        XCTAssertEqual(imported.first?.expenseDescription, "Internet, casa")
        XCTAssertEqual(imported.first?.note, "Factura \"junio\"")
        XCTAssertEqual(imported.first?.paymentMethod, "Transferencia")
        XCTAssertEqual(imported.first?.tags, ["hogar", "internet"])
        XCTAssertEqual(imported.first?.isConfirmed, false)
    }

    func testIncomeCSVRoundTripPreservesFields() throws {
        let income = Income(
            amount: 500,
            currency: "EUR",
            convertedAmount: 800000,
            baseCurrency: "ARS",
            date: Date(timeIntervalSince1970: 1_800_000_000),
            category: "Freelance",
            incomeDescription: "Proyecto",
            note: "Cliente A"
        )

        let csv = DataTransferService.exportIncomesCSV([income])
        let imported = try DataTransferService.importIncomesCSV(csv)

        XCTAssertEqual(imported.count, 1)
        XCTAssertEqual(imported.first?.originalAmount, 500)
        XCTAssertEqual(imported.first?.originalCurrency, "EUR")
        XCTAssertEqual(imported.first?.convertedAmount, 800000)
        XCTAssertEqual(imported.first?.baseCurrency, "ARS")
        XCTAssertEqual(imported.first?.category, "Freelance")
        XCTAssertEqual(imported.first?.incomeDescription, "Proyecto")
        XCTAssertEqual(imported.first?.note, "Cliente A")
        XCTAssertEqual(imported.first?.isConfirmed, true)
    }

    func testImportRejectsInvalidCSVHeader() {
        XCTAssertThrowsError(try DataTransferService.importExpensesCSV("bad,header\n1,2"))
    }

    func testBackupRoundTripPreservesCounts() throws {
        let accountID = UUID()
        let backup = DataTransferService.makeBackup(
            expenses: [Expense(amount: 100, currency: "ARS", date: Date(), category: "Comida", accountID: accountID)],
            incomes: [Income(amount: 200, currency: "ARS", date: Date(), category: "Sueldo", accountID: accountID)],
            currencies: [Currency(code: "ARS", name: "Peso Argentino", symbol: "$", isDefault: true)],
            exchangeRates: [ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400)],
            budgets: [Budget(category: "Comida", amount: 300000, currency: "ARS")],
            recurringExpenses: [
                RecurringExpense(name: "Internet", amount: 10000, category: "Servicios")
            ],
            recurringIncomes: [
                RecurringIncome(name: "Sueldo", amount: 1000000, category: "Sueldo")
            ],
            accounts: [
                Account(id: accountID, name: "Mercado Pago", type: .asset, category: "Billetera virtual", currency: "ARS", balance: 50000)
            ]
        )

        let encoded = try DataTransferService.encodeBackup(backup)
        let decoded = try DataTransferService.decodeBackup(encoded)

        XCTAssertEqual(decoded.version, 1)
        XCTAssertEqual(decoded.expenses.count, 1)
        XCTAssertEqual(decoded.incomes.count, 1)
        XCTAssertEqual(decoded.currencies.count, 1)
        XCTAssertEqual(decoded.exchangeRates.count, 1)
        XCTAssertEqual(decoded.budgets.count, 1)
        XCTAssertEqual(decoded.recurringExpenses.count, 1)
        XCTAssertEqual(decoded.recurringIncomes.count, 1)
        XCTAssertEqual(decoded.accounts.count, 1)
        XCTAssertEqual(decoded.expenses.first?.accountID, accountID)
        XCTAssertEqual(decoded.incomes.first?.accountID, accountID)
        XCTAssertEqual(decoded.accounts.first?.id, accountID)
    }

    func testDecodingBackupWithoutAccountsKeepsBackwardCompatibility() throws {
        let backup = """
        {
          "version": 1,
          "createdAt": "2026-06-08T12:00:00Z",
          "expenses": [],
          "incomes": [],
          "currencies": [],
          "exchangeRates": [],
          "budgets": [],
          "recurringExpenses": [],
          "recurringIncomes": []
        }
        """

        let decoded = try DataTransferService.decodeBackup(backup)

        XCTAssertEqual(decoded.version, 1)
        XCTAssertTrue(decoded.accounts.isEmpty)
    }
}
