# Testing

La app usa `XCTest`, incluido en Xcode. No se agrego ninguna libreria externa.

## Por que XCTest

Para esta fase, la logica importante esta en los view models y se puede probar con tests unitarios simples. `XCTest` es estable, integrado con Xcode y suficiente para validar:

- Parseo y validacion de formularios.
- Normalizacion de etiquetas y textos.
- Filtros de gastos.
- Duplicado de gastos.
- Calculos del dashboard.
- Conversion manual entre monedas.
- Uso de `convertedAmount` en estadisticas.
- Balance entre ingresos y gastos.
- Calculo de consumido, restante y porcentaje de presupuestos.
- Generacion de gastos recurrentes vencidos.
- Calculo de activos, pasivos y patrimonio neto por moneda.
- Impacto de gastos e ingresos confirmados sobre saldos de cuentas.
- Equivalente de patrimonio en moneda principal con cotizaciones manuales.
- Compatibilidad de backups previos sin cuentas.
- Exportacion Excel de movimientos.
- Exportacion JSON de movimientos.
- Importacion CSV bancaria normalizada.
- Agregados mensuales del dashboard con volumen alto de movimientos.
- Objetivos de ahorro, alertas avanzadas y comparacion mensual.

## Ejecutar tests

Desde terminal:

```bash
xcodebuild test -project expenses.xcodeproj -scheme expenses -destination 'platform=macOS'
```

Desde Xcode:

1. Abrir `expenses.xcodeproj`.
2. Seleccionar el scheme `expenses`.
3. Presionar `Command + U`.

## Estrategia

Los tests iniciales cubren los view models. Las vistas SwiftUI quedan fuera de tests unitarios por ahora; cuando la UI crezca, conviene sumar pruebas de snapshot o UI tests para flujos principales.

## Cobertura inicial

- `ExpenseFormViewModelTests`
- `ExpenseListViewModelTests`
- `DashboardViewModelTests`
- `IncomeFormViewModelTests`
- `BudgetViewModelTests`
- `RecurringExpenseViewModelTests`
- `RecurringIncomeViewModelTests`
- `IncomeListViewModelTests`
- `DataTransferServiceTests`
- `SyncReadinessServiceTests`
- `AppPersistenceServiceTests`
- `AccountViewModelTests`
- `AccountImpactServiceTests`
- `SwiftDataModelTests`
- `AdvancedFeaturesViewModelTests`
- `expensesUITests`

## Multi-moneda

La Fase 2 agrega tests para:

- Calcular `100 USD -> 140000 ARS` con tasa `USD -> ARS = 1400`.
- Calcular conversion inversa cuando solo existe la tasa opuesta.
- Verificar que el dashboard suma `convertedAmount`, no `originalAmount`.

## Ingresos

La Fase 3 agrega tests para:

- Crear ingresos con conversion manual.
- Rechazar montos invalidos.
- Calcular balance mensual restando gastos a ingresos por moneda base.

## Presupuestos

La Fase 4 agrega tests para:

- Calcular consumido, restante y porcentaje.
- Ignorar gastos de otra categoria, otra moneda base u otro mes.

## Gastos recurrentes

La Fase 5 agrega tests para:

- Avanzar la proxima fecha segun periodicidad semanal, mensual y anual.
- Generar gastos vencidos hasta la fecha actual.
- Evitar generacion cuando la plantilla esta inactiva.

## Patrimonio

La Fase de patrimonio agrega tests para:

- Agrupar activos y pasivos por moneda.
- Calcular patrimonio neto por moneda.
- Ignorar cuentas inactivas por defecto.
- Crear y actualizar cuentas desde el view model.
- Aplicar y revertir gastos e ingresos sobre cuentas.
- Ignorar movimientos pendientes o con moneda incompatible.
- Calcular resumen por cuenta con ingresos, gastos y flujo neto.
- Convertir patrimonio a moneda principal y reportar monedas sin cotizacion.

## Calidad

La Fase 8 agrega tests para:

- Decodificar backups generados antes de incorporar cuentas de patrimonio.
- Validar agregados mensuales del dashboard con miles de gastos e ingresos.
- Medir performance de `monthlyMovementTotals(expenses:incomes:monthsBack:)` como base para futuras revisiones de rendimiento.
- Crear un `ModelContainer` en memoria con el esquema SwiftData actual e insertar los modelos principales.
- Compilar un target de UI tests con smoke tests para dashboard, navegacion a gastos y apertura de alta de gasto.

La Fase 10 agrega tests para:

- Seleccionar store en memoria durante UI tests.
- Mantener persistencia local cuando la configuracion CloudKit esta incompleta.
- Seleccionar CloudKit privado cuando Bundle ID, Team ID, contenedor y capability estan listos.

La Fase 11 agrega tests para:

- Calcular avance, restante y porcentaje de objetivos de ahorro.
- Detectar presupuestos superados.
- Detectar gastos inusuales por promedio historico de categoria y moneda.
- Comparar ingresos, gastos y balance contra el mes anterior.
- Incluir objetivos de ahorro y recordatorio diario en backups.

El scheme principal compila `expensesUITests`, pero los marca como omitidos para la ejecucion por defecto. En macOS, la ejecucion de UI tests requiere permisos de automatizacion/accesibilidad para Xcode; sin esos permisos el runner puede fallar con `Timed out while enabling automation mode`.

Para validar compilacion de unit tests y UI tests:

```bash
xcodebuild build-for-testing -project expenses.xcodeproj -scheme expenses -destination 'platform=macOS'
```

Para ejecutar tambien UI tests, habilitar automatizacion de macOS para Xcode y quitar el skip del testable `expensesUITests` en el scheme.

Quedan pendientes migraciones SwiftData versionadas, revision completa de accesibilidad y revision general de rendimiento.
