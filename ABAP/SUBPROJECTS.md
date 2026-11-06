# SUBPROJECTS — Peta Sub-Project

Baca file ini **pertama kali** setiap mulai kerja di project "SAP ABAP Consultant".
Fungsinya: menentukan sub-project mana yang relevan dengan permintaan user, lalu bekerja
hanya di dalam folder sub-project tersebut.

Semua sub-project berada di dalam folder induk `subproject/`.

```
SAP ABAP Consultant/
├── AGENTS.md               <- entry point semua AI (konteks + aturan emas)
├── SUBPROJECTS.md          <- file ini (peta routing)
├── CHECKPOINT.md           <- terakhir mengerjakan apa (baca pertama)
├── 00_RULES/               <- aturan detail per topik
├── 01_TEMPLATE/            <- template README, Design Brief, FS, analisa, RCA, checkpoint
├── 02_AGENTS/              <- agent per peran (brainstormer, developer, syntax, test, QA, reviewer)
├── subproject/
│   ├── ADT_VSCODE/           ├── PO_AUTO_RELEASE/
│   ├── AUTO_TECO/            ├── PO_EMAIL/
│   ├── BARRIER/              ├── PP_SLITTING_REPORT/
│   ├── COA/                  ├── PROCESS_ORDER_RFC/
│   ├── DAILY_ABAP_BRIEFING/  ├── SAP_GUI_AUTOMATION/
│   ├── GI_JR_CLOSING/        ├── ZMM061/
│   ├── MCP_GATEWAY_TEST/     ├── ZMMI_WMS/  (+ asal ZBMBC)
│   ├── MES_CONTROL_TOWER/    ├── ZPP005N/
│   ├── PLANNING_SLITROLL/    └── ZPP090/
```
## Struktur Umum Tiap Sub-Project

Setiap sub-project memakai subfolder standar:

- `README.md` — ringkasan sub-project (atribut, tujuan, isi folder, dokumen kunci). Template: `01_TEMPLATE/Template_README_Subproject.md`

- `src/` — **1 file per objek** (salinan kerja source ABAP (`.abap`); **bukan sumber kebenaran**, pull dari `sandbox-new` dulu sebelum push ([03](00_RULES/03_Push_Program_dan_SmartForm.md#wajib-pull-source-terbaru-sebelum-push))). Snapshot/versi/kandidat → `outputs/`
- `scripts/` — script otomasi (`.mjs`, `.js`, `.py`, `.ps1`) untuk push/fetch/patch/audit via MCP SAP; script sekali pakai (check/inspect/sim) → `scripts/_adhoc/`
- `docs/` — dokumen FS/TS, spesifikasi, diagram, deck, xlsx timeframe/test-scenario, gambar
- `tests/` — script test (`.ps1`, `test_*`)
- `outputs/` — hasil dump/backup JSON & TXT (snapshot source sebelum perubahan, backup tabel ZMAP)

## Peta Sub-Project

Prinsip: **1 TCODE / program = 1 sub-project** (program + include + Smart Form + tabel Z miliknya tetap 1 project). Urutan routing:
1. Nama program / TCODE / include **persis** (mis. `ZPPR_GI_JR_CLOSING`, `ZQM004`) menang atas kata kunci umum.
2. Lalu kata kunci di kolom terakhir.
3. Kata kunci bertanda *(ambigu)* atau cocok >1 baris → tanya Baginda.

| Sub-Project (folder) | Program utama | Cakupan | Kata kunci untuk routing |
|---|---|---|---|
| `subproject/PO_AUTO_RELEASE/` | `ZPO_AUTO_RELEASE`, `ZMMI_PO_RELEASE_PHASE2` | Auto-release PO di bawah ambang (< USD 500), pilot org TPOL/9999, exception flagging, diagram proses As-Is/To-Be | po auto release, autorelease, zpo_auto_release, zmmi_po_release, release strategy, FRGRL/FRGKE, timeframe |
| `subproject/PO_EMAIL/` | `ZMMI_PO_EMAIL` | Routing approver berjenjang (Lisa/Melisa/Fenny/GM), notifikasi email PO, tabel mapping `ZMAP_TYPE` (EMAIL_TEXT, EXC_RULE, GM, PRICE_AXES, DEFAULT), dynamic exception rules | po email, zmmi_po_email, zmap_email, zmap_type EMAIL_TEXT/EXC_RULE/GM/PRICE_AXES *(zmap_type umum = ambigu)*, approver, gm, price_axes, exc_rule, SMTP/SOST |
| `subproject/AUTO_TECO/` | `ZPPI_COHVPI` | Auto TECO Production Order (beda project dengan MES Control Tower), FS Auto TECO, validasi status order, email notif TECO | cohvpi, zppi_cohvpi, zppr_zpp001, teco, auto teco, zpp001, teco production order |
| `subproject/COA/` | `ZQMI_COA` / `ZQMR_COA` (include `ZQMI_CERTIFICATE_F01`) | Certificate of Analysis — mode print (ZQM002) & ALV (ZQM003) via cabang `SY-TCODE`, perbaikan decimal MIC dari master QPMK, bootstrap patcher `ZTMP*` | coa, zqmi_coa, zqmr_coa, zqm002, zqm003, certificate, MIC, QPMK, decimal |
| `subproject/MES_CONTROL_TOWER/` | `ZPP_MD_DL` (Include `LZPP_MDU01`) | MES Control Tower download object (MAST, MKAL, STPO/STKO) dengan handling default date 19000101 | mes control tower, control tower, mes download, zpp_md_dl, lzpp_mdu01, mast, mkal, stpo, stko, stas |
| `subproject/BARRIER/` | `ZQMI_PENDING_BARRIER` | Barrier Inspection List & Upload (ZQM004), Result Recording & Usage Decision untuk karakteristik barrier (WVTR/MVTR, OTR/O2TR) | barrier, pending barrier, zqmi_pending_barrier, zqm004, wvtr, otr, mvtr, o2tr, barrier judgement |
| `subproject/GI_JR_CLOSING/` | `ZPPR_GI_JR_CLOSING` | Observasi closing PP: exception GI Jumbo Roll vs GR (tanpa 261, selisih toleransi, GI < GR), ALV report & email notifikasi per line | gi jr closing, zppr_gi_jr_closing, gi jumbo roll, gi jr, closing pp, gi vs gr, zzprodline, zznomorroll |
| `subproject/PP_SLITTING_REPORT/` | `ZPPR_SLITTING_REKAP_DAILY`, `ZPPR_SLITTING_REKAP_PC_V2` | Rekap Slitting Harian, perbandingan ZPP016/ZPP016N, detail eksekusi dan traceability batch/final batch, export OLAP | zpp016, zpp016n, zpp106, rekap slitting harian, slitting report, final batch, zbatchistory |
| `subproject/PLANNING_SLITROLL/` | `ZPPR_PLANNING_SLITROLL` | Report ALV hasil planning Slit Roll, relasi vendor batch ke original order dan original ke combine order, mapping order type SR di `ZMAP_TYPE` | planning slit roll, hasil planning sr, zppr_planning_slitroll, original order, combine order, vendor batch |
| `subproject/DAILY_ABAP_BRIEFING/` | Daily Briefing Agent | Triage email SAP/ABAP 24 jam, deteksi task development pending, dan checkpoint hasil briefing | daily briefing abap, briefing sap, email abap pending, cron abap |
| `subproject/SAP_GUI_AUTOMATION/` | SAP GUI for Java + Cua Driver | Display X11 khusus, computer-use transaksi SAP, screenshot verification, dan pemantauan VNC lokal | sap gui, sap logon, computer use, cua-driver, gui automation, monitor transaksi |
| `subproject/ZPP005N/` | `ZPPR_PENDING_ORDER_ALF` | Report Pending Order (monitoring Sales Order vs Production Order, status Delivery & Stock TTA, kolom SKU Design SubCont CKI, Digital Boardroom) | zpp005n, zpp005, zppr_pending_order_alf, pending order, so pending, order alf |
| `subproject/ZPP090/` | `ZPPI_CHANGE_JR_NUMBER` | Koreksi dan pemunduran sequence nomor Jumbo Roll (JR), update counter tabel `ZSEQNUM` & log `ZLOG_JRNO`, penanganan multi-step rollback | zpp090, zppi_change_jr_number, change jr, memundurkan no roll, sequence roll jr, zseqnum, zlog_jrno |
| `subproject/ZMM061/` | `ZMMR_RETURN_PALLET_STOCK` | Report Returnable Pallet Stock (RTP Pallet/Core/Sideboard), status siklus pallet dari log `ZPALLETR`, mapping Terminal `ZMAP_TYPE` per TCODE, dokumen WRICEF/FS | zmm061, zmmr_return_pallet_stock, returnable pallet, rtp pallet, zpalletr, pallet stock, terminal pallet |
| `subproject/ZMMI_WMS/` | `ZMMI_WMS` (baru) + asal T-Code `ZBMBC` / `ZBAP_STOCK_BY_CHAR1` | **Digabung dengan ZBMBC 2026-11-05.** Program baru feed WMS gudang berbasis HU: VEKP (Created On + MAGRV) -> HU Box/Pallet -> batch -> stok MCHB/MSKA -> karakteristik; output ALV / WMS (staging `Y_ZBMBCSR` + `SP_Merge_ZBMBCSR_WMS`), mass select di awal | zmmi_wms, zbmbc, zbmbcsr, zbap_stock_by_char1, wms, hu wms, stock overview characteristic, execution type, y_zbmbcsr, vekp, vepo, magrv, hu created on, hu pallet, hu box |
| `subproject/PROCESS_ORDER_RFC/` | `ABAP4_CALL_TRANSACTION` → COR1 | Create process order JR (1 ROL, base qty KG) dari luar SAP via RFC, zero transport, background | cor1, create process order, create production order via rfc, bapi_procord_create, abap4_call_transaction, process order rfc, base quantity |
| `subproject/MCP_GATEWAY_TEST/` *(kerangka, belum ada isi)* | MCP Gateway Test | Pengujian konektivitas, handshake, discovery tools, dan health check endpoint MCP SQL/RAG | mcp gateway, mcp-sql, mcp-rag, gateway test, testing mcp |
| `subproject/LABELROL_DOCX/` | `ZMMR_LABELROL_DOCX` (+ `ZCL_LABEL_DOCX`) | Cetak label roll/HU dari template DOCX, encode barcode Code128 (labelutils → native ABAP), rancangan QR code | labelrol docx, zmmr_labelrol_docx, zcl_label_docx, label roll, label docx, barcode128, code128, qr code label, labelutils |
| `subproject/ADT_VSCODE/` | ICF `/sap/bc/adt` + ICM 8000 + proxy | Buka/edit program SAP langsung di VSCode via ADT (ext ABAP remote FS), setup sandbox-new, proxy header `X-Requested-With` untuk SAP_BASIS 731 SP4 | adt, vscode, abap remote fs, abapfs, sicf adt, smicm, icm port, eclipse adt |


## Folder Non-Sub-Project

- `_SHARED/` dan `_REVIEW_IMAGES/` dihapus 2026-11-05 atas perintah Baginda. Arsip: `00_RULES/_backup/arsip_hapus_20261105/` (+ riwayat git commit `d4aafc5`). Helper lintas program baru → taruh di sub-project yang memakainya.

## Aturan Kerja Dengan Sub-Project

1. Baca permintaan user, cocokkan ke kolom **kata kunci** di tabel untuk memilih sub-project.
2. Jika ambigu antara dua sub-project (mis. PO release vs PO email), tanyakan ke user sebelum lanjut.
3. Baca konteks dari `docs/` sub-project itu dulu (FS/TS) sebelum ubah kode.
4. Source hasil kerja simpan di `src/`, script di `scripts/`, backup/dump di `outputs/` sub-project yang sama — jangan taruh di root atau di dalam `subproject/` langsung.
5. Aturan push/update program tetap berlaku penuh: lihat [03](00_RULES/03_Push_Program_dan_SmartForm.md) (write hanya `sandbox-new`, wajib pull terbaru sebelum push).

## AUTO-MAPPING — Menambah Sub-Project Baru (WAJIB)

Ketika muncul program/permintaan yang **tidak cocok** dengan sub-project mana pun di tabel:

1. Buat folder baru di dalam `subproject/` dengan nama singkat huruf besar, mis. `subproject/NAMA_BARU/`.
2. Buat subfolder standar di dalamnya: `src/ scripts/ docs/ tests/ outputs/` + `README.md` dari `01_TEMPLATE/Template_README_Subproject.md`.
3. **Tambahkan satu baris ke tabel "Peta Sub-Project" di atas**: folder, program utama, cakupan, dan kata kunci routing. Tanpa langkah ini sub-project baru tidak akan ter-route otomatis.
4. Taruh semua file terkait ke subfolder yang sesuai berdasarkan ekstensi:
   `.abap`→`src/`, `.mjs/.js/.py/.ps1`→`scripts/` (test→`tests/`), dokumen/gambar→`docs/`, `.json/.log/.txt` dump/backup→`outputs/`.
5. Buat `CHECKPOINT.md` dari `01_TEMPLATE/Template_Checkpoint.md` dan catat di root `CHECKPOINT.md`.
6. Jika satu file relevan ke >1 sub-project, taruh di sub-project utama dan sebut di kolom cakupan sub-project lain.

Ringkas: **setiap sub-project baru = 1 folder di `subproject/` + 1 baris di tabel peta ini.** Update tabel selalu, agar routing tetap otomatis.

## Catatan Housekeeping

- 2026-11-05: `ZBMBC` digabung ke `ZMMI_WMS` (script ZBMBC di `scripts/zbmbc/`). "Routing Cepat" dihapus (duplikat tabel). Keyword bentrok dirapikan (`zppr`/`zppi`/`mes`/`wms`/`jumbo roll`).

- 2026-11-05: restrukturisasi — `AGENTS.md` dipecah ke `00_RULES/`, ditambah `01_TEMPLATE/` dan `README.md` di setiap sub-project. `Claude outputs/Solusi_COR1_via_RFC.md` dipindah ke `subproject/PROCESS_ORDER_RFC/docs/`. Backup: `00_RULES/_backup/`.

- Root folder telah dirapikan: file spesifikasi PO Notification dan output Last Price telah dipindahkan ke `subproject/PO_EMAIL/`.
- File source `ZPPR_PENDING_ORDER_ALF.abap` telah dipindahkan ke `subproject/ZPP005N/src/`.
