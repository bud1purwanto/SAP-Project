# Dataset Hasil Inspeksi Kualitas SAP (LLM-Ready Markdown)

## 1. Konteks & Skema Data

- **Sumber Data**: 12 tangkapan layar (*screenshot*) modul Quality Management SAP (`Gambar 1` s/d `Gambar 12`).
- **Deduplikasi**: `Gambar 6` (`image_63d9f1.png`) dan `Gambar 7` (`image_63dcbe.png`) menampilkan `NO ODO` `0085006243` yang 100% identik. Dataset utama di bawah ini menggunakan **119 baris unik** dari **11 NO ODO unik** (tanpa duplikasi `Gambar 7`).
- **Definisi Kolom**:
  - `NO ODO`: Nomor Outbound Delivery Order (10 digit, *zero-padded*).
  - `Item`: Nomor item pengiriman (`10`, `20`, `30`).
  - `Batch`: Nomor *batch* produksi (10 digit, *zero-padded*).
  - `Nomor SR`: Kode identifikasi *Slitter Roll* / gulungan produksi.
  - `Material`: Kode material SAP (`SRCADI`, `SRAABI`, `SRGIDI`, `SREWEI`, `SRVC2I`, `SREASI`, `SRGJBI`).
  - `MIC`: *Master Inspection Characteristic* (kode parameter uji kualitas SAP).
  - `MIC Description`: Nama parameter pengujian kualitas fisik/optik/mekanik.
  - `Unit Of Measure`: Satuan ukur (`%`, `KMM`, `DCM`, `MIM`, `CMD`, `GMD`, `GPI`, atau `-` untuk tanpa satuan seperti *COF* dan *Optical Density*).
  - `Method`: Standar metode uji (mis. `ASTM D 882`, `ASTM D1204`, `ASTM D1003`, `ASTM D2457`, `ASTM D1894`, `ASTM D 2578`, `ASTM D 374`, `TRIAS METHOD`).
  - `Lower Limit` & `Upper Limit`: Batas spesifikasi bawah dan atas.
  - `Value`: Nilai hasil pengujian aktual (`-` jika belum diisi).
  - `Status Spec`: Evaluasi otomatis (`In Spec` bila `Lower Limit <= Value <= Upper Limit`, `Out of Spec` bila di luar rentang, atau `Belum Diisi (-)`).

## 2. Ringkasan Rekapitulasi per NO ODO

| No | NO ODO | Material | Sumber Gambar | Total Parameter | Nilai Terisi | Belum Diisi (-) | In Spec | Out of Spec |
| :---: | :---: | :---: | :--- | :---: | :---: | :---: | :---: | :---: |
| 1 | 0085006234 | SRCADI | Gambar 1 (image_638781.png) | 10 | 6 | 4 | 5 | 1 |
| 2 | 0085006235 | SRAABI | Gambar 2 (image_63d938.png) | 10 | 10 | 0 | 9 | 1 |
| 3 | 0085006240 | SRGIDI | Gambar 3 (image_63d95d.png) | 9 | 9 | 0 | 8 | 1 |
| 4 | 0085006241 | SREWEI | Gambar 4 (image_63d998.png) | 13 | 13 | 0 | 11 | 2 |
| 5 | 0085006242 | SRVC2I | Gambar 5 (image_63d9bb.png) | 13 | 13 | 0 | 9 | 4 |
| 6 | 0085006243 | SREASI | Gambar 6 & 7 (Duplikat) | 10 | 9 | 1 | 4 | 5 |
| 7 | 0085006244 | SRAABI | Gambar 8 (image_63dcfd.png) | 10 | 10 | 0 | 8 | 2 |
| 8 | 0085006245 | SRGJBI | Gambar 9 (image_63f3c4.png) | 9 | 9 | 0 | 4 | 5 |
| 9 | 0085006270 | SRAABI | Gambar 10 (image_63f41a.png) | 12 | 12 | 0 | 10 | 2 |
| 10 | 0085006271 | SRAABI | Gambar 11 (image_6dfc0b.png) | 13 | 13 | 0 | 12 | 1 |
| 11 | 0085006272 | SREASI | Gambar 12 (image_6e4d8a.png) | 10 | 10 | 0 | 4 | 6 |
| **Total** | **11 ODO** | **7 Material** | **12 Gambar (11 Unik)** | **119** | **114** | **5** | **84** | **30** |

## 3. Daftar Parameter Out of Spec & Belum Diisi (Anomali Kualitas)

### 3.1 Parameter Out of Spec (30 Baris)

| No Baris | NO ODO | Item | Batch | Nomor SR | Material | MIC | MIC Description | UoM | Lower Limit | Upper Limit | Value | Deviasi |
| :---: | :---: | :---: | :---: | :--- | :---: | :---: | :--- | :---: | :---: | :---: | :---: | :--- |
| 6 | 0085006234 | 20 | 0000405760 | Z CAD 076 001 9K 04 | SRCADI | PCADSHTD | Shrinkage TD | % | 0.00 | 0.50 | **0.81** | >0.50 (Selisih +0.31) |
| 15 | 0085006235 | 10 | 0000405553 | 4 AAB 076 009 9K 04 | SRAABI | PAABFDNT | COF Untreated Side Dyn | - | 0.30 | 0.50 | **0.265** | <0.30 (Selisih -0.035) |
| 24 | 0085006240 | 10 | 0000405583 | F GID 076 001 9K 06 | SRGIDI | PGIDTSMD | Tensile Strength MD | KMM | 6.00 | 8.00 | **0.64** | <6.00 (Selisih -5.36) |
| 31 | 0085006241 | 10 | 0000405610 | E EWE 076 001 9K 01 | SREWEI | SEWEO2TR | O2TR | CMD | 0.00 | 0.20 | **0.21** | >0.20 (Selisih +0.01) |
| 40 | 0085006241 | 20 | 0000405807 | E EWE 076 003 9K 05 | SREWEI | PCGATSMD | Tensile Strength MD | KMM | 18.00 | 26.00 | **27.00** | >26.00 (Selisih +1) |
| 46 | 0085006242 | 10 | 0000405831 | P1 VC2 076 001 9P 02 | SRVC2I | PVC2ELMD | Elongation MD | % | 617 | 681 | **389** | <617 (Selisih -228) |
| 47 | 0085006242 | 10 | 0000405831 | P1 VC2 076 001 9P 02 | SRVC2I | PVC2ELTD | Elongation TD | % | 725 | 801 | **640** | <725 (Selisih -85) |
| 52 | 0085006242 | 10 | 0000405834 | P1 VC2 076 001 9P 03 | SRVC2I | PVC2TSTD | Tensile Strength TD | KMM | 3.78 | 4.18 | **2.73** | <3.78 (Selisih -1.05) |
| 55 | 0085006242 | 20 | 0000405865 | P1 VC2 076 001 9P 02 | SRVC2I | PVC2TSMD | Tensile Strength MD | KMM | 5.53 | 6.11 | **6.48** | >6.11 (Selisih +0.37) |
| 56 | 0085006243 | 10 | 0000405619 | G EAS 076 003 9K 01 | SREASI | PAH8TSTD | Tensile Strength TD | KMM | 25.00 | 32.00 | **0.36** | <25.00 (Selisih -24.64) |
| 60 | 0085006243 | 10 | 0000405917 | G EAS 076 003 9K 05 | SREASI | PAH8TSMD | Tensile Strength MD | KMM | 12.00 | 18.00 | **3.27** | <12.00 (Selisih -8.73) |
| 61 | 0085006243 | 10 | 0000405920 | G EAS 076 003 9K 07 | SREASI | PAH8SHMD | Shrinkage MD | % | 3.00 | 5.00 | **0.58** | <3.00 (Selisih -2.42) |
| 63 | 0085006243 | 10 | 0000405921 | G EAS 076 003 9K 08 | SREASI | PAH8ELTD | Elongation TD | % | 50 | 80 | **92** | >80 (Selisih +12) |
| 64 | 0085006243 | 10 | 0000405922 | G EAS 076 003 9K 08 | SREASI | PAH8ELMD | Elongation MD | % | 150 | 220 | **1** | <150 (Selisih -149) |
| 66 | 0085006244 | 10 | 0000405819 | 4 AAB 076 011 9K 01 | SRAABI | PAABFDNT | COF Untreated Side Dyn | - | 0.300 | 0.500 | **0.265** | <0.300 (Selisih -0.035) |
| 71 | 0085006244 | 10 | 0000405827 | 4 AAB 076 011 9K 05 | SRAABI | SAABSTTR | Surface Tension Treated Side | DCM | 38 | 42 | **37** | <38 (Selisih -1) |
| 77 | 0085006245 | 10 | 0000405705 | F GJB 076 005 9P 04 | SRGJBI | PAH8SHMD | Shrinkage MD | % | 3.00 | 5.00 | **0.58** | <3.00 (Selisih -2.42) |
| 80 | 0085006245 | 20 | 0000405707 | F GJB 076 005 9P 05 | SRGJBI | PAH8TSMD | Tensile Strength MD | KMM | 12.00 | 18.00 | **3.27** | <12.00 (Selisih -8.73) |
| 81 | 0085006245 | 20 | 0000405709 | F GJB 076 005 9P 06 | SRGJBI | PAH8ELTD | Elongation TD | % | 50 | 80 | **92** | >80 (Selisih +12) |
| 82 | 0085006245 | 30 | 0000405936 | F GJB 076 005 9P 05 | SRGJBI | PAH8TSTD | Tensile Strength TD | KMM | 25.00 | 32.00 | **0.36** | <25.00 (Selisih -24.64) |
| 83 | 0085006245 | 30 | 0000405938 | F GJB 076 005 9P 07 | SRGJBI | PAH8ELMD | Elongation MD | % | 150 | 220 | **1** | <150 (Selisih -149) |
| 88 | 0085006270 | 20 | 0000406021 | 4 AAB 086 003 9K 03 | SRAABI | PAABG400 | Gloss 45° | % | 90 | 100 | **89** | <90 (Selisih -1) |
| 96 | 0085006270 | 10 | 0000406029 | 4 AAB 086 003 9K 04 | SRAABI | PAABTH00 | Thickness | MIM | 19.40 | 20.60 | **22.40** | >20.60 (Selisih +1.8) |
| 109 | 0085006271 | 10 | 0000406126 | 4 AAB 086 044 9K 03 | SRAABI | PAABTH00 | Thickness | MIM | 19.40 | 20.60 | **21.25** | >20.60 (Selisih +0.65) |
| 110 | 0085006272 | 10 | 0000406138 | G EAS 076 004 9K 03 | SREASI | PAH8ELMD | Elongation MD | % | 150 | 220 | **1** | <150 (Selisih -149) |
| 112 | 0085006272 | 10 | 0000406142 | G EAS 076 004 9K 05 | SREASI | PAH8SHMD | Shrinkage MD | % | 3.00 | 5.00 | **1.90** | <3.00 (Selisih -1.1) |
| 115 | 0085006272 | 20 | 0000406151 | V EAS 086 002 9K 03 | SREASI | PAH8ELTD | Elongation TD | % | 50 | 80 | **92** | >80 (Selisih +12) |
| 116 | 0085006272 | 20 | 0000406151 | V EAS 086 002 9K 03 | SREASI | PAH8TSTD | Tensile Strength TD | KMM | 25.00 | 32.00 | **0.36** | <25.00 (Selisih -24.64) |
| 118 | 0085006272 | 20 | 0000406155 | V EAS 086 002 9K 05 | SREASI | PAH8SHTD | Shrinkage TD | % | 0.50 | 1.50 | **0.37** | <0.50 (Selisih -0.13) |
| 119 | 0085006272 | 20 | 0000406156 | V EAS 086 002 9K 05 | SREASI | PAH8TSMD | Tensile Strength MD | KMM | 12.00 | 18.00 | **3.27** | <12.00 (Selisih -8.73) |

### 3.2 Parameter Belum Diisi / Kosong (5 Baris)

| No Baris | NO ODO | Item | Batch | Nomor SR | Material | MIC | MIC Description | UoM | Method | Lower Limit | Upper Limit | Value |
| :---: | :---: | :---: | :---: | :--- | :---: | :---: | :--- | :---: | :--- | :---: | :---: | :---: |
| 2 | 0085006234 | 10 | 0000405752 | Z CAD 076 001 9K 01 | SRCADI | PCADTSMD | Tensile Strength MD | KMM | ASTM D 882 | 16.00 | 26.00 | `-` |
| 3 | 0085006234 | 10 | 0000405755 | Z CAD 076 001 9K 02 | SRCADI | PCADELTD | Elongation TD | % | ASTM D 882 | 60.00 | 120.00 | `-` |
| 8 | 0085006234 | 20 | 0000405761 | Z CAD 076 001 9K 04 | SRCADI | PCADTSTD | Tensile Strength TD | KMM | ASTM D 882 | 18.00 | 30.00 | `-` |
| 9 | 0085006234 | 20 | 0000405762 | Z CAD 076 001 9K 04 | SRCADI | PCADELMD | Elongation MD | % | ASTM D 882 | 70.00 | 150.00 | `-` |
| 57 | 0085006243 | 10 | 0000405916 | G EAS 076 003 9K 04 | SREASI | PEASFDUZ | COF Unmetz Side Dyn | - | ASTM 1894 | 0.400 | 0.700 | `-` |

## 4. Tabel Master Gabungan (119 Baris Unik)

| No | NO ODO | Item | Batch | Nomor SR | Material | MIC | MIC Description | Unit Of Measure | Method | Lower Limit | Upper Limit | Value | Status Spec | Sumber Gambar |
| :---: | :---: | :---: | :---: | :--- | :---: | :---: | :--- | :---: | :--- | :---: | :---: | :---: | :---: | :--- |
| 1 | 0085006234 | 10 | 0000405752 | Z CAD 076 001 9K 01 | SRCADI | PCADSTTR | Surface Tension Treated Side | DCM | ASTM D 2578 | 55.00 | 58.00 | 58 | In Spec | Gambar 1 (image_638781.png) |
| 2 | 0085006234 | 10 | 0000405752 | Z CAD 076 001 9K 01 | SRCADI | PCADTSMD | Tensile Strength MD | KMM | ASTM D 882 | 16.00 | 26.00 | - | Belum Diisi (-) | Gambar 1 (image_638781.png) |
| 3 | 0085006234 | 10 | 0000405755 | Z CAD 076 001 9K 02 | SRCADI | PCADELTD | Elongation TD | % | ASTM D 882 | 60.00 | 120.00 | - | Belum Diisi (-) | Gambar 1 (image_638781.png) |
| 4 | 0085006234 | 10 | 0000405757 | Z CAD 076 001 9K 03 | SRCADI | PCADG400 | Gloss 45° | % | ASTM D2457 | 120.00 | 140.00 | 127 | In Spec | Gambar 1 (image_638781.png) |
| 5 | 0085006234 | 10 | 0000405758 | Z CAD 076 001 9K 03 | SRCADI | PCADHZ00 | Haze | % | ASTM D1003 | 1.50 | 3.00 | 2.95 | In Spec | Gambar 1 (image_638781.png) |
| 6 | 0085006234 | 20 | 0000405760 | Z CAD 076 001 9K 04 | SRCADI | PCADSHTD | Shrinkage TD | % | ASTM D1204 | 0.00 | 0.50 | 0.81 | Out of Spec | Gambar 1 (image_638781.png) |
| 7 | 0085006234 | 20 | 0000405761 | Z CAD 076 001 9K 04 | SRCADI | PCADFDNT | COF Untreated Side Dyn | - | ASTM D1894 | 0.20 | 0.60 | 0.480 | In Spec | Gambar 1 (image_638781.png) |
| 8 | 0085006234 | 20 | 0000405761 | Z CAD 076 001 9K 04 | SRCADI | PCADTSTD | Tensile Strength TD | KMM | ASTM D 882 | 18.00 | 30.00 | - | Belum Diisi (-) | Gambar 1 (image_638781.png) |
| 9 | 0085006234 | 20 | 0000405762 | Z CAD 076 001 9K 04 | SRCADI | PCADELMD | Elongation MD | % | ASTM D 882 | 70.00 | 150.00 | - | Belum Diisi (-) | Gambar 1 (image_638781.png) |
| 10 | 0085006234 | 20 | 0000405762 | Z CAD 076 001 9K 04 | SRCADI | PCADSHMD | Shrinkage MD | % | ASTM D1204 | 1.00 | 3.00 | 1.36 | In Spec | Gambar 1 (image_638781.png) |
| 11 | 0085006235 | 10 | 0000405547 | 4 AAB 076 009 9K 01 | SRAABI | PAABTSMD | Tensile Strength MD | KMM | ASTM D 882 | 11.00 | 18.00 | 12.92 | In Spec | Gambar 2 (image_63d938.png) |
| 12 | 0085006235 | 10 | 0000405549 | 4 AAB 076 009 9K 02 | SRAABI | PAABSHMD | Shrinkage MD | % | ASTM D1204 | 3.00 | 5.00 | 4.33 | In Spec | Gambar 2 (image_63d938.png) |
| 13 | 0085006235 | 10 | 0000405549 | 4 AAB 076 009 9K 02 | SRAABI | SAABSTTR | Surface Tension Treated Side | DCM | ASTM D 2578 | 38.00 | 42.00 | 39 | In Spec | Gambar 2 (image_63d938.png) |
| 14 | 0085006235 | 10 | 0000405551 | 4 AAB 076 009 9K 03 | SRAABI | PAABELTD | Elongation TD | % | ASTM D 882 | 30.00 | 90.00 | 46 | In Spec | Gambar 2 (image_63d938.png) |
| 15 | 0085006235 | 10 | 0000405553 | 4 AAB 076 009 9K 04 | SRAABI | PAABFDNT | COF Untreated Side Dyn | - | ASTM D1894 | 0.30 | 0.50 | 0.265 | Out of Spec | Gambar 2 (image_63d938.png) |
| 16 | 0085006235 | 10 | 0000405555 | 4 AAB 076 009 9K 05 | SRAABI | PAABG400 | Gloss 45° | % | ASTM D2457 | 90.00 | 100.00 | 97 | In Spec | Gambar 2 (image_63d938.png) |
| 17 | 0085006235 | 10 | 0000405727 | 4 AAB 076 010 9K 02 | SRAABI | PAABHZ00 | Haze | % | ASTM D1003 | 1.00 | 2.00 | 1.75 | In Spec | Gambar 2 (image_63d938.png) |
| 18 | 0085006235 | 10 | 0000405733 | 4 AAB 076 010 9K 05 | SRAABI | PAABSHTD | Shrinkage TD | % | ASTM D1204 | 0.00 | 3.00 | 2.05 | In Spec | Gambar 2 (image_63d938.png) |
| 19 | 0085006235 | 10 | 0000405733 | 4 AAB 076 010 9K 05 | SRAABI | PAABTSTD | Tensile Strength TD | KMM | ASTM D 882 | 22.00 | 35.00 | 27.71 | In Spec | Gambar 2 (image_63d938.png) |
| 20 | 0085006235 | 20 | 0000405738 | 4 AAB 076 010 9K 04 | SRAABI | PAABELMD | Elongation MD | % | ASTM D 882 | 120.00 | 240.00 | 151 | In Spec | Gambar 2 (image_63d938.png) |
| 21 | 0085006240 | 10 | 0000405561 | F GID 076 001 9K 01 | SRGIDI | PGIDELTD | Elongation TD | % | ASTM D 882 | 30.00 | 70.00 | 45 | In Spec | Gambar 3 (image_63d95d.png) |
| 22 | 0085006240 | 10 | 0000405576 | F GID 076 001 9K 05 | SRGIDI | PGIDTSTD | Tensile Strength TD | KMM | ASTM D 882 | 10.00 | 17.00 | 16.00 | In Spec | Gambar 3 (image_63d95d.png) |
| 23 | 0085006240 | 10 | 0000405580 | F GID 076 001 9K 06 | SRGIDI | SGIDSTCD | Surface Tension Coated Side | DCM | ASTM D 2578 | 38.00 | 44.00 | 40 | In Spec | Gambar 3 (image_63d95d.png) |
| 24 | 0085006240 | 10 | 0000405583 | F GID 076 001 9K 06 | SRGIDI | PGIDTSMD | Tensile Strength MD | KMM | ASTM D 882 | 6.00 | 8.00 | 0.64 | Out of Spec | Gambar 3 (image_63d95d.png) |
| 25 | 0085006240 | 20 | 0000405591 | F GID 076 001 9K 09 | SRGIDI | PALZTH00 | Thickness | - | ASTM D 374 | 67.90 | 72.10 | 69.97 | In Spec | Gambar 3 (image_63d95d.png) |
| 26 | 0085006240 | 20 | 0000405596 | F GID 076 001 9K 10 | SRGIDI | PGIDSHMD | Shrinkage MD | % | ASTM D 1204 | 1.00 | 4.00 | 3.25 | In Spec | Gambar 3 (image_63d95d.png) |
| 27 | 0085006240 | 20 | 0000405599 | F GID 076 001 9K 11 | SRGIDI | PGIDELMD | Elongation MD | % | ASTM D 882 | 130.00 | 170.00 | 138 | In Spec | Gambar 3 (image_63d95d.png) |
| 28 | 0085006240 | 20 | 0000405601 | F GID 076 001 9K 12 | SRGIDI | PGIDSHTD | Shrinkage TD | % | ASTM D 1204 | 1.00 | 3.00 | 2.87 | In Spec | Gambar 3 (image_63d95d.png) |
| 29 | 0085006240 | 20 | 0000405607 | F GID 076 001 9K 14 | SRGIDI | PGIDFDG2 | Gloss 20° | % | ASTM D2457 | 50.00 | 80.00 | 67 | In Spec | Gambar 3 (image_63d95d.png) |
| 30 | 0085006241 | 10 | 0000405610 | E EWE 076 001 9K 01 | SREWEI | PCGASHTD | Shrinkage TD | % | ASTM D 1204 | 0.00 | 0.60 | 0.32 | In Spec | Gambar 4 (image_63d998.png) |
| 31 | 0085006241 | 10 | 0000405610 | E EWE 076 001 9K 01 | SREWEI | SEWEO2TR | O2TR | CMD | ASTM F1927 23°C, 50%RH | 0.00 | 0.20 | 0.21 | Out of Spec | Gambar 4 (image_63d998.png) |
| 32 | 0085006241 | 10 | 0000405611 | E EWE 076 001 9K 02 | SREWEI | SEWEODMZ | Optical Density | - | - | 3.00 | 3.50 | 3.14 | In Spec | Gambar 4 (image_63d998.png) |
| 33 | 0085006241 | 10 | 0000405611 | E EWE 076 001 9K 02 | SREWEI | SEWESTMZ | Surface Tension Metz Side | DCM | ASTM D 2578 | 50.00 | 58.00 | 55 | In Spec | Gambar 4 (image_63d998.png) |
| 34 | 0085006241 | 10 | 0000405611 | E EWE 076 001 9K 02 | SREWEI | SEWESTUZ | Surface Tension Unmetz Side | DCM | ASTM D 2578 | 55.00 | 58.00 | 55 | In Spec | Gambar 4 (image_63d998.png) |
| 35 | 0085006241 | 10 | 0000405612 | E EWE 076 001 9K 02 | SREWEI | PCGAELTD | Elongation TD | % | ASTM D 882 | 75.00 | 120.00 | 85 | In Spec | Gambar 4 (image_63d998.png) |
| 36 | 0085006241 | 20 | 0000405613 | E EWE 076 001 9K 03 | SREWEI | PCGASHMD | Shrinkage MD | % | ASTM D 1204 | 0.00 | 2.00 | 1.40 | In Spec | Gambar 4 (image_63d998.png) |
| 37 | 0085006241 | 20 | 0000405805 | E EWE 076 003 9K 04 | SREWEI | PCGATH00 | Thickness | MIM | ASTM D 374 | 11.64 | 12.36 | 12.17 | In Spec | Gambar 4 (image_63d998.png) |
| 38 | 0085006241 | 20 | 0000405805 | E EWE 076 003 9K 04 | SREWEI | PEWEFDUZ | COF Unmetz Side Dyn | - | ASTM D 1894 | 0.50 | 1.00 | 0.690 | In Spec | Gambar 4 (image_63d998.png) |
| 39 | 0085006241 | 20 | 0000405805 | E EWE 076 003 9K 04 | SREWEI | SEWEMVTR | MVTR | GMD | ASTM F1249 38°C, 90%RH | 0.00 | 0.20 | 0.19 | In Spec | Gambar 4 (image_63d998.png) |
| 40 | 0085006241 | 20 | 0000405807 | E EWE 076 003 9K 05 | SREWEI | PCGATSMD | Tensile Strength MD | KMM | ASTM D 882 | 18.00 | 26.00 | 27.00 | Out of Spec | Gambar 4 (image_63d998.png) |
| 41 | 0085006241 | 20 | 0000405808 | E EWE 076 003 9K 05 | SREWEI | PCGAELMD | Elongation MD | % | ASTM D 882 | 90.00 | 150.00 | 95 | In Spec | Gambar 4 (image_63d998.png) |
| 42 | 0085006241 | 20 | 0000405808 | E EWE 076 003 9K 05 | SREWEI | PCGATSTD | Tensile Strength TD | KMM | ASTM D 882 | 20.00 | 30.00 | 26.00 | In Spec | Gambar 4 (image_63d998.png) |
| 43 | 0085006242 | 30 | 0000405829 | P1 VC2 076 001 9P 01 | SRVC2I | PVC2SHMD | Shrinkage MD | % | ASTM D 1204 | -1.00 | 0.00 | -0.32 | In Spec | Gambar 5 (image_63d9bb.png) |
| 44 | 0085006242 | 30 | 0000405829 | P1 VC2 076 001 9P 01 | SRVC2I | PVC2SHTD | Shrinkage TD | % | ASTM D 1204 | 0.00 | 2.00 | 1.39 | In Spec | Gambar 5 (image_63d9bb.png) |
| 45 | 0085006242 | 30 | 0000405829 | P1 VC2 076 001 9P 01 | SRVC2I | SVC2FDSS | COF Sealable Side Dyn | - | ASTM D 1894 | 0.050 | 0.150 | 0.136 | In Spec | Gambar 5 (image_63d9bb.png) |
| 46 | 0085006242 | 10 | 0000405831 | P1 VC2 076 001 9P 02 | SRVC2I | PVC2ELMD | Elongation MD | % | ASTM D 882 | 617 | 681 | 389 | Out of Spec | Gambar 5 (image_63d9bb.png) |
| 47 | 0085006242 | 10 | 0000405831 | P1 VC2 076 001 9P 02 | SRVC2I | PVC2ELTD | Elongation TD | % | ASTM D 882 | 725 | 801 | 640 | Out of Spec | Gambar 5 (image_63d9bb.png) |
| 48 | 0085006242 | 10 | 0000405833 | P1 VC2 076 001 9P 03 | SRVC2I | SVC2HZ00 | Haze | % | ASTM D 1003 | 5.50 | 6.50 | 5.85 | In Spec | Gambar 5 (image_63d9bb.png) |
| 49 | 0085006242 | 10 | 0000405833 | P1 VC2 076 001 9P 03 | SRVC2I | SVC2SSSS | Seal Strength Sealable Side ( 115 Ã¢Â.. | GPI | TRIAS METHOD | 1900 | 2300 | 2185 | In Spec | Gambar 5 (image_63d9bb.png) |
| 50 | 0085006242 | 10 | 0000405833 | P1 VC2 076 001 9P 03 | SRVC2I | SVC2STNS | Surface Tension Non Seal Side | DCM | ASTM D 2578 | 36 | 40 | 39 | In Spec | Gambar 5 (image_63d9bb.png) |
| 51 | 0085006242 | 10 | 0000405834 | P1 VC2 076 001 9P 03 | SRVC2I | PVC2G400 | Gloss 45° | % | ASTM D 2457 | 70 | 90 | 79 | In Spec | Gambar 5 (image_63d9bb.png) |
| 52 | 0085006242 | 10 | 0000405834 | P1 VC2 076 001 9P 03 | SRVC2I | PVC2TSTD | Tensile Strength TD | KMM | ASTM D 882 | 3.78 | 4.18 | 2.73 | Out of Spec | Gambar 5 (image_63d9bb.png) |
| 53 | 0085006242 | 10 | 0000405834 | P1 VC2 076 001 9P 03 | SRVC2I | SVC2FDNS | COF Non Seal Side Dyn | - | ASTM D 1894 | 0.100 | 0.200 | 0.147 | In Spec | Gambar 5 (image_63d9bb.png) |
| 54 | 0085006242 | 20 | 0000405865 | P1 VC2 076 001 9P 02 | SRVC2I | PVC2TH00 | Thickness | - | ASTM D 374 | 24.25 | 25.75 | 25.07 | In Spec | Gambar 5 (image_63d9bb.png) |
| 55 | 0085006242 | 20 | 0000405865 | P1 VC2 076 001 9P 02 | SRVC2I | PVC2TSMD | Tensile Strength MD | KMM | ASTM D 882 | 5.53 | 6.11 | 6.48 | Out of Spec | Gambar 5 (image_63d9bb.png) |
| 56 | 0085006243 | 10 | 0000405619 | G EAS 076 003 9K 01 | SREASI | PAH8TSTD | Tensile Strength TD | KMM | ASTM D 882 | 25.00 | 32.00 | 0.36 | Out of Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 57 | 0085006243 | 10 | 0000405916 | G EAS 076 003 9K 04 | SREASI | PEASFDUZ | COF Unmetz Side Dyn | - | ASTM 1894 | 0.400 | 0.700 | - | Belum Diisi (-) | Gambar 6 & 7 (image_63d9f1.png) |
| 58 | 0085006243 | 10 | 0000405916 | G EAS 076 003 9K 04 | SREASI | SEASODMZ | Optical Density | - | - | 2.20 | 2.70 | 2.65 | In Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 59 | 0085006243 | 10 | 0000405916 | G EAS 076 003 9K 04 | SREASI | SEASSTUZ | Surface Tension Unmetz Side | DCM | ASTM D 2578 | 38 | 44 | 38 | In Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 60 | 0085006243 | 10 | 0000405917 | G EAS 076 003 9K 05 | SREASI | PAH8TSMD | Tensile Strength MD | KMM | ASTM D 882 | 12.00 | 18.00 | 3.27 | Out of Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 61 | 0085006243 | 10 | 0000405920 | G EAS 076 003 9K 07 | SREASI | PAH8SHMD | Shrinkage MD | % | ASTM D1204 | 3.00 | 5.00 | 0.58 | Out of Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 62 | 0085006243 | 10 | 0000405920 | G EAS 076 003 9K 07 | SREASI | PAH8TH00 | Thickness | MIM | ASTM D 374 | 48.50 | 51.50 | 50.09 | In Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 63 | 0085006243 | 10 | 0000405921 | G EAS 076 003 9K 08 | SREASI | PAH8ELTD | Elongation TD | % | ASTM D 882 | 50 | 80 | 92 | Out of Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 64 | 0085006243 | 10 | 0000405922 | G EAS 076 003 9K 08 | SREASI | PAH8ELMD | Elongation MD | % | ASTM D 882 | 150 | 220 | 1 | Out of Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 65 | 0085006243 | 10 | 0000405926 | G EAS 076 003 9K 10 | SREASI | PAH8SHTD | Shrinkage TD | % | ASTM D1204 | 0.50 | 1.50 | 0.59 | In Spec | Gambar 6 & 7 (image_63d9f1.png) |
| 66 | 0085006244 | 10 | 0000405819 | 4 AAB 076 011 9K 01 | SRAABI | PAABFDNT | COF Untreated Side Dyn | - | ASTM D1894 | 0.300 | 0.500 | 0.265 | Out of Spec | Gambar 8 (image_63dcfd.png) |
| 67 | 0085006244 | 10 | 0000405824 | 4 AAB 076 011 9K 03 | SRAABI | PAABHZ00 | Haze | % | ASTM D1003 | 1.00 | 2.00 | 1.75 | In Spec | Gambar 8 (image_63dcfd.png) |
| 68 | 0085006244 | 10 | 0000405825 | 4 AAB 076 011 9K 04 | SRAABI | PAABSHTD | Shrinkage TD | % | ASTM D1204 | 0.00 | 3.00 | 2.05 | In Spec | Gambar 8 (image_63dcfd.png) |
| 69 | 0085006244 | 10 | 0000405826 | 4 AAB 076 011 9K 04 | SRAABI | PAABELTD | Elongation TD | % | ASTM D 882 | 30 | 90 | 46 | In Spec | Gambar 8 (image_63dcfd.png) |
| 70 | 0085006244 | 10 | 0000405826 | 4 AAB 076 011 9K 04 | SRAABI | PAABG400 | Gloss 45° | % | ASTM D2457 | 90 | 100 | 97 | In Spec | Gambar 8 (image_63dcfd.png) |
| 71 | 0085006244 | 10 | 0000405827 | 4 AAB 076 011 9K 05 | SRAABI | SAABSTTR | Surface Tension Treated Side | DCM | ASTM D 2578 | 38 | 42 | 37 | Out of Spec | Gambar 8 (image_63dcfd.png) |
| 72 | 0085006244 | 20 | 0000405931 | 4 AAB 076 011 9K 02 | SRAABI | PAABELMD | Elongation MD | % | ASTM D 882 | 120 | 240 | 151 | In Spec | Gambar 8 (image_63dcfd.png) |
| 73 | 0085006244 | 20 | 0000405931 | 4 AAB 076 011 9K 02 | SRAABI | PAABTSMD | Tensile Strength MD | KMM | ASTM D 882 | 11.00 | 18.00 | 12.92 | In Spec | Gambar 8 (image_63dcfd.png) |
| 74 | 0085006244 | 20 | 0000405931 | 4 AAB 076 011 9K 02 | SRAABI | PAABTSTD | Tensile Strength TD | KMM | ASTM D 882 | 22.00 | 35.00 | 27.71 | In Spec | Gambar 8 (image_63dcfd.png) |
| 75 | 0085006244 | 20 | 0000405932 | 4 AAB 076 011 9K 03 | SRAABI | PAABSHMD | Shrinkage MD | % | ASTM D1204 | 3.00 | 5.00 | 4.33 | In Spec | Gambar 8 (image_63dcfd.png) |
| 76 | 0085006245 | 10 | 0000405704 | F GJB 076 005 9P 03 | SRGJBI | SGJBSTNC | Surface Tension Uncoated Side | DCM | ASTM D 2578 | 38 | 44 | 42 | In Spec | Gambar 9 (image_63f3c4.png) |
| 77 | 0085006245 | 10 | 0000405705 | F GJB 076 005 9P 04 | SRGJBI | PAH8SHMD | Shrinkage MD | % | ASTM D1204 | 3.00 | 5.00 | 0.58 | Out of Spec | Gambar 9 (image_63f3c4.png) |
| 78 | 0085006245 | 10 | 0000405705 | F GJB 076 005 9P 04 | SRGJBI | PAH8SHTD | Shrinkage TD | % | ASTM D1204 | 0.50 | 1.50 | 0.59 | In Spec | Gambar 9 (image_63f3c4.png) |
| 79 | 0085006245 | 10 | 0000405706 | F GJB 076 005 9P 04 | SRGJBI | PAH8TH00 | Thickness | MIM | ASTM D 374 | 48.50 | 51.50 | 50.09 | In Spec | Gambar 9 (image_63f3c4.png) |
| 80 | 0085006245 | 20 | 0000405707 | F GJB 076 005 9P 05 | SRGJBI | PAH8TSMD | Tensile Strength MD | KMM | ASTM D 882 | 12.00 | 18.00 | 3.27 | Out of Spec | Gambar 9 (image_63f3c4.png) |
| 81 | 0085006245 | 20 | 0000405709 | F GJB 076 005 9P 06 | SRGJBI | PAH8ELTD | Elongation TD | % | ASTM D 882 | 50 | 80 | 92 | Out of Spec | Gambar 9 (image_63f3c4.png) |
| 82 | 0085006245 | 30 | 0000405936 | F GJB 076 005 9P 05 | SRGJBI | PAH8TSTD | Tensile Strength TD | KMM | ASTM D 882 | 25.00 | 32.00 | 0.36 | Out of Spec | Gambar 9 (image_63f3c4.png) |
| 83 | 0085006245 | 30 | 0000405938 | F GJB 076 005 9P 07 | SRGJBI | PAH8ELMD | Elongation MD | % | ASTM D 882 | 150 | 220 | 1 | Out of Spec | Gambar 9 (image_63f3c4.png) |
| 84 | 0085006245 | 30 | 0000405938 | F GJB 076 005 9P 07 | SRGJBI | PGJBFDNC | COF Uncoated Side Dyn | - | ASTM 1894 | 0.400 | 0.800 | 0.480 | In Spec | Gambar 9 (image_63f3c4.png) |
| 85 | 0085006270 | 10 | 0000406016 | 4 AAB 086 003 9K 01 | SRAABI | PAABELMD | Elongation MD | % | ASTM D 882 | 120 | 240 | 180 | In Spec | Gambar 10 (image_63f41a.png) |
| 86 | 0085006270 | 10 | 0000406017 | 4 AAB 086 003 9K 01 | SRAABI | PAABFDTR | COF Treated Side Dyn | - | ASTM D 374 | 0.300 | 0.600 | 0.562 | In Spec | Gambar 10 (image_63f41a.png) |
| 87 | 0085006270 | 10 | 0000406018 | 4 AAB 086 003 9K 02 | SRAABI | PAABTSMD | Tensile Strength MD | KMM | ASTM D 882 | 11.00 | 18.00 | 14.00 | In Spec | Gambar 10 (image_63f41a.png) |
| 88 | 0085006270 | 20 | 0000406021 | 4 AAB 086 003 9K 03 | SRAABI | PAABG400 | Gloss 45° | % | ASTM D2457 | 90 | 100 | 89 | Out of Spec | Gambar 10 (image_63f41a.png) |
| 89 | 0085006270 | 20 | 0000406021 | 4 AAB 086 003 9K 03 | SRAABI | PAABSHMD | Shrinkage MD | % | ASTM D1204 | 3.00 | 5.00 | 4.65 | In Spec | Gambar 10 (image_63f41a.png) |
| 90 | 0085006270 | 20 | 0000406021 | 4 AAB 086 003 9K 03 | SRAABI | PAABTSTD | Tensile Strength TD | KMM | ASTM D 882 | 22.00 | 35.00 | 26.90 | In Spec | Gambar 10 (image_63f41a.png) |
| 91 | 0085006270 | 10 | 0000406025 | 4 AAB 086 022 9K 02 | SRAABI | SAABSTTR | Surface Tension Treated Side | DCM | ASTM D 2578 | 38 | 42 | 40 | In Spec | Gambar 10 (image_63f41a.png) |
| 92 | 0085006270 | 10 | 0000406027 | 4 AAB 086 022 9K 03 | SRAABI | PAABHZ00 | Haze | % | ASTM D1003 | 1.00 | 2.00 | 1.00 | In Spec | Gambar 10 (image_63f41a.png) |
| 93 | 0085006270 | 10 | 0000406028 | 4 AAB 086 003 9K 04 | SRAABI | PAABELTD | Elongation TD | % | ASTM D 882 | 30 | 90 | 65 | In Spec | Gambar 10 (image_63f41a.png) |
| 94 | 0085006270 | 10 | 0000406028 | 4 AAB 086 003 9K 04 | SRAABI | PAABFDNT | COF Untreated Side Dyn | - | ASTM D1894 | 0.300 | 0.500 | 0.450 | In Spec | Gambar 10 (image_63f41a.png) |
| 95 | 0085006270 | 10 | 0000406028 | 4 AAB 086 003 9K 04 | SRAABI | PAABSHTD | Shrinkage TD | % | ASTM D1204 | 0.00 | 3.00 | 1.78 | In Spec | Gambar 10 (image_63f41a.png) |
| 96 | 0085006270 | 10 | 0000406029 | 4 AAB 086 003 9K 04 | SRAABI | PAABTH00 | Thickness | MIM | ASTM D 374 | 19.40 | 20.60 | 22.40 | Out of Spec | Gambar 10 (image_63f41a.png) |
| 97 | 0085006271 | 10 | 0000406113 | 4 AAB 086 024 9K 01 | SRAABI | PAABHZ00 | Haze | % | ASTM D1003 | 1.00 | 2.00 | 1.23 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 98 | 0085006271 | 10 | 0000406113 | 4 AAB 086 024 9K 01 | SRAABI | PAABTSMD | Tensile Strength MD | KMM | ASTM D 882 | 11.00 | 18.00 | 15.05 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 99 | 0085006271 | 10 | 0000406113 | 4 AAB 086 024 9K 01 | SRAABI | SAABO2TR | O2TR | CMD | ASTM F1927 23°C, 50%RH | 30.00 | 100.00 | 69.50 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 100 | 0085006271 | 10 | 0000406115 | 4 AAB 086 024 9K 02 | SRAABI | PAABTSTD | Tensile Strength TD | KMM | ASTM D 882 | 22.00 | 35.00 | 27.45 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 101 | 0085006271 | 10 | 0000406118 | 4 AAB 086 024 9K 03 | SRAABI | PAABG400 | Gloss 45° | % | ASTM D2457 | 90 | 100 | 93 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 102 | 0085006271 | 10 | 0000406118 | 4 AAB 086 024 9K 03 | SRAABI | SAABSTTR | Surface Tension Treated Side | DCM | ASTM D 2578 | 38 | 42 | 41 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 103 | 0085006271 | 10 | 0000406119 | 4 AAB 086 024 9K 04 | SRAABI | PAABELMD | Elongation MD | % | ASTM D 882 | 120 | 240 | 183 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 104 | 0085006271 | 10 | 0000406120 | 4 AAB 086 024 9K 04 | SRAABI | PAABSHMD | Shrinkage MD | % | ASTM D1204 | 3.00 | 5.00 | 4.05 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 105 | 0085006271 | 10 | 0000406120 | 4 AAB 086 024 9K 04 | SRAABI | SAABMVTR | MVTR | GMD | ASTM F1249 38°C, 90%RH | 0.10 | 1.00 | 0.58 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 106 | 0085006271 | 10 | 0000406125 | 4 AAB 086 044 9K 03 | SRAABI | PAABELTD | Elongation TD | % | ASTM D 882 | 30 | 90 | 60 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 107 | 0085006271 | 10 | 0000406125 | 4 AAB 086 044 9K 03 | SRAABI | PAABFDNT | COF Untreated Side Dyn | - | ASTM D1894 | 0.300 | 0.500 | 0.399 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 108 | 0085006271 | 10 | 0000406126 | 4 AAB 086 044 9K 03 | SRAABI | PAABSHTD | Shrinkage TD | % | ASTM D1204 | 0.00 | 3.00 | 1.67 | In Spec | Gambar 11 (image_6dfc0b.png) |
| 109 | 0085006271 | 10 | 0000406126 | 4 AAB 086 044 9K 03 | SRAABI | PAABTH00 | Thickness | MIM | ASTM D 374 | 19.40 | 20.60 | 21.25 | Out of Spec | Gambar 11 (image_6dfc0b.png) |
| 110 | 0085006272 | 10 | 0000406138 | G EAS 076 004 9K 03 | SREASI | PAH8ELMD | Elongation MD | % | ASTM D 882 | 150 | 220 | 1 | Out of Spec | Gambar 12 (image_6e4d8a.png) |
| 111 | 0085006272 | 10 | 0000406141 | G EAS 076 004 9K 05 | SREASI | SEASSTUZ | Surface Tension Unmetz Side | DCM | ASTM D 2578 | 38 | 44 | 42 | In Spec | Gambar 12 (image_6e4d8a.png) |
| 112 | 0085006272 | 10 | 0000406142 | G EAS 076 004 9K 05 | SREASI | PAH8SHMD | Shrinkage MD | % | ASTM D1204 | 3.00 | 5.00 | 1.90 | Out of Spec | Gambar 12 (image_6e4d8a.png) |
| 113 | 0085006272 | 10 | 0000406144 | G EAS 076 004 9K 06 | SREASI | PAH8TH00 | Thickness | MIM | ASTM D 374 | 48.50 | 51.50 | 50.14 | In Spec | Gambar 12 (image_6e4d8a.png) |
| 114 | 0085006272 | 10 | 0000406145 | G EAS 076 004 9K 07 | SREASI | SEASODMZ | Optical Density | - | - | 2.20 | 2.70 | 2.56 | In Spec | Gambar 12 (image_6e4d8a.png) |
| 115 | 0085006272 | 20 | 0000406151 | V EAS 086 002 9K 03 | SREASI | PAH8ELTD | Elongation TD | % | ASTM D 882 | 50 | 80 | 92 | Out of Spec | Gambar 12 (image_6e4d8a.png) |
| 116 | 0085006272 | 20 | 0000406151 | V EAS 086 002 9K 03 | SREASI | PAH8TSTD | Tensile Strength TD | KMM | ASTM D 882 | 25.00 | 32.00 | 0.36 | Out of Spec | Gambar 12 (image_6e4d8a.png) |
| 117 | 0085006272 | 20 | 0000406154 | V EAS 086 002 9K 04 | SREASI | PEASFDUZ | COF Unmetz Side Dyn | - | ASTM 1894 | 0.400 | 0.700 | 0.543 | In Spec | Gambar 12 (image_6e4d8a.png) |
| 118 | 0085006272 | 20 | 0000406155 | V EAS 086 002 9K 05 | SREASI | PAH8SHTD | Shrinkage TD | % | ASTM D1204 | 0.50 | 1.50 | 0.37 | Out of Spec | Gambar 12 (image_6e4d8a.png) |
| 119 | 0085006272 | 20 | 0000406156 | V EAS 086 002 9K 05 | SREASI | PAH8TSMD | Tensile Strength MD | KMM | ASTM D 882 | 12.00 | 18.00 | 3.27 | Out of Spec | Gambar 12 (image_6e4d8a.png) |
