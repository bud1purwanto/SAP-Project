# Checklist Transport & Setup COA ke QA (TRQ 320)

Dibuat 26 Nov 2026 dari perbandingan TADIR/E071/DD02L DEV AIX (TRD 130) vs QA (TRQ 320), hanya baca. Bukti: `outputs/qa_prep_20261126/objcheck*.txt`, `trcheck.txt`, `trlist.txt`, `ddic.txt`.

Eksekusi transport dilakukan user/Basis. Centang tiap baris setelah dicek di QA.

## A. Transport request yang sudah ada

Request **TRDK924626** (owner TRSTDEV, target **TRQ**, status *modifiable*), task **TRDK924627** (25 Nov 2026) "AB - Enhancement Program for COA Automation Project". Isi task:

| Tipe | Objek | Status di QA sekarang |
|:--|:--|:--|
| PROG | ZQMI_COA, ZQMI_COA_TOP, ZQMI_COA_F01, ZQMI_COA_F02, ZQMI_COA_ALV | belum ada |
| PROG | ZMAP_COA, ZMAP_COA_MIC, ZMAP_COA_BATCH | belum ada |
| PROG | ZQMI_PENDING_BARRIER (+ varian PENDING) | belum ada |
| LIMU REPS/REPT | ZMAP_GLOBAL | ada (versi lama) |
| TABL + TABD | ZMAP_COA, ZMAP_COA_GRP_COL, ZMAP_COA_GRP_CST, ZLOG_COA | belum ada |
| LIMU TABT | ZQM_COA_CUST_COL (hanya setting teknis, TABL-nya tidak ikut) | TABL belum ada |
| SSFO/SSST | ZQMF_COA (+ style) | ada, versi 2018 → tertimpa |
| SSFO | ZQMF_COA_EXPORT | belum ada |
| TRAN | ZQM001, ZQM002, ZQM003, ZQM004 | ZQM002 ada (menunjuk ZQMI_CERTIFICATE), lainnya belum |
| VARX | ZQMI_COAREPORT | — |

## B. Objek yang dipakai program tapi BELUM masuk TRDK924626

Diambil dari source DEV 25 Nov (`outputs/ZQMI_COA_*_Development AIX_dev_25nov_b.abap`).

- [ ] **ZQM_COA_DYN_ROLL** (struktur INTTAB, dipakai TOP + F01) — tidak ada di QA → syntax error tanpa ini
- [ ] **ZQM_COA_DYN_HDR** (struktur INTTAB, dipakai TOP) — tidak ada di QA
- [ ] **ZQMF_COA_BATCH** (smartform, dipakai F01) — tidak ada di QA
- [ ] **ZQM_COA_CUST_COL**: tidak dipakai source terbaru. Pilih: tambahkan R3TR TABL-nya, atau keluarkan LIMU TABT dari task (TABT tanpa TABL bisa gagal import)
- [ ] Putuskan ZQMI_PENDING_BARRIER / ZQM004 memang ikut rilis ini (bukan bagian COA)

Sudah ada di QA dan tidak perlu ditransport (dicek): ZBATCHISTORY, ZPROGINFO, ZMAP_TYPE, ZQM_GET_BATCH_SR (tabel), FM ZQM_GET_BATCH_JR_BY_SR (QA 24 Jul 2026 vs DEV 21 Jul), FM ZQM_GET_BATCH_SR_BY_JR (20 Okt 2026 sama), Z_GET_PRODUCTION_DATE, tcode ZEQM015 (ZQMR_TRACEABILITY_TTE, versi sama), karakteristik batch ZZALIAS/ZZNOMORROLL/ZZPRODLINE/ZZTYPE. Tabel COA baru tidak memakai data element/domain Z.

## C. Urutan langkah transport

- [ ] 1. Pastikan versi aktif DEV = versi yang mau dirilis (DEV 25 Nov). Bandingkan dengan sandbox-new bila perlu.
- [ ] 2. Tambahkan objek §B ke TRDK924626 (SE09/SE10).
- [ ] 3. Release task TRDK924627, lalu release request TRDK924626.
- [ ] 4. Import ke TRQ (STMS), cek log RC ≤ 4.
- [ ] 5. Di QA: SE38 ZQMI_COA → syntax check / generate OK. SE11 tabel COA aktif.
- [ ] 6. SE93: ZQM002 → ZQMI_COA (bukan ZQMI_CERTIFICATE), ZQM001 → ZMAP_COA, ZQM003 → ZQMI_COA.
- [ ] 7. SMARTFORMS: ZQMF_COA, ZQMF_COA_BATCH, ZQMF_COA_EXPORT aktif (generate FM).

## D. Isi tabel (delivery class A, tidak ikut transport)

| Tabel | Baris di DEV | Cara ke QA |
|:--|--:|:--|
| ZMAP_COA | 244 | Upload lewat ZQM001 di QA, atau transport R3TR TABU dengan key |
| ZMAP_COA_GRP_COL | 49 | sama |
| ZMAP_COA_GRP_CST | 60 | sama |
| ZLOG_COA | — | jangan disalin (log edit value saat testing) |

- [ ] Field KUNNR di ZMAP_COA / ZMAP_COA_GRP_CST diterjemahkan ke nomor customer **QA** (cocokkan nama; nomor beda antar sistem, mis. 1141000514).
- [ ] Mapping alias untuk data uji (PLE-22 → SRAACI, HSB-18/HSS-18/HSP-18) dan SRCBUX PCAD* ikut diisi.
- [ ] Setelah isi: jumlah baris QA = DEV per tabel (kecuali baris yang sengaja di-skip, dicatat).

## E. Otorisasi & sistem

- [ ] User uji (TRSTDEV / user tester) di QA 320 punya akses ZQM001/ZQM002/ZQM003/ZQM005, VA01, VL01N/VL02N, QE51N, MSC2N.
- [ ] Konfirmasi UAT/EUT di client 320 (bukan 360).
- [ ] Koneksi SAP GUI "QA" di server :99 bisa login client 320.

## F. Smoke test setelah transport

- [ ] ZQM002 di QA terbuka dengan layar ZQMI_COA (field Nomor ODO).
- [ ] Jalankan 1 DO uji QA → tidak dump (ST22 bersih).
- [ ] ZQM003 jalan untuk DO yang sama.
- [ ] Harness read-only Claude (pool subroutine) di QA: ZQM002 = EXEC = ZQM003.
