# Day 01 — Report Purchase Order Sederhana

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★ | MM / ABAP | `sandbox-new` (write) + `prod` (read-only, verifikasi) | 3 jam | abap-dev-sandbox-new, mm-analisa-production |

## Tujuan

1. Memahami alur **Procure to Pay** dan tabel inti Purchase Order (`EKKO`, `EKPO`).
2. Membuat, push, dan menjalankan **program ABAP pertama** (report + ALV) di Sandbox New Company.
3. Membuat **flow** pertama: flow bisnis PO dan flow logika program.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D01` — daftar PO dengan filter, tampil di ALV |
| 2 | Flow A (Procure to Pay) + Flow B (logika program) dalam Mermaid |
| 3 | Catatan: 3 PO contoh dari output program, dicocokkan dengan `ME23N` |

## Cerita Kasus

Tim Purchasing setiap pagi membuka `ME2N` dengan banyak filter untuk melihat PO yang dibuat minggu ini.
Manager Purchasing meminta report ringkas: **PO apa saja yang dibuat pada periode tertentu, ke vendor siapa, material apa, berapa nilainya**.

## Konsep Kunci

Alur Procure to Pay (P2P):

```
PR (ME51N, EBAN) -> PO (ME21N, EKKO/EKPO) -> Release (ME28/ME29N) -> GR (MIGO 101, MSEG/EKBE) -> Invoice (MIRO, RBKP/RSEG)
```

| Tabel | Isi | Field penting |
|---|---|---|
| `EKKO` | Header PO | `EBELN` no PO, `BSART` doc type, `LIFNR` vendor, `EKORG` purch. org, `BEDAT` tgl PO, `WAERS` currency |
| `EKPO` | Item PO | `EBELP` item, `MATNR`, `TXZ01` teks item, `WERKS`, `MENGE`, `MEINS`, `NETPR`, `NETWR`, `LOEKZ` (hapus) |

- `LOEKZ = 'L'` = item dihapus → tidak ditampilkan.
- ABAP hari ini: `REPORT`, `TABLES`, `TYPES`, `DATA`, `SELECT-OPTIONS`, `SELECTION-SCREEN BLOCK`, `INITIALIZATION`, `START-OF-SELECTION`, `SELECT ... INNER JOIN`, `CL_SALV_TABLE`.

## Spesifikasi Program `ZTRN_<INISIAL>_D01`

| Bagian | Isi |
|---|---|
| Input | `S_BEDAT` (tgl PO, wajib, default bulan berjalan), `S_EBELN`, `S_LIFNR`, `S_BSART`, `S_WERKS` |
| Proses | `EKKO` INNER JOIN `EKPO` pada `EBELN`; item terhapus (`LOEKZ = 'L'`) dibuang; maksimal 1.000 baris |
| Output | ALV: No PO, Item, Doc type, Tgl PO, Vendor, Material, Teks item, Plant, Qty, UoM, Net price, Net value, Currency |
| Fitur ALV | Sort, filter, total `Net value`, export Excel |
| Error | Data kosong → pesan "Data tidak ditemukan" |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | PR → PO → Release → GR → Invoice, dengan TCODE dan tabel di tiap langkah. Tandai bagian yang dibaca report ini. |
| B — Program | Input → validasi → SELECT JOIN → cek data kosong → ALV |

## Langkah dengan AI

**Langkah 1 — pahami data (read-only).**
```
Pakai skill mm-analisa-production. Server prod (read-only).
Baca 5 PO terbaru dari EKKO (EBELN BSART LIFNR EKORG BEDAT) lalu item-nya dari EKPO.
Jelaskan arti setiap field dalam bahasa awam.
```

**Langkah 2 — cek struktur di Sandbox.**
```
Set sandbox-new. read_table_structure EKKO dan EKPO, tampilkan hanya field di spesifikasi saya.
Cek juga apakah sandbox-new punya data PO (baca 5 baris EKKO).
```

**Langkah 3 — minta kode.**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D01 sesuai spesifikasi: <tempel tabel Spesifikasi>.
ABAP 7.31, CL_SALV_TABLE. Jelaskan setiap blok kode untuk pemula.
```

**Langkah 4 — review.**
```
Review kode tadi dengan checklist skill abap-dev-sandbox-new: sintaks 7.31? SELECT * ? sy-subrc dicek? TRY/CATCH ALV?
```

**Langkah 5 — push & jalankan.**
```
Set sandbox-new. Push ZTRN_<INISIAL>_D01 ke package $TMP dengan Z_RFC_PROGRAM_UPDATE.
Tampilkan EV_SUCCESS dan EV_MESSAGE, lalu read_program untuk memastikan jumlah baris sama.
```
SAP GUI Sandbox → `SE38` → `ZTRN_<INISIAL>_D01` → F8. Cocokkan 3 PO dengan `ME23N`.

**Langkah 6 — flow.**
```
Buatkan Flow A (Procure to Pay) dan Flow B (dari kode ZTRN_<INISIAL>_D01) dalam Mermaid.
Ikuti 03_TEMPLATE/Template_Flow_Mermaid.md.
```

## Tugas

1. Program berjalan; lampirkan ringkasan output (jumlah PO, total nilai).
2. Cocokkan 3 PO dengan `ME23N`: nilai sama? Jika tidak, mengapa?
3. Tambahkan sendiri (dengan AI) kolom **nama vendor** (`LFA1-NAME1`). Push ulang.
4. Flow A & B selesai.

## Checklist Selesai

- [ ] Push sukses (`EV_SUCCESS = 'X'`), program berjalan.
- [ ] Bisa menjelaskan beda `EKKO` dan `EKPO`.
- [ ] Bisa menjelaskan setiap blok kode ke orang lain.
- [ ] Flow A & B selesai dan cocok dengan kode.

## Kuis

1. Tabel mana yang menyimpan vendor PO? Mana yang menyimpan material?
2. Apa arti `EKPO-LOEKZ = 'L'`?
3. Mengapa field ditulis eksplisit di SELECT, bukan `SELECT *`?
4. Mengapa program dibuat di Sandbox, tetapi data dicocokkan ke Production?

<details>
<summary>Kunci jawaban</summary>

1. Vendor: `EKKO-LIFNR` (header). Material: `EKPO-MATNR` (item).
2. Item PO sudah ditandai hapus.
3. Mengurangi data yang ditransfer dari database (lebih cepat) dan membuat kode jelas.
4. Perubahan program hanya boleh di Sandbox; Production hanya dibaca.

Kode acuan:

```abap
REPORT ztrn_xx_d01.

TABLES: ekko, ekpo.

TYPES: BEGIN OF ty_out,
         ebeln TYPE ekko-ebeln,
         ebelp TYPE ekpo-ebelp,
         bsart TYPE ekko-bsart,
         bedat TYPE ekko-bedat,
         lifnr TYPE ekko-lifnr,
         matnr TYPE ekpo-matnr,
         txz01 TYPE ekpo-txz01,
         werks TYPE ekpo-werks,
         menge TYPE ekpo-menge,
         meins TYPE ekpo-meins,
         netpr TYPE ekpo-netpr,
         netwr TYPE ekpo-netwr,
         waers TYPE ekko-waers,
       END OF ty_out.

DATA: gt_out TYPE STANDARD TABLE OF ty_out,
      go_alv TYPE REF TO cl_salv_table,
      go_agg TYPE REF TO cl_salv_aggregations,
      go_err TYPE REF TO cx_salv_msg.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE text-b01.
SELECT-OPTIONS: s_bedat FOR ekko-bedat OBLIGATORY,
                s_ebeln FOR ekko-ebeln,
                s_lifnr FOR ekko-lifnr,
                s_bsart FOR ekko-bsart,
                s_werks FOR ekpo-werks.
SELECTION-SCREEN END OF BLOCK b1.

INITIALIZATION.
  " Default: awal bulan s/d hari ini
  s_bedat-sign   = 'I'.
  s_bedat-option = 'BT'.
  s_bedat-low    = sy-datum.
  s_bedat-low+6(2) = '01'.
  s_bedat-high   = sy-datum.
  APPEND s_bedat.

START-OF-SELECTION.
  SELECT a~ebeln b~ebelp a~bsart a~bedat a~lifnr
         b~matnr b~txz01 b~werks b~menge b~meins
         b~netpr b~netwr a~waers
    FROM ekko AS a
    INNER JOIN ekpo AS b ON b~ebeln = a~ebeln
    INTO TABLE gt_out
    UP TO 1000 ROWS
    WHERE a~bedat IN s_bedat
      AND a~ebeln IN s_ebeln
      AND a~lifnr IN s_lifnr
      AND a~bsart IN s_bsart
      AND b~werks IN s_werks
      AND b~loekz = space.            " buang item terhapus
  IF sy-subrc <> 0.
    MESSAGE 'Data tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  SORT gt_out BY ebeln ebelp.

  TRY.
      cl_salv_table=>factory( IMPORTING r_salv_table = go_alv
                              CHANGING  t_table      = gt_out ).
      go_alv->get_functions( )->set_all( abap_true ).
      go_alv->get_columns( )->set_optimize( abap_true ).
      go_agg = go_alv->get_aggregations( ).
      go_agg->add_aggregation( columnname = 'NETWR' ).   " total nilai
      go_alv->display( ).
    CATCH cx_salv_msg INTO go_err.
      MESSAGE go_err TYPE 'I'.
    CATCH cx_salv_not_found cx_salv_data_error cx_salv_existing.
      MESSAGE 'Gagal menyiapkan total ALV' TYPE 'I'.
  ENDTRY.
```

Text element `B01` (judul blok) diisi via SE38 → Goto → Text Elements, contoh "Filter Purchase Order".
</details>

## Referensi

- [Skill mm-analisa-production](../01_SKILLS/mm-analisa-production/SKILL.md)
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
