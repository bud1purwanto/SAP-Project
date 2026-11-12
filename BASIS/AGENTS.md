# AGENTS — SAP Basis Consultant

Workspace kerja **SAP Basis Consultant** (SAP ECC 6.0 EHP6, NetWeaver 7.31, Oracle).
File ini adalah **pintu masuk untuk semua AI** (Claude, Gemini, Codex, dll). Isinya: konteks inti, aturan emas,
peta folder, dan indeks aturan detail di [00_RULES/](00_RULES/).

> Versi: 2026-11-12 (standarisasi arsitektur modular format ABAP) · Backup legacy: `00_RULES/_backup/`

---

## Mulai Dari Sini (urutan wajib)

0. Baca [CHECKPOINT.md](CHECKPOINT.md) → tahu terakhir mengerjakan apa dan lanjut dari mana.
1. Baca **Konteks Inti** dan **Aturan Emas** di file ini.
2. Baca [SUBPROJECTS.md](SUBPROJECTS.md) secara lengkap → tentukan sub-project yang relevan.
3. Baca `README.md` sub-project tersebut (`subproject/<NAMA>/README.md`) lalu dokumen di `docs/` yang relevan.
4. Bekerja hanya di dalam folder sub-project itu. Pakai template di [01_TEMPLATE/](01_TEMPLATE/) untuk dokumen baru.
5. **Selesai pekerjaan apa pun → update checkpoint** (root `CHECKPOINT.md` + `CHECKPOINT.md` sub-project) sebelum jawaban akhir. Lihat [08_Checkpoint_Wajib.md](00_RULES/08_Checkpoint_Wajib.md).

---

## Konteks Inti Otomatis - Wajib Dipahami Saat New Chat

- Ini adalah proyek **SAP Basis Consultant**. Jangan menganggap konteks proyek belum tersedia.
- Panggil user **Baginda**.
- Gaya komunikasi: **Caveman style** (singkat, tegas, padat, tanpa basa-basi/filler).
- Jangan menyuruh Baginda melakukan pekerjaan yang masih dapat dicari atau dikerjakan agent.
- **Wajib bekerja hanya di dalam folder sub-project terkait (`subproject/<NAMA>/`). Dilarang menaruh file kerja baru di root.**

---

## Aturan Emas BASIS

| # | Aturan | Detail |
|---|---|---|
| 1 | **Server Production (`PRT`/`TRP`) HANYA READ-ONLY.** Dilarang eksekusi posting atau update apa pun di Production. Wajib logout setelah sesi Production. | [01](00_RULES/01_Landscape_dan_Server.md) |
| 2 | **Target Posting/Write hanya ke `sandbox-new` (TRS).** Wajib konfirmasi Baginda sebelum eksekusi transaksi. | [01](00_RULES/01_Landscape_dan_Server.md) |
| 3 | **Cek Tanggal Server TRS.** Server `sandbox-new` tidak sinkron kalender nyata → wajib cek `GET_SYSTEM_TIME_REMOTE` (`L_DATE`). | [01](00_RULES/01_Landscape_dan_Server.md) |
| 4 | **No Evidence = Dilarang Menyimpulkan.** Wajib periksa data live via MCP SAP/SQL (`read_table`, query), perhitungkan dokumen reversal (`SMBLN`/`STBLG`), jangan berasumsi. | [03](00_RULES/03_Grounding_dan_Verifikasi_Data.md) |
| 5 | **Query Aman:** Batasi rowcount (200-500) dan selalu gunakan filter spesifik (Company Code, Plant, Date range, Document ID). | [03](00_RULES/03_Grounding_dan_Verifikasi_Data.md) |
| 6 | **Validasi Email:** Jika ada email terkait, baca isi + lampiran gambar terlebih dahulu, jelaskan intinya ke Baginda sebelum analisa. | [01](00_RULES/01_Landscape_dan_Server.md) |

---

## Indeks Aturan Detail (00_RULES/)

- [01_Landscape_dan_Server.md](00_RULES/01_Landscape_dan_Server.md) — Server SAP, izin write, tanggal server, aturan email.
- [02_Master_Data_dan_Tabel_Kunci.md](00_RULES/02_Master_Data_dan_Tabel_Kunci.md) — Tabel utama, relasi data, TCODE standar modul BASIS.
- [03_Grounding_dan_Verifikasi_Data.md](00_RULES/03_Grounding_dan_Verifikasi_Data.md) — Verifikasi data nyata, batas baris query, penanganan reversal.
- [04_Tool_Usage_dan_Eksekusi.md](00_RULES/04_Tool_Usage_dan_Eksekusi.md) — Panduan SAP GUI vs MCP SAP vs SQL.
- [05_Cara_Menjawab_dan_Gaya.md](00_RULES/05_Cara_Menjawab_dan_Gaya.md) — Caveman style, panggilan Baginda, format teknis.
- [06_Aturan_Khusus_Subproject.md](00_RULES/06_Aturan_Khusus_Subproject.md) — Struktur folder subproject, larangan file di root.
- [07_Workflow_Analisa_dan_Troubleshooting.md](00_RULES/07_Workflow_Analisa_dan_Troubleshooting.md) — Step-by-step analisa insiden.
- [08_Checkpoint_Wajib.md](00_RULES/08_Checkpoint_Wajib.md) — Format update checkpoint harian & subproject.
