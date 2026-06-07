import SwiftData
import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

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
        dismiss()
    }
}

struct IncomeFormView: View {
    let title: String

    @ObservedObject var viewModel: IncomeFormViewModel
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

    private var activeCurrencies: [Currency] {
        CurrencyViewModel.activeCurrencies(from: currencies)
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
}
