# ZBMBC WMS — Multi-row INSERT (ADBC) & filter HU (29.10.2026)

## Perubahan (F01, hanya path LRB3)
1. `GT_DATA` loop: setelah HU Box/Pallet dihitung, baris WMS tanpa HU (`HUBOX` dan `HUPLT` kosong) langsung `CONTINUE` (skip karakteristik & NAME1).
2. `GT_DATA` blok exit WMS: `DELETE IT_ZBMBC WHERE HUBOX IS INITIAL AND HUPLT IS INITIAL`.
3. `INSERT_SQL_WMS` diganti ADBC:
   - `CL_SQL_CONNECTION=>GET_CONNECTION( S_CONN )`.
   - `DELETE FROM Y_ZBMBCSR`.
   - Multi-row `INSERT ... VALUES (..),(..)` 500 baris per statement.
   - `COMMIT`, lalu `EXECUTE_PROCEDURE( 'dbo.SP_Merge_ZBMBCSR_WMS' )`, lalu `COMMIT`.
   - Error `CX_SQL_EXCEPTION` / `CX_PARAMETER_INVALID` -> ROLLBACK + pesan dengan teks error SQL.
4. FORM baru:
   - `ADD_WMS_VAL`: nilai jadi literal `N'..'`; `'` di-escape menjadi `''`.
   - `EXEC_WMS_PACK`: kirim 1 statement.
   - `ROLLBACK_WMS`.

Sisi SQL Server: tidak ada perubahan (tabel Y, SP, tanpa trigger). Versi SQL Server = 13.0.4259 (2016), multi-row VALUES didukung (maks 1000 baris per statement).

## Hasil uji (Development Windows TRIASWIN2008, DBCO WMS, temp table `##T_ZBMBC_ADBC`, Y tidak disentuh)
| Metode | 71,296 baris |
|---|---|
| Per baris ADBC | ~4.1 ms/baris -> ~290 s |
| Per baris EXEC SQL (run user 28.10) | > 49 menit (ikut tertahan konkurensi) |
| Multi-row pack 500 | 42.4 s |
| Multi-row pack 50 / 20 / 100 | 24.6-46.3 / 43.9 / 69.9 s |

Variasi waktu besar -> bottleneck jaringan/beban MSSQL (~36 MB payload Unicode antar subnet), bukan jumlah statement. Pack 500 dipertahankan.
Escape quote: 71 baris `PT O'BRIEN TEST` terbaca utuh (COUNT_QUOTE = 71). Total baris pas (71,796 = 71,296 + 500).

Script: `scripts/test_adbc_multirow.mjs`. Rollback: `outputs/ZBAP_STOCK_BY_CHAR1_F01_before_adbc.abap`.
