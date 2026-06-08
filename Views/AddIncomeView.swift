import SwiftData
import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]
    @Query(sort: \Account.name) private var accounts: [Account]

    @StateObject private var viewModel = IncomeFormViewModel()

    var body: some View {
        NavigationStack {
            IncomeFormView(title: "Nuevo ingreso", viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            saveIncome()
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
        }
        .frame(minWidth: 480, minHeight: 460)
        .onAppear {
            viewModel.setDefaultCurrencyIfNeeded(CurrencyViewModel.defaultCurrencyCode(from: currencies))
            viewModel.updateConversion(using: exchangeRates)
        }
    }

    private func saveIncome() {
        guard let income = viewModel.makeIncome() else {
            return
        }

        modelContext.insert(income)
        AccountImpactService.applyIncome(income, to: accounts)
        dismiss()
    }
}

struct IncomeFormView: View {
    let title: String

    @ObservedObject var viewModel: IncomeFormViewModel
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]
    @Query(sort: \Account.name) private var accounts: [Account]

    private var activeCurrencies: [Currency] {
        CurrencyViewModel.activeCurrencies(from: currencies)
    }

    private var accountOptions: [Account] {
        AccountImpactService.accountOptions(for: accounts, currency: viewModel.currency)
    }

    var body: some View {
        Form {
            Section("Datos principales") {
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
                    clearAccountIfNeeded()
                    viewModel.updateConversion(using: exchangeRates)
                }

                DatePicker("Fecha", selection: $viewModel.date, displayedComponents: .date)

                Picker("Categoria", selection: $viewModel.category) {
                    ForEach(IncomeCategories.all, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }

            Section("Detalle") {
                TextField("Descripcion", text: $viewModel.incomeDescription)

                TextField("Notas", text: $viewModel.note, axis: .vertical)
                    .lineLimit(2...4)

                Picker("Cuenta", selection: $viewModel.accountID) {
                    Text("Sin cuenta").tag(UUID?.none)
                    ForEach(accountOptions) { account in
                        Text("\(account.name) (\(account.currency))").tag(Optional(account.id))
                    }
                }
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
        .navigationTitle(title)
        .padding()
    }

    private func clearAccountIfNeeded() {
        guard let accountID = viewModel.accountID else {
            return
        }

        if !AccountImpactService.accountOptions(for: accounts, currency: viewModel.currency).contains(where: { $0.id == accountID }) {
            viewModel.accountID = nil
        }
    }
}
