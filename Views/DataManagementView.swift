import SwiftData
import SwiftUI
import UniformTypeIdentifiers

struct TextFileDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.plainText, .commaSeparatedText, .json, .xml] }
    static var writableContentTypes: [UTType] { [.plainText, .commaSeparatedText, .json, .xml] }

    var text: String

    init(text: String = "") {
        self.text = text
    }

    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let text = String(data: data, encoding: .utf8) else {
            self.text = ""
            return
        }

        self.text = text
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: Data(text.utf8))
    }
}

struct DataManagementView: View {
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

    @State private var exportDocument = TextFileDocument()
    @State private var exportContentType = UTType.plainText
    @State private var exportFilename = "expenses"
    @State private var showingExporter = false
    @State private var importKind: ImportKind?
    @State private var statusMessage = "Sin operaciones recientes."

    private let dataActionColumns = [
        GridItem(.adaptive(minimum: 160), spacing: 12, alignment: .leading)
    ]

    var body: some View {
        VStack(spacing: 0) {
            PageHeader(
                title: "Datos",
                subtitle: "Exportacion, importacion y backup local",
                systemImage: "externaldrive.fill"
            )
            .padding([.horizontal, .top])

            ScrollView {
                VStack(alignment: .leading, spacing: AppTheme.pageSpacing) {
                    AppPanel(title: "CSV", systemImage: "tablecells") {
                        LazyVGrid(columns: dataActionColumns, alignment: .leading, spacing: 12) {
                            Button {
                                exportExpensesCSV()
                            } label: {
                                Label("Exportar gastos", systemImage: "square.and.arrow.up")
                            }

                            Button {
                                exportIncomesCSV()
                            } label: {
                                Label("Exportar ingresos", systemImage: "square.and.arrow.up")
                            }

                            Button {
                                exportMovementsExcel()
                            } label: {
                                Label("Exportar Excel", systemImage: "tablecells.badge.ellipsis")
                            }

                            Button {
                                importKind = .expensesCSV
                            } label: {
                                Label("Importar gastos", systemImage: "square.and.arrow.down")
                            }

                            Button {
                                importKind = .incomesCSV
                            } label: {
                                Label("Importar ingresos", systemImage: "square.and.arrow.down")
                            }

                            Button {
                                importKind = .bankCSV
                            } label: {
                                Label("Importar banco", systemImage: "building.columns")
                            }
                        }
                    }

                    AppPanel(title: "JSON", systemImage: "curlybraces") {
                        Button {
                            exportMovementsJSON()
                        } label: {
                            Label("Exportar movimientos", systemImage: "square.and.arrow.up")
                        }
                    }

                    AppPanel(title: "Backup local", systemImage: "archivebox") {
                        HStack(spacing: 12) {
                            Button {
                                exportBackup()
                            } label: {
                                Label("Exportar backup", systemImage: "externaldrive.badge.plus")
                            }

                            Button {
                                importKind = .backup
                            } label: {
                                Label("Restaurar backup", systemImage: "externaldrive.badge.arrowtriangle.down")
                            }
                        }
                    }

                    AppPanel(title: "Estado", systemImage: "info.circle") {
                        Text(statusMessage)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Datos")
        .fileExporter(
            isPresented: $showingExporter,
            document: exportDocument,
            contentType: exportContentType,
            defaultFilename: exportFilename
        ) { result in
            if case .failure(let error) = result {
                statusMessage = "No se pudo exportar: \(error.localizedDescription)"
            }
        }
        .fileImporter(
            isPresented: Binding(
                get: { importKind != nil },
                set: { isPresented in
                    if !isPresented {
                        importKind = nil
                    }
                }
            ),
            allowedContentTypes: [.plainText, .commaSeparatedText, .json]
        ) { result in
            handleImport(result)
        }
    }

    private func exportExpensesCSV() {
        exportDocument = TextFileDocument(text: DataTransferService.exportExpensesCSV(expenses))
        exportContentType = .commaSeparatedText
        exportFilename = "gastos.csv"
        showingExporter = true
    }

    private func exportIncomesCSV() {
        exportDocument = TextFileDocument(text: DataTransferService.exportIncomesCSV(incomes))
        exportContentType = .commaSeparatedText
        exportFilename = "ingresos.csv"
        showingExporter = true
    }

    private func exportMovementsExcel() {
        exportDocument = TextFileDocument(text: DataTransferService.exportMovementsExcel(expenses: expenses, incomes: incomes))
        exportContentType = .xml
        exportFilename = "movimientos.xls"
        showingExporter = true
    }

    private func exportMovementsJSON() {
        do {
            let export = DataTransferService.makeMovementsJSONExport(expenses: expenses, incomes: incomes)
            exportDocument = TextFileDocument(text: try DataTransferService.encodeMovementsJSONExport(export))
            exportContentType = .json
            exportFilename = "movimientos.json"
            showingExporter = true
        } catch {
            statusMessage = "No se pudo exportar JSON: \(error.localizedDescription)"
        }
    }

    private func exportBackup() {
        do {
            let backup = DataTransferService.makeBackup(
                expenses: expenses,
                incomes: incomes,
                currencies: currencies,
                exchangeRates: exchangeRates,
                budgets: budgets,
                recurringExpenses: recurringExpenses,
                recurringIncomes: recurringIncomes,
                accounts: accounts,
                savingsGoals: savingsGoals,
                dailyReminderSettings: reminderSettings.first
            )
            exportDocument = TextFileDocument(text: try DataTransferService.encodeBackup(backup))
            exportContentType = .json
            exportFilename = "expenses-backup.json"
            showingExporter = true
        } catch {
            statusMessage = "No se pudo crear el backup: \(error.localizedDescription)"
        }
    }

    private func handleImport(_ result: Result<URL, Error>) {
        guard let importKind else {
            return
        }

        defer {
            self.importKind = nil
        }

        do {
            let url = try result.get()
            let didAccess = url.startAccessingSecurityScopedResource()
            defer {
                if didAccess {
                    url.stopAccessingSecurityScopedResource()
                }
            }

            let text = try String(contentsOf: url, encoding: .utf8)
            switch importKind {
            case .expensesCSV:
                let importedExpenses = try DataTransferService.importExpensesCSV(text)
                importedExpenses.forEach { modelContext.insert($0) }
                statusMessage = "Se importaron \(importedExpenses.count) gastos."
            case .incomesCSV:
                let importedIncomes = try DataTransferService.importIncomesCSV(text)
                importedIncomes.forEach { modelContext.insert($0) }
                statusMessage = "Se importaron \(importedIncomes.count) ingresos."
            case .bankCSV:
                let importedMovements = try DataTransferService.importBankCSV(text, accounts: accounts)
                importedMovements.expenses.forEach { modelContext.insert($0) }
                importedMovements.incomes.forEach { modelContext.insert($0) }
                statusMessage = "Se importaron \(importedMovements.expenses.count) gastos y \(importedMovements.incomes.count) ingresos bancarios."
            case .backup:
                let backup = try DataTransferService.decodeBackup(text)
                restore(backup)
            }
        } catch {
            statusMessage = "No se pudo importar: \(error.localizedDescription)"
        }
    }

    private func restore(_ backup: AppBackup) {
        let existingCurrencyCodes = Set(currencies.map(\.code))
        let existingRateKeys = Set(exchangeRates.map { "\($0.fromCurrency)-\($0.toCurrency)" })
        let existingAccountIDs = Set(accounts.map(\.id))
        let existingSavingsGoalIDs = Set(savingsGoals.map(\.id))
        let existingReminderSettingsIDs = Set(reminderSettings.map(\.id))

        DataTransferService.expenses(from: backup).forEach { modelContext.insert($0) }
        DataTransferService.incomes(from: backup).forEach { modelContext.insert($0) }
        DataTransferService.currencies(from: backup)
            .filter { !existingCurrencyCodes.contains($0.code) }
            .forEach { modelContext.insert($0) }
        DataTransferService.exchangeRates(from: backup)
            .filter { !existingRateKeys.contains("\($0.fromCurrency)-\($0.toCurrency)") }
            .forEach { modelContext.insert($0) }
        DataTransferService.budgets(from: backup).forEach { modelContext.insert($0) }
        DataTransferService.recurringExpenses(from: backup).forEach { modelContext.insert($0) }
        DataTransferService.recurringIncomes(from: backup).forEach { modelContext.insert($0) }
        DataTransferService.accounts(from: backup)
            .filter { !existingAccountIDs.contains($0.id) }
            .forEach { modelContext.insert($0) }
        DataTransferService.savingsGoals(from: backup)
            .filter { !existingSavingsGoalIDs.contains($0.id) }
            .forEach { modelContext.insert($0) }
        if let settings = DataTransferService.dailyReminderSettings(from: backup),
           !existingReminderSettingsIDs.contains(settings.id),
           reminderSettings.isEmpty {
            modelContext.insert(settings)
        }

        statusMessage = "Backup restaurado: \(backup.expenses.count) gastos, \(backup.incomes.count) ingresos, \(backup.budgets.count) presupuestos, \(backup.accounts.count) cuentas y \(backup.savingsGoals.count) objetivos."
    }
}

private enum ImportKind {
    case expensesCSV
    case incomesCSV
    case bankCSV
    case backup
}
