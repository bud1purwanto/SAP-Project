*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_UKAU_REDIRECT                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FCODE_UKAU_REDIRECT
*&---------------------------------------------------------------------*
*       Setzt den nicht mehr gebräuchlichen Funktionscode UKAU auf
*       UER1 um. Aufruf als NMODUL der Folgebildsteuerung
*----------------------------------------------------------------------*

FORM FCODE_UKAU_REDIRECT.

  FCODE = 'UER1'.
  PERFORM FCODE_BEARBEITEN.

ENDFORM.                                        " FCODE_UKAU_REDIRECT