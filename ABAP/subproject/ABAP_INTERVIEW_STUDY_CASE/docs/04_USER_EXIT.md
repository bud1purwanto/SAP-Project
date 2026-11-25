# 04 — User Exit (validasi VA01 / VA02)

> Basis kasus: program standar Sales Order `SAPMV45A` (VA01/VA02/VA03).
>
> **Koreksi 25 Nov 2026 (setelah uji):** versi awal dokumen ini menyebut `MV45AFZZ`/`MV45AFZB` di DEV kosong. Itu **salah**. Include-nya memang hanya berisi FORM kosong, tetapi kode custom dipasang sebagai **implicit enhancement** di awal tiap FORM, dan `read_program` biasa tidak menampilkannya. Pengecekan lewat tabel `ENHINCINX` dan `CL_ENH_TOOL_HOOK_IMPL` menemukan 8 enhancement aktif di DEV (dan juga di sandbox-new, dengan sebagian isi berbeda).
>
> Snapshot DEV: [../outputs/dev_src/enh/](../outputs/dev_src/enh/) dan include kosong [../outputs/dev_src/MV45AFZZ.abap](../outputs/dev_src/MV45AFZZ.abap), [../outputs/dev_src/MV45AFZB.abap](../outputs/dev_src/MV45AFZB.abap).

## 1. Konsep singkat (untuk interview)

**User exit** (istilah SD) = FORM kosong yang SAP sediakan di include khusus (`MV45AFZZ`, `MV45AFZB`, `RV60AFZZ`, ...). Developer mengisi kode di FORM itu. Ada dua cara:

| Cara | Objek yang berubah | Access key | Terlihat di |
|---|---|---|---|
| **Modifikasi** langsung di include `MV45AFZZ` | Include SAP (objek SAP) | Perlu (SSCR) | Source include, SPAU saat upgrade |
| **Implicit enhancement** di awal/akhir FORM | Enhancement implementation (ENHO) terpisah | Tidak perlu | SE80 → *Enhance* / tombol spiral; **tidak** ikut terbaca oleh `READ REPORT` |

Di sistem kita (DEV dan sandbox) dipakai **cara kedua**. Ini poin interview yang bagus: "user exit di tempat kami diimplementasikan lewat implicit enhancement, bukan modifikasi, jadi tidak butuh access key."

Kode user exit berjalan di dalam `SAPMV45A`, jadi bisa langsung membaca semua data global dokumen: `VBAK`, `VBAP`, `VBKD`, `XVBAP` (tabel item), `XVBEP`, `XVBPA`, `XVBUP`, `RV45A`, `T180` (mode transaksi), `FCODE`, dll.

Beda dengan **customer exit** (SMOD/CMOD): FM `EXIT_<program>_<nnn>` memanggil include `ZX...`; data hanya lewat parameter. Di DEV tidak ada project CMOD untuk sales order (`V45A*`); yang ada untuk shipment (`V54B0001`, `V56*`) dan billing (`V60P0001`).

User exit penting di `SAPMV45A`:

| Include / FORM | Kapan dipanggil | Contoh pemakaian |
|---|---|---|
| `MV45AFZZ` `USEREXIT_FIELD_MODIFICATION` | Setiap PBO, per field layar | Field jadi display-only / wajib / tersembunyi |
| `MV45AFZZ` `USEREXIT_MOVE_FIELD_TO_VBAK` / `_VBAP` | Saat data header/item diisi | Isi default field (termasuk field Z) |
| `MV45AFZZ` `USEREXIT_SAVE_DOCUMENT_PREPARE` | Sebelum simpan, dokumen masih bisa dibatalkan | **Validasi akhir sebelum save** |
| `MV45AFZZ` `USEREXIT_SAVE_DOCUMENT` | Saat simpan | Simpan ke tabel Z, teks, bersih-bersih — **jangan** kirim pesan error |
| `MV45AFZB` `USEREXIT_CHECK_VBAK` | Pengecekan header | Validasi header |
| `MV45AFZB` `USEREXIT_CHECK_VBAP` | Pengecekan item | Validasi / default item saat item diinput |
| `MV45AFZZ` `USEREXIT_PRICING_PREPARE_TKOMK` | Persiapan pricing header | Isi field komunikasi pricing |

Mode transaksi: `T180-TRTYP` — `H` = create (VA01), `V` = change (VA02), `A` = display (VA03). Lebih aman daripada cek `SY-TCODE`.

## 2. Analisa: enhancement user exit yang ada di DEV

| Enhancement | FORM (hook) | Isi utama |
|---|---|---|
| `ZZMODIF_FIELD` | `USEREXIT_FIELD_MODIFICATION` | William 2012: Plant/SLoc item bisa diedit jika item belum selesai (`XVBUP-GBSTA <> 'C'`); Yulius: field order qty (`RV45A-KWMENG`) dikunci. Kecuali VA03/VA23/ZVA03A |
| `ZSDE_MV45AFZZ_H` | `USEREXIT_MOVE_FIELD_TO_VBAP` | Kode lama (cost center sample order) sudah di-comment |
| `ZCOBL` | `USEREXIT_MOVE_FIELD_TO_COBL` | `BREAK-POINT` untuk user `PST_BANDI` (sisa debug — contoh yang **sebaiknya dihapus**) |
| `ZSDE_MV45AFZB_002` | `USEREXIT_CHECK_VBAK` | PST_MONICA 2012: one-time customer hanya untuk sample order (ZDSO/ZESO); validasi currency SO |
| `ZSDE_MV45AFZB` | `USEREXIT_CHECK_VBAP` | **J. Budi 27.04.2023: "Automatic add Line & Date to VBAP"** — jika `VBAP-ZDATE` kosong diisi dari `RV45A-ETDAT` (atau tanggal schedule line quotation referensi); jika `VBAP-ZLINE` kosong diambil dari `ZMAP_PRODLINE` (BUKRS + MATNR), tidak ada mapping → error. Plus validasi lama: UoM third party hanya KG, sales unit, PO line item ganda, requirement type trading |
| `ZSDE_MV45AFZZ_03` | `USEREXIT_SAVE_DOCUMENT_PREPARE` | **J. Budi x Ryanhr 04.2023: "Validasi Tab Prod Line"** (detail di bawah). Plus: konsistensi qty order (Yulius 2016), requirement type third party, unit price < VPRS (warning) |
| `ZSDE_MV45AFZZ_04` | `USEREXIT_SAVE_DOCUMENT` | PST_MONICA 2012: salin `VBAK-KTEXT` ke header text Z101 untuk quotation ZEQT; **bersihkan parameter ID `ZDATE`/`ZLINE`** (SAP memory milik BAdI tab Additional Screen) |
| `ZSDE_MV45AFZZ_07` | `USEREXIT_PRICING_PREPARE_TKOMK` | Kosong |

### 2.1 Alur field Production Date / Line (BAdI + user exit bekerja bersama)

```
Item diinput (VA01/VA02/BAPI)
  USEREXIT_CHECK_VBAP  (ZSDE_MV45AFZB)
     material terpetakan -> ZDATE kosong? isi dari tanggal delivery / quotation
                          ZLINE kosong? isi dari ZMAP_PRODLINE, tidak ada -> error
Tab "Additional Screen" (BAdI BADI_SLS_ITEM_SCR_CUS, lihat 03_BADI.md)
     user bisa ubah ZDATE / ZLINE
Save
  USEREXIT_SAVE_DOCUMENT_PREPARE  (ZSDE_MV45AFZZ_03, "Validasi Tab Prod Line")
     LOOP AT XVBAP WHERE UPDKZ <> 'D'
       - kapan field dibersihkan (CLEAR XVBAP-ZDATE, XVBAP-ZLINE, bukan error):
           DEV     : material grup 3* tetapi kode material tidak diawali 'SR'
           sandbox : material TIDAK terpetakan (V_MAP kosong) = grup bukan 3*,
                     atau price control S2, atau material SR....X
       - DEV: order type ZDOR/ZEOR/... + grup 3* + ZDATE & ZLINE kosong -> 'Tanggal dan Line produksi harus diisi'
       - ZLINE harus ada di nilai karakteristik ZZPRODLINE -> 'Line produksi tidak sesuai'
       - ZDATE tanpa ZLINE / ZLINE tanpa ZDATE -> error
       - DATE_CHECK_PLAUSIBILITY -> 'Tanggal tidak valid'
  USEREXIT_SAVE_DOCUMENT  (ZSDE_MV45AFZZ_04)
     SET PARAMETER ID 'ZDATE'/'ZLINE' FIELD SPACE   (bersihkan SAP memory BAdI)
```

Dibuktikan saat uji di sandbox-new (25 Nov 2026): SO latihan 5683 dibuat lewat BAPI dengan EXTENSIONIN `ZDATE`/`ZLINE` untuk material `RPP-MZ` (grup B00501, bukan 3*). SO tersimpan tetapi `ZDATE`/`ZLINE` **kosong**, karena dibersihkan oleh `ZSDE_MV45AFZZ_03` (logika versi sandbox). Hal yang sama terjadi lewat `BAPI_SALESORDER_CHANGE`. Ini bukti nyata bahwa **user exit VA01 juga jalan saat SO dibuat lewat BAPI**.

### 2.2 Catatan desain (bahan diskusi interview)

- DEV memakai `MESSAGE ... TYPE 'E'` langsung di `USEREXIT_SAVE_DOCUMENT_PREPARE`. Di dialog VA01 ini berfungsi (save dibatalkan, user kembali ke layar). Di BAPI, pesan E masuk ke tabel RETURN dan dokumen tidak tersimpan.
- Pola alternatif yang sering dipakai untuk kembali ke layar tertentu tanpa pesan E (lihat 3.2): `FOLGE_GLEICHSETZEN` + `FCODE = 'ENT1'` + `SET SCREEN` + `LEAVE SCREEN`.
- Logika "Production Line" tersebar di 3 tempat: BAdI (layar), `CHECK_VBAP` (default), `SAVE_DOCUMENT_PREPARE` (validasi/clear). Saat debugging, ketiganya harus dilihat bersama.
- `BREAK-POINT` per user di `ZCOBL` sebaiknya dihapus (kalau terbawa ke QAS/PRD, extended check/ATC akan menandainya).
- Isi enhancement DEV dan sandbox-new **berbeda** untuk 5 dari 8 enhancement (`ZSDE_MV45AFZB`, `_ZZ_03`, `_ZZ_04`, `_ZZ_07`, `_ZZ_H`). Sandbox punya logika `V_MAP` yang lebih baru (pengecualian price control S2 dan material SR....X).

## 3. Study case

**Tujuan:** memahami user exit lewat kode yang sudah ada, lalu menambah 2 validasi latihan.
**Tempat:** `sandbox-new` (TRS 130). **Peringatan:** enhancement di `SAPMV45A` berlaku untuk semua user VA01/VA02 di client itu. Error sintaks membuat VA01/VA02/VA03 dump untuk semua orang. Selalu cek sintaks (Ctrl+F2) sebelum aktivasi, dan beri tahu pengguna sandbox lain.

### 3.1 Latihan baca (tanpa ubah apa pun)
1. SE80 → Program `SAPMV45A` → include `MV45AFZZ` → FORM `USEREXIT_SAVE_DOCUMENT_PREPARE`.
2. Tekan tombol *Enhance* (spiral) / menu *Edit → Enhancement Operations → Show Implicit Enhancement Options*: terlihat blok `ENHANCEMENT 1 ZSDE_MV45AFZZ_03`.
3. Pasang breakpoint di blok "Validasi Tab Prod Line", buat SO di VA01 (material SR grup 3*), isi tab Additional Screen, Save. Amati `XVBAP-ZDATE/ZLINE` dan `V_MAP`.
4. Ulangi dengan material grup bukan 3* (mis. `RPP-MZ` di sandbox): amati field dibersihkan.

### 3.2 Latihan tulis — 2 validasi baru

| # | Aturan bisnis (latihan) | Mode | Lokasi | Kenapa di sini |
|---|---|---|---|---|
| V1 | Requested delivery date header (`VBAK-VDATU`) tidak boleh di masa lalu | Create saja | `USEREXIT_CHECK_VBAK` | Langsung ditolak saat header diisi |
| V2 | PO number customer (`VBKD-BSTKD`) wajib untuk order type latihan | Create & change | `USEREXIT_SAVE_DOCUMENT_PREPARE` | Field bisa diisi di mana saja sebelum save |

Validasi Production Line **tidak perlu dibuat lagi** karena sudah ada (`ZSDE_MV45AFZZ_03`).

Buat sebagai implicit enhancement **baru** (mis. `ZTRN_MV45AFZB_V1`, `ZTRN_MV45AFZZ_V2`), jangan menyisipkan kode di enhancement yang sudah ada. Untuk tidak mengganggu user lain, batasi dengan user Anda sendiri selama latihan (`CHECK sy-uname = '<USER_ANDA>'.`) dan nonaktifkan/hapus setelah selesai.

```abap
* V1 - di awal FORM userexit_check_vbak (MV45AFZB)
  IF t180-trtyp = 'H'
     AND vbak-vdatu IS NOT INITIAL
     AND vbak-vdatu < sy-datum.
    MESSAGE e398(00) WITH 'Req. delivery date' vbak-vdatu
                          'tidak boleh sebelum hari ini' space.
  ENDIF.
```

```abap
* V2 - di awal FORM userexit_save_document_prepare (MV45AFZZ)
  DATA: lv_msg(100) TYPE c.
  IF ( t180-trtyp = 'H' OR t180-trtyp = 'V' )
     AND vbak-auart = 'ZDOR' AND vbkd-bstkd IS INITIAL.
    lv_msg = 'PO number customer wajib diisi untuk order type ZDOR'.
    MESSAGE lv_msg TYPE 'I' DISPLAY LIKE 'E'.
    PERFORM folge_gleichsetzen(saplv00f).
    fcode = 'ENT1'.
    SET SCREEN sy-dynnr.
    LEAVE SCREEN.
  ENDIF.
```

Bandingkan V2 dengan gaya DEV (`MESSAGE ... TYPE 'E'` langsung) dan catat bedanya saat diuji dari VA01 dan dari BAPI (`ZTRAIN_BAPI_SO`).

> Kode V1/V2 sudah lolos syntax check di sandbox-new memakai program mock `ZTRAIN_UEXIT_MOCK` (deklarasi `VBAK`, `VBKD`, `T180`, `XVBAP`, `FCODE` meniru `SAPMV45A`). Program mock itu tidak bisa membuktikan perilaku runtime; uji runtime harus lewat VA01.

### 3.3 Skenario uji (sandbox-new)

| No | Transaksi | Langkah | Hasil yang diharapkan |
|---|---|---|---|
| 1 | VA01 | Req. delivery date = kemarin | Error V1 di layar header |
| 2 | VA01 | Req. delivery date = besok | Lolos V1 |
| 3 | VA02 | SO lama dengan req. date sudah lewat, ubah qty | **Tidak** kena V1 (hanya create) |
| 4 | VA01 | ZDOR, PO number kosong, Save | Popup V2, tetap di layar, dokumen belum tersimpan |
| 5 | VA01 | Material SR grup 3*, tab Additional Screen: line `QQ` | Error "Line produksi tidak sesuai" (enhancement yang sudah ada) |
| 6 | VA01 | Material grup bukan 3*, isi ZDATE/ZLINE, Save | Tersimpan, ZDATE/ZLINE dibersihkan |
| 7 | `ZTRAIN_BAPI_SO` | P_TEST kosong, material grup bukan 3* | SO dibuat, ZDATE/ZLINE kosong — **sudah terbukti** (SO 5683) |
| 8 | `ZTRAIN_BAPI_SO` | P_TEST = X | Validasi save **tidak** jalan (test run berhenti sebelum save) — **sudah terbukti** |

## 4. Pertanyaan interview yang mungkin muncul

1. Di mana menaruh validasi sebelum SO disimpan? → `USEREXIT_SAVE_DOCUMENT_PREPARE` (MV45AFZZ).
2. Kenapa tidak di `USEREXIT_SAVE_DOCUMENT`? → sudah di dalam proses simpan; untuk menulis tabel tambahan / bersih-bersih (contoh DEV: clear SAP memory BAdI).
3. Bagaimana tahu mode create/change/display? → `T180-TRTYP` (H/V/A).
4. Bagaimana membaca semua item? → tabel global `XVBAP` (dan `YVBAP` = kondisi sebelum perubahan di VA02).
5. Bagaimana mencari kode user exit yang sudah ada? → SE80 include `MV45AFZZ` + tampilkan implicit enhancement; atau tabel `ENHINCINX` (program `SAPMV45A`); jangan hanya baca source include.
6. Apakah user exit jalan saat BAPI? → ya. Terbukti: BAPI create/change SO di sandbox ikut melewati `ZSDE_MV45AFZZ_03`. Tetapi saat `TESTRUN = 'X'`, save prepare tidak dipanggil.
7. Risiko user exit? → satu include untuk semua sales document type dan semua user → wajib filter `AUART`/`TRTYP`; logika bisa tersebar di banyak FORM; sisa `BREAK-POINT` bisa terbawa.
