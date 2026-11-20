# ZSMS — Program Messaging & Broadcast Pengguna SAP

| Atribut | Isi |
|---|---|
| Program utama | `ZSMS` |
| TCODE | `ZSMS` |
| Modul | BC / Basis / Tools / ABAP |
| Server analisa | `dev-aix` (TRD, 192.168.2.8, Client 130) |
| Server target write | `S4-HANA` (ADB, 192.168.1.199, Client 130) |
| Dokumen status | [CHECKPOINT.md](CHECKPOINT.md) |
| Terakhir diperbarui | 2026-11-20 |

## 1. Tujuan
Menyediakan utilitas interaktif pesan instan (broadcast popup) antar pengguna aktif SAP GUI dengan membaca user login via C-kernel / FM sistem dan memicu popup pesan melalui `TH_POPUP`. Subproject ini mencakup replikasi dan aktivasi Program serta TCode `ZSMS` dari SAP DEV AIX ke SAP S/4HANA 1909.

## 2. Isi Folder

| Folder | Isi |
|---|---|
| `src/` | Source code program ABAP (`ZSMS.abap`) |
| `scripts/` | Skrip automasi ekstraksi RFC, deployment, dan GUI automation test |
| `docs/` | Panduan langkah demi langkah (`STEP_BY_STEP_ZSMS_MIGRATION.md`) |
| `docs/attachments/` | Screenshot visual verifikasi live di SAP GUI Linux/Windows |
| `tests/` | Harness verifikasi integritas data dan eksekusi transaksi |
| `outputs/` | Backup source sebelum/sesudah migrasi |

## 3. Dokumen Kunci (baca dulu)

| Dokumen | Isi |
|---|---|
| [docs/STEP_BY_STEP_ZSMS_MIGRATION.md](docs/STEP_BY_STEP_ZSMS_MIGRATION.md) | Panduan komprehensif migrasi teknis Program & TCode ZSMS ke S/4HANA |
| [CHECKPOINT.md](CHECKPOINT.md) | Checkpoint status pengerjaan dan bukti verifikasi live |

## 4. Objek SAP Terkait

| Objek | Jenis | Keterangan |
|---|---|---|
| `ZSMS` | Program (Report) | Program executable messaging pengguna (229 baris, Unicode checked) |
| `ZSMS` | Transaction Code | Report transaction (`TSTC-CINFO = 80`), screen 1000 |
| `TSTC` / `TSTCT` | Tabel Sistem | Definisi transaksi dan teks deskripsi (`Program Messaging`) |
| `TADIR` | Tabel Repositori | Objek direktori repositori (`R3TR PROG ZSMS`, `R3TR TRAN ZSMS`, DevClass `$TMP`) |
| `TH_POPUP` | Function Module | Standard SAP FM pengirim pesan dialog popup |
| `USR21`, `V_ADRP_CP` | Tabel / CDS View | Pemetaan data personel, nama, departemen, dan nomor telepon user |