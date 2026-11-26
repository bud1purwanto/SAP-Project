*-------------------------------------------------------------------
***INCLUDE MV45AO0B .
*-------------------------------------------------------------------
*&---------------------------------------------------------------------*
*&      Module  BUTTON_AUSWAHL  OUTPUT
*&---------------------------------------------------------------------*
*       Auswahl der eingabebereiten Drucktasten auf dem Dynpro anhand
*       der cua_exclude Tabelle. (GROENE)
*----------------------------------------------------------------------*
MODULE BUTTON_AUSWAHL OUTPUT.

  PERFORM BUTTON_AUSWAHL.

ENDMODULE.                 " BUTTON_AUSWAHL  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  BEST_SET_CURSOR_TEXTE  OUTPUT
*&---------------------------------------------------------------------*
*       Set
*----------------------------------------------------------------------*
MODULE BEST_SET_CURSOR_TEXTE OUTPUT.

  PERFORM BEST_SET_CURSOR USING 'RTEXT-SPRAS'.

ENDMODULE.                 " BEST_SET_CURSOR_TEXTE  OUTPUT

INCLUDE MV45AO0B_BADI_SAPMV45A_4311.
INCLUDE MV45AO0B_BADI_SAPMV45A_4453.