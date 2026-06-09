# Arquitectura

La app usa una arquitectura MVVM simple.

## Capas

### Models

Contiene entidades persistidas con SwiftData.

- `Expense`: representa un gasto local con monto, moneda, fecha, categoria, descripcion, metodo de pago, notas, etiquetas y cuenta opcional.
- `Currency`: representa una moneda configurable por el usuario, con codigo, nombre, simbolo, estado activo y marca de moneda principal.
- `ExchangeRate`: representa una cotizacion manual entre dos monedas.
- `Income`: representa un ingreso local con monto original, moneda original, monto convertido, moneda base y cuenta opcional.
- `Budget`: representa un presupuesto mensual por categoria, moneda y estado activo.
- `RecurringExpense`: representa una plantilla de gasto recurrente con periodicidad, proxima fecha de generacion y estado activo.
- `RecurringIncome`: representa una plantilla de ingreso recurrente con periodicidad, proxima fecha de generacion y estado activo.
- `Account`: representa una cuenta, activo o pasivo con saldo manual, moneda, categoria, institucion y estado activo.
- `SavingsGoal`: representa un objetivo de ahorro con monto objetivo, avance, moneda, fecha opcional y estado activo.
- `DailyReminderSettings`: representa la configuracion local del recordatorio diario.
- `ExpensesSchemaV1`: define el schema versionado inicial de SwiftData para todos los modelos persistidos.

### ViewModels

Contiene logica de presentacion y transformacion de datos.

- `ExpenseFormViewModel`: valida y normaliza datos del formulario.
- `ExpenseListViewModel`: filtra gastos por texto, mes, categoria, etiqueta, moneda, metodo de pago y estado; genera opciones disponibles y duplica gastos.
- `DashboardViewModel`: calcula totales, ultimos movimientos, rankings por categoria, agregados mensuales y resumen por metodo de pago.
- `CurrencyViewModel`: crea, edita, desactiva y define moneda principal.
- `ExchangeRateViewModel`: crea, edita y aplica cotizaciones manuales.
- `IncomeFormViewModel`: valida, normaliza y convierte ingresos.
- `IncomeListViewModel`: filtra ingresos por texto, mes, categoria, moneda y estado.
- `BudgetViewModel`: valida presupuestos y calcula consumido, restante y porcentaje.
- `RecurringExpenseViewModel`: valida plantillas recurrentes y genera gastos pendientes.
- `RecurringIncomeViewModel`: valida plantillas recurrentes y genera ingresos pendientes.
- `AccountViewModel`: valida cuentas patrimoniales y calcula activos, pasivos y patrimonio neto por moneda.
- `SavingsGoalViewModel`: valida objetivos de ahorro y calcula avance, restante y porcentaje.
- `AdvancedFeaturesViewModel`: calcula alertas de presupuesto, gastos inusuales, comparacion mensual y semilla de recordatorio.

### Services

Contiene logica compartida que no depende de SwiftUI.

- `SyncReadinessService`: evalua si el proyecto esta listo para activar CloudKit segun Bundle ID, Apple Developer Team, contenedor iCloud y capability.
- `DataTransferService`: exporta/importa CSV de gastos e ingresos, exporta movimientos en Excel y JSON, importa CSV bancario normalizado, valida importaciones y genera/restaura backups JSON.
- `AccountImpactService`: aplica y revierte el impacto de gastos e ingresos confirmados sobre saldos de cuentas.
- `AppPersistenceService`: centraliza el `ModelContainer`; usa memoria para UI tests, SwiftData local por defecto y CloudKit privado solo cuando readiness esta completa.
- `ReminderNotificationService`: agenda o cancela la notificacion local diaria del recordatorio de carga.

### Views

Contiene pantallas SwiftUI.

- `DashboardView`: pantalla principal con resumen y navegacion.
- `ExpenseListView`: tabla de gastos con filtros y acciones.
- `AddExpenseView`: alta de gasto.
- `EditExpenseView`: edicion de gasto.
- `CurrencySettingsView`: administracion de monedas y cotizaciones manuales.
- `IncomeListView`: tabla de ingresos con filtros.
- `AddIncomeView`: alta de ingreso.
- `EditIncomeView`: edicion de ingreso.
- `BudgetListView`: tabla de presupuestos con barra de progreso y acciones de edicion.
- `RecurringExpenseListView`: administra gastos recurrentes y permite generar pendientes manualmente.
- `RecurringIncomeListView`: administra ingresos recurrentes y permite generar pendientes manualmente.
- `NetWorthView`: administra activos y pasivos, y muestra patrimonio neto por moneda.
- `AdvancedFeaturesView`: administra objetivos de ahorro, comparacion mensual, alertas avanzadas y recordatorio diario.
- `SyncSettingsView`: muestra el estado de preparacion para CloudKit y los requisitos pendientes.
- `DataManagementView`: administra exportacion CSV/Excel/JSON, importacion CSV, importacion bancaria, backup local y restauracion desde backup.

## Persistencia

La persistencia se configura en `expensesApp` a traves de `AppPersistenceService`:

```swift
.modelContainer(modelContainer)
```

SwiftData administra el almacenamiento. No hay backend ni login; cuando CloudKit este activado, la identidad dependera de iCloud. La app usa store local por defecto, store en memoria para UI tests y `ModelConfiguration` con CloudKit privado solo si la configuracion de readiness esta completa.

El schema actual queda versionado en `ExpensesSchemaV1` y se instala mediante `ExpensesMigrationPlan`. La version inicial no define etapas de migracion porque no existe una version previa versionada; el proximo cambio incompatible de modelos debe agregar un nuevo schema y una etapa explicita.

## Multi-moneda

La Fase 2 agrega conversion local basada en cotizaciones manuales.

Cada gasto guarda:

- `originalAmount`
- `originalCurrency`
- `convertedAmount`
- `baseCurrency`

Ejemplo:

- Gasto original: `100 USD`
- Moneda principal: `ARS`
- Cotizacion: `1 USD = 1400 ARS`
- Monto convertido guardado: `140000 ARS`

El dashboard usa `convertedAmount` y `baseCurrency` para estadisticas comparables.

## Ingresos

La Fase 3 agrega ingresos con las categorias iniciales:

- Sueldo
- Freelance
- Ventas
- Otros

El dashboard calcula ingresos, gastos y balance mensual por moneda base. El balance se calcula como:

```text
balance = ingresos convertidos - gastos convertidos
```

## Analisis visual

El dashboard usa Charts de Apple para graficos de:

- Gastos por mes.
- Gastos por categoria.
- Balance mensual.
- Gastos por metodo de pago.

Los graficos usan solo movimientos confirmados. Los importes se agrupan por `baseCurrency`; no se suman monedas distintas como si fueran equivalentes.

## Datos

La Fase 4 agrega transferencia de datos local:

- CSV de gastos.
- CSV de ingresos.
- Excel compatible con hojas de gastos e ingresos.
- JSON de movimientos con gastos e ingresos para analisis o intercambio.
- CSV bancario normalizado con movimientos positivos como ingresos y negativos como gastos.
- Backup JSON con gastos, ingresos, monedas, cotizaciones, presupuestos, plantillas recurrentes, cuentas patrimoniales, objetivos de ahorro y recordatorio diario.
- Restauracion desde backup JSON.

Las importaciones CSV validan encabezado, cantidad de columnas, fechas, importes, monedas, categorias y estados booleanos. La restauracion desde backup importa registros sin borrar la base actual y omite monedas/cotizaciones ya existentes para evitar conflictos con campos unicos.

La importacion bancaria espera el encabezado `date,description,amount,currency,category,paymentMethod,note,accountName,isConfirmed`. Si `accountName` coincide con una cuenta existente de la misma moneda, el movimiento queda asociado a esa cuenta.

## Presupuestos

La Fase 4 agrega presupuestos mensuales por categoria. Cada presupuesto guarda:

- Categoria.
- Monto limite.
- Moneda.
- Mes.
- Estado activo.

El avance se calcula comparando el presupuesto con gastos del mismo mes, misma categoria y misma moneda base:

```text
consumido = suma de gastos convertidos de la categoria
restante = presupuesto - consumido
porcentaje = consumido / presupuesto
```

La app inicia con ejemplos para Comida, Transporte y Ocio usando la moneda principal.

Para volumen alto, el progreso de presupuestos acumula primero gastos confirmados por categoria y moneda en un diccionario, y luego resuelve cada presupuesto contra esa tabla. Esto evita recorrer todos los gastos por cada presupuesto.

## Patrimonio

La app modela patrimonio con cuentas manuales. Cada `Account` guarda:

- Nombre.
- Institucion opcional.
- Tipo: activo o pasivo.
- Categoria.
- Moneda.
- Saldo actual.
- Notas.
- Estado activo.

El patrimonio neto se calcula por moneda:

```text
patrimonio neto = activos - pasivos
```

Las monedas se mantienen separadas en el resumen por moneda. El equivalente total en moneda principal se calcula solo cuando hay cotizaciones manuales disponibles; las monedas sin cotizacion no se suman y se informan como pendientes.

Los movimientos pueden asociarse opcionalmente a una cuenta activa de la misma moneda original. Para mantener saldos consistentes:

- Un gasto confirmado resta `originalAmount` de la cuenta asociada.
- Un ingreso confirmado suma `originalAmount` a la cuenta asociada.
- Al editar o eliminar un movimiento se revierte el impacto anterior antes de aplicar el nuevo estado.
- Al marcar un movimiento como pendiente se revierte su impacto; al confirmarlo se aplica.
- Si la moneda de la cuenta no coincide con la moneda original del movimiento, no se aplica impacto.

`NetWorthView` incluye un dashboard analitico por cuenta que muestra saldo actual, ingresos confirmados, gastos confirmados y flujo neto. Estos agregados usan la moneda propia de cada cuenta y no consolidan divisas.

Para volumen alto, el resumen de movimientos por cuenta acumula ingresos y gastos confirmados por `accountID` y moneda original antes de construir las filas por cuenta. Esto mantiene el calculo lineal respecto de cuentas y movimientos.

## Funciones avanzadas

La Fase 11 agrega funciones locales sobre los datos existentes:

- Objetivos de ahorro persistidos en `SavingsGoal`.
- Comparacion mensual de ingresos, gastos y balance contra el mes anterior, por moneda.
- Alertas de presupuesto superado derivadas desde `BudgetViewModel.progress`.
- Alertas de gasto inusual cuando un gasto del mes actual supera el promedio historico de su categoria y moneda.
- Recordatorio diario configurable en `DailyReminderSettings`.

Las alertas no se guardan en SwiftData: se calculan desde movimientos confirmados para evitar inconsistencias. El recordatorio diario usa `ReminderNotificationService` para solicitar autorizacion de `UserNotifications` al activarse y reemplazar la notificacion pendiente con un trigger diario.

## Gastos recurrentes

La Fase 5 agrega plantillas para gastos recurrentes como Netflix, Spotify, alquiler, expensas o internet.

Cada plantilla guarda:

- Nombre.
- Monto original y convertido.
- Categoria.
- Descripcion, nota, metodo de pago y etiquetas.
- Periodicidad: semanal, mensual o anual.
- Fecha de inicio.
- Proxima fecha de generacion.
- Estado activo.

La generacion automatica se ejecuta al abrir la app. Por cada plantilla activa vencida, se crea un `Expense` por cada ocurrencia pendiente hasta el dia actual y se avanza `nextRunDate` al siguiente vencimiento. La vista de recurrentes tambien incluye una accion manual para generar pendientes.

Los gastos recurrentes generados nacen con `isConfirmed = false`. No impactan dashboard ni presupuestos hasta que el usuario los confirme desde la lista de gastos.

## Ingresos recurrentes

Las plantillas de ingresos recurrentes usan la misma periodicidad semanal, mensual o anual. Por cada plantilla activa vencida se crea un `Income` pendiente y se avanza `nextRunDate`.

Los ingresos recurrentes generados nacen con `isConfirmed = false`. No impactan dashboard ni balance mensual hasta que el usuario los confirme desde la lista de ingresos.

## Sincronizacion

La Fase 7 prepara CloudKit. El runtime ya puede seleccionar CloudKit privado, pero no lo activa sin una decision explicita de firma y provisioning.

Requisitos pendientes para sincronizacion real:

- Apple Developer Team.
- Bundle ID estable.
- Contenedor iCloud privado.
- Capability iCloud + CloudKit.

La estrategia documentada en `Docs/CLOUDKIT_SYNC.md` usa CloudKit privado con SwiftData. Para conflictos, gana la ultima edicion persistida por registro. La expansion a iPhone requiere adaptar navegacion, reemplazar tablas por listas y validar migraciones con store sincronizado.

## Cotizaciones

La app soporta cotizaciones manuales locales, por ejemplo:

- `USD -> ARS = 1400`
- `EUR -> ARS = 1600`

Tambien se soporta conversion inversa cuando existe una tasa en sentido contrario. La conversion automatica por API queda para una fase posterior.
