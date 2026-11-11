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

- **Hasil program (semua DO)**: [`outputs/MT_qm04_C_fix.txt`](../outputs/MT_qm04_C_fix.txt) (19 Okt 2026). Format per baris: `|VBELN|MATNR|CHK|NUM|MIC|NILAI|INSLOT`.
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
- **L-QM12 (DO 71)**: ALV user hanya menampilkan 11 MIC, sedangkan golden file punya 13 MIC (ada `SAABMVTR 0.58` dan `SAABO2TR 69.50`, lot `050000014265`). **Diabaikan (keputusan user 2026-11-11):** penyebabnya mapping diubah oleh Aisyah saat testing. Jika `SAABMVTR`/`SAABO2TR` muncul atau hilang di hasil regresi DO 71, jangan dilaporkan sebagai REGRESI. Cukup dicatat sebagai "efek mapping testing".
- **L-QM13 (DO 72, item 20)**: Out Limit `X` pada TSMD, TSTD, ELMD, ELTD, SHMD, SHTD. Ini memang nilai lot `040000020690` (out of spec), bukan bug.
- Tab **`QM16`** dan **`QM17`** di Excel: **di-skip** dulu (keputusan user 2026-11-11), tidak termasuk regresi.

### 0.4 Prosedur wajib saat ada perubahan kode COA

1. Ambil ulang source DEV AIX terbaru. Uji patch lewat **subroutine pool** (`tests/mt_pool_*.abap` + `tests/mt_harness_final.abap`), tanpa mengubah program asli.
2. Jalankan suite untuk **semua DO** di §0.1 (satu sesi RFC per DO):
   ```bash
   DOS="0085006234 0085006235 0085006240 0085006241 0085006242 0085006243 0085006244 0085006245 0085006270 0085006271 0085006272 0085006276 0085006277 0085006278 0085006279" node scripts/mt_run_suite.mjs tests/mt_harness_final.abap outputs/MT_<tgl>_<nama>.txt "Development AIX"
   ```
3. Bandingkan hasilnya:
   - dengan golden file: `diff outputs/MT_qm04_C_fix.txt outputs/MT_<tgl>_<nama>.txt`
   - dengan nilai SAP: `python3 scripts/mt_compare_expected.py outputs/MT_<tgl>_<nama>.txt`
   - untuk ML-QM01–03, cocokkan dengan tabel §0.3
4. Laporkan per skenario (L-QM01…L-QM15, ML-QM01…ML-QM04) dengan status **SAMA / BERUBAH (disengaja) / REGRESI**. Setiap perbedaan harus disertai alasannya.
5. Kalau perubahan memang disengaja dan sudah disetujui, perbarui golden file dan tabel §0.3, lalu catat tanggalnya di §0.5.

### 0.5 Riwayat baseline

| Tanggal | Perubahan | Dampak ke baseline |
| :--- | :--- | :--- |
| 2026-10-16 | Multi-level dynamic genealogy (DO 78) | Tambah ML-QM03 |
| 2026-10-19 | Fix QM04/QM07 (`MT_qm04_C_fix.txt`) | Jadi golden file |
| 2026-11-03/04 | ZQM003 urutan `SEQ_NO` + DO-or-date (pushed sandbox-new) | Kolom `NUM` mengikuti `SEQ_NO`; acuan `seq_check_20261103/ALV_fix.txt` |
| 2026-11-11 | L-QM11/12/13 = DO 70/71/72 (dari sheet Excel user) | Tidak ada perubahan nilai |
| 2026-11-11 | Peta dua set skenario (L-QM vs ML-QM) + DO 76–79; ML-QM04 = outsource DO 79 | Baseline DO 79 (`outputs/MT_ml_qm04_do79_dev_20261111.txt`) ditambahkan ke golden file `MT_qm04_C_fix.txt`; MVTR/O2TR = 0.07 ikut program (hasil input TRST-AISYAH 05.11.2026) |

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
