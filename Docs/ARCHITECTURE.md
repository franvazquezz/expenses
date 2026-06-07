# Arquitectura

La app usa una arquitectura MVVM simple.

## Capas

### Models

Contiene entidades persistidas con SwiftData.

- `Expense`: representa un gasto local con monto, moneda, fecha, categoria, descripcion, metodo de pago, notas y etiquetas.

### ViewModels

Contiene logica de presentacion y transformacion de datos.

- `ExpenseFormViewModel`: valida y normaliza datos del formulario.
- `ExpenseListViewModel`: filtra gastos, genera categorias disponibles y duplica gastos.
- `DashboardViewModel`: calcula totales, ultimos gastos y rankings por categoria.

### Views

Contiene pantallas SwiftUI.

- `DashboardView`: pantalla principal con resumen y navegacion.
- `ExpenseListView`: tabla de gastos con filtros y acciones.
- `AddExpenseView`: alta de gasto.
- `EditExpenseView`: edicion de gasto.

## Persistencia

La persistencia local se configura en `expensesApp` con:

```swift
.modelContainer(for: Expense.self)
```

SwiftData administra el almacenamiento local. No hay backend ni login en esta fase.

## Monedas

Los totales del dashboard se agrupan por moneda. No se convierten monedas ni se suman importes de monedas distintas.
