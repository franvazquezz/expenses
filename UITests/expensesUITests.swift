import XCTest

@MainActor
final class expensesUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDashboardLaunchesAndExpensesScreenIsReachable() {
        let app = launchApp()

        XCTAssertTrue(app.staticTexts["Dashboard"].waitForExistence(timeout: 5))

        openExpensesScreen(in: app)

        XCTAssertTrue(app.staticTexts["Gastos"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Sin gastos"].waitForExistence(timeout: 3))
    }

    func testAddExpenseSheetOpensFromExpensesScreen() {
        let app = launchApp()

        openExpensesScreen(in: app)

        let addButton = firstExistingElement(waitingFor: [
            app.descendants(matching: .any)["expenses.addButton"],
            app.descendants(matching: .any)["expenses.addToolbarButton"],
            app.buttons["Agregar"]
        ], timeout: 3)
        XCTAssertTrue(addButton.exists)
        addButton.click()

        XCTAssertTrue(app.staticTexts["Nuevo gasto"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["expenseForm.amountField"].waitForExistence(timeout: 3))
    }

    func testPrimaryNavigationScreensAreReachable() {
        let app = launchApp()

        assertNavigation(identifier: "navigation.incomes", label: "Ingresos", opens: "screen.incomes", in: app)
        assertNavigation(identifier: "navigation.currencies", label: "Monedas", opens: "screen.currencies", in: app)
        assertNavigation(identifier: "navigation.budgets", label: "Presupuestos", opens: "screen.budgets", in: app)
        assertNavigation(identifier: "navigation.netWorth", label: "Patrimonio", opens: "screen.netWorth", in: app)
        assertNavigation(identifier: "navigation.advanced", label: "Avanzadas", opens: "screen.advanced", in: app)
        assertNavigation(identifier: "navigation.data", label: "Datos", opens: "screen.data", in: app)
        assertNavigation(identifier: "navigation.recurringExpenses", label: "Gastos recurrentes", opens: "screen.recurringExpenses", in: app)
        assertNavigation(identifier: "navigation.recurringIncomes", label: "Ingresos recurrentes", opens: "screen.recurringIncomes", in: app)
        assertNavigation(identifier: "navigation.sync", label: "Sincronizacion", opens: "screen.sync", in: app)
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["EXPENSES_UI_TESTING"] = "1"
        app.launch()
        app.activate()
        app.typeKey("n", modifierFlags: .command)
        return app
    }

    private func openExpensesScreen(in app: XCUIApplication) {
        let expensesNavigation = firstExistingElement(waitingFor: [
            app.descendants(matching: .any)["navigation.expenses"],
            app.buttons["Gastos"],
            app.staticTexts["Gastos"]
        ], timeout: 5)
        XCTAssertTrue(expensesNavigation.exists)
        expensesNavigation.click()
    }

    private func assertNavigation(identifier navigationIdentifier: String, label: String, opens screenIdentifier: String, in app: XCUIApplication) {
        let navigation = firstExistingElement(waitingFor: [
            app.descendants(matching: .any)[navigationIdentifier],
            app.buttons[label],
            app.staticTexts[label]
        ], timeout: 5)
        XCTAssertTrue(navigation.exists, "No se encontro \(navigationIdentifier)")
        navigation.click()

        let screen = app.descendants(matching: .any)[screenIdentifier]
        XCTAssertTrue(screen.waitForExistence(timeout: 5), "No se abrio \(screenIdentifier)")
    }

    private func firstExistingElement(waitingFor elements: [XCUIElement], timeout: TimeInterval) -> XCUIElement {
        let deadline = Date().addingTimeInterval(timeout)

        repeat {
            if let element = elements.first(where: \.exists) {
                return element
            }

            RunLoop.current.run(until: Date().addingTimeInterval(0.1))
        } while Date() < deadline

        return elements[0]
    }
}
