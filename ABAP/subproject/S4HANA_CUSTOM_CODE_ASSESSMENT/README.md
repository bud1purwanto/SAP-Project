# S4HANA_CUSTOM_CODE_ASSESSMENT — Assessment Custom ABAP ECC ke S/4HANA

| Atribut | Isi |
|---|---|
| Program utama | Seluruh objek custom (Z*/Y*) dalam file dari Alfa |
| TCODE | SE16 (TADIR), SE80/SE84, SMOD/CMOD, SE19, SE20, SE95, SAPRSEUB, SCI, ATC, SCMON/SUSG |
| Modul | ABAP (lintas modul) |
| Server analisa | ECC Production AIX (as-is, read-only), Development AIX |
| Server tujuan | S/4HANA ADB (192.168.1.199) sebagai calon central ATC check system |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| Terakhir diperbarui | 2026-11-24 |

## 1. Tujuan
Menilai custom ABAP ECC 6.0 sebelum migrasi ke S/4HANA dengan tool standar SAP dan tanpa Generative AI. Pekerjaan dimulai dari pilot 5–10 program dari file Alfa.

Deliverable (sesuai email manager): Custom ABAP Object Inventory, Dependency Analysis Report, Usage Analysis Report, ATC Findings Report, Migration Assessment & Remediation List, dan daftar objek/dependensi yang hilang.

## 2. Isi Folder

| Folder | Isi |
|---|---|
| `src/` | Baseline source dari Alfa (taruh di sini apa adanya, jangan diedit) |
| `tools/ekstrak-program-abap/` | Tool ekstrak dan dependency per program buatan rekan tim (Windows). Lihat `PETUNJUK.txt` |
| `docs/` | Analisis landscape, evaluasi tool, laporan pilot |
| `outputs/` | Hasil scan, export ATC/SCI, Excel deliverable |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/ANALISIS_LANDSCAPE_ATC.md](docs/ANALISIS_LANDSCAPE_ATC.md) | Versi ECC, tool yang tersedia/belum ada, arsitektur remote ATC ADB ke ECC, kendala Basis |
| [docs/BRIEF_TOOL_DETEKSI_PERBAIKAN_S4.md](docs/BRIEF_TOOL_DETEKSI_PERBAIKAN_S4.md) | Rancangan tool deteksi + perbaikan (Opsi A, Z-report di ADB) |
| [docs/UJI_F1_ZS4CCA.md](docs/UJI_F1_ZS4CCA.md) | Cara pasang & uji tool ZS4CCA F1 + hasil yang diharapkan |
| [docs/EVALUASI_TOOL_EKSTRAK_PROGRAM_ABAP.md](docs/EVALUASI_TOOL_EKSTRAK_PROGRAM_ABAP.md) | Seberapa jauh tool rekan menjawab poin 1 dan 2, beserta celahnya |

## 4. Aturan Khusus Sub-Project
- Assessment memakai tool standar SAP. Tool ekstrak hanya pelengkap untuk drill-down per program.
- PRD hanya dibaca, dan setiap akses perlu izin Baginda.
- File `.env` tool berisi kredensial, jadi jangan di-commit (sudah ada di `.gitignore`).
- Alur pakai mode lokal di Linux: `node tools/ekstrak-program-abap/tools/ringkas-abap.mjs src/<PROGRAM>.abap outputs/<folder>`

## 5. Objek SAP Terkait

| Objek | Jenis | Keterangan |
|---|---|---|
| TADIR, TRDIR, TFDIR, TSTC | Tabel repository | Inventory objek |
| WBCROSSGT, CROSS, D010INC | Tabel cross-reference | Dependency (butuh SAPRSEUB) |
| MODACT, ENHHEADER, SMODILOG | Tabel | User exit, enhancement, modifikasi |
| ZRFC_READ_REPORT | FM custom (ZFRFC) | Dipakai tool ekstrak untuk membaca source |
