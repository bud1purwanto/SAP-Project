# Checkpoint Daily Briefing SAP ABAP — 2026-09-30

- **Jendela Pemindaian**: 24 jam terakhir (29–30 Sep 2026).
- **Sumber**: Exchange live + SQLite archive via MCP RAG (`search_emails`, `read_email`).
- **Task ABAP & SAP Aktif (5 Item)**:
  1. **[NEW - DISCOVERY/ENHANCEMENT] Print Out ZSD003 Nota Retur Export (Kolom Total US$ dan Rp)** — Email masuk dari Aldi Dwi Kusuma (IT) meneruskan request Bu Lussy Lestyo (FINANCE - AR) ke `SAP-ABAP@trst.co.id` (30 Sep 2026 09:21 WIB). Request: Hapus kolom "Total US$" dan kolom "Rp." pada print out Nota Retur Export T-Code `ZSD003`. Lakukan discovery di DEV NC dan cek histori revisi program/Smart Form.
  2. **[OPP/MES ISSUE] Batal Start/Stop Error pada Production Order 100007209911** — Email dari Yusuf Hermawan (CNV-FNS-KR) ke Siti Aisyah (IT PP) & IT Helpdesk (30 Sep 2026 10:34 WIB). Order sudah di-revoke close dan status TECO, namun pembatalan start/stop masih error di lantai produksi. Perlu verifikasi status internal order (`JEST`), goods movement terkait, atau pembatalan konfirmasi (`CO13`/`CORS`).
  3. **[INTERFACE/UX ISSUE] No JR J EWE 096 128 Tidak Muncul di UX (MES)** — Email dari M Akhsan Nafi Bastomi (CNV-METZ #6) direspon uxadmin2 (IT) (30 Sep 2026 10:18 WIB). JR diturunkan manual ke UX. Terkait keandalan sinkronisasi staging `ZTPPR_NEW_LIST_JR` akibat fluktuasi koneksi native SQL (`DBCON` ERP).
  4. **[CARRY-OVER - BASIS ACTION] Import Transport Request ke Production PRT (`TRDK924831`, `TRDK924835`, `TRDK924805`) & T-Code `ZMMR_OLAP_RESB`** — Status `R` (Released) di `TRD`, menunggu eksekusi import Basis (Pak Sinyo) ke `PRT`.
  5. **[CARRY-OVER - FUNCTIONAL UAT] Follow-Up UAT ZSD028 (`TRDK924837`), ZSD012N (`TRDK924819`), dan Coretax V2 Faktur Pajak** — Menunggu hasil UAT tim functional SD/Finance (`Aldi`, `Fany`, `Iqri`, `Stefanus`).

- **Task Selesai / Resolved (29–30 Sep 2026)**:
  - **Unrest Batch Return Pelangi UV 25-Sep-26** — 6 batch (`0033927386`, `0033927708`, `0033927709`, `0033927711`, `0033927724`, `0033927748`) telah di-unrest oleh Aldi Dwi Kusuma.
  - **Create Master Data Sina Printing Inc - Canada** — Customer `1141100781` sudah termaintain di SAP oleh Aldi Dwi Kusuma.
  - **Penyelesaian Transaksi Gagal Mat to Mat (FNS-Thermal)** — Batch `33926688` (Material `SRIDFI`) panjang telah disesuaikan oleh Achmad Wafi Makarim.
  - **Update Production Version TSBS-23** — Template Master Recipe & Group Counter telah diupdate di SAP oleh Siti Aisyah.
  - **Problem SJ ke Krian (Open Deletion Flag & Costing)** — Selesai dilakukan oleh Indah Rahayuningtias & Angga Sanggarwangi.
