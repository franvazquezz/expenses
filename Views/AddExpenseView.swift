import SwiftData
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]
    @Query(sort: \Account.name) private var accounts: [Account]

    @StateObject private var viewModel = ExpenseFormViewModel()

    var body: some View {
        NavigationStack {
            ExpenseFormView(title: "Nuevo gasto", viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            saveExpense()
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
        }
        .frame(minWidth: 480, minHeight: 520)
        .onAppear {
            viewModel.setDefaultCurrencyIfNeeded(CurrencyViewModel.defaultCurrencyCode(from: currencies))
            viewModel.updateConversion(using: exchangeRates)
        }
    }

    private func saveExpense() {
        guard let expense = viewModel.makeExpense() else {
            return
        }

        modelContext.insert(expense)
        AccountImpactService.applyExpense(expense, to: accounts)
        dismiss()
    }
}

struct ExpenseFormView: View {
    let title: String

    @ObservedObject var viewModel: ExpenseFormViewModel
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
                    ForEach(ExpenseCategories.all, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
            }

            Section("Detalle") {
                TextField("Descripcion", text: $viewModel.expenseDescription)

                TextField("Notas", text: $viewModel.note, axis: .vertical)
                    .lineLimit(2...4)

                Picker("Metodo de pago", selection: $viewModel.paymentMethod) {
                    Text("Sin especificar").tag("")
                    ForEach(PaymentMethodOptions.all, id: \.self) { paymentMethod in
                        Text(paymentMethod).tag(paymentMethod)
                    }
                }

                Picker("Cuenta", selection: $viewModel.accountID) {
                    Text("Sin cuenta").tag(UUID?.none)
                    ForEach(accountOptions) { account in
                        Text("\(account.name) (\(account.currency))").tag(Optional(account.id))
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
