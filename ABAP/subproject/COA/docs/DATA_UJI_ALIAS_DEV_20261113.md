# Data Uji Alias (Opsi 1) di Development AIX — 13 Nov 2026

Tujuan: 1 DO berisi 2 tipe produksi beralias sama (PLE-22) untuk menguji COA gabungan per alias, plus 1 DO MIXED untuk fallback (cakupan lengkap di bagian "Cakupan skenario"). Tidak memakai DO, batch, lot, maupun mapping skenario testing (L-QM01–15, ML-QM01–04). Disetujui user per tahap.

## Bahan (final, setelah tahap 2 gagal)

| | Tipe 1 | Tipe 2 |
|---|---|---|
| Material SR | SRAABI (PLE-20) | SRABDI (PL-20) |
| Roll | 0000395789, 0000395790, 0000395791 (9.1 KG, sloc 2322) | 0000387115, 0000387116, 0000387117 (227.5 KG, sloc 2801) |
| JR | JRAABI 0000352265 | JRABDI 0000368300 |
| Alias (ZZALIAS) | PLE-22 | PLE-22 |

Material alias: **SRAACI (PLE-22)**, plan PLE22S/PLE22J. Roll stok bebas, belum pernah masuk DO, bukan batch/lot skenario. **Nilai inspeksi = 0** (lot JR sudah UD tanpa hasil), jadi DO ini menguji struktur: pengelompokan alias, terjemahan MIC, header, opsi limit, fallback, EXEC, ZQM003, bukan nilai rata-rata.

**DO uji: `0085006280`** (SO `0000007205`, customer 1141000514) untuk jalur alias, dan **`0085006281`** (SO `0000007206`, customer 1141000512) untuk MIXED/fallback. DO kedua ditambahkan 16 Nov 2026.

## Log perubahan

| Tahap | Waktu | Objek | Isi | Cara rollback |
|---|---|---|---|---|
| 1 | 13 Nov 2026 | ZMAP_COA | 9 baris baru MATNR = SRAACI, KUNNR kosong: PAACTH00, PAACTSMD, PAACTSTD, PAACELMD, PAACELTD, PAACSHMD, PAACSHTD, PAACHZ00, PAACG400 (MAPPING JR Base Film, SEQ 001–009, tanpa limit). USNAM TRSTDEV | `DELETE FROM ZMAP_COA WHERE MATNR = 'SRAACI'` (sebelumnya kosong) |
| 2 | 13 Nov 2026 | Hasil inspeksi lot JR 040000020664 / 040000020288 | **Gagal, tidak ada yang tersimpan** (BAPI_INSPOPER_RECORDRESULTS → "Confirmation ... not allowed in view of inspLot status", otomatis ROLLBACK). Kedua lot sudah UD (I0218) tanpa hasil | Tidak perlu |
| 3 | 13 Nov 2026 | Klasifikasi batch (class ZZSRBOPP, 023) | ZZALIAS (ATINN 0000000844) = PLE-22 pada 6 roll di atas lewat BAPI_OBJCL_CHANGE. Karakteristik lain dikirim ulang apa adanya; diff AUSP sebelum/sesudah = tepat 6 baris baru | Hapus nilai ZZALIAS 6 roll (CL20N / BAPI_OBJCL_CHANGE tanpa ZZALIAS). Snapshot: `outputs/test_data_alias_20261113/st3_before.txt` |
| 4a | 13 Nov 2026 | Sales order `0000007205` | ZDOR, sales org 1000/01/00, sales office 0002, customer AG/WE 1141000514, PO "UJI ALIAS PLE-22 (COA OPSI 1)", item 10 SRAABI 27.3 KG, item 20 SRABDI 682.5 KG (ZP, plant 2000, ZDATE 13.11.2026, ZLINE Z, ZD00 339.85). Incompletion hanya POSEX (billing) | Tolak item / hapus SO (VA02) setelah DO dihapus |
| 4b | 13 Nov 2026 | Outbound delivery `0085006280` | ZDLF, shipping point 2000, item 10/20 dari SO 7205 | Hapus DO (VL02N), tanpa PGI |
| 4c | 13 Nov 2026 | Batch split DO `0085006280` | 900001–900003 SRAABI 0000395789–91 (9.1 KG), 900004–900006 SRABDI 0000387115–17 (227.5 KG), item ZB, sloc 2813 (default, sama dengan DO skenario) | Ikut hapus DO |

| 5 | 16 Nov 2026 | ZMAP_COA SRAACI (KUNNR kosong) | Limit: PAACTSTD 25.00–35.00, PAACELMD 140.00–230.00, PAACSHTD lower kosong / upper 2.00, PAACG400 lower 92.00 / upper kosong. MIC lain tetap tanpa limit | `UPDATE ZMAP_COA SET LOWER_LIMIT = ' ' UPPER_LIMIT = ' ' WHERE MATNR = 'SRAACI' AND KUNNR = ' '` |
| 6 | 16 Nov 2026 | ZMAP_COA SRAACI, KUNNR 1141000514 | 1 baris override PAACTSTD: METHOD "ASTM D 882 (CUST)", limit 26.00–34.00, SEQ 003 | `DELETE FROM ZMAP_COA WHERE MATNR = 'SRAACI' AND KUNNR = '1141000514'` |
| 7a | 16 Nov 2026 | Klasifikasi batch SRAABI 0000395792 | ZZALIAS = PLE-22 (roll ini saja). Saudaranya 0000395793 sengaja **tanpa** alias | Hapus nilai ZZALIAS roll 0000395792 |
| 7b | 16 Nov 2026 | Sales order `0000007206` | ZDOR, sales office 0001, customer AG/WE 1141000512 (tidak punya mapping customer untuk SRAABI/SRAACI), PO "UJI ALIAS MIXED (COA OPSI 1)", item 10 SRAABI 18.2 KG. Incompletion hanya POSEX | Hapus SO setelah DO dihapus |
| 7c | 16 Nov 2026 | Outbound delivery `0085006281` | ZDLF, shipping point 2000, item 10 dari SO 7206 | Hapus DO (VL02N), tanpa PGI |
| 7d | 16 Nov 2026 | Batch split DO `0085006281` | 900001 SRAABI 0000395792 (alias PLE-22), 900002 SRAABI 0000395793 (tanpa alias), 9.1 KG, item ZB, sloc 2813 | Ikut hapus DO |

Script: `outputs/test_data_alias_20261113/` (st1–st4c) dan `outputs/test_data_alias_20261116/` (st5–st7d, chk_*), dijalankan lewat `scripts/mt_run_abap.mjs` ke Development AIX.

## Temuan tahap 2 (13 Nov 2026)

- Lot JR berkarakteristik P (Thickness, Tensile, Elongation, Shrinkage, Haze, Gloss) di DEV yang **belum ada hasilnya semuanya sudah UD**, sehingga hasil tidak bisa diinput lagi: JRCADI 040000020664, JRCCAI 040000020288, JRAABI 040000009268, JRABDI 040000015420.
- Lot JR yang belum UD (Z03, origin 09, dibuat TRST-BUDI 24.06.2025, mis. 090000000958 / 090000000975) hanya berisi karakteristik A (Surface Tension, Decay Time).
- Lot JR yang **punya hasil** hanya lot milik DO skenario (mis. 040000020662, 020752, 020757, 020764, 020773, 021050, 021125, 020671). Roll SR saudaranya tidak ada yang tersisa di stok dan belum masuk DO.

## Hasil uji DO 0085006280 (13 Nov 2026, read-only harness)

**Lot asli yang dibaca program (cek 16 Nov 2026, trace GET_TRACED_LOTS):**

| Roll | Material | JR batch | Lot dipakai program (LOT_JR_BASE) | Isi lot | Lot P (Z02) di JR yang sama |
|---|---|---|---|---|---|
| 0000395789–91 | SRAABI | JRAABI 0000352266 | 090000000959 (Z03, TRST-BUDI 24.06.2025) | Hanya AAABDTTR/STNT/STTR, **tanpa hasil**, belum UD | 040000009270: PAAB* lengkap, UD P1 12.10.2017, **tanpa hasil** |
| 0000387115–17 | SRABDI | JRABDI 0000368300 | 090000000975 (Z03, TRST-BUDI 24.06.2025) | Hanya AABDDTTR/STNT/STTR, **tanpa hasil**, belum UD | 040000015420: PABD* lengkap, UD P1 05.09.2019, **tanpa hasil** |

Lot SR (Z04) untuk keenam roll tidak ada. Jadi value 0 karena data inspeksi aslinya memang kosong, bukan karena logika alias.

**Cek cancel UD (16 Nov 2026, read-only, tidak ada perubahan data):**

- Sistem DEV: ECC 6.0 EhP6 (SAP_APPL 606, SAP_BASIS 731). Ada QA12 / QA14 (ubah kode UD) dan `BAPI_INSPLOT_SETUSAGEDECISION`, tetapi **tidak ada fungsi standar untuk membatalkan UD** (fitur reset UD baru ada di S/4HANA). Ubah kode UD tidak membuka kembali pencatatan hasil.
- Status kedua lot Z02: UD, SPCO (stock posting completed), STUP. Posting stok UD: 040000009270 → mat. doc 4900357599/2017, 040000015420 → 4900373548/2019, mvt **321** (QI → unrestricted) seluruh kuantitas (25.001.500 KG dan 8.153,6 KG).
- Stok batch JR sekarang **0** (JRAABI 0000352266, JRABDI 0000368300): sudah habis diproses jadi SR. Posting 321 tidak bisa dibalik tanpa stok.
- Satu-satunya jalan adalah ubah tabel langsung (QAVE, JEST I0218/I0220, QALS): non-standar, tidak konsisten dengan dokumen material, **tidak direkomendasikan**.
- Walaupun berhasil, `GET_TRACED_LOTS` (F01 ±2684, `SELECT SINGLE ... ART = 'Z02' OR ART = 'Z03'` tanpa ORDER BY) memilih lot Z03 090000000959 / 090000000975 yang hanya punya MIC A, jadi value P tetap 0.

Kesimpulan: value DO 6280 tidak bisa diisi lewat cancel UD. Alternatif: DO uji baru dari roll yang batch JR-nya hanya punya satu lot P belum UD.

| 8 | 16 Nov 2026 | UD lot 040000009270 dan 040000015420 | **Di-reset oleh user** (bukan Claude). Status sekarang REL + UDRE (I0297 "Usage decision reset"); UD, ICCO, STIC hilang; QAVE VCODE kosong. SPCO tetap, posting 321 tidak dibalik, stok batch tetap 0. Hasil (QAMR) belum ada | UD ulang (QA11) kode P1 |

Cek setelah reset (16 Nov 2026): trace `GET_TRACED_LOTS` DO 6280 **tetap** memilih lot Z03 090000000959 / 090000000975, value COA tetap 0. Lot 040000009270 / 040000015420 tidak dipakai DO skenario mana pun.

- **Harness alias (data asli DEV, tanpa paksa alias, tanpa mapping titipan):** keenam roll terbaca ZZALIAS = PLE-22 → ZZCODE → SRAACI; mapping SRAACI dibaca dari ZMAP_COA; terjemahan MIC **9/9 RULE** untuk SRAABI (PAAB*) dan SRABDI (PABD*). Nilai 0 (sesuai dugaan). Bukti: `outputs/test_data_alias_20261113/out_6280.txt`.
- Spec kedua tipe berbeda (untuk uji opsi limit): Tensile MD 11–18 vs 12–18, Tensile TD 22–35 vs 28–35, Elongation MD 120–240 vs 150–220, Elongation TD 30–90 vs 50–80, Shrinkage TD 0–3 vs 0.5–1.5, Haze 1–2 vs 1–1.5, Gloss 90–100 vs 90–99. Thickness dan Shrinkage MD sama.
- **Program DEV saat ini (as-is)** pada DO ini berhenti dengan pesan "Material belum dimapping di ZMAP_COA" karena SRABDI belum punya mapping. Ini perilaku lama yang benar; setelah logika alias aktif, DO ini lewat jalur alias. Bisa juga dipakai untuk skenario AL-10 (hapus mapping SRAACI sementara).

## Verifikasi tahap 5–7 (16 Nov 2026, read-only)

`outputs/test_data_alias_20261116/out_verify.txt`, dengan logika baca mapping yang sama dengan program (umum + override customer):
- DO 0085006280 (KUNAG 1141000514): 6 roll → PLE-22 → SRAACI. Mapping hasil gabung: PAACTSTD dari customer (ASTM D 882 (CUST), 26.00–34.00), MIC lain dari mapping umum.
- DO 0085006281 (KUNAG 1141000512): roll 0000395792 → SRAACI, roll 0000395793 tanpa alias → **MIXED**. Mapping SRAACI yang terbaca hanya yang umum (PAACTSTD 25.00–35.00).

## Cakupan skenario blueprint (§8)

| ID | Skenario | Data DEV | Cara uji |
|---|---|---|---|
| AL-01 | 1 COA gabungan per alias | DO 6280 | **Struktur saja** (1 COA PLE-22, 6 roll, MIC PAAC*, header alias). Nilai rata-rata lewat harness dengan nilai DO skenario |
| AL-02 | Opsi limit | DO 6280 | **Ya**, bandingkan dengan tabel expected di bawah |
| AL-03 | Satu tipe produksi | Belum | Bisa dengan mengisi ZZALIAS 0000395793 = PLE-22 (DO 6281 jadi 1 tipe). Belum dibuat karena DO 6281 dipakai untuk MIXED |
| AL-04 | Fallback NONE | Tidak | Harness (mapping titipan dengan MIC tanpa padanan) |
| AL-05 | Fallback NOCONV | Tidak | Harness (paksa alias tak terkonversi) |
| AL-06 / AL-10 | NOMAP / mapping kosong | DO 6280 | Nonaktifkan mapping SRAACI sementara (DELETION = 'X'). Karena SRABDI juga tak punya mapping, hasilnya STOP "Material belum dimapping" (= AL-10) |
| AL-07 | Override customer | DO 6280 | **Ya**, PAACTSTD harus tampil METHOD "ASTM D 882 (CUST)" dan (Opsi A) limit 26.00–34.00 |
| AL-08 | Pilih roll alias + roll as-is | Tidak | Harness, atau DO baru berisi kelompok alias + MATNR lain bermapping |
| AL-09 | Terjemahan DESC | Tidak | Harness (semua MIC DEV RULE) |
| AL-11 | ZQM003 jalur alias | DO 6280 | Struktur: 6 baris per MIC alias (MIC PAAC*), limit sama dengan print. Nilai 0 |
| AL-12 | ZQM003 fallback | DO 6281 | **Ya**, identik dengan output program sekarang |
| AL-13 | Fallback MIXED (baru) | DO 6281 | **Ya**, 1 COA SRAABI as-is (mapping SRAABI umum), 2 roll, identik dengan program sekarang |

## Expected limit DO 0085006280 per opsi

Nilai inspeksi 0, jadi bobot Opsi C = 1 per tipe (blueprint §3.6 aturan 1). Desimal mengikuti MIC (TH, TS, SH, HZ 2 desimal; EL, G400 0 desimal). Spec asli dari plan masing-masing tipe; QPMK = spec MIC alias SRAACI.

| MIC alias | SRAABI | SRABDI | Mapping (cust 1141000514) | QPMK alias | **A** | **B1** | **B2** | **C** |
|---|---|---|---|---|---|---|---|---|
| PAACTH00 Thickness | 19.40–20.60 | 19.40–20.60 | – | 21.34–22.66 | 21.34–22.66 ¹ | 19.40–20.60 | sama | 19.40–20.60 |
| PAACTSMD Tensile MD | 11–18 | 12–18 | – | 11–18 | 11.00–18.00 | 12.00–18.00 | beda | 11.50–18.00 |
| PAACTSTD Tensile TD | 22–35 | 28–35 | 26–34 (cust) | 22–35 | **26.00–34.00** | 28.00–35.00 | beda | 25.00–35.00 |
| PAACELMD Elongation MD | 120–240 | 150–220 | 140–230 | 120–240 | 140–230 | 150–220 | beda | 135–230 |
| PAACELTD Elongation TD | 30–90 | 50–80 | – | 30–90 | 30–90 | 50–80 | beda | 40–85 |
| PAACSHMD Shrinkage MD | 3–5 | 3–5 | – | 3–5 | 3.00–5.00 | 3.00–5.00 | sama | 3.00–5.00 |
| PAACSHTD Shrinkage TD | 0–3 | 0.5–1.5 | kosong / 2.00 | 0–3 | 0.00–2.00 ² | 0.50–1.50 | beda | 0.25–2.25 |
| PAACHZ00 Haze | 1–2 | 1–1.5 | – | 1–2 | 1.00–2.00 | 1.00–1.50 | beda | 1.00–1.75 |
| PAACG400 Gloss 45 | 90–100 | 90–99 | 92 / kosong | 90–100 | 92–100 ² | 90–99 | beda | 90–100 ³ |

- **B2:** 7 MIC beda → COA gabungan ditolak (pemicu LIMIT), fallback per tipe. SRABDI tidak punya mapping, jadi hasil akhirnya **STOP "Material belum dimapping"**. Ini perilaku yang benar, bukan bug.
- ¹ Spec QPMK alias (PLE-22) memang berbeda dari spec roll (tebal 20). Ini efek data uji: alias PLE-22 dipasang pada roll PLE-20/PL-20.
- ² Sisi kosong di mapping diisi QPMK MIC alias (SHTD lower 0.00, G400 upper 100).
- ³ (100 + 99) / 2 = 99.5, dibulatkan 0 desimal menjadi 100.

## Expected DO 0085006281

- Kelompok SRAACI tidak terbentuk: SRAABI punya roll beralias dan tanpa alias → MIXED → seluruh roll SRAABI dicetak as-is.
- ZQM002: 1 COA SRAABI, 2 roll, MIC PAAB*, mapping SRAABI umum (customer 1141000512 tanpa override), limit sama dengan program sekarang. Pesan fallback MIXED tampil.
- ZQM003: 2 baris batch per MIC (MIC PAAB*), kolom, nilai, dan limit identik dengan output program sekarang untuk DO ini (jadikan baseline sebelum implementasi).
