import SwiftData
import SwiftUI

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

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
                    CurrencySettingsView()
                } label: {
                    Label("Monedas", systemImage: "dollarsign.circle")
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
        }
    }

    private var dashboardContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                metricGrid

                HStack(alignment: .top, spacing: 20) {
                    latestExpenses
                    topCategories
                }
            }
            .padding()
        }
        .navigationTitle("Dashboard")
    }

    private var metricGrid: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            GridRow {
                MetricView(
                    title: "Total del mes",
                    totals: viewModel.totalsThisMonth(from: expenses),
                    systemImage: "calendar"
                )

                MetricView(
                    title: "Total del año",
                    totals: viewModel.totalsThisYear(from: expenses),
                    systemImage: "calendar.badge.clock"
                )
            }

            GridRow {
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

    private var latestExpenses: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Ultimos gastos", systemImage: "clock")
                .font(.headline)

            if viewModel.latestExpenses(from: expenses).isEmpty {
                Text("Todavia no hay gastos cargados.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(viewModel.latestExpenses(from: expenses)) { expense in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(expense.expenseDescription.isEmpty ? expense.category : expense.expenseDescription)
                                .font(.subheadline)
                            Text(expense.date, format: .dateTime.day().month().year())
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Text(expense.convertedAmount, format: .currency(code: expense.baseCurrency))
                            .monospacedDigit()
                    }
                    Divider()
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }

    private var topCategories: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Categorias con mayor gasto", systemImage: "chart.bar")
                .font(.headline)

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
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct MetricView: View {
    let title: String
    let totals: [MoneyTotal]
    let systemImage: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label(title, systemImage: systemImage)
                .font(.subheadline)
                .foregroundStyle(.secondary)

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
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
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
        .background(.quaternary.opacity(0.4), in: RoundedRectangle(cornerRadius: 8))
    }
}
