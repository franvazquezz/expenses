import SwiftData
import SwiftUI

struct RecurringIncomeListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringIncome.nextRunDate) private var recurringIncomes: [RecurringIncome]

    @State private var showingAddRecurringIncome = false
    @State private var editingRecurringIncome: RecurringIncome?

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Ingresos recurrentes",
                subtitle: "\(recurringIncomes.count) plantillas configuradas",
                systemImage: "repeat.circle.fill",
                actionTitle: "Agregar",
                actionSystemImage: "plus.circle.fill"
            ) {
                showingAddRecurringIncome = true
            }
            .padding([.horizontal, .top])

            FilterBar {
                Text("Generacion automatica al abrir la app")
                    .font(.headline)

                Spacer()

                Button {
                    generateDueIncomes()
                } label: {
                    Label("Generar pendientes", systemImage: "wand.and.stars")
                }
            }

            if recurringIncomes.isEmpty {
                EmptyState(
                    title: "Sin ingresos recurrentes",
                    systemImage: "repeat.circle",
                    message: "Agrega sueldo, honorarios o alquileres para generar ingresos automaticamente."
                )
            } else {
                recurringIncomeTable
            }
        }
        .navigationTitle("Ingresos recurrentes")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddRecurringIncome = true
                } label: {
                    Label("Agregar recurrente", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddRecurringIncome) {
            RecurringIncomeFormView(title: "Nuevo ingreso recurrente") { recurringIncome in
                modelContext.insert(recurringIncome)
            }
        }
        .sheet(item: $editingRecurringIncome) { recurringIncome in
            RecurringIncomeFormView(title: "Editar ingreso recurrente", recurringIncome: recurringIncome) { _ in }
        }
    }

    private var recurringIncomeTable: some View {
        Table(recurringIncomes) {
            TableColumn("Nombre") { recurringIncome in
                VStack(alignment: .leading, spacing: 2) {
                    Text(recurringIncome.name)
                        .fontWeight(.medium)
                    Text(recurringIncome.incomeDescription.isEmpty ? recurringIncome.category : recurringIncome.incomeDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            TableColumn("Periodicidad") { recurringIncome in
                StatusPill(title: recurringIncome.period.title, systemImage: "calendar", color: AppTheme.budgetColor)
            }

            TableColumn("Proxima") { recurringIncome in
                Text(recurringIncome.nextRunDate, format: .dateTime.day().month().year())
            }

            TableColumn("Monto") { recurringIncome in
                VStack(alignment: .leading, spacing: 2) {
                    Text(recurringIncome.originalAmount, format: .currency(code: recurringIncome.originalCurrency))
                        .monospacedDigit()

                    if recurringIncome.originalCurrency != recurringIncome.baseCurrency ||
                        recurringIncome.originalAmount != recurringIncome.convertedAmount {
                        Text(recurringIncome.convertedAmount, format: .currency(code: recurringIncome.baseCurrency))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }

            TableColumn("Estado") { recurringIncome in
                StatusPill(
                    title: recurringIncome.isActive ? "Activo" : "Inactivo",
                    systemImage: recurringIncome.isActive ? "checkmark.circle" : "pause.circle",
                    color: recurringIncome.isActive ? AppTheme.incomeColor : AppTheme.neutralColor
                )
            }

            TableColumn("") { recurringIncome in
                HStack {
                    Button {
                        editingRecurringIncome = recurringIncome
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .labelStyle(.iconOnly)
                    .help("Editar")

                    Button {
                        recurringIncome.isActive.toggle()
                    } label: {
                        Label(recurringIncome.isActive ? "Desactivar" : "Activar", systemImage: recurringIncome.isActive ? "pause.circle" : "play.circle")
                    }
                    .labelStyle(.iconOnly)
                    .help(recurringIncome.isActive ? "Desactivar" : "Activar")

                    Button(role: .destructive) {
                        modelContext.delete(recurringIncome)
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

    private func generateDueIncomes() {
        for recurringIncome in recurringIncomes {
            let result = RecurringIncomeViewModel.generatedIncomes(for: recurringIncome)
            for income in result.createdIncomes {
                modelContext.insert(income)
            }
            recurringIncome.nextRunDate = result.nextRunDate
        }
    }
}

struct RecurringIncomeFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

    let title: String
    let recurringIncome: RecurringIncome?
    let onSave: (RecurringIncome) -> Void

    @StateObject private var viewModel: RecurringIncomeViewModel

    init(title: String, recurringIncome: RecurringIncome? = nil, onSave: @escaping (RecurringIncome) -> Void) {
        self.title = title
        self.recurringIncome = recurringIncome
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: RecurringIncomeViewModel(recurringIncome: recurringIncome))
    }

    private var activeCurrencies: [Currency] {
        CurrencyViewModel.activeCurrencies(from: currencies)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Recurrencia") {
                    TextField("Nombre", text: $viewModel.name)

                    Picker("Periodicidad", selection: $viewModel.period) {
                        ForEach(RecurrencePeriod.allCases) { period in
                            Text(period.title).tag(period)
                        }
                    }

                    DatePicker("Inicio", selection: $viewModel.startDate, displayedComponents: .date)
                        .onChange(of: viewModel.startDate) {
                            if recurringIncome == nil {
                                viewModel.nextRunDate = viewModel.startDate
                            }
                        }

                    DatePicker("Proxima generacion", selection: $viewModel.nextRunDate, displayedComponents: .date)
                    Toggle("Activo", isOn: $viewModel.isActive)
                }

                Section("Ingreso") {
                    TextField("Monto", text: $viewModel.amountText)
                        .textFieldStyle(.roundedBorder)
                        .onChange(of: viewModel.amountText) {
                            viewModel.updateConversion(using: exchangeRates)
                        }

                    Picker("Moneda", selection: $viewModel.currency) {
                        ForEach(activeCurrencies) { currency in
                            Text("\(currency.code) - \(currency.name)").tag(currency.code)
                        }
                    }
                    .onChange(of: viewModel.currency) {
                        viewModel.updateConversion(using: exchangeRates)
                    }

                    Picker("Categoria", selection: $viewModel.category) {
                        ForEach(IncomeCategories.all, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }

                    TextField("Descripcion", text: $viewModel.incomeDescription)
                    TextField("Notas", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)
                }

                Section("Conversion") {
                    Picker("Moneda principal", selection: $viewModel.baseCurrency) {
                        ForEach(activeCurrencies) { currency in
                            Text("\(currency.code) - \(currency.name)").tag(currency.code)
                        }
                    }
                    .onChange(of: viewModel.baseCurrency) {
                        viewModel.updateConversion(using: exchangeRates)
                    }

                    TextField("Monto convertido", text: $viewModel.convertedAmountText)
                        .textFieldStyle(.roundedBorder)

                    if viewModel.needsConversion {
                        Text("Se calcula con la cotizacion manual disponible. Si no existe, podes cargar el monto convertido manualmente.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
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
        .frame(minWidth: 520, minHeight: 620)
        .onAppear {
            viewModel.setDefaultCurrencyIfNeeded(CurrencyViewModel.defaultCurrencyCode(from: currencies))
            viewModel.updateConversion(using: exchangeRates)
        }
    }

    private func save() {
        if let recurringIncome {
            viewModel.update(recurringIncome)
            onSave(recurringIncome)
        } else if let recurringIncome = viewModel.makeRecurringIncome() {
            onSave(recurringIncome)
        }

        dismiss()
    }
}
