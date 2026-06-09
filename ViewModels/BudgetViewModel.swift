import Foundation

struct BudgetProgress: Identifiable {
    let budget: Budget
    let consumed: Double

    var id: String {
        "\(budget.category)-\(budget.currency)-\(budget.monthStart.timeIntervalSince1970)"
    }

    var remaining: Double {
        max(budget.amount - consumed, 0)
    }

    var percentage: Double {
        guard budget.amount > 0 else {
            return 0
        }

        return min(consumed / budget.amount, 1)
    }

    var percentageText: String {
        percentage.formatted(.percent.precision(.fractionLength(0)))
    }
}

private struct BudgetProgressKey: Hashable {
    let category: String
    let currency: String
}

final class BudgetViewModel: ObservableObject {
    @Published var selectedMonth = MonthFilter.current
    @Published var category = ExpenseCategories.defaultCategory
    @Published var amountText = ""
    @Published var currency = CurrencyOptions.defaultCurrency

    init(budget: Budget? = nil) {
        if let budget {
            selectedMonth = MonthFilter(containing: budget.monthStart)
            category = budget.category
            amountText = Self.amountFormatter.string(from: NSNumber(value: budget.amount)) ?? "\(budget.amount)"
            currency = budget.currency
        }
    }

    var parsedAmount: Double? {
        let normalizedAmount = amountText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(normalizedAmount), amount > 0 else {
            return nil
        }

        return amount
    }

    var canSave: Bool {
        parsedAmount != nil && !category.isEmpty && !currency.isEmpty
    }

    func makeBudget() -> Budget? {
        guard let amount = parsedAmount else {
            return nil
        }

        return Budget(
            category: category,
            amount: amount,
            currency: currency,
            monthStart: selectedMonth.start
        )
    }

    func update(_ budget: Budget) {
        guard let amount = parsedAmount else {
            return
        }

        budget.category = category
        budget.amount = amount
        budget.currency = currency
        budget.monthStart = selectedMonth.start
    }

    static func progress(
        for budgets: [Budget],
        expenses: [Expense],
        month: MonthFilter = .current,
        includeInactive: Bool = false
    ) -> [BudgetProgress] {
        let consumedByBudgetKey = expenses
            .filter { $0.isConfirmed && month.contains($0.date) }
            .reduce(into: [BudgetProgressKey: Double]()) { totals, expense in
                let key = BudgetProgressKey(category: expense.category, currency: expense.baseCurrency)
                totals[key, default: 0] += expense.convertedAmount
            }

        return budgets
            .filter { (includeInactive || $0.isActive) && month.contains($0.monthStart) }
            .sorted { $0.category < $1.category }
            .map { budget in
                let key = BudgetProgressKey(category: budget.category, currency: budget.currency)
                let consumed = consumedByBudgetKey[key] ?? 0

                return BudgetProgress(budget: budget, consumed: consumed)
            }
    }

    static func seedInitialBudgetsIfNeeded(in budgets: [Budget], defaultCurrency: String) -> [Budget] {
        guard budgets.isEmpty else {
            return []
        }

        return [
            Budget(category: "Comida", amount: 300000, currency: defaultCurrency),
            Budget(category: "Transporte", amount: 100000, currency: defaultCurrency),
            Budget(category: "Ocio", amount: 150000, currency: defaultCurrency)
        ]
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}
