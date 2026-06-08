import Foundation

final class ExpenseListViewModel: ObservableObject {
    @Published var selectedMonth = MonthFilter.current
    @Published var selectedCategory = "Todas"
    @Published var searchText = ""
    @Published var selectedTag = "Todas"
    @Published var selectedCurrency = "Todas"
    @Published var selectedPaymentMethod = "Todos"
    @Published var selectedStatus = MovementStatusFilter.all
    @Published var selectedAccountID: UUID?

    func filteredExpenses(from expenses: [Expense]) -> [Expense] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return expenses.filter { expense in
            selectedMonth.contains(expense.date) &&
            (selectedCategory == "Todas" || expense.category == selectedCategory) &&
            (selectedTag == "Todas" || expense.tags.contains(selectedTag)) &&
            (selectedCurrency == "Todas" || expense.originalCurrency == selectedCurrency || expense.baseCurrency == selectedCurrency) &&
            (selectedPaymentMethod == "Todos" || expense.paymentMethod == selectedPaymentMethod) &&
            (selectedAccountID == nil || expense.accountID == selectedAccountID) &&
            selectedStatus.includes(isConfirmed: expense.isConfirmed) &&
            (query.isEmpty || matchesSearch(query, in: expense))
        }
    }

    func categoryOptions(from expenses: [Expense]) -> [String] {
        let storedCategories = Set(expenses.map(\.category))
        return ["Todas"] + Array(Set(ExpenseCategories.all).union(storedCategories)).sorted()
    }

    func tagOptions(from expenses: [Expense]) -> [String] {
        let tags = Set(expenses.flatMap(\.tags))
        return ["Todas"] + tags.sorted()
    }

    func currencyOptions(from expenses: [Expense]) -> [String] {
        let currencies = Set(expenses.flatMap { [$0.originalCurrency, $0.baseCurrency] })
        return ["Todas"] + currencies.sorted()
    }

    func paymentMethodOptions(from expenses: [Expense]) -> [String] {
        let storedMethods = Set(expenses.map(\.paymentMethod).filter { !$0.isEmpty })
        return ["Todos"] + Array(Set(PaymentMethodOptions.all).union(storedMethods)).sorted()
    }

    func resetFilters() {
        selectedMonth = .current
        selectedCategory = "Todas"
        searchText = ""
        selectedTag = "Todas"
        selectedCurrency = "Todas"
        selectedPaymentMethod = "Todos"
        selectedStatus = .all
        selectedAccountID = nil
    }

    func duplicate(_ expense: Expense) -> Expense {
        Expense(
            amount: expense.originalAmount,
            currency: expense.originalCurrency,
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
    }

    private func matchesSearch(_ query: String, in expense: Expense) -> Bool {
        let searchableValues = [
            expense.expenseDescription,
            expense.category,
            expense.note,
            expense.paymentMethod,
            expense.originalCurrency,
            expense.baseCurrency
        ] + expense.tags

        return searchableValues.contains { value in
            value.localizedCaseInsensitiveContains(query)
        }
    }
}

enum MovementStatusFilter: String, CaseIterable, Identifiable {
    case all
    case confirmed
    case pending

    var id: String { rawValue }

    var title: String {
        switch self {
        case .all:
            "Todos"
        case .confirmed:
            "Confirmados"
        case .pending:
            "Pendientes"
        }
    }

    func includes(isConfirmed: Bool) -> Bool {
        switch self {
        case .all:
            true
        case .confirmed:
            isConfirmed
        case .pending:
            !isConfirmed
        }
    }
}

struct MonthFilter: Hashable {
    let start: Date
    let end: Date

    var title: String {
        start.formatted(.dateTime.month(.wide).year())
    }

    static var current: MonthFilter {
        MonthFilter(containing: Date())
    }

    static var recentMonths: [MonthFilter] {
        let calendar = Calendar.current
        return (0..<18).compactMap { offset in
            guard let date = calendar.date(byAdding: .month, value: -offset, to: Date()) else {
                return nil
            }

            return MonthFilter(containing: date)
        }
    }

    init(containing date: Date) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        let start = calendar.date(from: components) ?? date
        let end = calendar.date(byAdding: .month, value: 1, to: start) ?? date

        self.start = start
        self.end = end
    }

    func contains(_ date: Date) -> Bool {
        date >= start && date < end
    }
}
