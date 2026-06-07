import SwiftData
import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

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
    }

    private func saveExpense() {
        guard let expense = viewModel.makeExpense() else {
            return
        }

        modelContext.insert(expense)
        dismiss()
    }
}

struct ExpenseFormView: View {
    let title: String

    @ObservedObject var viewModel: ExpenseFormViewModel

    var body: some View {
        Form {
            Section("Datos principales") {
                TextField("Monto", text: $viewModel.amountText)
                    .textFieldStyle(.roundedBorder)

                Picker("Moneda", selection: $viewModel.currency) {
                    ForEach(CurrencyOptions.all, id: \.self) { currency in
                        Text(currency).tag(currency)
                    }
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

                TextField("Etiquetas separadas por coma", text: $viewModel.tagsText)
            }
        }
        .formStyle(.grouped)
        .navigationTitle(title)
        .padding()
    }
}
