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

    private let viewModel = DashboardViewModel()

    var body: some View {
        NavigationSplitView {
            List {
                NavigationLink {
                    dashboardContent
                } label: {
                    Label("Dashboard", systemImage: "chart.pie")
                }

                NavigationLink {
                    ExpenseListView()
                } label: {
                    Label("Gastos", systemImage: "list.bullet.rectangle")
                }

                NavigationLink {
                    IncomeListView()
                } label: {
                    Label("Ingresos", systemImage: "banknote")
                }

                NavigationLink {
                    CurrencySettingsView()
                } label: {
                    Label("Monedas", systemImage: "dollarsign.circle")
                }

                NavigationLink {
                    BudgetListView()
                } label: {
                    Label("Presupuestos", systemImage: "chart.bar.doc.horizontal")
                }

                NavigationLink {
                    RecurringExpenseListView()
                } label: {
                    Label("Recurrentes", systemImage: "repeat.circle")
                }
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
