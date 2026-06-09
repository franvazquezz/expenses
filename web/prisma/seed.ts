import { PrismaClient } from "../src/generated/prisma/client";
import { PrismaPg } from "@prisma/adapter-pg";

const adapter = new PrismaPg({ connectionString: process.env.DATABASE_URL });
const prisma = new PrismaClient({ adapter });

async function main() {
  const email = process.env.SEED_USER_EMAIL;

  if (!email) {
    console.info("SEED_USER_EMAIL no definido; no se crearon datos iniciales.");
    return;
  }

  const user = await prisma.user.upsert({
    where: { email },
    update: {},
    create: {
      email,
      emailVerified: new Date(),
      name: "Usuario inicial",
    },
  });

  await prisma.currency.createMany({
    data: [
      { userId: user.id, code: "ARS", name: "Peso Argentino", symbol: "$", isDefault: true },
      { userId: user.id, code: "USD", name: "Dolar Estadounidense", symbol: "US$" },
      { userId: user.id, code: "EUR", name: "Euro", symbol: "EUR" },
    ],
    skipDuplicates: true,
  });
}

main()
  .then(async () => {
    await prisma.$disconnect();
  })
  .catch(async (error) => {
    console.error(error);
    await prisma.$disconnect();
    process.exit(1);
  });
