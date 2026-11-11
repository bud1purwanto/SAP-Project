# Analisa Temuan QA Aldi — ZMMI_WMS vs ZBMBC (2026-11-10)

| Atribut | Isi |
|---|---|
| Server | `qa` (TRQ 320), read-only |
| Program | `ZMMI_WMS` QA (UDAT 06.11.2026) = `src/ZMMI_WMS.abap` (diff kosong), `ZBAP_STOCK_BY_CHAR1_F01` QA → `outputs/*_qa.abap` |
| Pelapor | Aldi Dwi Kusuma (chat 3:23 PM) |
| Perubahan kode | Tidak ada |

## Logika HU di ZBMBC (QA, `ZBAP_STOCK_BY_CHAR1_F01` baris 843-866)

HU diisi hanya bila isi HU cocok dengan stock line: `VEPO-MATNR/CHARG/WERKS` **+ `VEPO-LGORT` = Sloc stok + `VEPO-SOBKZ` = jenis stok** + `VEKP-MAGRV`.
ZMMI_WMS hanya mencocokkan Material + Plant + Batch (temuan M4 di review 05.11.2026).

## 1. Batch 0003860400 — "duplikat"

| Data | Isi |
|---|---|
| HU | VENUM 0000702397 = **6000319605** (PLT, dibuat 27.01.2026), isi VEPO Sloc **2309**, 17,110 |
| MCHB | 2000/**2309** 17,110 (ERSDA 27.01.2026) · 2000/**2310** 118,758 (LAEDA 27.01.2026) · 2801 0 |
| MSEG | 311 tahun 2026: 17,110 dari 2310 → 2309 (sisa 118,758 tetap di 2310, tanpa HU) |

- **ZMMI_WMS Screen:** 2 stock line (2309 dan 2310) × 1 HU → **2 baris dengan HU yang sama** → terlihat duplikat. Baris 2310 seharusnya tidak punya HU.
- **ZBMBC:** 2309 → HU 6000319605; 2310 → HU kosong (VEPO-LGORT ≠ 2310).
- **ZMMI_WMS mode WMS:** unique batch memilih baris 2309 (Sloc = Sloc isi HU) → 1 baris; stok 2310 (118,758) tidak dikirim.
- **Akar masalah:** M4 — HU dipasang ke semua Sloc stok batch tanpa cek `VEPO-LGORT`.

## 2. Batch 0003879068 — di ZMMI ada HU, di ZBMBC tidak

| Data | Isi |
|---|---|
| HU | VENUM 0000701877 = **6000319206** (PLT, dibuat 20.05.2025), isi VEPO 2000/**1813**, **SOBKZ E, SO 15451/90**, 880,760 |
| MCHB | 2000/**1813** 880,760 (stok bebas, ERSDA 23.04.2026) |
| MSKA | semua 0 (15451/10, 15451/90, 15685/10) |
| MSEG terakhir | 413 15451/90 → 15685/10, lalu **411** 15685/10 → stok bebas 1813 (2026) |

- Fisik batch tetap di HU 6000319206 dan Sloc sama (1813). Yang berubah hanya jenis stok (SO → bebas) via 413/411; isi HU (VEPO-SOBKZ/SONUM) tidak ikut ter-update.
- **ZBMBC:** stok bebas (SOBKZ kosong) ≠ VEPO-SOBKZ 'E' → HU kosong.
- **ZMMI_WMS:** cocok Material + Plant + Batch → HU 6000319206 tampil.
- Secara fisik HU ZMMI benar; secara aturan ZBMBC tidak cocok. Perlu keputusan bisnis.

## 3. Batch 0003884578 & 0003880100

Di-exclude Aldi karena data transaksi QA keliru; batch dihapus Aldi. Tidak dianalisa.

## Usulan (perlu AGREED Baginda)

| Opsi | Aturan HU | 0003860400 | 0003879068 |
|---|---|---|---|
| A (rekomendasi) | Cocok Sloc (`VEPO-LGORT` = Sloc stok), SOBKZ diabaikan | 2310 tanpa HU → tidak duplikat | HU tetap tampil (Sloc sama) |
| B | Sama persis ZBMBC (Sloc + SOBKZ) | sama dengan A | HU kosong, sama ZBMBC |
| C | Tetap (as-is) | tetap duplikat di Screen | HU tampil |

Pertanyaan turunan: stock line yang tidak punya HU cocok (mis. 2310 = 118,758) — tetap ditampilkan dengan HU kosong (seperti ZBMBC) atau dibuang (program berbasis HU)?
Mode WMS tidak terpengaruh untuk 0003860400 (unique batch sudah memilih 2309).

## Keputusan & Implementasi (2026-11-11)

**Keputusan Baginda: Opsi B** (aturan HU sama persis ZBMBC). Stock line tanpa HU cocok tetap tampil dengan HU kosong (perilaku ZBMBC).

### Perubahan (Ref 003, sandbox-new TRS)
- `TY_VEPO` + `SOBKZ`; `READ_VEPO` SELECT + `SOBKZ`.
- `TY_CONT` + `LGORT`, `SOBKZ` (diisi dari VEPO isi HU).
- `ADD_OUT`: HU hanya dipasang bila `VEPO-LGORT` = Sloc stok. SOBKZ sama → HU Box + HU Pallet; SOBKZ beda → HU Box kosong, HU Pallet tetap dari pallet induk box (fallback ZBMBC `GT_HU` baris 853-866); pallet langsung + SOBKZ beda → tanpa HU. Tidak ada HU cocok → 1 baris stok dengan HU kosong. Pasangan HU per stock line di-sort & dedup.
- Backup: `outputs/ZMMI_WMS_sandbox_new_TRS_before_hu_sloc_sobkz_20261111.abap`; hasil pull setelah push: `outputs/ZMMI_WMS_after_hu_sloc_sobkz_20261111.abap` (1.345 baris, identik `src/`).

### QA gate (TRS, Created On 2000-2099, MAGRV BOX/PLT/TRS, baseline ZBMBC TRS diambil ulang 11.11.2026)

| Cek | Status | Hasil |
|---|---|---|
| Push `Z_RFC_PROGRAM_UPDATE` + pull ulang identik | PASS | EV_SUCCESS = X |
| Syntax check ZMMI_WMS / ZMMI_WMS_TEST | PASS | SYNTAX OK |
| Screen vs ZBMBC (17 kolom) | PASS | 50.872 / 50.876 identik; HU Box 0 beda (sebelumnya 93 HU terisi vs kosong); sisa 3 = batch di 2 pallet (ZBMBC SELECT SINGLE ambil 1, ZMMI tampil keduanya, HU ZBMBC ada di baris ZMMI) + 1 Storage Bin (m3) |
| WMS unique batch vs ZBMBC | PASS | 50.821 baris, 50.821 batch unik, 0 duplikat; 50.820 identik; 1 Storage Bin (m3). 43 batch terkirim tanpa HU (Sloc stok ≠ Sloc isi HU) |
| Kasus Aldi 0003860400 / 0003879068 | NOT RUN | Data hanya di QA; program QA masih versi lama → uji ulang setelah transport |

Compare: `outputs/COMPARE_ZMMI_WMS_Screen_vs_ZBMBC_TRS_20261111.md`, `outputs/COMPARE_ZMMI_WMS_WMSunique_vs_ZBMBC_TRS_20261111.md`.
Vonis: **READY WITH WARNINGS** — perlu transport ke DEV/QA lalu Aldi retest dua batch di atas.

## Uji Before/After di DEV (2026-11-11, read-only)

DEV (TRD-AIX 130): HU **6000036526** (PLT, isi 0003860400 Sloc 2309) dan **6000036527** (PLT, isi 0003879068 Sloc 1813, SOBKZ E SO 7203/90; stok aktual bebas 1813). Program ZMMI_WMS DEV = versi before (identik backup TRS).
Metode: `scripts/pool_test.mjs` (source lokal → GENERATE SUBROUTINE POOL di memori, insert SQL diganti dump, program DEV tidak diubah); validasi `scripts/verify_real.mjs` (SUBMIT program asli + CL_SALV_BS_RUNTIME_INFO).

| Run | 0003860400 / 2309 (17,110) | 0003860400 / 2310 (118,758) | 0003879068 / 1813 (880,760) |
|---|---|---|---|
| ZMMI_WMS DEV asli (Screen) | 6000036526 | **6000036526** | **6000036527** |
| Harness BEFORE Screen | 6000036526 | **6000036526** | **6000036527** |
| Harness AFTER Screen | 6000036526 | (kosong) | (kosong) |
| ZBMBC DEV | 6000036526 | (kosong) | (kosong) |
| Harness BEFORE WMS | 6000036526 | — (tidak dikirim) | **6000036527** |
| Harness AFTER WMS | 6000036526 | — (tidak dikirim) | (kosong) |

- Harness BEFORE = program DEV asli (3/3 baris identik) → harness valid.
- AFTER Screen = ZBMBC (3/3 identik).
- Masalah terbukti: 0003860400 tampil 2× dengan HU sama di mode Screen (WMS sudah 1 baris); 0003879068 dikirim ke WMS dengan HU 6000036527, sedangkan ZBMBC tanpa HU.

## Uji setelah deploy ke DEV (2026-11-11)

Source ZMMI_WMS DEV = Ref 003 (1.345 baris, identik `src/`; `outputs/ZMMI_WMS_dev_after_deploy_20261111.abap`), SYNTAX OK.

| Cek | Status | Hasil |
|---|---|---|
| 0003860400 & 0003879068 — program DEV asli (Screen) | PASS | 3/3 baris identik ZBMBC DEV (2310 & 1813 tanpa HU) |
| Mode WMS (harness, source DEV, tanpa insert SQL) | PASS | 2 baris: 0003860400/2309 HU 6000036526; 0003879068/1813 tanpa HU |
| Regresi penuh DEV: Created On 2000-2099, BOX/PLT, Screen vs ZBMBC SR* (diambil ulang) | PASS | 52.734 / 52.745 identik (99,98%); Sloc/SO/Storage Bin/karakteristik 0 beda |
| Sisa 11 beda HU (7 batch) | INFO | Batch tercatat di 2 HU sekaligus pada Sloc sama (mis. 0000361572: box 1000034120/pallet 6000031230 dan pallet 6000035390). ZBMBC SELECT SINGLE terpisah box & pallet → kombinasi HU campuran; ZMMI tampil 2 baris dengan pasangan benar, HU ZBMBC termasuk di dalamnya. Anomali data DEV (1 batch di 2 HU), bukan aturan HU |
| Insert nyata ke MSSQL WMS | NOT RUN | Tidak dijalankan agar data WMS tidak berubah |

Compare: `outputs/COMPARE_ZMMI_WMS_Screen_vs_ZBMBC_DEV_20261111.md`. Vonis: **READY** untuk transport ke QA + retest Aldi.
