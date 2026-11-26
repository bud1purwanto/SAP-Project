# Regresi aturan JR 20 sequence sebelumnya — DO yang berubah

Tanggal: 26 Nov 2026. Sistem: Development AIX client 130.
Before = program DEV sebelum deploy (`outputs/MT_20261126_jrprev_orig.txt`). After = program DEV setelah deploy (`outputs/MT_20261126_dev_after_jrprev.txt`).
21 DO diuji: 19 SAMA, 2 BERUBAH (di bawah). Aturan: [RANCANGAN_JR_20_SEQ_SEBELUMNYA_20261126.md](RANCANGAN_JR_20_SEQ_SEBELUMNYA_20261126.md). Keputusan QA (Aisyah): semua JR dalam 1 DO tetap mencari (opsi A).

| No | Skenario | DO | Material | Status | MIC berubah |
|:-:|:--|:--|:--|:--|:-:|
| 1 | L-QM11 (join 2 input JR, mapping khusus customer) | `0085006270` | SRAABI | BERUBAH | 11 dari 12 |
| 2 | ML-QM04 (outsource base film) | `0085006279` | SREC7I | BERUBAH | 1 dari 10 |

---

## 1. L-QM11 — DO `0085006270` (SRAABI)

### 1.1 Roll dan JR

| Roll SR | JR | Lot JR sendiri | Before: sumber nilai | After: sumber nilai |
|:--|:--|:--|:--|:--|
| `0000406016`–`021` (6 roll) | `4 AAB 086 003` (batch `0000405990`) | `040000020798`, tanpa hasil | Kosong: 002, 001 tanpa hasil; tidak boleh ke Juli. Tidak ikut rata-rata | `4 AAB 076 009` (Juli, lot `040000020752`) |
| `0000406022`–`027` (6 roll) | `4 AAB 086 022` (batch `0000406009`) | `040000020867`, tanpa hasil | `4 AAB 086 006` (lot `040000020851`) | Sama: `4 AAB 086 006` (lot `040000020851`) |

Nilai COA = rata-rata nilai per JR yang terisi. Before = 1 JR (022). After = 2 JR (022 dan 003).

### 1.2 Matrix nilai per MIC

| SEQ | MIC | Deskripsi | Limit | JR 022 (dari 006) | JR 003 (dari Juli 076 009) | **Before** | **After** | Status |
|:-:|:--|:--|:-:|--:|--:|--:|--:|:--|
| 001 | PAABTH00 | Thickness | 19.40 - 20.60 | 22.40 | 19.58 | 22.40 | **20.99** | BERUBAH (tetap di luar limit) |
| 002 | PAABTSMD | Tensile Strength MD | 11.00 - 18.00 | 14.00 | 12.92 | 14.00 | **13.46** | BERUBAH |
| 003 | PAABTSTD | Tensile Strength TD | 22.00 - 35.00 | 26.90 | 27.71 | 26.90 | **27.31** | BERUBAH |
| 004 | PAABELMD | Elongation MD | 120 - 240 | 180 | 151 | 180 | **166** | BERUBAH |
| 005 | PAABELTD | Elongation TD | 30 - 90 | 65 | 46 | 65 | **56** | BERUBAH |
| 006 | PAABSHMD | Shrinkage MD | 3.00 - 5.00 | 4.65 | 4.33 | 4.65 | **4.49** | BERUBAH |
| 007 | PAABSHTD | Shrinkage TD | 0.00 - 3.00 | 1.78 | 2.05 | 1.78 | **1.92** | BERUBAH |
| 008 | PAABHZ00 | Haze | 1.00 - 2.00 | 1.00 | 1.75 | 1.00 | **1.38** | BERUBAH |
| 009 | PAABG400 | Gloss 45° | 90 - 100 | 89 | 97 | 89 | **93** | BERUBAH (before di luar limit, after masuk) |
| 010 | SAABSTTR | Surface Tension Treated Side | 38 - 42 | – | – | 40 | 40 | SAMA (lot SR `050000014263`) |
| 011 | PAABFDNT | COF Untreated Side Dyn | 0.300 - 0.500 | 0.450 | 0.265 | 0.450 | **0.358** | BERUBAH |
| 012 | PAABFDTR | COF Treated Side Dyn | 0.300 - 0.600 | 0.562 | 0.371 | 0.562 | **0.467** | BERUBAH |

Lot yang tampil di print tetap `040000020867` (before dan after). Override ZLOG_COA: tidak ada di DO ini.

---

## 2. ML-QM04 — DO `0085006279` (SREC7I)

### 2.1 Roll dan JR (MIC JR `PEC7FDCD`)

| Roll SR | JR | Lot JR sendiri | Before: nilai COF | After: nilai COF |
|:--|:--|:--|--:|--:|
| `0000407199`, `200` | `V EC7 116 001` (Nov) | `040000021124`, tanpa hasil | Kosong | **0.400** dari `V EC7 106 001` (Okt, lot `040000021117`) |
| `0000407201`, `202` | `V EC7 116 002` (Nov) | `040000021126`, tanpa hasil | Kosong | **0.400** dari `V EC7 106 001` (Okt, lot `040000021117`) |
| `0000407207`, `208` | `R EC7 106 001` (Okt) | `040000021118`, tanpa hasil | Kosong | Kosong (September tidak ada roll `R EC7 096`) |
| `0000407209`, `210` | `R EC7 116 001` (Nov) | `040000021125`, ada hasil | 0.540 | 0.540 |
| `0000407211`, `212` | `R EC7 116 002` (Nov) | `040000021127`, tanpa hasil | 0.540 (dari 001) | 0.540 (dari 001) |
| **Nilai COA** | | | **0.540** (2 JR) | **0.470** (4 JR) |

### 2.2 Matrix nilai per MIC

| SEQ | MIC | Deskripsi | Limit | Lot | **Before** | **After** | Status |
|:-:|:--|:--|:-:|:--|--:|--:|:--|
| 001 | SVLCTSMD | Tensile Strength MD | 12.00 - 0.00 | `050000014331` | 16.15 | 16.15 | SAMA |
| 002 | SVLCTSTD | Tensile Strength TD | 22.00 - 0.00 | `050000014331` | 24.17 | 24.17 | SAMA |
| 003 | SVLCELMD | Elongation MD | 0 - 300 | `050000014331` | 237 | 237 | SAMA |
| 004 | SVLCELTD | Elongation TD | 0 - 80 | `050000014331` | 73 | 73 | SAMA |
| 005 | SVLCSHMD | Shrinkage MD | 0.00 - 5.00 | `050000014331` | 0.00 | 0.00 | SAMA |
| 006 | SVLCSHTD | Shrinkage TD | 0.00 - 4.00 | `050000014331` | 0.00 | 0.00 | SAMA |
| 007 | SEC7STCD | Surface Tension Corona side | 38 - 42 | `050000014339` | 39 | 39 | SAMA |
| 008 | PEC7FDCD | COF Corona Side Dyn | 0.300 - 0.800 | `040000021127` | 0.540 | **0.470** | BERUBAH |
| 009 | SEC7MVTR | MVTR | 0.05 - 0.15 | `050000014339` | 0.07 | 0.07 | SAMA |
| 010 | SEC7O2TR | O2TR | 0.05 - 0.15 | `050000014339` | 0.07 | 0.07 | SAMA |

---

## 3. DO yang SAMA (19)

| Skenario | DO |
|:--|:--|
| L-QM01, L-QM15 | `0085006234` |
| L-QM02 | `0085006235` |
| L-QM03 | `0085006240` |
| L-QM04 | `0085006241` |
| L-QM05, L-QM06 | `0085006242` |
| L-QM07, L-QM08 | `0085006243` |
| L-QM09 | `0085006244` |
| L-QM10 | `0085006245` |
| L-QM12 | `0085006271` |
| L-QM13 | `0085006272` |
| ML-QM01 | `0085006276` |
| ML-QM02 | `0085006277` |
| ML-QM03 | `0085006278` |
| AL-STRUKTUR | `0085006280` |
| AL-MIXED | `0085006281` |
| AL-VALUE1 | `0085006282` |
| AL-VALUE2 | `0085006284` |
| TTA-OUTSOURCE | `0085006285` |
| TTA-CONVERTING | `0085006286` |

ZQM002, EXEC, dan ZQM003 identik dengan before.
