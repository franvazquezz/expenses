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
- [ ] Exportar Excel.
- [ ] Exportar JSON.
- [x] Importar CSV de gastos.
- [ ] Importar CSV de bancos.

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
- [ ] Sincronizacion iCloud con CloudKit + SwiftData.
- [ ] Sincronizacion entre MacBook, iMac y Mac Mini.

## Fase 11 - Funciones avanzadas

- [ ] Objetivos de ahorro.
- [ ] Comparacion mensual.
- [ ] Alertas de presupuesto superado.
- [ ] Alertas de gasto inusual.
- [ ] Recordatorio de carga diaria.

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
- [ ] UI tests para flujos principales.
- [ ] Tests de migracion SwiftData.
- [ ] Revision de accesibilidad.
- [ ] Revision general de rendimiento con volumen alto de datos.

## Proximas fases posibles

- Preferencias de moneda principal.
- Conversion de moneda si se define fuente de tipo de cambio.
- Conversion automatica con API: ExchangeRate API, Frankfurter u Open Exchange Rates.
