# Analisis Material Outsource TTA → Trias untuk COA — 17 Nov 2026

Permintaan user (hasil diskusi QA): untuk material outsource dari TTA (PT. Trias Toyobo Astria) ke Trias, **MIC COA diambil sampai level material I** (contoh `SRSF9I`). Material TTA dikenali dari **batch berawalan `9`** dan **ZZNOMORROLL token pertama / ZZPRODLINE = `Z3`**. Status: **analisis saja**, data dibaca dari PRD (`RFC_READ_TABLE` + baca source, tanpa menjalankan program), program belum diubah.

## 1. Report acuan: ZEQM015

`ZEQM015` → `ZQMR_TRACEABILITY_TTE` (pilihan radio) → `ZQMR_TRACEABILITY_TR_TTE` "Report Tree Traceability Trace Roll TTE" (include TOP / F01 / PBO / PAI). Logika `LEVEL_UP` (F01 ±464–790):

- Batch → GR `101` (MSEG, tanpa yang dibatalkan) → order (`AUFNR`) atau PO.
- Komponen order: `AUFM` `261`; komponen subcontract: MSEG `543` (dan `601` untuk antar plant) → kalau ada `EBELN` → node **SUBCONTRACT**, lanjut ke GR `101` PO tersebut.
- Batch tanpa GR order/PO → **INITIAL** (titik awal di plant itu).
- Nomor roll dari klasifikasi (`ZZNOMORROLL`, `ZZNOROLLTOYOBO`, `ZZNOLOTTOYOBO`).

## 2. Contoh data PRD (tree di screenshot)

| Level tree | Material | Batch | Plant | Asal (MSEG) | Klasifikasi | Inspection lot |
|---|---|---|---|---|---|---|
| 1 | **SRCBUX** | **9034162142** | 2000 | 101 dari order `100007264855` (03.11.2026), lalu 311/413/601 (dikirim) | ZZNOMORROLL `Z3 SF9 106 095 7F 01 04`, ZZPRODLINE `Z3`, ZZCODE `CBU`, ZZTYPE `EPX`, ZZALIAS `EP-12` | **Tidak ada** |
| 2 | SRCBUO | 0034222684 | 2000 | 101 PO `4520006335` (PO21, vendor `2132000001` = TTA), vendor batch (LICHA) `0034162142`; 261 ke order `100007264855` | ZZCODE `CBU`, ZZTYPE `EPX`, ZZALIAS `EP-12` (tanpa ZZNOMORROLL/ZZPRODLINE) | **Tidak ada** |
| 3 | **SRSF9I** | 0034162142 | **TTA2** | 531 dari order slitting `100007254593` (header JRSIPI); 601 ke Trias | ZZNOMORROLL `Z3 SF9 106 095 7F 01 04`, ZZPRODLINE `Z3`, ZZCODE `SF9`, ZZTYPE `5_EP`, ZZALIAS `EP-12` | **Tidak ada** (roll saudara 0034162139–146 juga tidak ada lot Z04) |
| (hulu) | JRSIPI | 0034162103 | TTA2 | 261 ke order `100007254593` | ZZNOMORROLL `Z3 SIP 106 095`, ZZPRODLINE `Z3`, ZZCODE `SIP`, ZZTYPE `KE5100` | **`040001075921` (Z02)**, 30 MIC `PSIP*`, semua ada hasil |

Pola batch: `9` + `034162142` (SRCBUX) = nomor batch TTA `0034162142` dengan digit pertama diganti `9`.

**Lot JR TTA `040001075921` (MIC `PSIP*`, contoh):** Thickness 12.24 (11.16–12.84), Tensile MD 24.03, Tensile TD 23.69, Elongation MD 92.56 / TD 83.78, Shrinkage MD 1.34 / TD 0.32, Haze 2.03, Gloss 45° 128.44, Surface Tension Treated 58 / Untreated 45, COF (Dyn/Stat, sled 1500 g), Impact Strength 4.61, Surface Tension TOYOBO, dll.

## 3. Temuan

1. **Value hanya ada di lot JR TTA** (`JRSIPI`, Z02). Batch SRCBUX, SRCBUO dan SRSF9I sendiri tidak punya lot. "Sampai level material I" di data ini praktis berarti: telusuri SRCBUX → SRCBUO → (vendor batch) SRSF9I di TTA2 → JR induknya → lot Z02.
2. **Nama MIC berbeda per level**: lot memakai kode JR `SIP` (`PSIP*`), SR TTA `SF9`, produk Trias `CBU`. Mapping COA SRCBUX perlu cara menerjemahkan MIC (misalnya pola RULE `P` + kode + akhiran seperti alias, atau mapping langsung ke MIC `PSIP*`).
3. **ZMAP_COA belum ada di PRD** (`TABLE_NOT_AVAILABLE`): program COA baru ini memang belum live di PRD; mapping SRCBUX belum bisa dicek di PRD.
4. **Rantai melewati PO subcontract + vendor batch (LICHA)**, bukan order produksi biasa. Program COA sekarang punya penanganan SR berakhiran `A`/`O` (pakai LICHA) di `GET_TRACED_LOTS`, tapi batasnya di plant sendiri; trace ke plant TTA2 (`601` antar plant) dan pemakaian ZZPRODLINE `Z3` belum ada. Perilaku pasti program untuk batch ini belum bisa diuji karena data hanya ada di PRD.
5. **SRCBUX juga ber-ZZALIAS `EP-12`**: dengan logika alias yang baru, batch ini bisa masuk jalur alias (konversi ZZCODE EP-12). Interaksi alias × outsource TTA perlu diputuskan.
6. Batch berawalan `9` untuk material SR*X di plant 2000 sangat banyak (≥ 20.000 baris MCHA, terbanyak SRCALX, SRCBHX, SRCB6X, SRCB3X); belum dicek berapa yang ZZPRODLINE `Z3`.

## 4. Pertanyaan untuk QA

1. Value COA untuk material outsource TTA diambil dari **lot JR TTA** (contoh `040001075921`, JRSIPI)? Atau ada lot lain di level SRSF9I yang harus dipakai?
2. MIC di mapping SRCBUX: memakai MIC kode `CBU` (diterjemahkan ke `SIP`), atau mapping langsung berisi MIC `PSIP*`?
3. Aturan deteksi TTA: batch `9*` **dan** (`ZZPRODLINE = Z3` **atau** ZZNOMORROLL token pertama `Z3`)? Atau salah satu cukup?
4. Kalau batch TTA juga punya ZZALIAS, mana yang didahulukan: jalur alias atau jalur outsource TTA?
5. Data uji: DO PRD mana yang berisi batch TTA untuk dijadikan skenario, dan apakah data serupa perlu dibuat di DEV?

## 5. Jawaban QA (17 Nov 2026, via user)

| No | Pertanyaan | Jawaban |
|---|---|---|
| 1 | Sumber value | Ikut ZEQM015: level **SR\*** di rantai TTA = **SR Base Film**, level **JR\*** = **JR Base Film** |
| 2 | Mapping SRCBUX | Pakai MIC kode **CBU** (mapping material Trias), diterjemahkan ke MIC lot |
| 3 | Deteksi TTA | **Dua aturan sekaligus**: batch berawalan `9` **dan** `Z3` (ZZPRODLINE / token pertama ZZNOMORROLL) |
| 4 | Alias vs TTA | Biasanya tidak ada; kalau ada, **alias diprioritaskan** |
| 5 | Data uji | Tidak ada data PRD terstruktur (dulu manual Excel). Perlu data uji |

## 6. Rancangan (belum di-execute)

**Deteksi per roll:** `CHARG(1) = '9'` **dan** (`ZZPRODLINE = 'Z3'` **atau** token pertama `ZZNOMORROLL = 'Z3'`). Selain itu → logika trace sekarang (tidak berubah).

**Trace jalur TTA (mengikuti ZEQM015):**
1. Roll Trias (mis. SRCBUX `9034162142`) → GR 101 order → komponen 261 (SRCBUO `0034222684`).
2. Komponen dari PO subcontract (GR 101 PO, vendor TTA) → **vendor batch (MCH1-LICHA)** = batch TTA (SRSF9I `0034162142`, plant TTA2).
3. Batch TTA **SR\*** → lot Z04 batch itu = **SR Base Film**.
4. Order SR TTA (531 / 101) → komponen 261 **JR\*** (JRSIPI `0034162103`) → lot Z02/Z03 = **JR Base Film**.
5. Mapping SRCBUX menentukan stage tiap MIC (SR Base Film / JR Base Film), sama seperti program sekarang.

**Terjemahan MIC (koreksi 17 Nov, masukan user):** pakai **urutan yang sama dengan alias** (`ALIAS_TRANSLATE_GROUP`): EXACT → RULE (pola kode) → SUFFIX → DESC (deskripsi MIC sama, level S/P/A sama) → NONE. Setiap langkah dicocokkan dengan **inspection plan** (MAPL + PLMK) material lot. Bedanya: untuk TTA, plan yang dipakai adalah plan **material lot hasil trace** (mis. JRSIPI, SRSF9I), bukan plan turunan nama `JR` + kode (`ALIAS_LOAD_PLAN` menebak JR = `JR` + kode SR, sehingga untuk SRSF9I menjadi JRSF9I, padahal JR aslinya JRSIPI). Uraian pola di bawah adalah contoh langkah RULE.

**Terjemahan MIC:** mapping memakai kode Trias (`PCBUTH00`), lot TTA memakai kode material TTA. Diterjemahkan dengan pola yang sama dengan RULE alias: huruf 1 MIC + kode material lot (huruf 3–5 MATNR) + 4 huruf akhir MIC. Contoh: `PCBUTH00` → lot JR JRSIPI `PSIPTH00`, lot SR SRSF9I `PSF9TH00`. Lot JR PRD `040001075921` memakai akhiran standar (TH00, TSMD, TSTD, ELMD, ELTD, SHMD, SHTD, HZ00, G400, STTR, FDNT, dll.), jadi pola ini cocok.

**Alias:** kalau roll TTA juga punya ZZALIAS, alias tetap menentukan material COA dan mapping (prioritas alias); jalur TTA tetap dipakai untuk mencari lot dan value.

**Limit:** mengikuti aturan yang berlaku: mapping SRCBUX bila diisi, sisi kosong dari spec lot (lot TTA hasil trace).

**Catatan data PRD contoh:** SRSF9I `0034162142` dan roll saudaranya **tidak punya lot Z04**, jadi MIC stage SR Base Film akan kosong (value 0) untuk contoh ini; hanya JR Base Film (lot `040001075921`) yang ada value.

**Data uji DEV:** DEV punya plant TTA2 dan 440 batch SR\*X berawalan `9` di plant 2000. Langkah berikut: cari rantai lengkap di DEV (read-only); kalau tidak ada, buat data uji (perlu persetujuan).

## 7. Keputusan lanjutan (17 Nov 2026, via user)

| No | Topik | Keputusan |
|---|---|---|
| 1 | SR TTA tanpa lot | **Tetap 0.** Ambil per stage mapping seperti COA normal: SR Base Film dari lot SR, JR Base Film dari lot JR, tanpa saling mengisi |
| 2 | Batas trace TTA | Kalau material outsource dari TTA, trace **berhenti di JR material I** (contoh JRSIPI). SR material I di atasnya (SRSF9I) = SR Base Film, JR material I = JR Base Film |
| 3 | Cakupan | Logika TTA **hanya untuk case outsource** (stage base film). Stage converting tetap logika yang sudah ada |
| 4 | Limit | **Opsi D** |
| 5 | Data uji | Cari di DEV; kalau tidak ada, buat data uji (disetujui) |

## 8. Data rantai TTA di DEV (cek 17 Nov 2026, read-only)

Program pencari sementara di DEV (`RFC_ABAP_INSTALL_AND_RUN`, hanya SELECT): 440 roll SR\*X batch `9*` plant 2000 → 417 ber-`Z3`. Status rantai: **23 LENGKAP**, 383 TTA tanpa JR (trace sederhana belum menemukan JR), 11 tanpa komponen/vendor batch.

Rantai lengkap (semua sama): **SRCBUX** `9000377390`… → order → SRCBUO (PO, vendor batch) → **SRSEFI** (TTA2, **tanpa lot Z04**) → **JRSEFI** `0000371969` → lot **`040000015885`** (1 lot Z02/Z03, 19 MIC `PSEF*` berhasil: TH00, TSMD, TSTD, ELMD, ELTD, F5MD/TD, SHMD/TD, HZ00, G400, STNT, STTR, FDNT, FSNT, FDTR, FSTR, IS00, TREATED).

| Roll | Stok | Sudah di DO |
|---|---|---|
| 9000377390–392, 410–417 | 0.76–0.84 KG (sloc 2801/2804) | Tidak |
| 9000377404–407, 424–425 | 0 | STO HSTP 0160003247/3249 (bukan ZB) |
| 9000377408–409, 422–423 | ada | STO HODN/HSTP (bukan ZB) |
| 9000377418, 420 | 0 | Tidak |

- **SRCBUX belum punya ZMAP_COA di DEV** → perlu mapping uji (MIC `PCBU*`, stage JR Base Film / SR Base Film). Terjemahan RULE `PCBUTH00` → `PSEFTH00` (kode JRSEFI = `SEF`) cocok dengan MIC lot.
- Karena SRSEFI tanpa lot, MIC stage SR Base Film akan 0 (sesuai keputusan §7 no. 1).
