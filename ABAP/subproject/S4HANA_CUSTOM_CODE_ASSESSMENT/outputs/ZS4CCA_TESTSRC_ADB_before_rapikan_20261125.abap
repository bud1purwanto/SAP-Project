REPORT ZS4CCA_TESTSRC.
*&---------------------------------------------------------------------*
*& Fixture uji ZS4CCA: pola kode gaya ECC 6.0 yang bermasalah di S/4.
*& SENGAJA tidak bisa diaktifkan. Simpan saja (inactive), lalu scan
*& dengan ZS4CCA_MAIN mode RB_ADB, S_PROG = ZS4CCA_TESTSRC.
*& Temuan yang diharapkan ada di docs/UJI_F1_ZS4CCA.md
*&---------------------------------------------------------------------*
TABLES: VBUK, MKPF.

DATA: GT_KONV  TYPE STANDARD TABLE OF KONV,
      GS_MSEG  TYPE MSEG,
      GS_BSIS  TYPE BSIS,
      GV_MATNR TYPE MARA-MATNR,
      GV_MAT18(18) TYPE C,
      GV_ZTAB  TYPE ZS4CCA_TIDAK_ADA-FELD1,
      GO_ZCLS  TYPE REF TO ZCL_S4CCA_TIDAK_ADA.

* 1 baca tabel yang di S/4 tidak diisi lagi (KONV, VBUK)
SELECT * FROM KONV INTO TABLE GT_KONV WHERE KNUMV = '0000000001'.
SELECT SINGLE * FROM VBUK WHERE VBELN = '0000000001'.

* 2 baca tabel dengan replacement object (MSEG) dan compatibility view (BSIS)
SELECT SINGLE * FROM MSEG INTO GS_MSEG WHERE MBLNR = '4900000001'.
SELECT SINGLE * FROM BSIS INTO GS_BSIS WHERE BUKRS = '1000'.

* 3 hint database Oracle
SELECT SINGLE MATNR FROM MARA INTO GV_MAT18 WHERE MATNR = GV_MATNR
  %_HINTS ORACLE 'INDEX("MARA" "MARA~0")'.

* 4 tulis ke tabel dengan replacement object
UPDATE MSEG SET SGTXT = 'X' WHERE MBLNR = '4900000001'.

* 5 objek custom yang belum ada di ADB
CALL FUNCTION 'Z_S4CCA_FM_TIDAK_ADA'.
SUBMIT ZS4CCA_PROG_TIDAK_ADA AND RETURN.

* 6 transaksi lama
CALL TRANSACTION 'MB01'.

* 7 Native SQL
EXEC SQL.
  SELECT COUNT(*) FROM MARA
ENDEXEC.

* 8 include yang tidak ada
INCLUDE ZS4CCA_TESTSRC_INC_HILANG.