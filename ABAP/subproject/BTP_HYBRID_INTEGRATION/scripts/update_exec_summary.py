import re

file_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/docs/EXECUTIVE_SUMMARY_PRESENTATION.md"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

# 1. Add link in Slide 2 / Slide 3
arch_link = """\n> [!NOTE]
> **Dokumentasi Detail Alur Data Teknis:**  
> Untuk telaah komprehensif alur data end-to-end dari tabel `EKKO`/`EKPO` hingga browser UI5 beserta diagram detail, silakan buka: [END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md](./END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md).\n"""

if "END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md" not in content:
    content = content.replace("## Slide 3: Milestone Capaian Utama", arch_link + "\n## Slide 3: Milestone Capaian Utama")

# 2. Update attachments
new_attachments = """- `25_define_column_properties_1_column.png`: Temuan kunci personalisasi tabel (1/1 kolom) yang mengonfirmasi perlunya entity set `Results`
- `26_fiori_table_10_records_success.jpg`: Tampilan sukses 10 dokumen PO S/4HANA live di tabel Fiori Elements
- `27_page_editor_custom_column_dialog.png`: Investigasi pop-up "Add Custom Column" di Page Editor OData V2
- `28_pagemap_instruction_query.jpg`: Penyelarasan alur Page Map vs editing langsung `annotation.xml`
- `29_bas_default_annotation_xml.png`: Inspeksi file default `annotation.xml` bawaan SAP BAS"""

content = content.replace("- `25_define_column_properties_1_column.png`: Temuan kunci personalisasi tabel (1/1 kolom) yang mengonfirmasi perlunya entity set `Results`", new_attachments)
content = content.replace("(Screenshots Lengkap 25 File)", "(Screenshots Lengkap 29 File)")

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

print("Updated EXECUTIVE_SUMMARY_PRESENTATION.md successfully.")
