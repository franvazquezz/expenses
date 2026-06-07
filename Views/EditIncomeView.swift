import SwiftData
import SwiftUI

struct EditIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

    let income: Income

    @StateObject private var viewModel: IncomeFormViewModel

    init(income: Income) {
        self.income = income
        _viewModel = StateObject(wrappedValue: IncomeFormViewModel(income: income))
    }

    var body: some View {
        NavigationStack {
            IncomeFormView(title: "Editar ingreso", viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            updateIncome()
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
        }
        .frame(minWidth: 480, minHeight: 460)
        .onAppear {
            viewModel.updateConversion(using: exchangeRates)
        }
    }

    private func updateIncome() {
        viewModel.update(income)
        dismiss()
    }
}
