*---------------------------------------------------------------------*
*       FORM VBMUE_HAT_EINTRAG                                        *
*---------------------------------------------------------------------*
*       Prüfen ob in der Tabelle VBMUE ein Eintrag vorhanden ist.     *
*       Beim ersten mal wird wirklich von der Datenbank gelesen.      *
*---------------------------------------------------------------------*
FORM vbmue_hat_eintrag                    CHANGING ch_eintrag.

  STATICS st_eintrag.

* Nur beim ersten mal von Datenbank lesen
  IF st_eintrag IS INITIAL.
    st_eintrag = charn.
    SELECT * FROM vbmue UP TO 1 ROWS.
      st_eintrag = chary.
    ENDSELECT.
  ENDIF.

  ch_eintrag = st_eintrag.

ENDFORM.