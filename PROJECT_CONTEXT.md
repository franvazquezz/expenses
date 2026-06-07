# Estado actual del proyecto

## Resumen

App nativa de macOS para registrar y analizar gastos personales. La primera version esta enfocada en gastos, persistencia local y dashboard basico.

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
- [x] Tests unitarios iniciales para view models.
- [x] Documentacion inicial en `Docs/`.

## Funcionalidades pendientes

- [ ] Preferencias de moneda principal.
- [ ] Gestion de monedas activas.
- [ ] Presupuestos mensuales por categoria.
- [ ] Busqueda por texto, etiquetas y metodo de pago.
- [ ] Exportacion CSV.
- [ ] Importacion CSV.
- [ ] Graficos por mes y categoria.
- [ ] Ingresos.
- [ ] Patrimonio.
- [ ] Gastos recurrentes.
- [ ] CloudKit.
- [ ] UI tests para flujos principales.

## Proximos pasos

1. Preferencias de moneda principal y monedas activas.
2. Presupuestos mensuales por categoria.
3. Busqueda y filtros avanzados.
4. Graficos por mes y categoria.
5. Exportacion e importacion CSV.
6. Ingresos y patrimonio.
7. CloudKit cuando la base local este estable.

## Problemas conocidos

Ninguno documentado.

## Notas para futuras sesiones

- Antes de cambiar modelos SwiftData, revisar el impacto en migraciones.
- Antes de sumar conversion de moneda, definir fuente de tipo de cambio y reglas de actualizacion.
- Mantener sincronizados `README.md`, `Docs/ROADMAP.md`, `ROADMAP.md` y este archivo cuando cambie el estado del proyecto.
