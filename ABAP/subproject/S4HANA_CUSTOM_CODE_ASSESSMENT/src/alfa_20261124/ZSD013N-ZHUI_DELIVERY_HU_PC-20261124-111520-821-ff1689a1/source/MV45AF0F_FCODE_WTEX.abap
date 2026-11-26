*---------------------------------------------------------------------*
*       FORM FCODE_WTEX                                               *
*---------------------------------------------------------------------*
*       Fehlerprotokoll - Bearbeitung von Texten                      *
*---------------------------------------------------------------------*
FORM FCODE_WTEX.

  ACT_ALF = CHARA.
  FEHLER = CHARX.
  PERFORM TEXT_EDITIEREN(SAPFV45T) USING CHARX
                                         FEHLER.

ENDFORM.