*---------------------------------------------------------------------*
*       FORM FCODE_POTE                                               *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Gesamtnetzterminierung                   *
*---------------------------------------------------------------------*
FORM FCODE_POTE.

  IF VBAP-WERKS EQ SPACE AND
     VBAP-PROSA NE CHARA.
    MESSAGE I186 WITH VBAP-POSNR.
    EXIT.
  ENDIF.

* handelt es sich überhaupt um eine Montageposition ?
  PERFORM T459K_LESEN(SAPMV45A).
  IF T459K-MNTGA EQ MOFAUF.
    PERFORM T003O_SELECT(SAPMV45A) USING T459K-AUART
                                         CHARX
                                         SY-SUBRC.
    IF T003O-AUTYP NE NETZ.
      MESSAGE I638 WITH VBAP-POSNR.
      EXIT.
    ENDIF.
  ELSE.
    MESSAGE I638 WITH VBAP-POSNR.
    EXIT.
  ENDIF.

* globales Flag für Gesamtnetzterminierung setzen
  VBAP_GESAMTNETZTERMINIERUNG = CHARX.
  VBAP_ENDE_VERFUEGBARKEIT = CHARM.
  VBAP_ENDE_BEARBEITUNG    = CHARX.

* Montage statisch/Banf vorbereiten
  PERFORM XVBEP_LESEN_ERSTE(SAPFV45E) USING SPACE.
  PERFORM VBEP_BEARBEITEN_VORBEREITEN(SAPFV45E).      "Meldung VV400
  PERFORM VBEP_BEARBEITEN_BESCHAFFUNG(SAPFV45E).
  IF NOT T459K-MNTGA IS INITIAL.
    T185F-FCODE = FCODE_ZURUECK2.
    CLEAR MOAF.
  ENDIF.

* Bei Product Selection immer dunkel
  IF NOT VBAP-PROSA IS INITIAL.
    VBAP_ENDE_VERFUEGBARKEIT = CHARX.
  ENDIF.

* im den Kreditfällen Freigabe und Recheck muß bestätigte Menge
* aufgebaut werden.
  IF NOT VBUK_KREDIT_VFP IS INITIAL.
    VBAP_ENDE_VERFUEGBARKEIT = CHARX.
  ENDIF.

* Komplettlieferung aufgehoben: Dialog nur bei Unterdeckung
  IF *VBAK-AUTLF NE VBAK-AUTLF AND VBAK-AUTLF IS INITIAL.
    VBAP_ENDE_VERFUEGBARKEIT = CHARX.
  ENDIF.

* Liefersperre entfernt: Dialog nur bei Unterdeckung
  IF *VBAK-LIFSK NE VBAK-LIFSK AND VBAK-LIFSK IS INITIAL.
    VBAP_ENDE_VERFUEGBARKEIT = CHARX.
  ENDIF.

* ATP und Product Selection, bestätigte Menge
  VBAP_ENDE_BEARBEITUNG = CHARX.
  PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).

* globales Flag für Gesamtnetzterminierung zurücksetzen
  CLEAR VBAP_GESAMTNETZTERMINIERUNG.

ENDFORM.