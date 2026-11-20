import os

# 1. Update subproject CHECKPOINT.md
p_sub = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/CHECKPOINT.md"
if os.path.exists(p_sub):
    with open(p_sub, "r", encoding="utf-8") as f:
        c = f.read()

    new_log = "| 2026-11-20 09:40 | Antigravity / Windows | SAP HANA Consultant Review & Pembaruan Dokumen Word (.docx) Versi 2.0: Penambahan 10 screenshot baru (total 39 screenshot beranotasi visual) mencakup live SAP GUI (SICF, SU01, /IWFND/MAINT_SERVICE, SE16N EKPO, ME23N), BTP Cockpit Cloud Connectors tab, BAS Wizard Step 1 & 2, OData Metadata XML, dan Fiori Table Settings Gear | Selesai (Milestone Dokumentasi V2) | Upload file .docx revisi ke Google Drive Baginda |\n"

    target_header = "## Log Sesi (terbaru di atas, wajib — lihat [08](../../00_RULES/08_Checkpoint_Wajib.md))\n| Waktu | AI / device | Pekerjaan | Status | Next step |\n|---|---|---|---|---|\n"

    if "Milestone Dokumentasi V2" not in c and target_header in c:
        c = c.replace(target_header, target_header + new_log)
        c = c.replace("25 screenshots terverifikasi", "39 screenshots beranotasi terverifikasi")
        old_item = "- [x] Pembuatan dokumen resmi Microsoft Word (.docx) 2.6 MB beranotasi visual lengkap (kotak merah, nomor badge penunjuk aksi, tabel parameter, alur arsitektur, dan panduan troubleshooting) di folder outputs/ dan docs/."
        new_item = old_item + "\n- [x] Review SAP HANA Consultant & Rilis Dokumen Word Versi 2.0 (3.6 MB, 39 screenshot beranotasi visual lengkap, mencakup live SAP GUI SICF, SU01, /IWFND/MAINT_SERVICE, SE16N EKPO 10 hits, ME23N PO detail, OData $metadata XML, BTP Cockpit Cloud Connectors tab, BAS Wizard Step 1 & 2, dan Fiori Table Settings Gear)."
        c = c.replace(old_item, new_item)
        with open(p_sub, "w", encoding="utf-8") as f:
            f.write(c)
        print("Updated subproject CHECKPOINT.md successfully.")
    else:
        print("Subproject CHECKPOINT.md already updated or header not found.")

# 2. Update global CHECKPOINT.md
p_glob = "/data/Projects/SAP/ABAP/CHECKPOINT.md"
if os.path.exists(p_glob):
    with open(p_glob, "r", encoding="utf-8") as f:
        cg = f.read()

    new_glob_log = "| 2026-11-20 09:40 | Antigravity / Windows | BTP_HYBRID_INTEGRATION | Review SAP HANA Consultant & Pembaruan Dokumen Word (.docx) Versi 2.0 (3.6 MB, 39 screenshot beranotasi visual lengkap mencakup live SAP GUI SICF, SU01, Gateway, EKPO, ME23N, BTP Cockpit Cloud Connectors tab, BAS Wizard, dan Fiori Table Gear) | Selesai (Milestone Dokumentasi V2) | Upload file .docx revisi ke Google Drive Baginda |\n"
    glob_target = "## Log (terbaru di atas)\n\n| Waktu | AI / device | Sub-project | Pekerjaan | Status | Next step |\n|---|---|---|---|---|---|\n"

    if "Milestone Dokumentasi V2" not in cg and glob_target in cg:
        cg = cg.replace(glob_target, glob_target + new_glob_log)
        with open(p_glob, "w", encoding="utf-8") as f:
            f.write(cg)
        print("Updated global CHECKPOINT.md successfully.")
    else:
        print("Global CHECKPOINT.md already updated or header not found.")

# 3. Update README.md
p_readme = "/data/Projects/SAP/ABAP/subproject/BTP_HYBRID_INTEGRATION/README.md"
if os.path.exists(p_readme):
    with open(p_readme, "r", encoding="utf-8") as f:
        cr = f.read()
    cr = cr.replace("DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx (2.6 MB)", "DOKUMENTASI_STEP_BY_STEP_BTP_FIORI_HYBRID_INTEGRATION.docx (Versi 2.0 - 3.6 MB, 39 Screenshots Beranotasi)")
    with open(p_readme, "w", encoding="utf-8") as f:
        f.write(cr)
    print("README.md updated successfully.")
