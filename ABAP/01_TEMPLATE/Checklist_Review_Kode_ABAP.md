# Checklist Review Kode ABAP 7.31

Pakai sebelum push ke `sandbox-new`. Detail aturan: [02_Sintaks_ABAP_731.md](../00_RULES/02_Sintaks_ABAP_731.md), [04_Grounding_dan_Review_Kode.md](../00_RULES/04_Grounding_dan_Review_Kode.md).

## Sintaks
- [ ] Tidak ada fitur 7.40+ (inline decl, constructor operator, table expression `itab[ ]`, `@`, CDS) — daftar lengkap [02](../00_RULES/02_Sintaks_ABAP_731.md)
- [ ] Konvensi tim: tidak ada string template `|...|` / `&&`, tidak ada `WITH HEADER LINE` di kode baru
- [ ] Open SQL klasik: tanpa `@`, field list dipisah spasi

## Database
- [ ] Tidak ada `SELECT *` (kecuali tabel konfigurasi kecil, beri alasan)
- [ ] Tidak ada `SELECT` di dalam `LOOP`
- [ ] FAE dijaga `IS NOT INITIAL`, tabel pengendali di-SORT + DELETE ADJACENT DUPLICATES
- [ ] WHERE mengikuti index

## Internal Table
- [ ] `READ TABLE ... BINARY SEARCH` setelah `SORT` (atau SORTED/HASHED)
- [ ] `CLEAR` work area sebelum READ/APPEND
- [ ] `FREE`/`REFRESH` setelah data masif selesai dipakai

## Error Handling
- [ ] `sy-subrc` dicek setelah SELECT, READ, CALL FUNCTION
- [ ] BAPI: cek RETURN, ROLLBACK jika error, COMMIT WAIT jika sukses
- [ ] `TRY/CATCH` untuk class

## Bisnis & Keamanan
- [ ] Reversal movement diperhitungkan (`SMBLN`/`SJAHR`)
- [ ] Status order TECO/DLV/CLSD tidak diproses
- [ ] Tidak ada UPDATE/INSERT/DELETE langsung ke tabel standar
- [ ] Enqueue/Dequeue untuk data krusial
- [ ] AUTHORITY-CHECK untuk proses sensitif

## Push & Diff
- [ ] Source **terbaru di-pull dari `sandbox-new` tepat sebelum push** (bukan `src/*.abap` lama), backup di `outputs/`
- [ ] Diff hasil pull vs base lokal dicek; ada perubahan manual → STOP, lapor Baginda
- [ ] Baginda konfirmasi write
- [ ] Target `sandbox-new` (`set_active_server`)
- [ ] Diff minimal (tidak reformat, tidak hapus komentar/blank line)
- [ ] `EV_SUCCESS = 'X'` dan jumlah baris cocok setelah push

## Urutan & Konsistensi (merge ADT AGENTS)
- [ ] Semua aturan blocking dicek sebelum BAPI / COMMIT pertama
- [ ] Multi-step COMMIT punya guard idempotensi / kompensasi
- [ ] Hasil BDC/BAPI diverifikasi di database, semua message TYPE dievaluasi
- [ ] Komentar, FS/TS, dan konstanta cocok dengan kode

## Format Laporan QA

| Cek | Hasil (PASS / WARN / FAIL / NOT RUN) | Bukti |
|---|---|---|
| Objek tidak ada yang inaktif (`DWINACTIV`) | | |
| Syntax check | | |
| Test normal + data kosong + error | | |
| Short dump terbaru (`SNAP` / ST22) | | |
| Review statis (Critical/Major/Minor) | | |

Vonis: READY / READY WITH WARNINGS / NOT READY — langkah berikutnya: ...
Cek yang tidak dijalankan = NOT RUN + alasan, bukan PASS.
