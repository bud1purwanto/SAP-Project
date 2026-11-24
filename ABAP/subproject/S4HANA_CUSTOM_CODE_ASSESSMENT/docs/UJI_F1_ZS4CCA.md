# Pasang & Uji F1 — ZS4CCA (L1 diff DDIC + L2 syntax S/4)

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-24 |
| Server | S/4 ADB (192.168.1.199, client 130), package `$TMP` |
| Source | `src/ZS4CCA_MAIN.abap`, `src/ZS4CCA_TOP.abap`, `src/ZS4CCA_CORE.abap`, fixture `src/ZS4CCA_TESTSRC.abap` |
| Status | Source siap, **belum terpasang**. Push lewat gateway tidak bisa (`install_and_run_abap` FL 046, `write_program` tanpa `Z_RFC_PROGRAM_UPDATE`); abaplint lokal ditolak pengaman, jadi cek sintaks resmi = aktivasi di ADB |

## 1. Pasang lewat VS Code (ABAP FS) ke ADB

| # | Objek | Jenis | Isi dari | Aktivasi |
|---|---|---|---|---|
| 1 | `ZS4CCA_TOP` | Include (PROG/I) | `src/ZS4CCA_TOP.abap` | Simpan saja |
| 2 | `ZS4CCA_CORE` | Include (PROG/I) | `src/ZS4CCA_CORE.abap` | Simpan saja |
| 3 | `ZS4CCA_MAIN` | Program executable (PROG/P) | `src/ZS4CCA_MAIN.abap` | **Aktivasi** (ikut include 1–2; kalau diminta main program, pilih `ZS4CCA_MAIN`) |
| 4 | `ZS4CCA_TESTSRC` | Program executable (PROG/P) | `src/ZS4CCA_TESTSRC.abap` | **Jangan diaktifkan**, cukup simpan (sengaja penuh error) |

Semua di package `$TMP`. Kalau aktivasi `ZS4CCA_MAIN` error, kirim pesan error (baris + teks) supaya diperbaiki.

## 2. Jalankan uji

SE38 / SA38 → `ZS4CCA_MAIN` → F8:
- `RB_ADB` = X, `S_PROG` = `ZS4CCA_TESTSRC`, `P_L1` = X, `P_L2` = X, `P_DEST` kosong.

## 3. Hasil yang diharapkan (L1, tanpa P_DEST)

| Baris fixture | Kode temuan | Sev | Objek |
|---|---|---|---|
| SELECT MSEG | `L1_TAB_REPLACED_READ` | W | MSEG (via `NSDM_V_MSEG`) |
| UPDATE MSEG | `L1_TAB_REPLACED_WRITE` | E | MSEG |
| SELECT … `%_HINTS ORACLE` | `L1_DB_HINT` | W | %_HINTS ORACLE |
| `TYPE zs4cca_tidak_ada-feld1` | `L1_MISSING_Z` | I | ZS4CCA_TIDAK_ADA |
| `TYPE REF TO zcl_s4cca_tidak_ada` | `L1_MISSING_Z` | I | ZCL_S4CCA_TIDAK_ADA |
| `CALL FUNCTION 'Z_S4CCA_FM_TIDAK_ADA'` | `L1_MISSING_Z` | I | Z_S4CCA_FM_TIDAK_ADA |
| `SUBMIT zs4cca_prog_tidak_ada` | `L1_MISSING_Z` | I | ZS4CCA_PROG_TIDAK_ADA |
| `EXEC SQL` | `L1_NATIVE_SQL` | W | EXEC SQL |
| `INCLUDE zs4cca_testsrc_inc_hilang` | `L1_SOURCE_MISSING` | W | ZS4CCA_TESTSRC_INC_HILANG |

L2: minimal muncul error kompilasi untuk tipe/FM/include Z yang tidak ada (`L2_MISSING_Z`) dan untuk `UPDATE mseg` bila compiler S/4 menolaknya (`L2_SYNTAX`).

### Yang sengaja **belum** terdeteksi di F1 (bukti kebutuhan F2 katalog aturan / P_DEST)
| Pola | Kenapa belum | Ditangkap oleh |
|---|---|---|
| `KONV`, `VBUK` | Di ADB masih tabel TRANSP (sudah dicek), hanya tidak diisi lagi | L3 katalog (F2) |
| `CALL TRANSACTION 'MB01'` | `MB01` masih ada di TSTC ADB (sudah dicek) | L3 katalog (F2) |
| `BSIS` (baca) | Butuh data ECC untuk tahu dulu TRANSP | Isi `P_DEST` (RFC ECC) |
| `gv_mat18(18)` / `MARA-MATNR` 40 | Banding panjang field butuh ECC | Isi `P_DEST` |

## 4. Verifikasi setelah pasang (oleh Claude, read-only)
Pull ulang source dari ADB via MCP (`read_program`), bandingkan dengan `src/` (baris & isi). Beda → dilaporkan.
