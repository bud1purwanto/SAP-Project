# Day 02 — Report PO Monitoring (Join + Agregasi + Status)

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★ | MM / ABAP | `sandbox-new` (write) + `prod` (read-only) | 3–4 jam | abap-dev-sandbox-new, mm-analisa-production |

## Tujuan

1. Menggabungkan data dari **banyak tabel**: header, item, vendor, material, dan histori PO.
2. Menghitung **qty diterima & sisa** dari histori (`EKBE`) dengan benar, termasuk pembatalan GR.
3. Membuat ALV yang lebih kaya: **status lampu**, **hotspot ke ME23N**, total.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D02` — PO Monitoring: qty PO vs diterima vs sisa, status Open/Partial/Full, status release |
| 2 | Flow A (status PO dari dibuat sampai diterima penuh) + Flow B (logika program, termasuk penentuan status) |
| 3 | Catatan: 1 PO dengan GR yang pernah dibatalkan — bukti bahwa perhitungan benar |

## Cerita Kasus

Day 01 hanya menunjukkan PO yang dibuat. Manager Purchasing kini bertanya:
*"Dari PO tersebut, mana yang barangnya **belum datang**, mana yang **baru sebagian**, dan mana yang **belum di-release**?"*
Jawabannya ada di histori PO (`EKBE`), yang mencatat setiap GR dan pembatalannya.

## Konsep Kunci

| Tabel | Isi | Field penting |
|---|---|---|
| `EKKO` | Header PO | `EBELN`, `LIFNR`, `BEDAT`, `FRGKE` (release indicator), `FRGZU` (status release) |
| `EKPO` | Item PO | `EBELP`, `MATNR`, `MENGE`, `MEINS`, `NETWR`, `ELIKZ` (delivery completed), `LOEKZ` |
| `LFA1` | Master vendor | `LIFNR`, `NAME1` |
| `MAKT` | Deskripsi material | `MATNR`, `SPRAS`, `MAKTX` |
| `EKBE` | Histori PO | `VGABE` (`1` = GR, `2` = invoice), `SHKZG` (`S` tambah / `H` kurang), `MENGE`, `BELNR`, `BUDAT` |

- **Qty diterima (netto)** = Σ `MENGE` GR dengan `SHKZG = 'S'` − Σ `MENGE` dengan `SHKZG = 'H'` (pembatalan GR / retur).
- **Sisa** = `EKPO-MENGE` − qty diterima.
- Status: `Full` (sisa ≤ 0 atau `ELIKZ = 'X'`), `Partial` (diterima > 0), `Open` (belum ada GR).
- **JOIN vs FOR ALL ENTRIES**: JOIN untuk relasi 1:1 / N:1 yang pasti ada (EKKO–EKPO–LFA1). FOR ALL ENTRIES untuk data pelengkap atau yang perlu diagregasi di ABAP (EKBE, MAKT).
- Di ABAP 7.31, **fungsi agregat (SUM) tidak boleh dipakai bersama FOR ALL ENTRIES** → ambil baris `EKBE`, jumlahkan di ABAP (`COLLECT`).
- ALV: kolom ikon (`ICON_GREEN_LIGHT`, `ICON_YELLOW_LIGHT`, `ICON_RED_LIGHT`), hotspot + event `LINK_CLICK` → `CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN` dengan `SET PARAMETER ID 'BES'`.

## Spesifikasi Program `ZTRN_<INISIAL>_D02`

| Bagian | Isi |
|---|---|
| Input | `S_BEDAT` (wajib), `S_EBELN`, `S_LIFNR`, `S_EKORG`, `S_WERKS`, checkbox `P_OPEN` (hanya yang belum Full) |
| Data 1 | `EKKO` JOIN `EKPO` JOIN `LFA1` (item terhapus dibuang) |
| Data 2 | `MAKT` (bahasa login) dan `EKBE` (`VGABE = '1'`) via FOR ALL ENTRIES |
| Hitung | Qty diterima netto, sisa, % diterima, status (Open/Partial/Full), status release (Released / Belum) dari `FRGKE` |
| Output | ALV: Lampu, No PO (hotspot), Item, Vendor, Nama vendor, Material, Deskripsi, Qty PO, Qty diterima, Sisa, %, Status, Release, Net value |
| Interaksi | Klik No PO → buka `ME23N` |
| Error | Data kosong → pesan; ALV dibungkus `TRY/CATCH` |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | PO dibuat → menunggu release → released → GR sebagian → GR penuh / delivery completed; termasuk cabang **GR dibatalkan** |
| B — Program | Input → JOIN → data kosong? → FAE MAKT & EKBE → COLLECT per item → keputusan status (Open/Partial/Full) → filter `P_OPEN` → ALV → event klik |

## Langkah dengan AI

**Langkah 1 — pahami EKBE (read-only).**
```
Pakai skill mm-analisa-production, server prod. Cari 1 PO yang punya GR dan pembatalan GR
(EKBE VGABE = '1' dengan SHKZG 'S' dan 'H'). Tampilkan baris EKBE-nya dan hitung qty diterima netto.
```

**Langkah 2 — desain dulu, baru kode.**
```
Saya akan membuat ZTRN_<INISIAL>_D02 dengan spesifikasi: <tempel>.
Sebelum menulis kode, jelaskan: tabel mana pakai JOIN, mana pakai FOR ALL ENTRIES, dan alasannya.
Jelaskan juga mengapa SUM tidak dipakai bersama FOR ALL ENTRIES di ABAP 7.31.
```

**Langkah 3 — kode, review, push** (pola Day 01). Minta AI menulis event handler `LINK_CLICK` sebagai local class.

**Langkah 4 — uji.**
- PO tanpa GR → lampu merah, status Open.
- PO dengan GR sebagian → kuning, Partial.
- PO dengan GR lalu dibatalkan → qty diterima kembali berkurang.
- Klik No PO → `ME23N` terbuka di PO yang benar.

**Langkah 5 — flow** (Flow A & B, ikuti template).

## Tugas

1. Program berjalan; 4 skenario uji di atas terdokumentasi.
2. Bandingkan qty diterima program dengan tab *Purchase Order History* di `ME23N` untuk 2 PO.
3. Flow A & B selesai.

## Checklist Selesai

- [ ] Bisa menjelaskan kapan JOIN, kapan FOR ALL ENTRIES.
- [ ] Pembatalan GR (`SHKZG = 'H'`) dihitung benar.
- [ ] Hotspot ke `ME23N` berfungsi.
- [ ] Flow A & B selesai.

## Kuis

1. PO item qty 100. EKBE: GR +60 (S), GR +40 (S), batal −40 (H). Berapa sisa dan statusnya?
2. Mengapa `MAKT` tidak di-JOIN langsung?
3. Apa beda `ELIKZ` dan sisa = 0?

<details>
<summary>Kunci jawaban</summary>

1. Diterima netto 60, sisa 40, status **Partial**.
2. `MAKT` berbasis bahasa; JOIN dengan filter `SPRAS` bisa membuang baris PO tanpa material (item jasa/teks). FAE + READ TABLE lebih aman; atau LEFT OUTER JOIN.
3. `ELIKZ` = user menandai delivery selesai (walau qty kurang); sisa 0 = qty benar-benar diterima penuh. Keduanya dianggap Full.

Potongan kode acuan — agregasi EKBE:

```abap
TYPES: BEGIN OF ty_ekbe,
         ebeln TYPE ekbe-ebeln,
         ebelp TYPE ekbe-ebelp,
         shkzg TYPE ekbe-shkzg,
         menge TYPE ekbe-menge,
       END OF ty_ekbe,
       BEGIN OF ty_gr,
         ebeln TYPE ekbe-ebeln,
         ebelp TYPE ekbe-ebelp,
         menge TYPE ekbe-menge,
       END OF ty_gr.
DATA: gt_ekbe TYPE STANDARD TABLE OF ty_ekbe,
      gs_ekbe TYPE ty_ekbe,
      gt_gr   TYPE STANDARD TABLE OF ty_gr,
      gs_gr   TYPE ty_gr.

IF gt_out IS NOT INITIAL.
  SELECT ebeln ebelp shkzg menge FROM ekbe INTO TABLE gt_ekbe
    FOR ALL ENTRIES IN gt_out
    WHERE ebeln = gt_out-ebeln
      AND ebelp = gt_out-ebelp
      AND vgabe = '1'.                     " 1 = Goods Receipt
ENDIF.

LOOP AT gt_ekbe INTO gs_ekbe.
  CLEAR gs_gr.
  gs_gr-ebeln = gs_ekbe-ebeln.
  gs_gr-ebelp = gs_ekbe-ebelp.
  IF gs_ekbe-shkzg = 'H'.                  " pembatalan / retur
    gs_gr-menge = gs_ekbe-menge * -1.
  ELSE.
    gs_gr-menge = gs_ekbe-menge.
  ENDIF.
  COLLECT gs_gr INTO gt_gr.
ENDLOOP.
SORT gt_gr BY ebeln ebelp.
```

Potongan kode acuan — hotspot ke ME23N:

```abap
CLASS lcl_event DEFINITION.
  PUBLIC SECTION.
    METHODS on_link_click FOR EVENT link_click OF cl_salv_events_table
      IMPORTING row column.
ENDCLASS.

CLASS lcl_event IMPLEMENTATION.
  METHOD on_link_click.
    DATA ls_out TYPE ty_out.
    READ TABLE gt_out INTO ls_out INDEX row.
    IF sy-subrc = 0 AND column = 'EBELN'.
      SET PARAMETER ID 'BES' FIELD ls_out-ebeln.
      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
    ENDIF.
  ENDMETHOD.
ENDCLASS.

" setelah factory:
DATA: go_col    TYPE REF TO cl_salv_column_table,
      go_events TYPE REF TO cl_salv_events_table,
      go_event  TYPE REF TO lcl_event.
go_col ?= go_alv->get_columns( )->get_column( 'EBELN' ).
go_col->set_cell_type( if_salv_c_cell_type=>hotspot ).
go_events = go_alv->get_event( ).
CREATE OBJECT go_event.
SET HANDLER go_event->on_link_click FOR go_events.
```

Catatan: `get_column` dapat melempar `cx_salv_not_found` — tangkap di `TRY/CATCH`.
</details>

## Referensi

- [Skill mm-analisa-production](../01_SKILLS/mm-analisa-production/SKILL.md)
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
