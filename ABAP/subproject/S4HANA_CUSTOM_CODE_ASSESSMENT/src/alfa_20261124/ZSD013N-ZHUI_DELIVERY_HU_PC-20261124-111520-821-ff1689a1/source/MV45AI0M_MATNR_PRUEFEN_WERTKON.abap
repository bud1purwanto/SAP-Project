*&---------------------------------------------------------------------*
*&      Module  MATNR_PRUEFEN_WERTKONTRAKT  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE MATNR_PRUEFEN_WERTKONTRAKT INPUT.

  DATA: DA_SUBRC LIKE SY-SUBRC.

  PERFORM MATNR_PRUEFEN_WERTKONTRAKT USING    CHARX
                                     CHANGING DA_SUBRC.

ENDMODULE.                 " MATNR_PRUEFEN_WERTKONTRAKT  INPUT