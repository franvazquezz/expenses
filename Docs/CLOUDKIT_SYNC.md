# Sincronizacion con CloudKit

## Estado

La app todavia usa SwiftData local. CloudKit queda preparado a nivel de decision tecnica, pero no se activa hasta contar con:

- Apple Developer Team.
- Bundle ID estable, no `com.local.expenses`.
- Contenedor iCloud privado, por ejemplo `iCloud.com.pancho.expenses`.
- Capability iCloud + CloudKit configurada en Xcode.

## Decision

La sincronizacion debe usar CloudKit privado con SwiftData. No se agrega backend propio ni login externo; la identidad depende de la cuenta iCloud del usuario.

## Estrategia de conflictos

- Cada registro se sincroniza como entidad independiente.
- Si dos Macs editan el mismo registro, gana la version mas reciente que persista CloudKit.
- Las eliminaciones de registros se tratan como eliminaciones definitivas.
- Los movimientos generados por recurrencia nacen pendientes y deben confirmarse manualmente; esto evita que una generacion automatica impacte dashboard o presupuestos antes de revision.
- Las monedas distintas no se consolidan entre si sin una cotizacion definida.

## Preparacion para iPhone

La app debe mantener los modelos SwiftData compartibles entre plataformas. Antes de expandir a iPhone hay que revisar:

- Navegacion adaptativa para pantallas chicas.
- Tablas reemplazables por listas.
- Persistencia y migraciones probadas con store sincronizado.
- Reglas de generacion recurrente para evitar duplicados al abrir la app en varios dispositivos.

## Riesgos

- Agregar CloudKit cambia requisitos de firma y provisioning.
- Cambiar modelos SwiftData durante desarrollo puede requerir migraciones.
- La generacion recurrente en multiples dispositivos necesita una marca de origen o identificador estable por ocurrencia si se detectan duplicados.
