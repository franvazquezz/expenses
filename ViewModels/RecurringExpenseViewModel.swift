import Foundation

struct RecurringGenerationResult {
    let createdExpenses: [Expense]
    let nextRunDate: Date
}

final class RecurringExpenseViewModel: ObservableObject {
    @Published var name: String
    @Published var amountText: String
    @Published var currency: String
    @Published var convertedAmountText: String
    @Published var baseCurrency: String
    @Published var category: String
    @Published var expenseDescription: String
    @Published var note: String
    @Published var paymentMethod: String
    @Published var tagsText: String
    @Published var period: RecurrencePeriod
    @Published var startDate: Date
    @Published var nextRunDate: Date
    @Published var isActive: Bool

    init(recurringExpense: RecurringExpense? = nil) {
        name = recurringExpense?.name ?? ""
        amountText = recurringExpense.map { Self.amountFormatter.string(from: NSNumber(value: $0.originalAmount)) ?? "\($0.originalAmount)" } ?? ""
        currency = recurringExpense?.originalCurrency ?? CurrencyOptions.defaultCurrency
        convertedAmountText = recurringExpense.map { Self.amountFormatter.string(from: NSNumber(value: $0.convertedAmount)) ?? "\($0.convertedAmount)" } ?? ""
        baseCurrency = recurringExpense?.baseCurrency ?? CurrencyOptions.defaultCurrency
        category = recurringExpense?.category ?? ExpenseCategories.defaultCategory
        expenseDescription = recurringExpense?.expenseDescription ?? ""
        note = recurringExpense?.note ?? ""
        paymentMethod = recurringExpense?.paymentMethod ?? ""
        tagsText = recurringExpense?.tags.joined(separator: ", ") ?? ""
        period = recurringExpense?.period ?? .monthly
        startDate = recurringExpense?.startDate ?? Date()
        nextRunDate = recurringExpense?.nextRunDate ?? Date()
        isActive = recurringExpense?.isActive ?? true
    }

    var parsedAmount: Double? {
        parseAmount(amountText)
    }

    var parsedConvertedAmount: Double? {
        parseAmount(convertedAmountText)
    }

    var canSave: Bool {
        !cleaned(name).isEmpty &&
        parsedAmount != nil &&
        parsedConvertedAmount != nil &&
        !category.isEmpty &&
        !currency.isEmpty &&
        !baseCurrency.isEmpty
    }

    var needsConversion: Bool {
        currency != baseCurrency
    }

    var tags: [String] {
        tagsText
            .split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    func setDefaultCurrencyIfNeeded(_ defaultCurrency: String) {
        guard amountText.isEmpty else {
            return
        }

        currency = defaultCurrency
        baseCurrency = defaultCurrency
        convertedAmountText = amountText
    }

    func updateConversion(using rates: [ExchangeRate]) {
        guard let amount = parsedAmount else {
            convertedAmountText = ""
            return
        }

        guard let convertedAmount = ExchangeRateViewModel.convertedAmount(
            amount: amount,
            from: currency,
            to: baseCurrency,
            rates: rates
        ) else {
            return
        }

        convertedAmountText = Self.amountFormatter.string(from: NSNumber(value: convertedAmount)) ?? "\(convertedAmount)"
    }

    func makeRecurringExpense() -> RecurringExpense? {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return nil
        }

        return RecurringExpense(
            name: cleaned(name),
            amount: amount,
            currency: currency,
            convertedAmount: convertedAmount,
            baseCurrency: baseCurrency,
            category: category,
            expenseDescription: cleaned(expenseDescription),
            note: cleaned(note),
            paymentMethod: cleaned(paymentMethod),
            tags: tags,
            period: period,
            startDate: startDate,
            nextRunDate: nextRunDate,
            isActive: isActive
        )
    }

    func update(_ recurringExpense: RecurringExpense) {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return
        }

        recurringExpense.name = cleaned(name)
        recurringExpense.originalAmount = amount
        recurringExpense.originalCurrency = currency
        recurringExpense.convertedAmount = convertedAmount
        recurringExpense.baseCurrency = baseCurrency
        recurringExpense.category = category
        recurringExpense.expenseDescription = cleaned(expenseDescription)
        recurringExpense.note = cleaned(note)
        recurringExpense.paymentMethod = cleaned(paymentMethod)
        recurringExpense.tags = tags
        recurringExpense.period = period
        recurringExpense.startDate = startDate
        recurringExpense.nextRunDate = nextRunDate
        recurringExpense.isActive = isActive
    }

    static func generatedExpenses(for recurringExpense: RecurringExpense, through date: Date = Date(), calendar: Calendar = .current) -> RecurringGenerationResult {
        guard recurringExpense.isActive else {
            return RecurringGenerationResult(createdExpenses: [], nextRunDate: recurringExpense.nextRunDate)
        }

        var cursor = recurringExpense.nextRunDate
        var createdExpenses: [Expense] = []

        while calendar.startOfDay(for: cursor) <= calendar.startOfDay(for: date) {
            createdExpenses.append(makeExpense(from: recurringExpense, date: cursor))

            guard let nextDate = nextRunDate(after: cursor, period: recurringExpense.period, calendar: calendar) else {
                break
            }

            cursor = nextDate
        }

        return RecurringGenerationResult(createdExpenses: createdExpenses, nextRunDate: cursor)
    }

    static func nextRunDate(after date: Date, period: RecurrencePeriod, calendar: Calendar = .current) -> Date? {
        calendar.date(byAdding: period.calendarComponent, value: 1, to: date)
    }

    static func makeExpense(from recurringExpense: RecurringExpense, date: Date) -> Expense {
        Expense(
            amount: recurringExpense.originalAmount,
            currency: recurringExpense.originalCurrency,
            convertedAmount: recurringExpense.convertedAmount,
            baseCurrency: recurringExpense.baseCurrency,
            date: date,
            category: recurringExpense.category,
            expenseDescription: recurringExpense.expenseDescription.isEmpty ? recurringExpense.name : recurringExpense.expenseDescription,
            note: recurringExpense.note,
            paymentMethod: recurringExpense.paymentMethod,
            tags: Array(Set(recurringExpense.tags + ["recurrente"]))
        )
    }

    private func cleaned(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func parseAmount(_ value: String) -> Double? {
        let normalizedAmount = value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let amount = Double(normalizedAmount), amount > 0 else {
            return nil
        }

        return amount
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}
