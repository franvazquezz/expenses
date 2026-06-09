import SwiftData
import SwiftUI

struct RecurringExpenseListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \RecurringExpense.nextRunDate) private var recurringExpenses: [RecurringExpense]

    @State private var showingAddRecurringExpense = false
    @State private var editingRecurringExpense: RecurringExpense?

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Gastos recurrentes",
                subtitle: "\(recurringExpenses.count) plantillas configuradas",
                systemImage: "repeat.circle.fill",
                actionTitle: "Agregar",
                actionSystemImage: "plus.circle.fill"
            ) {
                showingAddRecurringExpense = true
            }
            .padding([.horizontal, .top])

            FilterBar {
                Text("Generacion automatica al abrir la app")
                    .font(.headline)

                Spacer()

                Button {
                    generateDueExpenses()
                } label: {
                    Label("Generar pendientes", systemImage: "wand.and.stars")
                }
                .accessibilityIdentifier("recurringExpenses.generateDueButton")
            }

            if recurringExpenses.isEmpty {
                EmptyState(
                    title: "Sin gastos recurrentes",
                    systemImage: "repeat.circle",
                    message: "Agrega Netflix, Spotify, alquiler, expensas o servicios para generar gastos automaticamente."
                )
            } else {
                recurringExpenseTable
            }
        }
        .navigationTitle("Recurrentes")
        .accessibilityIdentifier("screen.recurringExpenses")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddRecurringExpense = true
                } label: {
                    Label("Agregar recurrente", systemImage: "plus")
                }
                .accessibilityIdentifier("recurringExpenses.addToolbarButton")
            }
        }
        .sheet(isPresented: $showingAddRecurringExpense) {
            RecurringExpenseFormView(title: "Nuevo recurrente") { recurringExpense in
                modelContext.insert(recurringExpense)
            }
        }
        .sheet(item: $editingRecurringExpense) { recurringExpense in
            RecurringExpenseFormView(title: "Editar recurrente", recurringExpense: recurringExpense) { _ in }
        }
    }

    private var recurringExpenseTable: some View {
        Table(recurringExpenses) {
            TableColumn("Nombre") { recurringExpense in
                VStack(alignment: .leading, spacing: 2) {
                    Text(recurringExpense.name)
                        .fontWeight(.medium)
                    Text(recurringExpense.expenseDescription.isEmpty ? recurringExpense.category : recurringExpense.expenseDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            TableColumn("Periodicidad") { recurringExpense in
                StatusPill(title: recurringExpense.period.title, systemImage: "calendar", color: AppTheme.budgetColor)
            }

            TableColumn("Proxima") { recurringExpense in
                Text(recurringExpense.nextRunDate, format: .dateTime.day().month().year())
            }

            TableColumn("Monto") { recurringExpense in
                VStack(alignment: .leading, spacing: 2) {
                    Text(recurringExpense.originalAmount, format: .currency(code: recurringExpense.originalCurrency))
                        .monospacedDigit()

                    if recurringExpense.originalCurrency != recurringExpense.baseCurrency ||
                        recurringExpense.originalAmount != recurringExpense.convertedAmount {
                        Text(recurringExpense.convertedAmount, format: .currency(code: recurringExpense.baseCurrency))
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .monospacedDigit()
                    }
                }
            }

            TableColumn("Estado") { recurringExpense in
                StatusPill(
                    title: recurringExpense.isActive ? "Activo" : "Inactivo",
                    systemImage: recurringExpense.isActive ? "checkmark.circle" : "pause.circle",
                    color: recurringExpense.isActive ? AppTheme.incomeColor : AppTheme.neutralColor
                )
            }

            TableColumn("") { recurringExpense in
                HStack {
                    Button {
                        editingRecurringExpense = recurringExpense
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .labelStyle(.iconOnly)
                    .help("Editar")

                    Button {
                        recurringExpense.isActive.toggle()
                    } label: {
                        Label(recurringExpense.isActive ? "Desactivar" : "Activar", systemImage: recurringExpense.isActive ? "pause.circle" : "play.circle")
                    }
                    .labelStyle(.iconOnly)
                    .help(recurringExpense.isActive ? "Desactivar" : "Activar")

                    Button(role: .destructive) {
                        modelContext.delete(recurringExpense)
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

    private func generateDueExpenses() {
        for recurringExpense in recurringExpenses {
            let result = RecurringExpenseViewModel.generatedExpenses(for: recurringExpense)
            for expense in result.createdExpenses {
                modelContext.insert(expense)
            }
            recurringExpense.nextRunDate = result.nextRunDate
        }
    }
}

struct RecurringExpenseFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

    let title: String
    let recurringExpense: RecurringExpense?
    let onSave: (RecurringExpense) -> Void

    @StateObject private var viewModel: RecurringExpenseViewModel

    init(title: String, recurringExpense: RecurringExpense? = nil, onSave: @escaping (RecurringExpense) -> Void) {
        self.title = title
        self.recurringExpense = recurringExpense
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: RecurringExpenseViewModel(recurringExpense: recurringExpense))
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
                            if recurringExpense == nil {
                                viewModel.nextRunDate = viewModel.startDate
                            }
                        }

                    DatePicker("Proxima generacion", selection: $viewModel.nextRunDate, displayedComponents: .date)
                    Toggle("Activo", isOn: $viewModel.isActive)
                }

                Section("Gasto") {
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
                        ForEach(ExpenseCategories.all, id: \.self) { category in
                            Text(category).tag(category)
                        }
                    }

                    TextField("Descripcion", text: $viewModel.expenseDescription)
                    TextField("Notas", text: $viewModel.note, axis: .vertical)
                        .lineLimit(2...4)

                    Picker("Metodo de pago", selection: $viewModel.paymentMethod) {
                        Text("Sin especificar").tag("")
                        ForEach(PaymentMethodOptions.all, id: \.self) { paymentMethod in
                            Text(paymentMethod).tag(paymentMethod)
                        }
                    }

                    TextField("Etiquetas separadas por coma", text: $viewModel.tagsText)
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
        .frame(minWidth: 520, minHeight: 660)
        .onAppear {
            viewModel.setDefaultCurrencyIfNeeded(CurrencyViewModel.defaultCurrencyCode(from: currencies))
            viewModel.updateConversion(using: exchangeRates)
        }
    }

    private func save() {
        if let recurringExpense {
            viewModel.update(recurringExpense)
            onSave(recurringExpense)
        } else if let recurringExpense = viewModel.makeRecurringExpense() {
            onSave(recurringExpense)
        }

        dismiss()
    }
}
