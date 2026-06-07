import Foundation

final class ExpenseListViewModel: ObservableObject {
    @Published var selectedMonth = MonthFilter.current
    @Published var selectedCategory = "Todas"

    func filteredExpenses(from expenses: [Expense]) -> [Expense] {
        expenses.filter { expense in
            selectedMonth.contains(expense.date) &&
            (selectedCategory == "Todas" || expense.category == selectedCategory)
        }
    }

    func categoryOptions(from expenses: [Expense]) -> [String] {
        let storedCategories = Set(expenses.map(\.category))
        return ["Todas"] + Array(Set(ExpenseCategories.all).union(storedCategories)).sorted()
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
            tags: expense.tags
        )
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
