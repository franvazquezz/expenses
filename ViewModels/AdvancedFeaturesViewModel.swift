import Foundation

struct SavingsGoalProgress: Identifiable {
    let goal: SavingsGoal

    var id: UUID {
        goal.id
    }

    var remaining: Double {
        max(goal.targetAmount - goal.currentAmount, 0)
    }

    var percentage: Double {
        guard goal.targetAmount > 0 else {
            return 0
        }

        return min(goal.currentAmount / goal.targetAmount, 1)
    }

    var percentageText: String {
        percentage.formatted(.percent.precision(.fractionLength(0)))
    }
}

struct BudgetAlert: Identifiable {
    let progress: BudgetProgress

    var id: String {
        progress.id
    }

    var title: String {
        "Presupuesto superado: \(progress.budget.category)"
    }
}

struct UnusualExpenseAlert: Identifiable {
    let expense: Expense
    let averageAmount: Double
    let thresholdAmount: Double

    var id: String {
        "\(expense.date.timeIntervalSince1970)-\(expense.category)-\(expense.convertedAmount)"
    }
}

struct MonthlyComparison: Identifiable {
    let currency: String
    let currentMonthExpenseTotal: Double
    let previousMonthExpenseTotal: Double
    let currentMonthIncomeTotal: Double
    let previousMonthIncomeTotal: Double

    var id: String {
        currency
    }

    var expenseDifference: Double {
        currentMonthExpenseTotal - previousMonthExpenseTotal
    }

    var incomeDifference: Double {
        currentMonthIncomeTotal - previousMonthIncomeTotal
    }

    var balanceDifference: Double {
        (currentMonthIncomeTotal - currentMonthExpenseTotal) - (previousMonthIncomeTotal - previousMonthExpenseTotal)
    }
}

final class SavingsGoalViewModel: ObservableObject {
    @Published var name = ""
    @Published var targetAmountText = ""
    @Published var currentAmountText = ""
    @Published var currency = CurrencyOptions.defaultCurrency
    @Published var hasTargetDate = false
    @Published var targetDate = Date()
    @Published var note = ""
    @Published var isActive = true

    init(goal: SavingsGoal? = nil) {
        guard let goal else {
            return
        }

        name = goal.name
        targetAmountText = Self.amountFormatter.string(from: NSNumber(value: goal.targetAmount)) ?? "\(goal.targetAmount)"
        currentAmountText = Self.amountFormatter.string(from: NSNumber(value: goal.currentAmount)) ?? "\(goal.currentAmount)"
        currency = goal.currency
        hasTargetDate = goal.targetDate != nil
        targetDate = goal.targetDate ?? Date()
        note = goal.note
        isActive = goal.isActive
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var parsedTargetAmount: Double? {
        Self.parseAmount(targetAmountText, allowsZero: false)
    }

    var parsedCurrentAmount: Double? {
        Self.parseAmount(currentAmountText, allowsZero: true)
    }

    var canSave: Bool {
        !trimmedName.isEmpty &&
        parsedTargetAmount != nil &&
        parsedCurrentAmount != nil &&
        !currency.isEmpty
    }

    func makeGoal() -> SavingsGoal? {
        guard let targetAmount = parsedTargetAmount,
              let currentAmount = parsedCurrentAmount,
              canSave else {
            return nil
        }

        return SavingsGoal(
            name: trimmedName,
            targetAmount: targetAmount,
            currentAmount: currentAmount,
            currency: currency,
            targetDate: hasTargetDate ? targetDate : nil,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            isActive: isActive
        )
    }

    func update(_ goal: SavingsGoal) {
        guard let targetAmount = parsedTargetAmount,
              let currentAmount = parsedCurrentAmount,
              canSave else {
            return
        }

        goal.name = trimmedName
        goal.targetAmount = targetAmount
        goal.currentAmount = currentAmount
        goal.currency = currency
        goal.targetDate = hasTargetDate ? targetDate : nil
        goal.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        goal.isActive = isActive
        goal.updatedAt = Date()
    }

    static func progress(for goals: [SavingsGoal], includeInactive: Bool = false) -> [SavingsGoalProgress] {
        goals
            .filter { includeInactive || $0.isActive }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map(SavingsGoalProgress.init(goal:))
    }

    private static func parseAmount(_ value: String, allowsZero: Bool) -> Double? {
        let normalizedValue = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(normalizedValue) else {
            return nil
        }

        return allowsZero ? (amount >= 0 ? amount : nil) : (amount > 0 ? amount : nil)
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}

enum AdvancedFeaturesViewModel {
    static func budgetAlerts(
        budgets: [Budget],
        expenses: [Expense],
        month: MonthFilter = .current
    ) -> [BudgetAlert] {
        BudgetViewModel
            .progress(for: budgets, expenses: expenses, month: month)
            .filter { $0.consumed > $0.budget.amount }
            .map(BudgetAlert.init(progress:))
    }

    static func unusualExpenseAlerts(
        expenses: [Expense],
        currentMonth: MonthFilter = .current,
        historyMonths: Int = 6,
        multiplier: Double = 2,
        minimumBaseline: Double = 1
    ) -> [UnusualExpenseAlert] {
        guard historyMonths > 0, multiplier > 1 else {
            return []
        }

        let calendar = Calendar.current
        let historicalExpenses = expenses.filter { expense in
            guard expense.isConfirmed,
                  !currentMonth.contains(expense.date),
                  let lowerBound = calendar.date(byAdding: .month, value: -historyMonths, to: currentMonth.start) else {
                return false
            }

            return expense.date >= lowerBound && expense.date < currentMonth.start
        }
        let averagesByCategoryAndCurrency = Dictionary(grouping: historicalExpenses) { expense in
            "\(expense.category)|\(expense.baseCurrency)"
        }
        .compactMapValues { values -> Double? in
            guard !values.isEmpty else {
                return nil
            }

            return values.reduce(0) { $0 + $1.convertedAmount } / Double(values.count)
        }

        return expenses
            .filter { $0.isConfirmed && currentMonth.contains($0.date) }
            .compactMap { expense in
                let key = "\(expense.category)|\(expense.baseCurrency)"
                guard let average = averagesByCategoryAndCurrency[key],
                      average >= minimumBaseline else {
                    return nil
                }

                let threshold = average * multiplier
                guard expense.convertedAmount > threshold else {
                    return nil
                }

                return UnusualExpenseAlert(
                    expense: expense,
                    averageAmount: average,
                    thresholdAmount: threshold
                )
            }
            .sorted { $0.expense.convertedAmount > $1.expense.convertedAmount }
    }

    static func monthlyComparison(
        expenses: [Expense],
        incomes: [Income],
        month: MonthFilter = .current
    ) -> [MonthlyComparison] {
        let calendar = Calendar.current
        guard let previousMonthStart = calendar.date(byAdding: .month, value: -1, to: month.start) else {
            return []
        }

        let previousMonth = MonthFilter(containing: previousMonthStart)
        let confirmedExpenses = expenses.filter(\.isConfirmed)
        let confirmedIncomes = incomes.filter(\.isConfirmed)
        let currencies = Set(confirmedExpenses.map(\.baseCurrency)).union(confirmedIncomes.map(\.baseCurrency))

        return currencies
            .map { currency in
                MonthlyComparison(
                    currency: currency,
                    currentMonthExpenseTotal: confirmedExpenses
                        .filter { month.contains($0.date) && $0.baseCurrency == currency }
                        .reduce(0) { $0 + $1.convertedAmount },
                    previousMonthExpenseTotal: confirmedExpenses
                        .filter { previousMonth.contains($0.date) && $0.baseCurrency == currency }
                        .reduce(0) { $0 + $1.convertedAmount },
                    currentMonthIncomeTotal: confirmedIncomes
                        .filter { month.contains($0.date) && $0.baseCurrency == currency }
                        .reduce(0) { $0 + $1.convertedAmount },
                    previousMonthIncomeTotal: confirmedIncomes
                        .filter { previousMonth.contains($0.date) && $0.baseCurrency == currency }
                        .reduce(0) { $0 + $1.convertedAmount }
                )
            }
            .filter {
                $0.currentMonthExpenseTotal > 0 ||
                $0.previousMonthExpenseTotal > 0 ||
                $0.currentMonthIncomeTotal > 0 ||
                $0.previousMonthIncomeTotal > 0
            }
            .sorted { $0.currency < $1.currency }
    }

    static func seedReminderSettingsIfNeeded(in settings: [DailyReminderSettings]) -> DailyReminderSettings? {
        settings.isEmpty ? DailyReminderSettings() : nil
    }
}

