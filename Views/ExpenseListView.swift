import SwiftData
import SwiftUI

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @StateObject private var viewModel = ExpenseListViewModel()
    @State private var showingAddExpense = false
    @State private var editingExpense: Expense?

    private var filteredExpenses: [Expense] {
        viewModel.filteredExpenses(from: expenses)
    }

    var body: some View {
        VStack(spacing: 0) {
            filters

            if filteredExpenses.isEmpty {
                ContentUnavailableView(
                    "Sin gastos",
                    systemImage: "tray",
                    description: Text("Agrega un gasto o cambia los filtros.")
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                expenseTable
            }
        }
        .navigationTitle("Gastos")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddExpense = true
                } label: {
                    Label("Agregar gasto", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView()
        }
        .sheet(item: $editingExpense) { expense in
            EditExpenseView(expense: expense)
        }
    }

    private var filters: some View {
        HStack(spacing: 12) {
            Picker("Mes", selection: $viewModel.selectedMonth) {
                ForEach(MonthFilter.recentMonths, id: \.self) { month in
                    Text(month.title).tag(month)
                }
            }
            .frame(width: 220)

            Picker("Categoria", selection: $viewModel.selectedCategory) {
                ForEach(viewModel.categoryOptions(from: expenses), id: \.self) { category in
                    Text(category).tag(category)
                }
            }
            .frame(width: 220)

            Spacer()

            Button {
                showingAddExpense = true
            } label: {
                Label("Agregar", systemImage: "plus.circle.fill")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
    }

    private var expenseTable: some View {
        Table(filteredExpenses) {
            TableColumn("Fecha") { expense in
                Text(expense.date, format: .dateTime.day().month().year())
            }

            TableColumn("Descripcion") { expense in
                VStack(alignment: .leading, spacing: 2) {
                    Text(expense.expenseDescription.isEmpty ? expense.category : expense.expenseDescription)
                    if !expense.tags.isEmpty {
                        Text(expense.tags.joined(separator: ", "))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            TableColumn("Categoria") { expense in
                Text(expense.category)
            }

            TableColumn("Monto") { expense in
                Text(expense.amount, format: .currency(code: expense.currency))
                    .monospacedDigit()
            }

            TableColumn("Pago") { expense in
                Text(expense.paymentMethod.isEmpty ? "-" : expense.paymentMethod)
                    .foregroundStyle(expense.paymentMethod.isEmpty ? .secondary : .primary)
            }

            TableColumn("Notas") { expense in
                Text(expense.note.isEmpty ? "-" : expense.note)
                    .foregroundStyle(expense.note.isEmpty ? .secondary : .primary)
            }

            TableColumn("") { expense in
                HStack {
                    Button {
                        editingExpense = expense
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .labelStyle(.iconOnly)
                    .help("Editar")

                    Button {
                        duplicate(expense)
                    } label: {
                        Label("Duplicar", systemImage: "doc.on.doc")
                    }
                    .labelStyle(.iconOnly)
                    .help("Duplicar")

                    Button(role: .destructive) {
                        delete(expense)
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .labelStyle(.iconOnly)
                    .help("Eliminar")
                }
            }
            .width(120)
        }
    }

    private func duplicate(_ expense: Expense) {
        modelContext.insert(viewModel.duplicate(expense))
    }

    private func delete(_ expense: Expense) {
        modelContext.delete(expense)
    }
}
