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
