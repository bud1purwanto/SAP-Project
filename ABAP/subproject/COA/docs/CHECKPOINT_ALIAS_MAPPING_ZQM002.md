# CHECKPOINT — Mapping ZMAP_COA Berbasis Alias (ZQM002)

| Atribut | Isi |
|---|---|
| Tanggal | 2026-11-11 |
| Status | **Rencana / desain — belum ada perubahan program** (menunggu konfirmasi QA, lalu perintah "execute" dari Baginda) |
| Program terdampak (rencana) | `ZQMI_COA_F01` (versi `_group`, sandbox-new) — bagian pembacaan `ZMAP_COA` & `LT_COA_MAP` |
| Data dicek | Development AIX (TRD) & Production AIX — **read-only** |
| Bukti data | `outputs/alias_mapping_20261111/` (`prd_alias_to_material_sample.json`, `prd_mic_compare.json`, `prd_alias_counts_sample50k.json`) |
| Deck QA | `docs/Alias_COA_Opsi_QA.pptx` (12 Nov, dipakai untuk konfirmasi). Deck lama `docs/Alias_Mapping_ZQM002_QA.pptx` terlalu teknis, tidak dipakai. |

## 0. Revisi 12 Nov 2026 — keputusan utama sebelum desain

Hasil diskusi dengan leader: ada beda persepsi dari blueprint confirmation. Desain di bagian 5 belum bisa dipakai sebelum QA memilih salah satu opsi.

**Kasus:** 1 DO berisi SRAANI (PLE6-18) dan SRAPAI (PLE7-18), keduanya alias PLE-18. Data PRD (lot Z04): 9 MIC dengan deskripsi dan limit yang sama, tapi kode MIC berbeda (`SAANSTTR` vs `SAPASTTR`, `SRFCUNTR` vs `SAPASTNT`). Contoh terakhir menunjukkan pencocokan lewat akhiran 4 huruf tidak selalu berhasil, jadi pencocokan harus lewat deskripsi.

**As-is (dicek di `ZQMI_COA_F02_group.abap`, USER_COMMAND_0100 EXEC):**
- 1 print = 1 DO + 1 material. Kalau material berbeda: `'Tipe film tidak boleh berbeda!'`.
- Value per MIC = rata-rata baris roll terpilih (`MICMIT / CTR`).
- Header `PRODUCT` = alias unik roll material itu, digabung koma (`HSP-18, HSS-18`).
- Jadi kondisi sekarang sama dengan **Opsi 2**.

| | Opsi 1: 1 COA per alias | Opsi 2: COA per tipe produksi |
|---|---|---|
| Jumlah COA | 1 (PLE-18) | 2 (header keduanya PLE-18) |
| Mapping | 1 mapping untuk alias | Per tipe produksi (as-is) |
| Value | Rata-rata semua roll lintas tipe | Rata-rata roll satu tipe |
| Traceability | Per roll, angka COA gabungan | Per roll dan per tipe, terpisah |
| Spec beda (GLOSS, KZMB-9) | Rata-rata bisa menutupi roll keluar spec; perlu aturan limit atau blokir | Aman |
| Perubahan program | Besar: izinkan beda material bila alias sama, cocokkan MIC lintas material, mapping per alias | Minimal / tidak ada |

Kalau QA memilih Opsi 2, desain di bagian 5 (mapping berbasis alias) tidak diperlukan.

## 1. Permintaan User

- **Alias** (karakteristik batch `ZZALIAS`) menjadi patokan utama pencarian mapping di `ZMAP_COA`.
- Alias biasanya berisi `FTYPE + THICKNESS`. Alias dikonversi ke material, lalu dari material itu diambil mappingnya.
- **Material atau FTYPE berbeda tetapi alias sama → 1 mapping yang sama.**

## 2. Kondisi Sekarang (as-is)

Mapping dibaca per **DO item** dengan kunci material DO + Sold-to (`ZQMI_COA_F01_group.abap:399-444`):

1. `ZMAP_COA` dengan `MATNR = material DO`, `KUNNR = LIKP-KUNAG`, dan `DELETION <> 'X'` (mapping customer)
2. `ZMAP_COA` dengan `MATNR = material DO`, `KUNNR = ' '`, dan `DELETION <> 'X'` (mapping umum)
3. Override per MIC: customer menimpa umum. Lower/Upper/SEQ_NO hanya ditimpa kalau terisi.
4. Hasilnya disimpan di `LT_COA_MAP` dengan kunci `VBELN + MATNR + MIC`.

Alias saat ini **hanya dipakai untuk Product Name** di header COA, tidak untuk mapping.

## 3. Temuan Data

### 3.1 FTYPE + THICKNESS tersimpan di material (DEV)

| Material | MAKT | ZZCODE | CAWNT-ATWTB (ZZCODE) |
|---|---|---|---|
| SRACBI | SLITT ROLL HSB4-18 | ACB | HSB4-18 |
| SRCASI | SLITT ROLL EPB-12 | CAS | EPB-12 |
| SREASI | SLITT ROLL MZOB-50 | EAS | MZOB-50 |
| SRALZI | SLITT ROLL PWLMI7-70 | – | – |

FTYPE-THICK pada material tersedia dari dua sumber: **ZZCODE-ATWTB** (terstruktur) dan **MAKT** (teks dengan awalan `SLITT ROLL `).

### 3.2 Hanya sebagian alias yang cocok dengan FTYPE material (DEV)

| Alias | ZZCODE-ATWTB / MAKT |
|---|---|
| HSS-18 | ✅ SRACJI (`SLITT ROLL HSS-18`) |
| HSB-18, HSP-18, `HS - 18 M` | ❌ tidak ditemukan |

### 3.3 PRD: alias sama, material beda

Sampel 50.000 nilai `ZZALIAS` (AUSP, ATINN 0000000844) berisi 131 alias unik. Dari 45 alias teratas diambil 8 batch per alias dan ditelusuri materialnya lewat INOB:

| Alias | Material (MAKT) |
|---|---|
| GLOSS | SRIBRI (LCAT-24), SRIARI (LC01-22) |
| LC02 | SRIARI (LC01-22), SRIASI (LC02-20) |
| LF01 | SRICRI (LF01-25), SRKYGI (TLF01-25) |
| KZMB-9 | SREWCI (ZMB-9), SRKPKI (TZMB-9), SREUAI (ZB-9) |
| VMPET-9 | SRKPKI (TZMB-9), SREUAI (ZB-9) |

Ditemukan juga kebalikannya: **satu material dipakai banyak ejaan alias**. Contoh: SRCADI dipakai oleh `KTM-12`, `KTM`, `GP/FDW`, `PPF-12`, `IF-12`. SRCAHI dipakai oleh `KTM.12` dan `KTM.`. Isi alias tidak konsisten (ada titik, spasi, dan versi dengan/tanpa ketebalan).

### 3.4 PRD: perbandingan MIC antar material dengan alias sama

Sumber: QAMV dari lot Z04 terakhir per material.

| Alias | Kode MIC | Deskripsi MIC | Limit |
|---|---|---|---|
| GLOSS (SRIBRI vs SRIARI) | `SIBR*` vs `SIAR*` → **beda** | Sama (Seal to Paper, Surface Tension Non Th/Thermal) | **Beda**: Seal to Paper 3.5–6.5 vs 3.0–5.5 |
| LC02 (SRIARI vs SRIASI) | `SIAR*` vs `SIAS*` → **beda** | Sama | Sama |
| LF01 (SRICRI vs SRKYGI) | `SICR*` vs `SKYG*` → **beda** | Sama | Sama |
| KZMB-9 (SREWCI vs SRKPKI) | `SEWC*` vs `SKPK*` → **beda** | Sama | **Beda**: Optical Density 2.7–3.3 vs 3.0–3.5 |

Pola kode MIC: `S` + kode film material (3–4 huruf) + akhiran properti 4 huruf (`SPTH`, `STNE`, `STTH`, `ODMZ`, …). MIC umum (`DATBERAT`, `HARDNESS`, `STATIC*`, `THERMALS`, …) sama di semua material.

`ZMAP_COA` di PRD untuk 8 material di atas: **0 baris** (belum ada mapping di PRD).

### 3.5 Dampak ke desain

> **Kode MIC berbeda per material.** Kalau mapping material alias (misalnya SRIARI, MIC `SIARSPTH`) dipakai untuk batch SRIBRI, maka MIC itu **tidak ada di inspection lot batch** (yang ada `SIBRSPTH`). Program sekarang mencocokkan nilai dengan kode MIC persis, sehingga hasilnya Value kosong dan limit jatuh ke QPMK.

Artinya, mapping berbasis alias **wajib** punya aturan pencocokan MIC antar material, misalnya berdasarkan akhiran properti atau deskripsi.

## 4. Traceability

- **Tidak berubah.** Batch, material, inspection lot, dan genealogi tetap memakai material asli batch (`LIPS-MATNR` / `MCH1`). Nilai hasil (Value) tetap dibaca dari lot batch itu sendiri.
- Yang berubah hanya **tampilan COA**: daftar MIC, urutan (SEQ_NO), deskripsi, method, UOM, dan limit diambil dari mapping alias.
- **Risiko:** limit spec material asli bisa berbeda dengan limit di mapping alias (contoh GLOSS: 3.5–6.5 vs 3.0–5.5). Kalau mapping alias tidak mengisi Lower/Upper, limit akan ikut MIC material asli batch. Perlu keputusan QA: limit mana yang tercetak di COA.

## 5. Desain (rencana)

### 5.1 Konversi alias → material (pendekatan A, disetujui Baginda)

1. `CAWNT-ATWTB = alias` dengan ATINN = ZZCODE → nilai ZZCODE → material lewat `AUSP`/`INOB` (KLART 023, OBTAB MARA).
2. Kalau tidak ketemu: `MAKT-MAKTX = <awalan MAKT material DO> + alias` (contoh `SLITT ROLL HSS-18`).
3. Kalau ketemu lebih dari satu material: batasi ke awalan MATNR yang sama dengan material DO (SR/JR). Kalau masih lebih dari satu, pilih yang punya `ZMAP_COA`. Kalau masih lebih dari satu juga, ambil MATNR terkecil dan tampilkan warning.
4. Hasil di-cache per alias.

### 5.2 Hierarki mapping (per batch, disetujui Baginda)

```
Batch punya alias & berhasil dikonversi → MATNR_ALIAS
  ├─ ZMAP_COA ada untuk MATNR_ALIAS → pakai (KUNNR override per MIC → umum)
  └─ tidak ada                       → fallback ↓
Material DO (logic sekarang): MATNR_DO + KUNNR → MATNR_DO umum
```

- Alias kosong atau gagal dikonversi → pakai logic material DO, ditambah **warning** kalau alias ada tetapi gagal dikonversi (disetujui Baginda).
- Mapping material alias dan mapping material DO **tidak digabung**.
- Batch dengan alias berbeda dalam 1 DO → mapping **per batch** (disetujui Baginda). Kunci `LT_COA_MAP` ditambah `CHARG`.

### 5.3 Konversi MIC mapping alias → MIC lot asli (dianalisa di PRD, 12 Nov)

Usulan Baginda: MIC di mapping alias dikonversi ke MIC material asli memakai pola kode.
- SR (lot Z04): `S` + 3 huruf tengah material + akhiran properti (SRAANI → `SAAN` + `STTR`)
- JR (lot Z02/Z03): `P` + 3 huruf tengah material + akhiran properti (JRAPAI → `PAPA` + `DTTR`)

**Hasil cek PRD** (lot Aug–Nov 2026, sampel 45 material SR + 45 material JR; bukti `outputs/alias_mapping_20261111/prd_mic_pattern_sample.json`):

| | SR (Z04) | JR (Z02) |
|---|---|---|
| MIC ikut pola | 314 | 823 |
| MIC umum, kode sama di semua material | 306 | 52 |
| MIC tidak ikut pola | 20 | 55 |
| Material dengan pengecualian nyata | 4/45 (SRECVI→`SW3Y`, SRICLI→`SKYR`, SRGAGI→`ZGAG`, SRGAFI→`ZGAF`) | ±6/45 (JRABNI→`PW4R`, JRVCWI→`PW2R`, JRECZI→`PW3M`, JRG1SI→`SG1S`/`PAG1`, JRGAFI→`RGAF`) |
| Akhiran properti unik dalam 1 lot | 90/90 lot | |

Pengecualian terjadi karena material memakai MIC milik material lain (inspection plan dipakai bersama) atau prefix `Z`/`R`.

**Simulasi pada pasangan alias nyata:** SRIARI↔SRIBRI, SRIARI↔SRIASI, SRICRI↔SRKYGI, SREWCI↔SRKPKI, dan SRAANI→SRAPAI semuanya 100% ketemu. Satu gagal: SRAPAI→SRAANI, `SAPASTNT` (Surface Tension Untreated Side), karena SRAANI memakai MIC umum `SRFCUNTR`. Arah konversi berpengaruh, tergantung material mana yang dijadikan acuan mapping.

**Aturan konversi yang diusulkan** (dicari di MIC lot hasil trace, bukan di material DO):
1. MIC mapping ada persis di lot → pakai (MIC umum).
2. Rumus prefix + 3 huruf **material lot** (bukan material DO, karena lot JR punya material JR sendiri) + akhiran → kalau ada di lot, pakai.
3. Belum ketemu → cari MIC di lot dengan akhiran 4 huruf sama (selalu unik per lot) → menutup kasus `SW3Y`/`PW4R`/`ZGAG`.
4. Belum ketemu → cocokkan deskripsi (QPMT-KURZTEXT) → menutup kasus `SAPASTNT` ↔ `SRFCUNTR`.
5. Tetap tidak ketemu → print diblokir dan tampil pesan (bukan baris kosong).

Catatan: akhiran yang sama bisa punya nama sisi berbeda antar keluarga film (`STTR` = Treated Side / Unmatte Side). Dalam satu alias keluarganya sama, jadi aman. Tapi hasil konversi sebaiknya ditampilkan di ALV (MIC mapping → MIC lot) supaya QA bisa memeriksanya.

**Opsi 2 referensi (diusulkan Baginda, dicek PRD 12 Nov):** selain lot, pakai inspection plan material asli (`MAPL` PLNTY 'Q' → `PLMK`) sebagai kamus MIC. Bukti: `outputs/alias_mapping_20261111/prd_inspection_plan_sample.json`.
- Plan ada per material, dengan nama grup mirip FTYPE: SRAANI = `PLE6-18S`, SRAPAI = `PLE7.18S`, JRAPAI = `PLE7.18J`. Ada 10 group counter (PLNAL) di plant 1000/2000.
- Plan SR SRAANI juga berisi MIC level JR (`PAAN*`). Akhiran saja bisa bentrok antar level, jadi kunci pencocokan = **huruf pertama (level) + akhiran 4 huruf**.
- Plan JR berisi prefix `A` (`AAPASTTR`), selain `P`. Pola prefix tidak hanya S/P.
- Plan SRECVI memang berisi `SW3Y*`, jadi pencocokan di plan menutup kasus MIC pinjaman.
- Peran: **mapping alias** = apa yang tampil (daftar, urutan, deskripsi, limit override). **Plan material lot** = terjemahan dan validasi MIC. **Lot (QAMV/QAMR)** = nilai dan konfirmasi akhir, karena plan bisa berubah setelah lot dibuat.

### 5.4 Yang tidak berubah

Struktur `ZMAP_COA`, program `ZMAP_COA_MIC`, aturan per-field limit (kosong berarti ikut MIC), filter `DELETION <> 'X'`, dan traceability lot.

## 8. Live test DEV (12 Nov 2026) — tanpa mengubah program

**Cara:** F01 di-patch di salinan lokal (`tests/alias_live/ZQMI_COA_F01_alias_patch.abap`, FORM `ZZ_ALIAS_MAP`), lalu dijalankan sebagai subroutine pool in-memory di Development AIX (`mt_pool_build.mjs` + runner `tests/alias_live/runner_alias*.abap`). Program dan tabel di DEV **tidak diubah**. Source DEV diambil ulang hari ini (TAG `alias20261112`), isinya sama dengan versi `_group` lokal. Bukti: `outputs/alias_live_20261112/`.

**Logic yang diuji:** alias batch → material (ZZCODE-ATWTB → kode → `SR`+kode+`I`; fallback MAKT) → ZMAP_COA material alias → MIC diterjemahkan ke MIC material batch lewat inspection plan (EXACT → RULE → SUFFIX → DESC) → trace dan nilai tetap dari lot batch sendiri. Kalau alias gagal dikonversi atau tidak ada mapping → mapping material DO.

**Data DEV:** semua roll DO 76/77 bermaterial SRACBI (HSB4-18). Alias HSB-18 dan HSP-18 tidak punya material. HSS-18 → SRACJI (lewat ZZCODE). SRACJI belum punya ZMAP_COA, jadi mapping SRACJI disimulasikan di memori: 14 MIC mengikuti plan `HSS18S`/`HSS18J`, Haze upper = 2.5.

| Uji | Hasil |
|---|---|
| Konversi alias | HSS-18 → SRACJI via ZZCODE ✅. HSB-18/HSP-18 → NOCONV → fallback mapping SRACBI ✅ |
| Terjemahan MIC | 9/14 via RULE (TH00, TSMD, TSTD, ELMD, ELTD, SHMD, SHTD, HZ00, G400). **5/14 NONE**: `SACJSITR/SINT`, `PACJSSTR/SSNT`, `SACJFDTR` |
| Kenapa 5 gagal | HSB4-18 memakai sisi **Inside/Outside** (`SIIN/SIOT`, "SIT Inside"), HSS-18 memakai **Treated/Untreated** (`SITR/SINT`, "SIT Treated Side"). Akhiran maupun deskripsi tidak sama. Ini keputusan QA (Treated = Inside?), tidak bisa diturunkan otomatis |
| Traceability & nilai (DO 76 dipaksa HSS-18) | 9 MIC: lot dan nilai **sama persis** dengan baseline. Method/limit dari mapping alias terbawa (Haze upper 2.5) ✅ |
| MIC hilang | 5 MIC sisi **hilang diam-diam** dari COA (DO 76: 14 → 9 baris) ❌ → wajib blokir/pesan |
| DO campur alias (DO 77: 6 roll HSP-18 fallback + 12 roll HSS-18 alias) | 1 COA per material: limit Haze 2.5 dari alias ikut ke semua roll. Rata-rata SIT/COF hanya dari 6 roll HSP-18 (SIIN 108 → 101, SIOT 107 → 101, FDIN 0.275 → 0.301) ❌ → mapping per batch tidak konsisten dalam 1 COA |
| Regresi 15 DO (L-QM + ML-QM), patch tanpa mapping simulasi | **Identik** dengan program asli (182 baris) ✅ |

Catatan: dibandingkan golden Oktober, DO 34/35/44/45/71/72 punya selisih di program asli **dan** patch (ZLOG edit, mapping/data berubah sejak Oktober). Bukan dari patch.

**Kesimpulan:**
1. Konversi alias dan trace aman. Nilai tetap dari lot batch sendiri.
2. Pola kode MIC hanya menutup properti yang namanya sama. Properti sisi berbeda antar keluarga film perlu **tabel padanan properti** dari QA, atau print diblokir.
3. Dalam 1 COA, semua roll harus memakai 1 mapping yang sama. Kalau ada roll yang alias-nya gagal dikonversi atau mapping-nya berbeda, print harus ditolak (mirip "Tipe film tidak boleh berbeda").

## 9. Simulasi data PRD (12 Nov 2026) — read-only, tanpa transaksi

Program tidak dijalankan di PRD. Logic yang sama dengan live test DEV disimulasikan di luar SAP dengan membaca tabel PRD (CAWNT/CAWN, MARA, MAKT, MAPL/PLMK, QALS, QAMV, QAMR, ZMAP_COA). Script: `scripts/_adhoc/alias_prd_sim/`. Bukti: `outputs/alias_live_20261112/prd_sim_*.json`.

**1. Konversi alias → material** (45 alias teratas, mewakili 49.544 dari 50.000 sampel batch beralias):

| Status | Alias | Porsi batch |
|---|---|---|
| Tidak bisa dikonversi (NOCONV) | 38, contoh KTM-12, PFP-12, KTM, GLOSS, LC01, MATTE, GP/FDW | **80,9%** |
| Material alias berbeda (DIFF) | 6: KZMB-12, KZHMB-12, AZC-12, VMPET-9, LCA-24, KZMB-9 | 19,0% |
| Material sama (SAME) | SCRIM 4X4 | 0,1% |

Alias yang bisa dikonversi semuanya lewat ZZCODE dan punya material SKU sendiri (misalnya `SLITT ROLL KZMB-12` = SREWBI, sedangkan batch-nya SREWAI `ZMB-12`). Mayoritas alias adalah nama dagang atau nama customer, bukan FTYPE, jadi untuk ±81% batch beralias, model "alias → material" otomatis kembali ke mapping material DO.

**2. Terjemahan MIC** (mapping alias disimulasikan dari MIC lot Z04 terakhir material alias, atau dari plan SR kalau lot tidak ada):
- KZMB-12, KZHMB-12, AZC-12, LCA-24, KZMB-9: **100% MIC terjemah** (RULE/EXACT).
- VMPET-9: 8/9. `SEQBOD00` (Optical Density) ↔ `SKPKODMZ`/`SEUAODMZ`: akhirannya beda, dan deskripsi "Optical Density" muncul lebih dari 1 kali di plan (level S dan P), jadi ambigu. **Perbaikan:** pencocokan deskripsi harus dibatasi ke level yang sama (huruf pertama).
- MIC hasil terjemahan ada di lot Z04 batch asli: KZMB-12 15/15, KZHMB-12 15/15, KZMB-9→SREWCI 19/19, AZC-12 15/16 (`SKKTO2TR` barrier tidak ada di lot SR, ditangani logic MVTR/OTR khusus).
- Sebagian MIC tidak bernilai di lot SR karena nilainya dari lot JR hasil trace (sesuai kolom MAPPING), bukan karena terjemahan gagal.
- Beberapa sampel batch tidak punya lot Z04 langsung (kemungkinan change grade), jadi trace-nya tidak bisa diuji lewat baca tabel biasa.

**3. Limit spec:** untuk KZMB-12, KZHMB-12, AZC-12, limit material alias = limit batch asli (0 beda).

**Kesimpulan simulasi PRD:**
- Mekanisme (konversi lewat ZZCODE + terjemahan MIC lewat plan + nilai dari lot batch) **berjalan baik untuk alias yang memang punya material**.
- Masalah utamanya ada di cakupan: **±81% alias di PRD tidak punya material**. Kalau tujuan QA "alias sama = 1 mapping" juga berlaku untuk alias seperti KTM-12, GLOSS, PFP-12, perlu **master alias → material acuan** (tabel Z), bukan konversi otomatis.

## 10. Analisa ulang PRD — batch 1 tahun terakhir (12 Nov 2026)

Sampel di bagian 9 ternyata **data lama**: 50.000 baris AUSP pertama, CUOBJ kecil, sebagian besar batch tahun-tahun awal. Analisa diulang hanya untuk batch yang dibuat **11 Nov 2025 – 12 Nov 2026** (CUOBJ ≥ `000000000051282577`), dengan sampel sistematis 20% → 317.061 nilai alias, 221 alias unik. 54 alias teratas (95% batch) dianalisa. Excel: `docs/Analisa_Alias_PRD_1Tahun.xlsx`. Bukti: `outputs/alias_recent_20261112/`. Script: `scripts/_adhoc/alias_recent/`.

**Hasilnya berbalik dari data lama:**
- **81,8% batch beralias bisa dikonversi** (35 alias). Hampir semua alias terbaru berformat FTYPE-ketebalan, dan masing-masing punya material "induk" sendiri, misalnya alias HSS-18 → SRACJI "SLITT ROLL HSS-18", dengan batch produksi SRAC2I "HSS4-18".
- 18,2% tidak bisa dikonversi (19 alias): E5102, E5202, E5104, EB512, GLOSS-18/-12/., MATTE, DOFF-18/-20, HSC-18, HLS-20, PHL-18, OL-20, OL-W-20, KTM., KMM, SCSH-30, PFO01-35.

**Simulasi tracing MIC** (53 pasangan material alias → material batch, 637 MIC):
- 572/637 MIC (89,8%) berhasil diterjemahkan. 25 pasangan kategori **Aman**.
- Lot Z04 contoh batch ditemukan di 18 pasangan. **254/259 MIC hasil terjemahan memang ada di lot batch** → trace aman.
- Masalah yang ditemukan:
  1. `SRFCUNTR` (MIC umum Surface Tension Untreated) di material alias keluarga PLE/PSL/PHL tidak ada di plan batch (12 pasangan). Solusi: pencocokan deskripsi **dibatasi per level**.
  2. 5 material batch **tanpa inspection plan** (SRCBUO "Polyester Film 12", SRCBUX, SRXICI/SRXIHI/SRXIJI awalan "5…"): MIC tidak bisa diterjemahkan, termasuk MIC umum.
  3. Penamaan properti beda (MF-20 → EMF6-20 memakai NM/MT, sedangkan alias memakai pola lain; MA91-50 `SW3YFEP*`) → perlu padanan dari QA.
  4. **Limit spec beda di 6 pasangan**, misalnya PSL-17: 5 MIC (COF, Haze); SPO-13: SIT 120–135 vs 105–120; HSB-17.6: SIT 100–108 vs 102–108.
  5. EP-9: material alias SRCABX tidak punya lot maupun plan SR, jadi tidak bisa disimulasikan.

## 11. Rancangan fallback ke mapping material batch (13 Nov 2026, rencana)

Prinsip: mapping alias dipakai **hanya kalau seluruh COA bisa diselesaikan bersih**; selain itu satu COA penuh kembali ke perilaku as-is (mapping material batch).

**Level keputusan: per COA (DO + MATNR yang dipilih), bukan per batch atau per MIC.** Satu COA merata-rata nilai per MIC; kalau sumber mapping dicampur, set MIC dan limitnya jadi tidak konsisten (contoh: HSP-18 terkonversi, HSS-18 tidak, dalam satu COA).

Pemicu fallback (cukup salah satu):

| Kode | Kondisi |
|---|---|
| NOALIAS | Batch tidak punya ZZALIAS |
| NOCONV | Alias tidak bisa dikonversi ke material (ZZCODE/MAKT) |
| NOMAP | Material alias tidak punya ZMAP_COA |
| NONE | Ada MIC mapping alias yang tidak bisa diterjemahkan ke MIC material batch |
| MIXED | Batch dalam satu COA menghasilkan material alias berbeda |

- Tidak ada fallback per MIC (campur limit dua mapping ditolak).
- Fallback wajib terlihat: pesan info di layar/ALV + log alasan, supaya QA tahu mapping mana yang dipakai.
- Kalau mapping material batch juga kosong: blok print (jangan cetak COA tanpa MIC).

Dampak dari data PRD 1 tahun (top 54 alias, bobot batch):

| Jalur | Porsi | Catatan |
|---|---|---|
| Mapping alias, MIC terjemah penuh | 69,2% | 4,2% di antaranya limit alias beda dengan plan material batch (MFB-13, HSB-17.6, PFL-38, SPO-13) |
| Fallback karena MIC tidak terjemah penuh (NONE) | 12,6% | PSL-17, MF-20, PL-20, LCAH-24, MA91-50, keluarga SRFCUNTR |
| Fallback karena NOCONV | 18,2% | 19 alias; beberapa dipakai beberapa FTYPE (DOFF-18, OL-20, E5102) sehingga jadi perilaku Opsi 2 |

Konsekuensi: mapping material batch **tetap wajib di-maintain** untuk ~31% batch beralias. Simplifikasi mapping hanya berlaku untuk alias yang lolos.

Mapping customer di jalur alias: mapping umum (KUNNR kosong) + override customer **dua-duanya dibaca dari material alias** (contoh SRAAAI + KUNNR). Cukup satu kali per material alias + customer, berlaku untuk semua material produksi beralias sama. Mapping customer yang dibuat di material batch tidak dipakai di jalur alias, hanya dipakai saat fallback. MIC override customer juga ikut diterjemahkan, dan kalau gagal kena pemicu NONE.

Catatan 13 Nov 2026: ZMAP_COA belum ada di PRD (baru di DEV AIX). Jadi saat go-live QA harus membuat mapping material alias (alias yang lolos) **dan** mapping material batch (alias fallback serta batch tanpa alias).

Status harness DEV (`tests/alias_live/zz_alias_form.abap`): fallback NOCONV/NOMAP sudah ada tetapi per batch; pemicu NONE belum (MIC hilang diam-diam) dan MIXED belum ada.

## 6. Pertanyaan Konfirmasi ke QA

1. Alias sama tetapi limit spec material asli berbeda (GLOSS, KZMB-9): COA mencetak **limit mapping alias** atau **limit material asli batch**?
2. Ejaan alias tidak konsisten (`KTM-12`, `KTM.12`, `KTM`, `KTM.`): apakah dianggap **alias yang sama**? Kalau ya, perlu aturan normalisasi atau master alias.
3. Alias yang tidak cocok dengan FTYPE material mana pun (misalnya HSB-18): cukup fallback ke material DO + warning?
4. Apakah pencocokan MIC lewat akhiran properti (`SIBRSPTH` ↔ `SIARSPTH`) bisa diterima?
5. Material "acuan" untuk satu alias: siapa yang menentukan kalau satu alias dipakai beberapa material (misalnya KZMB-9 dipakai 3 material)?

## 7. Next Step

- [ ] Konfirmasi QA: Opsi 1 atau Opsi 2 (bagian 0), pakai deck `docs/Alias_COA_Opsi_QA.pptx`
- [ ] Kalau Opsi 1: jawab pertanyaan di bagian 6
- [ ] Revisi desain sesuai jawaban QA
- [x] Blueprint final (Opsi 1 PPT, COA gabungan per alias, fallback per tipe produksi): `docs/BLUEPRINT_ALIAS_MAPPING_ZQM002.md` (13 Nov 2026)
- [ ] Konfirmasi QA atas blueprint (bagian 6 blueprint)
- [ ] **Execute hanya setelah Baginda bilang "execute"**
- [ ] Regresi L-QM01–15 + ML-QM01–04 + skenario alias baru
