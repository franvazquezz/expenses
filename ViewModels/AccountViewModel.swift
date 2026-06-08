import Foundation

struct NetWorthTotal: Identifiable {
    let currency: String
    let assets: Double
    let liabilities: Double

    var id: String {
        currency
    }

    var netWorth: Double {
        assets - liabilities
    }
}

struct AccountMovementSummary: Identifiable {
    let account: Account
    let incomeTotal: Double
    let expenseTotal: Double

    var id: UUID {
        account.id
    }

    var currency: String {
        account.currency
    }

    var netFlow: Double {
        incomeTotal - expenseTotal
    }
}

struct BaseCurrencyNetWorth {
    let baseCurrency: String
    let total: Double
    let missingCurrencies: [String]
}

final class AccountViewModel: ObservableObject {
    @Published var name = ""
    @Published var institution = ""
    @Published var type = AccountType.asset {
        didSet {
            if !AccountCategoryOptions.categories(for: type).contains(category) {
                category = AccountCategoryOptions.categories(for: type).first ?? "Otro"
            }
        }
    }
    @Published var category = AccountCategoryOptions.assetCategories.first ?? "Otro"
    @Published var currency = CurrencyOptions.defaultCurrency
    @Published var balanceText = ""
    @Published var note = ""
    @Published var isActive = true

    init(account: Account? = nil) {
        guard let account else {
            return
        }

        name = account.name
        institution = account.institution
        type = account.type
        category = account.category
        currency = account.currency
        balanceText = Self.amountFormatter.string(from: NSNumber(value: account.balance)) ?? "\(account.balance)"
        note = account.note
        isActive = account.isActive
    }

    var parsedBalance: Double? {
        let normalizedBalance = balanceText
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: ",", with: ".")

        guard let balance = Double(normalizedBalance), balance >= 0 else {
            return nil
        }

        return balance
    }

    var trimmedName: String {
        name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var canSave: Bool {
        !trimmedName.isEmpty &&
        parsedBalance != nil &&
        !category.isEmpty &&
        !currency.isEmpty
    }

    func makeAccount() -> Account? {
        guard let balance = parsedBalance, canSave else {
            return nil
        }

        return Account(
            name: trimmedName,
            institution: institution.trimmingCharacters(in: .whitespacesAndNewlines),
            type: type,
            category: category,
            currency: currency,
            balance: balance,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            isActive: isActive
        )
    }

    func update(_ account: Account) {
        guard let balance = parsedBalance, canSave else {
            return
        }

        account.name = trimmedName
        account.institution = institution.trimmingCharacters(in: .whitespacesAndNewlines)
        account.type = type
        account.category = category
        account.currency = currency
        account.balance = balance
        account.note = note.trimmingCharacters(in: .whitespacesAndNewlines)
        account.isActive = isActive
        account.updatedAt = Date()
    }

    static func summaryTotals(from accounts: [Account], includeInactive: Bool = false) -> [NetWorthTotal] {
        let visibleAccounts = accounts.filter { includeInactive || $0.isActive }
        let currencies = Set(visibleAccounts.map(\.currency))

        return currencies
            .map { currency in
                let accountsForCurrency = visibleAccounts.filter { $0.currency == currency }
                let assets = accountsForCurrency
                    .filter { $0.type == .asset }
                    .reduce(0) { $0 + $1.balance }
                let liabilities = accountsForCurrency
                    .filter { $0.type == .liability }
                    .reduce(0) { $0 + $1.balance }

                return NetWorthTotal(
                    currency: currency,
                    assets: assets,
                    liabilities: liabilities
                )
            }
            .sorted { $0.currency < $1.currency }
    }

    static func accountsByType(from accounts: [Account], type: AccountType) -> [Account] {
        accounts
            .filter { $0.type == type }
            .sorted {
                if $0.isActive == $1.isActive {
                    return $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
                }

                return $0.isActive && !$1.isActive
            }
    }

    static func movementSummaries(
        accounts: [Account],
        expenses: [Expense],
        incomes: [Income],
        includeInactive: Bool = false
    ) -> [AccountMovementSummary] {
        accounts
            .filter { includeInactive || $0.isActive }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map { account in
                let expenseTotal = expenses
                    .filter {
                        $0.isConfirmed &&
                        $0.accountID == account.id &&
                        $0.originalCurrency == account.currency
                    }
                    .reduce(0) { $0 + $1.originalAmount }
                let incomeTotal = incomes
                    .filter {
                        $0.isConfirmed &&
                        $0.accountID == account.id &&
                        $0.originalCurrency == account.currency
                    }
                    .reduce(0) { $0 + $1.originalAmount }

                return AccountMovementSummary(
                    account: account,
                    incomeTotal: incomeTotal,
                    expenseTotal: expenseTotal
                )
            }
    }

    static func baseCurrencyNetWorth(
        accounts: [Account],
        baseCurrency: String,
        rates: [ExchangeRate]
    ) -> BaseCurrencyNetWorth {
        var missingCurrencies = Set<String>()
        let total = accounts
            .filter(\.isActive)
            .reduce(0) { partialResult, account in
                let signedBalance = account.type == .asset ? account.balance : -account.balance

                if account.currency == baseCurrency {
                    return partialResult + signedBalance
                }

                guard let convertedAmount = ExchangeRateViewModel.convertedAmount(
                    amount: abs(signedBalance),
                    from: account.currency,
                    to: baseCurrency,
                    rates: rates
                ) else {
                    missingCurrencies.insert(account.currency)
                    return partialResult
                }

                return partialResult + (signedBalance >= 0 ? convertedAmount : -convertedAmount)
            }

        return BaseCurrencyNetWorth(
            baseCurrency: baseCurrency,
            total: total,
            missingCurrencies: missingCurrencies.sorted()
        )
    }

    private static let amountFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = 2
        formatter.usesGroupingSeparator = false
        return formatter
    }()
}
