# Day 03 — Program Transaksi: Transfer Posting (BAPI)

| Level | Modul | Server | Durasi | Skill |
|---|---|---|---|---|
| ★★★ | MM / ABAP | `sandbox-new` (write) | 3–4 jam | abap-dev-sandbox-new, mm-analisa-production |

## Tujuan

1. Memahami **transfer posting** antar storage location (movement type **311**) dan dampaknya ke stok.
2. Membuat program yang **mengubah data** dengan cara yang benar: BAPI, test run, commit/rollback, pesan hasil.
3. Memahami kenapa **tidak boleh** `INSERT`/`UPDATE` langsung ke tabel stok (`MSEG`, `MARD`, `MCHB`).

> **Peringatan:** program ini memposting dokumen material. **Hanya dijalankan di `sandbox-new`**. Jangan pernah dijalankan di Production.

## Deliverable

| # | Deliverable |
|---|---|
| 1 | Program `ZTRN_<INISIAL>_D03` — transfer posting 311 satu material/batch dari SLoc asal ke SLoc tujuan, dengan Test Run |
| 2 | Flow A (proses transfer stok di gudang) + Flow B (logika program: validasi → BAPI → commit/rollback) |
| 3 | Bukti: 1 dokumen material hasil posting, dicek di `MB03` dan stok sebelum/sesudah di `MMBE` |

## Cerita Kasus

Gudang memindahkan roll dari lokasi produksi ke lokasi gudang jadi (contoh SLoc `2322` → SLoc lain) dengan `MIGO` (transfer posting 311).
Karena volumenya tinggi, user meminta **program sederhana**: isi material, batch, qty, lokasi asal & tujuan — sekali klik, dengan pengecekan stok dulu.

## Konsep Kunci

| Istilah | Arti |
|---|---|
| Movement type `311` | Transfer posting antar storage location dalam 1 plant. Pembatal: `312` |
| GM code `04` | Kode transaksi BAPI untuk transfer posting |
| `MARD-LABST` | Stok unrestricted per material + plant + SLoc |
| `MCHB-CLABS` | Stok unrestricted per batch |
| `BAPI_GOODSMVT_CREATE` | BAPI standar membuat dokumen material (seperti MIGO) |
| `TESTRUN = 'X'` | Simulasi: BAPI cek semua validasi tanpa posting |

Pola wajib BAPI yang mengubah data:

```
siapkan data -> CALL BAPI -> cek RETURN (TYPE E/A?)
   ├─ ada error -> BAPI_TRANSACTION_ROLLBACK -> tampilkan pesan
   └─ sukses    -> BAPI_TRANSACTION_COMMIT (WAIT = 'X') -> tampilkan no dokumen
```

- Tanggal posting di Sandbox tidak sama dengan kalender nyata — cek dengan FM `GET_SYSTEM_TIME_REMOTE` (`L_DATE`) bila posting ditolak karena periode.
- `AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'` (movement type) sebelum posting.

## Spesifikasi Program `ZTRN_<INISIAL>_D03`

| Bagian | Isi |
|---|---|
| Input | `P_MATNR`, `P_WERKS`, `P_LGORT` (asal), `P_UMLGO` (tujuan), `P_CHARG` (opsional), `P_MENGE`, `P_BUDAT` (default hari ini), `P_BKTXT` (header text), checkbox `P_TEST` (default `X`) |
| Validasi | Semua field wajib terisi; asal ≠ tujuan; qty > 0; stok cukup (`MCHB-CLABS` jika batch, `MARD-LABST` jika tidak); authority check |
| Proses | `BAPI_GOODSMVT_CREATE` GM code `04`, movement `311`, `TESTRUN = P_TEST` |
| Hasil | Test run sukses → "Simulasi OK, siap posting". Posting sukses → commit, tampilkan no dokumen + tahun. Error → rollback, tampilkan semua pesan `RETURN` |
| Output | List/pesan: stok sebelum, hasil BAPI, no dokumen, stok sesudah |

## Flow yang Dibuat

| Flow | Isi minimal |
|---|---|
| A — Bisnis | Operator gudang → transfer 311 → stok SLoc asal berkurang, SLoc tujuan bertambah → dokumen material (`MKPF`/`MSEG`); cabang **koreksi dengan 312** |
| B — Program | Input → validasi (tiap cek = 1 keputusan) → BAPI → test run? → error? → rollback/commit → output |

## Langkah dengan AI

**Langkah 1 — siapkan data uji di Sandbox.**
```
Set sandbox-new. Cari 3 material di plant 2000 yang punya stok unrestricted > 0 di MCHB (atau MARD).
Tampilkan MATNR, WERKS, LGORT, CHARG, CLABS. Cari juga 1 SLoc lain di plant yang sama (T001L) sebagai tujuan.
Cek tanggal sistem dengan GET_SYSTEM_TIME_REMOTE.
```

**Langkah 2 — pahami BAPI.**
```
read_function_module BAPI_GOODSMVT_CREATE di sandbox-new. Jelaskan parameter wajib untuk transfer posting 311
(GOODSMVT_HEADER, GOODSMVT_CODE, GOODSMVT_ITEM: MATERIAL, PLANT, STGE_LOC, BATCH, MOVE_TYPE, ENTRY_QNT,
MOVE_PLANT, MOVE_STLOC, MOVE_BATCH) dan arti TESTRUN.
```

**Langkah 3 — kode.**
```
Pakai skill abap-dev-sandbox-new. Buat ZTRN_<INISIAL>_D03 sesuai spesifikasi: <tempel>. ABAP 7.31.
Wajib: validasi sebelum BAPI, TESTRUN, ROLLBACK jika RETURN berisi E/A, COMMIT WAIT jika sukses.
Beri komentar setiap langkah.
```

**Langkah 4 — review keamanan.**
```
Review kode saya: apakah ada jalur yang memanggil COMMIT walau RETURN berisi error?
Apakah validasi stok dilakukan sebelum BAPI? Apakah ada UPDATE/INSERT langsung ke tabel standar?
```

**Langkah 5 — uji bertahap di Sandbox.**

| # | Skenario | Hasil diharapkan |
|---|---|---|
| T1 | `P_TEST = X`, data benar | "Simulasi OK", tidak ada dokumen |
| T2 | Qty > stok | Ditolak oleh validasi program |
| T3 | SLoc tujuan tidak ada | Error dari BAPI, rollback |
| T4 | `P_TEST` kosong, data benar | Dokumen terbentuk, stok pindah (cek `MMBE`, `MB03`) |

**Langkah 6 — flow** (Flow A & B).

## Tugas

1. Empat skenario uji terdokumentasi (input, hasil, no dokumen bila ada).
2. Bandingkan stok sebelum/sesudah T4 di `MMBE`.
3. Jelaskan dengan kata sendiri: apa yang terjadi jika program memanggil COMMIT walau BAPI error?
4. Flow A & B selesai.

## Checklist Selesai

- [ ] Program hanya dijalankan di `sandbox-new`.
- [ ] Test run berfungsi (tidak membuat dokumen).
- [ ] Error → rollback, sukses → commit + no dokumen.
- [ ] Flow A & B selesai.

## Kuis

1. Movement type untuk transfer antar SLoc dan pembatalnya?
2. Mengapa memakai BAPI, bukan `INSERT` ke `MSEG`?
3. Apa fungsi `WAIT = 'X'` pada `BAPI_TRANSACTION_COMMIT`?
4. Mengapa validasi stok di program tetap berguna padahal BAPI juga memvalidasi?

<details>
<summary>Kunci jawaban</summary>

1. `311`; pembatal `312`.
2. BAPI menjalankan seluruh validasi dan update standar (stok, nilai, akuntansi, dokumen, lock). INSERT langsung merusak konsistensi data dan audit.
3. Menunggu update database selesai sebelum program lanjut, sehingga dokumen langsung bisa dibaca setelahnya.
4. Pesan lebih jelas untuk user dan mencegah panggilan BAPI yang pasti gagal.

Kode acuan (inti):

```abap
REPORT ztrn_xx_d03.

PARAMETERS: p_matnr TYPE mara-matnr OBLIGATORY,
            p_werks TYPE t001w-werks OBLIGATORY DEFAULT '2000',
            p_lgort TYPE mard-lgort OBLIGATORY,
            p_umlgo TYPE mard-lgort OBLIGATORY,
            p_charg TYPE mchb-charg,
            p_menge TYPE ekpo-menge OBLIGATORY,
            p_budat TYPE mkpf-budat OBLIGATORY DEFAULT sy-datum,
            p_bktxt TYPE mkpf-bktxt,
            p_test  AS CHECKBOX DEFAULT 'X'.

DATA: gs_head  TYPE bapi2017_gm_head_01,
      gs_code  TYPE bapi2017_gm_code,
      gt_item  TYPE STANDARD TABLE OF bapi2017_gm_item_create,
      gs_item  TYPE bapi2017_gm_item_create,
      gt_ret   TYPE STANDARD TABLE OF bapiret2,
      gs_ret   TYPE bapiret2,
      gv_mblnr TYPE bapi2017_gm_head_ret-mat_doc,
      gv_mjahr TYPE bapi2017_gm_head_ret-doc_year,
      gv_stok  TYPE mchb-clabs,
      gv_err   TYPE c.

AT SELECTION-SCREEN.
  IF p_lgort = p_umlgo.
    MESSAGE 'SLoc asal dan tujuan tidak boleh sama' TYPE 'E'.
  ENDIF.
  IF p_menge <= 0.
    MESSAGE 'Qty harus lebih dari 0' TYPE 'E'.
  ENDIF.

START-OF-SELECTION.
  AUTHORITY-CHECK OBJECT 'M_MSEG_BWA'
    ID 'ACTVT' FIELD '01'
    ID 'BWART' FIELD '311'.
  IF sy-subrc <> 0.
    MESSAGE 'Tidak ada otorisasi movement 311' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  " 1. Cek stok sebelum memanggil BAPI
  IF p_charg IS INITIAL.
    SELECT SINGLE labst FROM mard INTO gv_stok
      WHERE matnr = p_matnr AND werks = p_werks AND lgort = p_lgort.
  ELSE.
    SELECT SINGLE clabs FROM mchb INTO gv_stok
      WHERE matnr = p_matnr AND werks = p_werks
        AND lgort = p_lgort AND charg = p_charg.
  ENDIF.
  IF sy-subrc <> 0 OR gv_stok < p_menge.
    MESSAGE 'Stok unrestricted tidak cukup' TYPE 'S' DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.
  WRITE: / 'Stok asal sebelum:', gv_stok.

  " 2. Siapkan data BAPI
  gs_code-gm_code    = '04'.            " transfer posting
  gs_head-pstng_date = p_budat.
  gs_head-doc_date   = sy-datum.
  gs_head-header_txt = p_bktxt.

  CLEAR gs_item.
  gs_item-material   = p_matnr.
  gs_item-plant      = p_werks.
  gs_item-stge_loc   = p_lgort.
  gs_item-batch      = p_charg.
  gs_item-move_type  = '311'.
  gs_item-entry_qnt  = p_menge.
  gs_item-move_plant = p_werks.
  gs_item-move_stloc = p_umlgo.
  gs_item-move_batch = p_charg.
  APPEND gs_item TO gt_item.

  " 3. Panggil BAPI (TESTRUN = simulasi)
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      goodsmvt_header  = gs_head
      goodsmvt_code    = gs_code
      testrun          = p_test
    IMPORTING
      materialdocument = gv_mblnr
      matdocumentyear  = gv_mjahr
    TABLES
      goodsmvt_item    = gt_item
      return           = gt_ret.

  " 4. Cek hasil
  LOOP AT gt_ret INTO gs_ret WHERE type = 'E' OR type = 'A'.
    gv_err = 'X'.
    WRITE: / 'ERROR:', gs_ret-message.
  ENDLOOP.

  IF gv_err = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
  ELSEIF p_test = 'X'.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.   " lepas buffer simulasi
    WRITE: / 'Simulasi OK, siap posting.'.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        wait = 'X'.
    WRITE: / 'Posting sukses. Dokumen:', gv_mblnr, gv_mjahr.
  ENDIF.
```

Catatan: tipe `P_MENGE` boleh disesuaikan (`BSTMG`/`MENGE_D`); minta AI memeriksa tipe `ENTRY_QNT` di SE11.
</details>

## Referensi

- [Skill abap-dev-sandbox-new](../01_SKILLS/abap-dev-sandbox-new/SKILL.md) — pola BAPI & push.
- [Skill mm-analisa-production](../01_SKILLS/mm-analisa-production/SKILL.md) — movement type & tabel stok.
- [Template_Flow_Mermaid.md](../03_TEMPLATE/Template_Flow_Mermaid.md)
