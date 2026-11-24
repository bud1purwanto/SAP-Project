import { copyFileSync, readFileSync } from "node:fs";
import { basename, dirname, join } from "node:path";
import { analyzeAbapSource, inventoryDeclarations } from "./abap-source-analyzer.mjs";

const file = process.argv[2] ?? new URL("../../SAP-Agent-Discovery-Platform/data/abap-source-local/ZQMR_TRACEABILITY.abap", import.meta.url);
import { fileURLToPath } from "node:url";
const root = typeof file === "string" ? file : fileURLToPath(file);
const exportFolder = process.argv[3];
const seen = new Set();
const labels = {
  includes: "INCLUDE",
  tableReads: "Sumber data pada SELECT atau JOIN",
  callFunctions: "Function module",
  submitPrograms: "Program yang dirujuk SUBMIT",
  callTransactions: "Tujuan CALL TRANSACTION (periksa literal atau variabel)",
  databaseWrites: "Indikasi penulisan data (perlu konfirmasi)",
  transactionSignals: "Kontrol transaksi",
};

function report(path) {
  if (seen.has(path)) return;
  seen.add(path);
  let source;
  try {
    source = readFileSync(path, "utf8");
  } catch (error) {
    if (error.code !== "ENOENT" || path === root) throw error;
    console.log("\nINCLUDE belum tersedia:", basename(path));
    return;
  }
  if (exportFolder) copyFileSync(path, join(exportFolder, basename(path)));
  const lines = source.split(/\r?\n/).map((text, i) => ({ text, lineNumber: i + 1 }));
  const result = analyzeAbapSource(lines);
  console.log("\n" + basename(path));
  for (const {type,lineNumber,value} of inventoryDeclarations(lines)) {
    console.log('  Baris '+lineNumber+' | '+type+' | '+value);
  }
  for (const [key, label] of Object.entries(labels)) {
    for (const entry of result[key]) {
      console.log("  Baris " + entry.lineNumber + " | " + label + " | " + (entry.value ?? entry.operation));
    }
  }
  for (const { value } of result.includes) {
    if (/^[A-Z0-9_]+$/.test(value)) report(join(dirname(path), value + ".abap"));
    else console.log("Periksa INCLUDE secara manual:", value);
  }
}

console.log("Inventaris referensi statis. Nomor baris menunjuk contoh kemunculan. Panggilan dinamis, jalur eksekusi, dan efek bisnis perlu ditinjau.");
report(root);

