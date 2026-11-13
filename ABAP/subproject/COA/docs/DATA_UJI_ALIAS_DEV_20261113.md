# Data Uji Alias (Opsi 1) di Development AIX — 13 Nov 2026

Tujuan: 1 DO berisi 2 tipe produksi beralias sama (PLE-22) untuk menguji COA gabungan per alias (blueprint AL-01, AL-02, AL-11). Tidak memakai DO, batch, lot, maupun mapping skenario testing (L-QM01–15, ML-QM01–04). Disetujui user per tahap.

## Bahan (final, setelah tahap 2 gagal)

| | Tipe 1 | Tipe 2 |
|---|---|---|
| Material SR | SRAABI (PLE-20) | SRABDI (PL-20) |
| Roll | 0000395789, 0000395790, 0000395791 (9.1 KG, sloc 2322) | 0000387115, 0000387116, 0000387117 (227.5 KG, sloc 2801) |
| JR | JRAABI 0000352265 | JRABDI 0000368300 |
| Alias (ZZALIAS) | PLE-22 | PLE-22 |

Material alias: **SRAACI (PLE-22)**, plan PLE22S/PLE22J. Roll stok bebas, belum pernah masuk DO, bukan batch/lot skenario. **Nilai inspeksi = 0** (lot JR sudah UD tanpa hasil), jadi DO ini menguji struktur: pengelompokan alias, terjemahan MIC, header, opsi limit, fallback, EXEC, ZQM003, bukan nilai rata-rata.

**DO uji: `0085006280`** (SO `0000007205`).

## Log perubahan

| Tahap | Waktu | Objek | Isi | Cara rollback |
|---|---|---|---|---|
| 1 | 13 Nov 2026 | ZMAP_COA | 9 baris baru MATNR = SRAACI, KUNNR kosong: PAACTH00, PAACTSMD, PAACTSTD, PAACELMD, PAACELTD, PAACSHMD, PAACSHTD, PAACHZ00, PAACG400 (MAPPING JR Base Film, SEQ 001–009, tanpa limit). USNAM TRSTDEV | `DELETE FROM ZMAP_COA WHERE MATNR = 'SRAACI'` (sebelumnya kosong) |
| 2 | 13 Nov 2026 | Hasil inspeksi lot JR 040000020664 / 040000020288 | **Gagal, tidak ada yang tersimpan** (BAPI_INSPOPER_RECORDRESULTS → "Confirmation ... not allowed in view of inspLot status", otomatis ROLLBACK). Kedua lot sudah UD (I0218) tanpa hasil | Tidak perlu |
| 3 | 13 Nov 2026 | Klasifikasi batch (class ZZSRBOPP, 023) | ZZALIAS (ATINN 0000000844) = PLE-22 pada 6 roll di atas lewat BAPI_OBJCL_CHANGE. Karakteristik lain dikirim ulang apa adanya; diff AUSP sebelum/sesudah = tepat 6 baris baru | Hapus nilai ZZALIAS 6 roll (CL20N / BAPI_OBJCL_CHANGE tanpa ZZALIAS). Snapshot: `outputs/test_data_alias_20261113/st3_before.txt` |
| 4a | 13 Nov 2026 | Sales order `0000007205` | ZDOR, sales org 1000/01/00, sales office 0002, customer AG/WE 1141000514, PO "UJI ALIAS PLE-22 (COA OPSI 1)", item 10 SRAABI 27.3 KG, item 20 SRABDI 682.5 KG (ZP, plant 2000, ZDATE 13.11.2026, ZLINE Z, ZD00 339.85). Incompletion hanya POSEX (billing) | Tolak item / hapus SO (VA02) setelah DO dihapus |
| 4b | 13 Nov 2026 | Outbound delivery `0085006280` | ZDLF, shipping point 2000, item 10/20 dari SO 7205 | Hapus DO (VL02N), tanpa PGI |
| 4c | 13 Nov 2026 | Batch split DO `0085006280` | 900001–900003 SRAABI 0000395789–91 (9.1 KG), 900004–900006 SRABDI 0000387115–17 (227.5 KG), item ZB, sloc 2813 (default, sama dengan DO skenario) | Ikut hapus DO |

Script: `outputs/test_data_alias_20261113/` (st1–st4c), dijalankan lewat `scripts/mt_run_abap.mjs` ke Development AIX.

## Temuan tahap 2 (13 Nov 2026)

- Lot JR berkarakteristik P (Thickness, Tensile, Elongation, Shrinkage, Haze, Gloss) di DEV yang **belum ada hasilnya semuanya sudah UD**, sehingga hasil tidak bisa diinput lagi: JRCADI 040000020664, JRCCAI 040000020288, JRAABI 040000009268, JRABDI 040000015420.
- Lot JR yang belum UD (Z03, origin 09, dibuat TRST-BUDI 24.06.2025, mis. 090000000958 / 090000000975) hanya berisi karakteristik A (Surface Tension, Decay Time).
- Lot JR yang **punya hasil** hanya lot milik DO skenario (mis. 040000020662, 020752, 020757, 020764, 020773, 021050, 021125, 020671). Roll SR saudaranya tidak ada yang tersisa di stok dan belum masuk DO.

## Hasil uji DO 0085006280 (13 Nov 2026, read-only harness)

- **Harness alias (data asli DEV, tanpa paksa alias, tanpa mapping titipan):** keenam roll terbaca ZZALIAS = PLE-22 → ZZCODE → SRAACI; mapping SRAACI dibaca dari ZMAP_COA; terjemahan MIC **9/9 RULE** untuk SRAABI (PAAB*) dan SRABDI (PABD*). Nilai 0 (sesuai dugaan). Bukti: `outputs/test_data_alias_20261113/out_6280.txt`.
- Spec kedua tipe berbeda (untuk uji opsi limit): Tensile MD 11–18 vs 12–18, Tensile TD 22–35 vs 28–35, Elongation MD 120–240 vs 150–220, Elongation TD 30–90 vs 50–80, Shrinkage TD 0–3 vs 0.5–1.5, Haze 1–2 vs 1–1.5, Gloss 90–100 vs 90–99. Thickness dan Shrinkage MD sama.
- **Program DEV saat ini (as-is)** pada DO ini berhenti dengan pesan "Material belum dimapping di ZMAP_COA" karena SRABDI belum punya mapping. Ini perilaku lama yang benar; setelah logika alias aktif, DO ini lewat jalur alias. Bisa juga dipakai untuk skenario AL-10 (hapus mapping SRAACI sementara).
