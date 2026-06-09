# Expenses Web

Aplicacion web Next.js para migrar el tracker de gastos desde SwiftUI/SwiftData al stack Next + Prisma.

## Stack

- Next.js App Router
- React
- Tailwind CSS
- Prisma 7
- PostgreSQL
- Auth.js / NextAuth con Google y GitHub

## Configuracion

1. Copiar variables de entorno:

```bash
cp .env.example .env
```

2. Configurar `DATABASE_URL`, `AUTH_SECRET`, `AUTH_URL` y credenciales OAuth:

```text
AUTH_GOOGLE_ID
AUTH_GOOGLE_SECRET
AUTH_GITHUB_ID
AUTH_GITHUB_SECRET
```

3. Generar Prisma Client:

```bash
pnpm prisma:generate
```

4. Crear migraciones cuando la base este disponible:

```bash
pnpm prisma:migrate
```

5. Ejecutar desarrollo:

```bash
pnpm dev
```

## Decisiones iniciales

- PostgreSQL queda como base relacional objetivo.
- `User` y tablas Auth.js (`Account`, `Session`, `VerificationToken`) soportan login OAuth.
- Las cuentas patrimoniales del producto usan `FinancialAccount` para no chocar con `Account` de Auth.js.
- Todas las entidades personales tienen `userId` y relacion `onDelete: Cascade`.
- El email verificado se usa como dato de contacto; el aislamiento de datos depende de `userId`.
- Los importes usan `Decimal` para evitar errores de punto flotante.
- Las monedas no se suman entre si sin una fuente de tipo de cambio definida.
