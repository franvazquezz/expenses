import Foundation

final class IncomeListViewModel: ObservableObject {
    @Published var selectedMonth = MonthFilter.current
    @Published var selectedCategory = "Todas"

    func filteredIncomes(from incomes: [Income]) -> [Income] {
        incomes.filter { income in
            selectedMonth.contains(income.date) &&
            (selectedCategory == "Todas" || income.category == selectedCategory)
        }
    }

    func categoryOptions(from incomes: [Income]) -> [String] {
        let storedCategories = Set(incomes.map(\.category))
        return ["Todas"] + Array(Set(IncomeCategories.all).union(storedCategories)).sorted()
    }
}
