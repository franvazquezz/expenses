# Sincronizacion con CloudKit

## Estado

La app usa SwiftData local por defecto. El runtime ya puede crear un `ModelContainer` con CloudKit privado cuando la configuracion de readiness esta completa, pero no se activa hasta contar con:

- Apple Developer Team.
- Bundle ID estable, no `com.local.expenses`.
- Contenedor iCloud privado, por ejemplo `iCloud.com.pancho.expenses`.
- Capability iCloud + CloudKit configurada en Xcode.

Mientras esos datos no esten configurados, `AppPersistenceService` fuerza persistencia local. Durante UI tests usa un store SwiftData en memoria con `EXPENSES_UI_TESTING=1`.

## Decision

La sincronizacion debe usar CloudKit privado con SwiftData. No se agrega backend propio ni login externo; la identidad depende de la cuenta iCloud del usuario.

## Activacion

La app lee estos valores desde el `Info.plist` generado por Xcode:

- `EXPENSESDevelopmentTeam`.
- `EXPENSESCloudKitContainerIdentifier`.
- `EXPENSESCloudKitEnabled`.

El proyecto define los build settings `EXPENSES_CLOUDKIT_CONTAINER_IDENTIFIER` y `EXPENSES_CLOUDKIT_ENABLED` en `NO` por defecto. Para activar sincronizacion real hay que configurar ademas el Apple Developer Team, un Bundle ID estable, la capability iCloud + CloudKit y los entitlements del contenedor.

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
