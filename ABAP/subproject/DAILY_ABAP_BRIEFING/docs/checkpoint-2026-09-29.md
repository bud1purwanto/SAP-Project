# Checkpoint Daily Briefing SAP ABAP — 2026-09-29

- **Jendela Pemindaian**: 24 jam terakhir (`28–29 Sep 2026`).
- **Sumber**: Exchange live + SQLite archive (`mcp__RAG__search_emails`, `mcp__RAG__read_email`) & Live SAP (`PRT`, `TRD`, `TRS` via `mcp__MCP_SAP__*`).
- **Task ABAP & SAP Aktif (5 Item)**:
  1. **Request Transport ke Production (`TRDK924831`, `TRDK924835`, `TRDK924805`) & Otorisasi T-Code Baru (`ZMMR_OLAP_RESB`)** — Email Baginda ke Pak Sinyo (`28 Sep 2026 17:30 WIB`). Ketiga TR berstatus `R` (Released) di `TRD` namun belum di-import ke `PRT`. `ZMMR_OLAP_RESB` belum memiliki T-Code di `TSTC` (`TRD` maupun `PRT`).
  2. **Follow-Up UAT & Transport `ZSD028` (`ZSDR_INVOICE_SO`) serta `ZSD012N` (`ZBAP_READY_REPORT`)** — Email Baginda ke Tim Functional (`Aldi`, `Fany`, `Iqri`, `Stefanus`). `TRDK924837` (`ZSDR_INVOICE_SO`) dan `TRDK924819` (`ZBAP_READY_REPORT`) masih berstatus `D` (Modifiable) di `TRD`.
  3. **Follow-Up UAT Faktur Pajak Coretax V2 (`ZSD_FAKTUR_PAJAK_CORETAX_V2`)** — Email Baginda ke `Iqri` & `Aldi` (`28 Sep 2026 13:51 WIB`). Program belum terdaftar di `TRDIR` (`TRD`/`TRS`/`PRT`), masih dalam tahap review draft/lokal.
  4. **Outage Koneksi Sekunder SQL `ERP` (`DBIF_DSQL2_SQL_ERROR` di `SAPTRPKR_TRP_00`)** — Berlanjut hingga `29 Sep 2026 06:21 WIB` (total 19 short dump pada `ZTPPR_NEW_LIST_JR`, `ZTQM_INSP_LOT`, `ZTPPR_PRO_RAW_RECYCLE`, `ZTPPR_SLITTING_REKAP_PC_V2`, `ZTPPI_CHANGE_BOM_PO`, `ZTMMR_STOCK_RM`, `ZTBAP_STOCK_BY_CHAR1`, `ZTDL_ZCORER`).
  5. **Short Dump Program Z Lainnya di `PRT` & `TRD` (`28–29 Sep 2026`)** — `ZPPR_SLITTING_REKAP_PC_V2` (`STOP_WITHIN_CALLED_DYNPRO` baris 1296), `ZBAP_STOCK_BY_CHAR1` (`TSV_TNEW_PAGE_ALLOC_FAILED` baris 273), serta `ZFIR_FAGLFLEXT` & `ZBAP_READY_REPORT_STFN` (`DBIF_DSQL2_CONNECTERR` di `TRD`).
- **Closed / Selesai (`28 Sep 2026`)**:
  - **RE: KEDATANGAN ROLL DARI CKI SLITT ROLL DLF50-45 (`SRWCVO` & `SRWCVX` Plant `2000`)** — Inspection Plan (`DLF5045O` & `DLF5045X`) sudah dibuat di `MAPL`, UD selesai, dan 49 roll telah dikonversi ke `SRWCVX` (Batch `0033923649` s/d `0033923753`, `CLABS > 0`).
  - **Cancel GRN / Outbound Delivery `8600008360` & `8600008361`** — Sudah di-unpick oleh IT (`Stefanus`) dan dibatalkan oleh `ZAK (FGS Admin Krian)`.
  - **Revisi PO Subcont `4506001362` (`5PCK7-15`)** — Sudah di-unrelease & direvisi oleh Purchasing (`Melisa`).
