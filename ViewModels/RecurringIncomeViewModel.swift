import Foundation

struct RecurringIncomeGenerationResult {
    let createdIncomes: [Income]
    let nextRunDate: Date
}

final class RecurringIncomeViewModel: ObservableObject {
    @Published var name: String
    @Published var amountText: String
    @Published var currency: String
    @Published var convertedAmountText: String
    @Published var baseCurrency: String
    @Published var category: String
    @Published var incomeDescription: String
    @Published var note: String
    @Published var period: RecurrencePeriod
    @Published var startDate: Date
    @Published var nextRunDate: Date
    @Published var isActive: Bool

    init(recurringIncome: RecurringIncome? = nil) {
        name = recurringIncome?.name ?? ""
        amountText = recurringIncome.map { Self.amountFormatter.string(from: NSNumber(value: $0.originalAmount)) ?? "\($0.originalAmount)" } ?? ""
        currency = recurringIncome?.originalCurrency ?? CurrencyOptions.defaultCurrency
        convertedAmountText = recurringIncome.map { Self.amountFormatter.string(from: NSNumber(value: $0.convertedAmount)) ?? "\($0.convertedAmount)" } ?? ""
        baseCurrency = recurringIncome?.baseCurrency ?? CurrencyOptions.defaultCurrency
        category = recurringIncome?.category ?? IncomeCategories.defaultCategory
        incomeDescription = recurringIncome?.incomeDescription ?? ""
        note = recurringIncome?.note ?? ""
        period = recurringIncome?.period ?? .monthly
        startDate = recurringIncome?.startDate ?? Date()
        nextRunDate = recurringIncome?.nextRunDate ?? Date()
        isActive = recurringIncome?.isActive ?? true
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

    func makeRecurringIncome() -> RecurringIncome? {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return nil
        }

        return RecurringIncome(
            name: cleaned(name),
            amount: amount,
            currency: currency,
            convertedAmount: convertedAmount,
            baseCurrency: baseCurrency,
            category: category,
            incomeDescription: cleaned(incomeDescription),
            note: cleaned(note),
            period: period,
            startDate: startDate,
            nextRunDate: nextRunDate,
            isActive: isActive
        )
    }

    func update(_ recurringIncome: RecurringIncome) {
        guard let amount = parsedAmount, let convertedAmount = parsedConvertedAmount else {
            return
        }

        recurringIncome.name = cleaned(name)
        recurringIncome.originalAmount = amount
        recurringIncome.originalCurrency = currency
        recurringIncome.convertedAmount = convertedAmount
        recurringIncome.baseCurrency = baseCurrency
        recurringIncome.category = category
        recurringIncome.incomeDescription = cleaned(incomeDescription)
        recurringIncome.note = cleaned(note)
        recurringIncome.period = period
        recurringIncome.startDate = startDate
        recurringIncome.nextRunDate = nextRunDate
        recurringIncome.isActive = isActive
    }

    static func generatedIncomes(for recurringIncome: RecurringIncome, through date: Date = Date(), calendar: Calendar = .current) -> RecurringIncomeGenerationResult {
        guard recurringIncome.isActive else {
            return RecurringIncomeGenerationResult(createdIncomes: [], nextRunDate: recurringIncome.nextRunDate)
        }

        var cursor = recurringIncome.nextRunDate
        var createdIncomes: [Income] = []

        while calendar.startOfDay(for: cursor) <= calendar.startOfDay(for: date) {
            createdIncomes.append(makeIncome(from: recurringIncome, date: cursor))

            guard let nextDate = RecurringExpenseViewModel.nextRunDate(after: cursor, period: recurringIncome.period, calendar: calendar) else {
                break
            }

            cursor = nextDate
        }

        return RecurringIncomeGenerationResult(createdIncomes: createdIncomes, nextRunDate: cursor)
    }

    static func makeIncome(from recurringIncome: RecurringIncome, date: Date) -> Income {
        Income(
            amount: recurringIncome.originalAmount,
            currency: recurringIncome.originalCurrency,
            convertedAmount: recurringIncome.convertedAmount,
            baseCurrency: recurringIncome.baseCurrency,
            date: date,
            category: recurringIncome.category,
            incomeDescription: recurringIncome.incomeDescription.isEmpty ? recurringIncome.name : recurringIncome.incomeDescription,
            note: recurringIncome.note,
            isConfirmed: false
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
