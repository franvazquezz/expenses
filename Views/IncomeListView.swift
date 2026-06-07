import SwiftData
import SwiftUI

struct IncomeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]

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
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddIncome = true
                } label: {
                    Label("Agregar ingreso", systemImage: "plus")
                }
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
            .frame(width: 220)

            Spacer()

            Button {
                showingAddIncome = true
            } label: {
                Label("Agregar", systemImage: "plus.circle.fill")
            }
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

                    Button(role: .destructive) {
                        delete(income)
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .labelStyle(.iconOnly)
                    .help("Eliminar")
                }
            }
            .width(80)
        }
    }

    private func delete(_ income: Income) {
        modelContext.delete(income)
    }
}
