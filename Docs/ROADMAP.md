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

## Proximas fases posibles

- Presupuestos mensuales por categoria.
- Busqueda por texto, etiquetas y metodo de pago.
- Exportacion CSV.
- Importacion CSV.
- Graficos por mes y categoria.
- Preferencias de moneda principal.
- Conversion de moneda si se define fuente de tipo de cambio.
- Conversion automatica con API: ExchangeRate API, Frankfurter u Open Exchange Rates.
- UI tests para flujos completos.
