# AGENTS — SAP ABAP Consultant

Workspace kerja **SAP ABAP Consultant** (SAP ECC 6.0 EHP6, NetWeaver 7.31, **ABAP 7.31**, Oracle).
File ini adalah **pintu masuk untuk semua AI** (Claude, GPT/Codex, Hermes, dll). Isinya: konteks inti, aturan emas,
peta folder, dan indeks aturan detail di [00_RULES/](00_RULES/).

> Versi: 2026-11-05 · Backup versi sebelumnya: [00_RULES/_backup/AGENTS_20261105.md](00_RULES/_backup/AGENTS_20261105.md)

---

## Mulai Dari Sini (urutan wajib)

0. Baca [CHECKPOINT.md](CHECKPOINT.md) → tahu terakhir mengerjakan apa dan lanjut dari mana.
1. Baca **Konteks Inti** dan **Aturan Emas** di file ini.
2. Baca [SUBPROJECTS.md](SUBPROJECTS.md) secara lengkap → tentukan sub-project yang relevan.
3. Baca `README.md` sub-project tersebut (`subproject/<NAMA>/README.md`) lalu dokumen di `docs/`.
4. Untuk development: ikuti [07_Workflow_Development.md](00_RULES/07_Workflow_Development.md). Sebelum menulis/mengubah kode, baca aturan detail yang relevan di [00_RULES/](#indeks-aturan-detail-00_rules).
5. Simpan hasil kerja hanya di folder sub-project itu. Pakai template di [01_TEMPLATE/](01_TEMPLATE/) untuk dokumen baru.
6. **Selesai pekerjaan apa pun → update checkpoint** (root `CHECKPOINT.md` + `CHECKPOINT.md` sub-project) sebelum jawaban akhir. Lihat [08](00_RULES/08_Checkpoint_Wajib.md).

---

## Konteks Inti Otomatis - Wajib Dipahami Saat New Chat

- Ini adalah proyek **SAP ABAP Consultant**. Jangan menganggap konteks proyek belum tersedia.
- Panggil user **Baginda**.
- Jangan menyuruh Baginda melakukan pekerjaan yang masih dapat dicari atau dikerjakan agent.
- Cari jalur alternatif sampai seluruh opsi aman yang tersedia benar-benar habis.
- Sebelum pekerjaan teknis, baca `SUBPROJECTS.md` secara lengkap.
- Jika pembacaan terminal biasa gagal, coba jalur read-only lain atau read-only di luar sandbox. Jangan langsung meminta Baginda menyalin file.
- Setelah routing ditemukan, baca Markdown relevan di folder subproject sebelum mengubah apa pun.
- **Wajib bekerja hanya di dalam folder sub-project terkait (`subproject/<NAMA>/`). Dilarang menaruh file kerja baru di root.**

---

## LANGKAH PERTAMA — WAJIB SEBELUM KERJA APA PUN

Sebelum menjawab permintaan teknis apa pun, **baca `SUBPROJECTS.md` lebih dulu** untuk
menentukan sub-project yang relevan. Semua sub-project berada di dalam folder induk
`subproject/`. Cocokkan permintaan user ke tabel kata kunci di `SUBPROJECTS.md`, lalu
bekerja hanya di dalam folder sub-project itu. Jangan menaruh file baru di root. Jika
routing ambigu antar sub-project, tanyakan dulu ke user.

Jika program/permintaan tidak cocok dengan sub-project mana pun, buat sub-project baru:
1 folder di `subproject/` + subfolder `src/ scripts/ docs/ tests/ outputs/` + tambah 1 baris
ke tabel peta di `SUBPROJECTS.md` (ikuti bagian "AUTO-MAPPING"). Wajib update tabel agar
routing tetap otomatis.

---

## Aturan Emas (ringkas — detail di 00_RULES)

| # | Aturan | Detail |
|---|---|---|
| 1 | **Write program/Smart Form HANYA ke server `sandbox-new` (TRS).** Analisa boleh di server mana saja. Set `set_active_server` → `sandbox-new` sebelum setiap write. Push program: prioritas FM `Z_RFC_PROGRAM_UPDATE`. | [03](00_RULES/03_Push_Program_dan_SmartForm.md) |
| 2 | **ABAP 7.31 saja.** Dilarang `DATA(...)`, string template, `NEW`/`VALUE`/`REDUCE`/`CORRESPONDING`/`FILTER`, `@` host variable, CDS/RAP/AMDP. | [02](00_RULES/02_Sintaks_ABAP_731.md) |
| 3 | **Minimal diff.** Hanya ubah yang diminta; jangan reformat, hapus komentar, atau tambah logika yang tidak diminta. | [04](00_RULES/04_Grounding_dan_Review_Kode.md) |
| 4 | **Integritas data.** Perhitungkan reversal (`SMBLN`), jangan proses order TECO/DLV/CLSD, dilarang direct `UPDATE/INSERT/DELETE` tabel standar — pakai BAPI + COMMIT/ROLLBACK. | [04](00_RULES/04_Grounding_dan_Review_Kode.md) |
| 5 | **Ambil data nyata, jangan berasumsi.** Pakai MCP SAP (`read_table`, `read_program`, ...) dan RAG SAP. | [01](00_RULES/01_Landscape_dan_Server.md) |
| 6 | **GUI diminta eksplisit → wajib Virtual VNC** (`DISPLAY=:99`, `cua-driver`). Dilarang mengalihkan ke RFC/BAPI. | [01](00_RULES/01_Landscape_dan_Server.md) |
| 7 | **Development ikuti workflow:** Brief → AGREED Baginda → Start gate → development → QA gate (PASS/WARN/FAIL/NOT RUN) → report. | [07](00_RULES/07_Workflow_Development.md) |
| 8 | **Hapus objek/data hanya dengan perintah eksplisit Baginda** (sebut objeknya, backup dulu). Production & tabel standar: tidak pernah. Tanpa perintah → saran penghapusan saja. | [03](00_RULES/03_Push_Program_dan_SmartForm.md#delete-rule-hapus-hanya-dengan-perintah-eksplisit) |
| 9 | **Checkpoint wajib setelah setiap pekerjaan** (termasuk yang terputus): timpa "Terakhir Dikerjakan" + 1 baris log di root `CHECKPOINT.md`, update `CHECKPOINT.md` sub-project. Awal sesi: baca checkpoint dulu. | [08](00_RULES/08_Checkpoint_Wajib.md) |
| 10 | **Jawaban:** Bahasa Indonesia, gaya caveman, sebut TCODE, kode 7.31 lengkap, catatan performa, dampak transport, peringatan risiko data. | [05](00_RULES/05_Cara_Menjawab_dan_Gaya.md) |

---

## Peta Folder

```
ABAP/
├── AGENTS.md                 <- file ini (entry point semua AI)
├── CHECKPOINT.md             <- terakhir mengerjakan apa + log lintas device/AI (baca pertama)
├── SUBPROJECTS.md            <- peta routing sub-project (kata kunci → folder)
├── 00_RULES/                 <- aturan detail, dipecah per topik
│   ├── 01_Landscape_dan_Server.md
│   ├── 02_Sintaks_ABAP_731.md
│   ├── 03_Push_Program_dan_SmartForm.md
│   ├── 04_Grounding_dan_Review_Kode.md
│   ├── 05_Cara_Menjawab_dan_Gaya.md
│   ├── 06_Aturan_Khusus_Subproject.md
│   ├── 07_Workflow_Development.md
│   ├── 08_Checkpoint_Wajib.md
│   └── _backup/              <- backup sebelum restrukturisasi & merge
├── 01_TEMPLATE/              <- template README sub-project, Design Brief, FS, analisa, RCA, checkpoint, checklist review
├── 02_AGENTS/                <- agent per peran + peta tool ADT → MCP SAP
├── subproject/<NAMA>/        <- satu folder per program/kasus
│   ├── README.md             <- ringkasan sub-project (wajib)
│   ├── src/  scripts/  docs/  tests/  outputs/
├── _SHARED/                  <- helper generik lintas sub-project
└── _REVIEW_IMAGES/           <- screenshot lama, perlu disortir Baginda
```

Catatan: nama folder `subproject/` dan subfolder standarnya **jangan diganti** — banyak script memakai path `subproject/...` secara hardcode.

---

## Indeks Aturan Detail (00_RULES)

| File | Isi | Wajib dibaca saat |
|---|---|---|
| [01_Landscape_dan_Server.md](00_RULES/01_Landscape_dan_Server.md) | Role, environment TRD, tool MCP SAP & RAG, routing MCP, aturan GUI VNC, etika | Awal sesi / memilih server / memakai GUI |
| [02_Sintaks_ABAP_731.md](00_RULES/02_Sintaks_ABAP_731.md) | Fitur yang dilarang & pengganti 7.31 | Menulis kode ABAP apa pun |
| [03_Push_Program_dan_SmartForm.md](00_RULES/03_Push_Program_dan_SmartForm.md) | Write hanya `sandbox-new`, status RFC push, PROGTAB 72 char, enhancement, Smart Form via XML | Push/update program atau Smart Form |
| [04_Grounding_dan_Review_Kode.md](00_RULES/04_Grounding_dan_Review_Kode.md) | Self-check sintaks, performa Oracle, memori, error handling, integritas data, minimal diff | Sebelum output kode / sebelum push |
| [05_Cara_Menjawab_dan_Gaya.md](00_RULES/05_Cara_Menjawab_dan_Gaya.md) | Format jawaban teknis, troubleshooting, area keahlian, bahasa, gaya caveman | Setiap jawaban |
| [06_Aturan_Khusus_Subproject.md](00_RULES/06_Aturan_Khusus_Subproject.md) | Arsitektur COA Dynamic Table & Smart Forms | Kerja di `subproject/COA/` |
| [07_Workflow_Development.md](00_RULES/07_Workflow_Development.md) | Alur Intake → Brainstorm → Agreement → Development → Verifikasi → Report | Development / enhancement program |
| [08_Checkpoint_Wajib.md](00_RULES/08_Checkpoint_Wajib.md) | Checkpoint root + sub-project setelah setiap pekerjaan, format log | Awal & akhir setiap pekerjaan |

---

## Agent per Peran (02_AGENTS)

Tidak butuh ADT — memakai MCP SAP (RFC). Peta tool, keterbatasan, dan cara install: [02_AGENTS/README.md](02_AGENTS/README.md).

| Agent | Peran |
|---|---|
| [abap-brainstormer](02_AGENTS/abap-brainstormer.md) | Analisa FS, opsi, Design Brief (read-only) |
| [abap-developer](02_AGENTS/abap-developer.md) | Development di `sandbox-new` |
| [abap-syntax-checker](02_AGENTS/abap-syntax-checker.md) | Cek sintaks 7.31 & aktivasi (read-only) |
| [abap-test-engineer](02_AGENTS/abap-test-engineer.md) | Skenario & kode test |
| [abap-qa-engineer](02_AGENTS/abap-qa-engineer.md) | QA gate → READY / NOT READY (read-only) |
| [abap-reviewer](02_AGENTS/abap-reviewer.md) | Code review Critical/Major/Minor (read-only) |

---

## Template (01_TEMPLATE)

| Template | Dipakai untuk |
|---|---|
| [Template_README_Subproject.md](01_TEMPLATE/Template_README_Subproject.md) | README setiap sub-project baru |
| [Template_Design_Brief.md](01_TEMPLATE/Template_Design_Brief.md) | Design Brief sebelum development |
| [Template_FS_Singkat.md](01_TEMPLATE/Template_FS_Singkat.md) | Functional Spec ringkas |
| [Template_Laporan_Analisa.md](01_TEMPLATE/Template_Laporan_Analisa.md) | Analisa kasus / data |
| [Template_Laporan_RCA.md](01_TEMPLATE/Template_Laporan_RCA.md) | Root Cause Analysis insiden |
| [Template_Checkpoint.md](01_TEMPLATE/Template_Checkpoint.md) | Checkpoint status kerja sub-project |
| [Checklist_Review_Kode_ABAP.md](01_TEMPLATE/Checklist_Review_Kode_ABAP.md) | Self-review sebelum push |

---

## Konvensi Penamaan File

| Jenis | Pola | Contoh |
|---|---|---|
| Dokumen analisa/keputusan | `YYYY-MM-DD_<TOPIK>.md` | `2026-10-16_ANALISA_ZPP001_GR_DUPLIKAT_SRAAOI.md` |
| Backup source sebelum ubah | `<PROGRAM>_<server>_before_<perubahan>_<YYYYMMDD>.abap` di `outputs/` | `ZPPR_GI_JR_CLOSING_backup_20260910_TRS_before_cutoff.abap` |
| Checkpoint | `CHECKPOINT.md` (root sub-project) atau `docs/checkpoint-YYYY-MM-DD.md` | `DAILY_ABAP_BRIEFING/docs/checkpoint-2026-11-01.md` |
| Source aktif | `src/<PROGRAM>.abap` (include: `_TOP`, `_F01`, ...) | `src/ZPPI_COHVPI.abap` |

---

## Housekeeping

- Setiap sub-project baru: folder + subfolder standar + `README.md` (dari template) + 1 baris di `SUBPROJECTS.md`.
- Setiap pekerjaan: update `CHECKPOINT.md` root + sub-project (wajib, lihat [08](00_RULES/08_Checkpoint_Wajib.md)). Perubahan besar: perbarui juga `README.md` sub-project.
- Jangan menaruh file kerja di root atau langsung di `subproject/`.
