# Roadmap

## Fase 1 - Base de la aplicacion

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
- [x] Campo monto.
- [x] Campo moneda.
- [x] Campo fecha.
- [x] Campo categoria.
- [x] Campo descripcion.
- [x] Campo metodo de pago.
- [x] Campo etiquetas opcionales.
- [x] Total gastado del mes.
- [x] Total gastado del ano.
- [x] Gastos del dia.
- [x] Ultimos gastos.
- [x] Categorias con mayor gasto.
- [x] Tests unitarios iniciales.
- [x] Documentacion inicial.

## Fase 2 - Multi-moneda

- [x] Modelo `Currency`.
- [x] Crear moneda.
- [x] Editar moneda.
- [x] Desactivar moneda.
- [x] Elegir moneda principal.
- [x] Semilla inicial: Peso Argentino ARS.
- [x] Semilla inicial: Dolar Estadounidense USD.
- [x] Semilla inicial: Euro EUR.
- [x] Modelo `ExchangeRate` para cotizaciones manuales.
- [x] Cotizaciones iniciales: `USD -> ARS = 1400`.
- [x] Cotizaciones iniciales: `EUR -> ARS = 1600`.
- [x] Expense guarda `originalAmount`.
- [x] Expense guarda `originalCurrency`.
- [x] Expense guarda `convertedAmount`.
- [x] Expense guarda `baseCurrency`.
- [x] Dashboard usa montos convertidos para estadisticas.
- [x] Tests de conversion manual.

## Fase 3 - Ingresos

- [x] Modelo `Income`.
- [x] Registrar ingresos por Sueldo.
- [x] Registrar ingresos por Freelance.
- [x] Registrar ingresos por Ventas.
- [x] Registrar ingresos por Otros.
- [x] Crear ingreso.
- [x] Editar ingreso.
- [x] Eliminar ingreso.
- [x] Conversión multi-moneda para ingresos.
- [x] Dashboard muestra ingresos.
- [x] Dashboard muestra gastos.
- [x] Dashboard muestra balance.
- [x] Tests de ingresos y balance.

## Fase 4 - Presupuestos

- [x] Modelo `Budget`.
- [x] Presupuestos mensuales por categoria.
- [x] Presupuestos iniciales: Comida, Transporte y Ocio.
- [x] Mostrar consumido.
- [x] Mostrar restante.
- [x] Mostrar porcentaje.
- [x] Mostrar barra de progreso.
- [x] Crear presupuesto.
- [x] Editar presupuesto.
- [x] Activar y desactivar presupuesto.
- [x] Dashboard con avance de presupuestos del mes.
- [x] Tests de calculo de presupuesto.

## Fase 5 - Recurrencia y automatizacion

- [x] Modelo `RecurringExpense`.
- [x] Crear gasto recurrente.
- [x] Editar gasto recurrente.
- [x] Eliminar gasto recurrente.
- [x] Activar y desactivar gasto recurrente.
- [x] Periodicidad semanal.
- [x] Periodicidad mensual.
- [x] Periodicidad anual.
- [x] Generacion automatica al abrir la app.
- [x] Generacion manual de pendientes.
- [x] Tests de generacion recurrente.
- [x] Modelo `RecurringIncome`.
- [x] Crear ingreso recurrente.
- [x] Editar ingreso recurrente.
- [x] Eliminar ingreso recurrente.
- [x] Activar y desactivar ingreso recurrente.
- [x] Generacion automatica de ingresos al abrir la app.
- [x] Generacion manual de ingresos pendientes.
- [x] Tests de generacion de ingresos recurrentes.
- [x] Marcado de movimientos recurrentes como confirmados.
- [x] Dashboard y presupuestos ignoran movimientos pendientes.

## Fase 6 - Graficos

- [x] Dashboard visual con Charts de Apple.
- [x] Torta por categoria.
- [x] Barras por mes.
- [x] Evolucion anual.
- [x] Evolucion por moneda.

## Fase 7 - Cuentas

- [x] Modelo `Account`.
- [x] Cuentas como Efectivo, Mercado Pago, Naranja X, Brubank, Galicia y tarjetas.
- [x] Cada gasto puede impactar en una cuenta.
- [x] Ingresos pueden impactar en una cuenta.
- [x] Filtros y columnas por cuenta en gastos e ingresos.
- [x] Dashboard analitico por cuenta.

## Fase 8 - Importacion y exportacion

- [x] Exportar CSV.
- [x] Exportar Excel.
- [x] Exportar JSON.
- [x] Importar CSV de gastos.
- [x] Importar CSV de bancos.

## Fase 9 - Busquedas

- [x] Buscar por texto.
- [x] Buscar por categoria.
- [x] Buscar por fecha.
- [x] Buscar por moneda.
- [x] Buscar por cuenta.
- [x] Buscar por metodo de pago.

## Fase 10 - Backup

- [x] Exportar base completa local.
- [x] Restaurar base desde backup local.
- [x] Evaluacion CloudKit + SwiftData.
- [x] Estrategia de conflictos de sincronizacion.
- [x] Preparacion para iPhone.
- [x] Preparacion runtime para SwiftData con CloudKit privado.
- [ ] Sincronizacion iCloud con CloudKit + SwiftData.
- [ ] Sincronizacion entre MacBook, iMac y Mac Mini.

## Fase 11 - Funciones avanzadas

- [x] Objetivos de ahorro.
- [x] Comparacion mensual.
- [x] Alertas de presupuesto superado.
- [x] Alertas de gasto inusual.
- [x] Recordatorio de carga diaria configurable localmente.
- [x] Notificaciones locales del sistema para recordatorio diario.

## Fase 12 - Patrimonio personal

- [x] Cuentas bancarias.
- [x] Efectivo.
- [x] USDC.
- [x] Binance.
- [x] Vesseo.
- [x] Inversiones.
- [x] Dashboard de patrimonio total por moneda.
- [x] Equivalente total en moneda base.

## Fase 13 - Calidad

- [x] Optimizacion inicial de agregados mensuales del dashboard para volumen alto.
- [x] Test de volumen alto para dashboard mensual.
- [x] Test de compatibilidad de backup previo sin cuentas.
- [x] Target de UI tests con smoke tests de dashboard, navegacion a gastos y apertura de alta de gasto.
- [x] Test de esquema SwiftData actual con `ModelContainer` en memoria.
- [x] Identificadores de accesibilidad iniciales para navegacion y alta de gastos.
- [x] Optimizacion de progreso de presupuestos para volumen alto.
- [x] Optimizacion de resumen de movimientos por cuenta para volumen alto.
- [x] Tests de volumen y performance para presupuestos y resumen por cuenta.
- [x] Identificadores de accesibilidad ampliados para pantallas, formularios y acciones principales.
- [x] Ejecutar UI tests en entorno macOS con automatizacion habilitada.
- [x] Smoke test de navegacion por pantallas principales.
- [x] Plan de migracion SwiftData versionado inicial.
- [x] Tests de migracion SwiftData versionada inicial.
- [ ] Validacion manual de accesibilidad con VoiceOver y navegacion por teclado.

## Fase 14 - Transicion a stack web Next + Prisma

Objetivo: pasar el producto al stack habitual basado en Next.js, Prisma y base relacional, conservando los datos y reglas ya implementadas en la app macOS.

- [ ] Decidir si la version web reemplaza la app macOS o si ambas conviven temporalmente.
- [x] Elegir base de datos objetivo para Prisma, preferentemente PostgreSQL.
- [x] Incluir autenticacion como requisito de la version web: usuario de la app con login por Google y GitHub usando email verificado.
- [x] Decidir si el login sera solo OAuth o si magic link/password queda para una fase posterior.
- [ ] Definir alcance MVP web: dashboard, gastos, ingresos, cuentas, presupuestos, recurrencias, importacion/exportacion y backup.
- [x] Mapear modelos SwiftData actuales a entidades Prisma, incluyendo `User` y cuentas de proveedor OAuth.
- [x] Agregar `userId` a todas las entidades personales para aislar datos por usuario.
- [x] Definir reglas de email: email verificado como dato de contacto, sin depender de que todos los proveedores devuelvan siempre el mismo correo.
- [ ] Definir linking de Google y GitHub al mismo usuario solo con confirmacion explicita cuando corresponda.
- [x] Definir IDs, tipos decimales, fechas, monedas, estados confirmado/pendiente y asociaciones entre movimientos y cuentas.
- [x] Disenar schema Prisma inicial y migracion versionada.
- [ ] Crear importador desde backup JSON actual hacia Prisma asignando datos a un usuario propietario.
- [ ] Crear tests de compatibilidad de backups existentes.
- [ ] Extraer reglas de dominio a servicios TypeScript puros: dashboard, presupuestos, patrimonio, recurrencias, alertas y conversiones manuales.
- [x] Definir estructura Next.js con rutas, componentes, server actions/API routes, capa Prisma y tests.
- [ ] Implementar MVP web con flujos principales de carga, edicion, listado y dashboard.
- [ ] Reimplementar recurrencias con movimientos pendientes hasta confirmacion.
- [ ] Reimplementar importacion/exportacion CSV, Excel compatible, JSON de movimientos y backup completo.
- [ ] Reimplementar objetivos de ahorro, alertas calculadas y recordatorio persistido.
- [ ] Reemplazar la estrategia CloudKit por decisiones de despliegue, backups, seguridad y sesiones de la app web.
- [x] Implementar login con Google OAuth.
- [x] Implementar login con GitHub OAuth.
- [ ] Implementar perfil basico con email, proveedor vinculado, fecha de creacion y cierre de sesion.
- [ ] Proteger rutas y mutaciones para que cada usuario vea y modifique solo sus datos.
- [ ] Agregar tests unitarios, tests de integracion Prisma y e2e de flujos principales.
- [ ] Validar experiencia desktop primero y mobile despues si se prioriza uso desde telefono.
- [ ] Documentar variables de entorno, migraciones Prisma, seed, backup y restore.

## Fase 15 - Cierre de migracion

- [ ] Migrar datos desde un backup real de SwiftData.
- [ ] Asignar datos migrados al usuario inicial y validar que no queden registros sin propietario.
- [ ] Comparar totales por moneda entre app macOS y app web.
- [ ] Comparar saldos de cuentas, patrimonio neto, presupuestos y recurrentes pendientes.
- [ ] Definir fecha de corte para dejar de cargar datos en la app macOS.
- [ ] Mantener la app macOS como referencia historica hasta validar la version web con datos reales.
- [ ] Actualizar documentacion para marcar SwiftUI/SwiftData como implementacion anterior cuando la web pase a ser principal.

## Proximas fases posibles

- Conversion de moneda si se define fuente de tipo de cambio.
- Conversion automatica con API: ExchangeRate API, Frankfurter u Open Exchange Rates.
