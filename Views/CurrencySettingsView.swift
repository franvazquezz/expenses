import SwiftData
import SwiftUI

struct CurrencySettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

    @State private var showingAddCurrency = false
    @State private var editingCurrency: Currency?
    @State private var showingAddRate = false
    @State private var editingRate: ExchangeRate?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.pageSpacing) {
                PageHeader(
                    title: "Monedas",
                    subtitle: "Moneda principal y cotizaciones manuales locales",
                    systemImage: "dollarsign.circle.fill",
                    actionTitle: "Agregar moneda",
                    actionSystemImage: "plus.circle.fill"
                ) {
                    showingAddCurrency = true
                }

                currenciesSection
                ratesSection
            }
            .padding()
        }
        .navigationTitle("Monedas")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddCurrency = true
                } label: {
                    Label("Agregar moneda", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddCurrency) {
            CurrencyFormView(title: "Nueva moneda") { currency in
                modelContext.insert(currency)
                if currency.isDefault {
                    CurrencyViewModel.setDefault(currency, in: currencies + [currency])
                }
            }
        }
        .sheet(item: $editingCurrency) { currency in
            CurrencyFormView(title: "Editar moneda", currency: currency) { _ in
                if currency.isDefault {
                    CurrencyViewModel.setDefault(currency, in: currencies)
                }
            }
        }
        .sheet(isPresented: $showingAddRate) {
            ExchangeRateFormView(
                title: "Nueva cotizacion",
                currencies: CurrencyViewModel.activeCurrencies(from: currencies),
                defaultBaseCurrency: CurrencyViewModel.defaultCurrencyCode(from: currencies)
            ) { rate in
                modelContext.insert(rate)
            }
        }
        .sheet(item: $editingRate) { rate in
            ExchangeRateFormView(
                title: "Editar cotizacion",
                rate: rate,
                currencies: CurrencyViewModel.activeCurrencies(from: currencies),
                defaultBaseCurrency: CurrencyViewModel.defaultCurrencyCode(from: currencies)
            ) { _ in }
        }
    }

    private var currenciesSection: some View {
        AppPanel(title: "Monedas", systemImage: "dollarsign.circle") {
            HStack {
                Spacer()

                Button {
                    showingAddCurrency = true
                } label: {
                    Label("Agregar", systemImage: "plus.circle")
                }
            }

            Table(currencies) {
                TableColumn("Codigo") { currency in
                    HStack {
                        Text(currency.code)
                            .fontWeight(.medium)
                        if currency.isDefault {
                            StatusPill(title: "Principal", systemImage: "star.fill", color: .yellow)
                        }
                    }
                }

                TableColumn("Nombre") { currency in
                    Text(currency.name)
                }

                TableColumn("Simbolo") { currency in
                    Text(currency.symbol)
                }

                TableColumn("Estado") { currency in
                    StatusPill(
                        title: currency.isActive ? "Activa" : "Inactiva",
                        systemImage: currency.isActive ? "checkmark.circle" : "pause.circle",
                        color: currency.isActive ? AppTheme.incomeColor : AppTheme.neutralColor
                    )
                }

                TableColumn("") { currency in
                    HStack {
                        Button {
                            editingCurrency = currency
                        } label: {
                            Label("Editar", systemImage: "pencil")
                        }
                        .labelStyle(.iconOnly)
                        .help("Editar")

                        Button {
                            CurrencyViewModel.setDefault(currency, in: currencies)
                        } label: {
                            Label("Principal", systemImage: "star")
                        }
                        .labelStyle(.iconOnly)
                        .disabled(currency.isDefault)
                        .help("Elegir como moneda principal")

                        Button {
                            CurrencyViewModel.deactivate(currency, in: currencies)
                        } label: {
                            Label("Desactivar", systemImage: "pause.circle")
                        }
                        .labelStyle(.iconOnly)
                        .disabled(!currency.isActive)
                        .help("Desactivar")
                    }
                }
                .width(120)
            }
            .frame(minHeight: 220)
        }
    }

    private var ratesSection: some View {
        AppPanel(title: "Cotizaciones manuales", systemImage: "arrow.left.arrow.right") {
            HStack {
                Spacer()

                Button {
                    showingAddRate = true
                } label: {
                    Label("Agregar", systemImage: "plus.circle")
                }
            }

            Table(exchangeRates) {
                TableColumn("Desde") { rate in
                    Text(rate.fromCurrency)
                }

                TableColumn("Hacia") { rate in
                    Text(rate.toCurrency)
                }

                TableColumn("Cotizacion") { rate in
                    Text(rate.rate, format: .number.precision(.fractionLength(0...6)))
                        .monospacedDigit()
                }

                TableColumn("Actualizada") { rate in
                    Text(rate.updatedAt, format: .dateTime.day().month().year().hour().minute())
                }

                TableColumn("") { rate in
                    Button {
                        editingRate = rate
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .labelStyle(.iconOnly)
                    .help("Editar")
                }
                .width(60)
            }
            .frame(minHeight: 220)
        }
    }
}

struct CurrencyFormView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let currency: Currency?
    let onSave: (Currency) -> Void

    @StateObject private var viewModel: CurrencyViewModel

    init(title: String, currency: Currency? = nil, onSave: @escaping (Currency) -> Void) {
        self.title = title
        self.currency = currency
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: CurrencyViewModel(currency: currency))
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Codigo", text: $viewModel.code)
                TextField("Nombre", text: $viewModel.name)
                TextField("Simbolo", text: $viewModel.symbol)
                Toggle("Moneda principal", isOn: $viewModel.isDefault)
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
        .frame(minWidth: 420, minHeight: 280)
    }

    private func save() {
        if let currency {
            viewModel.update(currency)
            onSave(currency)
        } else if let currency = viewModel.makeCurrency() {
            onSave(currency)
        }

        dismiss()
    }
}

struct ExchangeRateFormView: View {
    @Environment(\.dismiss) private var dismiss

    let title: String
    let rate: ExchangeRate?
    let currencies: [Currency]
    let onSave: (ExchangeRate) -> Void

    @StateObject private var viewModel: ExchangeRateViewModel

    init(
        title: String,
        rate: ExchangeRate? = nil,
        currencies: [Currency],
        defaultBaseCurrency: String,
        onSave: @escaping (ExchangeRate) -> Void
    ) {
        self.title = title
        self.rate = rate
        self.currencies = currencies
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: ExchangeRateViewModel(rate: rate, defaultBaseCurrency: defaultBaseCurrency))
    }

    var body: some View {
        NavigationStack {
            Form {
                Picker("Desde", selection: $viewModel.fromCurrency) {
                    ForEach(currencies) { currency in
                        Text(currency.code).tag(currency.code)
                    }
                }

                Picker("Hacia", selection: $viewModel.toCurrency) {
                    ForEach(currencies) { currency in
                        Text(currency.code).tag(currency.code)
                    }
                }

                TextField("Cotizacion", text: $viewModel.rateText)
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
        .frame(minWidth: 420, minHeight: 260)
    }

    private func save() {
        if let rate {
            viewModel.update(rate)
            onSave(rate)
        } else if let rate = viewModel.makeExchangeRate() {
            onSave(rate)
        }

        dismiss()
    }
}
