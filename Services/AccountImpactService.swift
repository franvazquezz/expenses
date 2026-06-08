import Foundation

enum AccountImpactService {
    static func accountName(for accountID: UUID?, in accounts: [Account]) -> String {
        guard let accountID,
              let account = accounts.first(where: { $0.id == accountID }) else {
            return "Sin cuenta"
        }

        return account.name
    }

    static func accountOptions(for accounts: [Account], currency: String) -> [Account] {
        accounts
            .filter { $0.isActive && $0.currency == currency }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    static func applyExpense(_ expense: Expense, to accounts: [Account]) {
        guard expense.isConfirmed,
              let account = account(for: expense.accountID, in: accounts),
              account.currency == expense.originalCurrency else {
            return
        }

        account.balance -= expense.originalAmount
        account.updatedAt = Date()
    }

    static func revertExpense(_ expense: Expense, in accounts: [Account]) {
        guard expense.isConfirmed,
              let account = account(for: expense.accountID, in: accounts),
              account.currency == expense.originalCurrency else {
            return
        }

        account.balance += expense.originalAmount
        account.updatedAt = Date()
    }

    static func applyIncome(_ income: Income, to accounts: [Account]) {
        guard income.isConfirmed,
              let account = account(for: income.accountID, in: accounts),
              account.currency == income.originalCurrency else {
            return
        }

        account.balance += income.originalAmount
        account.updatedAt = Date()
    }

    static func revertIncome(_ income: Income, in accounts: [Account]) {
        guard income.isConfirmed,
              let account = account(for: income.accountID, in: accounts),
              account.currency == income.originalCurrency else {
            return
        }

        account.balance -= income.originalAmount
        account.updatedAt = Date()
    }

    private static func account(for accountID: UUID?, in accounts: [Account]) -> Account? {
        guard let accountID else {
            return nil
        }

        return accounts.first { $0.id == accountID }
    }
}
