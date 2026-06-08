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
- [x] Importacion CSV de gastos e ingresos.
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
- [x] Tests unitarios iniciales para view models.
- [x] Tests unitarios para presupuestos, ingresos y recurrencias.
- [x] Tests unitarios para busqueda y filtros.
- [x] Tests unitarios para agregados de analisis.
- [x] Tests unitarios para transferencia de datos.
- [x] Tests unitarios de readiness de sincronizacion.
- [x] Tests unitarios para patrimonio.
- [x] Tests unitarios para impacto de movimientos en cuentas.
- [x] Tests unitarios para resumen de movimientos por cuenta.
- [x] Tests unitarios para equivalente de patrimonio en moneda principal.
- [x] Optimizacion inicial de agregados mensuales del dashboard para volumen alto de datos.
- [x] Test unitario de volumen alto para agregados mensuales del dashboard.
- [x] Test de compatibilidad para backups previos sin cuentas de patrimonio.
- [x] Documentacion inicial en `Docs/`.

## Funcionalidades pendientes

- [ ] UI tests para flujos principales.
- [ ] Tests de migracion SwiftData.
- [ ] Revision de accesibilidad.
- [ ] Revision general de rendimiento con volumen alto de datos.
- [ ] Activar CloudKit real con entitlements y contenedor iCloud.
- [ ] Sincronizacion entre Macs.

## Proximos pasos

1. Continuar calidad: UI tests, migraciones SwiftData, accesibilidad y revision general de rendimiento.
2. Retomar CloudKit: Apple Developer Team, Bundle ID final y contenedor iCloud.
3. Activar CloudKit real y validar sincronizacion entre Macs.

## Problemas conocidos

- Al agregar nuevos modelos SwiftData, una base local creada con una version anterior puede requerir migracion o recreacion del store durante desarrollo.
- La sincronizacion real esta bloqueada por configuracion de firma/iCloud fuera del codigo fuente actual.
- La restauracion de backup local importa registros y omite monedas/cotizaciones ya existentes; no reemplaza destructivamente la base actual.
- Los saldos de cuentas se impactan automaticamente solo desde movimientos confirmados asociados a cuenta; no hay conciliacion contra extractos bancarios.
- Si una base local previa no tiene `accountID` en gastos o ingresos, esos movimientos quedan sin cuenta asociada.

## Notas para futuras sesiones

- Antes de cambiar modelos SwiftData, revisar el impacto en migraciones.
- Antes de sumar conversion de moneda, definir fuente de tipo de cambio y reglas de actualizacion.
- Mantener sincronizados `README.md`, `Docs/ROADMAP.md`, `ROADMAP.md` y este archivo cuando cambie el estado del proyecto.
- Para usar GitHub CLI desde esta sesion sin instalacion global, ejecutar `.tools/gh-cli` o agregar `.tools` al `PATH`.
- La rama remota `master` fue eliminada despues de publicar su contenido como `development`; `main` y `development` apuntan al estado completo actual de la app.
