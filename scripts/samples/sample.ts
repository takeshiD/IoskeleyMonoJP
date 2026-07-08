// Ioskeley Mono JP — TypeScript のサンプル
interface User {
  id: number;
  name: string;
  roles: readonly string[];
}

const users: User[] = [
  { id: 1, name: "田中太郎", roles: ["admin", "user"] },
  { id: 2, name: "佐藤花子", roles: ["user"] },
];

// リガチャ確認: => === !== >= <= ?? ?. |>
const admins = users
  .filter((u) => u.roles.includes("admin"))
  .map((u) => u.name);

async function fetchUser(id: number): Promise<User | undefined> {
  const found = users.find((u) => u.id === id);
  return found ?? undefined;
}

void fetchUser(1);
console.log(`管理者: ${admins.join("、")}`);
