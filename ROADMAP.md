# Roadmap

## Fase 1 - Base de gastos

- [x] App nativa macOS.
- [x] SwiftUI.
- [x] SwiftData local.
- [x] Soporte Dark Mode.
- [x] Idioma inicial espanol.
- [x] Arquitectura MVVM.
- [x] Crear gasto.
- [x] Editar gasto.
- [x] Eliminar gasto.
- [x] Duplicar gasto.
- [x] Categorizar gasto.
- [x] Agregar notas.
- [x] Etiquetas opcionales.
- [x] Metodo de pago.
- [x] Dashboard mensual y anual.
- [x] Gastos del dia.
- [x] Ultimos gastos.
- [x] Categorias con mayor gasto.
- [x] Tests unitarios iniciales.
- [x] Documentacion inicial.

## Fase 2 - Configuracion y control

- [x] Preferencias de moneda principal.
- [x] Gestion de monedas activas.
- [x] Busqueda por texto.
- [x] Filtros por categoria, etiquetas, moneda y metodo de pago.
- [x] Presupuestos mensuales por categoria.
- [x] Alertas visuales de presupuesto.

## Fase 3 - Analisis

- [x] Graficos por mes.
- [x] Graficos por categoria.
- [x] Comparacion mensual.
- [x] Tendencias de gasto.
- [x] Resumen por metodo de pago.

## Fase 4 - Datos

- [x] Exportacion CSV.
- [x] Importacion CSV.
- [x] Validacion de importaciones.
- [x] Backup local.
- [x] Restauracion desde backup local.

## Fase 5 - Ingresos y patrimonio

- [x] Registrar ingresos.
- [x] Categorizar ingresos.
- [x] Dashboard de flujo mensual.
- [x] Registrar cuentas o activos.
- [x] Registrar pasivos.
- [x] Calcular patrimonio neto.
- [x] Impactar gastos e ingresos en cuentas.
- [x] Filtrar movimientos por cuenta.
- [x] Calcular equivalente total en moneda base con cotizaciones manuales.

## Fase 6 - Recurrencia y automatizacion

- [x] Gastos recurrentes.
- [x] Ingresos recurrentes.
- [x] Generacion automatica de movimientos esperados.
- [x] Marcado de movimientos como confirmados.

## Fase 7 - Sincronizacion

- [x] Evaluar CloudKit.
- [x] Definir estrategia de conflictos.
- [x] Preparacion runtime para SwiftData con CloudKit privado.
- [ ] Sincronizacion entre Macs.
- [x] Preparar base para iPhone si se decide expandir plataforma.

## Fase 8 - Calidad

- [x] Optimizacion inicial de agregados mensuales del dashboard para volumen alto.
- [x] Test de volumen alto para dashboard mensual.
- [x] Test de compatibilidad de backup previo sin cuentas.
- [x] Target de UI tests con smoke tests de dashboard, navegacion a gastos y apertura de alta de gasto.
- [x] Test de esquema SwiftData actual con `ModelContainer` en memoria.
- [x] Identificadores de accesibilidad iniciales para navegacion y alta de gastos.
- [ ] Ejecutar UI tests en entorno macOS con automatizacion habilitada.
- [ ] Tests de migracion SwiftData versionada cuando se defina `SchemaMigrationPlan`.
- [ ] Revision completa de accesibilidad.
- [ ] Revision general de rendimiento con volumen alto de gastos.

## Fase 9 - Funciones avanzadas locales

- [x] Objetivos de ahorro.
- [x] Comparacion mensual.
- [x] Alertas de presupuesto superado.
- [x] Alertas de gasto inusual.
- [x] Recordatorio de carga diaria configurable localmente.
- [ ] Notificaciones del sistema para recordatorio diario si se decide pedir permisos.
