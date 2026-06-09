import SwiftData
import SwiftUI

struct AdvancedFeaturesView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \SavingsGoal.name) private var savingsGoals: [SavingsGoal]
    @Query(sort: \DailyReminderSettings.updatedAt) private var reminderSettings: [DailyReminderSettings]
    @Query(sort: \Budget.category) private var budgets: [Budget]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]

    @State private var showingAddGoal = false
    @State private var editingGoal: SavingsGoal?

    private var goalProgressItems: [SavingsGoalProgress] {
        SavingsGoalViewModel.progress(for: savingsGoals, includeInactive: true)
    }

    private var settings: DailyReminderSettings? {
        reminderSettings.first
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.pageSpacing) {
                PageHeader(
                    title: "Funciones avanzadas",
                    subtitle: "Objetivos, alertas y recordatorios locales",
                    systemImage: "sparkles",
                    actionTitle: "Agregar objetivo",
                    actionSystemImage: "plus.circle.fill"
                ) {
                    showingAddGoal = true
                }

                goalsPanel
                monthlyComparisonPanel
                alertPanel
                reminderPanel
            }
            .padding()
        }
        .navigationTitle("Funciones avanzadas")
        .onAppear {
            if let seededSettings = AdvancedFeaturesViewModel.seedReminderSettingsIfNeeded(in: reminderSettings) {
                modelContext.insert(seededSettings)
            }
        }
        .sheet(isPresented: $showingAddGoal) {
            SavingsGoalFormView(title: "Nuevo objetivo") { goal in
                modelContext.insert(goal)
            }
        }
        .sheet(item: $editingGoal) { goal in
            SavingsGoalFormView(title: "Editar objetivo", goal: goal) { _ in }
        }
    }

    private var goalsPanel: some View {
        AppPanel(title: "Objetivos de ahorro", systemImage: "target") {
            if goalProgressItems.isEmpty {
                Text("Agrega objetivos para seguir el avance de tus ahorros.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(goalProgressItems) { item in
                    SavingsGoalRow(item: item) {
                        editingGoal = item.goal
                    } onToggle: {
                        item.goal.isActive.toggle()
                        item.goal.updatedAt = Date()
                    }
                    Divider()
                }
            }
        }
    }

    private var monthlyComparisonPanel: some View {
        AppPanel(title: "Comparacion mensual", systemImage: "arrow.left.arrow.right") {
            let items = AdvancedFeaturesViewModel.monthlyComparison(expenses: expenses, incomes: incomes)

            if items.isEmpty {
                Text("La comparacion aparecera cuando haya movimientos en el mes actual o anterior.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(items) { item in
                    MonthlyComparisonRow(item: item)
                    Divider()
                }
            }
        }
    }

    private var alertPanel: some View {
        AppPanel(title: "Alertas", systemImage: "exclamationmark.triangle") {
            let budgetAlerts = AdvancedFeaturesViewModel.budgetAlerts(budgets: budgets, expenses: expenses)
            let unusualAlerts = AdvancedFeaturesViewModel.unusualExpenseAlerts(expenses: expenses)

            if budgetAlerts.isEmpty && unusualAlerts.isEmpty {
                Text("No hay alertas activas para el mes actual.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(budgetAlerts) { alert in
                    AlertRow(
                        title: alert.title,
                        subtitle: "Consumido \(alert.progress.consumed.formatted(.currency(code: alert.progress.budget.currency))) sobre \(alert.progress.budget.amount.formatted(.currency(code: alert.progress.budget.currency))).",
                        systemImage: "chart.bar.doc.horizontal",
                        color: AppTheme.expenseColor
                    )
                    Divider()
                }

                ForEach(unusualAlerts) { alert in
                    AlertRow(
                        title: "Gasto inusual: \(alert.expense.category)",
                        subtitle: "\(alert.expense.convertedAmount.formatted(.currency(code: alert.expense.baseCurrency))) supera el promedio historico de \(alert.averageAmount.formatted(.currency(code: alert.expense.baseCurrency))).",
                        systemImage: "waveform.path.ecg",
                        color: .orange
                    )
                    Divider()
                }
            }
        }
    }

    private var reminderPanel: some View {
        AppPanel(
            title: "Recordatorio de carga diaria",
            systemImage: "bell.badge",
            footer: "Configuracion local. Las notificaciones del sistema quedan para una decision posterior de permisos."
        ) {
            if let settings {
                Toggle("Activar recordatorio", isOn: Binding(
                    get: { settings.isEnabled },
                    set: { newValue in
                        settings.isEnabled = newValue
                        settings.updatedAt = Date()
                    }
                ))

                DatePicker(
                    "Hora",
                    selection: Binding(
                        get: { reminderDate(from: settings) },
                        set: { date in updateReminderTime(settings, from: date) }
                    ),
                    displayedComponents: .hourAndMinute
                )
                .disabled(!settings.isEnabled)
            } else {
                Text("La configuracion se inicializara automaticamente al abrir esta pantalla.")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func reminderDate(from settings: DailyReminderSettings) -> Date {
        Calendar.current.date(
            bySettingHour: settings.hour,
            minute: settings.minute,
            second: 0,
            of: Date()
        ) ?? Date()
    }

    private func updateReminderTime(_ settings: DailyReminderSettings, from date: Date) {
        let components = Calendar.current.dateComponents([.hour, .minute], from: date)
        settings.hour = components.hour ?? settings.hour
        settings.minute = components.minute ?? settings.minute
        settings.updatedAt = Date()
    }
}

struct SavingsGoalFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Currency.code) private var currencies: [Currency]

    let title: String
    let goal: SavingsGoal?
    let onSave: (SavingsGoal) -> Void

    @StateObject private var viewModel: SavingsGoalViewModel

    init(title: String, goal: SavingsGoal? = nil, onSave: @escaping (SavingsGoal) -> Void) {
        self.title = title
        self.goal = goal
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: SavingsGoalViewModel(goal: goal))
    }

    private var activeCurrencies: [Currency] {
        CurrencyViewModel.activeCurrencies(from: currencies)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)

                TextField("Monto objetivo", text: $viewModel.targetAmountText)
                    .textFieldStyle(.roundedBorder)

                TextField("Monto actual", text: $viewModel.currentAmountText)
                    .textFieldStyle(.roundedBorder)

                Picker("Moneda", selection: $viewModel.currency) {
                    ForEach(activeCurrencies) { currency in
                        Text("\(currency.code) - \(currency.name)").tag(currency.code)
                    }
                }

                Toggle("Usar fecha objetivo", isOn: $viewModel.hasTargetDate)

                DatePicker("Fecha objetivo", selection: $viewModel.targetDate, displayedComponents: .date)
                    .disabled(!viewModel.hasTargetDate)

                TextField("Nota", text: $viewModel.note, axis: .vertical)
                    .lineLimit(3, reservesSpace: true)

                Toggle("Activo", isOn: $viewModel.isActive)
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
        .frame(minWidth: 460, minHeight: 420)
        .onAppear {
            if viewModel.currency.isEmpty {
                viewModel.currency = CurrencyViewModel.defaultCurrencyCode(from: currencies)
            }
        }
    }

    private func save() {
        if let goal {
            viewModel.update(goal)
            onSave(goal)
        } else if let goal = viewModel.makeGoal() {
            onSave(goal)
        }

        dismiss()
    }
}

private struct SavingsGoalRow: View {
    let item: SavingsGoalProgress
    let onEdit: () -> Void
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.goal.name)
                        .font(.subheadline)
                        .fontWeight(.medium)

                    if let targetDate = item.goal.targetDate {
                        Text("Meta: \(targetDate.formatted(.dateTime.day().month().year()))")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Spacer()

                Button(action: onEdit) {
                    Label("Editar", systemImage: "pencil")
                }
                .labelStyle(.iconOnly)
                .help("Editar")

                Button(action: onToggle) {
                    Label(item.goal.isActive ? "Desactivar" : "Activar", systemImage: item.goal.isActive ? "pause.circle" : "play.circle")
                }
                .labelStyle(.iconOnly)
                .help(item.goal.isActive ? "Desactivar" : "Activar")
            }

            ProgressView(value: item.percentage)
                .tint(item.percentage >= 1 ? AppTheme.incomeColor : AppTheme.balanceColor)

            HStack {
                Text("\(item.goal.currentAmount, format: .currency(code: item.goal.currency)) de \(item.goal.targetAmount, format: .currency(code: item.goal.currency))")
                Spacer()
                Text(item.percentageText)
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
    }
}

private struct MonthlyComparisonRow: View {
    let item: MonthlyComparison

    var body: some View {
        Grid(alignment: .leading, horizontalSpacing: 16, verticalSpacing: 8) {
            GridRow {
                Text(item.currency)
                    .fontWeight(.semibold)
                Text("Mes actual")
                    .foregroundStyle(.secondary)
                Text("Mes anterior")
                    .foregroundStyle(.secondary)
                Text("Diferencia")
                    .foregroundStyle(.secondary)
            }

            GridRow {
                Text("Gastos")
                Text(item.currentMonthExpenseTotal, format: .currency(code: item.currency))
                Text(item.previousMonthExpenseTotal, format: .currency(code: item.currency))
                DifferenceText(value: item.expenseDifference, currency: item.currency, positiveIsGood: false)
            }

            GridRow {
                Text("Ingresos")
                Text(item.currentMonthIncomeTotal, format: .currency(code: item.currency))
                Text(item.previousMonthIncomeTotal, format: .currency(code: item.currency))
                DifferenceText(value: item.incomeDifference, currency: item.currency, positiveIsGood: true)
            }

            GridRow {
                Text("Balance")
                Text(item.currentMonthIncomeTotal - item.currentMonthExpenseTotal, format: .currency(code: item.currency))
                Text(item.previousMonthIncomeTotal - item.previousMonthExpenseTotal, format: .currency(code: item.currency))
                DifferenceText(value: item.balanceDifference, currency: item.currency, positiveIsGood: true)
            }
        }
        .font(.subheadline)
        .monospacedDigit()
    }
}

private struct DifferenceText: View {
    let value: Double
    let currency: String
    let positiveIsGood: Bool

    var body: some View {
        Text(value, format: .currency(code: currency))
            .foregroundStyle(color)
    }

    private var color: Color {
        if value == 0 {
            return .secondary
        }

        let isPositive = value > 0
        return isPositive == positiveIsGood ? AppTheme.incomeColor : AppTheme.expenseColor
    }
}

private struct AlertRow: View {
    let title: String
    let subtitle: String
    let systemImage: String
    let color: Color

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: systemImage)
                .foregroundStyle(color)
                .frame(width: 20)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

