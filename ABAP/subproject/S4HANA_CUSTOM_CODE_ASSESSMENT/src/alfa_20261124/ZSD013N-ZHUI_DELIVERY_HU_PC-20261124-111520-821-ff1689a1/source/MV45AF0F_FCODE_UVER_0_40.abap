*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_UVER_0_40                                   *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FCODE_uver_0_40                                          *
*---------------------------------------------------------------------*
*       Ansteuerung des Übersichtsbilds Versand/Liefergruppen         *
*       im GUI 4.0 aus den Bildgruppen A0,FL,P1,U0                    *
*---------------------------------------------------------------------*

FORM FCODE_UVER_0_40.

  PERFORM XVBEP_INITIALISIEREN_ALLE(SAPFV45E).
  PERFORM FCODE_LGKO.

ENDFORM.                        " FCODE_UVER_0_40