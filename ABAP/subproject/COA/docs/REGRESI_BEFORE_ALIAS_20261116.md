# Regresi "Before" Alias — 16 Nov 2026 (Development AIX)

Tujuan: memotret hasil program ZQMI_COA **sebelum** perubahan alias, untuk semua skenario di `STANDAR_SKENARIO_TESTING_COA.md` §0.1 plus DO uji alias. Program DEV tidak diubah: harness read-only (`tests/mt_harness_final.abap` untuk ZQM002/GET_DATA, `tests/mt_harness_alv.abap` untuk ZQM003/RPT_BUILD), 1 sesi RFC per DO.

- Source DEV diambil ulang 16 Nov: TOP, F01, F02, ALV **identik** dengan fetch 12 Nov (`*_alias20261112.abap`) yang jadi dasar rancangan alias.
- Output: `outputs/MT_20261116_before_alias.txt` (ZQM002), `outputs/ALV_20261116_before_alias.txt` (ZQM003).
- ZQM002 15 DO skenario **identik baris per baris** dengan suite program asli 12 Nov (`outputs/alias_live_20261112/suite_original.txt`). Data uji alias yang dibuat 13 dan 16 Nov tidak mengubah skenario mana pun.

## Hasil per skenario

Pembanding: golden file `outputs/MT_qm04_C_fix.txt` (19 Okt), nilai SAP `data_inspeksi_sap_gabungan.md` (cocok 103/119), tabel §0.3, dan `seq_check_20261103/ALV_fix.txt` (ZQM003). Kolom NUM berubah karena SEQ_NO di semua DO lama sudah diketahui (bukan regresi).

| Skenario | DO | ZQM002 | ZQM003 | Status | Keterangan |
|---|---|---|---|---|---|
| L-QM01 | 6234 | 10 MIC | ✓ | **BERUBAH (data)** | 5 MIC (ELMD 75, ELTD 110, SHTD 0.43, TSMD 17.5, TSTD 22.5) mengikuti override ZLOG_COA yang diinput TRST-AISYAH 05.11.2026. ZQM003 menampilkan nilai asli + override di kolom NEW_VALUE, sesuai desain |
| L-QM02 | 6235 | 11 MIC | ✓ | **BERUBAH (data)** | Tambah PAABTH00 19.58: mapping SRAABI Thickness ditambah TRST-AISYAH 02.11.2026. MIC lain sama |
| L-QM03 | 6240 | 9 MIC | ✓ | SAMA | |
| L-QM04 | 6241 | 13 MIC | ✓ | SAMA | |
| L-QM05 / 06 | 6242 | 12 MIC | ✓ | **BERUBAH (data)** | SVC2FDNS hilang: mapping SRVC2I baris ini di-flag DELETION oleh TRST-AISYAH 02.11.2026 |
| L-QM07 / 08 | 6243 | 10 MIC | ✓ | SAMA | ZQM003 PEASFDUZ tampil `0`, ZQM002 `0.000` (format saja) |
| L-QM09 | 6244 | 11 MIC | ✓ | **BERUBAH (data)** | Tambah PAABTH00 19.58 (sama dengan L-QM02) |
| L-QM10 | 6245 | 10 MIC | ✓ | **BERUBAH (data)** | Mapping SRGJBI diubah TRST-AISYAH 05.11.2026: PGJBFDNC → PGJBFDCD (0.600), SGJBSTNC → SGJBSTCD (45), tambah PGJBHZ00 (2.04) |
| L-QM11 | 6270 | 12 MIC | ✓ | SAMA | |
| L-QM12 | 6271 | 11 MIC | ✓ | SAMA (diabaikan) | SAABMVTR/SAABO2TR tidak muncul: efek mapping testing Aisyah, sudah disepakati diabaikan |
| L-QM13 | 6272 | 10 MIC | ✓ | **BERUBAH (data)** | 6 MIC lot 040000020690 (TSMD 13.27, TSTD 27.36, ELMD 178, ELTD 72, SHMD 4.90, SHTD 1.37) mengikuti override ZLOG_COA TRST-AISYAH 09.11.2026. ZQM003: nilai asli + NEW_VALUE |
| L-QM14 | semua | — | — | SAMA | Tiap DO dijalankan di sesi sendiri, hasil = cetak sendiri |
| L-QM15 | 6234 | ✓ | ✓ | SAMA | Override ZLOG_COA terpakai di ZQM002 dan tampil di NEW_VALUE ZQM003. Uji layar Print Certificate tetap manual |
| ML-QM01 | 6276 | 14 MIC | ✓ | SAMA | = §0.3 |
| ML-QM02 | 6277 | 14 MIC | ⚠️ | SAMA (ZQM002) | = §0.3. **Temuan ZQM003:** SACBSIIN 106 dan SACBSIOT 106, sedangkan ZQM002 108 dan 107 |
| ML-QM03 | 6278 | 10 MIC | ✓ | SAMA | ZQM003 = `ALV_fix.txt` (OD 2.41, ST 41/51), berbeda dengan ZQM002 2.38, 42/52, sama seperti baseline 3 Nov |
| ML-QM04 | 6279 | 10 MIC | ✓ | SAMA | MVTR/O2TR 0.07 |

**Kesimpulan:** tidak ada REGRESI program. Semua BERUBAH berasal dari data DEV yang diubah TRST-AISYAH (mapping ZMAP_COA 02 dan 05 Nov, override ZLOG_COA 05 dan 09 Nov) setelah golden file dibuat. Golden file **belum** diperbarui, menunggu persetujuan user (§0.4 langkah 5).

## Temuan ZQM003 vs ZQM002 (sudah ada sejak sebelum alias)

ZQM003 (ALV ±162–216) merata-rata nilai **unik** per VBELN + MATNR + MIC (`DELETE ADJACENT DUPLICATES ... COMPARING VBELN MATNR MIC MICMIT`), sedangkan ZQM002 merata-rata per inspection lot (dedup INSLOT + GET_AVG_KEY). Kalau beberapa lot punya nilai sama, bobotnya berbeda. Akibatnya angka ZQM003 bisa berbeda dengan COA yang dicetak:
- DO 6277 (ML-QM02): SACBSIIN 106 vs 108, SACBSIOT 106 vs 107. Terbukti dari QAMR SACBSIIN: lot 050000014309 = 111, 050000014310 = 111, 050000014311 = 101. ZQM003 = (111 + 101) / 2 = **106** (nilai 111 dihitung sekali); ZQM002 = (111 + 111 + 101) / 3 = 107.67 → **108**.
- DO 6278 (ML-QM03): PGLBOD00 2.41 vs 2.38, SGLASTCD 41 vs 42, SGLASTMZ 51 vs 52 (sudah tercatat sebagai baseline ZQM003 3 Nov).

Status 16 Nov: user setuju ini bug. Fix (ZQM003 = nilai print ZQM002, override tetap di NEW_VALUE) sudah di-push ke sandbox-new dan di-deploy user ke DEV AIX (terverifikasi 16 Nov), lihat `docs/FIX_ZQM003_NILAI_20261116.md`.

## Baseline DO uji alias (sebelum alias)

| DO | ZQM002 | ZQM003 | Keterangan |
|---|---|---|---|
| 0085006280 | kosong (STOP) | kosong (STOP) | "Material belum dimapping di ZMAP_COA" karena SRABDI tidak punya mapping. Setelah alias aktif harus lewat jalur alias (kecuali Opsi B2) |
| 0085006281 | 11 MIC SRAABI (PAAB*), nilai 0 | 22 baris (2 roll × 11 MIC), nilai 0 | Baseline untuk AL-12/AL-13: setelah alias aktif harus identik |
