************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Kundenauftragsabwicklung            *
*     Module alphabetisch geordnet; hier beginnend mit "X"             *
*                                                                      *
************************************************************************

  INCLUDE MV45AO0X_XKOMV_LESEN_N46 .
  INCLUDE MV45AO0X_XVBUK_UPDATE.
  INCLUDE MV45AO0X_XVBEPDG_LESEN.

*&---------------------------------------------------------------------*
*&      Module  XVBUK_UPDATE_TEXTS  OUTPUT
*&---------------------------------------------------------------------*
*       Tabellen XVBUK und VBSTT werden aktualisiert.
*----------------------------------------------------------------------*
MODULE XVBUK_UPDATE_TEXTS OUTPUT.

  PERFORM XVBUK_UPDATE(SAPFV45K).
  PERFORM XVBUK_UPDATE_TEXTS(SAPFV45K).

ENDMODULE.                 " XVBUK_UPDATE_TEXTS  OUTPUT

