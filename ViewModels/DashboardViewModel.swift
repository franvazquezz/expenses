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

struct MonthlyMovementTotal: Identifiable {
    let monthStart: Date
    let currency: String
    let expenseTotal: Double
    let incomeTotal: Double

    var id: String {
        "\(monthStart.timeIntervalSince1970)-\(currency)"
    }

    var balance: Double {
        incomeTotal - expenseTotal
    }
}

struct PaymentMethodTotal: Identifiable {
    let paymentMethod: String
    let total: Double
    let currency: String

    var id: String {
        "\(paymentMethod)-\(currency)"
    }
}

private struct MonthlyMovementKey: Hashable {
    let monthStart: Date
    let currency: String
}

final class DashboardViewModel {
    private let calendar = Calendar.current

    func totalsThisMonth(from expenses: [Expense]) -> [MoneyTotal] {
        totalsByCurrency(
            from: expenses.filter { $0.isConfirmed && calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        )
    }

    func totalsThisYear(from expenses: [Expense]) -> [MoneyTotal] {
        totalsByCurrency(
            from: expenses.filter { $0.isConfirmed && calendar.isDate($0.date, equalTo: Date(), toGranularity: .year) }
        )
    }

    func todayExpenses(from expenses: [Expense]) -> [Expense] {
        expenses.filter { $0.isConfirmed && calendar.isDateInToday($0.date) }
    }

    func todayTotals(from expenses: [Expense]) -> [MoneyTotal] {
        totalsByCurrency(from: todayExpenses(from: expenses))
    }

    func incomeTotalsThisMonth(from incomes: [Income]) -> [MoneyTotal] {
        incomeTotalsByCurrency(
            from: incomes.filter { $0.isConfirmed && calendar.isDate($0.date, equalTo: Date(), toGranularity: .month) }
        )
    }

    func expenseTotalsThisMonth(from expenses: [Expense]) -> [MoneyTotal] {
        totalsThisMonth(from: expenses)
    }

    func balanceThisMonth(expenses: [Expense], incomes: [Income]) -> [MoneyTotal] {
        let incomeTotals = incomeTotalsThisMonth(from: incomes)
        let expenseTotals = expenseTotalsThisMonth(from: expenses)
        let currencies = Set(incomeTotals.map(\.currency)).union(expenseTotals.map(\.currency))

        return currencies
            .map { currency in
                let incomeTotal = incomeTotals.first(where: { $0.currency == currency })?.total ?? 0
                let expenseTotal = expenseTotals.first(where: { $0.currency == currency })?.total ?? 0
                return MoneyTotal(currency: currency, total: incomeTotal - expenseTotal)
            }
            .sorted { $0.currency < $1.currency }
    }

    func latestExpenses(from expenses: [Expense], limit: Int = 5) -> [Expense] {
        Array(expenses.filter(\.isConfirmed).sorted { $0.date > $1.date }.prefix(limit))
    }

    func latestIncomes(from incomes: [Income], limit: Int = 5) -> [Income] {
        Array(incomes.filter(\.isConfirmed).sorted { $0.date > $1.date }.prefix(limit))
    }

    func topCategories(from expenses: [Expense], limit: Int = 5) -> [CategoryTotal] {
        let groupedTotals = Dictionary(grouping: expenses.filter(\.isConfirmed)) { expense in
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

    func monthlyMovementTotals(expenses: [Expense], incomes: [Income], monthsBack: Int = 12) -> [MonthlyMovementTotal] {
        let months = recentMonthStarts(count: monthsBack)
        let monthSet = Set(months)
        let confirmedExpenses = expenses.filter { $0.isConfirmed }
        let confirmedIncomes = incomes.filter { $0.isConfirmed }
        let currencies = Set(confirmedExpenses.map(\.baseCurrency)).union(confirmedIncomes.map(\.baseCurrency))
        let expenseTotals = totalsByMonthAndCurrency(
            expenses: confirmedExpenses,
            allowedMonths: monthSet
        )
        let incomeTotals = totalsByMonthAndCurrency(
            incomes: confirmedIncomes,
            allowedMonths: monthSet
        )

        return months.flatMap { monthStart in
            currencies.map { currency in
                let key = MonthlyMovementKey(monthStart: monthStart, currency: currency)

                return MonthlyMovementTotal(
                    monthStart: monthStart,
                    currency: currency,
                    expenseTotal: expenseTotals[key] ?? 0,
                    incomeTotal: incomeTotals[key] ?? 0
                )
            }
        }
        .filter { $0.expenseTotal > 0 || $0.incomeTotal > 0 }
        .sorted {
            if $0.monthStart == $1.monthStart {
                return $0.currency < $1.currency
            }

            return $0.monthStart < $1.monthStart
        }
    }

    func paymentMethodTotals(from expenses: [Expense], limit: Int = 6) -> [PaymentMethodTotal] {
        let groupedTotals = Dictionary(grouping: expenses.filter(\.isConfirmed)) { expense in
            let paymentMethod = expense.paymentMethod.isEmpty ? "Sin especificar" : expense.paymentMethod
            return "\(paymentMethod)|\(expense.baseCurrency)"
        }
        .map { key, values -> PaymentMethodTotal in
            let parts = key.split(separator: "|", maxSplits: 1).map(String.init)
            return PaymentMethodTotal(
                paymentMethod: parts.first ?? "Sin especificar",
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

    private func incomeTotalsByCurrency(from incomes: [Income]) -> [MoneyTotal] {
        Dictionary(grouping: incomes, by: \.baseCurrency)
            .map { currency, values in
                MoneyTotal(currency: currency, total: values.reduce(0) { $0 + $1.convertedAmount })
            }
            .sorted { $0.currency < $1.currency }
    }

    private func totalsByMonthAndCurrency(expenses: [Expense], allowedMonths: Set<Date>) -> [MonthlyMovementKey: Double] {
        expenses.reduce(into: [:]) { totals, expense in
            let monthStart = monthStartForDate(expense.date)
            guard allowedMonths.contains(monthStart) else {
                return
            }

            totals[MonthlyMovementKey(monthStart: monthStart, currency: expense.baseCurrency), default: 0] += expense.convertedAmount
        }
    }

    private func totalsByMonthAndCurrency(incomes: [Income], allowedMonths: Set<Date>) -> [MonthlyMovementKey: Double] {
        incomes.reduce(into: [:]) { totals, income in
            let monthStart = monthStartForDate(income.date)
            guard allowedMonths.contains(monthStart) else {
                return
            }

            totals[MonthlyMovementKey(monthStart: monthStart, currency: income.baseCurrency), default: 0] += income.convertedAmount
        }
    }

    private func recentMonthStarts(count: Int) -> [Date] {
        let currentMonth = monthStartForDate(Date())

        return (0..<count)
            .compactMap { offset in
                calendar.date(byAdding: .month, value: -offset, to: currentMonth)
            }
            .reversed()
    }

    private func monthStartForDate(_ date: Date) -> Date {
        let components = calendar.dateComponents([.year, .month], from: date)
        return calendar.date(from: components) ?? date
    }
}
