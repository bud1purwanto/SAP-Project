REPORT zs4cca_testsrc.
*&---------------------------------------------------------------------*
*& Fixture uji ZS4CCA: pola kode gaya ECC 6.0 yang bermasalah di S/4.
*& SENGAJA tidak bisa diaktifkan. Simpan saja (inactive), lalu scan
*& dengan ZS4CCA_MAIN mode RB_ADB, S_PROG = ZS4CCA_TESTSRC.
*& Temuan yang diharapkan ada di docs/UJI_F1_ZS4CCA.md
*&---------------------------------------------------------------------*
TABLES: vbuk, mkpf.

DATA: gt_konv  TYPE STANDARD TABLE OF konv,
      gs_mseg  TYPE mseg,
      gs_bsis  TYPE bsis,
      gv_matnr TYPE mara-matnr,
      gv_mat18(18) TYPE c,
      gv_ztab  TYPE zs4cca_tidak_ada-feld1,
      go_zcls  TYPE REF TO zcl_s4cca_tidak_ada.

* 1 baca tabel yang di S/4 tidak diisi lagi (KONV, VBUK)
SELECT * FROM konv INTO TABLE gt_konv WHERE knumv = '0000000001'.
SELECT SINGLE * FROM vbuk WHERE vbeln = '0000000001'.

* 2 baca tabel dengan replacement object (MSEG) dan compatibility view (BSIS)
SELECT SINGLE * FROM mseg INTO gs_mseg WHERE mblnr = '4900000001'.
SELECT SINGLE * FROM bsis INTO gs_bsis WHERE bukrs = '1000'.

* 3 hint database Oracle
SELECT SINGLE matnr FROM mara INTO gv_mat18 WHERE matnr = gv_matnr
  %_HINTS ORACLE 'INDEX("MARA" "MARA~0")'.

* 4 tulis ke tabel dengan replacement object
UPDATE mseg SET sgtxt = 'X' WHERE mblnr = '4900000001'.

* 5 objek custom yang belum ada di ADB
CALL FUNCTION 'Z_S4CCA_FM_TIDAK_ADA'.
SUBMIT zs4cca_prog_tidak_ada AND RETURN.

* 6 transaksi lama
CALL TRANSACTION 'MB01'.

* 7 Native SQL
EXEC SQL.
  SELECT COUNT(*) FROM MARA
ENDEXEC.

* 8 include yang tidak ada
INCLUDE zs4cca_testsrc_inc_hilang.
