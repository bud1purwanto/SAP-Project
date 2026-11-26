*----------------------------------------------------------------------*
*   INCLUDE MV45AI0V_VBAK_DAT_FZAU_PRUEFEN                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VBAK-DAT_FZAU_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       Eingabeprüfung: Datum Auftragsfortschrittszahl
*----------------------------------------------------------------------*
MODULE VBAK-DAT_FZAU_PRUEFEN INPUT.

  PERFORM DATUM_IN_VERGANGENHEIT_PRUEFEN USING VBAK-DAT_FZAU.

ENDMODULE.                             " VBAK-DAT_FZAU_PRUEFEN  INPUT