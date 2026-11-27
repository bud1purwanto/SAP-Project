# Lot JR dari 20 sequence sebelumnya (lintas bulan)

Tanggal: 26 Nov 2026. Status: **sandbox-new + DEV AIX** (F01 6293 baris). Deploy DEV oleh user 26 Nov; source DEV identik dengan patch, regresi program DEV apa adanya 21 DO `outputs/MT_20261126_dev_after_jrprev.txt` = hasil harness patch (0 selisih), tanpa error/dump.
Sumber aturan: feedback Mbak Alfa (QA) lewat user, 26 Nov 2026.

## 1. Masalah sebelumnya

Source DEV (`ZQMI_COA_F01`, fetch 26 Nov = sandbox-new) punya dua aturan JR yang arahnya berlawanan:

| Kasus | FORM | Arah lama | Batas | Syarat |
|---|---|---|---|---|
| JR tanpa lot Z02/Z03 | `GET_JR_SIBLING_LOT` | Sequence **sesudahnya** (+1 s/d +20) | 20 | Prefix roll sama |
| JR punya lot, hasil kosong | `GET_JR_AVG` langkah 2 | Sequence **sebelumnya**, terdekat | Tanpa batas | Production order sama, per MIC |

Keduanya tidak menyeberang bulan.

## 2. Aturan baru

Nomor roll JR `G EYA 114 005` = line `G`, code `EYA`, bulan-tahun `114` (bulan `11`, digit tahun `4`), sequence `005`.

1. Berlaku bila lot JR tidak ada, atau lot ada tapi tidak punya hasil sama sekali (`QAMR ANZWERTG > 0`).
2. Cari ke sequence **sebelumnya**, terdekat duluan, jatah **20 sequence** (roll itu sendiri tidak dihitung).
3. Bulan yang sama dulu (`seq-1` s/d `001`). Sisa jatah dari **satu bulan sebelumnya**, mulai sequence terakhir bulan itu. Contoh `G EYA 114 005`: `004–001` lalu `G EYA 104 230–215`.
4. Berhenti di roll pertama yang lot-nya punya hasil. Tidak ketemu → kosong.
5. Fokus lot: nilai MIC diambil dari lot itu sesuai mapping; MIC yang tidak ada di lot itu tetap kosong.
6. Tahun: `114` bisa 2014/2024. Pilih batch dengan `MCH1-ERSDA` paling dekat ke batch JR yang dicari. Nomor roll yang punya >1 batch: semua batch tahun itu dicek. **Beda dekade tidak valid** (27 Nov 2026): batch dengan selisih `ERSDA` > 5 tahun (1826 hari) dari batch JR dilewati, walaupun hanya itu yang ada.
7. Tidak ada syarat production order sama.

Yang **tidak berubah**: lot yang tampil di COA, rata-rata DO per JR (kunci = lot JR sendiri), override `ZLOG_COA` (dibaca dari lot sendiri).

## 3. Perubahan program (`ZQMI_COA_F01`)

| Lokasi | Perubahan |
|---|---|
| FORM baru `GET_JR_PREV_LOT`, `JR_PREV_CHECK`, `JR_LOT_HAS_RESULT` | Aturan §2 |
| `GET_TRACED_LOTS` (JR Conv, JR Base), `GET_MT_LOTS`, `TTA_TRACE` | JR tanpa lot: `GET_JR_SIBLING_LOT` diganti `GET_JR_PREV_LOT` |
| `GET_JR_AVG` langkah 2 | Fallback per MIC 1 production order diganti: lot sendiri tanpa hasil → nilai dari lot `GET_JR_PREV_LOT` |

`GET_JR_SIBLING_LOT` dan `SPLIT_ROLL` masih ada tapi tidak dipanggil lagi.

## 4. Hasil uji (harness DEV, 21 DO, program DEV tidak diubah)

Acuan: program asli `outputs/MT_20261126_jrprev_orig.txt`, patch `outputs/MT_20261126_jrprev_new.txt`.

- **19 DO SAMA** (ZQM002, EXEC, ZQM003): 6234, 6235, 6240–6245, 6271, 6272, 6276, 6277, 6278, 6280–6282, 6284–6286.
- **2 DO BERUBAH (disengaja, lintas bulan):**

| DO | JR tanpa hasil | Lama | Baru |
|---|---|---|---|
| 6270 (L-QM11) | `4 AAB 086 003` | Kosong (tidak ikut rata-rata) | Lot `4 AAB 076 009` (Juli). 11 MIC berubah, mis. Thickness 22.40 → 20.99 |
| 6279 (ML-QM04) | `V EC7 116 001/002` | Kosong | Lot `V EC7 106 001` (Oktober). PEC7FDCD 0.540 → 0.470 |

Uji tambahan: JR `4 ACB 106 007` → lot JR 004; `4 ACB 106 025` → 20 kandidat (024–005), tanpa hasil, tetap kosong; `4 AAB 126 003` (Des 2016) → `002, 001` lalu `4 AAB 116 028–011` (Nov 2016) = 20 kandidat.

Data uji JR tanpa lot sama sekali (27 Nov 2026, DO lama di DEV, tanpa membuat data baru):

| DO | JR (tanpa lot) | Lot dipakai | Program lama | Program DEV sekarang |
|---|---|---|---|---|
| `0085003759` (SRAAAI, 5 roll `0000353057`–`061`) | `5 AAA 076 002` (`0000353010`) | `040000009481` (`5 AAA 076 001`) | Semua MIC JR 0, lot kosong | ELMD 139, ELTD 40, FDNT 0.400, FDTR 0.400, G400 99, HZ00 1.00, SHMD 4.00, SHTD 4.00, TSMD 12.00, TSTD 23.00 (= QAMR); SAAASTTR 55 tetap dari lot SR |
| `0085003757` (SRAAAI, 6 roll `0000352989`–`994`) | `5 AAA 066 010` (`0000352995`) | `040000009460` (`5 AAA 066 002`) | Semua 0, lot kosong | Semua 0: lot 9460 hanya punya hasil PAAATH00 (tidak ada di mapping), pencarian berhenti di lot ini |

Output: `outputs/test_data_jrnolot_20261127/MT_jrnolot_existing.txt` (program DEV) dan `MT_jrnolot_existing_orig.txt` (harness program sebelum patch). Lintas bulan untuk JR tanpa lot belum ada datanya di DEV (sudah dicek 34 JR tanpa lot; logikanya sama dengan DO 6270/6279).

## 5. Catatan

- Query sequence terakhir bulan sebelumnya memakai `AUSP ... ATWRT LIKE '<prefix> ___'`; perlu dicek performanya di PRD.
- Jatah 20 dihitung per nomor sequence, bukan per roll yang ada.
- Backup sandbox-new sebelum push: `outputs/ZQMI_COA_F01_sandbox-new_sbx_pre_jrprev.abap`.

## 6. Keputusan QA

26 Nov 2026, Aisyah (QA): semua JR dalam 1 DO tetap mencari sampai 20 sequence sebelumnya, walaupun DO berisi lebih dari 1 JR (opsi A, `outputs/konfirmasi_jr_20261126/konfirmasi_hitung_jr.html`). Program DEV sudah sesuai; tidak ada perubahan lagi.

## 7. Tambalan beda dekade (27 Nov 2026)

Pertanyaan Aisyah: DO 6270 JR `4 AAB 086 003` mengambil `4 AAB 076 009` tahun 2026. Hasil cek: JR di DO 6270 adalah batch `0000405990` (dibuat 05.08.2026), jadi 2026 sudah benar. Batch 2016 `4 AAB 076 009` (`0000353972`) memang tanpa hasil.

Celah yang ditambal (perintah user: "beda dekade soale ga valid"): kalau roll di tahun yang sama tidak ada, program lama tetap mengambil batch dekade lain karena memilih ERSDA terdekat. Sekarang batch dengan selisih ERSDA > 1826 hari dilewati, di `JR_PREV_CHECK` (kandidat per roll) dan di `GET_JR_PREV_LOT` (penentuan sequence terakhir bulan sebelumnya). F01 6303 baris, `outputs/ZQMI_COA_F01_jrprev_decade_patch.abap`.

| Uji (`outputs/test_data_jrnolot_20261127/dec_test.txt`) | Lama | Baru |
|---|---|---|
| Roll `5 AAA 076 001` (hanya 2016), JR acuan 2016 | lot `040000009481` | lot `040000009481` |
| Roll `5 AAA 076 001` (hanya 2016), JR acuan 2026 | lot `040000009481` (beda dekade) | **kosong** |
| Roll `4 AAB 076 009` (2016 dan 2026), JR acuan 2026 | `040000020752` | `040000020752` |
| JR `0000405990` / `0000353010` / `0000352995` | 20752 / 9481 / 9460 | sama |

Regresi 23 DO (harness DEV, `outputs/MT_20261127_jrprev_decade.txt`): **23 SAMA** dengan acuan aktif. Push sandbox-new 27 Nov (RC 0, readback identik; backup `outputs/ZQMI_COA_F01_sandbox-new_sbx_pre_decade.abap`). **DEV AIX: deploy user 27 Nov**, source DEV identik patch (F01 6303); regresi program DEV apa adanya 23 DO `outputs/MT_20261127_dev_after_decade.txt` = acuan aktif dan = harness (23 SAMA, tanpa error).

## 8. Analisa Excel Aisyah `trace_bulan_beda.xlsx` (27 Nov 2026)

Excel Aisyah menelusuri JR `0000354031` (2016) lewat SR `0000358959` (roll `4 AAB 086 003 9K 01 1`, dibuat 25.07.2017) dan menyimpulkan "trace 2016, 20 ke atas tidak dapat, harusnya tetap before".

Hasil cek DEV: SR di DO 6270 adalah `0000406016`–`0000406021` (roll `4 AAB 086 003 9K 0x 0x`, dibuat 05.08.2026, GR 101 dari order `P29000003258`–`260`). `ZQM_GET_BATCH_JR_BY_SR` untuk SR ini = JR `0000405990` (05.08.2026, lot `040000020798` tanpa hasil), bukan `0000354031`. SR `0000358959` adalah batch lain dengan nomor roll mirip (data 2016/2017) dan tidak ada di DO 6270. Jadi program memakai JR 2026, lalu mengambil `4 AAB 076 009` 2026 di urutan ke-11 (002, 001, lalu Juli 2026 017 → 009). Nilai Excel Aisyah (JR1 19.58, JR2 22.40, rata-rata 20.99) = print ZQM002. Program tidak diubah.

Cek lanjutan (klaim "DO 6270 punya JR 2016 `0000354031`"): silsilah SAP (`outputs/test_data_jrnolot_20261127/q6.txt`) SR → order P29 → ZCA (`AFPO-MILL_OC_AUFNR_U`) → GI 261:

| SR | Order P29 | ZCA | JR dikonsumsi (261) |
|---|---|---|---|
| `406016/017` | `P29000003258` | `100000073129` | `0000405990` (`4 AAB 086 003`, 05.08.2026) |
| `406018/019` | `P29000003259` | `100000073130` | `0000405990` |
| `406020/021` | `P29000003260` | `100000073131` | `0000405990` |
| `406022`–`027` | `P29000003261`–`263` | `100000073132`… | `0000406009` (`4 AAB 086 022`, 2026) |
| `406028/029` | `P29000003264` | `100000073135` | `0000405990` + `0000406009` (join) |

Tidak ada GI dari JR `0000354031` di DO 6270. Simulasi `GET_JR_PREV_LOT`: JR `0000354031` (2016) → kosong (benar, 2016 tidak ada hasil dalam 20); JR `0000405990` (2026) → `040000020752`.
