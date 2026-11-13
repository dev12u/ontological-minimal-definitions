import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";
import pg from "pg";

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const sqlPath = path.join(__dirname, "seed_hvac_samples.sql");
const url = process.env.OS20_PRODUCT_DATA_DATABASE_URL;
if (!url) {
  console.error("SEED_BLOCKED missing OS20_PRODUCT_DATA_DATABASE_URL");
  process.exit(2);
}

const sql = fs.readFileSync(sqlPath, "utf8");
const client = new pg.Client({ connectionString: url });
await client.connect();
try {
  await client.query(sql);
  const props = await client.query(
    "select count(*)::int as n from product_property where package_key=$1",
    ["@example/hvac-ontology-samples"],
  );
  const cats = await client.query(
    "select name from product_category where package_key=$1 order by sort_order",
    ["@example/hvac-ontology-samples"],
  );
  console.log("properties", props.rows[0].n);
  console.log("categories", cats.rows.map((r) => r.name).join(","));
} finally {
  await client.end();
}
