*----------------------------------------------------------------------*
*   FORM MV45AF0F_FCODE_CRLT                                           *
*----------------------------------------------------------------------*
FORM FCODE_CRLT.

  DATA:
    DA_SUBRC LIKE SY-SUBRC,
    DA_STLNR LIKE VBAP-STLNR,
    BEGIN OF IT_GRKOR OCCURS 0,
      GRKOR LIKE VBAP-GRKOR,
    END OF IT_GRKOR.

* Aktuelle Position
  PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING DA_SUBRC.
  IF DA_SUBRC GT 0.
* Cursor steht auch nicht auf einer Zeile
    MESSAGE S323.
    EXIT.
  ENDIF.
  IT_GRKOR-GRKOR = XVBAP-GRKOR.
  APPEND IT_GRKOR.

* Alle markierten Liefergruppen merken
  LOOP AT IVBAP WHERE SELKZ EQ SELEKTIERT.
    READ TABLE XVBAP INDEX IVBAP-TABIX.
    IF SY-SUBRC NE 0.
* Indexaufbau fehlerhaft
      MESSAGE A322 WITH 'XVBAP'.
    ENDIF.
    IT_GRKOR-GRKOR = XVBAP-GRKOR.
    COLLECT IT_GRKOR.
  ENDLOOP.

* Für alle markierten Liefergruppen die Gruppenprüfung vorbereiten
  LOOP AT IT_GRKOR.

    IF IT_GRKOR-GRKOR IS INITIAL AND VBAK-AUTLF IS INITIAL
    OR ATP_GRUPPENAUFRUF NE CHARX.
      MESSAGE S812(AG).
      CONTINUE.
    ENDIF.

    CLEAR DA_STLNR.

    LOOP AT XVBAP WHERE GRKOR EQ IT_GRKOR-GRKOR
                  AND   UPDKZ NE UPDKZ_DELETE.
      SVBAP-TABIX = SY-TABIX.
      IF XVBAP-STLNR IS NOT INITIAL.
        DA_STLNR = XVBAP-STLNR.
      ENDIF.
      PERFORM GVBAP_ANREICHERN(SAPFV45V) USING XVBAP-GRKOR
                                               XVBAP-POSNR
                                               XVBAP-MATNR
                                               XVBAP-WERKS
                                               XVBAP-STLNR
                                               SPACE.
      CHECK GVBAP-NOAPO IS INITIAL.
      PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
      PERFORM TVAP_SELECT USING VBAP-PSTYV
                                SPACE
                                DA_SUBRC.
      VBAP_ENDE_BEARBEITUNG    = CHARX.
      VBAP_ENDE_VERFUEGBARKEIT = CHARM.
      PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).
    ENDLOOP.

    IF DA_STLNR IS INITIAL.
      PERFORM LIEFERGRUPPE_NO_APO(SAPFV45V) USING IT_GRKOR-GRKOR.
    ENDIF.

  ENDLOOP.

* Ein gemeinsamer Aufruf für alle Liefergruppen (analog zu FCODE BVFP)
  PERFORM VERFUEGBARKEIT_PRUEFEN_GRUPPEN(SAPFV45P) USING VERARB_HELL.

ENDFORM.