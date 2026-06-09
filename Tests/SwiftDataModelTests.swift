import SwiftData
import XCTest
@testable import expenses

final class SwiftDataModelTests: XCTestCase {
    @MainActor
    func testCurrentSchemaCreatesInMemoryContainer() throws {
        let container = try makeContainer()

        XCTAssertNotNil(container.mainContext)
    }

    @MainActor
    func testCurrentSchemaPersistsCoreModelsInMemory() throws {
        let container = try makeContainer()
        let context = container.mainContext

        context.insert(Currency(code: "ARS", name: "Peso Argentino", symbol: "$", isDefault: true))
        context.insert(ExchangeRate(fromCurrency: "USD", toCurrency: "ARS", rate: 1400))
        context.insert(Expense(amount: 100, currency: "ARS", date: Date(), category: "Comida"))
        context.insert(Income(amount: 200, currency: "ARS", date: Date(), category: "Sueldo"))
        context.insert(Budget(category: "Comida", amount: 300, currency: "ARS"))
        context.insert(RecurringExpense(name: "Internet", amount: 100, category: "Servicios"))
        context.insert(RecurringIncome(name: "Sueldo", amount: 1000, category: "Sueldo"))
        context.insert(Account(name: "Efectivo", type: .asset, category: "Efectivo", currency: "ARS", balance: 500))
        context.insert(SavingsGoal(name: "Vacaciones", targetAmount: 1000, currentAmount: 250, currency: "USD"))
        context.insert(DailyReminderSettings(isEnabled: true, hour: 21, minute: 30))

        try context.save()

        XCTAssertEqual(try context.fetch(FetchDescriptor<Currency>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<ExchangeRate>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Expense>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Income>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Budget>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RecurringExpense>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<RecurringIncome>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<Account>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<SavingsGoal>()).count, 1)
        XCTAssertEqual(try context.fetch(FetchDescriptor<DailyReminderSettings>()).count, 1)
    }

    private func makeContainer() throws -> ModelContainer {
        let schema = Schema([
            Expense.self,
            Income.self,
            Currency.self,
            ExchangeRate.self,
            Budget.self,
            RecurringExpense.self,
            RecurringIncome.self,
            Account.self,
            SavingsGoal.self,
            DailyReminderSettings.self
        ])
        let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)

        return try ModelContainer(for: schema, configurations: [configuration])
    }
}
