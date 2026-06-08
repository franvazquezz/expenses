import Foundation

final class IncomeListViewModel: ObservableObject {
    @Published var selectedMonth = MonthFilter.current
    @Published var selectedCategory = "Todas"
    @Published var searchText = ""
    @Published var selectedCurrency = "Todas"
    @Published var selectedStatus = MovementStatusFilter.all
    @Published var selectedAccountID: UUID?

    func filteredIncomes(from incomes: [Income]) -> [Income] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        return incomes.filter { income in
            selectedMonth.contains(income.date) &&
            (selectedCategory == "Todas" || income.category == selectedCategory) &&
            (selectedCurrency == "Todas" || income.originalCurrency == selectedCurrency || income.baseCurrency == selectedCurrency) &&
            (selectedAccountID == nil || income.accountID == selectedAccountID) &&
            selectedStatus.includes(isConfirmed: income.isConfirmed) &&
            (query.isEmpty || matchesSearch(query, in: income))
        }
    }

    func categoryOptions(from incomes: [Income]) -> [String] {
        let storedCategories = Set(incomes.map(\.category))
        return ["Todas"] + Array(Set(IncomeCategories.all).union(storedCategories)).sorted()
    }

    func currencyOptions(from incomes: [Income]) -> [String] {
        let currencies = Set(incomes.flatMap { [$0.originalCurrency, $0.baseCurrency] })
        return ["Todas"] + currencies.sorted()
    }

    func resetFilters() {
        selectedMonth = .current
        selectedCategory = "Todas"
        searchText = ""
        selectedCurrency = "Todas"
        selectedStatus = .all
        selectedAccountID = nil
    }

    private func matchesSearch(_ query: String, in income: Income) -> Bool {
        [
            income.incomeDescription,
            income.category,
            income.note,
            income.originalCurrency,
            income.baseCurrency
        ].contains { value in
            value.localizedCaseInsensitiveContains(query)
        }
    }
}
