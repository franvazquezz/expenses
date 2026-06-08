import SwiftData
import SwiftUI

struct NetWorthView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Account.name) private var accounts: [Account]
    @Query(sort: \Expense.date, order: .reverse) private var expenses: [Expense]
    @Query(sort: \Income.date, order: .reverse) private var incomes: [Income]
    @Query(sort: \Currency.code) private var currencies: [Currency]
    @Query(sort: \ExchangeRate.fromCurrency) private var exchangeRates: [ExchangeRate]

    @State private var showingAddAccount = false
    @State private var editingAccount: Account?

    private var totals: [NetWorthTotal] {
        AccountViewModel.summaryTotals(from: accounts)
    }

    private var assets: [Account] {
        AccountViewModel.accountsByType(from: accounts, type: .asset)
    }

    private var liabilities: [Account] {
        AccountViewModel.accountsByType(from: accounts, type: .liability)
    }

    private var movementSummaries: [AccountMovementSummary] {
        AccountViewModel.movementSummaries(accounts: accounts, expenses: expenses, incomes: incomes)
    }

    private var baseCurrencyTotal: BaseCurrencyNetWorth {
        AccountViewModel.baseCurrencyNetWorth(
            accounts: accounts,
            baseCurrency: CurrencyViewModel.defaultCurrencyCode(from: currencies),
            rates: exchangeRates
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Patrimonio",
                subtitle: "\(accounts.count) cuentas, activos y pasivos",
                systemImage: "building.columns.fill",
                actionTitle: "Agregar",
                actionSystemImage: "plus.circle.fill"
            ) {
                showingAddAccount = true
            }
            .padding([.horizontal, .top])

            if accounts.isEmpty {
                EmptyState(
                    title: "Sin patrimonio cargado",
                    systemImage: "building.columns",
                    message: "Agrega cuentas, activos o pasivos para calcular tu patrimonio neto."
                )
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: AppTheme.pageSpacing) {
                        summaryGrid
                        baseCurrencySummary
                        movementSummary
                        accountSection(title: "Activos", systemImage: "plus.circle", accounts: assets)
                        accountSection(title: "Pasivos", systemImage: "minus.circle", accounts: liabilities)
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Patrimonio")
        .toolbar {
            ToolbarItem {
                Button {
                    showingAddAccount = true
                } label: {
                    Label("Agregar cuenta", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddAccount) {
            AccountFormView(title: "Nueva cuenta") { account in
                modelContext.insert(account)
            }
        }
        .sheet(item: $editingAccount) { account in
            AccountFormView(title: "Editar cuenta", account: account) { _ in }
        }
    }

    private var summaryGrid: some View {
        AppPanel(title: "Patrimonio neto por moneda", systemImage: "sum") {
            if totals.isEmpty {
                Text("Los totales apareceran cuando cargues cuentas activas.")
                    .foregroundStyle(.secondary)
            } else {
                Grid(horizontalSpacing: 16, verticalSpacing: 12) {
                    GridRow {
                        Text("Moneda")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Activos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Pasivos")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("Neto")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    ForEach(totals) { total in
                        GridRow {
                            Text(total.currency)
                                .fontWeight(.semibold)
                            Text(total.assets, format: .currency(code: total.currency))
                                .monospacedDigit()
                                .foregroundStyle(AppTheme.incomeColor)
                            Text(total.liabilities, format: .currency(code: total.currency))
                                .monospacedDigit()
                                .foregroundStyle(AppTheme.expenseColor)
                            Text(total.netWorth, format: .currency(code: total.currency))
                                .monospacedDigit()
                                .fontWeight(.semibold)
                                .foregroundStyle(total.netWorth >= 0 ? AppTheme.balanceColor : AppTheme.expenseColor)
                        }
                    }
                }
            }
        }
    }

    private func accountSection(title: String, systemImage: String, accounts: [Account]) -> some View {
        AppPanel(title: title, systemImage: systemImage) {
            if accounts.isEmpty {
                Text("No hay registros en esta seccion.")
                    .foregroundStyle(.secondary)
            } else {
                AccountTable(
                    accounts: accounts,
                    onEdit: { editingAccount = $0 },
                    onToggleActive: { $0.isActive.toggle() },
                    onDelete: { modelContext.delete($0) }
                )
                .frame(minHeight: min(CGFloat(accounts.count + 1) * 44, 320))
            }
        }
    }

    private var movementSummary: some View {
        AppPanel(title: "Movimientos por cuenta", systemImage: "arrow.left.arrow.right") {
            if movementSummaries.isEmpty {
                Text("El resumen aparecera cuando haya cuentas activas.")
                    .foregroundStyle(.secondary)
            } else {
                Table(movementSummaries) {
                    TableColumn("Cuenta") { item in
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.account.name)
                                .fontWeight(.medium)
                            Text(item.account.category)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }

                    TableColumn("Saldo actual") { item in
                        Text(item.account.balance, format: .currency(code: item.currency))
                            .monospacedDigit()
                    }

                    TableColumn("Ingresos") { item in
                        Text(item.incomeTotal, format: .currency(code: item.currency))
                            .monospacedDigit()
                            .foregroundStyle(AppTheme.incomeColor)
                    }

                    TableColumn("Gastos") { item in
                        Text(item.expenseTotal, format: .currency(code: item.currency))
                            .monospacedDigit()
                            .foregroundStyle(AppTheme.expenseColor)
                    }

                    TableColumn("Flujo neto") { item in
                        Text(item.netFlow, format: .currency(code: item.currency))
                            .monospacedDigit()
                            .fontWeight(.semibold)
                            .foregroundStyle(item.netFlow >= 0 ? AppTheme.balanceColor : AppTheme.expenseColor)
                    }
                }
                .frame(minHeight: min(CGFloat(movementSummaries.count + 1) * 44, 320))
            }
        }
    }

    private var baseCurrencySummary: some View {
        AppPanel(title: "Equivalente en moneda principal", systemImage: "equal.circle") {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(baseCurrencyTotal.baseCurrency)
                        .fontWeight(.semibold)
                    Spacer()
                    Text(baseCurrencyTotal.total, format: .currency(code: baseCurrencyTotal.baseCurrency))
                        .monospacedDigit()
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundStyle(baseCurrencyTotal.total >= 0 ? AppTheme.balanceColor : AppTheme.expenseColor)
                }

                if baseCurrencyTotal.missingCurrencies.isEmpty {
                    Text("Calculado con saldos en moneda principal y cotizaciones manuales disponibles.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    Text("Faltan cotizaciones para: \(baseCurrencyTotal.missingCurrencies.joined(separator: ", ")). Esas cuentas no se suman al equivalente.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}

private struct AccountTable: View {
    let accounts: [Account]
    let onEdit: (Account) -> Void
    let onToggleActive: (Account) -> Void
    let onDelete: (Account) -> Void

    var body: some View {
        Table(accounts) {
            TableColumn("Nombre") { account in
                VStack(alignment: .leading, spacing: 2) {
                    Text(account.name)
                        .fontWeight(.medium)
                    if !account.institution.isEmpty {
                        Text(account.institution)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            TableColumn("Categoria") { account in
                StatusPill(title: account.category, systemImage: "tag", color: AppTheme.balanceColor)
            }

            TableColumn("Saldo") { account in
                Text(account.balance, format: .currency(code: account.currency))
                    .monospacedDigit()
            }

            TableColumn("Estado") { account in
                Text(account.isActive ? "Activo" : "Inactivo")
                    .foregroundStyle(account.isActive ? .primary : .secondary)
            }

            TableColumn("Actualizado") { account in
                Text(account.updatedAt.formatted(.dateTime.day().month().year()))
                    .foregroundStyle(.secondary)
            }

            TableColumn("") { account in
                HStack {
                    Button {
                        onEdit(account)
                    } label: {
                        Label("Editar", systemImage: "pencil")
                    }
                    .labelStyle(.iconOnly)
                    .help("Editar")

                    Button {
                        onToggleActive(account)
                    } label: {
                        Label(account.isActive ? "Desactivar" : "Activar", systemImage: account.isActive ? "pause.circle" : "play.circle")
                    }
                    .labelStyle(.iconOnly)
                    .help(account.isActive ? "Desactivar" : "Activar")

                    Button(role: .destructive) {
                        onDelete(account)
                    } label: {
                        Label("Eliminar", systemImage: "trash")
                    }
                    .labelStyle(.iconOnly)
                    .help("Eliminar")
                }
            }
            .width(110)
        }
    }
}

struct AccountFormView: View {
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Currency.code) private var currencies: [Currency]

    let title: String
    let account: Account?
    let onSave: (Account) -> Void

    @StateObject private var viewModel: AccountViewModel

    init(title: String, account: Account? = nil, onSave: @escaping (Account) -> Void) {
        self.title = title
        self.account = account
        self.onSave = onSave
        _viewModel = StateObject(wrappedValue: AccountViewModel(account: account))
    }

    private var activeCurrencies: [Currency] {
        CurrencyViewModel.activeCurrencies(from: currencies)
    }

    private var availableCategories: [String] {
        AccountCategoryOptions.categories(for: viewModel.type)
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Nombre", text: $viewModel.name)
                    .textFieldStyle(.roundedBorder)

                TextField("Institucion", text: $viewModel.institution)
                    .textFieldStyle(.roundedBorder)

                Picker("Tipo", selection: $viewModel.type) {
                    ForEach(AccountType.allCases, id: \.self) { type in
                        Text(type.title).tag(type)
                    }
                }
                .pickerStyle(.segmented)

                Picker("Categoria", selection: $viewModel.category) {
                    ForEach(availableCategories, id: \.self) { category in
                        Text(category).tag(category)
                    }
                }

                TextField("Saldo", text: $viewModel.balanceText)
                    .textFieldStyle(.roundedBorder)

                Picker("Moneda", selection: $viewModel.currency) {
                    ForEach(activeCurrencies) { currency in
                        Text("\(currency.code) - \(currency.name)").tag(currency.code)
                    }
                }

                TextField("Notas", text: $viewModel.note, axis: .vertical)
                    .lineLimit(2...4)

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
        .frame(minWidth: 460, minHeight: 460)
        .onAppear {
            if viewModel.currency.isEmpty {
                viewModel.currency = CurrencyViewModel.defaultCurrencyCode(from: currencies)
            }
        }
    }

    private func save() {
        if let account {
            viewModel.update(account)
            onSave(account)
        } else if let account = viewModel.makeAccount() {
            onSave(account)
        }

        dismiss()
    }
}
