import re

# Update subproject CHECKPOINT.md
sub_cp_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/CHECKPOINT.md"
with open(sub_cp_path, "r", encoding="utf-8") as f:
    sub_text = f.read()

sub_log_entry = "| 2026-11-20 09:15 | Antigravity / Windows | Pembuatan dokumen Word (.docx) komprehensif berisi 29 screenshot beranotasi visual (kotak merah & nomor penunjuk aksi) untuk pelaporan Google Drive | Selesai (Milestone Dokumentasi) | Upload file .docx ke Google Drive Baginda |\n"

# insert below table header of Log Sesi
sub_text = sub_text.replace(
    "| Waktu | AI / device | Pekerjaan | Status | Next step |\n|---|---|---|---|---|\n",
    "| Waktu | AI / device | Pekerjaan | Status | Next step |\n|---|---|---|---|---|\n" + sub_log_entry
)

# add item in Yang Sudah Selesai
checklist_addition = "- [x] Pembuatan dokumen resmi Microsoft Word (.docx) 2.6 MB beranotasi visual lengkap (kotak merah, nomor badge penunjuk aksi, tabel parameter, alur arsitektur, dan panduan troubleshooting) di folder outputs/ dan docs/.\n"
sub_text = sub_text.replace(
    "- [x] Penyusunan dokumentasi teknis `STEP_BY_STEP_IMPLEMENTATION_GUIDE.md` dan presentasi eksekutif `EXECUTIVE_SUMMARY_PRESENTATION.md`.\n",
    "- [x] Penyusunan dokumentasi teknis `STEP_BY_STEP_IMPLEMENTATION_GUIDE.md` dan presentasi eksekutif `EXECUTIVE_SUMMARY_PRESENTATION.md`.\n" + checklist_addition
)

with open(sub_cp_path, "w", encoding="utf-8") as f:
    f.write(sub_text)
print("Subproject CHECKPOINT.md updated.")

# Update root CHECKPOINT.md
root_cp_path = "/data/Projects/SAP/ABAP/CHECKPOINT.md"
with open(root_cp_path, "r", encoding="utf-8") as f:
    root_text = f.read()

root_log_entry = "| 2026-11-20 09:15 | Antigravity / Windows | BTP_HYBRID_INTEGRATION | Pembuatan dokumen Word (.docx) lengkap dengan 29 screenshot beranotasi visual (kotak merah & panah) untuk Google Drive pelaporan | Selesai (Milestone Dokumentasi) | Upload dokumen .docx ke Google Drive Baginda |\n"

root_text = root_text.replace(
    "| Waktu | AI / device | Sub-project | Pekerjaan | Status | Next step |\n|---|---|---|---|---|---|\n",
    "| Waktu | AI / device | Sub-project | Pekerjaan | Status | Next step |\n|---|---|---|---|---|---|\n" + root_log_entry
)

with open(root_cp_path, "w", encoding="utf-8") as f:
    f.write(root_text)
print("Root CHECKPOINT.md updated.")
