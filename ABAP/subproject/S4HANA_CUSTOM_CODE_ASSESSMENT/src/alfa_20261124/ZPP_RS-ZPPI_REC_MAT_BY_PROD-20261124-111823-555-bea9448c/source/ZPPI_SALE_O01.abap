*----------------------------------------------------------------------*
***INCLUDE ZPPI_SALE_O01 .
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  STATUS_3000  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE STATUS_3000 OUTPUT.
  SET PF-STATUS 'PROD_STAT1300'.
  SET TITLEBAR  'PROD_TITLE1300'.

IF ZMJAHR EQ ''.
  ZMJAHR = SY-DATUM(4).
ENDIF.

IF LIKP-ERDAT EQ '00000000'.
  LIKP-ERDAT = SY-DATUM.
ENDIF.

IF ZWERKS EQ ''.
  ZWERKS = '2000'.
ENDIF.


  ZVKORG = '1000'.
  ZVTWEG = '01'.
  ZSPART = '19'.

  SELECT SINGLE TVKOT~VTEXT
    INTO ZVTEXT1
    FROM TVKOT
    WHERE TVKOT~VKORG = ZVKORG
      AND TVKOT~SPRAS = 'E'.

  SELECT SINGLE TVTWT~VTEXT
    INTO ZVTEXT2
    FROM TVTWT
    WHERE TVTWT~VTWEG = ZVTWEG
      AND TVTWT~SPRAS = 'E'.

  SELECT SINGLE TSPAT~VTEXT
    INTO ZVTEXT3
    FROM TSPAT
    WHERE TSPAT~SPART = ZSPART
      AND TSPAT~SPRAS = 'E'.

ENDMODULE.                 " STATUS_3000  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  SEL_SCR_3100  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE SEL_SCR_3100 OUTPUT.
  SELECTION-SCREEN BEGIN OF SCREEN 3100 AS SUBSCREEN.
    SELECT-OPTIONS : S_MBLNR FOR MKPF-MBLNR. " OBLIGATORY.
  SELECTION-SCREEN END OF SCREEN 3100.

ENDMODULE.                 " SEL_SCR_3100  OUTPUT