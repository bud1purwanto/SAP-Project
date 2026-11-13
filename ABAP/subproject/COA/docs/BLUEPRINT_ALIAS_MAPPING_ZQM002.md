# Blueprint: COA Gabungan per Alias (ZQM002 / ZMAP_COA) — Opsi 1

| | |
|---|---|
| Program | ZQMI_COA (tcode ZQM002), mapping ZMAP_COA (ZQM001 / ZMAP_COA_MIC) |
| Status | **Rancangan, menunggu konfirmasi tim QA.** Jangan dieksekusi sebelum ada perintah "execute". |
| Tanggal | 13 Nov 2026 |
| Acuan QA | Deck `04_BP_Confirmation_Type_Alias.pptx`, Opsi 1 (1 COA gabungan per alias) |
| Dasar teknis | Live test DEV 12 Nov 2026, analisa PRD 1 tahun (read-only); lihat `CHECKPOINT_ALIAS_MAPPING_ZQM002.md` bagian 8–11 |
| Data pendukung | `docs/Analisa_Alias_PRD_1Tahun.xlsx` |

---

## 1. Tujuan

Kalau beberapa tipe produksi punya alias yang sama dalam satu DO, sistem mencetak **1 COA gabungan per alias**.

Contoh DO 0085418364: 3 roll PLE6-18 (SRAANI) dan 3 roll PLE7-18 (SRAPAI) sama-sama beralias PLE-18. Hasilnya **1 COA PLE-18** berisi 6 roll:
- Properti, MIC, dan limit diambil dari mapping alias PLE-18 (material alias SRAAAI).
- Nilai tiap roll tetap ditelusuri dari JR/SR roll itu sendiri, lalu dirata-rata gabungan untuk seluruh roll.

Prinsip:
- **Jalur alias berjalan penuh dari awal sampai akhir (end-to-end), tidak ada hybrid.** Dalam satu COA gabungan, semua tipe produksi memakai mapping alias.
- **Hybrid hanya saat fallback.** Kalau jalur alias tidak bisa dipakai dengan bersih, setiap tipe produksi kembali ke perilaku sekarang: 1 COA per tipe produksi dengan mapping material sendiri.
- **Tidak ada kolom baru** di ZMAP_COA.
- Header Product tetap memakai nama alias (PLE-18).

## 2. Ringkasan Alur

```
DO → roll yang ada di DO
 └─ per roll: baca ZZALIAS → material alias (AMAT)
 └─ kelompokkan roll per (VBELN + AMAT)  ← calon COA gabungan
     └─ per tipe produksi (MATNR) dalam kelompok:
         ├─ baca ZMAP_COA material alias (umum + override customer)
         └─ terjemahkan MIC alias → MIC material batch
             (EXACT → RULE → SUFFIX → DESC)
     └─ keputusan per kelompok:
         ├─ SEMUA tipe produksi lolos → JALUR ALIAS
         │    nilai dibaca dari lot roll dengan MIC batch,
         │    lalu dikembalikan ke MIC alias dan dirata-rata gabungan
         │    → 1 COA per alias
         └─ ada pemicu fallback → JALUR AS-IS untuk setiap MATNR
              → 1 COA per tipe produksi (seperti sekarang)
```

## 3. Aturan Detail

### 3.1 Konversi alias → material alias

1. **ZZCODE.** Cari nilai alias di CAWNT-ATWTB (ATINN ZZCODE `0000000811`) untuk mendapatkan kode 3 karakter dari CAWN-ATWRT. Material alias = 2 karakter awal material batch (SR/JR) + kode + karakter terakhir material batch, dan harus ada di MARA. Contoh: HSS-18 → ACJ → SRACJI.
2. **MAKT.** Kalau langkah 1 gagal, ambil awalan teks MAKT material batch (semua kata kecuali kata terakhir, misalnya `SLITT ROLL `) lalu tambahkan alias. Cari MAKT-MAKTG dengan teks itu, dibatasi pada material yang 2 karakter awalnya sama. Awalan tidak di-hardcode.
3. **1 alias = 1 material alias** (dipastikan 13 Nov 2026). Tidak perlu aturan kandidat ganda; `SELECT SINGLE` seperti harness sudah cukup.
4. Kalau semua langkah gagal: **NOCONV**.
5. Kalau material alias sama dengan material batch: **SAME**. Jalur alias tetap jalan, dan terjemahan MIC-nya identitas.
6. Hasil konversi di-cache per (alias, prefix material).

ATINN dibaca lewat CONVERSION_EXIT_ATINN_INPUT, jangan di-hardcode. ZZALIAS `0000000844` sama di DEV dan PRD.

### 3.2 Mapping dari material alias (termasuk customer)

- Mapping umum (KUNNR kosong) dan override customer (KUNNR = LIKP-KUNAG) **dua-duanya dibaca dari material alias**. Aturan merge sama dengan as-is: field override menimpa, MIC baru di-append, dan LOWER/UPPER/SEQ yang kosong di override tidak menimpa.
- Mapping customer cukup dibuat sekali per **material alias + customer**.
- Mapping customer di material batch hanya terbaca saat fallback.
- Kalau mapping material alias kosong: **NOMAP**.

### 3.3 Terjemahan MIC alias → MIC batch (dua referensi + deskripsi cadangan)

Kamus MIC diambil dari inspection plan (MAPL PLNTY 'Q' → PLMK VERWMERKM/KURZTEXT) milik material batch, material alias, dan material JR pasangannya. Untuk setiap MIC di mapping alias, langkahnya dicoba berurutan:

| Urutan | Cara | Contoh |
|---|---|---|
| 1 | **EXACT**: MIC sama persis (MIC umum) | DATBERAT, HARDNESS, TREATED, STATIC* |
| 2 | **RULE**: prefix level + 3 karakter kode material batch (MATNR+2(3)) + 4 karakter akhiran properti, dan hasilnya ada di plan batch | PAAATSTD → PAANTSTD (PLE6) / PAPATSTD (PLE7) |
| 3 | **SUFFIX**: level dan akhiran sama, dan hanya ada tepat 1 kandidat di plan batch | |
| 4 | **DESC (cadangan)**: deskripsi properti sama setelah dinormalisasi (huruf besar, spasi dibuang), **dibatasi pada level yang sama** (S/P/A), dan hanya ada tepat 1 kandidat | SRFCUNTR keluarga PLE/PSL/PHL |
| 5 | **NONE**: tidak ketemu | memicu fallback |

- **Cek silang deskripsi.** Kalau MIC ketemu lewat RULE atau SUFFIX tetapi deskripsinya jelas berbeda dengan deskripsi MIC alias, hasil terjemahan tetap dipakai, tetapi diberi tanda `CHK` di log supaya bisa ditinjau. Pengecekan ini tidak membatalkan terjemahan.
- Terjemahan dibuat **per tipe produksi**. Setiap MIC alias harus punya padanan di setiap MATNR dalam kelompok.
- Atribut yang terbawa dari mapping alias: METHOD, MAPPING (sumber lot SR/JR), UOM, MIC_DESC, SEQ_NO, dan LOWER/UPPER (lihat 3.6).

### 3.4 Pengambilan nilai dan rata-rata gabungan

1. GET_TRACED_LOTS / GET_MIC berjalan per roll seperti sekarang, dan membaca QAMV dengan **MIC batch** hasil terjemahan. Traceability tidak berubah.
2. Setelah nilai terbaca, baris nilai diberi **kunci COA gabungan**:
   - `COA_MAT` = material alias (AMAT)
   - `COA_MIC` = MIC alias
   - MIC batch asli disimpan untuk detail dan trace.
3. Rata-rata (F01, saat ini per VBELN+MATNR+MIC) memakai kunci **VBELN + COA_MAT + COA_MIC** untuk jalur alias. Aturan deduplikasi lot yang sudah ada (INSLOT, GET_AVG_KEY untuk 1 grup JR-SR) tetap dipakai. Hasilnya rata-rata gabungan seluruh roll, bukan rata-rata dari rata-rata per tipe.
4. Untuk jalur as-is, `COA_MAT` = MATNR dan `COA_MIC` = MIC, sehingga perilakunya identik dengan sekarang.

### 3.5 Keputusan per kelompok dan fallback

Kelompok COA = **VBELN + AMAT**. Jalur alias hanya dipakai kalau **semua** tipe produksi dalam kelompok lolos.

| Kode | Pemicu fallback |
|---|---|
| NOALIAS | Roll tanpa ZZALIAS. Roll ini tidak masuk kelompok alias dan langsung dicetak as-is per MATNR |
| NOCONV | Alias tidak bisa dikonversi |
| NOMAP | Material alias tidak punya ZMAP_COA |
| NONE | Ada MIC alias (umum atau customer) yang tidak punya padanan di salah satu MATNR dalam kelompok |
| MIXED | Dalam satu MATNR (satu DO), roll-nya menghasilkan material alias yang berbeda, atau campur roll beralias dengan roll tanpa alias/NOCONV. Semua roll MATNR itu dicetak per tipe produksi, dan kelompok alias yang memuat MATNR itu ikut fallback (diputuskan 13 Nov 2026) |
| LIMIT | Hanya untuk mode limit L3 (lihat 3.6): limit asli antar tipe produksi berbeda |

- Kalau ada satu pemicu saja di kelompok, **seluruh kelompok** fallback. Setiap MATNR dicetak terpisah dengan mapping material batch (kode as-is). Inilah satu-satunya kondisi hybrid.
- Tidak ada fallback per MIC atau per roll.
- Kalau mapping material batch juga kosong, pesan dan STOP yang sudah ada tetap berlaku (`Material belum dimapping di ZMAP_COA...`).

### 3.6 Limit: dua opsi (menunggu keputusan QA)

QA belum memutuskan limit (lower/upper) mana yang dicetak di COA gabungan (deck, pertanyaan 3). Ketiga opsi dicatat di sini. **Yang diimplementasikan hanya opsi yang dipilih QA**, tanpa parameter pemilih dan tanpa kolom baru.

**Opsi A — Limit dari MIC alias (kode L1)**
- LOWER/UPPER diambil dari ZMAP_COA material alias (PLE-18). Kalau kosong, pakai spec MIC alias (QPMK material alias).
- Satu limit untuk seluruh COA, jadi perbedaan limit antar tipe produksi tidak relevan.
- Sama dengan perilaku program sekarang (limit dari mapping), sehingga perubahannya paling kecil.

**Opsi B — Limit dari MIC asli material (spec batch)**
- LOWER/UPPER diambil dari spec MIC batch di **inspection plan** (PLMK) masing-masing tipe produksi, juga untuk Opsi C (diputuskan 13 Nov 2026). LOWER/UPPER di ZMAP_COA material alias diabaikan.
- Kalau limit PLE6 dan PLE7 berbeda (contoh Tensile TD 22–35 vs 22–40), QA perlu memilih satu sub-opsi:
  - **B1 – Terketat (kode L2):** lower terbesar, upper terkecil → 22–35. Kalau tidak beririsan (lower > upper), diperlakukan seperti B2.
  - **B2 – Tolak (kode L3):** COA gabungan ditolak dengan pesan berisi daftar MIC yang berbeda. Kelompok jatuh ke fallback per tipe produksi (pemicu LIMIT).

**Opsi C — Rata-rata limit MIC asli antar tipe produksi (kode L4)** — usulan user, 13 Nov 2026
- Sumber sama dengan Opsi B (spec MIC batch per tipe produksi). Lower dan upper masing-masing dirata-rata.
- Contoh PLE-18:

| MIC alias | PLE6-18 | PLE7-18 | B1 (terketat) | C (rata-rata) |
|---|---|---|---|---|
| Tensile TD (PAAATSTD) | 22–35 | 22–40 | 22–35 | 22–**37.5** |
| COF Dyn (PAAAFDNT) | 0.3–0.5 | 0.3–0.45 | 0.3–0.45 | 0.3–**0.475** |
| MIC lain (limit sama) | sama | sama | sama | sama |

- **Aturan hitung = aturan rata-rata nilai tanpa alias** (diputuskan 13 Nov 2026):
  1. **Bobot:** sama dengan rata-rata nilai, yaitu per inspection lot unik yang punya hasil (dedup INSLOT, 1 grup JR-SR dihitung 1x lewat GET_AVG_KEY). Jadi limit tertimbang jumlah lot/roll per tipe. Contoh Tensile TD: 3 lot PLE6 + 3 lot PLE7 → (3×35 + 3×40)/6 = 37.5; 4 lot PLE6 + 2 lot PLE7 → 36.67. Contoh di tabel atas memakai jumlah lot sama. Kalau tidak ada lot yang punya hasil untuk MIC itu, tiap tipe berbobot 1.
  2. **Desimal:** sama dengan nilai rata-rata, yaitu format desimal MIC (MICFMT), dibulatkan. Tensile TD 0 desimal → 37.5 tercetak **38**, 36.67 tercetak **37**; COF Dyn 2 desimal → 0.475 tercetak **0.48**.
- Risiko yang harus disetujui QA:
  - Limit hasil rata-rata **tidak ada di spec SAP mana pun** (bukan spec PLE6, PLE7, maupun mapping PLE-18), sehingga perlu penjelasan kalau ditanya customer/auditor.
  - Roll yang di luar spec aslinya bisa tampil masih dalam limit. Contoh: Tensile TD roll PLE6 = 36 → out of spec PLE6 (upper 35), tapi masih ≤ 37.5 di COA gabungan. Pada B1 hal ini tidak terjadi.
- Dampak program: kecil, varian dari Opsi B (data sama, hanya rumus berbeda).

- **Sisi limit kosong** di salah satu tipe produksi (diputuskan 13 Nov 2026, mengikuti sifat opsi): B1 pakai limit yang ada; B2 menganggapnya beda sehingga COA tidak digabung; C merata-rata hanya dari tipe yang punya nilai; A tidak terpengaruh (sisi kosong di mapping alias diisi spec QPMK MIC alias).
- Data PRD 1 tahun: 4,2% batch punya limit alias yang berbeda dengan spec batch (MFB-13, HSB-17.6, PFL-38, SPO-13). Pada contoh PLE-18, limit PLE6 dan PLE7 berbeda di Tensile TD dan COF Dyn.

### 3.7 Pemilihan roll dan cetak (EXEC)

- Validasi `Tipe film tidak boleh berbeda!` diganti dengan **validasi kelompok**:
  - Semua roll yang dipilih berada dalam satu kelompok alias berstatus jalur alias → boleh lebih dari 1 MATNR, dan dicetak 1 COA.
  - Selain itu (ada roll as-is, kelompok fallback, atau AMAT berbeda) → aturan lama berlaku: hanya 1 MATNR, dan pesannya tetap `Tipe film tidak boleh berbeda!`.
- Header Product: kumpulkan alias dari **semua roll terpilih** di kelompok, bukan hanya dari `LV_PRODUCT_MATNR`. Hasilnya PLE-18.
- Batch list / lampiran roll: berisi semua roll kelompok (PLE6 dan PLE7). Kolom TYPE tetap alias.
- Pesan info (TYPE 'S'):
  - Jalur alias: `COA gabungan alias <ALIAS> (<AMAT>), <n> tipe produksi`
  - Fallback: `Alias <ALIAS> dicetak per tipe produksi: <KODE>`
- Simpan log alasan (VBELN, MATNR, CHARG, ALIAS, AMAT, STATUS, MIC alias, MIC batch, HOW) supaya bisa dibaca saat investigasi.

### 3.8 ZQM003 (report ALV per batch) — diputuskan 13 Nov 2026

ZQM003 adalah representasi print COA yang dipecah per batch. Saat ini barisnya per batch (IT_MIC1: CHARG, MATNR, ZZTYPE, INSLOT), tapi nilainya adalah rata-rata COA per VBELN+MATNR+MIC (LT_FINAL, ALV ±162–216), sama dengan nilai yang dicetak ZQM002. Prinsip ini dipertahankan: **angka di ZQM003 harus sama dengan angka di COA yang dicetak.**

- **Baris tetap per batch.** CHARG, MATNR asli, dan ZZTYPE tetap tampil, supaya QA tahu batch mana berasal dari tipe produksi mana.
- **Kolom mengikuti COA gabungan** untuk kelompok jalur alias:
  - MIC + deskripsi = MIC alias.
  - Limit = sesuai opsi limit yang dipilih (sama dengan print).
  - Method dan urutan SEQ_NO = dari mapping material alias (+ override customer).
  - Nilai = rata-rata gabungan dengan kunci VBELN + COA_MAT + COA_MIC.
  - ZLOG_COA dibaca dengan MIC alias (sama dengan print).
- **Kolom baru:**
  - `COA_MAT` (Material COA): material alias, atau MATNR pada jalur as-is/fallback.
  - `COA_PATH` (Status jalur): `ALIAS` atau kode fallback (`NOALIAS`, `NOCONV`, `NOMAP`, `NONE`, `MIXED`, `LIMIT`).
  - `BATCH_MIC` (MIC asli batch): **tersembunyi** (NO_OUT), bisa dimunculkan lewat layout untuk investigasi.
- **Jalur as-is/fallback:** COA_MAT = MATNR dan COA_MIC = MIC, sehingga tampilan dan nilai identik dengan sekarang (kecuali tambahan kolom).

## 4. Dampak Berdasarkan Data PRD 1 Tahun

Data: batch 11 Nov 2025 – 12 Nov 2026, sampel 20%, top 54 alias (95% batch beralias), dihitung dengan bobot batch.

| Jalur | Porsi | Catatan |
|---|---|---|
| Jalur alias, MIC terjemah penuh | 69,2% | Termasuk 4,2% dengan limit alias berbeda dari spec batch |
| Fallback NONE | 12,6% | PSL-17, MF-20, PL-20, LCAH-24, MA91-50; sebagian SRFCUNTR tertolong oleh DESC per level |
| Fallback NOCONV | 18,2% | 19 alias (E5102, E5202, GLOSS-*, MATTE, DOFF-*, OL-20, KMM, ...) |

Angka ini dihitung per pasangan alias–material. Untuk COA gabungan, kelompok fallback kalau **salah satu** tipe produksinya gagal, jadi porsi jalur alias di level DO bisa sedikit lebih kecil.

## 5. Persiapan Go-Live (Master Data)

ZMAP_COA **belum ada di PRD** (baru di DEV AIX). QA perlu membuat, masing-masing umum dan per customer kalau ada:

1. **Mapping material alias** untuk alias yang lolos konversi (±35 alias; sheet "Konversi Alias").
2. **Mapping material batch** untuk alias yang fallback dan untuk roll tanpa alias.

Perlu dicek functional:
- Material batch tanpa inspection plan: SRCBUO, SRCBUX, SRXICI, SRXIHI, SRXIJI.
- Material alias tanpa lot/plan: EP-9 → SRCABX.

## 6. Pertanyaan yang Harus Dijawab QA Sebelum Execute

1. Opsi 1 (1 COA gabungan per alias), dengan rata-rata gabungan seluruh roll? (Deck, pertanyaan 1–2.)
2. Limit: Opsi A (MIC alias), Opsi B (MIC asli: B1 terketat / B2 tolak), atau Opsi C (rata-rata limit asli, dihitung dengan aturan rata-rata nilai)? (Bagian 3.6, deck pertanyaan 3.)
3. Setuju dengan fallback per kelompok ke 1 COA per tipe produksi (bagian 3.5)?
4. Untuk perbedaan penamaan properti (MF-20 NM/MT, MA91-50 SW3YFEP*, LCAH-24 SIBESTTN): cukup fallback, atau QA menyediakan tabel padanan?
5. Isi kolom kuning di Excel (alias NOCONV): apakah ada alias yang seharusnya punya material alias?
6. Ejaan alias tidak konsisten (`KTM-12`, `KTM.12`, `KTM.`, `GLOSS.`): perlu normalisasi atau master alias? Cek juga apakah tabel `ZMAP_TYPE` (kolom ALIAS, mapping COA Trias) bisa dipakai.
7. ~~Kalau satu alias menghasilkan beberapa material alias?~~ Tidak perlu: dipastikan 1 alias = 1 material alias (13 Nov 2026).
8. Header: nama alias saja, atau alias + tipe produksi? (Deck, pertanyaan 5; rancangan ini memakai nama alias saja.)

## 7. Rencana Implementasi (saat "execute")

> Rancangan kode per titik (FORM baru, perubahan per baris, tiga opsi limit): [RANCANGAN_PROGRAM_ALIAS_ZQM002.md](RANCANGAN_PROGRAM_ALIAS_ZQM002.md).
>
> Pra-syarat: **re-fetch source DEV AIX terbaru** sebelum edit. Uji dulu lewat subroutine pool (harness `scripts/mt_pool_build.mjs` + `mt_run_suite.mjs`) sebelum menyentuh program.

Referensi baris mengikuti `src/ZQMI_COA_F01_group.abap` dan `src/ZQMI_COA_F02_group.abap` per 13 Nov 2026; verifikasi ulang setelah re-fetch.

| # | Langkah | Lokasi |
|---|---|---|
| 1 | Tambah field internal `COA_MAT`, `COA_MIC`, `BATCH_MIC` di struktur IT_DATA (type internal, bukan DDIC). Tambah tabel kelompok (VBELN, AMAT, ALIAS, STATUS), tabel terjemahan (VBELN, MATNR, MIC alias, MIC batch, HOW, CHK), dan log | TOP |
| 2 | FORM baru `ALIAS_RESOLVE` sebelum loop mapping (sebelum baris 362): konversi alias per roll, bentuk kelompok VBELN+AMAT, baca mapping alias, terjemahkan MIC per MATNR, tetapkan STATUS kelompok (termasuk LIMIT untuk mode L3). Cache per (AMAT, MATNR, KUNNR) | F01 |
| 3 | Build IT_ZMAP (baris 393–451): kalau kelompok jalur alias, isi IT_ZMAP dari hasil terjemahan untuk MATNR roll tersebut; selain itu as-is | F01 ±446 |
| 4 | Re-read METHOD (baris 594–612): untuk jalur alias, ambil dari tabel terjemahan | F01 ±594 |
| 5 | Setelah nilai terbaca, isi COA_MAT/COA_MIC (alias atau as-is), lalu ubah kunci sort, dedup, dan rata-rata (baris 642–734) menjadi VBELN + COA_MAT + COA_MIC | F01 ±642 |
| 6 | Limit sesuai opsi yang dipilih QA (A, B1, B2, atau C; lihat 3.6) saat mengisi MICMIN/MICMAX | F01 (blok limit) |
| 7 | READ `LT_COA_MAP` (baris 752) dengan kunci COA_MAT/COA_MIC | F01 ±752 |
| 8 | EXEC: validasi kelompok menggantikan cek MSTAT, header alias dari semua roll terpilih, pesan info. Cek QPMK MAX(VERSION) dan MICFMT memakai MIC alias, dengan fallback ke MIC batch kalau MIC alias tidak ada di plant | F02 baris 54–250 |
| 9 | Pastikan F_PRINT, DOWNLOAD_DETAIL, DOWNLOAD_BATCH_LIST_XLSX, PREPARE_DYNAMIC_ROLL_COLUMNS, dan VB_BATCH_GET_DETAIL tetap memakai MATNR+CHARG asli roll (bukan COA_MAT), dan batch list mencakup semua MATNR kelompok | F01 / F02 |
| 10 | Port dan perbaiki logic harness `tests/alias_live/zz_alias_form.abap`: kelompok VBELN+AMAT, pemicu NONE/MIXED/LIMIT, DESC per level, cek silang deskripsi, pilihan material ganda | — |
| 11 | Header lebar (ZZWIDTH) di EXEC dikumpulkan dari semua roll kelompok (IT_LOT), bukan hanya dari batch wakil di baris MIC | F02 ±100–125 |
| 12 | ZLOG_COA (override nilai): simpan dan baca dengan MIC sesuai jalur (alias → MIC alias, fallback/as-is → MIC batch). Tidak ada warning, blok, atau lookup kedua (lihat 9.3 #2) | F01 ±780, F02 ±930 |
| 13 | ALV: tambah kolom internal `COA_MAT` (material alias) supaya baris gabungan terbaca; DOWNLOAD/DOWNLOAD_DETAIL ikut menampilkan COA_MAT dan MIC batch | ALV ±409, F01 1129/1264 |
| 14 | Tidak ada perubahan DDIC ZMAP_COA, ZLOG_COA, ZQM001, maupun layout Smartform | — |
| 15 | ZQM003 (§3.8): TY_ALVR tambah COA_MAT, COA_PATH, BATCH_MIC (NO_OUT); kunci LT_UNIQUE/LT_FINAL, LT_SEQ, LT_METHOD dan READ LT_FINAL diganti MATNR/MIC → COA_MAT/COA_MIC; MIC/MICDES/limit dari MIC alias; field catalog | ALV ±4–24, 152–216, 255–274, 286–345, fieldcat |

## 8. Rencana Uji

1. **Regresi:** L-QM01–15 + ML-QM01–04 harus identik dengan baseline (DO tanpa alias atau fallback), baik output ZQM002 maupun ZQM003 (abaikan kolom baru COA_MAT/COA_PATH).
2. **Skenario alias** (mapping di-inject lewat harness atau dibuat di DEV):

| ID | Skenario | Ekspektasi |
|---|---|---|
| AL-01 | DO 0085418364: PLE6-18 (SRAANI) + PLE7-18 (SRAPAI), mapping SRAAAI lengkap | 1 COA PLE-18, 6 roll; nilai = rata-rata gabungan; MIC/properti dari PLE-18 |
| AL-02 | Sama dengan AL-01, sesuai opsi limit yang dipilih | A: limit PLE-18. B1: terketat (Tensile TD 22–35, COF Dyn 0.30–0.45). B2: ditolak, fallback 2 COA. C: rata-rata tertimbang lot seperti rata-rata nilai (lot PLE6 = PLE7 → Tensile TD 22–37.5, COF Dyn 0.3–0.475), tercetak sesuai desimal MIC; cocokkan dengan hitungan manual dari jumlah lot DO |
| AL-03 | Satu tipe produksi saja (HSS-18, SRAC2I → SRACJI) | 1 COA jalur alias; nilai sama dengan baseline |
| AL-04 | Kelompok PLE-18, salah satu MATNR punya MIC tanpa padanan | Fallback NONE: 2 COA per tipe produksi, mapping material sendiri |
| AL-05 | Alias NOCONV (mis. GLOSS-18) | Fallback, identik dengan as-is, pesan tampil |
| AL-06 | Material alias tanpa ZMAP_COA | Fallback NOMAP |
| AL-07 | Override customer di material alias | Override terpakai di COA gabungan |
| AL-08 | Pilih roll jalur alias + roll as-is bersamaan | Ditolak `Tipe film tidak boleh berbeda!` |
| AL-09 | Terjemahan lewat DESC, dan RULE dengan deskripsi berbeda | DESC terpakai; RULE diberi tanda CHK di log |
| AL-10 | Mapping alias dan mapping batch dua-duanya kosong | STOP dengan pesan "Material belum dimapping" |
| AL-11 | ZQM003 untuk DO AL-01 | 6 baris batch per MIC alias (CHARG + MATNR asli PLE6/PLE7); nilai, limit, dan MIC sama persis dengan COA AL-01; COA_MAT = SRAAAI, COA_PATH = ALIAS |
| AL-12 | ZQM003 untuk DO fallback (AL-04/AL-05) | Tampilan dan nilai identik dengan sekarang; COA_MAT = MATNR, COA_PATH = kode fallback |

3. Bandingkan dengan simulasi PRD (`outputs/alias_recent_20261112/`) untuk HSS-18, HLS-18, dan HSL-21.

## 9. Analisa Impact ke Program Sekarang (13 Nov 2026)

Dasar: source DEV AIX hasil fetch 12 Nov 2026 (`outputs/ZQMI_COA_*_Development AIX_alias20261112.abap`), yang isinya sama dengan `src/*_group.abap`. Program: ZQMI_COA = TOP (380 baris) + F01 (4.847) + F02 (1.117) + ALV (431). **ZQM002 dan ZQM003 memakai program yang sama** (dibedakan lewat `SY-TCODE`).

### 9.1 Titik yang tersentuh

| # | Area | Baris (DEV) | Sifat perubahan | Impact | Risiko regresi |
|---|---|---|---|---|---|
| 1 | Resolve alias, terjemahan MIC, keputusan kelompok | FORM baru | Kode baru ±350–450 baris (port harness ±280 baris + kelompok + mode limit) | Besar dari sisi volume, tapi terisolasi | Rendah: hanya aktif untuk roll beralias |
| 2 | Build IT_ZMAP per roll | 393–451 | Kait 1 PERFORM, isi IT_ZMAP dari hasil terjemahan | Kecil | Rendah |
| 3 | Re-read METHOD | 594–612 | Untuk jalur alias, ambil dari tabel terjemahan | Kecil | Rendah |
| 4 | **Rata-rata nilai** (sort, dedup INSLOT, GET_AVG_KEY, average) | 642–734 | Kunci VBELN+MATNR+MIC menjadi VBELN+COA_MAT+COA_MIC | **Sedang, inti** | **Tinggi**: semua DO lewat kode ini |
| 5 | Pasang SEQ/CHK dari LT_COA_MAP, SELMAPPING | 460–469, 752, 1642 | Kunci ikut COA_MAT/COA_MIC | Kecil | Sedang (ikut #4) |
| 6 | Limit Opsi A / B / C (3.6) | blok limit GET_MIC + rata-rata | Opsi A = perilaku sekarang (limit dari mapping). Opsi B dan C perlu kumpulkan spec MIC batch per tipe produksi saat merge | Sedang | Rendah kalau QA pilih Opsi A |
| 7 | EXEC: validasi `Tipe film tidak boleh berbeda!` | F02 ±236–242 | Diganti validasi kelompok | Kecil | Rendah |
| 8 | EXEC: header alias | F02 ±190 (`WHERE MATNR = LV_PRODUCT_MATNR`) | Loop semua MATNR kelompok | Kecil | Rendah |
| 9 | EXEC: header lebar (ZZWIDTH) | F02 ±100–125 | Lebar diambil dari CHARG baris MIC (batch wakil). Pada COA gabungan, batch wakil bisa hanya dari satu tipe produksi, jadi perlu diambil dari semua roll kelompok | Kecil | Sedang |
| 10 | QPMK MAX(VERSION), MICFMT (desimal) | F02 ±80, ±270 | Pakai MIC alias, fallback ke MIC batch kalau MIC alias tidak ada di plant | Kecil | Rendah |
| 11 | **ZLOG_COA (override nilai manual)** | F01 ±780–806, F02 ±930–1010 | Kunci VBELN+PRUEFLOS+MIC+KUNNR. Baris gabungan memakai MIC alias + lot batch wakil | Kecil | Rendah: mapping dipastikan lengkap sebelum dipakai; perubahan mapping setelah override = perilaku as-is (lihat 9.3 #2) |
| 12 | ALV + download | ALV ±409, F01 1129, 1264 | Tambah kolom COA_MAT | Kecil | Rendah |
| 13 | Print / batch list | F01 1661–2050 | `LT_ROLL_LOT = IT_LOT`, berisi semua roll DO (tidak difilter MATNR). Untuk COA gabungan tidak perlu diubah | Tidak ada | — |
| 14 | ZQM003 (report ALV) | ALV ±152–345 + fieldcat | Baris tetap per batch; MIC/limit/method/nilai ikut COA gabungan; tambah COA_MAT, COA_PATH, BATCH_MIC (tersembunyi) — lihat §3.8 | Kecil | Rendah (jalur as-is identik) |
| 15 | DDIC, ZQM001, Smartform | — | Tidak berubah | Tidak ada | — |

### 9.2 Kesimpulan impact

- **Skala: sedang.** Sebagian besar kode baru terisolasi di FORM tersendiri. Perubahan di kode lama sekitar 60–100 baris di ±10 titik.
- **Risiko utama ada di rata-rata (#4) dan baris wakil (#9, #11).** Setelah rata-rata, satu baris per MIC memegang MATNR/CHARG/INSLOT roll pertama. Selama ini aman karena satu baris = satu material. Pada COA gabungan, baris itu mewakili beberapa material, jadi semua fungsi yang memakai MATNR/CHARG/INSLOT dari baris MIC harus dicek: EXEC width, VB_BATCH_GET_DETAIL, ZLOG_COA, dan download.
- **Mitigasi regresi:** untuk jalur as-is, `COA_MAT = MATNR` dan `COA_MIC = MIC`, sehingga sort dan average menghasilkan urutan dan angka yang identik. Ini dibuktikan dengan suite regresi L-QM01–15 + ML-QM01–04 (bandingkan output harness sebelum/sesudah, harus 100% identik) sebelum skenario AL dijalankan.
- **Perkiraan kerja:** pengembangan 3–4 hari (harness dulu, lalu program), pengujian 2–3 hari (regresi + AL-01..10 + uji user QA). Ini perkiraan kasar, dan belum termasuk pembuatan mapping alias oleh QA.

### 9.3 Keputusan tambahan yang dibutuhkan

1. ~~**ZQM003:** ikut gabungan atau per tipe produksi?~~ **Diputuskan 13 Nov 2026:** baris tetap per batch, kolom dan nilai ikut COA gabungan (§3.8).
2. ~~**ZLOG_COA:** warning atau blok kalau jalur DO berubah?~~ **Diputuskan 13 Nov 2026: tidak perlu keduanya.** Alasannya:
   - Belum go-live, dan ZLOG_COA belum ada di PRD, jadi tidak ada override lama dengan MIC batch yang bisa hilang saat alias aktif.
   - Mapping material alias dipastikan sudah dimaintain sebelum DO dicetak, jadi DO tidak berpindah dari fallback (NOMAP) ke alias di tengah jalan.
   - Kalau QA mengubah atau menghapus mapping setelah ada override, override dengan MIC lama tidak terbawa. Ini **sama dengan perilaku sekarang** (mengganti MIC di ZMAP_COA juga memutus override lama), jadi bukan risiko baru. Aturan operasional: *ubah mapping setelah ada override = override diisi ulang*.

