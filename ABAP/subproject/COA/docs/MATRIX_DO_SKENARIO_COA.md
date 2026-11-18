# Matriks Skenario dan DO Uji COA (ZQMI_COA)

Update: 18 Nov 2026. Total **21 DO uji**. Sumber: `STANDAR_SKENARIO_TESTING_COA.md` §0.1.

## 1. Matriks skenario

| No | Kelompok | Skenario | No DO | Material | Yang diuji | Acuan hasil |
|:-:|:--|:--|:--|:--|:--|:--|
| 1 | Lama | L-QM01, L-QM15 | 0085006234 | SRCADI | Base film normal, 1 JR sama; plus edit value di print (ZLOG_COA) | Golden + data inspeksi |
| 2 | Lama | L-QM02 | 0085006235 | SRAABI | Base film normal, beda JR dalam 1 DO | Golden + data inspeksi |
| 3 | Lama | L-QM03 | 0085006240 | SRGIDI | Converting normal, 1 JR | Golden + data inspeksi |
| 4 | Lama | L-QM04 | 0085006241 | SREWEI | Converting, beda JR | Golden + data inspeksi |
| 5 | Lama | L-QM05, L-QM06 | 0085006242 | SRVC2I | Base film, urutan inspeksi dan change grade | Golden + data inspeksi |
| 6 | Lama | L-QM07, L-QM08 | 0085006243 | SREASI | Converting, urutan inspeksi dan change grade | Golden + data inspeksi |
| 7 | Lama | L-QM09 | 0085006244 | SRAABI | Base film di secondary slitting | Golden + data inspeksi |
| 8 | Lama | L-QM10 | 0085006245 | SRGJBI | Converting di secondary slitting | Golden + data inspeksi |
| 9 | Lama | L-QM11 | 0085006270 | SRAABI | Join 2 input JR, mapping khusus customer | 12 MIC cocok dengan ALV user |
| 10 | Lama | L-QM12 | 0085006271 | SRAABI | Join 2 JR dalam 1 DO, inspeksi seq >= 20 | 11 MIC cocok |
| 11 | Lama | L-QM13 | 0085006272 | SREASI | 1 DO 3 JR beda line | 10 MIC cocok |
| 12 | Multi-level | ML-QM01 | 0085006276 | SRACBI | Alias, 1 DO 1 alias | Golden file |
| 13 | Multi-level | ML-QM02 | 0085006277 | SRACBI | 1 DO lebih dari 1 alias | Golden file |
| 14 | Multi-level | ML-QM03 | 0085006278 | SRGLBI | Produksi 4 tahap (BF, Coat, Metz, Coat) | Golden + BAGIAN 1 |
| 15 | Multi-level | ML-QM04 | 0085006279 | SREC7I | Outsource base film (tanpa JR BF di SAP) | Baseline program DEV 11 Nov |
| 16 | Alias | AL-STRUKTUR | 0085006280 | SRAABI, SRABDI | Struktur alias 2 material, value 0 | §0.6.2 |
| 17 | Alias | AL-MIXED | 0085006281 | SRAABI | Alias dan tanpa alias dalam 1 grup (fallback) | Sama dengan sebelum alias |
| 18 | Alias | AL-VALUE1 | 0085006282 | SRAABI | Alias 1 material, 3 roll / 3 JR | 9/9 = rata-rata manual QAMR |
| 19 | Alias | AL-VALUE2 | 0085006284 | SRAABI, SRAAAI | Alias 2 material | 9/9 = rata-rata manual QAMR |
| 20 | TTA | TTA-OUTSOURCE | 0085006285 | SRCBUX | SRCBUX (batch 9*, Z3): nilai dari lot JR TTA | 10/10 = lot JR TTA |
| 21 | TTA | TTA-CONVERTING (baru) | 0085006286 | SREYAI | SRCBUX TTA, JR converting, SR converting, DO | 10/10 = lot JR TTA 040000015885 |

Catatan:
- L-QM14 (banyak DO sekali cetak) tidak punya DO sendiri. Diuji dengan menjalankan semua DO di atas sekaligus, dan lewat ALV multi-DO.
- DO 0085006283 sudah dihapus, tidak dipakai.
- L-QM15 (edit value di Print Certificate) diuji manual di layar.

## 2. Status per lingkungan

| Lingkungan | Versi program | Status |
|:--|:--|:--|
| Sandbox-new | Alias, Opsi D, TTA, converting (TOP 486, F01 5923) | Dipush 18 Nov 2026. Syntax check RC 0, readback identik |
| DEV AIX | Alias, Opsi D, TTA (tanpa patch converting) | Deploy patch converting adalah langkah user |

## 3. Hasil regresi terakhir (harness, 18 Nov 2026)

| Cakupan | Hasil |
|:--|:--|
| 20 DO lama (no 1 s.d. 20) | 0 selisih untuk value dan limit |
| DO 0085006286 | Value 10/10 cocok (ZQM002 = EXEC = ZQM003) |
| Error / dump | Tidak ada |

Catatan limit DO 0085006286: enam baris ZQM002 tampil bulat (misalnya 2 dan 3) sedangkan ZQM003/EXEC tampil 1.50 dan 2.50. Penyebabnya MIC PEYA* tidak ada di QPMK DEV, jadi desimal MIC (STELLEN) 0. Ini masalah data uji, bukan bug program.
