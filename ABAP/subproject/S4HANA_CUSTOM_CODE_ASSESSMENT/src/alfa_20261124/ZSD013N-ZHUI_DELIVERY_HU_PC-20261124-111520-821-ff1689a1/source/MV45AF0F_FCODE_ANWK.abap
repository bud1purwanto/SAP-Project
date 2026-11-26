*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_ANWK                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   FORM FCODE_ANWK                                                    *
*----------------------------------------------------------------------*
*   Zuordnen eines Kontraktes zu einem bestehenden                     *
*   Kundenauftragskopf                                                 *
*----------------------------------------------------------------------*
FORM FCODE_ANWK.

  DATA: DA_SUBRC LIKE SY-SUBRC.

  LOCAL: TVCPA.

* TVCPA nachlesen
  PERFORM TVCPA_SELECT USING VBAK-AUART
                             CVBAK-AUART
                             SPACE
                             SPACE
                             SPACE
                             SPACE
                             DA_SUBRC.

  CHECK DA_SUBRC = 0.

* Zuordnung vornehmen
  PERFORM VBAK_BEARBEITEN_VORBEREITEN(SAPFV45K).
  VBAK-VGBEL = CVBAK-VBELN.
  VBAK-VGTYP = CVBAK-VBTYP.
  PERFORM VBAK_BEARBEITEN(SAPFV45K).
* Positionen abloopen und Preisfindung neu durchführen
  LOOP AT XVBAP WHERE UPDKZ NE UPDKZ_DELETE
                  AND PVPOS IS INITIAL.
    SVBAP-TABIX = SY-TABIX.
    PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
    PERFORM VBAP_FUELLEN(SAPFV45P).
    PERFORM PREISFINDUNG(SAPFV45P) USING CHARC.
    PERFORM VBAP_BEARBEITEN(SAPFV45P).
    PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).
  ENDLOOP.

  MESSAGE S729 WITH CVBAK-VBELN.

ENDFORM.