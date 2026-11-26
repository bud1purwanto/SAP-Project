*----------------------------------------------------------------------*
*   INCLUDE MV45AFFE_FELDAUSWAHL_VBAP_MAT1                             *
*----------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_VBAP-MATNR                                   *
*---------------------------------------------------------------------*
*       Eingabebereitschaftsregel MATNR                               *
*---------------------------------------------------------------------*
FORM FELDAUSWAHL_VBAP-MATNR CHANGING VALUE(CH_SUBRC).

  DATA: DA_SUBRC LIKE SY-SUBRC,
        DA_VBAP LIKE VBAP.

  LOCAL: VBAP,
         VBAPD,
         XVBAP,
         XVBUP,
         TVAP,
         XVBFA,
         XVBAPF.

  PERFORM FELDAUSWAHL_VBAP-MATNR_SPEZ CHANGING CH_SUBRC.

  IF CH_SUBRC = 0 AND
     SCREEN-NAME = 'VBAP-PSTYV'.
    DA_VBAP = VBAP.

* Wenn es sich um eine Hauptposition handelt und die Unterpositionen
* nicht mehr geändert werden dürfen, dann darf auch die Hauptposition
* wegen der Auswirkungen auf Unterpositionen nicht mehr geändert werden
    LOOP AT UVBAP WHERE UEPOS EQ DA_VBAP-POSNR.
*     Zunächst die erforderlichen Daten zur Verfügung stellen
      LOOP AT XVBAP WHERE VBELN EQ DA_VBAP-VBELN AND
                          POSNR EQ UVBAP-POSNR   AND
                          UPDKZ NE UPDKZ_DELETE.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC > 0.
        CONTINUE.
      ENDIF.
      VBAP = XVBAP.
      MOVE-CORRESPONDING XVBAP TO VBAPD.
      LOOP AT XVBUP WHERE VBELN EQ DA_VBAP-VBELN AND
                          POSNR EQ UVBAP-POSNR   AND
                          UPDKZ NE UPDKZ_DELETE.
        EXIT.
      ENDLOOP.
      IF SY-SUBRC > 0.
        CLEAR XVBUP.
      ENDIF.
      READ TABLE XVBAPF WITH KEY VBELN = VBAP-VBELN
                                 POSNR = VBAP-POSNR.
      IF SY-SUBRC > 0.
        CLEAR XVBAPF.
      ENDIF.
      PERFORM TVAP_SELECT USING VBAP-PSTYV
                                SPACE
                                DA_SUBRC.
      IF DA_SUBRC > 0.
        CLEAR TVAP.
      ENDIF.

*     Prüfung für Unterpositionen durchführen
      PERFORM FELDAUSWAHL_VBAP-MATNR_SPEZ CHANGING CH_SUBRC.

*     Wenn nicht eingabebereit, dann sofort nach außen weitergeben
      IF CH_SUBRC > 0.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDIF.

ENDFORM.