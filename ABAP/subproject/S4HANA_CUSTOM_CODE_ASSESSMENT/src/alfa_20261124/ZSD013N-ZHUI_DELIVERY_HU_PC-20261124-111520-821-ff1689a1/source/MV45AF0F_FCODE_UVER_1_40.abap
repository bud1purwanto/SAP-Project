*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_UVER_1_40                                   *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FCODE_UVER_1_40                                          *
*---------------------------------------------------------------------*
*       Ansteuerung des Übersichtsbilds Versand/Liefergruppen         *
*       im GUI 4.0 aus den Bildgruppen K0,P0                          *
*---------------------------------------------------------------------*

FORM FCODE_UVER_1_40.

  PERFORM XVBAP_UEBERSICHT_ANSTEUERN(SAPFV45P).
  PERFORM FCODE_LGKO.

ENDFORM.                        " FCODE_UVER_1_40