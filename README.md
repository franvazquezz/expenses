# expenses

App nativa para macOS hecha con SwiftUI y SwiftData para registrar y analizar gastos personales.

Nota: el roadmap actual plantea una transicion futura al stack web habitual con Next.js, Prisma, base relacional y login por Google/GitHub, manteniendo esta app macOS como implementacion actual y referencia para migracion de datos.

## App web en migracion

La Fase 14 ya esta iniciada en [web](/Users/franciscovazquez/Pancho/Repos/expenses/web):

- Next.js App Router.
- Prisma 7 con PostgreSQL como base objetivo.
- Auth.js con proveedores Google y GitHub configurables por variables de entorno.
- Schema Prisma inicial equivalente al modelo SwiftData actual.
- Entidades personales aisladas por `userId`.

Ver instrucciones especificas en [web/README.md](/Users/franciscovazquez/Pancho/Repos/expenses/web/README.md).

## Estado actual

Fases 1 a 11 implementadas en modo local:

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
- Registro de ingresos por sueldo, freelance, ventas y otros.
- Dashboard con ingresos, gastos y balance mensual.
- Presupuestos mensuales por categoria.
- Visualizacion de consumido, restante, porcentaje y barra de progreso.
- Gastos recurrentes semanales, mensuales y anuales.
- Generacion automatica local de gastos vencidos.
- Ingresos recurrentes semanales, mensuales y anuales.
- Generacion automatica local de ingresos vencidos.
- Movimientos recurrentes generados como pendientes hasta confirmacion.
- Dashboard y presupuestos calculados solo con movimientos confirmados.
- Pantalla de sincronizacion con readiness para CloudKit.
- Preparacion runtime para SwiftData con CloudKit privado cuando la configuracion iCloud este completa.
- Estrategia de sincronizacion documentada en `Docs/CLOUDKIT_SYNC.md`.
- Busqueda y filtros avanzados en gastos e ingresos.
- Graficos de analisis mensual, categorias, balance y metodo de pago.
- Exportacion e importacion CSV de gastos e ingresos.
- Exportacion Excel compatible de movimientos.
- Exportacion JSON de movimientos.
- Importacion CSV bancaria normalizada.
- Backup y restauracion local en JSON.
- Patrimonio con cuentas, activos y pasivos manuales.
- Calculo de patrimonio neto por moneda.
- Gastos e ingresos asociados opcionalmente a cuentas.
- Impacto automatico de movimientos confirmados sobre saldos de cuentas.
- Dashboard analitico por cuenta con ingresos, gastos y flujo neto.
- Equivalente total de patrimonio en moneda principal usando cotizaciones manuales.
- Objetivos de ahorro con avance, moneda y fecha opcional.
- Comparacion mensual de ingresos, gastos y balance contra el mes anterior.
- Alertas de presupuesto superado y gasto inusual.
- Recordatorio diario configurable localmente.
- Notificacion local diaria para recordatorio de carga.
- Inicio de Fase 8 de calidad con optimizacion de agregados mensuales, test de volumen alto y compatibilidad de backups previos sin cuentas.
- Optimizacion de presupuestos y resumen por cuenta para volumen alto de datos.
- Identificadores de accesibilidad ampliados para pantallas, formularios y acciones principales.
- UI tests activos para smoke tests de dashboard/gastos y navegacion principal, con store SwiftData en memoria durante ejecucion de pruebas.
- Schema SwiftData versionado inicial con `ExpensesSchemaV1` y `ExpensesMigrationPlan`.

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
- [Sincronizacion CloudKit](Docs/CLOUDKIT_SYNC.md)
- [Testing](Docs/TESTING.md)
- [Roadmap](Docs/ROADMAP.md)
