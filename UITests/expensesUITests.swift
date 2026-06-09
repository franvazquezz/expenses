import XCTest

@MainActor
final class expensesUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testDashboardLaunchesAndExpensesScreenIsReachable() {
        let app = launchApp()

        XCTAssertTrue(app.windows.firstMatch.waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["Dashboard"].waitForExistence(timeout: 5))

        openExpensesScreen(in: app)

        XCTAssertTrue(app.staticTexts["Gastos"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.staticTexts["Sin gastos"].waitForExistence(timeout: 3))
    }

    func testAddExpenseSheetOpensFromExpensesScreen() {
        let app = launchApp()

        openExpensesScreen(in: app)

        let addButton = firstExistingElement([
            app.descendants(matching: .any)["expenses.addButton"],
            app.descendants(matching: .any)["expenses.addToolbarButton"],
            app.buttons["Agregar"]
        ])
        XCTAssertTrue(addButton.waitForExistence(timeout: 3))
        addButton.click()

        XCTAssertTrue(app.staticTexts["Nuevo gasto"].waitForExistence(timeout: 3))
        XCTAssertTrue(app.descendants(matching: .any)["expenseForm.amountField"].waitForExistence(timeout: 3))
    }

    private func launchApp() -> XCUIApplication {
        let app = XCUIApplication()
        app.launchEnvironment["EXPENSES_UI_TESTING"] = "1"
        app.launch()
        return app
    }

    private func openExpensesScreen(in app: XCUIApplication) {
        let expensesNavigation = firstExistingElement([
            app.descendants(matching: .any)["navigation.expenses"],
            app.staticTexts["Gastos"],
            app.buttons["Gastos"]
        ])
        XCTAssertTrue(expensesNavigation.waitForExistence(timeout: 5))
        expensesNavigation.click()
    }

    private func firstExistingElement(_ elements: [XCUIElement]) -> XCUIElement {
        elements.first { $0.exists } ?? elements[0]
    }
}
