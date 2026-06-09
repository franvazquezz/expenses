import Link from "next/link";
import { auth, signOut } from "@/auth";

const metrics = [
  { label: "Gastos del mes", value: "$ 1.245.000", currency: "ARS" },
  { label: "Ingresos del mes", value: "$ 2.100.000", currency: "ARS" },
  { label: "Patrimonio", value: "USD 8.420", currency: "USD" },
];

const migrationItems = [
  "Next.js App Router inicial",
  "Prisma 7 con PostgreSQL",
  "Auth.js con Google y GitHub",
  "Modelo multiusuario por userId",
  "Schema equivalente a SwiftData",
];

export default async function Home() {
  const session = await auth();

  return (
    <main className="min-h-screen">
      <header className="border-b border-[#dfddd4] bg-[#fbfbf8]">
        <div className="mx-auto flex max-w-7xl items-center justify-between px-6 py-4">
          <div>
            <p className="text-sm font-medium text-[#66645d]">Expenses Web</p>
            <h1 className="text-xl font-semibold tracking-normal text-[#20201d]">
              Migracion Next + Prisma
            </h1>
          </div>
          {session?.user ? (
            <form
              action={async () => {
                "use server";
                await signOut();
              }}
            >
              <button className="h-10 rounded-md border border-[#cbc7ba] px-4 text-sm font-medium text-[#20201d] hover:bg-[#eeeeea]">
                Cerrar sesion
              </button>
            </form>
          ) : (
            <Link
              href="/login"
              className="inline-flex h-10 items-center rounded-md bg-[#20201d] px-4 text-sm font-medium text-white hover:bg-[#3a3934]"
            >
              Iniciar sesion
            </Link>
          )}
        </div>
      </header>

      <section className="mx-auto grid max-w-7xl gap-8 px-6 py-10 lg:grid-cols-[1.2fr_0.8fr]">
        <div className="space-y-8">
          <div className="rounded-lg border border-[#dfddd4] bg-[#fbfbf8] p-6 shadow-sm">
            <div className="flex flex-col gap-4 sm:flex-row sm:items-start sm:justify-between">
              <div>
                <h2 className="text-2xl font-semibold tracking-normal">
                  Base web lista para construir el MVP
                </h2>
                <p className="mt-2 max-w-2xl text-sm leading-6 text-[#66645d]">
                  Esta primera etapa crea la infraestructura de Fase 14:
                  Next.js, Prisma, Auth.js y modelo relacional multiusuario.
                </p>
              </div>
              <div className="rounded-md bg-[#e8f0df] px-3 py-2 text-sm font-medium text-[#385027]">
                Fase 14
              </div>
            </div>

            <div className="mt-8 grid gap-4 md:grid-cols-3">
              {metrics.map((metric) => (
                <div
                  key={metric.label}
                  className="rounded-md border border-[#dfddd4] bg-white p-4"
                >
                  <p className="text-sm text-[#66645d]">{metric.label}</p>
                  <p className="mt-3 text-2xl font-semibold tracking-normal">
                    {metric.value}
                  </p>
                  <p className="mt-1 text-xs font-medium text-[#87847b]">
                    {metric.currency}
                  </p>
                </div>
              ))}
            </div>
          </div>

          <div className="rounded-lg border border-[#dfddd4] bg-white p-6">
            <h2 className="text-lg font-semibold">Alcance inicial</h2>
            <div className="mt-4 grid gap-3 md:grid-cols-2">
              {migrationItems.map((item) => (
                <div
                  key={item}
                  className="flex items-center gap-3 rounded-md border border-[#e7e4dc] px-3 py-3 text-sm"
                >
                  <span className="h-2 w-2 rounded-full bg-[#4d7c36]" />
                  {item}
                </div>
              ))}
            </div>
          </div>
        </div>

        <aside className="rounded-lg border border-[#dfddd4] bg-[#20201d] p-6 text-white">
          <h2 className="text-lg font-semibold">Sesion</h2>
          {session?.user ? (
            <div className="mt-5 space-y-4">
              <div>
                <p className="text-sm text-[#c9c5b8]">Usuario</p>
                <p className="mt-1 font-medium">{session.user.name ?? "Sin nombre"}</p>
              </div>
              <div>
                <p className="text-sm text-[#c9c5b8]">Email</p>
                <p className="mt-1 font-medium">{session.user.email ?? "Sin email"}</p>
              </div>
              <div>
                <p className="text-sm text-[#c9c5b8]">ID</p>
                <p className="mt-1 break-all font-mono text-xs">{session.user.id}</p>
              </div>
            </div>
          ) : (
            <div className="mt-5">
              <p className="text-sm leading-6 text-[#d8d3c7]">
                Inicia sesion para validar el flujo OAuth. Los datos personales
                del futuro MVP se aislan por usuario en Prisma.
              </p>
              <Link
                href="/login"
                className="mt-5 inline-flex h-10 items-center rounded-md bg-white px-4 text-sm font-medium text-[#20201d] hover:bg-[#eeeeea]"
              >
                Ir al login
              </Link>
            </div>
          )}
        </aside>
      </section>
    </main>
  );
}
