cp_path = '/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/CHECKPOINT.md'

with open(cp_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add log entry
target = "| 2026-11-19 14:00 | Antigravity / Windows | Update tanggal 10 PO ke 20261119 & verifikasi query filter 2026 sukses (10 items) | Selesai | Refresh preview Fiori & Pilih kolom via gear settings |\n"
new_entry = "| 2026-11-19 14:58 | Antigravity / Windows | Opsi A TUNTAS 100%: 10 Purchase Order S/4HANA live berhasil tampil di tabel Fiori Elements List Report BAS | Selesai (Milestone Tercapai) | Opsi C: Build & Deploy ke SAP BTP HTML5 Repository / Launchpad |\n" + target

content = content.replace(target, new_entry)

# Update Backup terakhir screenshot count
content = content.replace("| Backup terakhir | \\docs/attachments/\\ (8 screenshots terverifikasi) |", "| Backup terakhir | \\docs/attachments/\\ (25 screenshots terverifikasi) |")

# Add completed checklist items under ## 1. Yang Sudah Selesai
checklist_target = "- [x] Eksekusi Preview Fiori Run: server lokal aktif di BAS (`npx fiori run --open test/flp.html#app-preview`)."
new_checklist = """- [x] Eksekusi Preview Fiori Run: server lokal aktif di BAS (`npx fiori run --open test/flp.html#app-preview`).
- [x] Seeding 10 Data Purchase Order otentik di S/4HANA Client 130 (`EKKO`, `EKPO`, `EKET`, `LFM1`, `TCURR`, `TCURF`).
- [x] Konfigurasi entity set `C_PurchaseOrderItemMoniResults` & `considerAnalyticalParameters = true` di `manifest.json`.
- [x] **OPSI A TUNTAS 100%**: 10 Dokumen Purchase Order S/4HANA On-Premise mengalir live dan tampil sempurna di tabel Fiori Elements."""

content = content.replace(checklist_target, new_checklist)

with open(cp_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated subproject CHECKPOINT.md successfully.")
