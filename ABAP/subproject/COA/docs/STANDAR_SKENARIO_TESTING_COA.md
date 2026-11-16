# Knowledge Base & Baseline Skenario Testing COA (Certificate of Analysis)

Dokumen ini merupakan referensi resmi (*Golden Knowledge Base*) skenario pengujian Program Cetak COA (`ZQMI_COA` / `ZQMI_COA_F01` / `ZQM002`). Ada **dua set skenario** yang nomornya sama-sama dimulai dari `QM01`, jadi selalu tulis dengan prefix set-nya:

| Set | Prefix | Isi | Sumber Excel |
| :--- | :--- | :--- | :--- |
| **Skenario Lama (Baseline)** | `L-QM01` – `L-QM15` | Basefilm/Converting normal, change grade, secondary slitting, join, multi-DO, edit value | `docs/SKENARIO/SEMUA SKENARIO LAMA SEBELUM + MULTI LEVEL.xlsm` (asal: *Copy of Scenario Test COA v3.xlsm*) |
| **Skenario Baru Multi-Level** | `ML-QM01` – `ML-QM04` | Alias, multi-alias, produksi 4 tahap, outsource base film | `docs/SKENARIO/SKENARIO BARU CONVERTING LEVEL MUTLI.xlsm` (versi terbaru user punya sheet `QM04` & `QM04 all (2)`; file di repo masih versi lama tanpa sheet QM04) |

Setiap pembaruan kode ABAP COA **wajib** dibandingkan dengan **semua** skenario di bawah (lihat **BAGIAN 0**) agar **Zero Regression** pada skenario lama dan akurat pada skenario baru.

---

## 📌 BAGIAN 0: Peta Skenario → DO → Baseline (Checklist Regresi)

### 0.1 Daftar DO uji lengkap

| Skenario | Judul singkat | DO (DEV) | Material | Baseline nilai | Status data |
| :--- | :--- | :---: | :---: | :--- | :--- |
| L-QM01 | BF normal, 1 JR sama dalam 1 DO | `0085006234` | SRCADI | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM02 | BF normal, beda JR dalam 1 DO | `0085006235` | SRAABI | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM03 | Conv normal, 1 JR Conv sama dalam 1 DO | `0085006240` | SRGIDI | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM04 | Conv normal, beda JR Conv dalam 1 DO | `0085006241` | SREWEI | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM05 | SR BF inspeksi dulu → change grade | `0085006242` | SRVC2I | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM06 | SR BF change grade dulu → inspeksi | `0085006242` | SRVC2I | Golden file + data_inspeksi | ✅ Lengkap (DO sama dengan L-QM05) |
| L-QM07 | SR Conv inspeksi dulu → change grade | `0085006243` | SREASI | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM08 | SR Conv change grade dulu → inspeksi | `0085006243` | SREASI | Golden file + data_inspeksi | ✅ Lengkap (DO sama dengan L-QM07) |
| L-QM09 | SR BF di secondary slitting | `0085006244` | SRAABI | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM10 | SR Conv di secondary slitting | `0085006245` | SRGJBI | Golden file + data_inspeksi | ✅ Lengkap |
| L-QM11 | Join 2 input JR (1 DO 1 JR) + **mapping khusus customer** ATLANTIC BIRURAYA, PT. (`1141000026`) | `0085006270` | SRAABI | Golden file + data_inspeksi | ✅ 12 MIC cocok dengan ALV user; urutan ikut `SEQ_NO` mapping customer |
| L-QM12 | Join 2 JR (1 DO 2 JR), cari inspeksi seq ≥ 20 | `0085006271` | SRAABI | Golden file + data_inspeksi | ✅ 11 MIC cocok; MVTR/O2TR diabaikan (mapping diubah Aisyah saat testing) |
| L-QM13 | 1 DO 3 JR beda line | `0085006272` | SREASI | Golden file + data_inspeksi | ✅ 10 MIC cocok dengan ALV user (item 20) |
| L-QM14 | Banyak DO sekali cetak | Semua DO di tabel ini | — | Hasil per DO = hasil saat dicetak sendiri | ✅ Diuji lewat run suite (1 sesi RFC per DO) dan ALV multi-DO |
| L-QM15 | Ubah value di Print Certificate | `0085006234` (`ZLOG_COA`, `PCADELMD = 75`) | SRCADI | Nilai editan tidak tertimpa saat print | ⚠️ Uji manual di layar |
| **ML-QM01** | Alias, 1 DO 1 alias (Customer Export) | `0085006276` | SRACBI | Golden file (§0.3) | ✅ Lengkap |
| **ML-QM02** | 1 DO lebih dari 1 alias (Customer Export) | `0085006277` | SRACBI | Golden file (§0.3) | ✅ Lengkap |
| **ML-QM03** (A/B/C) | Produksi 4 tahap BF → Coat → Metz → Coat (juga contoh **tanpa alias**) | `0085006278` | SRGLBI | Golden file + BAGIAN 1 | ✅ Lengkap |
| **ML-QM04** | Outsource base film SR*X (tanpa JR BF di SAP) | `0085006279` | SREC7I | Golden file + §0.3 | ✅ Lengkap (baseline = hasil program DEV 11 Nov) |

> Tabel ini dipetakan lewat batch: sheet `ML-QM01`/`ML-QM02` di Excel memakai batch BF `0000406862`–`0000406919`, sesuai dengan DO 76/77 (SR `0000406885`). Sheet `ML-QM03` memakai batch `0000406686`–`0000406852`, yaitu silsilah DO 78. Di Excel sendiri tidak tertulis nomor DO-nya.

### 0.2 Golden baseline file

- **Acuan aktif (16 Nov 2026)**: §0.6 + [`outputs/MT_20261116_before_alias.txt`](../outputs/MT_20261116_before_alias.txt) (ZQM002) dan [`outputs/ALV_20261116_before_alias.txt`](../outputs/ALV_20261116_before_alias.txt) (ZQM003). Golden lama di bawah disimpan untuk riwayat.
- **Golden lama — hasil program (semua DO)**: [`outputs/MT_qm04_C_fix.txt`](../outputs/MT_qm04_C_fix.txt) (19 Okt 2026). Format per baris: `|VBELN|MATNR|CHK|NUM|MIC|NILAI|INSLOT`.
  - File ini dipilih, bukan `MT_v2_DU.txt` (17 Okt). Di `MT_v2_DU.txt`, DO 43 `PEASFDUZ` bernilai `0.543`, padahal `data_inspeksi` menyebut `-` (belum diisi, jadi seharusnya `0.000`).
- **Nilai inspeksi SAP (screenshot)**: [`docs/data_inspeksi_sap_gabungan.md`](data_inspeksi_sap_gabungan.md) untuk DO 34 sampai 72. DO 76–79 **tidak** ada di sini.
- **Urutan MIC (SEQ_NO)**: [`outputs/seq_check_20261103/ALV_fix.txt`](../outputs/seq_check_20261103/ALV_fix.txt) (fix ZQM003, 3 Nov 2026).
  - Golden file Oktober masih berisi `NUM = 999` untuk DO lama. Kolom `NUM` untuk DO tersebut **jangan** dianggap regresi jika berubah mengikuti `SEQ_NO` mapping.

### 0.3 Nilai baseline skenario baru (dari golden file)

**ML-QM01: DO `0085006276` (SRACBI, alias `HSB-18`)**. Lot JR `040000021076`, lot SR `050000014308`:

| SEQ | MIC | Nilai | | SEQ | MIC | Nilai |
| :-: | :--- | ---: | - | :-: | :--- | ---: |
| 1 | PACBTH00 | 17.95 | | 8 | SACBHZ00 | 2.21 |
| 2 | PACBTSMD | 14.51 | | 9 | SACBG400 | 88 |
| 3 | PACBTSTD | 28.15 | | 10 | SACBSIIN | 111 |
| 4 | PACBELMD | 160 | | 11 | SACBSIOT | 110 |
| 5 | PACBELTD | 49 | | 12 | PACBSSIN | 294 |
| 6 | SACBSHMD | 4.84 | | 13 | PACBSSOT | 267 |
| 7 | SACBSHTD | 7.01 | | 14 | SACBFDIN | 0.265 |

**ML-QM02: DO `0085006277` (SRACBI, alias per batch `HSS-18` × 12 roll dan `HSP-18` × 6 roll)**. Lot JR `040000021077`, lot SR `050000014311`:

| SEQ | MIC | Nilai | | SEQ | MIC | Nilai |
| :-: | :--- | ---: | - | :-: | :--- | ---: |
| 1 | PACBTH00 | 17.87 | | 8 | SACBHZ00 | 1.72 |
| 2 | PACBTSMD | 15.81 | | 9 | SACBG400 | 91 |
| 3 | PACBTSTD | 25.75 | | 10 | SACBSIIN | 108 |
| 4 | PACBELMD | 185 | | 11 | SACBSIOT | 107 |
| 5 | PACBELTD | 56 | | 12 | PACBSSIN | 294 |
| 6 | SACBSHMD | 6.93 | | 13 | PACBSSOT | 267 |
| 7 | SACBSHTD | 8.83 | | 14 | SACBFDIN | 0.275 |

- Header sertifikat memakai alias batch pertama yang terisi. Batch List menampilkan alias per batch. Untuk Export, Product Name bisa diubah di pop-up header.

**ML-QM03: DO `0085006278` (SRGLBI, tanpa alias, Product Name = `MB51-50`)**:

| SEQ | MIC | Nilai | Lot | Tahap |
| :-: | :--- | ---: | :---: | :--- |
| 1–4 | PAH8TSMD / PAH8TSTD / PAH8ELMD / PAH8ELTD | 0.00 / 0.00 / 0 / 0 | `040000021013` | 1 · JR BF `JRAH8I` |
| 5–6 | PGLASHMD / PGLASHTD | 2.62 / 0.34 | `040000021042` | 3 · JR Metz `JRGLAI` |
| 7–8 | SGLASTCD / SGLASTMZ | 42 / 52 | `050000014297` | 3 · SR Metz `SRGLAI` |
| 9 | PGLAG6CD | 636 | `040000021042` | 3 · JR Metz `JRGLAI` |
| 10 | PGLBOD00 | 2.38 (Excel: 2.378) | `040000021052` | 4 · JR Coat `JRGLBI` |

- Nilai per batch di Batch List (mis. `0000406850`: OD `2.41`, ST `41/51`) memang berbeda dengan rata-rata DO. Itu **bukan** regresi.

**ML-QM04: DO `0085006279` (SREC7I, outsource base film)**. Mapping: SR Conv, JR Conv, SR BF (tidak ada JR BF). JR Conv `0000407183` (`JREC7I`). SR BF outsource `SRVLCX` `0000407171`–`0000407174`. Product Name `MZUBD-18`.

| SEQ | Item | MIC | Deskripsi | Lower | Upper | Out Limit (ALV) | ALV user (sebelum input hasil) | **Baseline (program DEV 11-11)** | Lot (harness) |
| :-: | :-: | :--- | :--- | ---: | ---: | :-: | ---: | ---: | :---: |
| 1 | 10 | SVLCTSMD | Tensile Strength MD | 12.00 | 0.00 | X | 16.15 | 16.15 | `050000014331` |
| 2 | 10 | SVLCTSTD | Tensile Strength TD | 22.00 | 0.00 | X | 24.17 | 24.17 | `050000014331` |
| 3 | 10 | SVLCELMD | Elongation MD | 0 | 300 | | 237 | 237 | `050000014331` |
| 4 | 10 | SVLCELTD | Elongation TD | 0 | 80 | | 73 | 73 | `050000014331` |
| 5 | 10 | SVLCSHMD | Shrinkage MD | 0.00 | 5.00 | | 0.00 | 0.00 | `050000014331` |
| 6 | 10 | SVLCSHTD | Shrinkage TD | 0.00 | 4.00 | | 0.00 | 0.00 | `050000014331` |
| 7 | 20 | SEC7STCD | Surface Tension Corona side | 38 | 42 | | 39 | 39 | `050000014339` |
| 8 | 20 | PEC7FDCD | COF Corona Side Dyn | 0.300 | 0.800 | | 0.540 | 0.540 | `040000021127` |
| 9 | 20 | SEC7MVTR | MVTR | 0.05 | 0.15 | X | 0.00 | **0.07** | `050000014339` |
| 10 | 20 | SEC7O2TR | O2TR | 0.05 | 0.15 | X | 0.00 | **0.07** | `050000014339` |

Catatan ML-QM04 (perlu dikonfirmasi):
- **MVTR / O2TR: baseline = `0.07` (ikut program, disepakati user 2026-11-11).** Hasil barrier diinput oleh **TRST-AISYAH** pada 05.11.2026, untuk lot SREC7I `050000014335`–`…339`, dan tidak pernah diubah. Screenshot ALV `0.00` / X diambil sebelum hasil itu diinput. `ZLOG_COA` DO 79 kosong.
  - Catatan teknis (tidak dianggap bug): `0.07` = nilai lot `…339` ÷ 2. Rata-rata sederhana lot item 20 akan ≈ 0.11 / 0.12. Kalau suatu saat program berubah dan nilai ini ikut berubah, laporkan sebagai **BERUBAH**.
  - Batch DO: item 10 = `0000407199`–`…202`, item 20 = `0000407207`–`…212`. Lot SR BF outsource `050000014330`–`…333` = batch `0000407171`–`…174` (SRVLCX).
- **Tensile MD/TD bertanda Out Limit `X`** padahal nilainya ≥ lower. Penyebabnya upper limit `0.00` di mapping. Perlu dipastikan apakah upper `0` berarti "tanpa batas atas" (jadi flag ini salah) atau mapping-nya yang belum diisi.
- Lot di harness (`050000014331`, `040000021127`) berbeda dengan slide flow internal (`050000014330`, `040000021124`). Penyebabnya, program memilih lot SR/JR saudara. Pastikan lot mana yang benar sesuai Excel.

**Catatan L-QM11 – L-QM13 (dari screenshot ALV DEV, sheet `QM11-85006270`, `QM12-85006271`, `QM13-85006272`)**
- **L-QM11 (DO 70)**: memakai **mapping khusus customer** ATLANTIC BIRURAYA, PT. (`1141000026`) di ZQM001, dengan Mapping for Get Insp. = `JR Base Film` dan Sequence 1..n. Urutan tampil di ALV: TH00, TSMD, TSTD, ELMD, ELTD, SHMD, SHTD, HZ00, G400, STTR, FDNT, FDTR. Out Limit `X`: Thickness 22.40 (> 20.60) dan Gloss 89 (< 90).
- **L-QM12 (DO 71)**: ALV user hanya menampilkan 11 MIC, sedangkan golden file punya 13 MIC (ada `SAABMVTR 0.58` dan `SAABO2TR 69.50`, lot `050000014265`). **Diabaikan (keputusan user 2026-11-11):** penyebabnya mapping diubah oleh Aisyah saat testing (terlacak 16 Nov: mapping customer 1141100304 untuk SRAABI di-flag DELETION 05.11.2026, sehingga DO 71 memakai mapping umum yang tidak punya MVTR/O2TR, lihat §0.6.1). Jika `SAABMVTR`/`SAABO2TR` muncul atau hilang di hasil regresi DO 71, jangan dilaporkan sebagai REGRESI. Cukup dicatat sebagai "efek mapping testing".
- **L-QM13 (DO 72, item 20)**: Out Limit `X` pada TSMD, TSTD, ELMD, ELTD, SHMD, SHTD. Ini memang nilai lot `040000020690` (out of spec), bukan bug.
- Tab **`QM16`** dan **`QM17`** di Excel: **di-skip** dulu (keputusan user 2026-11-11), tidak termasuk regresi.

### 0.4 Prosedur wajib saat ada perubahan kode COA

1. Ambil ulang source DEV AIX terbaru. Uji patch lewat **subroutine pool** (`tests/mt_pool_*.abap` + `tests/mt_harness_final.abap`), tanpa mengubah program asli.
2. Jalankan suite untuk **semua DO** di §0.1 (satu sesi RFC per DO):
   ```bash
   DOS="0085006234 0085006235 0085006240 0085006241 0085006242 0085006243 0085006244 0085006245 0085006270 0085006271 0085006272 0085006276 0085006277 0085006278 0085006279" node scripts/mt_run_suite.mjs tests/mt_harness_final.abap outputs/MT_<tgl>_<nama>.txt "Development AIX"
   ```
3. Bandingkan hasilnya:
   - dengan acuan aktif: `diff outputs/MT_20261116_before_alias.txt outputs/MT_<tgl>_<nama>.txt` (harus 0 selisih untuk 15 DO skenario), lalu cek nilai/MIC/lot per skenario di §0.6. ZQM003: `diff outputs/ALV_20261116_before_alias.txt outputs/ALV_<tgl>_<nama>.txt`
   - dengan nilai SAP: `python3 scripts/mt_compare_expected.py outputs/MT_<tgl>_<nama>.txt`
   - untuk ML-QM01–03, cocokkan dengan tabel §0.3
4. Laporkan per skenario (L-QM01…L-QM15, ML-QM01…ML-QM04) dengan status **SAMA / BERUBAH (disengaja) / REGRESI**. Setiap perbedaan harus disertai alasannya.
5. Kalau perubahan memang disengaja dan sudah disetujui, perbarui acuan (§0.6 + file acuan aktif), lalu catat tanggalnya di §0.5. Kalau selisih berasal dari data (mapping/ZLOG/hasil inspeksi diubah tim functional), catat nilai sebelum dan sesudah, siapa, dan kapan di §0.6.1 dan tabel §0.6.2.

### 0.5 Riwayat baseline

| Tanggal | Perubahan | Dampak ke baseline |
| :--- | :--- | :--- |
| 2026-10-16 | Multi-level dynamic genealogy (DO 78) | Tambah ML-QM03 |
| 2026-10-19 | Fix QM04/QM07 (`MT_qm04_C_fix.txt`) | Jadi golden file |
| 2026-11-03/04 | ZQM003 urutan `SEQ_NO` + DO-or-date (pushed sandbox-new) | Kolom `NUM` mengikuti `SEQ_NO`; acuan `seq_check_20261103/ALV_fix.txt` |
| 2026-11-11 | L-QM11/12/13 = DO 70/71/72 (dari sheet Excel user) | Tidak ada perubahan nilai |
| 2026-11-11 | Peta dua set skenario (L-QM vs ML-QM) + DO 76–79; ML-QM04 = outsource DO 79 | Baseline DO 79 (`outputs/MT_ml_qm04_do79_dev_20261111.txt`) ditambahkan ke golden file `MT_qm04_C_fix.txt`; MVTR/O2TR = 0.07 ikut program (hasil input TRST-AISYAH 05.11.2026) |
| 2026-11-16 | Regresi "before" alias (program tidak diubah), laporan `docs/REGRESI_BEFORE_ALIAS_20261116.md` | Tidak ada regresi program. DO 34/35/42/44/45/72 BERUBAH karena data DEV diubah TRST-AISYAH (mapping 02 & 05 Nov, ZLOG 05 & 09 Nov). Acuan baru §0.6 (nilai asli + override + log mapping), golden aktif = `MT_20261116_before_alias.txt`. Temuan: ZQM003 DO 77 SI 106 vs ZQM002 108/107 |
| 2026-11-16 | Patch alias tanpa limit (harness DEV, belum push), laporan `docs/IMPLEMENTASI_ALIAS_HARNESS_20261116.md` | 15 DO skenario + DO 6281: ZQM002, ZQM003, EXEC **0 selisih** vs program asli. DO 6280 berubah sesuai tujuan (COA alias PLE-22). Nilai jalur alias (paksa HSS-18, DO 76/77) 14/14 = §0.3 |


### 0.6 Data acuan per skenario (before alias, 16 Nov 2026) — **acuan compare utama**

**Default testing = hasil real** (keputusan user 16 Nov 2026): bandingkan dengan kolom **Nilai asli** (hasil inspeksi SAP, tanpa override) per skenario/DO/MIC/lot. Override ZLOG_COA dan perubahan mapping **hanya diuji kalau user menyebut secara eksplisit**; selisih yang berasal dari keduanya dilaporkan terpisah, bukan sebagai selisih hasil. Diambil dari program DEV yang aktif 16 Nov 2026 (harness read-only, source = fetch 12 Nov), file mentah `outputs/MT_20261116_before_alias.txt` (ZQM002) dan `outputs/ALV_20261116_before_alias.txt` (ZQM003). Laporan: `docs/REGRESI_BEFORE_ALIAS_20261116.md`.

Arti kolom:
- **Nilai asli**: nilai dari hasil inspeksi SAP tanpa override (untuk MIC yang di-override diambil dari golden 19 Okt; sama dengan `data_inspeksi_sap_gabungan.md` dan dengan kolom nilai ZQM003).
- **Override ZLOG_COA**: nilai yang diketik user di Print Certificate (VALUE2), siapa dan kapan. ZQM002 mencetak nilai ini; ZQM003 menampilkannya di kolom NEW_VALUE.
- **ZQM003**: `=` sama dengan print, `= asli` sama dengan nilai asli (override ada di NEW_VALUE), angka lain = berbeda (lihat 0.6.3).
- Baris ~~coret~~: MIC yang dulu ada di golden 19 Okt tapi sekarang tidak tampil karena mapping berubah.

#### 0.6.1 Log perubahan data DEV setelah golden 19 Okt

| Tanggal | User | Objek | Perubahan | Skenario terdampak |
|---|---|---|---|---|
| 02.11.2026 | TRST-AISYAH | ZMAP_COA SRAABI (umum) | Tambah PAABTH00 (SEQ 001), SEQ_NO MIC lain diisi ulang | L-QM02, L-QM09 (MIC baru Thickness 19.58) |
| 02.11.2026 | TRST-AISYAH | ZMAP_COA SRVC2I (umum) | SVC2FDNS di-flag DELETION | L-QM05/06 (SVC2FDNS 0.147 tidak tampil) |
| 02.11.2026 | TRST-AISYAH | ZMAP_COA semua material skenario lama | SEQ_NO diisi (sebelumnya 999) | Kolom SEQ semua L-QM (bukan regresi) |
| 05.11.2026 | TRST-AISYAH | ZMAP_COA SRGJBI (umum) | PGJBFDNC, SGJBSTNC di-flag DELETION; tambah PGJBHZ00 (008), SGJBSTCD (009), PGJBFDCD (010) | L-QM10 |
| 05.11.2026 | TRST-AISYAH | ZMAP_COA SRAABI customer 1141100304 | Semua 13 baris di-flag DELETION → DO 71 pakai mapping umum | L-QM12 (SAABMVTR/SAABO2TR tidak tampil) |
| 05.11.2026 | TRST-AISYAH | ZLOG_COA DO 0085006234, lot 040000020662 | Override 5 MIC (ELMD, ELTD, SHTD, TSMD, TSTD) | L-QM01, L-QM15 |
| 09.11.2026 | TRST-AISYAH | ZLOG_COA DO 0085006272, lot 040000020690 | Override 6 MIC (TSMD, TSTD, ELMD, ELTD, SHMD, SHTD) | L-QM13 |
| 13 & 16.11.2026 | Claude (TRSTDEV) | ZMAP_COA SRAACI baru, ZZALIAS 7 roll, DO 6280/6281 | Data uji alias, lihat `docs/DATA_UJI_ALIAS_DEV_20261113.md` | Tidak ada (skenario di atas identik dengan 12 Nov) |

#### 0.6.2 Nilai dan limit per skenario

Kolom **Lower / Upper** = limit yang tercetak di COA (ZQM002, setelah limit mapping ZMAP_COA). **ZQM003 limit** `=` kalau sama dengan ZQM002; kalau berbeda ditulis limitnya. Per 16 Nov 2026 semua 178 MIC sama. Sumber: `outputs/LIMIT_20261116_before.txt`; hasil after patch alias `outputs/LIMIT_20261116_after_alias.txt` identik untuk semua DO di tabel ini.


#### L-QM01, L-QM15: DO `0085006234` (SRCADI), customer 1141000514, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PCADELMD | `040000020662` | 0 | 75 (TRST-AISYAH 05.11.2026) | **75** | 70 | 150 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 2 | PCADELTD | `040000020662` | 0 | 110 (TRST-AISYAH 05.11.2026) | **110** | 60 | 120 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 3 | PCADSHMD | `040000020662` | 1.36 |  | **1.36** | 1.00 | 3.00 | = | = |  |
| 4 | PCADSHTD | `040000020662` | 0.81 | 0.43 (TRST-AISYAH 05.11.2026) | **0.43** | 0.00 | 0.50 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 5 | PCADHZ00 | `040000020662` | 2.95 |  | **2.95** | 1.50 | 3.00 | = | = |  |
| 6 | PCADG400 | `040000020662` | 127 |  | **127** | 120 | 140 | = | = |  |
| 7 | PCADSTTR | `040000020662` | 58 |  | **58** | 55 | 58 | = | = |  |
| 8 | PCADFDNT | `040000020662` | 0.480 |  | **0.480** | 0.200 | 0.600 | = | = |  |
| 9 | PCADTSMD | `040000020662` | 0.00 | 17.5 (TRST-AISYAH 05.11.2026) | **17.5** | 16.00 | 26.00 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 10 | PCADTSTD | `040000020662` | 0.00 | 22.5 (TRST-AISYAH 05.11.2026) | **22.5** | 18.00 | 30.00 | = asli | = | ZQM003 kolom NEW_VALUE = override |

#### L-QM02: DO `0085006235` (SRAABI), customer 1800000002, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAABTH00 | `040000020753` | 19.58 |  | **19.58** | 19.40 | 20.60 | = | = | MIC baru: mapping SRAABI ditambah TRST-AISYAH 02.11.2026 |
| 2 | PAABTSMD | `040000020753` | 12.92 |  | **12.92** | 11.00 | 18.00 | = | = |  |
| 3 | PAABTSTD | `040000020753` | 27.71 |  | **27.71** | 22.00 | 35.00 | = | = |  |
| 4 | PAABELMD | `040000020753` | 151 |  | **151** | 120 | 240 | = | = |  |
| 5 | PAABELTD | `040000020753` | 46 |  | **46** | 30 | 90 | = | = |  |
| 6 | PAABSHMD | `040000020753` | 4.33 |  | **4.33** | 3.00 | 5.00 | = | = |  |
| 7 | PAABSHTD | `040000020753` | 2.05 |  | **2.05** | 0.00 | 3.00 | = | = |  |
| 8 | PAABHZ00 | `040000020753` | 1.75 |  | **1.75** | 1.00 | 2.00 | = | = |  |
| 9 | PAABG400 | `040000020753` | 97 |  | **97** | 90 | 100 | = | = |  |
| 10 | SAABSTTR | `050000014208` | 39 |  | **39** | 38 | 42 | = | = |  |
| 11 | PAABFDNT | `040000020753` | 0.265 |  | **0.265** | 0.300 | 0.500 | = | = |  |

#### L-QM03: DO `0085006240` (SRGIDI), customer 1800000002, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PALZTH00 | `040000020676` | 69.97 |  | **69.97** | 67.90 | 72.10 | = | = |  |
| 2 | PGIDTSMD | `040000020757` | 0.64 |  | **0.64** | 6.00 | 8.00 | = | = |  |
| 3 | PGIDTSTD | `040000020757` | 16.00 |  | **16.00** | 10.00 | 17.00 | = | = |  |
| 4 | PGIDELMD | `040000020757` | 138 |  | **138** | 130 | 170 | = | = |  |
| 5 | PGIDELTD | `040000020757` | 45 |  | **45** | 30 | 70 | = | = |  |
| 6 | PGIDSHMD | `040000020757` | 3.25 |  | **3.25** | 1.00 | 4.00 | = | = |  |
| 7 | PGIDSHTD | `040000020757` | 2.87 |  | **2.87** | 1.00 | 3.00 | = | = |  |
| 8 | SGIDSTCD | `050000014206` | 40 |  | **40** | 38 | 44 | = | = |  |
| 9 | PGIDFDG2 | `040000020757` | 67 |  | **67** | 50 | 80 | = | = |  |

#### L-QM04: DO `0085006241` (SREWEI), customer 1800000002, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PCGATH00 | `040000020693` | 12.17 |  | **12.17** | 11.64 | 12.36 | = | = |  |
| 2 | PCGATSMD | `040000020693` | 27.00 |  | **27.00** | 18.00 | 26.00 | = | = |  |
| 3 | PCGATSTD | `040000020693` | 26.00 |  | **26.00** | 20.00 | 30.00 | = | = |  |
| 4 | PCGAELMD | `040000020693` | 95 |  | **95** | 90 | 150 | = | = |  |
| 5 | PCGAELTD | `040000020693` | 85 |  | **85** | 75 | 120 | = | = |  |
| 6 | PCGASHMD | `040000020693` | 1.40 |  | **1.40** | 0.00 | 2.00 | = | = |  |
| 7 | PCGASHTD | `040000020693` | 0.32 |  | **0.32** | 0.00 | 0.60 | = | = |  |
| 8 | SEWESTUZ | `050000014215` | 55 |  | **55** | 55 | 58 | = | = |  |
| 9 | PEWEFDUZ | `040000020771` | 0.690 |  | **0.690** | 0.500 | 1.000 | = | = |  |
| 9 | SEWESTMZ | `050000014215` | 55 |  | **55** | 50 | 58 | = | = |  |
| 10 | SEWEMVTR | `050000014215` | 0.19 |  | **0.19** | 0.00 | 0.20 | = | = |  |
| 11 | SEWEO2TR | `050000014215` | 0.21 |  | **0.21** | 0.00 | 0.20 | = | = |  |
| 12 | SEWEODMZ | `050000014215` | 3.14 |  | **3.14** | 3.00 | 3.50 | = | = |  |

#### L-QM05, L-QM06: DO `0085006242` (SRVC2I), customer 1141000004, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PVC2TH00 | `040000020671` | 25.07 |  | **25.07** | 24.25 | 25.75 | = | = |  |
| 2 | PVC2TSMD | `040000020671` | 6.48 |  | **6.48** | 5.53 | 6.11 | = | = |  |
| 3 | PVC2TSTD | `040000020671` | 2.73 |  | **2.73** | 3.78 | 4.18 | = | = |  |
| 4 | PVC2ELMD | `040000020671` | 389 |  | **389** | 617 | 681 | = | = |  |
| 5 | PVC2ELTD | `040000020671` | 640 |  | **640** | 725 | 801 | = | = |  |
| 6 | PVC2SHMD | `040000020671` | -0.32 |  | **-0.32** | -1.00 | 0.00 | = | = |  |
| 7 | PVC2SHTD | `040000020671` | 1.39 |  | **1.39** | 0.00 | 2.00 | = | = |  |
| 8 | SVC2HZ00 | `050000014216` | 5.85 |  | **5.85** | 5.50 | 6.50 | = | = |  |
| 9 | PVC2G400 | `040000020671` | 79 |  | **79** | 70 | 90 | = | = |  |
| 10 | SVC2STNS | `050000014216` | 39 |  | **39** | 36 | 40 | = | = |  |
| 11 | SVC2SSSS | `050000014216` | 2185 |  | **2185** | 1900 | 2300 | = | = |  |
| 12 | SVC2FDSS | `050000014216` | 0.136 |  | **0.136** | 0.050 | 0.150 | = | = |  |
| – | ~~SVC2FDNS~~ | `050000014216` | 0.147 |  | tidak tampil | – | – | – | – | Hilang: mapping SRVC2I di-flag DELETION TRST-AISYAH 02.11.2026 |

#### L-QM07, L-QM08: DO `0085006243` (SREASI), customer 1141000004, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAH8TH00 | `040000020683` | 50.09 |  | **50.09** | 48.50 | 51.50 | = | = |  |
| 2 | PAH8TSMD | `040000020683` | 3.27 |  | **3.27** | 12.00 | 18.00 | = | = |  |
| 3 | PAH8TSTD | `040000020683` | 0.36 |  | **0.36** | 25.00 | 32.00 | = | = |  |
| 4 | PAH8ELMD | `040000020683` | 1 |  | **1** | 150 | 220 | = | = |  |
| 5 | PAH8ELTD | `040000020683` | 92 |  | **92** | 50 | 80 | = | = |  |
| 6 | PAH8SHMD | `040000020683` | 0.58 |  | **0.58** | 3.00 | 5.00 | = | = |  |
| 7 | PAH8SHTD | `040000020683` | 0.59 |  | **0.59** | 0.50 | 1.50 | = | = |  |
| 8 | SEASSTUZ | `050000014211` | 38 |  | **38** | 38 | 44 | = | = |  |
| 9 | PEASFDUZ | `040000020763` | 0.000 |  | **0.000** | 0.400 | 0.700 | = | = |  |
| 10 | SEASODMZ | `050000014211` | 2.65 |  | **2.65** | 2.20 | 2.70 | = | = |  |

#### L-QM09: DO `0085006244` (SRAABI), customer 1141000004, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAABTH00 | `040000020754` | 19.58 |  | **19.58** | 19.40 | 20.60 | = | = | MIC baru: mapping SRAABI ditambah TRST-AISYAH 02.11.2026 |
| 2 | PAABTSMD | `040000020754` | 12.92 |  | **12.92** | 11.00 | 18.00 | = | = |  |
| 3 | PAABTSTD | `040000020754` | 27.71 |  | **27.71** | 22.00 | 35.00 | = | = |  |
| 4 | PAABELMD | `040000020754` | 151 |  | **151** | 120 | 240 | = | = |  |
| 5 | PAABELTD | `040000020754` | 46 |  | **46** | 30 | 90 | = | = |  |
| 6 | PAABSHMD | `040000020754` | 4.33 |  | **4.33** | 3.00 | 5.00 | = | = |  |
| 7 | PAABSHTD | `040000020754` | 2.05 |  | **2.05** | 0.00 | 3.00 | = | = |  |
| 8 | PAABHZ00 | `040000020754` | 1.75 |  | **1.75** | 1.00 | 2.00 | = | = |  |
| 9 | PAABG400 | `040000020754` | 97 |  | **97** | 90 | 100 | = | = |  |
| 10 | SAABSTTR | `050000014222` | 37 |  | **37** | 38 | 42 | = | = |  |
| 11 | PAABFDNT | `040000020754` | 0.265 |  | **0.265** | 0.300 | 0.500 | = | = |  |

#### L-QM10: DO `0085006245` (SRGJBI), customer 1141000004, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAH8TH00 | `040000020687` | 50.09 |  | **50.09** | 48.50 | 51.50 | = | = |  |
| 2 | PAH8TSMD | `040000020687` | 3.27 |  | **3.27** | 12.00 | 18.00 | = | = |  |
| 3 | PAH8TSTD | `040000020687` | 0.36 |  | **0.36** | 25.00 | 32.00 | = | = |  |
| 4 | PAH8ELMD | `040000020687` | 1 |  | **1** | 150 | 220 | = | = |  |
| 5 | PAH8ELTD | `040000020687` | 92 |  | **92** | 50 | 80 | = | = |  |
| 6 | PAH8SHMD | `040000020687` | 0.58 |  | **0.58** | 3.00 | 5.00 | = | = |  |
| 7 | PAH8SHTD | `040000020687` | 0.59 |  | **0.59** | 0.50 | 1.50 | = | = |  |
| 8 | PGJBHZ00 | `040000020773` | 2.04 |  | **2.04** | 1.80 | 3.00 | = | = | MIC baru: mapping SRGJBI 05.11.2026 |
| 9 | SGJBSTCD | `050000014224` | 45 |  | **45** | 40 | 44 | = | = | Pengganti SGJBSTNC (mapping SRGJBI 05.11.2026) |
| 10 | PGJBFDCD | `040000020773` | 0.600 |  | **0.600** | 0.300 | 0.600 | = | = | Pengganti PGJBFDNC (mapping SRGJBI 05.11.2026) |
| – | ~~PGJBFDNC~~ | `040000020773` | 0.480 |  | tidak tampil | – | – | – | – | Hilang: mapping SRGJBI di-flag DELETION 05.11.2026 (diganti PGJBFDCD) |
| – | ~~SGJBSTNC~~ | `050000014224` | 42 |  | tidak tampil | – | – | – | – | Hilang: mapping SRGJBI di-flag DELETION 05.11.2026 (diganti SGJBSTCD) |

#### L-QM11: DO `0085006270` (SRAABI), customer 1141000026, mapping customer 1141000026

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAABTH00 | `040000020867` | 22.40 |  | **22.40** | 19.40 | 20.60 | = | = |  |
| 2 | PAABTSMD | `040000020867` | 14.00 |  | **14.00** | 11.00 | 18.00 | = | = |  |
| 3 | PAABTSTD | `040000020867` | 26.90 |  | **26.90** | 22.00 | 35.00 | = | = |  |
| 4 | PAABELMD | `040000020867` | 180 |  | **180** | 120 | 240 | = | = |  |
| 5 | PAABELTD | `040000020867` | 65 |  | **65** | 30 | 90 | = | = |  |
| 6 | PAABSHMD | `040000020867` | 4.65 |  | **4.65** | 3.00 | 5.00 | = | = |  |
| 7 | PAABSHTD | `040000020867` | 1.78 |  | **1.78** | 0.00 | 3.00 | = | = |  |
| 8 | PAABHZ00 | `040000020867` | 1.00 |  | **1.00** | 1.00 | 2.00 | = | = |  |
| 9 | PAABG400 | `040000020867` | 89 |  | **89** | 90 | 100 | = | = |  |
| 10 | SAABSTTR | `050000014263` | 40 |  | **40** | 38 | 42 | = | = |  |
| 11 | PAABFDNT | `040000020867` | 0.450 |  | **0.450** | 0.300 | 0.500 | = | = |  |
| 12 | PAABFDTR | `040000020867` | 0.562 |  | **0.562** | 0.300 | 0.600 | = | = |  |

#### L-QM12: DO `0085006271` (SRAABI), customer 1141100304, mapping umum (mapping customer 1141100304 di-flag DELETION 05.11.2026)

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAABTH00 | `040000020892` | 21.25 |  | **21.25** | 19.40 | 20.60 | = | = |  |
| 2 | PAABTSMD | `040000020892` | 15.05 |  | **15.05** | 11.00 | 18.00 | = | = |  |
| 3 | PAABTSTD | `040000020892` | 27.45 |  | **27.45** | 22.00 | 35.00 | = | = |  |
| 4 | PAABELMD | `040000020892` | 183 |  | **183** | 120 | 240 | = | = |  |
| 5 | PAABELTD | `040000020892` | 60 |  | **60** | 30 | 90 | = | = |  |
| 6 | PAABSHMD | `040000020892` | 4.05 |  | **4.05** | 3.00 | 5.00 | = | = |  |
| 7 | PAABSHTD | `040000020892` | 1.67 |  | **1.67** | 0.00 | 3.00 | = | = |  |
| 8 | PAABHZ00 | `040000020892` | 1.23 |  | **1.23** | 1.00 | 2.00 | = | = |  |
| 9 | PAABG400 | `040000020892` | 93 |  | **93** | 90 | 100 | = | = |  |
| 10 | SAABSTTR | `050000014265` | 41 |  | **41** | 38 | 42 | = | = |  |
| 11 | PAABFDNT | `040000020892` | 0.399 |  | **0.399** | 0.300 | 0.500 | = | = |  |
| – | ~~SAABMVTR~~ | `050000014265` | 0.58 |  | tidak tampil | – | – | – | – | Hilang: mapping customer 1141100304 di-flag DELETION 05.11.2026 |
| – | ~~SAABO2TR~~ | `050000014265` | 69.50 |  | tidak tampil | – | – | – | – | Hilang: mapping customer 1141100304 di-flag DELETION 05.11.2026 |

#### L-QM13: DO `0085006272` (SREASI), customer 1141000265, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAH8TH00 | `040000020690` | 50.14 |  | **50.14** | 48.50 | 51.50 | = | = |  |
| 2 | PAH8TSMD | `040000020690` | 3.27 | 13.27 (TRST-AISYAH 09.11.2026) | **13.27** | 12.00 | 18.00 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 3 | PAH8TSTD | `040000020690` | 0.36 | 27.36 (TRST-AISYAH 09.11.2026) | **27.36** | 25.00 | 32.00 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 4 | PAH8ELMD | `040000020690` | 1 | 178 (TRST-AISYAH 09.11.2026) | **178** | 150 | 220 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 5 | PAH8ELTD | `040000020690` | 92 | 72 (TRST-AISYAH 09.11.2026) | **72** | 50 | 80 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 6 | PAH8SHMD | `040000020690` | 1.90 | 4.90 (TRST-AISYAH 09.11.2026) | **4.90** | 3.00 | 5.00 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 7 | PAH8SHTD | `040000020690` | 0.37 | 1.37 (TRST-AISYAH 09.11.2026) | **1.37** | 0.50 | 1.50 | = asli | = | ZQM003 kolom NEW_VALUE = override |
| 8 | SEASSTUZ | `050000014269` | 42 |  | **42** | 38 | 44 | = | = |  |
| 9 | PEASFDUZ | `040000020894` | 0.543 |  | **0.543** | 0.400 | 0.700 | = | = |  |
| 10 | SEASODMZ | `050000014269` | 2.56 |  | **2.56** | 2.20 | 2.70 | = | = |  |

#### ML-QM01: DO `0085006276` (SRACBI), customer 1141100239, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PACBTH00 | `040000021076` | 17.95 |  | **17.95** | 17.46 | 18.54 | = | = |  |
| 2 | PACBTSMD | `040000021076` | 14.51 |  | **14.51** | 11.00 | 18.00 | = | = |  |
| 3 | PACBTSTD | `040000021076` | 28.15 |  | **28.15** | 22.00 | 35.00 | = | = |  |
| 4 | PACBELMD | `040000021076` | 160 |  | **160** | 120 | 240 | = | = |  |
| 5 | PACBELTD | `040000021076` | 49 |  | **49** | 30 | 90 | = | = |  |
| 6 | SACBSHMD | `050000014308` | 4.84 |  | **4.84** | 6.00 | 8.00 | = | = |  |
| 7 | SACBSHTD | `050000014308` | 7.01 |  | **7.01** | 7.00 | 9.00 | = | = |  |
| 8 | SACBHZ00 | `050000014308` | 2.21 |  | **2.21** | 1.50 | 2.50 | = | = |  |
| 9 | SACBG400 | `050000014308` | 88 |  | **88** | 85 | 100 | = | = |  |
| 10 | SACBSIIN | `050000014308` | 111 |  | **111** | 102 | 108 | = | = |  |
| 11 | SACBSIOT | `050000014308` | 110 |  | **110** | 102 | 108 | = | = |  |
| 12 | PACBSSIN | `040000021076` | 294 |  | **294** | 200 | 400 | = | = |  |
| 13 | PACBSSOT | `040000021076` | 267 |  | **267** | 200 | 400 | = | = |  |
| 14 | SACBFDIN | `050000014308` | 0.265 |  | **0.265** | 0.200 | 0.400 | = | = |  |

#### ML-QM02: DO `0085006277` (SRACBI), customer 1141100081, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PACBTH00 | `040000021077` | 17.87 |  | **17.87** | 17.46 | 18.54 | = | = |  |
| 2 | PACBTSMD | `040000021077` | 15.81 |  | **15.81** | 11.00 | 18.00 | = | = |  |
| 3 | PACBTSTD | `040000021077` | 25.75 |  | **25.75** | 22.00 | 35.00 | = | = |  |
| 4 | PACBELMD | `040000021077` | 185 |  | **185** | 120 | 240 | = | = |  |
| 5 | PACBELTD | `040000021077` | 56 |  | **56** | 30 | 90 | = | = |  |
| 6 | SACBSHMD | `050000014311` | 6.93 |  | **6.93** | 6.00 | 8.00 | = | = |  |
| 7 | SACBSHTD | `050000014311` | 8.83 |  | **8.83** | 7.00 | 9.00 | = | = |  |
| 8 | SACBHZ00 | `050000014311` | 1.72 |  | **1.72** | 1.50 | 2.50 | = | = |  |
| 9 | SACBG400 | `050000014311` | 91 |  | **91** | 85 | 100 | = | = |  |
| 10 | SACBSIIN | `050000014311` | 108 |  | **108** | 102 | 108 | = (fix) | = | Sebelum fix ZQM003 106 (rata-rata nilai unik, lihat 0.6.3) |
| 11 | SACBSIOT | `050000014311` | 107 |  | **107** | 102 | 108 | = (fix) | = | Sebelum fix ZQM003 106 (rata-rata nilai unik, lihat 0.6.3) |
| 12 | PACBSSIN | `040000021077` | 294 |  | **294** | 200 | 400 | = | = |  |
| 13 | PACBSSOT | `040000021077` | 267 |  | **267** | 200 | 400 | = | = |  |
| 14 | SACBFDIN | `050000014311` | 0.275 |  | **0.275** | 0.200 | 0.400 | = | = |  |

#### ML-QM03: DO `0085006278` (SRGLBI), customer 1141000131, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAH8TSMD | `040000021013` | 0.00 |  | **0.00** | 12.00 | 18.00 | = | = |  |
| 2 | PAH8TSTD | `040000021013` | 0.00 |  | **0.00** | 25.00 | 32.00 | = | = |  |
| 3 | PAH8ELMD | `040000021013` | 0 |  | **0** | 150 | 220 | = | = |  |
| 4 | PAH8ELTD | `040000021013` | 0 |  | **0** | 50 | 80 | = | = |  |
| 5 | PGLASHMD | `040000021042` | 2.62 |  | **2.62** | 3.00 | 5.00 | = | = |  |
| 6 | PGLASHTD | `040000021042` | 0.34 |  | **0.34** | 0.00 | 2.00 | = | = |  |
| 7 | SGLASTCD | `050000014297` | 42 |  | **42** | 40 | 44 | = (fix) | = | Sebelum fix ZQM003 41 (lihat 0.6.3) |
| 8 | SGLASTMZ | `050000014297` | 52 |  | **52** | 38 | 58 | = (fix) | = | Sebelum fix ZQM003 51 (lihat 0.6.3) |
| 9 | PGLAG6CD | `040000021042` | 636 |  | **636** | 600 | 660 | = | = |  |
| 10 | PGLBOD00 | `040000021052` | 2.38 |  | **2.38** | 2.20 | 2.80 | = (fix) | = | Sebelum fix ZQM003 2.41 (lihat 0.6.3) |

#### ML-QM04: DO `0085006279` (SREC7I), customer 1141100236, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | SVLCTSMD | `050000014331` | 16.15 |  | **16.15** | 12.00 | 0.00 | = | = |  |
| 2 | SVLCTSTD | `050000014331` | 24.17 |  | **24.17** | 22.00 | 0.00 | = | = |  |
| 3 | SVLCELMD | `050000014331` | 237 |  | **237** | 0 | 300 | = | = |  |
| 4 | SVLCELTD | `050000014331` | 73 |  | **73** | 0 | 80 | = | = |  |
| 5 | SVLCSHMD | `050000014331` | 0.00 |  | **0.00** | 0.00 | 5.00 | = | = |  |
| 6 | SVLCSHTD | `050000014331` | 0.00 |  | **0.00** | 0.00 | 4.00 | = | = |  |
| 7 | SEC7STCD | `050000014339` | 39 |  | **39** | 38 | 42 | = | = |  |
| 8 | PEC7FDCD | `040000021127` | 0.540 |  | **0.540** | 0.300 | 0.800 | = | = |  |
| 9 | SEC7MVTR | `050000014339` | 0.07 |  | **0.07** | 0.05 | 0.15 | = | = |  |
| 10 | SEC7O2TR | `050000014339` | 0.07 |  | **0.07** | 0.05 | 0.15 | = | = |  |

#### Data uji alias (MIXED): DO `0085006281` (SRAABI), customer 1141000512, mapping umum

| SEQ | MIC | Lot (INSLOT) | Nilai asli | Override ZLOG_COA | **Nilai print ZQM002** | **Lower** | **Upper** | ZQM003 nilai | ZQM003 limit | Catatan |
|:-:|:--|:-:|--:|--:|--:|--:|--:|--:|:-:|:--|
| 1 | PAABTH00 | `000000000000` | 0.00 |  | **0.00** | 19.40 | 20.60 | = | = |  |
| 2 | PAABTSMD | `000000000000` | 0.00 |  | **0.00** | 11.00 | 18.00 | = | = |  |
| 3 | PAABTSTD | `000000000000` | 0.00 |  | **0.00** | 22.00 | 35.00 | = | = |  |
| 4 | PAABELMD | `000000000000` | 0 |  | **0** | 120 | 240 | = | = |  |
| 5 | PAABELTD | `000000000000` | 0 |  | **0** | 30 | 90 | = | = |  |
| 6 | PAABSHMD | `000000000000` | 0.00 |  | **0.00** | 3.00 | 5.00 | = | = |  |
| 7 | PAABSHTD | `000000000000` | 0.00 |  | **0.00** | 0.00 | 3.00 | = | = |  |
| 8 | PAABHZ00 | `000000000000` | 0.00 |  | **0.00** | 1.00 | 2.00 | = | = |  |
| 9 | PAABG400 | `000000000000` | 0 |  | **0** | 90 | 100 | = | = |  |
| 10 | SAABSTTR | `000000000000` | 0 |  | **0** | 38 | 42 | = | = |  |
| 11 | PAABFDNT | `000000000000` | 0.000 |  | **0.000** | 0.300 | 0.500 | = | = |  |


#### Data uji alias: DO `0085006280` (SRAABI + SRABDI, alias PLE-22)

Before alias: ZQM002 dan ZQM003 **kosong**, program STOP "Material belum dimapping di ZMAP_COA" (SRABDI tanpa mapping). Expected setelah alias: `docs/DATA_UJI_ALIAS_DEV_20261113.md`. Hasil after patch alias (9 MIC, limit per MIC): `docs/IMPLEMENTASI_ALIAS_HARNESS_20261116.md` §3, mentah di `outputs/LIMIT_20261116_after_alias.txt`.
#### 0.6.3 ZQM003 vs ZQM002: bug nilai unik dan perbaikannya (16 Nov 2026)

**Sebelum fix** (program DEV AIX sampai 16 Nov 2026, sudah ada paling lambat 19 Sep 2026): ZQM003 merata-rata nilai **unik** per VBELN + MATNR + MIC, ZQM002 merata-rata per lot. Contoh DO 77 SACBSIIN: lot 050000014309 = 111, …310 = 111, …311 = 101 → ZQM003 (111 + 101) / 2 = 106, ZQM002 (111 + 111 + 101) / 3 = 108. Dilaporkan juga oleh TRST-AISYAH (dulu hanya ZQM002 yang diperbaiki).

**Sesudah fix** (sandbox-new 16 Nov, `docs/FIX_ZQM003_NILAI_20261116.md`): kolom Value ZQM003 = nilai print ZQM002 sebelum override ZLOG_COA; override tetap di NEW_VALUE.

| Skenario | DO | MIC | Sebelum fix | Sesudah fix | ZQM002 print |
|---|---|---|---|---|---|
| ML-QM02 | 0085006277 | SACBSIIN | 106 | 108 | 108 |
| ML-QM02 | 0085006277 | SACBSIOT | 106 | 107 | 107 |
| ML-QM03 | 0085006278 | PGLBOD00 | 2.41 | 2.38 | 2.38 |
| ML-QM03 | 0085006278 | SGLASTCD | 41 | 42 | 42 |
| ML-QM03 | 0085006278 | SGLASTMZ | 51 | 52 | 52 |

Perubahan format saja (nilai 0 tampil sesuai desimal MIC, sama dengan ZQM002): DO 6234 PCADTSMD/TSTD `0`→`0.00`, DO 6243 PEASFDUZ `0`→`0.000`, DO 6278 PAH8TSMD/TSTD, DO 6279 SVLCSHMD/SHTD `0`→`0.00`, DO 6281 7 MIC PAAB*.

Status: fix di-deploy user ke DEV AIX 16 Nov 2026 dan diverifikasi (program DEV apa adanya, 17 DO, `outputs/MT_20261116_dev_after_zqm003fix.txt`). Acuan ZQM003 aktif = kolom **Sesudah fix**; angka "sebelum fix" hanya sejarah.

---

## 📌 BAGIAN 1: ML-QM03, Multi-Tier Converting End-to-End (7 Tahapan Produksi, DO `0085006278`)

### Ringkasan Alur Produksi Multi-Tier
Alur produksi melewati 7 tahapan berurutan dari **Basefilm BOPP** hingga **Converting Coating**, dengan mapping pengambilan nilai rata-rata (*Average*) ke COA:

| Tahap | Proses Produksi | Kode Material | Jumlah Roll / Lot | Rentang Batch / Lot | Status Mapping COA | Parameter yang Diambil ke COA (Nilai Average) |
| :---: | :--- | :--- | :---: | :--- | :---: | :--- |
| **1** | **JR Basefilm (BOPP)** | `JRAH8I` | 2 (JR 1 – JR 2) | `0000406686` – `0000406687` | **Aktif** | Tensile Strength MD (`0.00`), Tensile Strength TD (`0.00`), Elongation MD (`0`), Elongation TD (`0`) |
| **2** | **SR Basefilm (BOPP)** | `SRAH8I` | 10 (JR 1 – JR 10) | `0000406711` – `0000406720` | *Tidak Ada Mapping* | — |
| **3** | **JR Conv (Coat 1)** | `JRGKAI` | 10 (JR 1 – JR 10) | `0000406727` – `0000406745` *(Ganjil)* | *Tidak Ada Mapping* | — |
| **4** | **SR Conv (Coat 1)** | `SRGKAI` | 10 (JR 1 – JR 10) | `0000406756` – `0000406765` | *Tidak Ada Mapping* | — |
| **5** | **JR Conv (Metz)** | `JRGLAI` | 10 (JR 1 – JR 10) | `0000406781` – `0000406799` *(Ganjil)* | **Aktif** | Shrinkage MD (`2.62`), Shrinkage TD (`0.34`), Gloss 60° Coated Side (`636`) |
| **6** | **SR Conv (Metz)** | `SRGLAI` | 10 (JR 1 – JR 10) | `0000406810` – `0000406819` | **Aktif** | Surface Tension Coated Side (`42`), Surface Tension Metz Side (`52`) |
| **7** | **JR Conv (Coat 2)** | `JRGLBI` | 10 (JR 1 – JR 10) | `0000406821` – `0000406839` *(Ganjil)* | **Aktif** | Optical Density (`2.378`) |

---

### Nilai Karakteristik Riil per Tahapan Multi-Tier

#### 1. Tahap 1: JR Basefilm (`JRAH8I`)
- **Roll**: JR 1 (`0000406686`), JR 2 (`0000406687`)
- **Hasil COA**: Tensile MD = `0.00`, Tensile TD = `0.00`, Elongation MD = `0`, Elongation TD = `0`.

#### 2. Tahap 5: JR Conv Metz (`JRGLAI`)
- **Roll**: `0000406781` s/d `0000406799` (Pengujian di JR 4 s/d JR 10).
- **Hasil Rata-Rata (COA)**:
  - Shrinkage MD: `2.62`
  - Shrinkage TD: `0.34`
  - Gloss 60° (Coated Side): `636`

#### 3. Tahap 6: SR Conv Metz (`SRGLAI`)
- **Roll 10 Sibling**: `0000406810` s/d `0000406819` (Lot `050000014288` s/d `050000014297`).
- **Data Uji Laboratorium**:
  - Roll 1 (`...810`): Surface Tension Coated = `38`, Metz = `52`
  - Roll 2–8 (`...811` s/d `...817`): Surface Tension Coated = `42`, Metz = (`48`, `48`, `48`, `42`, `56`, `56`, `56`)
  - Roll 9–10 (`...818` s/d `...819`): Surface Tension Coated = `44`, Metz = `58`
- **Hasil Rata-Rata (COA)**:
  - **Surface Tension Coated Side**: `42`
  - **Surface Tension Metz Side**: `52`

#### 4. Tahap 7: JR Conv Coat 2 (`JRGLBI`)
- **Roll**: `0000406821` s/d `0000406839`.
- **Hasil Uji**: JR 1–7 = `2.33`, JR 8–10 = `2.49`.
- **Hasil Rata-Rata (COA)**: **Optical Density = `2.378`**.

### Sub-skenario ML-QM03 di Excel
- **ML-QM03.A**: traceability ZQM015, lalu produksi (ZPP041) dan inspeksi (QA32/ZQM005) per tahap BF → Coat.
- **ML-QM03.B**: JR Metz. Hanya sebagian JR yang diinspeksi. JR yang tidak diinspeksi mencari JR terdekat (seq ≥ 20 ke atas, 1 type film, 1 line, 1 bulan). Ada JR yang tidak menemukan JR terdekat, dan ada yang menemukan `0000406787`.
- **ML-QM03.C**: Print COA (ZQM002), Change Value Lower/Upper, Print + pilih header, Print Batch List.

### ML-QM01 / ML-QM02 di Excel (alur langkah)
ZQM015 Traceability → ZPP041 Produksi JR BF → QA32 Inspeksi JR BF → ZQM005 → QA32 Inspeksi SR BF → ZQM005 → ZQM002 Print COA → Change Value Lower/Upper → Print COA → Print COA + Pilih header → Print Batch List.
- ML-QM01: JR BF `0000406862`–`0000406883` tidak diinspeksi, sehingga dicari JR terdekat (seq ≥ 20): `406861` (4 ACB 106 002) dan `406863` (4 ACB 106 004).
- ML-QM02: JR BF `0000406866`, `0000406874`, `0000406884`. Dua JR mendapatkan JR terdekat `406863`. **Satu JR tidak mendapatkan JR terdekat (seq ≥ 20)**: ini kasus negatif yang wajib dicek.

---

## 📌 BAGIAN 2: Skenario Lama L-QM01 – L-QM15 (Baseline Komprehensif)
*Sumber: Copy of Scenario Test COA v3.xlsm / `SEMUA SKENARIO LAMA SEBELUM + MULTI LEVEL.xlsm`*

| Kode Skenario | Judul Skenario Testing | Contoh No DO Acuan | Karakteristik / Alur Kunci | Ketentuan Penting (Anti-Regresi) |
| :---: | :--- | :---: | :--- | :--- |
| **L-QM01** | Sc Normal BF - 1 JR sama dalam 1 DO | `85006234` | 1 JR Basefilm menghasilkan beberapa SR pada 1 DO yang sama. | Inspeksi JR & SR standar. Seluruh roll turunan mengambil data lot JR acuan yang sama. |
| **L-QM02** | Sc Normal BF - Beda JR dalam 1 DO | `85006235` | Beberapa JR Basefilm berbeda dalam 1 DO pengiriman. | Sistem harus mengagregasi rata-rata per JR atau multi-lot sesuai mapping. |
| **L-QM03** | Sc Normal Conv - 1 JR Conv Sama dalam 1 DO | `85006240` | 1 JR Converting yang sama untuk seluruh roll dalam 1 DO. | Menelusuri JR Basefilm dan JR Converting. Parameter Basefilm ditarik dari root, Conv ditarik dari stage perantara. |
| **L-QM04** | Sc Normal Conv - Beda JR Conv dalam 1 DO | `85006241` | Beberapa JR Converting berbeda dalam 1 DO. | Penelusuran independen per roll/lot converting tanpa tumpang tindih. |
| **L-QM05** | Sc SR BF yang di-Inspeksi SR dulu → Change Grade (1 DO 1 JR) | `85006242` | Inspeksi SR dilakukan sebelum Change Grade (pergerakan `311`/`309`). | Silsilah batch history harus mampu melacak lot inspeksi sebelum transfer grade. |
| **L-QM06** | Sc SR BF yang Change Grade dulu → Inspeksi SR (1 DO 1 JR) | `85006242` | Change Grade dilakukan terlebih dahulu, baru diinspeksi. | Lot inspeksi melekat pada batch baru; silsilah tetap harus terhubung ke JR asal. |
| **L-QM07** | Sc SR Conv yang di-Inspeksi SR dulu → Change Grade (1 DO 1 JR) | `85006243` | Skenario Converting: Inspeksi SR sebelum Change Grade. | Memastikan lot converting lama tetap terbaca di tingkat batch baru. |
| **L-QM08** | Sc SR Conv yang Change Grade dulu → Inspeksi SR (1 DO 1 JR) | `85006243` | Skenario Converting: Change Grade sebelum Inspeksi SR. | Lot inspeksi batch baru terhubung ke silsilah JR Conv dan JR Basefilm. |
| **L-QM09** | Sc SR BF yang di-Inspeksi di Secondary Slitting (1 DO 1 JR) | `85006244` | Basefilm mengalami proses pemotongan ulang (*Secondary Slitting*). | Silsilah penelusuran bertingkat SR $\to$ SR $\to$ JR Basefilm. |
| **L-QM10** | Sc SR Conv yang di-Inspeksi di Secondary Slitting (1 DO 1 JR) | `85006245` | Converting mengalami proses pemotongan ulang (*Secondary Slitting*). | Silsilah penelusuran bertingkat SR Conv $\to$ SR Conv $\to$ JR Conv $\to$ JR Basefilm. |
| **L-QM11** | Sc JOIN 2 Inputan Jumbo Roll (1 DO 1 JR) | `85006270` | Proses produksi menggabungkan (*join/splice*) 2 inputan Jumbo Roll menjadi 1 JR baru. | Multi-parent handling: mengambil nilai karakteristik dari kedua parent atau lot acuan yang valid. |
| **L-QM12** | Sc JOIN 2 Inputan Jumbo Roll (1 DO 2 JR) & Cari Inspeksi 20 ke atas | `85006271` | Join 2 JR dalam 1 DO berisi 2 JR berbeda, dengan pencarian inspeksi sample urutan ke-20 ke atas. | Algoritma penarikan sample order tidak boleh terpotong limit index. |
| **L-QM13** | 1 DO 3 JR Beda Line | `85006272` | Pengiriman 1 DO memuat roll dari 3 JR berbeda yang diproduksi di mesin/line berbeda. | Evaluasi per-line dan per-JR tidak boleh saling menimpa nilai parameter. |
| **L-QM14** | Sc banyak DO sekali Cetak | — | Pemanggilan massal cetak COA untuk banyak DO sekaligus di Layar ALV `ZQM002`. | Bebas memory leak, *refresh global variables* (`CLEAR`, `REFRESH`) pada setiap pergantian DO/Item. |
| **L-QM15** | Sc Ketika Ubah value di Print Certificate | — | Pengguna mengedit/mengubah nilai karakteristik secara manual di Layar ALV 0200 sebelum cetak. | Nilai editan manual tidak boleh tertimpa kembali oleh kalkulasi ulang database saat tombol Print ditekan. |

---

## 🔒 Standar Kepatuhan Teknis & Aturan Pengubahan Kode
1. **Prinsip Zero Hardcode**: Dilarang melakukan hardcode kode material (misal `SRGLBI`, `JRAH8I`), nomor order, atau nomor batch di dalam logika traversal program.
2. **Harmonisasi Variabel Warisan**: Variabel lama (`LOT_SR_CONV`, `LOT_JR_CONV`, `LOT_SR_BASE`, `LOT_JR_BASE`) wajib tetap terisi agar skenario **L-QM01 s/d L-QM15** tidak mengalami regresi.
3. **Penyelarasan Multi-Tier**: Pengambilan MIC bertingkat menggunakan struktur pohon dinamis (`GT_STAGE_LOTS`) dengan proteksi siklus silsilah (`LT_TREE_VISITED`).
4. **Wajib regresi penuh**: Setiap perubahan dijalankan terhadap semua DO di BAGIAN 0 §0.1 dan dilaporkan per skenario (lihat §0.4).
