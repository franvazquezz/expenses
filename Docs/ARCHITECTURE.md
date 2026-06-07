# Arquitectura

La app usa una arquitectura MVVM simple.

## Capas

### Models

Contiene entidades persistidas con SwiftData.

- `Expense`: representa un gasto local con monto, moneda, fecha, categoria, descripcion, metodo de pago, notas y etiquetas.
- `Currency`: representa una moneda configurable por el usuario, con codigo, nombre, simbolo, estado activo y marca de moneda principal.
- `ExchangeRate`: representa una cotizacion manual entre dos monedas.
- `Income`: representa un ingreso local con monto original, moneda original, monto convertido y moneda base.
- `Budget`: representa un presupuesto mensual por categoria, moneda y estado activo.
- `RecurringExpense`: representa una plantilla de gasto recurrente con periodicidad, proxima fecha de generacion y estado activo.

### ViewModels

Contiene logica de presentacion y transformacion de datos.

- `ExpenseFormViewModel`: valida y normaliza datos del formulario.
- `ExpenseListViewModel`: filtra gastos, genera categorias disponibles y duplica gastos.
- `DashboardViewModel`: calcula totales, ultimos gastos y rankings por categoria.
- `CurrencyViewModel`: crea, edita, desactiva y define moneda principal.
- `ExchangeRateViewModel`: crea, edita y aplica cotizaciones manuales.
- `IncomeFormViewModel`: valida, normaliza y convierte ingresos.
- `IncomeListViewModel`: filtra ingresos por mes y categoria.
- `BudgetViewModel`: valida presupuestos y calcula consumido, restante y porcentaje.
- `RecurringExpenseViewModel`: valida plantillas recurrentes y genera gastos pendientes.

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

## Persistencia

La persistencia local se configura en `expensesApp` con:

```swift
.modelContainer(for: [Expense.self, Income.self, Currency.self, ExchangeRate.self, Budget.self, RecurringExpense.self])
```

SwiftData administra el almacenamiento local. No hay backend ni login en esta fase.

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

## Cotizaciones

La app soporta cotizaciones manuales locales, por ejemplo:

- `USD -> ARS = 1400`
- `EUR -> ARS = 1600`

Tambien se soporta conversion inversa cuando existe una tasa en sentido contrario. La conversion automatica por API queda para una fase posterior.
