# Estado actual del proyecto

## Resumen

App nativa de macOS para registrar y analizar gastos personales. La primera version esta enfocada en gastos, ingresos, presupuestos, recurrencias, persistencia local y dashboard basico.

## Decisiones tomadas

- SwiftUI para la interfaz.
- SwiftData como base local.
- Arquitectura MVVM.
- XCTest para tests unitarios.
- Sin backend.
- Sin login.
- Sin dependencias externas.
- Idioma inicial: espanol.
- Soporte multi-moneda desde la primera version.
- Los totales del dashboard se agrupan por moneda.
- No se convierten monedas ni se suman importes de monedas distintas sin una fuente de tipo de cambio.
- Las recurrencias se modelan como plantillas SwiftData separadas de los movimientos generados.
- La generacion de recurrentes crea movimientos vencidos al abrir la app y tambien puede dispararse manualmente desde cada pantalla de recurrentes.
- Los movimientos creados manualmente nacen confirmados.
- Los movimientos generados por recurrencia nacen pendientes y no impactan dashboard ni presupuestos hasta confirmarse.
- CloudKit queda evaluado y preparado a nivel de requisitos, pero no se activa sin Apple Developer Team, Bundle ID estable y contenedor iCloud definido.
- La estrategia de conflictos para sincronizacion sera ultima edicion persistida por registro; los movimientos recurrentes pendientes evitan impacto automatico antes de revision.
- GitHub CLI queda habilitado localmente en `.tools/gh-cli` para esta copia de trabajo; la autenticacion esta configurada en Keychain para la cuenta `franvazquezz`.
- El repositorio GitHub queda normalizado con `origin` como remote canonico, `main` como rama principal y `development` como rama de desarrollo en reemplazo de `master`.
- El patrimonio se modela como cuentas manuales de tipo activo o pasivo. Los saldos se agrupan por moneda y el patrimonio neto se calcula por moneda sin consolidar divisas distintas.
- Los gastos e ingresos pueden asociarse a una cuenta de la misma moneda original. Los gastos confirmados restan saldo y los ingresos confirmados suman saldo; al editar, eliminar o cambiar estado se revierte/aplica el impacto correspondiente.
- El equivalente total de patrimonio en moneda principal usa solamente cotizaciones manuales disponibles; las monedas sin cotizacion se informan y no se suman.
- Los backups JSON incluyen cuentas de patrimonio y mantienen compatibilidad al restaurar backups previos sin cuentas.
- CloudKit queda pospuesto hasta cerrar patrimonio y una ronda de calidad.
- La Fase 8 de calidad comienza por optimizar y medir agregados del dashboard antes de incorporar UI tests y migraciones SwiftData reales.
- Los UI tests quedan en un target separado `expensesUITests`; la app usa SwiftData en memoria cuando se lanza con `EXPENSES_UI_TESTING=1`.
- El scheme principal ejecuta unit tests y UI tests. Los UI tests crean una ventana con `Command + N` al iniciar para evitar fallos por restauracion de estado de macOS sin ventanas abiertas.
- La exportacion JSON de movimientos queda separada del backup completo: incluye gastos e ingresos para analisis o intercambio, sin presupuestos, monedas, cotizaciones, recurrencias ni cuentas como entidades independientes.
- La Fase 9 de busquedas del roadmap detallado ya esta cubierta por los filtros existentes de texto, fecha/mes, categoria, moneda, cuenta y metodo de pago.
- La exportacion Excel se resuelve sin dependencias externas mediante XML Spreadsheet 2003 compatible con Excel, guardado como `.xls`.
- La importacion bancaria usa un CSV normalizado: `date,description,amount,currency,category,paymentMethod,note,accountName,isConfirmed`. Importes negativos crean gastos; positivos crean ingresos; `accountName` asocia una cuenta existente si coincide nombre y moneda.
- La persistencia queda centralizada en `AppPersistenceService`: usa memoria para UI tests, store local por defecto y CloudKit privado solo cuando readiness confirma Bundle ID estable, Apple Developer Team, contenedor iCloud y capability habilitada.
- La configuracion de readiness se lee desde claves generadas en `Info.plist` por Xcode: `EXPENSESDevelopmentTeam`, `EXPENSESCloudKitContainerIdentifier` y `EXPENSESCloudKitEnabled`.
- La Fase 11 queda implementada como funciones avanzadas locales: objetivos de ahorro, comparacion mensual, alertas calculadas y recordatorio diario configurable.
- El recordatorio diario se guarda como preferencia local en SwiftData y agenda una notificacion local diaria con `UserNotifications` cuando el usuario lo activa.
- Las alertas de presupuesto y gasto inusual son derivadas en view models; no se persisten como eventos para evitar estado duplicado.
- Los backups JSON incluyen objetivos de ahorro y configuracion de recordatorio, manteniendo compatibilidad con backups previos sin esos campos.
- La revision de rendimiento posterior a Fase 11 optimiza agregados de presupuestos y resumen por cuenta usando diccionarios de acumulacion para evitar recorridas anidadas con alto volumen.
- La revision de accesibilidad programatica amplia identificadores de pantallas, formularios y acciones principales para facilitar UI tests y automatizacion futura.
- La persistencia usa `ExpensesSchemaV1` y `ExpensesMigrationPlan` como base versionada inicial de SwiftData, sin etapas de migracion todavia porque no hay version previa versionada que migrar.

## Funcionalidades implementadas

- [x] Crear gasto.
- [x] Editar gasto.
- [x] Eliminar gasto.
- [x] Duplicar gasto.
- [x] Categorizar gasto.
- [x] Agregar notas.
- [x] Etiquetas opcionales.
- [x] Metodo de pago.
- [x] Dashboard con totales del mes.
- [x] Dashboard con totales del ano.
- [x] Gastos del dia.
- [x] Ultimos gastos.
- [x] Ranking de categorias con mayor gasto.
- [x] Ingresos.
- [x] Dashboard con ingresos, gastos y balance mensual.
- [x] Presupuestos mensuales por categoria.
- [x] Gestion de monedas activas.
- [x] Preferencias de moneda principal.
- [x] Gastos recurrentes.
- [x] Ingresos recurrentes.
- [x] Generacion automatica de movimientos recurrentes vencidos.
- [x] Generacion manual de movimientos recurrentes pendientes.
- [x] Marcado de movimientos recurrentes como confirmados.
- [x] Evaluacion de CloudKit.
- [x] Estrategia de conflictos para sincronizacion.
- [x] Pantalla de estado de sincronizacion y requisitos pendientes.
- [x] Preparacion runtime para SwiftData con CloudKit privado.
- [x] Documentacion tecnica de CloudKit en `Docs/CLOUDKIT_SYNC.md`.
- [x] Busqueda por texto en gastos e ingresos.
- [x] Filtros avanzados de gastos por categoria, etiqueta, moneda, metodo de pago y estado.
- [x] Filtros avanzados de ingresos por categoria, moneda y estado.
- [x] Graficos de gastos por mes.
- [x] Grafico de gastos por categoria.
- [x] Comparacion mensual de ingresos, gastos y balance.
- [x] Tendencia de balance mensual.
- [x] Resumen por metodo de pago.
- [x] Exportacion CSV de gastos e ingresos.
- [x] Exportacion Excel de movimientos.
- [x] Exportacion JSON de movimientos.
- [x] Importacion CSV de gastos e ingresos.
- [x] Importacion CSV bancaria normalizada.
- [x] Validacion de importaciones CSV.
- [x] Backup local JSON.
- [x] Restauracion local desde backup JSON sin borrar datos existentes.
- [x] Modelo de cuentas para patrimonio.
- [x] Registro, edicion, desactivacion y eliminacion de activos y pasivos.
- [x] Calculo de patrimonio neto por moneda.
- [x] Resumen de patrimonio en dashboard.
- [x] Asociacion opcional de gastos e ingresos a cuentas.
- [x] Impacto automatico de movimientos confirmados en saldos de cuentas.
- [x] Filtros y columnas por cuenta en gastos e ingresos.
- [x] Dashboard analitico por cuenta con saldo, ingresos, gastos y flujo neto.
- [x] Equivalente total de patrimonio en moneda principal con cotizaciones manuales.
- [x] Backup y restauracion de cuentas de patrimonio.
- [x] Objetivos de ahorro con monto objetivo, avance, moneda, fecha opcional y estado activo.
- [x] Pantalla de funciones avanzadas para objetivos, comparacion mensual, alertas y recordatorio diario.
- [x] Resumen de objetivos, alertas y recordatorio en dashboard.
- [x] Comparacion mensual de ingresos, gastos y balance contra el mes anterior.
- [x] Alertas de presupuesto superado.
- [x] Alertas de gasto inusual basadas en promedio historico por categoria y moneda.
- [x] Recordatorio de carga diaria configurable localmente.
- [x] Notificacion local diaria para recordatorio de carga cuando esta activado.
- [x] Backup y restauracion de objetivos de ahorro y recordatorio diario.
- [x] Tests unitarios iniciales para view models.
- [x] Tests unitarios para presupuestos, ingresos y recurrencias.
- [x] Tests unitarios para busqueda y filtros.
- [x] Tests unitarios para agregados de analisis.
- [x] Tests unitarios para transferencia de datos.
- [x] Tests unitarios de readiness de sincronizacion.
- [x] Tests unitarios de seleccion de persistencia local, memoria y CloudKit.
- [x] Tests unitarios para patrimonio.
- [x] Tests unitarios para impacto de movimientos en cuentas.
- [x] Tests unitarios para resumen de movimientos por cuenta.
- [x] Tests unitarios para equivalente de patrimonio en moneda principal.
- [x] Tests unitarios para objetivos de ahorro, alertas avanzadas y comparacion mensual.
- [x] Optimizacion inicial de agregados mensuales del dashboard para volumen alto de datos.
- [x] Test unitario de volumen alto para agregados mensuales del dashboard.
- [x] Optimizacion de progreso de presupuestos para volumen alto de movimientos.
- [x] Optimizacion de resumen de movimientos por cuenta para volumen alto de datos.
- [x] Tests unitarios de volumen y performance para presupuestos y resumen por cuenta.
- [x] Identificadores de accesibilidad ampliados para pantallas, formularios y acciones principales.
- [x] Ejecucion de UI tests dentro del scheme principal con automatizacion macOS habilitada.
- [x] Smoke test de navegacion por pantallas principales.
- [x] Plan de migracion SwiftData versionado inicial con `ExpensesSchemaV1`.
- [x] Test unitario para el plan de migracion SwiftData versionado inicial.
- [x] Tests unitarios para calculo de proxima notificacion diaria.
- [x] Test de compatibilidad para backups previos sin cuentas de patrimonio.
- [x] Target de UI tests con smoke tests de dashboard, navegacion a gastos y apertura de alta de gasto.
- [x] Test de esquema SwiftData actual con `ModelContainer` en memoria.
- [x] Identificadores de accesibilidad iniciales para navegacion y alta de gastos.
- [x] Documentacion inicial en `Docs/`.

## Funcionalidades pendientes

- [ ] Validacion manual de accesibilidad con VoiceOver y navegacion por teclado.
- [ ] Activar CloudKit real con entitlements, Apple Developer Team y contenedor iCloud.
- [ ] Sincronizacion entre Macs.

## Proximos pasos

1. Validar accesibilidad manual con VoiceOver y navegacion por teclado.
2. Retomar CloudKit cuando se decida hacerlo: Apple Developer Team, Bundle ID final, contenedor iCloud y capability iCloud + CloudKit.
3. Activar `EXPENSES_CLOUDKIT_ENABLED`, configurar entitlements reales y validar sincronizacion entre Macs.
4. Cuando cambien modelos SwiftData, agregar una nueva version de schema y una etapa concreta en `ExpensesMigrationPlan`.

## Problemas conocidos

- Al agregar nuevos modelos SwiftData, se debe crear una nueva version de schema y una etapa de migracion desde `ExpensesSchemaV1`; durante desarrollo, bases locales viejas no versionadas pueden requerir recreacion del store.
- La sincronizacion real esta bloqueada por configuracion de firma/iCloud fuera del codigo fuente actual: Apple Developer Team, Bundle ID estable, contenedor iCloud, capability y entitlements.
- La restauracion de backup local importa registros y omite monedas/cotizaciones ya existentes; no reemplaza destructivamente la base actual.
- Los saldos de cuentas se impactan automaticamente solo desde movimientos confirmados asociados a cuenta; no hay conciliacion contra extractos bancarios.
- Si una base local previa no tiene `accountID` en gastos o ingresos, esos movimientos quedan sin cuenta asociada.
- Los UI tests requieren permisos de automatizacion/accesibilidad para Xcode en macOS; sin esos permisos el runner puede fallar antes de interactuar con la app.
- La exportacion Excel genera XML Spreadsheet 2003, no `.xlsx` nativo, para evitar dependencias externas.
- Los CSV bancarios de bancos reales deben normalizarse al encabezado soportado antes de importarse.
- El recordatorio diario usa notificaciones locales del sistema y solicita autorizacion al activarse; si el usuario deniega permisos, se cancela la notificacion pendiente.

## Notas para futuras sesiones

- Antes de cambiar modelos SwiftData, revisar el impacto en migraciones.
- Antes de sumar conversion de moneda, definir fuente de tipo de cambio y reglas de actualizacion.
- Mantener sincronizados `README.md`, `Docs/ROADMAP.md`, `ROADMAP.md` y este archivo cuando cambie el estado del proyecto.
- Para usar GitHub CLI desde esta sesion sin instalacion global, ejecutar `.tools/gh-cli` o agregar `.tools` al `PATH`.
- La rama remota `master` fue eliminada despues de publicar su contenido como `development`; `main` y `development` apuntan al estado completo actual de la app.
