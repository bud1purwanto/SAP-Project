# Implementasi Alias COA (tanpa opsi limit) — Uji Harness DEV AIX, 16 Nov 2026

Perintah user: "execute" untuk logika alias tanpa limit (16 Nov 2026). Patch dibangun dan diuji **in-memory** (GENERATE SUBROUTINE POOL) di Development AIX. **Program DEV tidak diubah.** Sudah di-push ke **sandbox-new** 16 Nov 2026 atas perintah user (lihat §7).

## 1. Objek dan file

| Include | File patch | Asli (DEV 16 Nov) | Baris + / − |
|---|---|---|---|
| ZQMI_COA_TOP | `tests/alias_impl/ZQMI_COA_TOP.abap` | `tests/alias_impl/ZQMI_COA_TOP.orig.abap` | +89 / −1 |
| ZQMI_COA_F01 | `tests/alias_impl/ZQMI_COA_F01.abap` | `…F01.orig.abap` | +676 / −21 |
| ZQMI_COA_F02 | `tests/alias_impl/ZQMI_COA_F02.abap` | `…F02.orig.abap` | +50 / −5 |
| ZQMI_COA_ALV | `tests/alias_impl/ZQMI_COA_ALV.abap` | `…ALV.orig.abap` | +34 / −11 |

Source asli = fetch DEV 16 Nov, identik dengan fetch 12 Nov (dasar rancangan). Harness: `scripts/mt_pool_build2.mjs` (pemetaan baris lewat GNU diff; `UC=1` mengubah MODULE USER_COMMAND_0100 jadi FORM supaya EXEC ikut diuji), runner `tests/alias_impl/runner_alias_impl.abap`.

### Isi perubahan (sesuai RANCANGAN_PROGRAM_ALIAS_ZQM002.md)

- **TOP:** field IT_DATA `COA_MAT, COA_PATH, BATCH_MIC, ALIAS`; IT_MIC1 `COA_MAT, COA_PATH, COA_MIC`; tabel kerja GT_AROLL, GT_AGRP, GT_AMAP, GT_AMIC(_B), GT_ACONV, GT_APLAN, GT_ALOG. `GV_ATINN_ALIAS` memakai deklarasi yang sudah ada.
- **F01 GET_DATA:** AUSP ikut baca ZZALIAS; `PERFORM ALIAS_RESOLVE` sebelum PHASE 3; roll jalur alias → `ALIAS_FILL_ZMAP` (mapping alias, MIC diterjemahkan ke MIC batch), selain itu blok mapping as-is **tidak diubah**; LT_COA_MAP dari GT_AMAP; relabel MIC (baca MIC batch, simpan MIC alias, `BATCH_MIC`); METHOD dari mapping alias; rata-rata berkunci `VBELN + COA_MAT + MIC`, GET_AVG_KEY pakai `BATCH_MIC`; limit LT_COA_MAP by COA_MAT; hook `ALIAS_APPLY_LIMIT` (kosong); SORT by COA_MAT (GET_DATA, START-OF-SELECTION, SELMAPPING); SELMAPPING jalur alias cek GT_AMAP; pesan info `ALIAS_MESSAGE`.
- **F01 FORM baru:** ALIAS_RESOLVE, ALIAS_CONVERT (ZZCODE lalu MAKT, cache), ALIAS_READ_MAP (umum + customer, deskripsi MIC alias dari QPMT), ALIAS_LOAD_PLAN, ALIAS_NORM_DESC, ALIAS_TRANSLATE_GROUP (EXACT/RULE/SUFFIX/DESC/NONE + duplikat), ALIAS_FILL_ZMAP, ALIAS_APPLY_LIMIT, ALIAS_MESSAGE.
- **F02 EXEC:** cek "Tipe film tidak boleh berbeda" per COA_MAT; header alias dari semua roll COA_MAT yang sama; lebar ZZWIDTH dari semua roll kelompok alias. Jalur as-is tidak berubah.
- **ALV ZQM003:** kunci COA_MAT/COA_MIC (LT_UNIQUE, LT_FINAL, LT_SEQ, ZLOG); jalur alias: deskripsi/unit/limit dari baris COA (sama dengan print). Cara hitung ZQM003 (rata-rata nilai unik) **tidak diubah**. Tanpa kolom baru.

## 2. Regresi: program asli vs patch (hasil real, 16 Nov 2026)

Pembanding: pool program asli (`outputs/MT_20261116_orig_exec.txt`) dan acuan before (`MT_20261116_before_alias.txt`, `ALV_20261116_before_alias.txt`). Hasil patch: `outputs/MT_20261116_alias_patch.txt`.

| Skenario | DO | Jalur alias (roll) | ZQM002 | ZQM003 | EXEC (header, lebar, detail) |
|---|---|---|---|---|---|
| L-QM01 / L-QM15 | 0085006234 | NOALIAS 12 | SAMA (10 MIC) | SAMA | SAMA |
| L-QM02 | 0085006235 | NOALIAS 20 | SAMA (11) | SAMA | SAMA |
| L-QM03 | 0085006240 | NOALIAS 49 | SAMA (9) | SAMA | SAMA |
| L-QM04 | 0085006241 | NOALIAS 20 | SAMA (13) | SAMA | SAMA |
| L-QM05 / 06 | 0085006242 | NOALIAS 5 | SAMA (12) | SAMA | SAMA |
| L-QM07 / 08 | 0085006243 | NOALIAS 17 | SAMA (10) | SAMA | SAMA |
| L-QM09 | 0085006244 | NOALIAS 10 | SAMA (11) | SAMA | SAMA |
| L-QM10 | 0085006245 | NOALIAS 14 | SAMA (10) | SAMA | SAMA |
| L-QM11 | 0085006270 | NOALIAS 14 | SAMA (12) | SAMA | SAMA |
| L-QM12 | 0085006271 | NOALIAS 14 | SAMA (11) | SAMA | SAMA |
| L-QM13 | 0085006272 | NOALIAS 23 | SAMA (10) | SAMA | SAMA |
| ML-QM01 | 0085006276 | HSB-18 → NOCONV 12 | SAMA (14) | SAMA | SAMA (header HSB-18) |
| ML-QM02 | 0085006277 | HSS-18 → SRACJI 12 + HSP-18 NOCONV 6 → MIXED 18 | SAMA (14) | SAMA | SAMA (header HSS-18, HSP-18) |
| ML-QM03 | 0085006278 | NOALIAS 10 | SAMA (10) | SAMA | SAMA |
| ML-QM04 | 0085006279 | NOALIAS 10 | SAMA (10) | SAMA | SAMA |
| Uji alias MIXED (AL-12/13) | 0085006281 | 1 alias + 1 tanpa alias → MIXED 2 | SAMA (11) | SAMA | SAMA |
| Uji alias (AL-01/07/11) | 0085006280 | PLE-22 → SRAACI, ALIAS 6 | **BERUBAH (disengaja):** 0 → 9 MIC | 0 → 54 baris | 0 → COA PLE-22 |

ZQM003 dibandingkan penuh: batch, MIC, nilai, lot, deskripsi, limit, urutan SEQ. **0 selisih untuk 16 DO**; hanya DO 6280 yang berubah sesuai tujuan.

**Limit (Lower/Upper):** suite khusus limit (`outputs/LIMIT_20261116_before.txt` vs `LIMIT_20261116_after_alias.txt`): ZQM002 178 MIC dan ZQM003 2.715 baris batch **identik** untuk 16 DO. Acuan limit per MIC ada di `STANDAR_SKENARIO_TESTING_COA.md` §0.6.2.

## 3. DO 0085006280: jalur alias (nilai 0, uji struktur)

- Keenam roll SRAABI + SRABDI → 1 COA material SRAACI, terjemahan 18/18 RULE (9 MIC × 2 tipe).
- EXEC lolos (tidak ada "Tipe film tidak boleh berbeda"), header **PLE-22**, lebar **1,000;500** (dari roll kedua tipe).
- Override customer 1141000514 terpakai: PAACTSTD method "ASTM D 882 (CUST)", limit 26.00–34.00.

| MIC alias | MIC batch wakil | Method | Limit tercetak | Asal limit |
|---|---|---|---|---|
| PAACTH00 | PABDTH00 | ASTM D 374 | 19.40–20.60 | spec lot wakil |
| PAACTSMD | PABDTSMD | ASTM D 882 | 12.00–18.00 | spec lot wakil |
| PAACTSTD | PABDTSTD | ASTM D 882 (CUST) | 26.00–34.00 | mapping customer |
| PAACELMD | PABDELMD | ASTM D 882 | 140.00–230.00 | mapping alias |
| PAACELTD | PABDELTD | ASTM D 882 | 50–80 | spec lot wakil |
| PAACSHMD | PABDSHMD | ASTM D 1204 | 3.00–5.00 | spec lot wakil |
| PAACSHTD | PABDSHTD | ASTM D 1204 | 0.50–2.00 | lower lot wakil, upper mapping |
| PAACHZ00 | PABDHZ00 | ASTM D 1003 | 1.00–1.50 | spec lot wakil |
| PAACG400 | PABDG400 | ASTM D 2457 | 92.00–99 | lower mapping, upper lot wakil |

**Catatan limit sementara (opsi limit belum dipilih QA):** limit = mapping alias kalau terisi; sisi kosong = spec lot wakil (MATNR/lot pertama hasil urutan, di DO ini SRABDI). Ini **berbeda dengan Opsi A** (Opsi A mengisi sisi kosong dari QPMK MIC alias: Thickness 21.34–22.66, SHTD lower 0.00, Gloss upper 100). Hook `ALIAS_APPLY_LIMIT` sudah ada; isi sesuai opsi QA.

## 4. Uji nilai gabungan dengan data real (harness saja, tidak disimpan)

DEV tidak punya DO dua tipe dengan hasil inspeksi, jadi nilai diuji satu tipe (AL-03): semua roll DO 76 / 77 dipaksa alias HSS-18 → SRACJI, mapping SRACJI dititipkan di harness (14 MIC, struktur sama dengan SRACBI). File: `outputs/test_alias_force_HSS18_*.txt`.

| Skenario | DO | MIC | Patch (jalur alias) | Acuan §0.3 |
|---|---|---|---|---|
| ML-QM01 | 0085006276 | TH00 / TSMD / TSTD / ELMD / ELTD | 17.95 / 14.51 / 28.15 / 160 / 49 | 17.95 / 14.51 / 28.15 / 160 / 49 |
| ML-QM01 | 0085006276 | SHMD / SHTD / HZ00 / G400 | 4.84 / 7.01 / 2.21 / 88 | 4.84 / 7.01 / 2.21 / 88 |
| ML-QM01 | 0085006276 | SIIN / SIOT / SSIN / SSOT / FDIN | 111 / 110 / 294 / 267 / 0.265 | 111 / 110 / 294 / 267 / 0.265 |
| ML-QM02 | 0085006277 | TH00 / TSMD / TSTD / ELMD / ELTD | 17.87 / 15.81 / 25.75 / 185 / 56 | 17.87 / 15.81 / 25.75 / 185 / 56 |
| ML-QM02 | 0085006277 | SHMD / SHTD / HZ00 / G400 | 6.93 / 8.83 / 1.72 / 91 | 6.93 / 8.83 / 1.72 / 91 |
| ML-QM02 | 0085006277 | SIIN / SIOT / SSIN / SSOT / FDIN | 108 / 107 / 294 / 267 / 0.275 | 108 / 107 / 294 / 267 / 0.275 |

- Hasil: **14/14 MIC sama** di kedua DO, 18 dan 12 roll jalur ALIAS, 14 MIC RULE.
- Catatan uji: run pertama FDIN = 0 karena MIC titipan `SACJFDIN` tidak ada di master QPMK (desimal 0). Dengan MIC yang ada di master (`SACBFDIN`) nilainya 0.275 / 0.265. Di produksi MIC mapping selalu MIC master (F4 ZMAP_COA), jadi ini efek data titipan.
- Gabungan **dua tipe dengan nilai** belum bisa dibuktikan dengan data real; logikanya sama (kunci COA_MAT, GET_AVG_KEY per BATCH_MIC) dan strukturnya terbukti di DO 6280.

## 5. Uji fallback (harness)

| Uji | DO | Pemicu | Jalur roll | Hasil vs program asli |
|---|---|---|---|---|
| NOMAP (AL-06) | 0085006277 | alias HSS-18 dipaksa, SRACJI tanpa mapping | NOMAP 18 | ZQM002, ZQM003, EXEC **SAMA** |
| NONE (AL-04) | 0085006277 | mapping titipan + MIC `PACJXX99` tanpa padanan | NONE 18, log `PACJXX99 NONE` | ZQM002, ZQM003, EXEC **SAMA** |
| NOCONV + mapping batch kosong (AL-05/AL-10) | 0085006280 | alias `XX-99` dipaksa | NOCONV | STOP "Material belum dimapping", sama dengan program asli |
| NOCONV alami | 0085006276 | HSB-18 | NOCONV | SAMA (tabel §2) |
| MIXED alami | 0085006277, 0085006281 | 2 alias / alias + tanpa alias | MIXED | SAMA (tabel §2) |

## 6. Yang belum

- Opsi limit (A/B1/B2/C): menunggu QA; hook `ALIAS_APPLY_LIMIT` kosong.
- AL-08 (pilih roll alias + roll as-is sekaligus) dan AL-09 (terjemahan DESC) belum diuji; data DEV semua RULE.
- Syntax check resmi (SE38) belum: yang terbukti hanya GENERATE SUBROUTINE POOL lolos dan runtime berjalan di 17 DO.

## 7. Push ke sandbox-new (16 Nov 2026)

Perintah user: "ngikut sandbox saja karna terbaru, silahkan push".

| Langkah | Hasil |
|---|---|
| Pull sandbox-new tepat sebelum push | TOP 381, F01 4848, F02 1118, ALV 432 baris. Isi logika **identik** dengan DEV; satu-satunya beda baris 2 komentar header (`ZQMI_COA_*` vs `ZQMI_CERTIFICATE_*`) di TOP/F01/F02. Tidak ada perubahan pihak lain |
| Backup | `outputs/ZQMI_COA_{TOP,F01,F02,ALV}_sandbox-new_backup_before_alias_20261116.abap` |
| File yang di-push | `src/alias_sbx/ZQMI_COA_*.abap` = patch harness + header sandbox-new |
| Push (`Z_RFC_PROGRAM_UPDATE`, $TMP) | TOP 469, F01 5503, F02 1163, ALV 455 baris, semua `EV_SUCCESS = X` |
| Syntax check ZQMI_COA (`RS_SYNTAX_CHECK`) | RC 0 |
| Readback | Jumlah baris dan isi **identik** dengan file yang dikirim (4/4) |
| Run GET_DATA di sandbox-new (read-only) | Tanpa dump: DO 0085004703 (SRACBI), 0085004573 (SREWEI), 0085000306 (SRAAAI). DO skenario DEV tidak ada di sandbox-new, jadi pembuktian fungsi tetap dari harness DEV (§2–§5) |

Rollback: push ulang file backup di atas dengan `scripts/sbx_push_check.mjs`. Transport ke DEV/QAS/PRD dikerjakan user / tim Basis.

## 8. Rollback alias dari sandbox-new (16 Nov 2026)

Atas permintaan user, patch alias di sandbox-new dikembalikan ke backup `outputs/ZQMI_COA_*_sandbox-new_backup_before_alias_20261116.abap` (RC 0, readback = backup), lalu diganti fix ZQM003 (`docs/FIX_ZQM003_NILAI_20261116.md`). Patch alias tetap di `tests/alias_impl/` dan `src/alias_sbx/`, perlu disesuaikan dengan fix ZQM003 sebelum di-push lagi.

## 9. Alias dipasang kembali di atas fix ZQM003 (16 Nov 2026)

Perintah user: "ok sekarang pasang kembali alias". Base = DEV AIX setelah deploy fix ZQM003 (`outputs/ZQMI_COA_*_Development AIX_after_zqm003fix.abap`); sandbox-new identik dengan DEV sebelum push.

**Rebase** (`git merge-file` patch alias → base baru), hasil di `tests/alias_v2/` (file `*.base.abap` = base, `*.abap` = alias v2):

| Include | Konflik | Penyelesaian |
|---|---|---|
| TOP | IT_DATA akhir struktur | `QM_CMICMIT` + field alias (COA_MAT, COA_PATH, BATCH_MIC, ALIAS) dua-duanya |
| F01 | sebelum blok ZLOG_COA | `ALIAS_APPLY_LIMIT` dulu, lalu `IT_DATA-QM_CMICMIT = IT_DATA-CMICMIT` |
| F01 | akhir file | Ambil versi alias; baris `ENDFORM. "GET_BATCH_COL_CFG` yang tadinya menyatu dengan komentar FORM berikutnya dipisah (hanya komentar, tanpa efek) |
| F02 | — | Otomatis |
| ALV | RPT_BUILD | Normalisasi `COA_MAT`/`COA_MIC` alias tetap; `LT_FINAL` dari `IT_DATA` (fix ZQM003) dengan kunci `MATNR = IT_DATA-COA_MAT`, `MIC = IT_DATA-MIC` (MIC COA) |

**Uji harness DEV** (in-memory):

| Uji | Pembanding | Hasil |
|---|---|---|
| Regresi 17 DO, ZQM002 + EXEC + ZQM003 (`outputs/MT_20261116_alias_v2_reg.txt`) | DEV terverifikasi `MT_20261116_dev_after_zqm003fix.txt` | 16 DO **identik**. DO 6280: dulu kosong (STOP), sekarang COA alias PLE-22 / SRAACI |
| Detail alias DO 6280, 6281, 6277 (`MT_20261116_alias_v2_detail.txt`) | Run alias kemarin `MT_20261116_alias_patch.txt` | ZQM002, EXEC, #X/#R/#M/#L identik (DO 6280: 18 MIC RULE, header PLE-22, width 1,000;500, limit dan method sama). Beda hanya ZQM003 sesuai fix: nilai 0 → `0.00`/`0.000`, DO 6277 SACBSIIN/SIOT 106 → 108/107 |
| Nilai jalur alias paksa HSS-18 DO 6276/6277 (`outputs/test_alias_v2_force_HSS18.txt`) | `test_alias_force_HSS18_*.txt` | ZQM002 + EXEC identik (14/14 = §0.3). ZQM003 alias DO 6277 SACJSIIN/SIOT = 108/107 = print |

**Push sandbox-new**:

| Langkah | Hasil |
|---|---|
| Backup sebelum push | `outputs/ZQMI_COA_*_sandbox-new_backup_before_alias_v2_20261116.abap` (= DEV dengan fix ZQM003) |
| Push | TOP 470, F01 5508, F02 1163, ALV 399; syntax RC 0 tiap include |
| Readback | Identik 4/4. File push juga di `src/alias_v2_sbx/` |

Rollback: push ulang backup `*_before_alias_v2_20261116.abap`. Limit alias masih sementara (hook `ALIAS_APPLY_LIMIT` kosong, menunggu QA). DEV AIX belum ada alias; transport oleh user / Basis.

## 10. Verifikasi setelah user deploy alias_v2 ke DEV AIX (16 Nov 2026)

| Cek | Hasil |
|---|---|
| Source DEV vs `tests/alias_v2/` | TOP 470, F01 5508, F02 1163, ALV 399: **identik**. Program utama ZQMI_COA tidak berubah |
| Program DEV apa adanya, 17 DO, ZQM002 + EXEC + ZQM003 (`outputs/MT_20261116_dev_after_alias_v2.txt`) | Tanpa error/dump; **identik** dengan harness alias_v2 |
| Detail alias DO 6280/6281/6277 (`outputs/MT_20261116_dev_after_alias_v2_detail.txt`) | **Identik** dengan harness alias_v2 |
| Skenario lama vs DEV sebelum alias (`MT_20261116_dev_after_zqm003fix.txt`) | L-QM01–15, ML-QM01–04 dan DO 6281: **0 selisih** (nilai, limit, EXEC, ZQM003). Yang berubah hanya DO 6280 (uji alias): STOP → COA alias PLE-22 |
| ZQM002 + EXEC vs program asli sebelum semua perubahan (`MT_20261116_orig_exec.txt`) | 0 selisih (kecuali DO 6280) |
