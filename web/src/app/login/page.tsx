import Link from "next/link";
import { redirect } from "next/navigation";
import { auth, signIn } from "@/auth";

const googleEnabled = Boolean(process.env.AUTH_GOOGLE_ID && process.env.AUTH_GOOGLE_SECRET);
const githubEnabled = Boolean(process.env.AUTH_GITHUB_ID && process.env.AUTH_GITHUB_SECRET);

export default async function LoginPage() {
  const session = await auth();

  if (session?.user) {
    redirect("/");
  }

  return (
    <main className="grid min-h-screen place-items-center px-6 py-10">
      <section className="w-full max-w-md rounded-lg border border-[#dfddd4] bg-[#fbfbf8] p-6 shadow-sm">
        <Link href="/" className="text-sm font-medium text-[#66645d] hover:text-[#20201d]">
          Expenses Web
        </Link>
        <h1 className="mt-6 text-2xl font-semibold tracking-normal">
          Iniciar sesion
        </h1>
        <p className="mt-2 text-sm leading-6 text-[#66645d]">
          Usa Google o GitHub para asociar tus datos a un usuario propio de la app.
        </p>

        <div className="mt-8 space-y-3">
          <form
            action={async () => {
              "use server";
              await signIn("google", { redirectTo: "/" });
            }}
          >
            <button
              disabled={!googleEnabled}
              className="flex h-11 w-full items-center justify-center rounded-md border border-[#cbc7ba] bg-white px-4 text-sm font-medium text-[#20201d] hover:bg-[#eeeeea] disabled:cursor-not-allowed disabled:opacity-50"
            >
              Continuar con Google
            </button>
          </form>

          <form
            action={async () => {
              "use server";
              await signIn("github", { redirectTo: "/" });
            }}
          >
            <button
              disabled={!githubEnabled}
              className="flex h-11 w-full items-center justify-center rounded-md bg-[#20201d] px-4 text-sm font-medium text-white hover:bg-[#3a3934] disabled:cursor-not-allowed disabled:opacity-50"
            >
              Continuar con GitHub
            </button>
          </form>
        </div>

        <p className="mt-6 text-xs leading-5 text-[#87847b]">
          Configura `AUTH_GOOGLE_ID`, `AUTH_GOOGLE_SECRET`, `AUTH_GITHUB_ID` y
          `AUTH_GITHUB_SECRET` para habilitar los proveedores.
        </p>
      </section>
    </main>
  );
}
