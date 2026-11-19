path = "/data/Projects/SAP/ABAP/CHECKPOINT.md"
with open(path, "r", encoding="utf-8") as f:
    content = f.read()

old_terakhir = """| Waktu | 2026-11-19 11:15 |
| AI / device | Antigravity / Linux GUI |
| Sub-project | S4HANA_DATA_MIGRATION |
| Pekerjaan | Eksekusi EC01 di S/4HANA ADB 130: Copy Company Code 0001 -> 9999 sukses penuh, tercatat di TR ADBK900049, verifikasi live di tabel T001 (BUKRS 9999 aktif) |
| Status | Selesai (Fase 1: CoCode 9999 Terbuat) |
| Next step | Maintenance detail CoCode 9999 di OX02 (IDR, Sidoarjo) & Copy Plant 1000/2000 via EC02 |"""

new_terakhir = """| Waktu | 2026-11-19 12:12 |
| AI / device | Antigravity / Linux GUI |
| Sub-project | S4HANA_DATA_MIGRATION |
| Pekerjaan | Fase 1 Enterprise Structure Tuntas: CoCode 9999 (OX02), Plants 1000 & 2000 (EC02/OX10), Assignment OX18 (9999->1000/2000) tersimpan di TR ADBK900049. Ekstraksi Pilot Production Model (JRAAAI/JROPP01/MKAL) dari DEV AIX. |
| Status | Selesai (Fase 1 100% OK) |
| Next step | Storage Location OX09 & Eksekusi Master Data (MM01, CR01, CS01, C223) di S/4HANA |"""

new_log_row = "| 2026-11-19 12:12 | Antigravity / Linux GUI | S4HANA_DATA_MIGRATION | Fase 1 Enterprise Structure Tuntas (CoCode 9999, Plants 1000/2000, OX18, OX10) di TR ADBK900049 & Ekstraksi Model Produksi DEV AIX | Selesai | Storage Location OX09 & Eksekusi Master Data Produksi (MM01, CR01, CS01, C223) |\n"

if old_terakhir in content:
    content = content.replace(old_terakhir, new_terakhir)
log_header = "| Waktu | AI / device | Sub-project | Pekerjaan | Status | Next step |\n|---|---|---|---|---|---|\n"
content = content.replace(log_header, log_header + new_log_row)

with open(path, "w", encoding="utf-8") as f:
    f.write(content)
print("Root CHECKPOINT.md updated successfully!")
