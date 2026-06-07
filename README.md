# expenses

App nativa para macOS hecha con SwiftUI y SwiftData para registrar y analizar gastos personales.

## Estado actual

Fase 1 en progreso:

- App macOS nativa.
- SwiftUI para UI.
- SwiftData para persistencia local.
- Soporte Dark Mode mediante estilos adaptativos de SwiftUI.
- Idioma inicial: espanol.
- Arquitectura MVVM.
- Crear, editar, eliminar y duplicar gastos.
- Campos de gasto: monto, moneda, fecha, categoria, descripcion, metodo de pago, notas y etiquetas.
- Dashboard con totales del mes, totales del ano, gastos del dia, ultimos gastos y categorias con mayor gasto.
- Multi-moneda con monedas personalizables.
- Moneda principal configurable.
- Cotizaciones manuales locales.
- Conversión guardada por gasto: monto original, moneda original, monto convertido y moneda base.

## Abrir en Xcode

Abrir:

```bash
open expenses.xcodeproj
```

Scheme principal:

```text
expenses
```

## Build y tests

Build:

```bash
xcodebuild -project expenses.xcodeproj -scheme expenses -destination 'platform=macOS' build
```

Tests:

```bash
xcodebuild test -project expenses.xcodeproj -scheme expenses -destination 'platform=macOS'
```

## Documentacion

- [Arquitectura](Docs/ARCHITECTURE.md)
- [Testing](Docs/TESTING.md)
- [Roadmap](Docs/ROADMAP.md)
