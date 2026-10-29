# Checklist Review Kode ABAP 7.31

## Sintaks
- [ ] Tidak ada `DATA(...)` / `FIELD-SYMBOL(...)` inline
- [ ] Tidak ada string template `|...|`
- [ ] Tidak ada `NEW` / `VALUE` / `REDUCE` / `CORRESPONDING` / `FILTER`
- [ ] Open SQL tanpa `@`, field list dipisah spasi

## Database
- [ ] Tidak ada `SELECT *` (kecuali tabel konfigurasi kecil, beri alasan)
- [ ] Tidak ada `SELECT` di dalam `LOOP`
- [ ] FAE dijaga `IS NOT INITIAL`, tabel pengendali di-SORT + DELETE ADJACENT DUPLICATES
- [ ] WHERE mengikuti index

## Internal Table
- [ ] `READ TABLE ... BINARY SEARCH` setelah `SORT` (atau SORTED/HASHED)
- [ ] `CLEAR` work area sebelum READ/APPEND

## Error Handling
- [ ] `sy-subrc` dicek setelah SELECT, READ, CALL FUNCTION
- [ ] BAPI: cek RETURN, ROLLBACK jika error, COMMIT WAIT jika sukses
- [ ] `TRY/CATCH` untuk class

## Bisnis & Keamanan
- [ ] Reversal movement diperhitungkan
- [ ] Status order TECO/DLV/CLSD tidak diproses
- [ ] Tidak ada UPDATE/INSERT/DELETE langsung ke tabel standar
- [ ] AUTHORITY-CHECK untuk proses sensitif

## Kerapian
- [ ] Header program + change history
- [ ] Komentar pada logika kritis
- [ ] Minimal diff (tidak reformat bagian yang tidak diminta)
