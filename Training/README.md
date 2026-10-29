# Training SAP dengan AI — Program 14 Hari "Z Program"

Program belajar mandiri SAP ECC (PT Trias Sentosa) menggunakan AI (Claude Code + MCP SAP + MCP RAG).
Semua study case diambil dari **project nyata** di repository ini, diurutkan dari **paling mudah (Day 1)**
sampai **paling sulit (Day 14)**.

---

## Mulai Dari Sini

> **Versi Excel:** seluruh materi juga tersedia dalam satu file [Training_SAP_AI_14_Hari.xlsx](Training_SAP_AI_14_Hari.xlsx) — sheet Panduan, Jadwal, Progress (bisa diisi), Persiapan, Glosarium, Skills, Day01–Day14, Kunci Jawaban, Referensi.

1. Baca [00_PERSIAPAN/01_Landscape_dan_Aturan_Server.md](00_PERSIAPAN/01_Landscape_dan_Aturan_Server.md) — **wajib**, berisi aturan keamanan.
2. Baca [00_PERSIAPAN/02_Cara_Belajar_dengan_AI.md](00_PERSIAPAN/02_Cara_Belajar_dengan_AI.md) — cara bertanya ke AI.
3. Pasang skill (lihat [01_SKILLS/README.md](01_SKILLS/README.md)).
4. Kerjakan study case berurutan di [02_STUDY_CASE/](02_STUDY_CASE/), satu file per hari.
5. Catat progres di [04_PROGRESS/Progress_Tracker.md](04_PROGRESS/Progress_Tracker.md).

---

## Peta Folder

```
Training/
├── README.md                         <- file ini
├── Training_SAP_AI_14_Hari.xlsx      <- versi Excel seluruh materi (1 file)
├── 00_PERSIAPAN/                     <- baca sebelum Day 1
│   ├── 01_Landscape_dan_Aturan_Server.md
│   ├── 02_Cara_Belajar_dengan_AI.md
│   └── 03_Glosarium.md
├── 01_SKILLS/                        <- "skill" AI siap pakai
│   ├── README.md                     <- cara install & kapan dipakai
│   ├── abap-dev-sandbox-new/         <- development ABAP (WRITE hanya di Sandbox New Company)
│   ├── pp-analisa-production/        <- analisa modul PP di Production AIX (READ-ONLY)
│   ├── mm-analisa-production/
│   ├── qm-analisa-production/
│   ├── sd-analisa-production/
│   └── fico-analisa-production/
├── 02_STUDY_CASE/                    <- Day 01 s/d Day 14
├── 03_TEMPLATE/                      <- template laporan analisa, FS, checklist review
├── 04_PROGRESS/                      <- tracker progres harian
└── 05_REFERENSI/                     <- salinan dokumen & source asli yang dirujuk study case
```

---

## Jadwal 14 Hari

Level: ★ = sangat mudah ... ★★★★★ = sangat sulit. Server: **PRD-RO** = Production AIX read-only, **SBX** = Sandbox New Company (boleh tulis).

| Day | Judul | Modul | Server | Level | Program yang dibuat | Flow utama |
|---|---|---|---|---|---|---|
| [01](02_STUDY_CASE/Day01_Report_PO_Sederhana.md) | Report Purchase Order Sederhana | MM | SBX + PRD-RO | ★★ | PO list (EKKO/EKPO) + ALV | Procure to Pay |
| [02](02_STUDY_CASE/Day02_Report_PO_Monitoring_Join.md) | Report PO Monitoring (Join + Agregasi) | MM | SBX + PRD-RO | ★★★ | PO vs GR vs sisa, status lampu, klik ke ME23N | Status PO sampai diterima penuh |
| [03](02_STUDY_CASE/Day03_Program_Transfer_Posting.md) | Program Transaksi: Transfer Posting | MM | SBX | ★★★ | Transfer 311 via BAPI + test run | Transfer stok antar SLoc |
| [04](02_STUDY_CASE/Day04_Report_dan_Posting_Satu_Program.md) | Report + Posting dalam 1 Program | MM | SBX | ★★★ | Radio Report / Posting (modifikasi Day 03) | Cek stok → transfer → histori |
| [05](02_STUDY_CASE/Day05_PO_Exception_Email.md) | PO Exception Email | MM | SBX + PRD-RO | ★★★ | Rule `ZMAP_TYPE` + email HTML & Excel | PO → exception → approver |
| [06](02_STUDY_CASE/Day06_PP_Status_Order_dan_Auto_TECO.md) | Status Production Order & Auto TECO | PP | PRD-RO + SBX | ★★★ | TECO Readiness Checker | Siklus status order |
| [07](02_STUDY_CASE/Day07_MM_Movement_Type_dan_Reversal.md) | Movement Type, Reversal & GI JR Closing | MM/PP | PRD-RO + SBX | ★★★ | GR vs GI per order, 3 mode | Produksi JR & closing |
| [08](02_STUDY_CASE/Day08_Batch_Characteristic.md) | Batch Characteristic (CABN/AUSP) | PP/QM | PRD-RO + SBX | ★★★★ | Pivot karakteristik batch | Upload SR → karakteristik |
| [09](02_STUDY_CASE/Day09_Aplikasi_Z_Tabel_Lock_Log.md) | Develop Aplikasi Z: Tabel, Lock & Log | PP/ABAP | SBX + PRD-RO | ★★★★ | Tabel Z + lock object + SM30 + program counter & log | Koreksi nomor roll |
| [10](02_STUDY_CASE/Day10_FICO_Upload_Faktur.md) | FICO: Upload Faktur & Jejak Audit | FI | PRD-RO + SBX | ★★★★ | Upload file + audit checker (simulasi) | Faktur pajak → audit |
| [11](02_STUDY_CASE/Day11_QM_Pending_Lot_Mass_UD.md) | QM: Pending Lot + Mass Usage Decision | QM | SBX + PRD-RO | ★★★★ | Report lot pending + transaksi UD massal | GR → uji → UD → stok release |
| [12](02_STUDY_CASE/Day12_Performance_Index_Data_Besar.md) | Performance: Index & Data Besar | MM/ABAP | SBX + PRD-RO | ★★★★ | 3 mode: lambat / index / package size | Akses database per mode |
| [13](02_STUDY_CASE/Day13_Transaksi_Process_Order_End_to_End.md) | Transaksi Sulit: Process Order End-to-End | PP/MM | SBX + PRD-RO | ★★★★★ | Create → release → GI/GR → confirm → TECO + cancel | Siklus order + kompensasi |
| [14](02_STUDY_CASE/Day14_Capstone_ZPP001L_Slitting_Packing.md) | Capstone: ZPP001L Slitting + Packing | PP/MM/SD | SBX + PRD-RO | ★★★★★ | Copy ZPP001L + step packing ZHU5SO/FS + unpack saat cancel | Slitting → alokasi → packing → TECO |

Perkiraan waktu: 3–4 jam per hari (Day 13–14 bisa 5 jam).

---

## Deliverable Setiap Hari (wajib, mulai Day 01)

Walaupun dibantu AI, setiap hari **wajib** menghasilkan tiga hal:

| # | Deliverable | Keterangan |
|---|---|---|
| 1 | **Program** `ZTRN_<INISIAL>_D<NN>` | Dibuat & dijalankan di `sandbox-new`. AI membantu menulis, Anda yang menjalankan, menguji, dan menjelaskan setiap bagiannya. |
| 2 | **Flow** (Mermaid) | Flow A = proses bisnis, Flow B = logika program. Lihat [Template_Flow_Mermaid.md](03_TEMPLATE/Template_Flow_Mermaid.md). |
| 3 | **Catatan analisa** | Jawaban tugas & kuis, bukti hasil program (screenshot/ringkasan output). |

Aturan: jangan menerima kode AI tanpa membaca. Setiap program harus bisa Anda jelaskan baris demi baris ke orang lain.

## Tiga Aturan Emas

1. **Production AIX = hanya baca.** Tidak ada perubahan data, program, atau konfigurasi. Logout setelah selesai.
2. **Semua perubahan program hanya di `sandbox-new`** (Sandbox New Company), package `$TMP`, nama program diawali `ZTRN_`.
3. **AI adalah asisten, bukan sumber kebenaran.** Setiap jawaban AI dicek ke data nyata (SE11/SE16N/SE38 atau MCP SAP).

---

## Sumber Bahan

Semua dokumen sumber sudah disalin ke [05_REFERENSI/](05_REFERENSI/README.md), sehingga folder `Training` bisa dibaca tanpa repository project.

| Day | Diambil dari project |
|---|---|
| 01–04 | Proses standar MM (PO, GR, transfer posting) — skill [mm-analisa-production](01_SKILLS/mm-analisa-production/SKILL.md) |
| 05 | [PO_EMAIL/](05_REFERENSI/PO_EMAIL/) (`ZMMI_PO_EMAIL`) |
| 06 | [AUTO_TECO_ZPP001/](05_REFERENSI/AUTO_TECO_ZPP001/) (`ZPPI_COHVPI`) |
| 07 | [GI_JR_CLOSING/](05_REFERENSI/GI_JR_CLOSING/) (`ZPPR_GI_JR_CLOSING`) |
| 08, 12 | [PLANNING_SLITROLL/](05_REFERENSI/PLANNING_SLITROLL/) (`ZPPR_PLANNING_SLITROLL`) |
| 09 | [ZPP090/](05_REFERENSI/ZPP090/) (`ZPPI_CHANGE_JR_NUMBER`) — pola counter & log |
| 10 | [FICO_UPLOAD_FAKTUR/](05_REFERENSI/FICO_UPLOAD_FAKTUR/) (`ZFIC_UPLOAD_FAKTUR`) |
| 11 | [BARRIER/](05_REFERENSI/BARRIER/) (`ZQMI_PENDING_BARRIER`, Auto UD) |
| 13–14 | [ZPP001L_PACKING/](05_REFERENSI/ZPP001L_PACKING/ANALISA_ZPP001L_DAN_ZHU5SO_FS.md) (`ZPPI_SR_EXEC`, `ZHUI_PACK_PC`) + [analisa GR duplikat ZPP001](05_REFERENSI/AUTO_TECO_ZPP001/2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md) |
