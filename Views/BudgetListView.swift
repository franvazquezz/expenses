import SwiftData
import SwiftUI

struct BudgetListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Budget.category) private var budgets: [Budget]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]

    @State private var showingAddBudget = false
    @State private var editingBudget: Budget?

    private var progressItems: [BudgetProgress] {
        BudgetViewModel.progress(for: budgets, expenses: expenses, includeInactive: true)
    }

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Presupuestos",
                subtitle: "\(progressItems.count) presupuestos del mes actual",
                systemImage: "chart.bar.doc.horizontal",
                actionTitle: "Agregar",
                actionSystemImage: "plus.circle.fill"
            ) {
                showingAddBudget = true
            }
            .padding([.horizontal, .top])

            header

            if progressItems.isEmpty {
                EmptyState(
                    title: "Sin presupuestos",
                    systemImage: "chart.bar.doc.horizontal",
                    message: "Agrega presupuestos por categoria para este mes."
                )
            } else {
                budgetTable
            }
        }
        .navigationTitle("Presupuestos")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddBudget = true
                } label: {
                    Label("Agregar presupuesto", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddBudget) {
            BudgetFormView(title: "Nuevo presupuesto") { budget in
                modelContext.insert(budget)
            }
        }
        .sheet(item: $editingBudget) { budget in
            BudgetFormView(title: "Editar presupuesto", budget: budget) { _ in }
        }
    }

    private var header: some View {
        FilterBar {
            Text("Presupuestos del mes")
                .font(.headline)

            Spacer()

            Button {
                showingAddBudget = true
            } label: {
                Label("Agregar", systemImage: "plus.circle.fill")
            }
        }
    }

    private var budgetTable: some View {
        Table(progressItems) {
            TableColumn("Categoria") { item in
                StatusPill(title: item.budget.category, systemImage: "tag", color: AppTheme.budgetColor)
            }

            TableColumn("Consumido") { item in
                Text(item.consumed, format: .currency(code: item.budget.currency))
                    .monospacedDigit()
            }

            TableColumn("Restante") { item in
                Text(item.remaining, format: .currency(code: item.budget.currency))
                    .monospacedDigit()
            }

            TableColumn("Porcentaje") { item in
                VStack(alignment: .leading, spacing: 6) {
                    ProgressView(value: item.percentage)
                        .tint(color(for: item.percentage))
                    Text(item.percentageText)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            TableColumn("Estado") { item in
                Text(item.budget.isActive ? "Activo" : "Inactivo")
                    .foregroundStyle(item.budget.isActive ? .primary : .secondary)
            }

            TableColumn("") { item in
                HStack {
                    Button {
                        editingBudget = item.budget
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .labelStyle(.iconOnly)
                    .help("Editar")

                    Button {
                        item.budget.isActive.toggle()
                    } label: {
                        Label(item.budget.isActive ? "Desactivar" : "Activar", systemImage: item.budget.isActive ? "pause.circle" : "play.circle")
                    }
                    .labelStyle(.iconOnly)
                    .help(item.budget.isActive ? "Desactivar" : "Activar")
                }
            }
            .width(80)
        }
    }

    private func color(for percentage: Double) -> Color {
        switch percentage {
        case 0..<0.7:
            return AppTheme.incomeColor
        case 0..<0.9:
            return .orange
        default:
            return AppTheme.expenseColor
        }
    }
}

struct BudgetFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Currency.code) private var currencies: [Currency]

    let title: String
    let budget: Budget?
    let onSave: (Budget) -> Void

    @StateObject private var viewModel: BudgetViewModel

    init(title: String, budget: Budget? = nil, onSave: @escaping (Budget) -> Void) {
        self.title = title
        self.budget = budget
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: BudgetViewModel(budget: budget))
    }

    private var activeCurrencies: [Currency] {
        CurrencyViewModel.activeCurrencies(from: currencies)
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Mes", selection: $viewModel.selectedMonth) {
                    ForEach(MonthFilter.recentMonths, id: \.self) { month in
                        Text(month.title).tag(month)
                    }
                }

                Picker("Categoria", selection: $viewModel.category) {
                    ForEach(ExpenseCategories.all, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }

                TextField("Monto", text: $viewModel.amountText)
                    .textFieldStyle(.roundedBorder)

                Picker("Moneda", selection: $viewModel.currency) {
                    ForEach(activeCurrencies) { currency in
                        Text("\(currency.code) - \(currency.name)").tag(currency.code)
                    }
                }
            }
            .formStyle(.grouped)
            .padding()
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancelar") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Guardar") {
                        save()
                    }
                    .disabled(!viewModel.canSave)
                }
            }
        }
        .frame(minWidth: 420, minHeight: 320)
        .onAppear {
            if viewModel.currency.isEmpty {
                viewModel.currency = CurrencyViewModel.defaultCurrencyCode(from: currencies)
            }
        }
    }

    private func save() {
        if let budget {
            viewModel.update(budget)
            onSave(budget)
        } else if let budget = viewModel.makeBudget() {
            onSave(budget)
        }

        dismiss()
    }
}
