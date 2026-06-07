# Arquitectura

La app usa una arquitectura MVVM simple.

## Capas

### Models

Contiene entidades persistidas con SwiftData.

- `Expense`: representa un gasto local con monto, moneda, fecha, categoria, descripcion, metodo de pago, notas y etiquetas.
- `Currency`: representa una moneda configurable por el usuario, con codigo, nombre, simbolo, estado activo y marca de moneda principal.
- `ExchangeRate`: representa una cotizacion manual entre dos monedas.

### ViewModels

Contiene logica de presentacion y transformacion de datos.

- `ExpenseFormViewModel`: valida y normaliza datos del formulario.
- `ExpenseListViewModel`: filtra gastos, genera categorias disponibles y duplica gastos.
- `DashboardViewModel`: calcula totales, ultimos gastos y rankings por categoria.
- `CurrencyViewModel`: crea, edita, desactiva y define moneda principal.
- `ExchangeRateViewModel`: crea, edita y aplica cotizaciones manuales.

### Views

Contiene pantallas SwiftUI.

- `DashboardView`: pantalla principal con resumen y navegacion.
- `ExpenseListView`: tabla de gastos con filtros y acciones.
- `AddExpenseView`: alta de gasto.
- `EditExpenseView`: edicion de gasto.
- `CurrencySettingsView`: administracion de monedas y cotizaciones manuales.

## Persistencia

La persistencia local se configura en `expensesApp` con:

```swift
.modelContainer(for: Expense.self)
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

## Cotizaciones

La app soporta cotizaciones manuales locales, por ejemplo:

- `USD -> ARS = 1400`
- `EUR -> ARS = 1600`

Tambien se soporta conversion inversa cuando existe una tasa en sentido contrario. La conversion automatica por API queda para una fase posterior.
