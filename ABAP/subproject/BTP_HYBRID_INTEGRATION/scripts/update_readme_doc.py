readme_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/README.md"
with open(readme_path, "r", encoding="utf-8") as f:
    text = f.read()

old_tree = """├── docs/
│   ├── STEP_BY_STEP_IMPLEMENTATION_GUIDE.md <-- Panduan teknis lengkap & detail per-langkah
│   ├── EXECUTIVE_SUMMARY_PRESENTATION.md   <-- Format presentasi eksekutif & alur demo
│   └── attachments/                        <-- Arsip screenshot & bukti verifikasi integrasi"""

new_tree = """├── docs/
│   ├── DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx <-- Dokumen Word Resmi Siap Share
│   ├── STEP_BY_STEP_IMPLEMENTATION_GUIDE.md <-- Panduan teknis lengkap & detail per-langkah
│   ├── EXECUTIVE_SUMMARY_PRESENTATION.md   <-- Format presentasi eksekutif & alur demo
│   └── attachments/                        <-- Arsip 29 screenshot bukti verifikasi integrasi
│       └── annotated/                      <-- 29 Screenshot Beranotasi Visual (Kotak Merah & Badge Aksi)"""

if old_tree in text:
    text = text.replace(old_tree, new_tree)

old_out = "└── outputs/                                <-- File ekspor / log verifikasi"
new_out = "└── outputs/                                <-- DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx (2.6 MB)"
if old_out in text:
    text = text.replace(old_out, new_out)

with open(readme_path, "w", encoding="utf-8") as f:
    f.write(text)

print("subproject README.md updated successfully.")
