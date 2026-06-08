import Foundation

enum DataTransferError: Error, LocalizedError {
    case invalidHeader
    case invalidColumnCount(line: Int)
    case invalidDate(line: Int)
    case invalidAmount(line: Int)
    case invalidBoolean(line: Int)
    case missingRequiredField(line: Int)
    case invalidBackup

    var errorDescription: String? {
        switch self {
        case .invalidHeader:
            "El encabezado del archivo no coincide con el formato esperado."
        case .invalidColumnCount(let line):
            "La linea \(line) no tiene la cantidad de columnas esperada."
        case .invalidDate(let line):
            "La linea \(line) tiene una fecha invalida."
        case .invalidAmount(let line):
            "La linea \(line) tiene un importe invalido."
        case .invalidBoolean(let line):
            "La linea \(line) tiene un estado invalido."
        case .missingRequiredField(let line):
            "La linea \(line) tiene campos requeridos vacios."
        case .invalidBackup:
            "El backup no tiene un formato valido."
        }
    }
}

struct AppBackup: Codable {
    let version: Int
    let createdAt: Date
    let expenses: [ExpenseBackup]
    let incomes: [IncomeBackup]
    let currencies: [CurrencyBackup]
    let exchangeRates: [ExchangeRateBackup]
    let budgets: [BudgetBackup]
    let recurringExpenses: [RecurringExpenseBackup]
    let recurringIncomes: [RecurringIncomeBackup]
    let accounts: [AccountBackup]

    enum CodingKeys: String, CodingKey {
        case version
        case createdAt
        case expenses
        case incomes
        case currencies
        case exchangeRates
        case budgets
        case recurringExpenses
        case recurringIncomes
        case accounts
    }

    init(
        version: Int,
        createdAt: Date,
        expenses: [ExpenseBackup],
        incomes: [IncomeBackup],
        currencies: [CurrencyBackup],
        exchangeRates: [ExchangeRateBackup],
        budgets: [BudgetBackup],
        recurringExpenses: [RecurringExpenseBackup],
        recurringIncomes: [RecurringIncomeBackup],
        accounts: [AccountBackup] = []
    ) {
        self.version = version
        self.createdAt = createdAt
        self.expenses = expenses
        self.incomes = incomes
        self.currencies = currencies
        self.exchangeRates = exchangeRates
        self.budgets = budgets
        self.recurringExpenses = recurringExpenses
        self.recurringIncomes = recurringIncomes
        self.accounts = accounts
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        version = try container.decode(Int.self, forKey: .version)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        expenses = try container.decode([ExpenseBackup].self, forKey: .expenses)
        incomes = try container.decode([IncomeBackup].self, forKey: .incomes)
        currencies = try container.decode([CurrencyBackup].self, forKey: .currencies)
        exchangeRates = try container.decode([ExchangeRateBackup].self, forKey: .exchangeRates)
        budgets = try container.decode([BudgetBackup].self, forKey: .budgets)
        recurringExpenses = try container.decode([RecurringExpenseBackup].self, forKey: .recurringExpenses)
        recurringIncomes = try container.decode([RecurringIncomeBackup].self, forKey: .recurringIncomes)
        accounts = try container.decodeIfPresent([AccountBackup].self, forKey: .accounts) ?? []
    }
}

struct ExpenseBackup: Codable {
    let originalAmount: Double
    let originalCurrency: String
    let convertedAmount: Double
    let baseCurrency: String
    let date: Date
    let category: String
    let expenseDescription: String
    let note: String
    let paymentMethod: String
    let tags: [String]
    let isConfirmed: Bool
    let accountID: UUID?
}

struct IncomeBackup: Codable {
    let originalAmount: Double
    let originalCurrency: String
    let convertedAmount: Double
    let baseCurrency: String
    let date: Date
    let category: String
    let incomeDescription: String
    let note: String
    let isConfirmed: Bool
    let accountID: UUID?
}

struct CurrencyBackup: Codable {
    let code: String
    let name: String
    let symbol: String
    let isActive: Bool
    let isDefault: Bool
}

struct ExchangeRateBackup: Codable {
    let fromCurrency: String
    let toCurrency: String
    let rate: Double
    let updatedAt: Date
}

struct BudgetBackup: Codable {
    let category: String
    let amount: Double
    let currency: String
    let monthStart: Date
    let isActive: Bool
}

struct RecurringExpenseBackup: Codable {
    let name: String
    let originalAmount: Double
    let originalCurrency: String
    let convertedAmount: Double
    let baseCurrency: String
    let category: String
    let expenseDescription: String
    let note: String
    let paymentMethod: String
    let tags: [String]
    let periodRawValue: String
    let startDate: Date
    let nextRunDate: Date
    let isActive: Bool
}

struct RecurringIncomeBackup: Codable {
    let name: String
    let originalAmount: Double
    let originalCurrency: String
    let convertedAmount: Double
    let baseCurrency: String
    let category: String
    let incomeDescription: String
    let note: String
    let periodRawValue: String
    let startDate: Date
    let nextRunDate: Date
    let isActive: Bool
}

struct AccountBackup: Codable {
    let id: UUID
    let name: String
    let institution: String
    let typeRawValue: String
    let category: String
    let currency: String
    let balance: Double
    let note: String
    let isActive: Bool
    let updatedAt: Date
}

enum DataTransferService {
    static let expenseCSVHeader = [
        "date",
        "originalAmount",
        "originalCurrency",
        "convertedAmount",
        "baseCurrency",
        "category",
        "description",
        "note",
        "paymentMethod",
        "tags",
        "isConfirmed"
    ]

    static let incomeCSVHeader = [
        "date",
        "originalAmount",
        "originalCurrency",
        "convertedAmount",
        "baseCurrency",
        "category",
        "description",
        "note",
        "isConfirmed"
    ]

    static func exportExpensesCSV(_ expenses: [Expense]) -> String {
        csvLines(
            header: expenseCSVHeader,
            rows: expenses.map { expense in
                [
                    formatDate(expense.date),
                    formatNumber(expense.originalAmount),
                    expense.originalCurrency,
                    formatNumber(expense.convertedAmount),
                    expense.baseCurrency,
                    expense.category,
                    expense.expenseDescription,
                    expense.note,
                    expense.paymentMethod,
                    expense.tags.joined(separator: "|"),
                    String(expense.isConfirmed)
                ]
            }
        )
    }

    static func importExpensesCSV(_ text: String) throws -> [Expense] {
        let rows = try parseCSV(text)
        guard rows.first == expenseCSVHeader else {
            throw DataTransferError.invalidHeader
        }

        return try rows.dropFirst().enumerated().map { offset, row in
            let line = offset + 2
            guard row.count == expenseCSVHeader.count else {
                throw DataTransferError.invalidColumnCount(line: line)
            }

            guard let date = parseDate(row[0]) else {
                throw DataTransferError.invalidDate(line: line)
            }
            guard let originalAmount = parsePositiveDouble(row[1]),
                  let convertedAmount = parsePositiveDouble(row[3]) else {
                throw DataTransferError.invalidAmount(line: line)
            }
            guard let isConfirmed = parseBool(row[10]) else {
                throw DataTransferError.invalidBoolean(line: line)
            }
            guard hasRequiredValues([row[2], row[4], row[5]]) else {
                throw DataTransferError.missingRequiredField(line: line)
            }

            return Expense(
                amount: originalAmount,
                currency: row[2],
                convertedAmount: convertedAmount,
                baseCurrency: row[4],
                date: date,
                category: row[5],
                expenseDescription: row[6],
                note: row[7],
                paymentMethod: row[8],
                tags: splitTags(row[9]),
                isConfirmed: isConfirmed
            )
        }
    }

    static func exportIncomesCSV(_ incomes: [Income]) -> String {
        csvLines(
            header: incomeCSVHeader,
            rows: incomes.map { income in
                [
                    formatDate(income.date),
                    formatNumber(income.originalAmount),
                    income.originalCurrency,
                    formatNumber(income.convertedAmount),
                    income.baseCurrency,
                    income.category,
                    income.incomeDescription,
                    income.note,
                    String(income.isConfirmed)
                ]
            }
        )
    }

    static func importIncomesCSV(_ text: String) throws -> [Income] {
        let rows = try parseCSV(text)
        guard rows.first == incomeCSVHeader else {
            throw DataTransferError.invalidHeader
        }

        return try rows.dropFirst().enumerated().map { offset, row in
            let line = offset + 2
            guard row.count == incomeCSVHeader.count else {
                throw DataTransferError.invalidColumnCount(line: line)
            }

            guard let date = parseDate(row[0]) else {
                throw DataTransferError.invalidDate(line: line)
            }
            guard let originalAmount = parsePositiveDouble(row[1]),
                  let convertedAmount = parsePositiveDouble(row[3]) else {
                throw DataTransferError.invalidAmount(line: line)
            }
            guard let isConfirmed = parseBool(row[8]) else {
                throw DataTransferError.invalidBoolean(line: line)
            }
            guard hasRequiredValues([row[2], row[4], row[5]]) else {
                throw DataTransferError.missingRequiredField(line: line)
            }

            return Income(
                amount: originalAmount,
                currency: row[2],
                convertedAmount: convertedAmount,
                baseCurrency: row[4],
                date: date,
                category: row[5],
                incomeDescription: row[6],
                note: row[7],
                isConfirmed: isConfirmed
            )
        }
    }

    static func makeBackup(
        expenses: [Expense],
        incomes: [Income],
        currencies: [Currency],
        exchangeRates: [ExchangeRate],
        budgets: [Budget],
        recurringExpenses: [RecurringExpense],
        recurringIncomes: [RecurringIncome],
        accounts: [Account]
    ) -> AppBackup {
        AppBackup(
            version: 1,
            createdAt: Date(),
            expenses: expenses.map { expense in
                ExpenseBackup(
                    originalAmount: expense.originalAmount,
                    originalCurrency: expense.originalCurrency,
                    convertedAmount: expense.convertedAmount,
                    baseCurrency: expense.baseCurrency,
                    date: expense.date,
                    category: expense.category,
                    expenseDescription: expense.expenseDescription,
                    note: expense.note,
                    paymentMethod: expense.paymentMethod,
                    tags: expense.tags,
                    isConfirmed: expense.isConfirmed,
                    accountID: expense.accountID
                )
            },
            incomes: incomes.map { income in
                IncomeBackup(
                    originalAmount: income.originalAmount,
                    originalCurrency: income.originalCurrency,
                    convertedAmount: income.convertedAmount,
                    baseCurrency: income.baseCurrency,
                    date: income.date,
                    category: income.category,
                    incomeDescription: income.incomeDescription,
                    note: income.note,
                    isConfirmed: income.isConfirmed,
                    accountID: income.accountID
                )
            },
            currencies: currencies.map { currency in
                CurrencyBackup(
                    code: currency.code,
                    name: currency.name,
                    symbol: currency.symbol,
                    isActive: currency.isActive,
                    isDefault: currency.isDefault
                )
            },
            exchangeRates: exchangeRates.map { rate in
                ExchangeRateBackup(
                    fromCurrency: rate.fromCurrency,
                    toCurrency: rate.toCurrency,
                    rate: rate.rate,
                    updatedAt: rate.updatedAt
                )
            },
            budgets: budgets.map { budget in
                BudgetBackup(
                    category: budget.category,
                    amount: budget.amount,
                    currency: budget.currency,
                    monthStart: budget.monthStart,
                    isActive: budget.isActive
                )
            },
            recurringExpenses: recurringExpenses.map { recurringExpense in
                RecurringExpenseBackup(
                    name: recurringExpense.name,
                    originalAmount: recurringExpense.originalAmount,
                    originalCurrency: recurringExpense.originalCurrency,
                    convertedAmount: recurringExpense.convertedAmount,
                    baseCurrency: recurringExpense.baseCurrency,
                    category: recurringExpense.category,
                    expenseDescription: recurringExpense.expenseDescription,
                    note: recurringExpense.note,
                    paymentMethod: recurringExpense.paymentMethod,
                    tags: recurringExpense.tags,
                    periodRawValue: recurringExpense.periodRawValue,
                    startDate: recurringExpense.startDate,
                    nextRunDate: recurringExpense.nextRunDate,
                    isActive: recurringExpense.isActive
                )
            },
            recurringIncomes: recurringIncomes.map { recurringIncome in
                RecurringIncomeBackup(
                    name: recurringIncome.name,
                    originalAmount: recurringIncome.originalAmount,
                    originalCurrency: recurringIncome.originalCurrency,
                    convertedAmount: recurringIncome.convertedAmount,
                    baseCurrency: recurringIncome.baseCurrency,
                    category: recurringIncome.category,
                    incomeDescription: recurringIncome.incomeDescription,
                    note: recurringIncome.note,
                    periodRawValue: recurringIncome.periodRawValue,
                    startDate: recurringIncome.startDate,
                    nextRunDate: recurringIncome.nextRunDate,
                    isActive: recurringIncome.isActive
                )
            },
            accounts: accounts.map { account in
                AccountBackup(
                    id: account.id,
                    name: account.name,
                    institution: account.institution,
                    typeRawValue: account.typeRawValue,
                    category: account.category,
                    currency: account.currency,
                    balance: account.balance,
                    note: account.note,
                    isActive: account.isActive,
                    updatedAt: account.updatedAt
                )
            }
        )
    }

    static func encodeBackup(_ backup: AppBackup) throws -> String {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return String(data: try encoder.encode(backup), encoding: .utf8) ?? ""
    }

    static func decodeBackup(_ text: String) throws -> AppBackup {
        guard let data = text.data(using: .utf8) else {
            throw DataTransferError.invalidBackup
        }

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try decoder.decode(AppBackup.self, from: data)
    }

    static func expenses(from backup: AppBackup) -> [Expense] {
        backup.expenses.map { item in
            Expense(
                amount: item.originalAmount,
                currency: item.originalCurrency,
                convertedAmount: item.convertedAmount,
                baseCurrency: item.baseCurrency,
                date: item.date,
                category: item.category,
                expenseDescription: item.expenseDescription,
                note: item.note,
                paymentMethod: item.paymentMethod,
                tags: item.tags,
                isConfirmed: item.isConfirmed,
                accountID: item.accountID
            )
        }
    }

    static func incomes(from backup: AppBackup) -> [Income] {
        backup.incomes.map { item in
            Income(
                amount: item.originalAmount,
                currency: item.originalCurrency,
                convertedAmount: item.convertedAmount,
                baseCurrency: item.baseCurrency,
                date: item.date,
                category: item.category,
                incomeDescription: item.incomeDescription,
                note: item.note,
                isConfirmed: item.isConfirmed,
                accountID: item.accountID
            )
        }
    }

    static func currencies(from backup: AppBackup) -> [Currency] {
        backup.currencies.map { item in
            Currency(
                code: item.code,
                name: item.name,
                symbol: item.symbol,
                isDefault: item.isDefault,
                isActive: item.isActive
            )
        }
    }

    static func exchangeRates(from backup: AppBackup) -> [ExchangeRate] {
        backup.exchangeRates.map { item in
            ExchangeRate(
                fromCurrency: item.fromCurrency,
                toCurrency: item.toCurrency,
                rate: item.rate,
                updatedAt: item.updatedAt
            )
        }
    }

    static func budgets(from backup: AppBackup) -> [Budget] {
        backup.budgets.map { item in
            Budget(
                category: item.category,
                amount: item.amount,
                currency: item.currency,
                monthStart: item.monthStart,
                isActive: item.isActive
            )
        }
    }

    static func recurringExpenses(from backup: AppBackup) -> [RecurringExpense] {
        backup.recurringExpenses.map { item in
            RecurringExpense(
                name: item.name,
                amount: item.originalAmount,
                currency: item.originalCurrency,
                convertedAmount: item.convertedAmount,
                baseCurrency: item.baseCurrency,
                category: item.category,
                expenseDescription: item.expenseDescription,
                note: item.note,
                paymentMethod: item.paymentMethod,
                tags: item.tags,
                period: RecurrencePeriod(rawValue: item.periodRawValue) ?? .monthly,
                startDate: item.startDate,
                nextRunDate: item.nextRunDate,
                isActive: item.isActive
            )
        }
    }

    static func recurringIncomes(from backup: AppBackup) -> [RecurringIncome] {
        backup.recurringIncomes.map { item in
            RecurringIncome(
                name: item.name,
                amount: item.originalAmount,
                currency: item.originalCurrency,
                convertedAmount: item.convertedAmount,
                baseCurrency: item.baseCurrency,
                category: item.category,
                incomeDescription: item.incomeDescription,
                note: item.note,
                period: RecurrencePeriod(rawValue: item.periodRawValue) ?? .monthly,
                startDate: item.startDate,
                nextRunDate: item.nextRunDate,
                isActive: item.isActive
            )
        }
    }

    static func accounts(from backup: AppBackup) -> [Account] {
        backup.accounts.map { item in
            Account(
                id: item.id,
                name: item.name,
                institution: item.institution,
                type: AccountType(rawValue: item.typeRawValue) ?? .asset,
                category: item.category,
                currency: item.currency,
                balance: item.balance,
                note: item.note,
                isActive: item.isActive,
                updatedAt: item.updatedAt
            )
        }
    }

    private static func csvLines(header: [String], rows: [[String]]) -> String {
        ([header] + rows)
            .map { row in row.map(escapeCSVValue).joined(separator: ",") }
            .joined(separator: "\n")
    }

    private static func escapeCSVValue(_ value: String) -> String {
        guard value.contains(",") || value.contains("\"") || value.contains("\n") else {
            return value
        }

        return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
    }

    private static func parseCSV(_ text: String) throws -> [[String]] {
        var rows: [[String]] = []
        var row: [String] = []
        var field = ""
        var isInsideQuotes = false
        var index = text.startIndex

        while index < text.endIndex {
            let character = text[index]

            if character == "\"" {
                let nextIndex = text.index(after: index)
                if isInsideQuotes && nextIndex < text.endIndex && text[nextIndex] == "\"" {
                    field.append("\"")
                    index = nextIndex
                } else {
                    isInsideQuotes.toggle()
                }
            } else if character == "," && !isInsideQuotes {
                row.append(field)
                field = ""
            } else if character == "\n" && !isInsideQuotes {
                row.append(field)
                rows.append(row)
                row = []
                field = ""
            } else if character != "\r" {
                field.append(character)
            }

            index = text.index(after: index)
        }

        if !field.isEmpty || !row.isEmpty {
            row.append(field)
            rows.append(row)
        }

        return rows.filter { !$0.allSatisfy(\.isEmpty) }
    }

    private static func formatDate(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private static func parseDate(_ value: String) -> Date? {
        ISO8601DateFormatter().date(from: value)
    }

    private static func formatNumber(_ value: Double) -> String {
        String(value)
    }

    private static func parsePositiveDouble(_ value: String) -> Double? {
        guard let amount = Double(value), amount > 0 else {
            return nil
        }

        return amount
    }

    private static func parseBool(_ value: String) -> Bool? {
        switch value.lowercased() {
        case "true", "1", "si", "sí":
            true
        case "false", "0", "no":
            false
        default:
            nil
        }
    }

    private static func splitTags(_ value: String) -> [String] {
        value
            .split(separator: "|")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    private static func hasRequiredValues(_ values: [String]) -> Bool {
        values.allSatisfy { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
    }
}
