import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss

    let expense: Expense

    @StateObject private var viewModel: ExpenseFormViewModel

    init(expense: Expense) {
        self.expense = expense
        _viewModel = StateObject(wrappedValue: ExpenseFormViewModel(expense: expense))
    }

    var body: some View {
        NavigationStack {
            ExpenseFormView(title: "Editar gasto", viewModel: viewModel)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancelar") {
                            dismiss()
                        }
                    }

                    ToolbarItem(placement: .confirmationAction) {
                        Button("Guardar") {
                            updateExpense()
                        }
                        .disabled(!viewModel.canSave)
                    }
                }
        }
        .frame(minWidth: 480, minHeight: 520)
    }

    private func updateExpense() {
        viewModel.update(expense)
        dismiss()
    }
}
