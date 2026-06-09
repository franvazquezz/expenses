import Charts
import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]
    @Query(sort: \Budget.category) private var budgets: [Budget]
    @Query(sort: \RecurringExpense.nextRunDate) private var recurringExpenses: [RecurringExpense]
    @Query(sort: \RecurringIncome.nextRunDate) private var recurringIncomes: [RecurringIncome]
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \SavingsGoal.name) private var savingsGoals: [SavingsGoal]
    @Query(sort: \DailyReminderSettings.updatedAt) private var reminderSettings: [DailyReminderSettings]

    private let viewModel = DashboardViewModel()

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    dashboardContent
                } label: {
                    Label("Dashboard", systemImage: "chart.pie")
                }
                .accessibilityIdentifier("navigation.dashboard")

                NavigationLink {
                    ExpenseListView()
                } label: {
                    Label("Gastos", systemImage: "list.bullet.rectangle")
                }
                .accessibilityIdentifier("navigation.expenses")

                NavigationLink {
                    IncomeListView()
                } label: {
                    Label("Ingresos", systemImage: "banknote")
                }
                .accessibilityIdentifier("navigation.incomes")

                NavigationLink {
                    CurrencySettingsView()
                } label: {
                    Label("Monedas", systemImage: "dollarsign.circle")
                }
                .accessibilityIdentifier("navigation.currencies")

                NavigationLink {
                    BudgetListView()
                } label: {
                    Label("Presupuestos", systemImage: "chart.bar.doc.horizontal")
                }
                .accessibilityIdentifier("navigation.budgets")

                NavigationLink {
                    NetWorthView()
                } label: {
                    Label("Patrimonio", systemImage: "building.columns")
                }
                .accessibilityIdentifier("navigation.netWorth")

                NavigationLink {
                    AdvancedFeaturesView()
                } label: {
                    Label("Avanzadas", systemImage: "sparkles")
                }
                .accessibilityIdentifier("navigation.advanced")

                NavigationLink {
                    DataManagementView()
                } label: {
                    Label("Datos", systemImage: "externaldrive")
                }
                .accessibilityIdentifier("navigation.data")

                NavigationLink {
                    RecurringExpenseListView()
                } label: {
                    Label("Gastos recurrentes", systemImage: "repeat.circle")
                }
                .accessibilityIdentifier("navigation.recurringExpenses")

                NavigationLink {
                    RecurringIncomeListView()
                } label: {
                    Label("Ingresos recurrentes", systemImage: "repeat.circle")
                }
                .accessibilityIdentifier("navigation.recurringIncomes")

                NavigationLink {
                    SyncSettingsView()
                } label: {
                    Label("Sincronizacion", systemImage: "icloud")
                }
                .accessibilityIdentifier("navigation.sync")
            }
            .navigationTitle("expenses")
            .navigationSplitViewColumnWidth(min: 180, ideal: 220)
        } detail: {
            dashboardContent
        }
        .onAppear {
            CurrencyViewModel.seedInitialCurrenciesIfNeeded(in: modelContext, existingCurrencies: currencies)
            ExchangeRateViewModel.seedInitialRatesIfNeeded(in: modelContext, existingRates: exchangeRates)
            BudgetViewModel
                .seedInitialBudgetsIfNeeded(
                    in: budgets,
                    defaultCurrency: CurrencyViewModel.defaultCurrencyCode(from: currencies)
                )
                .forEach { modelContext.insert($0) }
            generateDueRecurringExpenses()
            generateDueRecurringIncomes()
            seedReminderSettings()
        }
    }

    private var dashboardContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: AppTheme.pageSpacing) {
                PageHeader(
                    title: "Dashboard",
                    subtitle: "Resumen financiero del mes actual",
                    systemImage: "chart.pie.fill"
                )

                metricGrid
                netWorthSummary
                advancedSummary
                analysisCharts
                budgetProgress

                HStack(alignment: .top, spacing: 20) {
                    latestExpenses
                    latestIncomes
                    topCategories
                }
            }
            .padding()
        }
        .background(.background)
        .navigationTitle("Dashboard")
        .accessibilityIdentifier("screen.dashboard")
    }

    private var metricGrid: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                MetricView(
                    title: "Ingresos del mes",
                    totals: viewModel.incomeTotalsThisMonth(from: incomes),
                    systemImage: "arrow.down.circle"
                )

                MetricView(
                    title: "Gastos del mes",
                    totals: viewModel.expenseTotalsThisMonth(from: expenses),
                    systemImage: "arrow.up.circle"
                )

                MetricView(
                    title: "Balance del mes",
                    totals: viewModel.balanceThisMonth(expenses: expenses, incomes: incomes),
                    systemImage: "equal.circle"
                )
            }

            GridRow {
                MetricView(
                    title: "Total de gastos del ano",
                    totals: viewModel.totalsThisYear(from: expenses),
                    systemImage: "calendar"
                )

                MetricView(
                    title: "Gastos del dia",
                    totals: viewModel.todayTotals(from: expenses),
                    systemImage: "sun.max"
                )

                CountMetricView(
                    title: "Movimientos de hoy",
                    value: viewModel.todayExpenses(from: expenses).count,
                    systemImage: "number"
                )
            }
        }
    }

    private var analysisCharts: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                MonthlyExpenseChart(items: viewModel.monthlyMovementTotals(expenses: expenses, incomes: incomes))
                CategoryDistributionChart(items: viewModel.topCategories(from: expenses, limit: 8))
            }

            GridRow {
                MonthlyBalanceChart(items: viewModel.monthlyMovementTotals(expenses: expenses, incomes: incomes))
                PaymentMethodChart(items: viewModel.paymentMethodTotals(from: expenses))
            }
        }
    }

    private var netWorthSummary: some View {
        AppPanel(title: "Patrimonio neto", systemImage: "building.columns") {
            let totals = AccountViewModel.summaryTotals(from: accounts)

            if totals.isEmpty {
                Text("El patrimonio aparecera cuando cargues cuentas, activos o pasivos.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(totals) { total in
                    HStack {
                        Text(total.currency)
                            .fontWeight(.semibold)
                        Spacer()
                        Text(total.netWorth, format: .currency(code: total.currency))
                            .monospacedDigit()
                            .foregroundStyle(total.netWorth >= 0 ? AppTheme.balanceColor : AppTheme.expenseColor)
                    }
                    Divider()
                }
            }
        }
    }

    private var advancedSummary: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                savingsGoalsSummary
                activeAlertsSummary
                dailyReminderSummary
            }
        }
    }

    private var savingsGoalsSummary: some View {
        AppPanel(title: "Objetivos de ahorro", systemImage: "target") {
            let activeGoals = SavingsGoalViewModel.progress(for: savingsGoals)

            if activeGoals.isEmpty {
                Text("No hay objetivos activos.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(activeGoals.prefix(3)) { item in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(item.goal.name)
                                .font(.subheadline)
                            Spacer()
                            Text(item.percentageText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        ProgressView(value: item.percentage)
                            .tint(item.percentage >= 1 ? AppTheme.incomeColor : AppTheme.balanceColor)
                    }
                    Divider()
                }
            }
        }
    }

    private var activeAlertsSummary: some View {
        AppPanel(title: "Alertas del mes", systemImage: "exclamationmark.triangle") {
            let budgetAlerts = AdvancedFeaturesViewModel.budgetAlerts(budgets: budgets, expenses: expenses)
            let unusualAlerts = AdvancedFeaturesViewModel.unusualExpenseAlerts(expenses: expenses)

            if budgetAlerts.isEmpty && unusualAlerts.isEmpty {
                Text("Sin alertas activas.")
                    .foregroundStyle(.secondary)
            } else {
                Label("\(budgetAlerts.count) presupuestos superados", systemImage: "chart.bar.doc.horizontal")
                    .foregroundStyle(budgetAlerts.isEmpty ? Color.secondary : AppTheme.expenseColor)
                Label("\(unusualAlerts.count) gastos inusuales", systemImage: "waveform.path.ecg")
                    .foregroundStyle(unusualAlerts.isEmpty ? Color.secondary : Color.orange)
            }
        }
    }

    private var dailyReminderSummary: some View {
        AppPanel(title: "Recordatorio diario", systemImage: "bell.badge") {
            if let settings = reminderSettings.first, settings.isEnabled {
                Text("Activo a las \(twoDigit(settings.hour)):\(twoDigit(settings.minute))")
                    .font(.subheadline)
            } else {
                Text("Desactivado")
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var budgetProgress: some View {
        AppPanel(title: "Presupuestos del mes", systemImage: "chart.bar.doc.horizontal") {
            let progressItems = BudgetViewModel.progress(for: budgets, expenses: expenses)

            if progressItems.isEmpty {
                Text("Los presupuestos apareceran cuando cargues limites por categoria.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(progressItems) { item in
                    BudgetProgressRow(item: item)
                }
            }
        }
    }

    private var latestExpenses: some View {
        AppPanel(title: "Ultimos gastos", systemImage: "clock") {
            if viewModel.latestExpenses(from: expenses).isEmpty {
                Text("Todavia no hay gastos cargados.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.latestExpenses(from: expenses)) { expense in
                    MovementRow(
                        title: expense.expenseDescription.isEmpty ? expense.category : expense.expenseDescription,
                        subtitle: expense.date.formatted(.dateTime.day().month().year()),
                        amount: expense.convertedAmount,
                        currency: expense.baseCurrency,
                        color: AppTheme.expenseColor
                    )
                    Divider()
                }
            }
        }
    }

    private var latestIncomes: some View {
        AppPanel(title: "Ultimos ingresos", systemImage: "banknote") {
            if viewModel.latestIncomes(from: incomes).isEmpty {
                Text("Todavia no hay ingresos cargados.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.latestIncomes(from: incomes)) { income in
                    MovementRow(
                        title: income.incomeDescription.isEmpty ? income.category : income.incomeDescription,
                        subtitle: income.date.formatted(.dateTime.day().month().year()),
                        amount: income.convertedAmount,
                        currency: income.baseCurrency,
                        color: AppTheme.incomeColor
                    )
                    Divider()
                }
            }
        }
    }

    private var topCategories: some View {
        AppPanel(title: "Categorias con mayor gasto", systemImage: "chart.bar") {
            if viewModel.topCategories(from: expenses).isEmpty {
                Text("Las categorias apareceran cuando cargues gastos.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.topCategories(from: expenses)) { item in
                    HStack {
                        Text(item.category)
                        Spacer()
                        Text(item.total, format: .currency(code: item.currency))
                            .monospacedDigit()
                    }
                    Divider()
                }
            }
        }
    }

    private func generateDueRecurringExpenses() {
        for recurringExpense in recurringExpenses {
            let result = RecurringExpenseViewModel.generatedExpenses(for: recurringExpense)
            for expense in result.createdExpenses {
                modelContext.insert(expense)
            }
            recurringExpense.nextRunDate = result.nextRunDate
        }
    }

    private func generateDueRecurringIncomes() {
        for recurringIncome in recurringIncomes {
            let result = RecurringIncomeViewModel.generatedIncomes(for: recurringIncome)
            for income in result.createdIncomes {
                modelContext.insert(income)
            }
            recurringIncome.nextRunDate = result.nextRunDate
        }
    }

    private func seedReminderSettings() {
        if let seededSettings = AdvancedFeaturesViewModel.seedReminderSettingsIfNeeded(in: reminderSettings) {
            modelContext.insert(seededSettings)
        }
    }

    private func twoDigit(_ value: Int) -> String {
        String(format: "%02d", value)
    }
}

struct MonthlyExpenseChart: View {
    let items: [MonthlyMovementTotal]

    var body: some View {
        AppPanel(title: "Gastos por mes", systemImage: "chart.bar.xaxis") {
            if items.isEmpty {
                Text("El grafico aparecera cuando haya gastos confirmados.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(items) { item in
                    BarMark(
                        x: .value("Mes", item.monthStart, unit: .month),
                        y: .value("Gasto", item.expenseTotal)
                    )
                    .foregroundStyle(by: .value("Moneda", item.currency))
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 220)
            }
        }
    }
}

struct MonthlyBalanceChart: View {
    let items: [MonthlyMovementTotal]

    var body: some View {
        AppPanel(title: "Balance mensual", systemImage: "chart.xyaxis.line") {
            if items.isEmpty {
                Text("El grafico aparecera cuando haya ingresos o gastos confirmados.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(items) { item in
                    LineMark(
                        x: .value("Mes", item.monthStart, unit: .month),
                        y: .value("Balance", item.balance)
                    )
                    .foregroundStyle(by: .value("Moneda", item.currency))

                    PointMark(
                        x: .value("Mes", item.monthStart, unit: .month),
                        y: .value("Balance", item.balance)
                    )
                    .foregroundStyle(by: .value("Moneda", item.currency))
                }
                .chartXAxis {
                    AxisMarks(values: .stride(by: .month)) { _ in
                        AxisGridLine()
                        AxisValueLabel(format: .dateTime.month(.abbreviated))
                    }
                }
                .frame(height: 220)
            }
        }
    }
}

struct CategoryDistributionChart: View {
    let items: [CategoryTotal]

    var body: some View {
        AppPanel(title: "Gastos por categoria", systemImage: "chart.pie") {
            if items.isEmpty {
                Text("El grafico aparecera cuando haya gastos confirmados.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(items) { item in
                    SectorMark(
                        angle: .value("Total", item.total),
                        innerRadius: .ratio(0.58),
                        angularInset: 1.5
                    )
                    .foregroundStyle(by: .value("Categoria", "\(item.category) \(item.currency)"))
                }
                .frame(height: 220)
            }
        }
    }
}

struct PaymentMethodChart: View {
    let items: [PaymentMethodTotal]

    var body: some View {
        AppPanel(title: "Gastos por metodo de pago", systemImage: "creditcard") {
            if items.isEmpty {
                Text("El grafico aparecera cuando haya metodos de pago confirmados.")
                    .foregroundStyle(.secondary)
            } else {
                Chart(items) { item in
                    BarMark(
                        x: .value("Total", item.total),
                        y: .value("Metodo", item.paymentMethod)
                    )
                    .foregroundStyle(by: .value("Moneda", item.currency))
                }
                .frame(height: 220)
            }
        }
    }
}

struct BudgetProgressRow: View {
    let item: BudgetProgress

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(item.budget.category)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Spacer()

                Text(item.percentageText)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: item.percentage)
                .tint(progressColor)

            HStack {
                Text("Consumido: \(item.consumed, format: .currency(code: item.budget.currency))")
                Spacer()
                Text("Restante: \(item.remaining, format: .currency(code: item.budget.currency))")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
            .monospacedDigit()
        }
    }

    private var progressColor: Color {
        switch item.percentage {
        case 0..<0.7:
            AppTheme.incomeColor
        case 0..<0.9:
            .orange
        default:
            AppTheme.expenseColor
        }
    }
}

struct MetricView: View {
    let title: String
    let totals: [MoneyTotal]
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: systemImage)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Spacer()
            }

            if totals.isEmpty {
                Text(0, format: .currency(code: CurrencyOptions.defaultCurrency))
                    .font(.system(size: 28, weight: .semibold))
                    .monospacedDigit()
            } else {
                ForEach(totals) { item in
                    Text(item.total, format: .currency(code: item.currency))
                        .font(.system(size: 24, weight: .semibold))
                        .monospacedDigit()
                }
            }
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: AppTheme.sectionRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.sectionRadius)
                .strokeBorder(.separator.opacity(0.35))
        }
    }
}

struct CountMetricView: View {
    let title: String
    let value: Int
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(value.formatted())
                .font(.system(size: 28, weight: .semibold))
                .monospacedDigit()
        }
        .frame(maxWidth: .infinity, minHeight: 96, alignment: .leading)
        .padding()
        .background(.background.secondary, in: RoundedRectangle(cornerRadius: AppTheme.sectionRadius))
        .overlay {
            RoundedRectangle(cornerRadius: AppTheme.sectionRadius)
                .strokeBorder(.separator.opacity(0.35))
        }
    }
}

struct MovementRow: View {
    let title: String
    let subtitle: String
    let amount: Double
    let currency: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Circle()
                .fill(color.opacity(0.18))
                .overlay {
                    Circle()
                        .fill(color)
                        .frame(width: 6, height: 6)
                }
                .frame(width: 18, height: 18)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .lineLimit(1)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Text(amount, format: .currency(code: currency))
                .font(.subheadline)
                .fontWeight(.medium)
                .monospacedDigit()
        }
    }
}
