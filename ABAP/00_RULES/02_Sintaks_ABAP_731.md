# 02 — Batasan Sintaks ABAP 7.31

> **Satu-satunya sumber** aturan sintaks. File lain (AGENTS.md, 04, checklist) cukup menautkan ke sini.
> Kembali ke [AGENTS.md](../AGENTS.md). Backup versi lama: `_backup/rules_20261105_optimasi/`.

## 1. Fitur 7.40+ — TIDAK tersedia di 7.31 (dilarang)

| Fitur | Mulai | Pengganti 7.31 |
|---|---|---|
| Inline declaration `DATA(...)`, `FIELD-SYMBOL(...)` (termasuk `LOOP AT ... INTO DATA(...)`, `SELECT ... INTO @DATA(...)`) | 7.40 | Deklarasi eksplisit di `DATA:` / `TYPES:` / `FIELD-SYMBOLS:` |
| Constructor operator `NEW`, `VALUE`, `CONV`, `CORRESPONDING`, `COND`, `SWITCH`, `CAST`, `REF`, `EXACT`, `REDUCE`, `FILTER`, `FOR ... IN` | 7.40 | `CREATE OBJECT`, `APPEND`/`INSERT`, `MOVE-CORRESPONDING`, `IF`/`CASE`, `?=`, `GET REFERENCE OF` |
| Table expression `itab[ ... ]`, `line_exists( )`, `line_index( )` | 7.40 | `READ TABLE ... WITH KEY ...` + cek `sy-subrc` / `sy-tabix` |
| `xsdbool( )` | 7.40 SP08 | `IF ... . lv_flag = 'X'. ENDIF.` |
| `LOOP AT ... GROUP BY` | 7.40 | `SORT` + `AT NEW` / `AT END OF`, atau collect manual |
| Open SQL baru: host variable `@`, field list dipisah koma, ekspresi SQL (`CASE`, `COALESCE`) di SELECT, strict mode | 7.40 SP05 | Open SQL klasik: field dipisah **spasi**, tanpa `@` |
| ABAP CDS View | 7.40 SP05 | **Tidak ada sama sekali** di 7.31 → classic view SE11 / JOIN Open SQL |
| AMDP, RAP | 7.40 / 7.50+ | Tidak tersedia → FM/Class biasa |

## 2. Tersedia di 7.31 tapi DILARANG (konvensi tim)

| Fitur | Status teknis | Konvensi |
|---|---|---|
| String template `\|...{ var }...\|` | **Sudah ada sejak 7.02** | Tidak dipakai — konsistensi dengan kode existing. Pakai `CONCATENATE ... INTO ... SEPARATED BY`, `WRITE ... TO`. |
| Operator `&&` | Sudah ada sejak 7.02 | Tidak dipakai, alasan sama. Pakai `CONCATENATE`. |
| Internal table `WITH HEADER LINE`, `TABLES` di report | Obsolete | Jangan dipakai di kode baru. Kode existing yang sudah pakai: biarkan (minimal diff). |

Boleh dipakai (tersedia 7.02+): `lines( itab )`, `strlen( )`, `condense( )`, `to_upper( )`, `boolc( )`, `TRY/CATCH`, `REPLACE ... OCCURRENCE`, `FIND ... REGEX`, SORTED/HASHED table, secondary key.

## 3. Sintaks yang dipakai

- Deklarasi eksplisit `DATA` / `TYPES` di awal blok, sebelum logic.
- Open SQL klasik: `SELECT f1 f2 FROM ... INTO TABLE lt_xxx WHERE ...`.
- Work area eksplisit (`DATA ls_xxx TYPE ty_xxx`) atau `FIELD-SYMBOLS`.
- String: `CONCATENATE`, `SPLIT`, `REPLACE`, `CONDENSE`, `WRITE ... TO`.
- Error: `sy-subrc` dan `TRY/CATCH` (ABAP OO).
- Enhancement: Enhancement Framework, BAdI classic/new, User Exit, BTE.

## 4. Error syntax yang sering muncul

- `Unexpected operator IS` untuk `IF func( ... ) IS NOT INITIAL` → simpan hasil ke variabel dulu, lalu cek variabel.
- `A RETURNING parameter must be fully typed` untuk `RETURNING VALUE(x) TYPE c LENGTH 4` → deklarasikan `TYPES` dulu, pakai tipe itu.
- Runtime (tidak terdeteksi syntax check): `MOVE_TO_LIT_NOTALLOWED_NODATA` saat assign seluruh struktur ke baris SORTED/HASHED table dengan unique key → hanya ubah field non-key.
- `REPLACE 'X' WITH 'Y' IN field.` → error "Specification WITH ... is not expected" → pakai `REPLACE FIRST OCCURRENCE OF 'X' IN field WITH 'Y'.`
- Setelah push source panjang, **baca ulang** source dari server dan bandingkan jumlah baris. Blok yang hilang bukan syntax error.
- Syntax check bersih ≠ logika benar. Laporkan "tidak ada syntax error" + apa yang dicek, jangan klaim kode benar.
