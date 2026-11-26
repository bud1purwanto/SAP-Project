*&---------------------------------------------------------------------*
*&      Module  TSABT_SELECT  OUTPUT                                   *
*&---------------------------------------------------------------------*
*       Lesen des Abteilungstextes                                     *
*----------------------------------------------------------------------*
MODULE TSABT_SELECT OUTPUT.

  PERFORM TSABT_SELECT USING VBKD-ABTNR
                             SPACE
                             SY-SUBRC.

ENDMODULE.                             " TSABT_SELECT  OUTPUT