*eject
*----------------------------------------------------------------------*
* Nachricht wird erzeugt                                               *
*----------------------------------------------------------------------*
FORM NACHRICHT_ERZEUGEN.

  CHECK T185F-TRTYP NE A.
  CHECK T185F-TRTYP NE V.
  PERFORM KOPFDIALOGSTRUKTUR_FUELLEN USING X.
  PERFORM POSIDIALOGSTRUKTUR_FUELLEN USING X.
  PERFORM MESSAGING USING X.

ENDFORM.