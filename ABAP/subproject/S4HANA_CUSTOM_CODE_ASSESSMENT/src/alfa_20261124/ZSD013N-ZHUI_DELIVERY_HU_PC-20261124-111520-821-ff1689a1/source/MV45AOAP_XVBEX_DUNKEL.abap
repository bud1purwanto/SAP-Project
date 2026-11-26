*&---------------------------------------------------------------------*
*&      Module  XVBEX_DUNKEL  OUTPUT                                   *
*&---------------------------------------------------------------------*
*       Wenn die Tabelle XVBEX leer ist, wird das Dynpro 213 dunkel    *
*       prozessiert                                                    *
*----------------------------------------------------------------------*
MODULE XVBEX_DUNKEL OUTPUT.

  DATA:  ANZ_ZEILEN TYPE I VALUE 0.
  CLEAR: ANZ_ZEILEN.
  DESCRIBE TABLE XVBEX LINES ANZ_ZEILEN.

  IF ANZ_ZEILEN IS INITIAL.
     T185-DUNKEL = CHARX.
     FCODE       = 'ABBR'.
  ENDIF.

ENDMODULE.