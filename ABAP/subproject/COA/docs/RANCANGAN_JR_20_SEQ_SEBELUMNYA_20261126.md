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
6. Tahun: `114` bisa 2014/2024. Pilih batch dengan `MCH1-ERSDA` paling dekat ke batch JR yang dicari. Nomor roll yang punya >1 batch: semua batch tahun itu dicek.
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

Belum ada data uji JR tanpa lot sama sekali.

## 5. Catatan

- Query sequence terakhir bulan sebelumnya memakai `AUSP ... ATWRT LIKE '<prefix> ___'`; perlu dicek performanya di PRD.
- Jatah 20 dihitung per nomor sequence, bukan per roll yang ada.
- Backup sandbox-new sebelum push: `outputs/ZQMI_COA_F01_sandbox-new_sbx_pre_jrprev.abap`.

## 6. Keputusan QA

26 Nov 2026, Aisyah (QA): semua JR dalam 1 DO tetap mencari sampai 20 sequence sebelumnya, walaupun DO berisi lebih dari 1 JR (opsi A, `outputs/konfirmasi_jr_20261126/konfirmasi_hitung_jr.html`). Program DEV sudah sesuai; tidak ada perubahan lagi.
