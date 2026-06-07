import Foundation

struct MoneyTotal: Identifiable {
    let currency: String
    let total: Double

    var id: String {
        currency
    }
}

struct CategoryTotal: Identifiable {
    let category: String
    let total: Double
    let currency: String

    var id: String {
        "\(category)-\(currency)"
    }
}

final class DashboardViewModel {
    private let calendar = Calendar.current

    func totalsThisMonth(from expenses: [Expense]) -> [MoneyTotal] {
        totalsByCurrency(
            from: expenses.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        )
    }

    func totalsThisYear(from expenses: [Expense]) -> [MoneyTotal] {
        totalsByCurrency(
            from: expenses.filter { calendar.isDate($0.date, equalTo: Date(), toGranularity: .year) }
        )
    }

    func todayExpenses(from expenses: [Expense]) -> [Expense] {
        expenses.filter { calendar.isDateInToday($0.date) }
    }

    func todayTotals(from expenses: [Expense]) -> [MoneyTotal] {
        totalsByCurrency(from: todayExpenses(from: expenses))
    }

    func latestExpenses(from expenses: [Expense], limit: Int = 5) -> [Expense] {
        Array(expenses.sorted { $0.date > $1.date }.prefix(limit))
    }

    func topCategories(from expenses: [Expense], limit: Int = 5) -> [CategoryTotal] {
        let groupedTotals = Dictionary(grouping: expenses) { expense in
            "\(expense.category)|\(expense.baseCurrency)"
        }
        .map { key, values -> CategoryTotal in
            let parts = key.split(separator: "|", maxSplits: 1).map(String.init)
            return CategoryTotal(
                category: parts.first ?? "Sin categoria",
                total: values.reduce(0) { $0 + $1.convertedAmount },
                currency: parts.dropFirst().first ?? CurrencyOptions.defaultCurrency
            )
        }

        return Array(groupedTotals.sorted { $0.total > $1.total }.prefix(limit))
    }

    private func totalsByCurrency(from expenses: [Expense]) -> [MoneyTotal] {
        Dictionary(grouping: expenses, by: \.baseCurrency)
            .map { currency, values in
                MoneyTotal(currency: currency, total: values.reduce(0) { $0 + $1.convertedAmount })
            }
            .sorted { $0.currency < $1.currency }
    }
}
