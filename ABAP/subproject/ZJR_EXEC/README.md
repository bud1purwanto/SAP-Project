# Subproject: ZJR_EXEC (Replikasi ZPP041 ke S/4HANA)

## Atribut
- **Program Utama:** `ZPPI_JR_EXEC`
- **TCode Sumber (DEV AIX):** `ZPP041`
- **TCode Target (S/4HANA):** `ZJR_EXEC`
- **Tipe Transaksi:** Report Transaction (`CINFO = 80`), Dynpro 1000
- **Modul SAP:** PP / Manufaktur (Jumbo Roll Execution Floor)

## Isi Folder
- `src/`: Source code ABAP program utama (`ZPPI_JR_EXEC.abap`), 6 includes (`Z_PROG_INFO.abap`, `ZABAPALV.abap`, `ZPPI_JR_EXEC_TOP.abap`, `ZPPI_JR_EXEC_F01.abap`, `ZPPI_JR_EXEC_LYT.abap`, `ZPPI_JR_EXEC_FTE.abap`), FM `Z_MMUR_ROUND_FOR_FRACT5.abap`, `cua.json`, `dynpros.json`, `tables.json`, `dtels.json`.
- `scripts/`: Skrip otomasi migrasi dan replikasi DDIC/Program ke S/4HANA.
- `docs/`: Analisis teknis (`MIGRATION_ANALYSIS_ZJR_EXEC.md`) dan screenshot pengujian live GUI.
- `outputs/`: Backup JSON dan log eksekusi.