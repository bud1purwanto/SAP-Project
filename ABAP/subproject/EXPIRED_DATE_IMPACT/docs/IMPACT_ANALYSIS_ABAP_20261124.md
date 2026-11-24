# Impact Analysis ABAP: Perubahan Perhitungan Expired Date Roll

| Atribut | Isi |
|---|---|
| Tanggal | 24 Nov 2026 (revisi 2: scan penuh) |
| Permintaan | Email "FW: Ref. Roll number and best used" (Alfa, 24 Nov 2026) |
| Usulan | Roll yang jadi FG **tanggal ≥ 15** memakai bulan **berikutnya** sebagai bulan produksi, lalu + 6 bulan. Hanya untuk customer yang butuh film segar (mis. STT), tidak untuk metallized CPP |
| Sumber | **DEV AIX (TRD 130)**, read-only via RFC (`sap-leader-mcp`) |
| Status | Analisis saja. Belum ada perubahan program |

> PRD belum dibandingkan. Versi program di PRD bisa berbeda dari DEV; perlu dicek sebelum keputusan final.

---

## 0. Cakupan scan

Revisi 1 hanya bertumpu pada where-used FM `Z_GET_PRODUCTION_DATE` (41 objek). Revisi ini memindai **full-text seluruh source**:

| Yang dipindai | Jumlah |
|---|---|
| Semua objek Z/Y di TRDIR (report, include, function group `LZ*`/`SAPLZ*`, class pool, module pool, user exit `ZX*`, enhancement) | 4.725 (0 gagal) |
| Include generate Smart Form (`/1BCDWB/LSF*`) | 770 |
| Output type yang memanggil program Z (TNAPR) | 24 |

Pola yang dicari (di luar baris komentar): `ZZEXPIREDLIVE`, `Z_GET_PRODUCTION_DATE`, `VFDAT`, `HSDAT`, `MHDHB/MHDRZ`, `EXPIR`, `BEST USE / USED BEFORE / SHELF`, `+ 180`.

Hasil: **144 objek** cocok. **93 objek** memakai `ZZEXPIREDLIVE`; sisanya hanya `VFDAT/HSDAT` untuk bahan baku (BAPI goods movement, upload batch RM), `EXPIR` dalam arti lain (LC expiry, payment), atau hanya memanggil FM tanggal produksi tanpa hitung expired.

Karakteristik di CABN: hanya **`ZZEXPIREDLIVE`** (ATINN 877, NUM 3 digit) yang terkait umur simpan. Tidak ada karakteristik lain seperti "BEST USE", "SHELF", atau "MANUF".

---

## 1. Rumus yang berlaku sekarang

```
Expired Date = Tanggal Produksi + ZZEXPIREDLIVE (hari)
```

- **`ZZEXPIREDLIVE`** ada di batch (class 023). Nilainya **tidak sama untuk semua batch** (lihat §2).
- **Tanggal Produksi** biasanya diambil dari FM `Z_GET_PRODUCTION_DATE` (`LZTRIASU01`): `MSEG-BUDAT_MKPF` GR 101/102 non-reversal, fallback `MCH1-ERSDA`.
- Label mencetak **YYYY.MM** (beberapa label DD.MM.YYYY / MM/YYYY).
- Field standar SLED (`MCH1-VFDAT`, `MARA-MHDHB`) tidak dipakai untuk roll FG.
- Expired date **tidak disimpan**; setiap program menghitung sendiri.

### Variasi yang ditemukan

| Variasi | Program |
|---|---|
| Label CKI `D121`: hari = bulan × 30 dari `ZMAP_LABEL-TEXT5` | `ZMMR_LABELROL_STANDAR`, `ZLABELROL_CHANGE_90`, `ZHUR_LABELPACK_INCL` |
| Tanggal dasar **tanpa** FM: `MKPF-BUDAT` dari `MAX(MBLNR)` 101/102, tanpa filter material dan tanpa cek reversal | `ZQMI_PACKING_STATUS` (ZQM001P) dan `ZQMI_PACKING_STATUS_TTE` (ZEQM001P) |
| Tanggal dasar `MCH1-ERSDA` / `LWEDT` langsung (program lama) | `ZBAP_READY_REPORT_ORI`, `ZHUR_READY_REPORT`, `ZMMR_STOCK_BY_CHAR*`, `ZHUR_ROLL_LIST_BY_DEL1/2` |
| Membaca `ZZEXPIREDLIVE` tanpa menghitung (dikirim ke layout) | `ZLABELROL_A131`, `A136`, `A138`, `A139`, `ZMMR_LABELROL_PM`, `ZMMR_LABELROL_PRIMA`, `ZLABEL_A211`, `ZMMR_LABELHU_KTNG` |

---

## 2. Nilai umur simpan per company code dan plant (DEV, batch class 023)

| Company | Plant | Batch | 60 | 90 | 120 | 180 | 270 | 360 | 365 |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| 9999 PT Trias Sentosa | 1000 Waru | 206.964 | 907 | – | 1.633 | **202.153** | 3 | 306 | 1.962 |
| 9999 PT Trias Sentosa | 2000 Krian | 229.704 | 735 | 8 | 3.147 | **181.170** | – | 3.285 | 41.359 |
| 9701 PT Trias Toyobo Astria (TTA) | TTA2 | 7.504 | – | – | – | 3.334 | – | – | **4.170** |
| 6500 PT Toyobo Trias Ecosyar (TTE) | TTE | 12.785 | – | – | – | 3.517 | – | – | **9.268** |
| 9702 PT TTE (inactive) | TTE2 | 21 | – | – | – | 18 | – | – | 3 |
| 9800 PT Unggul Niaga Sentosa | UNS2 | 39 | – | – | – | 9 | – | – | 30 |

Catatan:
- Satu batch bisa ada di lebih dari satu plant (MCHA), jadi jumlah per plant bisa tumpang tindih. 1.324 nilai AUSP tidak terpetakan ke MCH1.
- Contoh di email (180 hari) adalah mayoritas di Trias. Di **TTA dan TTE mayoritas 365 hari**. Aturan "+ 6 bulan" tidak bisa langsung menggantikan semua nilai.
- Nilai `ZZEXPIREDLIVE` berasal dari konfigurasi penjualan. Upload quotation/SO membaca variant table **`ZZCODE`** (per type film) dan mengisi karakteristik ini ke batch lewat BDC. Program terkait: `ZSD101`/`ZSD101TTA`/`ZSD101TTE`, `ZIC004SL`, `ZSD506_1`. Artinya umur simpan sudah ditentukan per type/pesanan, dan bisa menjadi tempat aturan "customer kritis". **Perlu konfirmasi functional SD/PP.**
- Ini data DEV. Distribusi PRD bisa berbeda.

---

## 3. Program yang terdampak (aktif)

### A. Report, monitor, dan interface

| T-code | Company | Program | Rumus / catatan |
|---|---|---|---|
| ZQM001P | Trias | `ZQMI_PACKING_STATUS` | `V_BUDAT + V_EXP`, tanggal dasar beda (§1) |
| **ZEQM001P** | **TTE** | `ZQMI_PACKING_STATUS_TTE` | sama dengan ZQM001P |
| ZBMBC | semua | `ZBAP_STOCK_BY_CHAR1` | `ERSDA + ZZEXPIREDLIVE` → `DEXDT`; juga feed WMS |
| ZBMBC_2, ZTBMBC | | `ZCOPY_ZBMBC`, `ZTBAP_STOCK_BY_CHAR1` | salinan ZBMBC |
| **ZBMBC2** | | `ZRM07MLBS` | `ERSDA + ATFLV2` |
| ZSD012N | semua | `ZBAP_READY_REPORT` | `ERSDA + ATFLV`; tulis ke SQL `XZSD012N` |
| ZSD024, **ZSD024TTE** | Trias, TTE | `ZHUR_ROLL_LIST_BY_DEL` | `LWEDT + V_EXPR`; tulis ke SQL `XZSD024` |
| ZSD024A | | `ZHUR_ROLL_LIST_BY_DEL_GG` | `V_PDATE + V_VLIVE` |
| ZQM002, ZQM003 | semua | `ZQMI_COA` | expired date di **COA** customer |
| ZMM062, ZAMM062K, ZEMM062, ZMM062_TS, ZMM062_WKA | Trias, TTA, TTE | `ZMMR_RETURN_PALLET`, `_W_CYCLE` | `V_PDATE + V_VLIVE` |
| ZTYB10 | Toyobo | `ZMM_TYBROL_TO_BATCH` | `GRDATE + V_LIVE` |
| ZEQM041, ZEQM044 (dan dari ZBMBC) | TTE | `ZQMI_BARRIER_PASS_FAIL`, `ZQMI_BARRIER_NCR_UPLOAD` | `PROD_DATE + V_COUNT` |

### B. Label roll (cetak saat produksi dan cetak ulang)

Dispatcher **`ZMMR_LABELROL`** dipanggil oleh: ZPP001 / ZPP001N / ZPP001L / ZPP001_WO_VAL (Trias), **ZAPP001 (TTA)**, **ZEPP001 (TTE)**, ZTYB001 / ZTYB02 (Toyobo), ZIC006 (subcon), ZPP006 (reslit), ZPP018, ZPP021, ZPP029R, ZPPTYB1, ZQM016 / **ZEQM016** (change grade), ZLABEL (reprint).

| Program | Dipakai untuk | Rumus |
|---|---|---|
| `ZMMR_LABELROL_STANDAR` (include) | label standar | `V_POSTDATE + V_LIVE`, D121 ×30 |
| `ZMMR_LABELROL_INCHI` (include) | | `V_POSTDATE + V_LIVE` |
| `ZMMR_LABELROL_DOCX` | A153–A157, A159, B101, C109, D128, E127, E128, E133 | `V_POSTDATE + ITAB-VLIVE` |
| `ZMMR_LABELROL_WINDOWS` | A010–A013, A161, CP18 | `V_POSTDATE + ITAB-VLIVE` |
| `ZLABELROL_A132`, `A133`, `A400`, `A401` | label type sesuai nama | `V_POSTDATE + V_LIVE` |
| `ZLABELROL_A131`, `A136`, `A138`, `A139` | label type sesuai nama | baca `ZZEXPIREDLIVE`, hitung di layout |
| `ZMMR_LABELROL_TYB` (via ZTYB03/03A/03B) | Toyobo | `V_POSTDATE + V_LIVE` |
| `ZMMR_LABELROL_NONSAP` | | `V_POSTDATE + ITAB-VLIVE` |
| ZLABEL90 `ZLABELROL_CHANGE_90` | ganti label | `V_POSTDATE + V_LIVE`, D121 ×30 |
| ZLABEL91 `ZMMR_CHANGE_LABELROL_WIN` | ganti label | `V_POSTDATE + ITAB-VLIVE` |

### C. Label HU / pallet

| Pemicu | Program | Rumus |
|---|---|---|
| Output type HU **V6 Z001 / Z002** | `ZHUR_LABELPACK` (`_INCL`, `_INCH`) | `V_POSTDATE + V_LIVE`, D121 ×30 |
| `ZMAP_LABEL-PROG_HU` A146 / A400 / A401 | `ZLABELHU_A146`, `A400`, `A401` | `V_POSTDATE + V_LIVE` |
| `ZMAP_LABEL-PROG_HU` A010–A013, A161, CP18 | `ZMMR_LABELHU_WINDOWS` | `V_POSTDATE + ITAB-VLIVE` |
| `ZMAP_LABEL-PROG_HU` A158, A164, A173 | `ZMMR_LABELHU_KTNG` | baca `VLIVE` saja |
| ZHU020 | `ZHU_LABEL_PMI` | `V_POSTDATE + V_LIFE` |
| ZHU021 | `ZHU_LABEL_GG01` | `PDATE + VLIVE` |
| ZHU023 | `ZHU_LABEL` (include `ZHU_LABEL_1100`) | `PDATE + VLIVE` |
| ZHU025 | `ZHU_LABEL_KTNG` | `PDATE + VLIVE` |

### D. Sumber nilai / tampilan (tidak menghitung tanggal, tapi terdampak kalau satuan atau aturan berubah)

| T-code | Program | Peran |
|---|---|---|
| ZSD101, ZSD101TTA, ZSD101TTE | `ZSDI_UP_QUOT`, `_TTA`, `_TTE` | upload quotation, baca variant table `ZZCODE` |
| ZIC004SL | `ZIC_UPLOAD_SO_CKI_2` (dan `ZIC_UPLOAD_SO`, `_CKI`) | upload SO, isi `ZZEXPIREDLIVE` ke batch via BDC |
| ZSD506_1 | `ZSDR_CUSTOMIZING_SALES_MASTER1` | baca nilai dari variant table |
| ZSD500 | `ZSDR_QUOTATION_LIST` | tampilkan "Expired Life" |
| ZPP005N, ZPP005S | `ZPPR_PENDING_ORDER_ALF`, `_SCHLINE` | tampilkan karakteristik |
| ZIC007 | `ZMMI_GRN_SUBCON_TTE` | bawa `ZZEXPIREDLIVE` saat GR subcon TTE |
| – | FG `ZCHARACTERISTICS` (`LZCHARACTERISTICSU01/03/04/06`) | FM baca karakteristik batch |

### E. Kemungkinan tidak dipakai (tanpa T-code, umumnya salinan/uji/lama)

`ZBAP_READY_REPORT_STFN`, `ZBAP_READY_REPORT_ORI`, `ZBAP_STOCK_BY_CHAR`, `ZBMBC_JR`, `ZHUR_READY_REPORT`, `ZHUR_ROLL_LIST_BY_DEL1/2/V2`, `ZITI_ZSD024S`, `ZHU_LABEL_GG01X`, `ZLABELROL_TES`, `ZTES_LABEL_INCL`, `ZMMR_CHANGE_LABELROL_WIN_BUDI`, `ZMMI_GRN_SUBCON_TTE_BUDI`, `ZMMR_STOCK_BY_CHAR`, `ZMMR_STOCK_BY_CHAR1`, `ZQMI_BARRIER_PASS_FAIL_CP`, `ZPPR_PENDING_ORDER_ALF_CP`, `ZPPR_SLITTING_REKAP_KACONG`, `ZPP_UP_CLASS3/4/5`, `Z_COBA_HU`, `Z_CONSIGNMENT2`, `Z_POOPEN`, `ZSO`, `Z_SO`. Perlu konfirmasi pemakaian di PRD sebelum diabaikan.

### Yang dicek dan tidak terdampak

- Label TTA/TTE `ZMMR_LABELROL_TTA` / `_TTE`, `ZMMR_LABELROL_TOYOBO`, label jumbo roll `ZMMR_LABELJR` / `_TTE`: tidak mencetak expired date.
- Smart Form: hanya `ZLABEL_001` yang punya teks "EXPIRED", dan isinya teks statis. Smart Form lain tidak menghitung expired roll.
- `VFDAT/HSDAT/MHDHB` (FG `ZTRIAS02`, `ZMM_INV`, `ZSD_DO`, ZMB5M, ZQM006, ZBC001, ZMM020, ZMMIB_07, ZTMB51, ZTCOID): shelf-life bahan baku / BAPI movement, bukan roll FG.

---

## 4. Dampak per opsi

| Opsi | Yang diubah | Dampak |
|---|---|---|
| **1. Label saja** | §3-B dan §3-C (±25 program) | Label menunjukkan Juni; ZQM001P/ZEQM001P, ZBMBC, ZSD012N, ZSD024/ZSD024TTE, COA, return pallet, barrier dan SQL `XZSD012N`/`XZSD024` tetap 14 Mei |
| **2. Semua diselaraskan** | §3-A sampai §3-C (±45 program aktif) | Satu angka di semua tempat. Disarankan satu FM pusat expired date (input material + batch) untuk mengganti semua rumus `tanggal + hari` |

Catatan:
- Karena expired date tidak disimpan, perubahan rumus juga mengubah tampilan batch lama di report. Perlu aturan "berlaku mulai tanggal produksi X".
- Di TTA/TTE mayoritas 365 hari; aturan "+ 6 bulan" perlu dipastikan berlaku untuk company mana saja.

---

## 5. Hal yang perlu diputuskan di meeting

1. **Kriteria customer kritis** (STT dll.) dan pengecualian metallized CPP: dari customer, type film, label type (`ZMAP_LABEL`), atau variant table `ZZCODE` / konfigurasi SO? Sumber `ZZEXPIREDLIVE` sudah per type/pesanan.
2. **Company/plant yang ikut**: Trias saja (1000, 2000) atau juga TTA, TTE, UNS?
3. **Tanggal persis** di SAP: awal bulan, akhir bulan, atau tanggal yang sama? Report memakai tanggal penuh.
4. **Satuan umur simpan**: tetap hari (180/365) atau bulan (6/12)? Bagaimana untuk nilai 60/90/120/270/360?
5. **Batas tanggal 15** dari tanggal GR 101 atau tanggal konfirmasi produksi?
6. **Berlaku mulai kapan**, dan apakah batch lama ikut dihitung ulang.
7. **Interface SQL** `XZSD012N`, `XZSD024`: koordinasi dengan OLAP.

---

## 6. Lampiran teknis

| File | Isi |
|---|---|
| `src/dev_20261124/` | Source 144 objek yang cocok + include Smart Form `ZLABEL_001` |
| `outputs/scan_result.json` | Hit per objek per pola |
| `outputs/summary.json` | Objek, tipe, tanggal ubah, program induk, T-code, baris rumus |
| `outputs/life_by_plant.json` | Distribusi `ZZEXPIREDLIVE` per plant |
| `scripts/bulk_rfc.mjs`, `scan.py`, `summ.py`, `dump.mjs`, `tc.mjs` | Script ambil source/tabel (read-only) dan scan |
