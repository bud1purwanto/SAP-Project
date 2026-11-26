*&---------------------------------------------------------------------*
*&      Form  GRUKO_LESEN
*&---------------------------------------------------------------------*
*       Aktuelle Zeile des Tablecontrol aus der GRUKO fuellen
*----------------------------------------------------------------------*
FORM GRUKO_LESEN.

* Anzahl Loop-Zeilen fuer Blaettern
  GRUKO_LOOPC = SY-LOOPC.

  READ TABLE GRUKO INDEX GRUKO_TABIX_AKTUELL.
  IF SY-SUBRC EQ 0.
    GRUKO_TABIX_AKTUELL = GRUKO_TABIX_AKTUELL + 1.
    MOVE-CORRESPONDING GRUKO TO RV46G_DOC.
  ENDIF.

ENDFORM.                               " GRUKO_LESEN