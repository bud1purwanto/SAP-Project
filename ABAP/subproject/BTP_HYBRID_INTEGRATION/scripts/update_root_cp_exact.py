with open('/data/Projects/SAP/ABAP/CHECKPOINT.md', 'r') as f:
    lines = f.readlines()

new_lines = []
for line in lines:
    new_lines.append(line)
    if line.strip() == "| 2026-11-19 13:50 | Antigravity / Linux GUI | S4HANA_DATA_MIGRATION | Fase 2 Storage Locations OX09 Selesai (Plant 1000: 1011 Feed OPP WR, 1813 WR FGS-Non WM; Plant 2000: 1813 WR FGS-Non WM, 2011 Feed XLM1, 2021 Feed OPP4) di TR ADBK900049 | Selesai | Fase 3: Pembuatan Master Data Material (MM01) & Master Data Produksi |":
        new_lines.insert(-1, "| 2026-11-19 14:00 | Antigravity / Windows | BTP_HYBRID_INTEGRATION | Update tanggal 10 PO ke 20261119 & verifikasi query filter 2026 sukses (10 items) | Selesai | Refresh preview Fiori & Pilih kolom via gear settings |\n")

with open('/data/Projects/SAP/ABAP/CHECKPOINT.md', 'w') as f:
    f.writelines(new_lines)
print("Root checkpoint updated.")
