import SwiftData
import SwiftUI

struct ExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \Account.name) private var accounts: [Account]

    @StateObject private var viewModel = ExpenseListViewModel()
    @State private var showingAddExpense = false
    @State private var editingExpense: Expense?

    private var filteredExpenses: [Expense] {
        viewModel.filteredExpenses(from: expenses)
    }

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Gastos",
                subtitle: "\(filteredExpenses.count) registros para el filtro actual",
                systemImage: "arrow.up.circle.fill",
                actionTitle: "Agregar",
                actionSystemImage: "plus.circle.fill"
            ) {
                showingAddExpense = true
            }
            .padding([.horizontal, .top])

            filters

            if filteredExpenses.isEmpty {
                EmptyState(title: "Sin gastos", systemImage: "tray", message: "Agrega un gasto o cambia los filtros.")
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
        FilterBar {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    TextField("Buscar", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 220)

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
                    .frame(width: 180)

                    Picker("Estado", selection: $viewModel.selectedStatus) {
                        ForEach(MovementStatusFilter.allCases) { status in
                            Text(status.title).tag(status)
                        }
                    }
                    .frame(width: 150)
                }

                HStack(spacing: 12) {
                    Picker("Etiqueta", selection: $viewModel.selectedTag) {
                        ForEach(viewModel.tagOptions(from: expenses), id: \.self) { tag in
                            Text(tag).tag(tag)
                        }
                    }
                    .frame(width: 180)

                    Picker("Moneda", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.currencyOptions(from: expenses), id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .frame(width: 140)

                    Picker("Pago", selection: $viewModel.selectedPaymentMethod) {
                        ForEach(viewModel.paymentMethodOptions(from: expenses), id: \.self) { paymentMethod in
                            Text(paymentMethod).tag(paymentMethod)
                        }
                    }
                    .frame(width: 180)

                    Picker("Cuenta", selection: $viewModel.selectedAccountID) {
                        Text("Todas").tag(UUID?.none)
                        ForEach(accounts.sorted { $0.name < $1.name }) { account in
                            Text(account.name).tag(Optional(account.id))
                        }
                    }
                    .frame(width: 180)

                    Button {
                        viewModel.resetFilters()
                    } label: {
                        Label("Limpiar", systemImage: "xmark.circle")
                    }
                }
            }

            Spacer()

            Button {
                showingAddExpense = true
            } label: {
                Label("Agregar", systemImage: "plus.circle.fill")
            }
        }
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
                StatusPill(title: expense.category, systemImage: "tag", color: AppTheme.expenseColor)
            }

            TableColumn("Monto") { expense in
                VStack(alignment: .leading, spacing: 2) {
                    Text(expense.originalAmount, format: .currency(code: expense.originalCurrency))
                        .monospacedDigit()

                    if expense.originalCurrency != expense.baseCurrency ||
                        expense.originalAmount != expense.convertedAmount {
                        Text(expense.convertedAmount, format: .currency(code: expense.baseCurrency))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }

            TableColumn("Pago") { expense in
                Text(expense.paymentMethod.isEmpty ? "-" : expense.paymentMethod)
                    .foregroundStyle(expense.paymentMethod.isEmpty ? .secondary : .primary)
            }

            TableColumn("Cuenta") { expense in
                Text(AccountImpactService.accountName(for: expense.accountID, in: accounts))
                    .foregroundStyle(expense.accountID == nil ? .secondary : .primary)
            }

            TableColumn("Estado") { expense in
                StatusPill(
                    title: expense.isConfirmed ? "Confirmado" : "Pendiente",
                    systemImage: expense.isConfirmed ? "checkmark.circle" : "clock",
                    color: expense.isConfirmed ? AppTheme.incomeColor : AppTheme.budgetColor
                )
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

                    Button {
                        toggleConfirmation(for: expense)
                    } label: {
                        Label(expense.isConfirmed ? "Marcar pendiente" : "Confirmar", systemImage: expense.isConfirmed ? "clock" : "checkmark.circle")
                    }
                    .labelStyle(.iconOnly)
                    .help(expense.isConfirmed ? "Marcar pendiente" : "Confirmar")

                    Button(role: .destructive) {
                        delete(expense)
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .labelStyle(.iconOnly)
                    .help("Eliminar")
                }
            }
            .width(150)
        }
    }

    private func duplicate(_ expense: Expense) {
        let duplicatedExpense = viewModel.duplicate(expense)
        modelContext.insert(duplicatedExpense)
        AccountImpactService.applyExpense(duplicatedExpense, to: accounts)
    }

    private func delete(_ expense: Expense) {
        AccountImpactService.revertExpense(expense, in: accounts)
        modelContext.delete(expense)
    }

    private func toggleConfirmation(for expense: Expense) {
        if expense.isConfirmed {
            AccountImpactService.revertExpense(expense, in: accounts)
            expense.isConfirmed = false
        } else {
            expense.isConfirmed = true
            AccountImpactService.applyExpense(expense, to: accounts)
        }
    }
}
