with open('/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/CHECKPOINT.md', 'r') as f:
    content = f.read()

target = "| 2026-11-19 10:38 | Antigravity / Windows | Verifikasi End-to-End Fiori App zpoitems SUKSES (HTTP 200 OK, tabel ter-load sempurna) | Selesai (Milestone Tercapai) | Dokumentasi & Opsi Input Data PO di S/4HANA |\n"
replacement = "| 2026-11-19 14:00 | Antigravity / Windows | Update tanggal 10 PO ke 20261119 & verifikasi query filter 2026 sukses (10 items) | Selesai | Refresh preview Fiori & Pilih kolom via gear settings |\n" + target

if target in content:
    content = content.replace(target, replacement)
    with open('/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/CHECKPOINT.md', 'w') as f:
        f.write(content)
    print("Checkpoint updated successfully.")
else:
    print("Target string not found in Checkpoint.")
