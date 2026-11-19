import datetime

path = 'subproject/BTP_HYBRID_INTEGRATION/CHECKPOINT.md'

with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Add to completed list
completed_entry = """- [x] Provisioning Master Data & Seeding 10 Data Purchase Order di S/4HANA Client 130 (Opsi A Selesai).
  - Business Partner `0000000102` / Vendor `0000100000` (PT TECH SOLUTIONS INDONESIA) dibuat via BAPI CVI (`FLVN01`).
  - Purchasing Org `0001` dimaintain di `LFM1`.
  - Rate tukar `EUR` dimaintain di `TCURR` dan `TCURF`.
  - 10 Data Purchase Order `4500000001` - `4500000010` dibuat di `EKKO`, `EKPO`, `EKET`.
  - Root cause filter `IMMPURCHORDRITEM` terpecahkan (`EKPO-BSTYP = 'F'` dan `EKPO-MFRNR = '0000100000'`).
  - OData service `MM_PUR_POITEMS_MONI_SRV` memverifikasi 10 data PO mengalir sempurna dengan status HTTP 200 OK."""

content = content.replace("- [x] Penyusunan dokumentasi teknis \\STEP_BY_STEP_IMPLEMENTATION_GUIDE.md\\ dan presentasi eksekutif \\EXECUTIVE_SUMMARY_PRESENTATION.md\\.",
                          "- [x] Penyusunan dokumentasi teknis `STEP_BY_STEP_IMPLEMENTATION_GUIDE.md` dan presentasi eksekutif `EXECUTIVE_SUMMARY_PRESENTATION.md`.\n" + completed_entry)

# Update log table
new_log = "| 2026-11-19 | Master Data & PO Seeding (Opsi A) Selesai | EKKO, EKPO, EKET, LFM1, TCURR | OData returns 10 PO records HTTP 200 OK |\n"
content = content.replace("| 2026-11-18 | Initial Subproject Creation | BTP_HYBRID_INTEGRATION | Check Connection HTTP 200 OK |\n",
                          "| 2026-11-18 | Initial Subproject Creation | BTP_HYBRID_INTEGRATION | Check Connection HTTP 200 OK |\n" + new_log)

# Update next step
content = content.replace("- [ ] Konfigurasi Principal Propagation / SSO (X.509 Client Certificate).",
                          "- [x] Seeding 10 Dokumen Purchase Order di S/4HANA On-Premise Client 130 (Opsi A Selesai).\n- [ ] Deploy Fiori Application ke SAP BTP Cloud Foundry Launchpad / HTML5 Repository (Opsi C).\n- [ ] Konfigurasi Principal Propagation / SSO (X.509 Client Certificate).")

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print("subproject CHECKPOINT.md updated!")
