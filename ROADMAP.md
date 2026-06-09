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
- [x] Optimizacion de presupuestos y resumen por cuenta para volumen alto.
- [x] Tests de volumen y performance para agregados compartidos.
- [x] Identificadores de accesibilidad ampliados en pantallas principales.
- [x] Ejecutar UI tests en entorno macOS con automatizacion habilitada.
- [x] Smoke test de navegacion por pantallas principales.
- [x] Plan de migracion SwiftData versionado inicial.
- [x] Tests de migracion SwiftData versionada inicial.
- [ ] Validacion manual de accesibilidad con VoiceOver y navegacion por teclado.

## Fase 9 - Funciones avanzadas locales

- [x] Objetivos de ahorro.
- [x] Comparacion mensual.
- [x] Alertas de presupuesto superado.
- [x] Alertas de gasto inusual.
- [x] Recordatorio de carga diaria configurable localmente.
- [x] Notificaciones locales del sistema para recordatorio diario.

## Fase 10 - Transicion a stack web Next + Prisma

Objetivo: pasar el producto desde una app macOS local basada en SwiftUI/SwiftData a una aplicacion web del stack habitual con Next.js, Prisma y base relacional, preservando reglas de negocio, datos y soporte multi-moneda.

- [ ] Definir si la app web reemplaza completamente a la app macOS o si conviven durante una etapa de transicion.
- [x] Elegir base de datos objetivo para Prisma, preferentemente PostgreSQL si no hay restriccion operativa.
- [x] Definir autenticacion como parte del alcance web: usuario propio de la app con acceso por Google y GitHub usando email verificado.
- [x] Definir si se permite login solo con proveedores OAuth o si se agrega tambien magic link/password en una fase posterior.
- [ ] Congelar el alcance funcional inicial de la version web: dashboard, gastos, ingresos, cuentas, presupuestos, recurrencias, objetivos, importacion/exportacion y backup.
- [x] Mapear modelos SwiftData actuales a entidades Prisma: usuarios, cuentas OAuth, monedas, cotizaciones, gastos, ingresos, cuentas patrimoniales, presupuestos, recurrencias, objetivos de ahorro y recordatorio diario.
- [x] Agregar ownership por usuario a todas las entidades de datos personales y definir reglas de aislamiento por `userId`.
- [x] Definir normalizacion de email: email verificado como identificador de contacto, sin asumir que todos los proveedores siempre exponen el mismo correo.
- [ ] Definir linking de cuentas: permitir asociar Google y GitHub al mismo usuario solo con confirmacion explicita cuando los emails coincidan o hayan sido verificados.
- [x] Definir reglas de identidad y migracion: IDs estables, fechas, importes decimales, moneda original, moneda base, estado confirmado/pendiente y asociaciones a cuenta.
- [x] Disenar el esquema Prisma inicial con migracion versionada.
- [ ] Crear estrategia de migracion desde backup JSON actual hacia la base Prisma asignando los datos importados a un usuario propietario.
- [ ] Crear pruebas de compatibilidad para importar backups existentes sin perdida de informacion.
- [ ] Separar reglas de dominio reutilizables en servicios puros TypeScript: calculos de dashboard, presupuestos, patrimonio, recurrencias, alertas y conversiones manuales.
- [x] Definir estructura Next.js: rutas de app, componentes de UI, server actions/API routes, capa de datos Prisma y tests.
- [ ] Reimplementar MVP web con flujos principales: dashboard, alta/edicion/listado de gastos, ingresos, cuentas y presupuestos.
- [ ] Incorporar recurrencias y confirmacion de movimientos generados.
- [ ] Incorporar importacion/exportacion CSV, Excel compatible, JSON de movimientos y backup completo.
- [ ] Incorporar objetivos, alertas calculadas y recordatorio como configuracion persistida.
- [ ] Reemplazar readiness CloudKit por una estrategia explicita de despliegue, backups, seguridad y sesiones para la app web.
- [x] Implementar login con Google OAuth.
- [x] Implementar login con GitHub OAuth.
- [ ] Implementar pantalla de perfil basica: email, proveedor vinculado, fecha de creacion y cierre de sesion.
- [ ] Proteger rutas y acciones de datos para que solo operen sobre el usuario autenticado.
- [ ] Crear suite de tests web: unitarios de dominio, integracion con Prisma y e2e de flujos principales.
- [ ] Validar UI responsive para desktop primero y mobile despues si se decide usarla desde telefono.
- [ ] Documentar operacion local: variables de entorno, migraciones Prisma, seed, backup y restore.

## Fase 11 - Cierre de migracion

- [ ] Ejecutar migracion de datos desde un backup real de la app SwiftData.
- [ ] Asignar datos migrados al usuario inicial y validar que no existan registros sin propietario.
- [ ] Comparar totales por moneda entre app macOS y app web.
- [ ] Comparar saldos de cuentas, patrimonio neto, presupuestos y movimientos recurrentes pendientes.
- [ ] Definir fecha de corte para dejar de cargar datos en la app macOS.
- [ ] Mantener la app macOS como referencia historica hasta validar la version web con datos reales.
- [ ] Actualizar documentacion para marcar SwiftUI/SwiftData como implementacion anterior si la web pasa a ser principal.
