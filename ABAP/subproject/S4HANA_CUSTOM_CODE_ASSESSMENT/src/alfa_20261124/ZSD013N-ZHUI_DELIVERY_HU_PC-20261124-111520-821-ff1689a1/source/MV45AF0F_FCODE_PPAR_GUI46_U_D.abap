*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_PPAR_GUI46_U_D                              *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FCODE_PPAR_GUI46_U_D
*&---------------------------------------------------------------------*
*       Übergang zum Positionspartnerbild aus der Übersicht
*----------------------------------------------------------------------*
FORM FCODE_PPAR_GUI46_U_D.

  PERFORM XVBAP_DETAIL(SAPFV45P).

  PERFORM PARTNER_PREPARE USING CHARI.

ENDFORM.                               " FCODE_PPAR_GUI46_U_D












