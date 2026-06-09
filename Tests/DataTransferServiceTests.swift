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

    func testExcelExportIncludesExpenseAndIncomeWorksheets() {
        let expense = Expense(
            amount: 100,
            currency: "ARS",
            date: Date(timeIntervalSince1970: 1_800_000_000),
            category: "Servicios",
            expenseDescription: "Internet & hogar",
            paymentMethod: "Transferencia"
        )
        let income = Income(
            amount: 500,
            currency: "ARS",
            date: Date(timeIntervalSince1970: 1_800_000_100),
            category: "Freelance",
            incomeDescription: "Proyecto <A>"
        )

        let excel = DataTransferService.exportMovementsExcel(expenses: [expense], incomes: [income])

        XCTAssertTrue(excel.contains("<?mso-application progid=\"Excel.Sheet\"?>"))
        XCTAssertTrue(excel.contains("<Worksheet ss:Name=\"Gastos\">"))
        XCTAssertTrue(excel.contains("<Worksheet ss:Name=\"Ingresos\">"))
        XCTAssertTrue(excel.contains("Internet &amp; hogar"))
        XCTAssertTrue(excel.contains("Proyecto &lt;A&gt;"))
    }

    func testBankCSVImportCreatesExpensesAndIncomesFromSignedAmounts() throws {
        let accountID = UUID()
        let account = Account(
            id: accountID,
            name: "Mercado Pago",
            type: .asset,
            category: "Billetera virtual",
            currency: "ARS",
            balance: 1000
        )
        let csv = """
        date,description,amount,currency,category,paymentMethod,note,accountName,isConfirmed
        2026-06-09T12:00:00Z,Cafe,-1200,ARS,Comida,Debito,Desayuno,Mercado Pago,true
        2026-06-09T13:00:00Z,Transferencia,5000,ARS,Otros,,Ingreso,Mercado Pago,false
        """

        let result = try DataTransferService.importBankCSV(csv, accounts: [account])

        XCTAssertEqual(result.expenses.count, 1)
        XCTAssertEqual(result.incomes.count, 1)
        XCTAssertEqual(result.expenses.first?.originalAmount, 1200)
        XCTAssertEqual(result.expenses.first?.category, "Comida")
        XCTAssertEqual(result.expenses.first?.paymentMethod, "Debito")
        XCTAssertEqual(result.expenses.first?.accountID, accountID)
        XCTAssertEqual(result.incomes.first?.originalAmount, 5000)
        XCTAssertEqual(result.incomes.first?.incomeDescription, "Transferencia")
        XCTAssertEqual(result.incomes.first?.isConfirmed, false)
        XCTAssertEqual(result.incomes.first?.accountID, accountID)
    }

    func testBankCSVImportRejectsZeroAmounts() {
        let csv = """
        date,description,amount,currency,category,paymentMethod,note,accountName,isConfirmed
        2026-06-09T12:00:00Z,Ajuste,0,ARS,Otros,,,Mercado Pago,true
        """

        XCTAssertThrowsError(try DataTransferService.importBankCSV(csv))
    }

    func testMovementsJSONExportPreservesExpensesAndIncomes() throws {
        let accountID = UUID()
        let expense = Expense(
            amount: 100,
            currency: "USD",
            convertedAmount: 140000,
            baseCurrency: "ARS",
            date: Date(timeIntervalSince1970: 1_800_000_000),
            category: "Servicios",
            expenseDescription: "Internet",
            paymentMethod: "Transferencia",
            tags: ["hogar"],
            isConfirmed: false,
            accountID: accountID
        )
        let income = Income(
            amount: 500,
            currency: "EUR",
            convertedAmount: 800000,
            baseCurrency: "ARS",
            date: Date(timeIntervalSince1970: 1_800_000_100),
            category: "Freelance",
            incomeDescription: "Proyecto",
            note: "Cliente A",
            accountID: accountID
        )

        let export = DataTransferService.makeMovementsJSONExport(expenses: [expense], incomes: [income])
        let encoded = try DataTransferService.encodeMovementsJSONExport(export)
        let decoded = try JSONDecoder.iso8601.decode(MovementJSONExport.self, from: Data(encoded.utf8))

        XCTAssertEqual(decoded.version, 1)
        XCTAssertEqual(decoded.expenses.count, 1)
        XCTAssertEqual(decoded.incomes.count, 1)
        XCTAssertEqual(decoded.expenses.first?.originalCurrency, "USD")
        XCTAssertEqual(decoded.expenses.first?.paymentMethod, "Transferencia")
        XCTAssertEqual(decoded.expenses.first?.isConfirmed, false)
        XCTAssertEqual(decoded.incomes.first?.originalCurrency, "EUR")
        XCTAssertEqual(decoded.incomes.first?.incomeDescription, "Proyecto")
        XCTAssertEqual(decoded.incomes.first?.accountID, accountID)
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
            ],
            savingsGoals: [
                SavingsGoal(name: "Vacaciones", targetAmount: 1000, currentAmount: 250, currency: "USD")
            ],
            dailyReminderSettings: DailyReminderSettings(isEnabled: true, hour: 21, minute: 30)
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
        XCTAssertEqual(decoded.savingsGoals.count, 1)
        XCTAssertEqual(decoded.dailyReminderSettings?.isEnabled, true)
        XCTAssertEqual(decoded.dailyReminderSettings?.hour, 21)
        XCTAssertEqual(decoded.expenses.first?.accountID, accountID)
        XCTAssertEqual(decoded.incomes.first?.accountID, accountID)
        XCTAssertEqual(decoded.accounts.first?.id, accountID)
        XCTAssertEqual(DataTransferService.savingsGoals(from: decoded).first?.name, "Vacaciones")
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
        XCTAssertTrue(decoded.savingsGoals.isEmpty)
        XCTAssertNil(decoded.dailyReminderSettings)
    }
}

private extension JSONDecoder {
    static var iso8601: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }
}
