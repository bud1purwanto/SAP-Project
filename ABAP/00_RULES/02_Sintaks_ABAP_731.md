# 02 — Batasan Sintaks ABAP 7.31

> Fitur yang dilarang dan sintaks pengganti yang valid di ABAP 7.31.
> Sumber: dipecah dari `AGENTS.md` (backup: `_backup/AGENTS_20261105.md`). Kembali ke [AGENTS.md](../AGENTS.md).

## Batasan Versi ABAP 7.31 — WAJIB DIPATUHI

**TIDAK boleh** menyarankan fitur yang belum tersedia di ABAP 7.31:
- Inline declaration `DATA(...)` → mulai 7.40
- String template `` |Hello { name }| `` → mulai 7.40
- `NEW`, `VALUE`, `REDUCE`, `FILTER` operator → mulai 7.40
- ABAP CDS Views (`CREATE VIEW ... AS SELECT`) → terbatas, gunakan classic view
- RAP (RESTful Application Programming Model) → tidak tersedia
- AMDP (ABAP Managed Database Procedures) → tidak tersedia
- Open SQL strict mode, `@variable` binding → tidak tersedia
- `LOOP AT ... INTO DATA(...)` → tidak tersedia

**GUNAKAN** sintaks valid ABAP 7.31:
- Deklarasi variable eksplisit di bagian `DATA` / `TYPES`
- Open SQL klasik: `SELECT ... INTO TABLE lt_xxx`
- Internal table dengan HEADER LINE atau eksplisit work area
- String handling: `CONCATENATE`, `MOVE`, `WRITE`
- Exception handling: `SY-SUBRC` dan `TRY/CATCH` (ABAP OO)
- Enhancement Framework, User Exit, BADI, BTE

---

## Catatan Error Syntax yang Sering Muncul (merge dari ADT AGENTS, 2026-11-05)

- `Unexpected operator IS` untuk `IF func( ... ) IS NOT INITIAL` → simpan hasil ke variabel dulu, lalu cek variabel.
- `A RETURNING parameter must be fully typed` untuk `RETURNING VALUE(x) TYPE c LENGTH 4` → deklarasikan `TYPES` dulu, pakai tipe itu.
- Runtime (tidak terdeteksi syntax check): `MOVE_TO_LIT_NOTALLOWED_NODATA` saat assign seluruh struktur ke baris SORTED/HASHED table dengan unique key → hanya ubah field non-key.
- Setelah push source panjang, **baca ulang** source dari server dan bandingkan jumlah baris. Blok yang hilang bukan syntax error.
- Syntax check bersih ≠ logika benar. Laporkan "tidak ada syntax error" + apa yang dicek, jangan klaim kode benar.
