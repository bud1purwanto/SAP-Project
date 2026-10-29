---
name: abap-dev-sandbox-new
description: Gunakan saat membuat, mengubah, push, atau menguji program ABAP (report, ALV, FORM, FM) untuk training atau prototipe. Semua penulisan hanya ke server sandbox-new (Sandbox New Company, TRS client 130) dengan sintaks ABAP 7.31.
---

# Skill: Development ABAP di Sandbox New Company

## 1. Guardrail (wajib, tanpa pengecualian)

- Target tulis **hanya** `sandbox-new`. Panggil `set_active_server` → `sandbox-new` sebelum setiap operasi tulis.
- Server lain (`dev`, `dev-aix`, `qa`, `prod`) hanya boleh dibaca.
- Program training: nama `ZTRN_<INISIAL>_D<NN>`, package `$TMP`, tanpa transport request.
- Jangan menimpa program yang bukan milik training. Sebelum mengubah program existing: baca source, simpan backup lokal (`outputs/<PROGRAM>_backup_<YYYYMMDD>.abap`), bandingkan jumlah baris.
- Minimal diff: ubah hanya bagian yang diminta. Jangan reformat atau menghapus komentar.
- Dilarang `UPDATE`/`INSERT`/`DELETE`/`MODIFY` langsung ke tabel standar SAP.

## 2. Sintaks ABAP 7.31

Dilarang: `DATA(...)`, `FIELD-SYMBOL(...)` inline, string template `|...|`, `NEW`, `VALUE`, `REDUCE`, `CORRESPONDING`, `FILTER`, host variable `@` di Open SQL, pemisah koma di field list SELECT.

Wajib:
- Semua deklarasi di blok `TYPES:` / `DATA:` di awal.
- Keyword ABAP UPPER CASE, komentar pada logika kritis.
- `CONCATENATE`, `SPLIT`, `CONDENSE`, `REPLACE ... OCCURRENCE OF ... IN ... WITH ...` untuk string.

## 3. Standar Kode

Kerangka report:

```abap
REPORT ztrn_xx_dnn.
*----------------------------------------------------------------------*
* Program  : ZTRN_XX_DNN
* Tujuan   : <satu kalimat>
* Author   : <nama>      Tanggal: <YYYY-MM-DD>
*----------------------------------------------------------------------*
TABLES: aufk.                             " hanya untuk SELECT-OPTIONS

TYPES: BEGIN OF ty_out,
         aufnr TYPE aufk-aufnr,
         auart TYPE aufk-auart,
       END OF ty_out.

DATA: gt_out TYPE STANDARD TABLE OF ty_out,
      gs_out TYPE ty_out.

SELECT-OPTIONS: s_aufnr FOR aufk-aufnr.

START-OF-SELECTION.
  PERFORM get_data.
  PERFORM display.

FORM get_data.
  SELECT aufnr auart
    FROM aufk
    INTO TABLE gt_out
    WHERE aufnr IN s_aufnr.
  IF sy-subrc <> 0.
    MESSAGE 'Data tidak ditemukan' TYPE 'S' DISPLAY LIKE 'E'.
  ENDIF.
ENDFORM.

FORM display.
  " ALV: CL_SALV_TABLE atau REUSE_ALV_GRID_DISPLAY
ENDFORM.
```

Database & performa:
- Hindari `SELECT *`; sebut field eksplisit.
- `WHERE` mengikuti urutan field index.
- `FOR ALL ENTRIES`: cek `IF lt_drv IS NOT INITIAL`, lalu `SORT` + `DELETE ADJACENT DUPLICATES` tabel pengendali.
- Tidak ada `SELECT` di dalam `LOOP`. Ambil sekali, lalu `READ TABLE ... BINARY SEARCH` (tabel sudah di-`SORT`) atau pakai `SORTED`/`HASHED TABLE`.
- `CLEAR` work area sebelum `READ TABLE`/`APPEND`.

Error handling:
- Cek `sy-subrc` setelah SELECT, READ TABLE, CALL FUNCTION.
- BAPI: cek `RETURN` (`TYPE` E/A) → `BAPI_TRANSACTION_ROLLBACK`; sukses → `BAPI_TRANSACTION_COMMIT` `WAIT = 'X'`.
- OO: `TRY ... CATCH cx_... ENDTRY`.

Integritas bisnis:
- Movement: perhitungkan reversal (102/262/532, `MSEG-SMBLN`).
- Order: jangan proses status `TECO`, `DLV`, `CLSD` (cek `STATUS_READ` / `JEST`).
- Proses data sensitif: `AUTHORITY-CHECK` level `WERKS`/`BUKRS`/`EKORG`.

## 4. Alur Push Program

1. `set_active_server` → `sandbox-new`.
2. Jika program sudah ada: `read_program` → simpan backup.
3. Siapkan source sebagai array baris (maks 255 karakter per baris).
4. `call_function` FM `Z_RFC_PROGRAM_UPDATE`:
   - `IV_PROGRAM_NAME = 'ZTRN_XX_DNN'`
   - `IV_PACKAGE = '$TMP'`
   - `IV_CORRNUMBER = ' '`
   - `IT_SOURCE = [ {LINE: '...'}, ... ]`
5. Pastikan `EV_SUCCESS = 'X'`. Jika gagal, tampilkan `EV_MESSAGE` apa adanya.
6. `read_program` lagi → bandingkan jumlah baris dengan source lokal.

## 5. Checklist Sebelum Menyerahkan Kode

- [ ] Tidak ada sintaks 7.40+.
- [ ] Semua variabel dideklarasikan.
- [ ] Tidak ada `SELECT *` dan tidak ada `SELECT` di dalam `LOOP`.
- [ ] FAE dijaga `IS NOT INITIAL`.
- [ ] `sy-subrc` dicek.
- [ ] Reversal / status order diperhitungkan (jika relevan).
- [ ] Push sukses (`EV_SUCCESS = 'X'`) dan jumlah baris cocok.
- [ ] Test minimal 1 skenario normal + 1 skenario data kosong.

## 6. Format Jawaban

1. TCODE relevan (SE38, SE80, SE11, SE37, ST22, ST05).
2. Kode ABAP 7.31 lengkap dengan deklarasi.
3. Catatan performa jika menyentuh database.
4. Dampak transport (training: tidak ditransport, `$TMP`).
5. Peringatan eksplisit jika ada risiko data.

## 7. Troubleshooting

Urutan: ST22 (dump) → SM21 (system log) → Debugger (breakpoint) → ST05 (SQL trace) → baru ubah kode.
