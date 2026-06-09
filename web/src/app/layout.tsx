import type { Metadata } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "Expenses Web",
  description: "Seguimiento personal de gastos, ingresos y patrimonio.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="es"
      className="h-full antialiased"
    >
      <body className="min-h-full bg-[#f7f7f4] text-[#20201d]">{children}</body>
    </html>
  );
}
