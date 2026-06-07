# Expense Tracker macOS

## Tecnologias

- Swift 6
- SwiftUI
- SwiftData
- Charts
- macOS 15+
- XCTest para tests

## Arquitectura

- MVVM
- `Views/` para pantallas SwiftUI
- `Models/` para entidades SwiftData y tipos de dominio
- `ViewModels/` para estado, validacion y logica de presentacion
- `Services/` para integraciones o logica compartida cuando haga falta
- `Docs/` para documentacion tecnica

## Reglas de trabajo

- No usar UIKit salvo que sea estrictamente necesario.
- Mantener compatibilidad con SwiftData.
- Priorizar componentes reutilizables.
- No agregar dependencias externas sin aprobacion.
- Usar async/await para trabajo asincronico.
- Mantener codigo documentado cuando la intencion no sea obvia.
- Mantener la app en espanol mientras no se defina una estrategia de localizacion.
- No sumar backend, login ni servicios externos sin una decision explicita.
- Cuando se complete una funcionalidad importante, actualizar `PROJECT_CONTEXT.md` con decisiones tomadas, estado actual y proximos pasos.
- Si el alcance cambia de manera relevante, actualizar tambien `ROADMAP.md`.

## Monedas soportadas

- ARS
- USD
- EUR

Las monedas deben ser configurables por el usuario. Los importes de monedas distintas no deben sumarse como si fueran equivalentes sin una fuente de tipo de cambio definida.

## Objetivo

Aplicacion personal para seguimiento de gastos, ingresos y patrimonio.

## Mantenimiento de documentación

Después de completar cualquier tarea:

1. Actualizar PROJECT_CONTEXT.md.
2. Registrar decisiones arquitectónicas.
3. Actualizar funcionalidades implementadas.
4. Actualizar próximos pasos.
5. Actualizar problemas conocidos.

Antes de comenzar:
- Leer PROJECT_CONTEXT.md

Al finalizar:
- Actualizar PROJECT_CONTEXT.md