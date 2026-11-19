file_path = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/CHECKPOINT.md"
with open(file_path, "r", encoding="utf-8") as f:
    content = f.read()

new_row = "| 2026-11-19 | Dokumen Arsitektur Alur Data & Anotasi Permanen PO | END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md | Alur end-to-end S/4HANA ke Fiori terdokumentasi lengkap |\n"
content = content.replace("| 2026-11-19 | Master Data & PO Seeding (Opsi A) Selesai | EKKO, EKPO, EKET, LFM1, TCURR | OData returns 10 PO records HTTP 200 OK |\n", "| 2026-11-19 | Master Data & PO Seeding (Opsi A) Selesai | EKKO, EKPO, EKET, LFM1, TCURR | OData returns 10 PO records HTTP 200 OK |\n" + new_row)

with open(file_path, "w", encoding="utf-8") as f:
    f.write(content)

# Root CHECKPOINT
root_path = "/data/Projects/SAP/ABAP/CHECKPOINT.md"
with open(root_path, "r", encoding="utf-8") as f:
    rcontent = f.read()

r_row = "| 2026-11-19 | BTP_HYBRID_INTEGRATION | Dokumen Arsitektur End-to-End & Anotasi PO | END_TO_END_TECHNICAL_ARCHITECTURE_FLOW.md |\n"
if "Dokumen Arsitektur End-to-End" not in rcontent:
    rcontent = rcontent.replace("| 2026-11-19 | BTP_HYBRID_INTEGRATION | Master Data & Seeding 10 PO (Opsi A) Selesai | 10 PO Live di Fiori Elements |\n", "| 2026-11-19 | BTP_HYBRID_INTEGRATION | Master Data & Seeding 10 PO (Opsi A) Selesai | 10 PO Live di Fiori Elements |\n" + r_row)

with open(root_path, "w", encoding="utf-8") as f:
    f.write(rcontent)

print("Updated checkpoints successfully.")
