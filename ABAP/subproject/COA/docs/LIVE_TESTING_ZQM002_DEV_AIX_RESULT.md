# LAPORAN LIVE TESTING ZQM002 DI DEV AIX (TRD CLIENT 130) VS MARKDOWN SKENARIO

| Parameter | Keterangan |
|---|---|
| **Sistem Target** | SAP DEV AIX (`TRD` Client `130`) |
| **Program ABAP** | `SAPMZQM002` / `ZQMI_COA` (TOP 486, F01 6042) |
| **User Eksekusi** | `TRSTDEV` |
| **Waktu Live Run** | 18 November 2026, 17:00 WIB |
| **Total Skenario Diuji** | **21 Delivery Order (DO)** — 100% Seluruh Skenario |
| **Hasil Rekonsiliasi** | **100% MATCH (ZERO REGRESSION) ✅** |

---

## 📊 RINGKASAN REKONSILIASI PER SKENARIO

| No | Kelompok | Kode Skenario | Nomor DO | Material | Jml MIC | Baseline Ref | Status Live DEV AIX | Kesimpulan |
|:--:|:---|:---|:---:|:---:|:---:|:---:|:---:|:---:|
| 1 | Baseline & Warisan | **L-QM01 & L-QM15** | `0085006234` | `SRCADI` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 2 | Baseline & Warisan | **L-QM02** | `0085006235` | `SRAABI` | 11 | 11 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 3 | Baseline & Warisan | **L-QM03** | `0085006240` | `SRGIDI` | 9 | 9 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 4 | Baseline & Warisan | **L-QM04** | `0085006241` | `SREWEI` | 13 | 13 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 5 | Baseline & Warisan | **L-QM05 & L-QM06** | `0085006242` | `SRVC2I` | 12 | 12 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 6 | Baseline & Warisan | **L-QM07 & L-QM08** | `0085006243` | `SREASI` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 7 | Baseline & Warisan | **L-QM09** | `0085006244` | `SRAABI` | 11 | 11 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 8 | Baseline & Warisan | **L-QM10** | `0085006245` | `SRGJBI` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 9 | Baseline & Warisan | **L-QM11** | `0085006270` | `SRAABI` | 12 | 12 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 10 | Baseline & Warisan | **L-QM12** | `0085006271` | `SRAABI` | 11 | 11 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 11 | Baseline & Warisan | **L-QM13** | `0085006272` | `SREASI` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 12 | Multi-Level Genealogi | **ML-QM01** | `0085006276` | `SRACBI` | 14 | 14 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 13 | Multi-Level Genealogi | **ML-QM02** | `0085006277` | `SRACBI` | 14 | 14 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 14 | Multi-Level Genealogi | **ML-QM03** | `0085006278` | `SRGLBI` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 15 | Multi-Level Genealogi | **ML-QM04** | `0085006279` | `SREC7I` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 16 | Grouping Alias | **AL-STRUKTUR** | `0085006280` | `SRABDI` | 9 | 9 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 17 | Grouping Alias | **AL-MIXED** | `0085006281` | `SRAABI` | 11 | 11 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 18 | Grouping Alias | **AL-VALUE1** | `0085006282` | `SRAABI` | 9 | 9 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 19 | Grouping Alias | **AL-VALUE2** | `0085006284` | `SRAAAI` | 9 | 9 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 20 | Outsource TTA | **TTA-OUTSOURCE** | `0085006285` | `SRCBUX` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |
| 21 | Outsource TTA | **TTA-CONVERTING** | `0085006286` | `SREYAI` | 10 | 10 MIC | ✅ 100% MATCH | **LULUS / VALID** |

---

## 🔍 DETAIL REKONSILIASI NILAI PER SKENARIO


### 1. Skenario L-QM01 & L-QM15 — DO `0085006234` (SRCADI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000100 (PT INDOFOOD CBP) | **SO:** 0000007201
**Karakteristik Alur:** Base film normal 1 JR; Verifikasi edit manual di ALV (ZLOG_COA)

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PCADELMD` | Elongation MD | ASTM D 882 | 70 - 150 | **75** | 75 | `040000020662` | ✅ MATCH |
| 2 | `PCADELTD` | Elongation TD | ASTM D 882 | 60 - 120 | **110** | 110 | `040000020662` | ✅ MATCH |
| 3 | `PCADSHMD` | Shrinkage MD | ASTM D1204 | 1.00 - 3.00 | **1.36** | 1.36 | `040000020662` | ✅ MATCH |
| 4 | `PCADSHTD` | Shrinkage TD | ASTM D1204 | 0.00 - 0.50 | **0.43** | 0.43 | `040000020662` | ✅ MATCH |
| 5 | `PCADHZ00` | Haze | ASTM D1003 | 1.50 - 3.00 | **2.95** | 2.95 | `040000020662` | ✅ MATCH |
| 6 | `PCADG400` | Gloss 45Â° | ASTM D2457 | 120 - 140 | **127** | 127 | `040000020662` | ✅ MATCH |
| 7 | `PCADSTTR` | Surface Tension Treated Side | ASTM D 2578 | 55 - 58 | **58** | 58 | `040000020662` | ✅ MATCH |
| 8 | `PCADFDNT` | COF Untreated Side Dyn | ASTM D1894 | 0.200 - 0.600 | **0.480** | 0.480 | `040000020662` | ✅ MATCH |
| 9 | `PCADTSMD` | Tensile Strength MD | ASTM D 882 | 16.00 - 26.00 | **17.5** | 17.5 | `040000020662` | ✅ MATCH |
| 10 | `PCADTSTD` | Tensile Strength TD | ASTM D 882 | 18.00 - 30.00 | **22.5** | 22.5 | `040000020662` | ✅ MATCH |

### 2. Skenario L-QM02 — DO `0085006235` (SRAABI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000101 (PT MAYORA INDAH) | **SO:** 0000007202
**Karakteristik Alur:** Base film normal dengan beda JR dalam 1 DO

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAABTH00` | Thickness | ASTM D 374 | 19.40 - 20.60 | **19.58** | 19.58 | `040000020753` | ✅ MATCH |
| 2 | `PAABTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **12.92** | 12.92 | `040000020753` | ✅ MATCH |
| 3 | `PAABTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 35.00 | **27.71** | 27.71 | `040000020753` | ✅ MATCH |
| 4 | `PAABELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **151** | 151 | `040000020753` | ✅ MATCH |
| 5 | `PAABELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **46** | 46 | `040000020753` | ✅ MATCH |
| 6 | `PAABSHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **4.33** | 4.33 | `040000020753` | ✅ MATCH |
| 7 | `PAABSHTD` | Shrinkage TD | ASTM D1204 | 0.00 - 3.00 | **2.05** | 2.05 | `040000020753` | ✅ MATCH |
| 8 | `PAABHZ00` | Haze | ASTM D1003 | 1.00 - 2.00 | **1.75** | 1.75 | `040000020753` | ✅ MATCH |
| 9 | `PAABG400` | Gloss 45Â° | ASTM D2457 | 90 - 100 | **97** | 97 | `040000020753` | ✅ MATCH |
| 10 | `SAABSTTR` | Surface Tension Treated Side | ASTM D 2578 | 38 - 42 | **39** | 39 | `050000014208` | ✅ MATCH |
| 11 | `PAABFDNT` | COF Untreated Side Dyn | ASTM D1894 | 0.300 - 0.500 | **0.265** | 0.265 | `040000020753` | ✅ MATCH |

### 3. Skenario L-QM03 — DO `0085006240` (SRGIDI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000102 (PT KALBE FARMA) | **SO:** 0000007203
**Karakteristik Alur:** Converting normal, 1 JR converting sama

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PALZTH00` | Thickness | ASTM D 374 | 67.90 - 72.10 | **69.97** | 69.97 | `040000020676` | ✅ MATCH |
| 2 | `PGIDTSMD` | Tensile Strength MD | ASTM D 882 | 6.00 - 8.00 | **0.64** | 0.64 | `040000020757` | ✅ MATCH |
| 3 | `PGIDTSTD` | Tensile Strength TD | ASTM D 882 | 10.00 - 17.00 | **16.00** | 16.00 | `040000020757` | ✅ MATCH |
| 4 | `PGIDELMD` | Elongation MD | ASTM D 882 | 130 - 170 | **138** | 138 | `040000020757` | ✅ MATCH |
| 5 | `PGIDELTD` | Elongation TD | ASTM D 882 | 30 - 70 | **45** | 45 | `040000020757` | ✅ MATCH |
| 6 | `PGIDSHMD` | Shrinkage MD | ASTM D 1204 | 1.00 - 4.00 | **3.25** | 3.25 | `040000020757` | ✅ MATCH |
| 7 | `PGIDSHTD` | Shrinkage TD | ASTM D 1204 | 1.00 - 3.00 | **2.87** | 2.87 | `040000020757` | ✅ MATCH |
| 8 | `SGIDSTCD` | Surface Tension Coated Side | ASTM D 2578 | 38 - 44 | **40** | 40 | `050000014206` | ✅ MATCH |
| 9 | `PGIDFDG2` | Gloss 20Â° | ASTM D2457 | 50 - 80 | **67** | 67 | `040000020757` | ✅ MATCH |

### 4. Skenario L-QM04 — DO `0085006241` (SREWEI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000103 (PT UNILEVER INDONESIA) | **SO:** 0000007204
**Karakteristik Alur:** Converting normal dengan beda JR converting

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PCGATH00` | Thickness | ASTM D 374 | 11.64 - 12.36 | **12.17** | 12.17 | `040000020693` | ✅ MATCH |
| 2 | `PCGATSMD` | Tensile Strength MD | ASTM D 882 | 18.00 - 26.00 | **27.00** | 27.00 | `040000020693` | ✅ MATCH |
| 3 | `PCGATSTD` | Tensile Strength TD | ASTM D 882 | 20.00 - 30.00 | **26.00** | 26.00 | `040000020693` | ✅ MATCH |
| 4 | `PCGAELMD` | Elongation MD | ASTM D 882 | 90 - 150 | **95** | 95 | `040000020693` | ✅ MATCH |
| 5 | `PCGAELTD` | Elongation TD | ASTM D 882 | 75 - 120 | **85** | 85 | `040000020693` | ✅ MATCH |
| 6 | `PCGASHMD` | Shrinkage MD | ASTM D 1204 | 0.00 - 2.00 | **1.40** | 1.40 | `040000020693` | ✅ MATCH |
| 7 | `PCGASHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 0.60 | **0.32** | 0.32 | `040000020693` | ✅ MATCH |
| 8 | `SEWESTUZ` | Surface Tension Unmetz Side | ASTM D 2578 | 55 - 58 | **55** | 55 | `050000014215` | ✅ MATCH |
| 9 | `PEWEFDUZ` | Surface Tension Metz Side | ASTM D 1894 | 0.500 - 1.000 | **0.690** | 0.690 | `040000020771` | ✅ MATCH |
| 10 | `SEWESTMZ` | COF Unmetz Side Dyn | ASTM D 2578 | 50 - 58 | **55** | 55 | `050000014215` | ✅ MATCH |
| 11 | `SEWEMVTR` | MVTR | ASTM F1249 38Â°C, 90%RH | 0.00 - 0.20 | **0.19** | 0.19 | `050000014215` | ✅ MATCH |
| 12 | `SEWEO2TR` | O2TR | ASTM F1927 23Â°C, 50%RH | 0.00 - 0.20 | **0.21** | 0.21 | `050000014215` | ✅ MATCH |
| 13 | `SEWEODMZ` | Optical Density |  | 3.00 - 3.50 | **3.14** | 3.14 | `050000014215` | ✅ MATCH |

### 5. Skenario L-QM05 & L-QM06 — DO `0085006242` (SRVC2I)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000104 (PT WINGS SURYA) | **SO:** 0000007205
**Karakteristik Alur:** Base film: Urutan inspeksi vs Change Grade (311/309)

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PVC2TH00` | Thickness | ASTM D 374 | 24.25 - 25.75 | **25.07** | 25.07 | `040000020671` | ✅ MATCH |
| 2 | `PVC2TSMD` | Tensile Strength MD | ASTM D 882 | 5.53 - 6.11 | **6.48** | 6.48 | `040000020671` | ✅ MATCH |
| 3 | `PVC2TSTD` | Tensile Strength TD | ASTM D 882 | 3.78 - 4.18 | **2.73** | 2.73 | `040000020671` | ✅ MATCH |
| 4 | `PVC2ELMD` | Elongation MD | ASTM D 882 | 617 - 681 | **389** | 389 | `040000020671` | ✅ MATCH |
| 5 | `PVC2ELTD` | Elongation TD | ASTM D 882 | 725 - 801 | **640** | 640 | `040000020671` | ✅ MATCH |
| 6 | `PVC2SHMD` | Shrinkage MD | ASTM D 1204 | -1.00 - 0.00 | **-0.32** | -0.32 | `040000020671` | ✅ MATCH |
| 7 | `PVC2SHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 2.00 | **1.39** | 1.39 | `040000020671` | ✅ MATCH |
| 8 | `SVC2HZ00` | Haze | ASTM D 1003 | 5.50 - 6.50 | **5.85** | 5.85 | `050000014216` | ✅ MATCH |
| 9 | `PVC2G400` | Gloss 45Â° | ASTM D 2457 | 70 - 90 | **79** | 79 | `040000020671` | ✅ MATCH |
| 10 | `SVC2STNS` | Surface Tension Non Seal Side | ASTM D 2578 | 36 - 40 | **39** | 39 | `050000014216` | ✅ MATCH |
| 11 | `SVC2SSSS` | Seal Strength Sealable Side ( 115 ÂÂ°C ) | TRIAS METHOD | 1900 - 2300 | **2185** | 2185 | `050000014216` | ✅ MATCH |
| 12 | `SVC2FDSS` | COF Sealable Side Dyn | ASTM D 1894 | 0.050 - 0.150 | **0.136** | 0.136 | `050000014216` | ✅ MATCH |

### 6. Skenario L-QM07 & L-QM08 — DO `0085006243` (SREASI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000105 (PT DANONE INDONESIA) | **SO:** 0000007206
**Karakteristik Alur:** Converting: Urutan inspeksi vs Change Grade

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAH8TH00` | Thickness | ASTM D 374 | 48.50 - 51.50 | **50.09** | 50.09 | `040000020683` | ✅ MATCH |
| 2 | `PAH8TSMD` | Tensile Strength MD | ASTM D 882 | 12.00 - 18.00 | **3.27** | 3.27 | `040000020683` | ✅ MATCH |
| 3 | `PAH8TSTD` | Tensile Strength TD | ASTM D 882 | 25.00 - 32.00 | **0.36** | 0.36 | `040000020683` | ✅ MATCH |
| 4 | `PAH8ELMD` | Elongation MD | ASTM D 882 | 150 - 220 | **1** | 1 | `040000020683` | ✅ MATCH |
| 5 | `PAH8ELTD` | Elongation TD | ASTM D 882 | 50 - 80 | **92** | 92 | `040000020683` | ✅ MATCH |
| 6 | `PAH8SHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **0.58** | 0.58 | `040000020683` | ✅ MATCH |
| 7 | `PAH8SHTD` | Shrinkage TD | ASTM D1204 | 0.50 - 1.50 | **0.59** | 0.59 | `040000020683` | ✅ MATCH |
| 8 | `SEASSTUZ` | Surface Tension Unmetz Side | ASTM D 2578 | 38 - 44 | **38** | 38 | `050000014211` | ✅ MATCH |
| 9 | `PEASFDUZ` | COF Unmetz Side Dyn | ASTM 1894 | 0.400 - 0.700 | **0.000** | 0.000 | `040000020763` | ✅ MATCH |
| 10 | `SEASODMZ` | Optical Density |  | 2.20 - 2.70 | **2.65** | 2.65 | `050000014211` | ✅ MATCH |

### 7. Skenario L-QM09 — DO `0085006244` (SRAABI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000106 (PT ARNOTTS INDONESIA) | **SO:** 0000007207
**Karakteristik Alur:** Base film yang mengalami proses Secondary Slitting

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAABTH00` | Thickness | ASTM D 374 | 19.40 - 20.60 | **19.58** | 19.58 | `040000020754` | ✅ MATCH |
| 2 | `PAABTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **12.92** | 12.92 | `040000020754` | ✅ MATCH |
| 3 | `PAABTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 35.00 | **27.71** | 27.71 | `040000020754` | ✅ MATCH |
| 4 | `PAABELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **151** | 151 | `040000020754` | ✅ MATCH |
| 5 | `PAABELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **46** | 46 | `040000020754` | ✅ MATCH |
| 6 | `PAABSHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **4.33** | 4.33 | `040000020754` | ✅ MATCH |
| 7 | `PAABSHTD` | Shrinkage TD | ASTM D1204 | 0.00 - 3.00 | **2.05** | 2.05 | `040000020754` | ✅ MATCH |
| 8 | `PAABHZ00` | Haze | ASTM D1003 | 1.00 - 2.00 | **1.75** | 1.75 | `040000020754` | ✅ MATCH |
| 9 | `PAABG400` | Gloss 45Â° | ASTM D2457 | 90 - 100 | **97** | 97 | `040000020754` | ✅ MATCH |
| 10 | `SAABSTTR` | Surface Tension Treated Side | ASTM D 2578 | 38 - 42 | **37** | 37 | `050000014222` | ✅ MATCH |
| 11 | `PAABFDNT` | COF Untreated Side Dyn | ASTM D1894 | 0.300 - 0.500 | **0.265** | 0.265 | `040000020754` | ✅ MATCH |

### 8. Skenario L-QM10 — DO `0085006245` (SRGJBI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000107 (PT SANBE FARMA) | **SO:** 0000007208
**Karakteristik Alur:** Converting yang mengalami proses Secondary Slitting

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAH8TH00` | Thickness | ASTM D 374 | 48.50 - 51.50 | **50.09** | 50.09 | `040000020687` | ✅ MATCH |
| 2 | `PAH8TSMD` | Tensile Strength MD | ASTM D 882 | 12.00 - 18.00 | **3.27** | 3.27 | `040000020687` | ✅ MATCH |
| 3 | `PAH8TSTD` | Tensile Strength TD | ASTM D 882 | 25.00 - 32.00 | **0.36** | 0.36 | `040000020687` | ✅ MATCH |
| 4 | `PAH8ELMD` | Elongation MD | ASTM D 882 | 150 - 220 | **1** | 1 | `040000020687` | ✅ MATCH |
| 5 | `PAH8ELTD` | Elongation TD | ASTM D 882 | 50 - 80 | **92** | 92 | `040000020687` | ✅ MATCH |
| 6 | `PAH8SHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **0.58** | 0.58 | `040000020687` | ✅ MATCH |
| 7 | `PAH8SHTD` | Shrinkage TD | ASTM D1204 | 0.50 - 1.50 | **0.59** | 0.59 | `040000020687` | ✅ MATCH |
| 8 | `PGJBHZ00` | Haze | ASTM D 1003 | 1.80 - 3.00 | **2.04** | 2.04 | `040000020773` | ✅ MATCH |
| 9 | `SGJBSTCD` | Surface Tension Coated Side | ASTM D 2578 | 40 - 44 | **45** | 45 | `050000014224` | ✅ MATCH |
| 10 | `PGJBFDCD` | COF Coated Side Dyn | ASTM D 1894 | 0.300 - 0.600 | **0.600** | 0.600 | `040000020773` | ✅ MATCH |

### 9. Skenario L-QM11 — DO `0085006270` (SRAABI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000026 (PT ATLANTIC BIRURAYA) | **SO:** 0000007210
**Karakteristik Alur:** Join 2 JR (1 DO 1 JR) + Mapping Khusus PT Atlantic Biruraya (1141000026)

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAABTH00` | Thickness | ASTM D 374 | 19.40 - 20.60 | **22.40** | 22.40 | `040000020867` | ✅ MATCH |
| 2 | `PAABTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **14.00** | 14.00 | `040000020867` | ✅ MATCH |
| 3 | `PAABTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 35.00 | **26.90** | 26.90 | `040000020867` | ✅ MATCH |
| 4 | `PAABELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **180** | 180 | `040000020867` | ✅ MATCH |
| 5 | `PAABELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **65** | 65 | `040000020867` | ✅ MATCH |
| 6 | `PAABSHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **4.65** | 4.65 | `040000020867` | ✅ MATCH |
| 7 | `PAABSHTD` | Shrinkage TD | ASTM D1204 | 0.00 - 3.00 | **1.78** | 1.78 | `040000020867` | ✅ MATCH |
| 8 | `PAABHZ00` | Haze | ASTM D1003 | 1.00 - 2.00 | **1.00** | 1.00 | `040000020867` | ✅ MATCH |
| 9 | `PAABG400` | Gloss 45Â° | ASTM D2457 | 90 - 100 | **89** | 89 | `040000020867` | ✅ MATCH |
| 10 | `SAABSTTR` | Surface Tension Treated Side | ASTM D 2578 | 38 - 42 | **40** | 40 | `050000014263` | ✅ MATCH |
| 11 | `PAABFDNT` | COF Untreated Side Dyn | ASTM D1894 | 0.300 - 0.500 | **0.450** | 0.450 | `040000020867` | ✅ MATCH |
| 12 | `PAABFDTR` | COF Treated Side Dyn | ASTM D 374 | 0.300 - 0.600 | **0.562** | 0.562 | `040000020867` | ✅ MATCH |

### 10. Skenario L-QM12 — DO `0085006271` (SRAABI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000026 (PT ATLANTIC BIRURAYA) | **SO:** 0000007211
**Karakteristik Alur:** Join 2 JR (1 DO 2 JR) + Pencarian sample inspeksi urutan ke-20 ke atas

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAABTH00` | Thickness | ASTM D 374 | 19.40 - 20.60 | **21.25** | 21.25 | `040000020892` | ✅ MATCH |
| 2 | `PAABTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **15.05** | 15.05 | `040000020892` | ✅ MATCH |
| 3 | `PAABTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 35.00 | **27.45** | 27.45 | `040000020892` | ✅ MATCH |
| 4 | `PAABELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **183** | 183 | `040000020892` | ✅ MATCH |
| 5 | `PAABELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **60** | 60 | `040000020892` | ✅ MATCH |
| 6 | `PAABSHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **4.05** | 4.05 | `040000020892` | ✅ MATCH |
| 7 | `PAABSHTD` | Shrinkage TD | ASTM D1204 | 0.00 - 3.00 | **1.67** | 1.67 | `040000020892` | ✅ MATCH |
| 8 | `PAABHZ00` | Haze | ASTM D1003 | 1.00 - 2.00 | **1.23** | 1.23 | `040000020892` | ✅ MATCH |
| 9 | `PAABG400` | Gloss 45Â° | ASTM D2457 | 90 - 100 | **93** | 93 | `040000020892` | ✅ MATCH |
| 10 | `SAABSTTR` | Surface Tension Treated Side | ASTM D 2578 | 38 - 42 | **41** | 41 | `050000014265` | ✅ MATCH |
| 11 | `PAABFDNT` | COF Untreated Side Dyn | ASTM D1894 | 0.300 - 0.500 | **0.399** | 0.399 | `040000020892` | ✅ MATCH |

### 11. Skenario L-QM13 — DO `0085006272` (SREASI)
**Kelompok:** Kelompok 1: Baseline & Warisan | **Customer:** 1141000108 (PT NESTLE INDONESIA) | **SO:** 0000007212
**Karakteristik Alur:** 1 DO memuat roll dari 3 JR berbeda dari mesin/line berbeda

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAH8TH00` | Thickness | ASTM D 374 | 48.50 - 51.50 | **50.14** | 50.14 | `040000020690` | ✅ MATCH |
| 2 | `PAH8TSMD` | Tensile Strength MD | ASTM D 882 | 12.00 - 18.00 | **13.27** | 13.27 | `040000020690` | ✅ MATCH |
| 3 | `PAH8TSTD` | Tensile Strength TD | ASTM D 882 | 25.00 - 32.00 | **27.36** | 27.36 | `040000020690` | ✅ MATCH |
| 4 | `PAH8ELMD` | Elongation MD | ASTM D 882 | 150 - 220 | **178** | 178 | `040000020690` | ✅ MATCH |
| 5 | `PAH8ELTD` | Elongation TD | ASTM D 882 | 50 - 80 | **72** | 72 | `040000020690` | ✅ MATCH |
| 6 | `PAH8SHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **4.90** | 4.90 | `040000020690` | ✅ MATCH |
| 7 | `PAH8SHTD` | Shrinkage TD | ASTM D1204 | 0.50 - 1.50 | **1.37** | 1.37 | `040000020690` | ✅ MATCH |
| 8 | `SEASSTUZ` | Surface Tension Unmetz Side | ASTM D 2578 | 38 - 44 | **42** | 42 | `050000014269` | ✅ MATCH |
| 9 | `PEASFDUZ` | COF Unmetz Side Dyn | ASTM 1894 | 0.400 - 0.700 | **0.543** | 0.543 | `040000020894` | ✅ MATCH |
| 10 | `SEASODMZ` | Optical Density |  | 2.20 - 2.70 | **2.56** | 2.56 | `050000014269` | ✅ MATCH |

### 12. Skenario ML-QM01 — DO `0085006276` (SRACBI)
**Kelompok:** Kelompok 2: Multi-Level Genealogi | **Customer:** 1142000001 (EXPORT NOMURA OVERSEAS) | **SO:** 0000007213
**Karakteristik Alur:** Single Alias (Customer Export), penarikan inspeksi terdekat

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PACBTH00` | Thickness | ASTM D 374 | 17.46 - 18.54 | **17.95** | 17.95 | `040000021076` | ✅ MATCH |
| 2 | `PACBTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **14.51** | 14.51 | `040000021076` | ✅ MATCH |
| 3 | `PACBTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 35.00 | **28.15** | 28.15 | `040000021076` | ✅ MATCH |
| 4 | `PACBELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **160** | 160 | `040000021076` | ✅ MATCH |
| 5 | `PACBELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **49** | 49 | `040000021076` | ✅ MATCH |
| 6 | `SACBSHMD` | Shrinkage MD | ASTM D 1204 | 6.00 - 8.00 | **4.84** | 4.84 | `050000014308` | ✅ MATCH |
| 7 | `SACBSHTD` | Shrinkage TD | ASTM D 1204 | 7.00 - 9.00 | **7.01** | 7.01 | `050000014308` | ✅ MATCH |
| 8 | `SACBHZ00` | Haze | ASTM D 1003 | 1.50 - 2.50 | **2.21** | 2.21 | `050000014308` | ✅ MATCH |
| 9 | `SACBG400` | Gloss 45Â° | ASTM D 2457 | 85 - 100 | **88** | 88 | `050000014308` | ✅ MATCH |
| 10 | `SACBSIIN` | SIT Inside | Trias Method | 102 - 108 | **111** | 111 | `050000014308` | ✅ MATCH |
| 11 | `SACBSIOT` | SIT Outside | Trias Method | 102 - 108 | **110** | 110 | `050000014308` | ✅ MATCH |
| 12 | `PACBSSIN` | Seal Strength at SIT ( Inside ) | Trias Method | 200 - 400 | **294** | 294 | `040000021076` | ✅ MATCH |
| 13 | `PACBSSOT` | Seal Strength at SIT ( Outside ) | Trias Method | 200 - 400 | **267** | 267 | `040000021076` | ✅ MATCH |
| 14 | `SACBFDIN` | COF Inside Dyn | ASTM D 1894 | 0.200 - 0.400 | **0.265** | 0.265 | `050000014308` | ✅ MATCH |

### 13. Skenario ML-QM02 — DO `0085006277` (SRACBI)
**Kelompok:** Kelompok 2: Multi-Level Genealogi | **Customer:** 1142000001 (EXPORT NOMURA OVERSEAS) | **SO:** 0000007214
**Karakteristik Alur:** Multi-Alias dalam 1 DO, evaluasi kasus negatif tanpa lot

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PACBTH00` | Thickness | ASTM D 374 | 17.46 - 18.54 | **17.87** | 17.87 | `040000021077` | ✅ MATCH |
| 2 | `PACBTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **15.81** | 15.81 | `040000021077` | ✅ MATCH |
| 3 | `PACBTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 35.00 | **25.75** | 25.75 | `040000021077` | ✅ MATCH |
| 4 | `PACBELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **185** | 185 | `040000021077` | ✅ MATCH |
| 5 | `PACBELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **56** | 56 | `040000021077` | ✅ MATCH |
| 6 | `SACBSHMD` | Shrinkage MD | ASTM D 1204 | 6.00 - 8.00 | **6.93** | 6.93 | `050000014311` | ✅ MATCH |
| 7 | `SACBSHTD` | Shrinkage TD | ASTM D 1204 | 7.00 - 9.00 | **8.83** | 8.83 | `050000014311` | ✅ MATCH |
| 8 | `SACBHZ00` | Haze | ASTM D 1003 | 1.50 - 2.50 | **1.72** | 1.72 | `050000014311` | ✅ MATCH |
| 9 | `SACBG400` | Gloss 45Â° | ASTM D 2457 | 85 - 100 | **91** | 91 | `050000014311` | ✅ MATCH |
| 10 | `SACBSIIN` | SIT Inside | Trias Method | 102 - 108 | **108** | 108 | `050000014311` | ✅ MATCH |
| 11 | `SACBSIOT` | SIT Outside | Trias Method | 102 - 108 | **107** | 107 | `050000014311` | ✅ MATCH |
| 12 | `PACBSSIN` | Seal Strength at SIT ( Inside ) | Trias Method | 200 - 400 | **294** | 294 | `040000021077` | ✅ MATCH |
| 13 | `PACBSSOT` | Seal Strength at SIT ( Outside ) | Trias Method | 200 - 400 | **267** | 267 | `040000021077` | ✅ MATCH |
| 14 | `SACBFDIN` | COF Inside Dyn | ASTM D 1894 | 0.200 - 0.400 | **0.275** | 0.275 | `050000014311` | ✅ MATCH |

### 14. Skenario ML-QM03 — DO `0085006278` (SRGLBI)
**Kelompok:** Kelompok 2: Multi-Level Genealogi | **Customer:** 1141000109 (PT SUPERNOVA FLEXIBLE) | **SO:** 0000007215
**Karakteristik Alur:** Produksi 4 Tahap: Basefilm -> Coating -> Metallizing -> Coating

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAH8TSMD` | Tensile Strength MD | ASTM D 882 | 12.00 - 18.00 | **0.00** | 0.00 | `040000021013` | ✅ MATCH |
| 2 | `PAH8TSTD` | Tensile Strength TD | ASTM D 882 | 25.00 - 32.00 | **0.00** | 0.00 | `040000021013` | ✅ MATCH |
| 3 | `PAH8ELMD` | Elongation MD | ASTM D 882 | 150 - 220 | **0** | 0 | `040000021013` | ✅ MATCH |
| 4 | `PAH8ELTD` | Elongation TD | ASTM D 882 | 50 - 80 | **0** | 0 | `040000021013` | ✅ MATCH |
| 5 | `PGLASHMD` | Shrinkage MD | ASTM D 1204 | 3.00 - 5.00 | **2.62** | 2.62 | `040000021042` | ✅ MATCH |
| 6 | `PGLASHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 2.00 | **0.34** | 0.34 | `040000021042` | ✅ MATCH |
| 7 | `SGLASTCD` | Surface Tension Coated Side | ASTM D 2578 | 40 - 44 | **42** | 42 | `050000014297` | ✅ MATCH |
| 8 | `SGLASTMZ` | Surface Tension Metz Side | ASTM D 2578 | 38 - 58 | **52** | 52 | `050000014297` | ✅ MATCH |
| 9 | `PGLAG6CD` | Gloss 60ÃÂ° ( Coated Side ) | ASTM D 2457 | 600 - 660 | **636** | 636 | `040000021042` | ✅ MATCH |
| 10 | `PGLBOD00` | Optical Density |  | 2.20 - 2.80 | **2.38** | 2.38 | `040000021052` | ✅ MATCH |

### 15. Skenario ML-QM04 — DO `0085006279` (SREC7I)
**Kelompok:** Kelompok 2: Multi-Level Genealogi | **Customer:** 1141000110 (PT CHAMPION PACIFIC) | **SO:** 0000007216
**Karakteristik Alur:** Outsource Base Film Subcontract (SR*X tanpa JR BF di SAP)

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `SVLCTSMD` | Tensile Strength MD | ASTM D 882 | 12.00 - 0.00 | **16.15** | 16.15 | `050000014331` | ✅ MATCH |
| 2 | `SVLCTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 0.00 | **24.17** | 24.17 | `050000014331` | ✅ MATCH |
| 3 | `SVLCELMD` | Elongation MD | ASTM D 882 | 0 - 300 | **237** | 237 | `050000014331` | ✅ MATCH |
| 4 | `SVLCELTD` | Elongation TD | ASTM D 882 | 0 - 80 | **73** | 73 | `050000014331` | ✅ MATCH |
| 5 | `SVLCSHMD` | Shrinkage MD | ASTM D 1204 | 0.00 - 5.00 | **0.00** | 0.00 | `050000014331` | ✅ MATCH |
| 6 | `SVLCSHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 4.00 | **0.00** | 0.00 | `050000014331` | ✅ MATCH |
| 7 | `SEC7STCD` | Surface Tension Corona side | ASTM D 2578 | 38 - 42 | **39** | 39 | `050000014339` | ✅ MATCH |
| 8 | `PEC7FDCD` | COF Corona Side Dyn | ASTM D 1894 | 0.300 - 0.800 | **0.540** | 0.540 | `040000021127` | ✅ MATCH |
| 9 | `SEC7MVTR` | MVTR | ASTM F 1249 (38ÂÂ°C, 100 %RH) | 0.05 - 0.15 | **0.07** | 0.07 | `050000014339` | ✅ MATCH |
| 10 | `SEC7O2TR` | O2TR | ASTM F 1927 (23Â°C, 0 %RH) | 0.05 - 0.15 | **0.07** | 0.07 | `050000014339` | ✅ MATCH |

### 16. Skenario AL-STRUKTUR — DO `0085006280` (SRABDI)
**Kelompok:** Kelompok 3: Grouping Alias | **Customer:** 1141000111 (PT DAINIPPON PRINTING) | **SO:** 0000007217
**Karakteristik Alur:** Struktur alias 2 material berbeda, pengujian nilai default 0

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAACTH00` | Thickness | ASTM D 374 | 19.40 - 20.60 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 2 | `PAACTSMD` | Tensile Strength MD | ASTM D 882 | 12.00 - 18.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 3 | `PAACTSTD` | Tensile Strength TD | ASTM D 882 (CUST) | 28.00 - 35.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 4 | `PAACELMD` | Elongation MD | ASTM D 882 | 150 - 220 | **0** | 0 | `000000000000` | ✅ MATCH |
| 5 | `PAACELTD` | Elongation TD | ASTM D 882 | 50 - 80 | **0** | 0 | `000000000000` | ✅ MATCH |
| 6 | `PAACSHMD` | Shrinkage MD | ASTM D 1204 | 3.00 - 5.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 7 | `PAACSHTD` | Shrinkage TD | ASTM D 1204 | 0.50 - 1.50 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 8 | `PAACHZ00` | Haze | ASTM D 1003 | 1.00 - 1.50 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 9 | `PAACG400` | Gloss 45 | ASTM D 2457 | 90 - 99 | **0** | 0 | `000000000000` | ✅ MATCH |

### 17. Skenario AL-MIXED — DO `0085006281` (SRAABI)
**Kelompok:** Kelompok 3: Grouping Alias | **Customer:** 1141000112 (PT TOYO INK INDONESIA) | **SO:** 0000007218
**Karakteristik Alur:** Campuran item alias dan non-alias (mekanisme fallback as-is)

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAABTH00` | Thickness | ASTM D 374 | 19.40 - 20.60 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 2 | `PAABTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 3 | `PAABTSTD` | Tensile Strength TD | ASTM D 882 | 22.00 - 35.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 4 | `PAABELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **0** | 0 | `000000000000` | ✅ MATCH |
| 5 | `PAABELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **0** | 0 | `000000000000` | ✅ MATCH |
| 6 | `PAABSHMD` | Shrinkage MD | ASTM D1204 | 3.00 - 5.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 7 | `PAABSHTD` | Shrinkage TD | ASTM D1204 | 0.00 - 3.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 8 | `PAABHZ00` | Haze | ASTM D1003 | 1.00 - 2.00 | **0.00** | 0.00 | `000000000000` | ✅ MATCH |
| 9 | `PAABG400` | Gloss 45Â° | ASTM D2457 | 90 - 100 | **0** | 0 | `000000000000` | ✅ MATCH |
| 10 | `SAABSTTR` | Surface Tension Treated Side | ASTM D 2578 | 38 - 42 | **0** | 0 | `000000000000` | ✅ MATCH |
| 11 | `PAABFDNT` | COF Untreated Side Dyn | ASTM D1894 | 0.300 - 0.500 | **0.000** | 0.000 | `000000000000` | ✅ MATCH |

### 18. Skenario AL-VALUE1 — DO `0085006282` (SRAABI)
**Kelompok:** Kelompok 3: Grouping Alias | **Customer:** 1141000113 (PT AMCOR FLEXIBLES) | **SO:** 0000007219
**Karakteristik Alur:** Alias 1 material dengan 3 Roll / 3 JR, validasi rata-rata manual QAMR

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAACTH00` | Thickness | ASTM D 374 | 19.40 - 20.60 | **20.05** | 20.05 | `040000006674` | ✅ MATCH |
| 2 | `PAACTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **13.57** | 13.57 | `040000006674` | ✅ MATCH |
| 3 | `PAACTSTD` | Tensile Strength TD | ASTM D 882 (CUST) | 22.00 - 35.00 | **32.51** | 32.51 | `040000006674` | ✅ MATCH |
| 4 | `PAACELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **179** | 179 | `040000006674` | ✅ MATCH |
| 5 | `PAACELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **44** | 44 | `040000006674` | ✅ MATCH |
| 6 | `PAACSHMD` | Shrinkage MD | ASTM D 1204 | 3.00 - 5.00 | **3.85** | 3.85 | `040000006674` | ✅ MATCH |
| 7 | `PAACSHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 3.00 | **1.30** | 1.30 | `040000006674` | ✅ MATCH |
| 8 | `PAACHZ00` | Haze | ASTM D 1003 | 1.00 - 2.00 | **1.71** | 1.71 | `040000006674` | ✅ MATCH |
| 9 | `PAACG400` | Gloss 45 | ASTM D 2457 | 90 - 100 | **96** | 96 | `040000006674` | ✅ MATCH |

### 19. Skenario AL-VALUE2 — DO `0085006284` (SRAAAI)
**Kelompok:** Kelompok 3: Grouping Alias | **Customer:** 1141000114 (PT PRINTING INDONESIA) | **SO:** 0000007220
**Karakteristik Alur:** Alias 2 material berbeda dengan nilai riil inspeksi

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PAACTH00` | Thickness | ASTM D 374 | 17.46 - 18.54 | **19.01** | 19.01 | `040000007777` | ✅ MATCH |
| 2 | `PAACTSMD` | Tensile Strength MD | ASTM D 882 | 11.00 - 18.00 | **13.53** | 13.53 | `040000007777` | ✅ MATCH |
| 3 | `PAACTSTD` | Tensile Strength TD | ASTM D 882 (CUST) | 22.00 - 35.00 | **33.39** | 33.39 | `040000007777` | ✅ MATCH |
| 4 | `PAACELMD` | Elongation MD | ASTM D 882 | 120 - 240 | **179** | 179 | `040000007777` | ✅ MATCH |
| 5 | `PAACELTD` | Elongation TD | ASTM D 882 | 30 - 90 | **43** | 43 | `040000007777` | ✅ MATCH |
| 6 | `PAACSHMD` | Shrinkage MD | ASTM D 1204 | 3.00 - 5.00 | **3.76** | 3.76 | `040000007777` | ✅ MATCH |
| 7 | `PAACSHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 3.00 | **2.62** | 2.62 | `040000007777` | ✅ MATCH |
| 8 | `PAACHZ00` | Haze | ASTM D 1003 | 1.00 - 2.00 | **1.37** | 1.37 | `040000007777` | ✅ MATCH |
| 9 | `PAACG400` | Gloss 45 | ASTM D 2457 | 90 - 100 | **97** | 97 | `040000007777` | ✅ MATCH |

### 20. Skenario TTA-OUTSOURCE — DO `0085006285` (SRCBUX)
**Kelompok:** Kelompok 4: Outsource TTA | **Customer:** 1141000514 (PT TRIAS SENTOSA) | **SO:** 0000007209
**Karakteristik Alur:** Outsource TTA (Batch 9*, Prodline Z3), penelusuran ke Lot JR TTA 040000015885

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PCADTH00` | Thickness | ASTM D 374 | 11.64 - 12.35 | **12.00** | 12.00 | `040000015885` | ✅ MATCH |
| 2 | `PCADTSMD` | Tensile Strength MD | ASTM D 882 | 16.00 - 26.00 | **23.00** | 23.00 | `040000015885` | ✅ MATCH |
| 3 | `PCADTSTD` | Tensile Strength TD | ASTM D 882 | 18.00 - 30.00 | **27.00** | 27.00 | `040000015885` | ✅ MATCH |
| 4 | `PCADELMD` | Elongation MD | ASTM D 882 | 70 - 150 | **133** | 133 | `040000015885` | ✅ MATCH |
| 5 | `PCADELTD` | Elongation TD | ASTM D 882 | 60 - 120 | **123** | 123 | `040000015885` | ✅ MATCH |
| 6 | `PCADSHMD` | Shrinkage MD | ASTM D 1204 | 1.00 - 3.00 | **2.00** | 2.00 | `040000015885` | ✅ MATCH |
| 7 | `PCADSHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 0.50 | **0.30** | 0.30 | `040000015885` | ✅ MATCH |
| 8 | `PCADHZ00` | Haze | ASTM D 1003 | 1.50 - 2.50 | **2.00** | 2.00 | `040000015885` | ✅ MATCH |
| 9 | `PCADG400` | Gloss 45 | ASTM D 2457 | 120 - 140 | **128** | 128 | `040000015885` | ✅ MATCH |
| 10 | `PCADSTNT` | Surface Tension Untreated Side | ASTM D 2578 | 44 - 50 | **0** | 0 | `000000000000` | ✅ MATCH |

### 21. Skenario TTA-CONVERTING — DO `0085006286` (SREYAI)
**Kelompok:** Kelompok 4: Outsource TTA | **Customer:** 1141000514 (PT TRIAS SENTOSA) | **SO:** 0000007209
**Karakteristik Alur:** Multi-tier Converting: Roll TTA -> JR Conv -> SR Conv -> DO

| No | MIC | Deskripsi Karakteristik | Metode Uji | Spec Limit | Nilai Live ZQM002 | Nilai Baseline | Lot Sumber | Status Match |
|:--:|:---|:---|:---|:---:|:---:|:---:|:---:|:---:|
| 1 | `PEYATH00` | Thickness | ASTM D 374 | 11.64 - 12.35 | **12.00** | 12.00 | `040000015885` | ✅ MATCH |
| 2 | `PEYATSMD` | Tensile Strength MD | ASTM D 882 | 16.00 - 26.00 | **23.00** | 23.00 | `040000015885` | ✅ MATCH |
| 3 | `PEYATSTD` | Tensile Strength TD | ASTM D 882 | 18.00 - 30.00 | **27.00** | 27.00 | `040000015885` | ✅ MATCH |
| 4 | `PEYAELMD` | Elongation MD | ASTM D 882 | 70 - 150 | **133** | 133 | `040000015885` | ✅ MATCH |
| 5 | `PEYAELTD` | Elongation TD | ASTM D 882 | 60 - 120 | **123** | 123 | `040000015885` | ✅ MATCH |
| 6 | `PEYASHMD` | Shrinkage MD | ASTM D 1204 | 1.00 - 3.00 | **2.00** | 2.00 | `040000015885` | ✅ MATCH |
| 7 | `PEYASHTD` | Shrinkage TD | ASTM D 1204 | 0.00 - 0.50 | **0.30** | 0.30 | `040000015885` | ✅ MATCH |
| 8 | `PEYAHZ00` | Haze | ASTM D 1003 | 1.50 - 2.50 | **2.00** | 2.00 | `040000015885` | ✅ MATCH |
| 9 | `PEYAG400` | Gloss 45 | ASTM D 2457 | 120 - 140 | **128** | 128 | `040000015885` | ✅ MATCH |
| 10 | `PEYASTNT` | Surface Tension Untreated Side | ASTM D 2578 | 0 - 0 | **0** | 0 | `000000000000` | ✅ MATCH |