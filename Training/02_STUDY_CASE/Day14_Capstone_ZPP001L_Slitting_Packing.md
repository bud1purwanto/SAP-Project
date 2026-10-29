# Day 14 — Capstone: ZPP001L Slitting One Button + Packing (ZHU5SO / ZHU5FS)

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★★★ | PP / MM / SD / ABAP | `sandbox-new` (write) + `prod` (read-only) | 5–6 jam | abap-dev-sandbox-new, pp-analisa-production, mm-analisa-production |

## Tujuan

Menggabungkan seluruh materi Day 1–13 dalam satu enhancement nyata:

```
Analisa program existing -> FS -> Desain teknis -> Coding (copy di Sandbox) -> Test skenario -> Review -> Presentasi
```

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D14` (salinan `ZPPI_SR_EXEC` di Sandbox) dengan **step baru PACKING** setelah slitting, plus pembongkaran packing saat Cancel |
| 2 | Flow A (slitting → alokasi SO/free stock → packing → TECO) + Flow B (step 1–15 + step packing, guard, kompensasi) |
| 3 | FS singkat, hasil test T1–T8, presentasi 10 menit |

## Cerita Kasus

Saat ini operator Laminator menjalankan **dua transaksi terpisah**:

1. `ZPP001L` (`ZPPI_SR_EXEC`) — *Slitting One Button*: satu klik membuat order SR, release, batch, GI JR, GR SR, confirmation, sales order/alokasi, dan TECO.
2. `ZHU5SO` / `ZHU5FS` (`ZHUI_PACK_PC`) — *Packing*: memasukkan roll SR ke pallet (Handling Unit) sesuai **packing instruction** (`ZHU4SO`/`ZHU4FS`), untuk stok **Sales Order** atau **Free Stock**.

Akibatnya: double input, roll lupa di-packing, dan ketika slitting dibatalkan, roll yang sudah di-pallet membuat pembatalan GR gagal.
Manager Produksi meminta: **setelah slitting sukses, packing otomatis dalam tombol yang sama**, dan **Cancel ikut membongkar packing**.

Anda membangun **prototipe** di Sandbox — program asli tidak diubah.

## Konsep Kunci

**Alur ZPP001L sekarang** (dari analisa source, lihat referensi):

| # | FORM | Inti |
|---|---|---|
| 1–2 | `VALIDATE_POPUP`, `SET_NUMBERING` | Validasi input, penomoran batch SR |
| 3–5 | `CREATE_PRO_ORIGINAL`, `CREATE_PRO_COMBINE`, `RELEASE_ORDERS` | Order SR + release |
| 6–7 | `CREATE_BATCH`, `CHANGE_BATCH` | Batch SR + karakteristik |
| 8–10 | `GOODS_ISSUE`, `GOODS_RECEIPT`, `CHANGE_BATCH_INPUTAN` | GI JR, GR SR, update JR |
| 11 | `CREATE_CONFIRMATION` | Confirmation |
| 12–14 | `CREATE_SO`, `CHANGE_SO`, `FREE_TO_SO` | Sales order & alokasi stok |
| **15 baru** | **`PACKING`** | **Pack batch SR ke HU sesuai packing instruction** |
| 16 | `TECO` | TECO order |

**Logika packing (ZHU5SO/ZHU5FS):**

| Hal | SO (`ZHU5SO`) | Free Stock (`ZHU5FS`) |
|---|---|---|
| Kapan | Batch SR dialokasikan ke sales order (stok khusus `E`) | Batch tetap free stock |
| Packing instruction | `ZPACK_PCH` by `VBELN` + `POSNR` | Instruction free stock (pelajari `F_PROCESS_FREESTOCK`) |
| Isi HU | `BAPI_HU_PACK` dengan `SPEC_STOCK = 'E'`, `SP_STCK_NO` | `BAPI_HU_PACK` tanpa stok SO |
| Catatan packing | `ZPACK_PCL` (`PINNR`, `HUSEQ`, `VENUM`, `HUSTAT`, `PACKED`) | sama |
| Lock | `ENQUEUE_EZPACK` / `ENQUEUE_EZPACK_PCL` | sama |

**Temuan teknis yang harus diperbaiki di desain baru:**
- HU saat ini dibuat lewat **BDC `HU02`**, nomor HU **ditebak** dari number range, lalu menunggu dengan loop `WHILE ... SELECT VEKP ... ENDWHILE` **tanpa batas waktu**. Desain baru: `BAPI_HU_CREATE` (nomor HU pasti) atau loop dengan batas percobaan + timeout.
- Setiap step slitting commit sendiri (multi-LUW). Packing adalah step ke-15: jika gagal, **slitting tidak dibatalkan** — tandai status "Slitting OK, Packing gagal" agar bisa diulang via `ZHU5SO/FS` (keputusan desain yang harus dibahas dengan bisnis).
- **Cancel**: sebelum `BAPI_GOODSMVT_CANCEL` GR SR, unpack (`BAPI_HU_UNPACK`) dan hapus HU kosong (`BAPI_HU_DELETE`), update `ZPACK_PCL`.

## Spesifikasi Program `ZTRN_<INISIAL>_D14`

| Bagian | Isi |
|---|---|
| Basis | Copy `ZPPI_SR_EXEC` → `ZTRN_<INISIAL>_D14` di `SE38` **Sandbox** (sertakan screen 100/2000, GUI status, text elements), package `$TMP` |
| Step baru | `FORM PACKING` dipanggil setelah `FREE_TO_SO`, sebelum `TECO` (hanya untuk baris tanpa error) |
| Penentuan mode | Batch SR berstok SO (`MSKA` / hasil `FREE_TO_SO`) → mode SO; selain itu → mode FS |
| Guard | Batch sudah ada di HU (`VEPO` / `ZPACK_PCL`) → lewati; packing instruction tidak ada → lewati + peringatan (slitting tetap sukses) |
| Proses | Lock packing instruction → buat HU (`BAPI_HU_CREATE`) → `BAPI_HU_PACK` per batch → commit → update `ZPACK_PCL` (tabel Z) → unlock |
| Kompensasi | Pack gagal setelah HU dibuat → `BAPI_HU_DELETE` HU kosong; catat status packing gagal |
| Cancel | Di `PROCESS_CANCEL`, sebelum cancel GR SR: `BAPI_HU_UNPACK` + `BAPI_HU_DELETE`, reset `ZPACK_PCL` |
| Output | Kolom baru di ALV hasil: No HU, Status packing (OK / Dilewati / Gagal + pesan) |
| Batasan | Program asli `ZPPI_SR_EXEC` dan `ZHUI_PACK_PC` **tidak** diubah |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | JR → slitting (ZPP001L) → batch SR → alokasi SO / free stock → packing ke pallet sesuai packing instruction → label → TECO; cabang Cancel: unpack → batal slitting |
| B — Program | Step 1–14 (ringkas) → step 15 PACKING: mode SO/FS? → guard (sudah di HU? instruction ada?) → lock → create HU → pack → error? → hapus HU kosong + status gagal / commit + update ZPACK_PCL → TECO; Cancel: unpack → delete HU → cancel GR |

Ikuti [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md). Flow dibuat di fase desain, **sebelum** coding.

## Langkah Kerja

**Fase 1 — Analisa (60 menit).**
```
Baca 05_REFERENSI/ZPP001L_PACKING/ANALISA_ZPP001L_DAN_ZHU5SO_FS.md.
Server sandbox-new (read-only dulu): read_program ZPPI_SR_EXEC, fokus FORM FREE_TO_SO, TECO, PROCESS_CANCEL, CHECK_ERROR.
Lalu read_program ZHUI_PACK_OL_F01 (FORM HU_PACKING, HU_UNPACKING) dan ZHUI_PACK_NB_F01 (F_PROCESS_FREESTOCK, F_READ_SONUM).
Jelaskan: data apa yang dibutuhkan packing, dari mana didapat di ZPPI_SR_EXEC (ITAB), dan tabel Z apa yang diupdate.
```
Bandingkan juga dengan data nyata (read-only) di Production: 1 batch SR hasil `ZPP001L` → apakah sudah di HU (`VEPO`) dan baris `ZPACK_PCL`-nya.

**Fase 2 — FS & desain (60 menit).**
```
Buat Functional Spec singkat (03_TEMPLATE/Template_FS_Singkat.md) untuk "ZPP001L + Packing".
Sertakan keputusan desain: jika packing gagal, slitting tetap sukses atau dibatalkan? Beri rekomendasi + alasan.
Lalu desain teknis: FORM baru, data dari ITAB, BAPI, urutan commit, lock, kompensasi, perubahan PROCESS_CANCEL.
```
Buat Flow A & B di fase ini.

**Fase 3 — Copy & coding (120 menit).**
1. SAP GUI Sandbox → `SE38` → Copy `ZPPI_SR_EXEC` → `ZTRN_<INISIAL>_D14` (centang semua sub-objek), package `$TMP`.
2. Verifikasi salinan berjalan sama seperti `ZPP001L` sebelum diubah.
3. Tambahkan step PACKING secara **minimal diff**.
```
Pakai skill abap-dev-sandbox-new. Ini source ZTRN_<INISIAL>_D14 (read_program sandbox-new) dan desain saya: <tempel>.
Tambahkan FORM PACKING + PERFORM-nya setelah FREE_TO_SO, dan unpack di PROCESS_CANCEL. Minimal diff.
Tampilkan diff sebelum push. Jangan menulis ke program asli.
```

**Fase 4 — Test (60 menit).**

| # | Skenario | Hasil diharapkan |
|---|---|---|
| T1 | Slitting batch untuk SO yang punya packing instruction | Slitting sukses + HU terbentuk + `ZPACK_PCL` terisi, status packing OK |
| T2 | Slitting free stock dengan instruction FS | HU terbentuk (mode FS) |
| T3 | Tidak ada packing instruction | Slitting sukses, packing "Dilewati" + peringatan |
| T4 | Batch sudah ada di HU | Guard melewati, tidak ada HU ganda |
| T5 | Paksa error di `BAPI_HU_PACK` | HU kosong dihapus, status "Gagal", slitting tetap tercatat |
| T6 | Cancel slitting hasil T1 | HU di-unpack & dihapus, lalu GR SR batal sukses |
| T7 | Cancel dua kali | Langkah yang sudah batal dilewati |
| T8 | Dua user packing instruction sama bersamaan | Lock menolak user kedua |

**Fase 5 — Review & presentasi (30 menit).**
```
Review ZTRN_<INISIAL>_D14: (1) ada jalur yang bisa membuat HU ganda? (2) ada step commit yang tidak dikompensasi?
(3) loop tunggu tanpa batas? (4) sintaks 7.31? (5) diff hanya di area yang diminta?
```
Presentasi 10 menit: masalah (2 transaksi terpisah), solusi, hasil test, risiko, langkah berikutnya (Dev → QA → Production via transport resmi oleh tim ABAP).

## Checklist Selesai

- [ ] FS + desain teknis tertulis, keputusan "packing gagal" dibahas.
- [ ] Flow A & B selesai dan cocok dengan kode.
- [ ] Program asli tidak tersentuh; perubahan hanya di `ZTRN_<INISIAL>_D14` di Sandbox.
- [ ] 8 skenario test terdokumentasi.
- [ ] Presentasi siap.

## Rubrik Penilaian Mandiri

| Aspek | Bobot | 1 (kurang) | 3 (cukup) | 5 (baik) |
|---|---|---|---|---|
| Pemahaman proses | 20% | Hanya tahu tombol | Paham alur slitting & packing | Paham data, tabel, dan titik integrasi |
| Desain | 20% | Packing ditempel tanpa guard | Guard atau kompensasi | Guard + kompensasi + cancel + lock |
| Kode | 25% | Error / sintaks 7.40 | Jalan, diff besar | Minimal diff, 7.31, `RETURN` dicek, tanpa loop tanpa batas |
| Testing | 20% | < 4 skenario | 5–6 skenario | 8 skenario + bukti dokumen |
| Komunikasi | 15% | Teknis saja | Jelas | Jelas untuk manajemen & teknis |

## Kuis

1. Mengapa packing ditempatkan setelah `FREE_TO_SO` dan sebelum `TECO`?
2. Apa yang terjadi jika slitting dibatalkan tanpa unpack HU lebih dulu?
3. Apa risiko loop `WHILE ... SELECT ... ENDWHILE` tanpa batas, dan bagaimana memperbaikinya?
4. Mengapa prototipe dibuat dengan menyalin program, bukan mengubah `ZPPI_SR_EXEC` langsung?

<details>
<summary>Kunci jawaban</summary>

1. Packing butuh batch SR sudah ada (setelah GR) dan sudah dialokasikan (SO atau free stock) untuk menentukan mode & stok khusus; TECO menutup order sehingga sebaiknya terakhir.
2. Stok batch berada di dalam HU, sehingga `BAPI_GOODSMVT_CANCEL` GR SR gagal / stok tidak konsisten dengan HU.
3. Bila data yang ditunggu tidak pernah muncul, program berjalan terus (work process tertahan, user tidak bisa keluar). Gunakan batas percobaan + `WAIT UP TO n SECONDS`, atau BAPI yang langsung mengembalikan nomor HU.
4. Aturan: perubahan program hanya di Sandbox; salinan menjaga program produksi tetap utuh dan memudahkan perbandingan (diff) sebelum diusulkan resmi.

Potongan kode acuan — pack satu batch ke HU (pola dari `ZHUI_PACK_PC`):

```abap
DATA: ls_item TYPE bapihuitmproposal,
      ls_huit TYPE bapihuitem,
      ls_huhd TYPE bapihuheader,
      lt_ret  TYPE STANDARD TABLE OF bapiret2,
      ls_ret  TYPE bapiret2.

CLEAR ls_item.
ls_item-hu_item_type      = '1'.            " 1 = material
ls_item-material          = gs_itab-matnr_s.
ls_item-pack_qty          = '1'.
ls_item-base_unit_qty     = 'ROL'.
ls_item-base_unit_qty_iso = 'ROL'.
ls_item-batch             = gs_itab-charg_s.
ls_item-plant             = gs_itab-werks.
ls_item-stge_loc          = gs_itab-lgort_s.
IF gv_mode = 'SO'.
  ls_item-spec_stock      = 'E'.            " stok sales order
  ls_item-sp_stck_no      = gv_sonum.       " SO + item (format seperti ZHUI_PACK_PC)
ENDIF.

CALL FUNCTION 'BAPI_HU_PACK'
  EXPORTING
    hukey        = gv_hukey
    itemproposal = ls_item
  IMPORTING
    huitem       = ls_huit
    huheader     = ls_huhd
  TABLES
    return       = lt_ret.

LOOP AT lt_ret INTO ls_ret WHERE type CA 'EA'.
  EXIT.
ENDLOOP.
IF sy-subrc = 0.
  CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  PERFORM delete_empty_hu USING gv_hukey.     " kompensasi
  gs_itab-pack_stat = 'Gagal'.
ELSE.
  CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
    EXPORTING
      wait = 'X'.
  gs_itab-pack_stat = 'OK'.
ENDIF.
```

Tipe yang dipakai `ZHUI_PACK_PC`: `BAPIHUITMPROPOSAL`, `BAPIHUITEM`, `BAPIHUHEADER`, nomor HU `BAPIHUKEY-HU_EXID`; `HU_ITEM_TYPE = '1'` (material) dan `'3'` (HU di dalam HU). Format `SP_STCK_NO` ikuti `ZHUI_PACK_PC`.
</details>

## Referensi

- [ANALISA_ZPP001L_DAN_ZHU5SO_FS.md](../05_REFERENSI/ZPP001L_PACKING/ANALISA_ZPP001L_DAN_ZHU5SO_FS.md) — struktur ZPP001L & packing.
- [Day 13](Day13_Transaksi_Process_Order_End_to_End.md) — pola langkah, guard, kompensasi.
- [Day 09](Day09_Aplikasi_Z_Tabel_Lock_Log.md) — lock & log.
- [Template_FS_Singkat.md](../03_TEMPLATE/Template_FS_Singkat.md), [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
