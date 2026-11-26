# Analisa: NCR approval "hilang" setelah update hasil barrier (DEV, 25 Nov 2026)

| Atribut | Isi |
|---|---|
| Server | Development AIX (TRD 130) |
| Batch | SRRPAI / 0000407498 (prod date 24.11.2026, roll C1 RPA 116 026), tester TRST-WAFI |
| Program DEV | sudah berisi guard NCR v8 (beda dengan TRS hanya param `IT_SR_CG` di `ZQM_GET_BARRIER_POS`) |
| ZQM039 di DEV | `ZQMI_UPLOAD_QA_HOLD` (upload long text UD), tidak menulis `ZLOG_BARRIER` |

## Kronologi (data asli)

| Waktu 25.11 | Kejadian | Sumber |
|---|---|---|
| 13:22:32 | UD lot R 050000014405 = NCR, lot C 050000014406 = PASS | QAVE |
| 13:31:50 | ZQM004 buat baris ZLOG V1 judgement NCR | ZLOG_BARRIER CPUDT/CPUTM |
| (setelahnya) | NCR di-approve → `NCRAPPROVAL = Approved` | ZLOG_BARRIER |
| 16:43:21 | UD lot L 050000014407 = FAIL (update WVTR/OTR) | QAVE |
| 16:53:42 | ZQM004 jalan lagi: CANBESHIP baris Approved diubah ke `X`, batch 407499/407500 dibuat SCRAP | ZLOG_BARRIER AEDAT/PSOTM |

Baris ZLOG sekarang: `SRRPAI 0000407498 V1 NCR Approved CANBESHIP=X DELETION=''` → **approval tidak terhapus dari tabel**.

## Akar masalah

`GET_JUDGEMENT` hanya memakai baris ZLOG kalau `CPUDT+CPUTM` baris >= waktu UD R, C, dan L:

```abap
IF DATETIME GE DATETIME_R AND DATETIME GE DATETIME_C AND DATETIME GE DATETIME_L.
  JUDGEMENT    = IT_JUDGEMENT-JUDGEMENT.
  NCR_APPROVAL = IT_JUDGEMENT-NCRAPPROVAL.
```

UD L (16:43:21) lebih baru dari baris approval (13:31:50) → judgement & NCR approval kosong → program menghitung ulang judgement.
`INSERT_JUDGEMENT` keluar karena guard (tidak ada versi baru), tetapi `ITAB-NCR_APPROVAL` tetap kosong,
sehingga ZQM004 menampilkan approval kosong dan `GET_SHIPMENT` menulis `CANBESHIP = X` ke baris Approved.

Guard v8 bekerja (tabel aman), tetapi logika tampilan masih mengabaikan approval jika ada UD baru.

## Reproduksi (read-only, DEV)

`PERFORM GET_JUDGEMENT IN PROGRAM ZQMI_BARRIER_PASS_FAIL` untuk batch 0000407498 (R/C = 20261125132232):

| Kasus | DATETIME_L | JUDGEMENT | NCR_APPROVAL | CAN_BE_SHIP |
|---|---|---|---|---|
| A | kosong | NCR | Approved | X |
| B | 20261125164321 (asli) | kosong | kosong | kosong |

Program uji: `ZTREPRO_get_judgement.abap`.

## Keputusan bisnis yang dibutuhkan

Kalau hasil barrier berubah (UD baru) setelah NCR di-approve, mana yang benar?
1. Approval tetap berlaku (judgement beku, konsisten dengan guard v8) → `GET_JUDGEMENT` harus memakai baris Approved tanpa cek waktu UD.
2. Approval gugur, perlu approval ulang → guard v8 di `INSERT_JUDGEMENT` harus dilonggarkan (versi baru dibuat untuk judgement baru).

## Keputusan & perbaikan (26 Nov)

Keputusan user: **approval tetap berlaku (dibekukan), ZQM004 menampilkan data tabel**.

Perubahan `ZQMI_BARRIER_PASS_FAIL` (sandbox-new, GENERATE_OK, TRS = lokal):
1. `GET_JUDGEMENT`: baris aktif dengan `NCRAPPROVAL = 'Approved'` langsung dipakai (judgement, approval, CANBESHIP) tanpa cek waktu UD.
2. Syarat hitung ulang judgement di loop utama: dibungkus `ITAB-NCR_APPROVAL NE 'Approved' AND ( ...syarat lama... )`.

Uji TRS (batch dummy `ZTEST_NCR/ZTNCR00002`, baris dibuat 25.11 13:31:50, UD L 16:43:21):

| Tes | Kondisi | Hasil | Status |
|---|---|---|---|
| T1 | belum Approved | judgement/approval kosong (hitung ulang, perilaku lama) | LULUS |
| T2 | Approved | NCR / Approved / O dari tabel | LULUS |

Dummy dihapus (sisa 0). Belum dicakup: run penuh ZQM004 di GUI; DEV belum dipatch (oleh user).
Setelah patch masuk DEV dan ZQM004 dijalankan ulang, CANBESHIP batch 407498 (sekarang `X`) akan dihitung ulang dengan approval → perlu dicek.
