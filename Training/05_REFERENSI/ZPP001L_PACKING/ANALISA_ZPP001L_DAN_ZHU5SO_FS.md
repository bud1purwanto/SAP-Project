# Analisa Struktur: ZPP001L (Slitting One Button) & ZHU5SO / ZHU5FS (Packing)

Sumber: source program dibaca read-only dari **Development AIX (TRD)** pada 2026-10-28, dicek keberadaannya di **Sandbox New Company (TRS)**.
Dokumen ini ringkasan struktur untuk bahan Day 13–14; bukan salinan source.

## 1. Mapping TCODE

| TCODE | Program | Teks |
|---|---|---|
| `ZPP001L` | `ZPPI_SR_EXEC` | Slitting Program for Laminator |
| `ZPP001` | `ZPPI_SR_PROCESS` | Slitting Program |
| `ZPP001N` | `ZPPI_SR_PROCESS_BC` | Slitting Program |
| `ZHU5SO` / `ZHU5SOR` | `ZHUI_PACK_PC` | Packing for Sales Order |
| `ZHU5FS` / `ZHU5FSR` | `ZHUI_PACK_PC` | Packing for Free Stock |
| `ZHU4SO` / `ZHU4FS` | `ZHUI_PACKINST` | Maintain Packing Instruction |
| `ZHU02A` | `ZHUI_UNPACK` | Delete collective HU non ZHU5SO/FS |

## 2. ZPPI_SR_EXEC (ZPP001L) — ±4.600 baris, satu source

- Selection screen: `S_AUFNR`, `S_CHARG`, `S_BUDAT`, `S_WERKS`, `S_ARBPL` → `CALL SCREEN 100` (ALV preview JR) → popup screen 2000 (input slitting).
- User command screen 100: `EXEC`, `CANC`, `DELETE`, `REFRESH`, `PRINT`. Popup: `BTN_SAVE`, `BTN_CANCEL`.

**Urutan "one button" (BTN_SAVE):**

| # | FORM | Isi utama | Commit |
|---|---|---|---|
| 1 | `VALIDATE_POPUP` | Validasi input slitting | – |
| 2 | `SET_NUMBERING` | Penomoran batch SR | – |
| 3 | `CREATE_PRO_ORIGINAL` | `BAPI_PROCORD_CREATE` (order SR original) | Ya |
| 4 | `CREATE_PRO_COMBINE` | Order combine | Ya |
| 5 | `RELEASE_ORDERS` | `BAPI_PROCORD_RELEASE` | Ya |
| 6 | `CREATE_BATCH` | `BAPI_BATCH_CREATE` | Ya |
| 7 | `CHANGE_BATCH` | `BAPI_BATCH_CHANGE` / karakteristik (`BAPI_OBJCL_CHANGE`) | Ya |
| 8 | `GOODS_ISSUE` | `BAPI_GOODSMVT_CREATE` (GI JR) | Ya |
| 9 | `GOODS_RECEIPT` | `BAPI_GOODSMVT_CREATE` (GR SR) | Ya |
| 10 | `CHANGE_BATCH_INPUTAN` | Update batch JR (panjang sisa) | Ya |
| 11 | `CREATE_CONFIRMATION` | `BAPI_PROCORDCONF_CREATE_TT` | Ya |
| 12 | `CREATE_SO` | Sales order (`BAPI_SALESORDER_*`, konfigurasi VC) | Ya |
| 13 | `CHANGE_SO` | Update SO | Ya |
| 14 | `FREE_TO_SO` | Free stock → stok SO | Ya |
| 15 | `TECO` | `BAPI_PROCORD_COMPLETE_TECH` | Ya |
| – | `CHECK_ERROR 'EXEC'` | Tampilkan hasil | – |

Pola penting: **setiap step commit sendiri** (multi-LUW). Cancel (`PROCESS_CANCEL`) membalik: `REVOKE_TECO`, `CANCEL_CONFIRMATION`, `BAPI_GOODSMVT_CANCEL`, `CANCEL_SO`, `DELETE_ORDERS`, dst. Pelajaran insiden GR duplikat ZPP001 (lihat folder `AUTO_TECO_ZPP001`) berlaku juga di sini: guard, kompensasi, log persisten.

## 3. ZHUI_PACK_PC (ZHU5SO / ZHU5FS)

- Program utama kecil; logika di include `ZHUI_PACK_NB_TOP`, `ZHUI_PACK_NB_F01` (±7.000 baris), `ZHUI_PACK_NB_O01`, `ZHUI_PACK_NB_I01`, `ZHUI_PACK_OL_F01` (±2.900 baris), `ZHUI_PACK_PC_*220`.
- Mode ditentukan `SY-TCODE`: `ZHU5SO`/`ZHU5SOR` = packing untuk **Sales Order**; `ZHU5FS`/`ZHU5FSR` = packing **Free Stock** (`F_PROCESS_FREESTOCK`).
- Alur SO: baca SO dari packing instruction (`F_READ_SONUM` / `F_READ_SONUM_IN_PINS`) → cek batch (`F_CHECK_BATCH`) → buat HU → pack batch ke HU → update tabel packing.

| FM / BAPI | Dipakai di FORM | Fungsi |
|---|---|---|
| BDC transaksi `HU02` | `HU_CREATE_BY_BDC` (OL_F01) | Buat Handling Unit (pallet). `BAPI_HU_CREATE` ada di source tetapi **dikomentari** |
| `BAPI_HU_PACK` | `HU_PACKING` (OL_F01) | Masukkan batch ke HU |
| `BAPI_HU_UNPACK`, `BAPI_HU_DELETE` | `HU_UNPACKING` (OL_F01) | Bongkar / hapus HU |
| `HU_CREATE_GOODS_MOVEMENT` | `F_MOVE_SLOC_BAPI` (NB_F01) | Pindah SLoc HU |
| `BAPI_HU_CHANGE_HEADER`, `BAPI_HU_GETLIST`, `BAPI_HU_PROCESS_MSG_DIRECT` | beberapa | Ubah header, baca, output label |
| `ENQUEUE_EZPACK` / `ENQUEUE_EZPACK_PCL` | `F_REFRESH` | Lock packing instruction |
| `ZFM_LOG_PK` | – | Log packing |

| Tabel Z | Arti (DD02T) | Field kunci |
|---|---|---|
| `ZPACK_PCH` | Packing Instruction Header | `PINNR`; `VBELN`, `POSNR` (SO item), `PINST`, `MATNR`, `WERKS`, `LGORT`, `LOEVR` |
| `ZPACK_PCL` | Pack Table (baris HU) | `PINNR`, `HUSEQ`; `VENUM` (HU), `HUSTAT`, `PRSTAT`, `PACKED`, `MEINS`, `PACKING_STATION`, `SLOC_UP` |
| `ZPACK_PC` | Packing instruction by sales order item | – |
| `ZPACK_PCL_LOG` | Log table for packing process | – |
| `ZPALLETR`, `ZHU_MAPP`, `ZPACK00` | Pallet, mapping HU, field layar | – |

### Temuan teknis pembuatan HU (penting untuk desain ulang)

- HU dibuat dengan BDC `HU02`, lalu nomor HU **ditebak** dari `NUMBER_RANGE_GET_BUFFERED` (`HU_VEKP`, `NRIV-NRLEVEL`).
- Setelah itu program menunggu dengan `WHILE RETURN = '' ... SELECT SINGLE EXIDV FROM VEKP ... ENDWHILE` — **tanpa batas waktu**. Jika HU tidak terbentuk, loop tidak berhenti.
- `BAPI_HU_PACK` mengisi `ITEMPROPOSAL`: `HU_ITEM_TYPE`, `MATERIAL`, `PACK_QTY`, `BASE_UNIT_QTY` (`ROL`/`PAK`), `BATCH`, `PLANT`, `STGE_LOC`, `SPEC_STOCK = 'E'` + `SP_STCK_NO` (stok SO).
- Untuk enhancement baru disarankan `BAPI_HU_CREATE` (mengembalikan nomor HU pasti) + `BAPI_HU_PACK`, dengan batas waktu/percobaan bila perlu menunggu.

## 4. Titik Integrasi untuk Enhancement (Day 14)

- Packing logis dilakukan **setelah** batch SR terbentuk dan dialokasikan (step 9 GR SR, step 14 `FREE_TO_SO`), **sebelum** `TECO`.
- Mode packing mengikuti hasil alokasi: batch ke SO → logika ZHU5SO (butuh packing instruction SO di `ZPACK_PCH`); tetap free stock → logika ZHU5FS.
- Cancel slitting harus **unpack/hapus HU dulu** sebelum membatalkan GR SR, kalau tidak pembatalan GR gagal (stok sudah di HU).

> Catatan verifikasi: rincian parameter BAPI dan isi field wajib dicek ulang dengan `read_function_module` dan source FORM terkait sebelum coding.
