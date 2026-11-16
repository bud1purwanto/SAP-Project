# Analisis Pemilihan Lot JR (Z02 / Z03) — 16 Nov 2026

Pemicu: DO uji alias `0085006280` tetap bernilai 0 walaupun UD lot Z02 sudah di-reset user. Status: **analisis saja, program belum diubah**.

## 1. Masalah

Program (ZQMI_COA_F01) mencari lot JR dengan:

```abap
SELECT SINGLE PRUEFLOS INTO LOT_JR_BASE FROM QALS
  WHERE CHARG = L_JR_BASE_BATCH AND ( ART = 'Z02' OR ART = 'Z03' ).
```

Pola yang sama ada di 3 tempat:

| Lokasi F01 (DEV alias_v2) | Lot | Dipakai untuk mapping |
|---|---|---|
| ±2552 `GET_TRACED_LOTS` | `LOT_JR_CONV` | "JR Converting" |
| ±2684 `GET_TRACED_LOTS` | `LOT_JR_BASE` | "JR Base Film" |
| ±4835 `GET_MT_LOTS` | lot JR stage multi-level | cadangan bila MIC tidak ada di lot utama |

`SELECT SINGLE` tanpa urutan: kalau satu batch JR punya lot Z02 **dan** Z03, lot yang terambil tergantung database. Z02 berisi MIC P (Thickness, Tensile, Elongation, Shrinkage, Haze, Gloss, COF, ...), Z03 (origin 09) hanya MIC A (Surface Tension, Decay Time).

Program sudah punya cadangan: kalau MIC mapping tidak ada di lot utama, dicari di lot `GT_MT_LOT` stage yang sama (F01 ±1031–1050). Tapi lot JR di `GT_MT_LOT` juga diambil dengan `SELECT SINGLE` yang sama, jadi untuk batch yang sama hasilnya lot yang sama, dan cadangan tidak menolong.

## 2. Data DEV

Trace `GET_TRACED_LOTS` untuk 17 DO (program DEV alias_v2, in-memory), lalu daftar lot Z02/Z03 tiap batch JR (55 batch):

| DO | Batch JR | Lot Z02 / Z03 di batch | Lot terpilih | Akibat |
|---|---|---|---|---|
| 15 DO skenario (L-QM01–15, ML-QM01–04) | 53 batch | **1 lot Z02** saja | lot Z02 itu | Tidak ada pilihan, selalu benar |
| 0085006280 (uji alias) | JRAABI 0000352266 | Z02 040000009270 + 5 lot Z03 (090000000588/592/594/632/959) | **090000000959 (Z03)** | MIC P tidak ketemu → INSLOT 0, value 0 |
| 0085006280 (uji alias) | JRABDI 0000368300 | Z02 040000015420 + Z03 090000000975 | **090000000975 (Z03)** | Sama |
| 0085006281 (uji alias MIXED) | JRAABI 0000356780 | Z02 040000011497 + Z03 090000000483 | 040000011497 (Z02) | Kebetulan benar; value 0 karena lot tanpa hasil |

Di output DEV (`outputs/MT_20261116_dev_after_alias_v2.txt`), baris CHK = X dengan INSLOT `000000000000` hanya ada di DO 6280 (9 MIC) dan 6281 (11 MIC). Semua MIC mapping di 15 DO skenario sudah ketemu lot.

Lot Z03 origin 09 di DEV dibuat TRST-BUDI 24.06.2025.

**Arti tipe lot (TQ30T):** Z02 = Inspeksi Jumbo Roll After Production, Z03 = Inspeksi Jumbo Roll After Aging, Z04 = Inspeksi Slit Roll. TRST-AISYAH (QA) konfirmasi 16 Nov 2026: JR memang bisa punya Z02 dan Z03.

**Cek PRD (16 Nov 2026, atas permintaan user, RFC_READ_TABLE QALS saja, tanpa menjalankan program):**

| Item | Hasil |
|---|---|
| Lot Z03 di PRD | 4.907 lot, 4.896 batch JR. Per tahun dibuat: 2013: 9, 2014: 1.254, 2015: 1.332, 2016: 1.088, 2017: 1.048, 2018: 169, 2019: 7 (terakhir 090000005304, 06.04.2019). Tidak ada setelah April 2019 |
| Batch Z03 yang juga punya lot Z02 | **4.896 / 4.896 (100%)**, masing-masing 1 lot Z02 |
| Material terbanyak | JRAABI 3.106, JRAAAI 672, JRAADI 160, JRABRI 151, JRAAEI 129, JRAFAI 96, JRAFFI 85, JRAJDI 52 |
| Pernah / masih masuk DO | Belum dicek |

Artinya kasus Z02 + Z03 nyata di PRD (bukan cuma data uji DEV), tetapi hanya untuk JR yang lot-nya dibuat 2013 – April 2019. Kalau QA memakai inspeksi aging lagi, kasus ini muncul di produksi baru.

## 3. Opsi perbaikan

| Opsi | Cara | Kelebihan | Risiko |
|---|---|---|---|
| **A. Z02 diutamakan** | Ganti 3 `SELECT SINGLE` jadi `SELECT ... UP TO 1 ROWS ... ORDER BY ART` (Z02 dulu, baru Z03) | Sederhana | Kalau mapping "JR Base Film" memakai MIC A (Surface Tension / Decay Time) yang hanya ada di Z03, MIC itu jadi hilang. Mengubah pilihan lot untuk semua batch yang punya Z02 + Z03 |
| **B. Per MIC (direkomendasikan)** | Lot utama tetap seperti sekarang. Hanya kalau MIC mapping **tidak ada** di lot utama, cari di lot Z02/Z03 lain dari batch JR yang sama yang memuat MIC itu (utamakan yang punya hasil) | Lot utama tidak berubah. Hanya menambah pencarian di kasus yang sekarang gagal (INSLOT 0). MIC P dan MIC A sama-sama bisa ketemu | Tambah 1 query per MIC yang tidak ketemu |
| C. Biarkan | Tidak diubah | Tanpa risiko program | DO 6280 tidak bisa diuji nilai; kasus serupa di PRD (kalau ada) tetap salah ambil |

## 3.1 Rancangan Opsi B (belum di-execute)

Satu sisipan di `GET_MIC` (F01), setelah blok cadangan multi-level (±1050) dan sebelum `IF INS IS NOT INITIAL.`, plus satu FORM baru:

```abap
    " JR bisa punya lot Z02 (after production) + Z03 (after aging).
    " MIC tidak ada di lot terpilih -> cari lot lain batch JR yg sama
    IF INS IS NOT INITIAL AND IT_ZMAP-MAPPING CS 'JR'.
      SELECT SINGLE MERKNR INTO LV_MT_MK FROM QAMV
        WHERE PRUEFLOS = INS AND VERWMERKM = IT_ZMAP-MIC.
      IF SY-SUBRC <> 0.
        PERFORM GET_JR_LOT_FOR_MIC USING IT_ZMAP-MIC CHANGING INS.
      ENDIF.
    ENDIF.
```

`FORM GET_JR_LOT_FOR_MIC USING P_MIC CHANGING P_LOT`:
1. Ambil batch JR dari lot sekarang (`QALS-CHARG` where `PRUEFLOS = P_LOT`).
2. Cari semua lot batch itu dengan `ART` Z02 / Z03 yang punya MIC `P_MIC` di QAMV.
3. Pilih: (a) yang punya hasil (QAMR `ANZWERTG > 0`), (b) Z02 sebelum Z03, (c) nomor lot terkecil. Urutan tetap, tidak tergantung database.
4. Tidak ketemu → `P_LOT` tidak diubah (perilaku sama dengan sekarang: MIC tampil tanpa lot, value 0).

Yang **tidak** diubah: `GET_TRACED_LOTS`, `LOT_JR_BASE` / `LOT_JR_CONV` global, `GET_MT_LOTS`, lot SR (Z04), perhitungan rata-rata. MIC yang sudah ketemu di lot utama tetap dari lot utama (termasuk Surface Tension bila ada di lot utama).

Uji: regresi 17 DO (harus identik kecuali DO 6280 baris INSLOT); DO 6280 MIC P terbaca dari 040000009270 / 040000015420 (value tetap 0 sampai hasil diinput); setelah hasil diinput QA, value DO 6280 dibandingkan dengan rata-rata manual per lot.

## 4. Dampak Opsi B ke skenario

- Opsi B hanya aktif kalau MIC tidak ada di lot utama. Di 15 DO skenario semua MIC mapping sudah ketemu lot, jadi **secara konstruksi nilai, limit, lot, EXEC dan ZQM003 tidak berubah**. Tetap dibuktikan dengan regresi 17 DO.
- DO 6280: MIC P akan terbaca dari lot Z02 040000009270 / 040000015420. Value tetap 0 sampai hasil inspeksi diinput di kedua lot (UD sudah di-reset user, jadi sekarang bisa).
- DO 6281: lot sudah Z02, tidak berubah.

## 5. Di luar cakupan

Pola `SELECT SINGLE ... ART = 'Z04'` (lot SR) juga tanpa urutan. Kalau satu batch SR punya lebih dari satu lot Z04, masalah serupa bisa terjadi. Belum dianalisis.
