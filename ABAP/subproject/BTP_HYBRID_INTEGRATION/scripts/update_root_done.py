root_cp_path = '/data/Projects/SAP/ABAP/CHECKPOINT.md'

with open(root_cp_path, 'r', encoding='utf-8') as f:
    content = f.read()

target = "| 2026-11-19 14:00 | Antigravity / Windows | BTP_HYBRID_INTEGRATION | Update tanggal 10 PO ke 20261119 & verifikasi query filter 2026 sukses (10 items) | Selesai | Refresh preview Fiori & Pilih kolom via gear settings |\n"
new_entry = "| 2026-11-19 14:58 | Antigravity / Windows | BTP_HYBRID_INTEGRATION | Opsi A TUNTAS 100%: 10 Purchase Order S/4HANA live berhasil tampil di tabel Fiori Elements List Report BAS | Selesai (Milestone Tercapai) | Opsi C: Build & Deploy ke SAP BTP HTML5 Repository / Launchpad |\n" + target

content = content.replace(target, new_entry)

with open(root_cp_path, 'w', encoding='utf-8') as f:
    f.write(content)

print("Updated root CHECKPOINT.md successfully.")
