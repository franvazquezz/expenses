import SwiftData
import SwiftUI

struct IncomeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]
    @Query(sort: \Account.name) private var accounts: [Account]

    @StateObject private var viewModel = IncomeListViewModel()
    @State private var showingAddIncome = false
    @State private var editingIncome: Income?

    private var filteredIncomes: [Income] {
        viewModel.filteredIncomes(from: incomes)
    }

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Ingresos",
                subtitle: "\(filteredIncomes.count) registros para el filtro actual",
                systemImage: "arrow.down.circle.fill",
                actionTitle: "Agregar",
                actionSystemImage: "plus.circle.fill"
            ) {
                showingAddIncome = true
            }
            .padding([.horizontal, .top])

            filters

            if filteredIncomes.isEmpty {
                EmptyState(title: "Sin ingresos", systemImage: "tray", message: "Agrega un ingreso o cambia los filtros.")
            } else {
                incomeTable
            }
        }
        .navigationTitle("Ingresos")
        .accessibilityIdentifier("screen.incomes")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddIncome = true
                } label: {
                    Label("Agregar ingreso", systemImage: "plus")
                }
                .accessibilityIdentifier("incomes.addToolbarButton")
            }
        }
        .sheet(isPresented: $showingAddIncome) {
            AddIncomeView()
        }
        .sheet(item: $editingIncome) { income in
            EditIncomeView(income: income)
        }
    }

    private var filters: some View {
        FilterBar {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    TextField("Buscar", text: $viewModel.searchText)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 220)
                        .accessibilityIdentifier("incomes.searchField")

                    Picker("Mes", selection: $viewModel.selectedMonth) {
                        ForEach(MonthFilter.recentMonths, id: \.self) { month in
                            Text(month.title).tag(month)
                        }
                    }
                    .frame(width: 220)

                    Picker("Categoria", selection: $viewModel.selectedCategory) {
                        ForEach(viewModel.categoryOptions(from: incomes), id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }
                    .frame(width: 180)
                }

                HStack(spacing: 12) {
                    Picker("Moneda", selection: $viewModel.selectedCurrency) {
                        ForEach(viewModel.currencyOptions(from: incomes), id: \.self) { currency in
                            Text(currency).tag(currency)
                        }
                    }
                    .frame(width: 140)

                    Picker("Estado", selection: $viewModel.selectedStatus) {
                        ForEach(MovementStatusFilter.allCases) { status in
                            Text(status.title).tag(status)
                        }
                    }
                    .frame(width: 150)

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
                showingAddIncome = true
            } label: {
                Label("Agregar", systemImage: "plus.circle.fill")
            }
            .accessibilityIdentifier("incomes.addButton")
        }
    }

    private var incomeTable: some View {
        Table(filteredIncomes) {
            TableColumn("Fecha") { income in
                Text(income.date, format: .dateTime.day().month().year())
            }

            TableColumn("Descripcion") { income in
                Text(income.incomeDescription.isEmpty ? income.category : income.incomeDescription)
            }

            TableColumn("Categoria") { income in
                StatusPill(title: income.category, systemImage: "tag", color: AppTheme.incomeColor)
            }

            TableColumn("Monto") { income in
                VStack(alignment: .leading, spacing: 2) {
                    Text(income.originalAmount, format: .currency(code: income.originalCurrency))
                        .monospacedDigit()

                    if income.originalCurrency != income.baseCurrency ||
                        income.originalAmount != income.convertedAmount {
                        Text(income.convertedAmount, format: .currency(code: income.baseCurrency))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }

            TableColumn("Cuenta") { income in
                Text(AccountImpactService.accountName(for: income.accountID, in: accounts))
                    .foregroundStyle(income.accountID == nil ? .secondary : .primary)
            }

            TableColumn("Estado") { income in
                StatusPill(
                    title: income.isConfirmed ? "Confirmado" : "Pendiente",
                    systemImage: income.isConfirmed ? "checkmark.circle" : "clock",
                    color: income.isConfirmed ? AppTheme.incomeColor : AppTheme.budgetColor
                )
            }

            TableColumn("Notas") { income in
                Text(income.note.isEmpty ? "-" : income.note)
                    .foregroundStyle(income.note.isEmpty ? .secondary : .primary)
            }

            TableColumn("") { income in
                HStack {
                    Button {
                        editingIncome = income
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .labelStyle(.iconOnly)
                    .help("Editar")

                    Button {
                        toggleConfirmation(for: income)
                    } label: {
                        Label(income.isConfirmed ? "Marcar pendiente" : "Confirmar", systemImage: income.isConfirmed ? "clock" : "checkmark.circle")
                    }
                    .labelStyle(.iconOnly)
                    .help(income.isConfirmed ? "Marcar pendiente" : "Confirmar")

                    Button(role: .destructive) {
                        delete(income)
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .labelStyle(.iconOnly)
                    .help("Eliminar")
                }
            }
            .width(110)
        }
    }

    private func delete(_ income: Income) {
        AccountImpactService.revertIncome(income, in: accounts)
        modelContext.delete(income)
    }

    private func toggleConfirmation(for income: Income) {
        if income.isConfirmed {
            AccountImpactService.revertIncome(income, in: accounts)
            income.isConfirmed = false
        } else {
            income.isConfirmed = true
            AccountImpactService.applyIncome(income, to: accounts)
        }
    }
}
