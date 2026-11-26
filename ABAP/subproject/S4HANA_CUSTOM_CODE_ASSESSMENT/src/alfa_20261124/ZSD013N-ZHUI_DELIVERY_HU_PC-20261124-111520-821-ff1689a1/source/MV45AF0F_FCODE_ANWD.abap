*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_ANWD                                        *
*----------------------------------------------------------------------*

*----------------------------------------------------------------------*
*   FORM FCODE_ANWD                                                    *
*----------------------------------------------------------------------*
*   Zuordnen einer Kontraktposition zu einer bestehenden               *
*   Kundenauftragsposition                                             *
*----------------------------------------------------------------------*
FORM FCODE_ANWD.

  DATA: DA_SUBRC LIKE SY-SUBRC,
        DA_VBAP LIKE VBAP,
        DA_TVAP LIKE TVAP,
        DA_XKOMV TYPE TABLE OF KOMV WITH HEADER LINE.

  DATA: DA_UEPVW LIKE VBAP-UEPVW,
        DA_PROSA LIKE VBAP-PROSA,
        DA_SUGRD LIKE VBAP-SUGRD.

  LOCAL: TVCPA.

* Zuordnung nur möglich, wenn genau ein Quelleintrag da ist
  DESCRIBE TABLE CVBAP LINES SY-TABIX.
  IF SY-TABIX = 1.
*   Kopierkennzeichen setzen
    KOPIEREN = CHARX.
* TVCPA nachlesen
    PERFORM TVCPA_SELECT USING VBAK-AUART
                               CVBAK-AUART
                               SPACE
                               CVBAP-PSTYV
                               SPACE
                               SPACE
                               DA_SUBRC.

    CHECK DA_SUBRC = 0.

* Nicht zulassen, wenn der Vorgänger Einteilungen besitzt, da es dort
* Probleme mit der Bedarfsübergabe gibt
    SELECT SINGLE * FROM TVAP INTO DA_TVAP WHERE PSTYV = CVBAP-PSTYV.
    IF NOT DA_TVAP-ETERL IS INITIAL.
      MESSAGE I129(V2).
      EXIT.
    ENDIF.

* Für Wertkontraktpositionen muß CVBAP-VGPOS_WK gefüllt werden:
* (wird in VBAP_COPY_DATA_STANDARD benötigt)
    IF CVBAP-ERLRE EQ CON_ERLRE_WERTKONTRAKT.
      CVBAP-VGPOS_WK = CVBAP-POSNR.
* Ist der Zielwert bereits erreicht?
      DA_VBAP = CVBAP.
      PERFORM WK_ABRUF_PRUEFEN_KOPIEREN USING DA_SUBRC
                                              DA_VBAP.

      IF DA_SUBRC > 0.
        EXIT.
      ENDIF.

    ENDIF.

* CVBKD einlesen
    PERFORM CVBKD_LESEN USING CVBAP-VBELN
                              CVBAP-POSNR.

*   Zuordnung vornehmen
    LOOP AT XVBAP WHERE POSNR EQ VBAP-POSNR AND
                        UPDKZ NE UPDKZ_DELETE.
      SVBAP-TABIX = SY-TABIX.
      PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
      PERFORM VBAP_FUELLEN(SAPFV45P).
* Vorgängerbeleg in Position eintragen
      VBAP-VGBEL = CVBAP-VBELN.
      VBAP-VGPOS = CVBAP-POSNR.
      VBAP-VGTYP = CVBAK-VBTYP.
ENHANCEMENT-POINT FCODE_ANWD_10 SPOTS ES_SAPMV45A.
* Kennzeichen Update Belegfluß setzen
      VBAP-UPFLU = TVCPA-UPFLU.
      PERFORM VVBAP_LESEN(SAPFV45P) USING    VBAP-VGBEL
                                             VBAP-VGPOS
                                             VBAP-UPFLU
                                    CHANGING DA_SUBRC.
* save fields relevant for product selection as they should
* not be changed when assigning a contract
      DA_UEPVW = VBAP-UEPVW.
      DA_PROSA = VBAP-PROSA.
      DA_SUGRD = VBAP-SUGRD.
* Standard-Kopierroutine ablaufen lassen für Felder, die standardmäßig
* immer übernommen werden
      PERFORM VBAP_COPY_DATA_STANDARD(SAPFV45C).
      PERFORM VBKD_COPY_DATA_STANDARD(SAPFV45C) USING VBAP-POSNR.
ENHANCEMENT-POINT FCODE_ANWD_16 SPOTS ES_SAPMV45A.
* Konditionen kopieren
* Variantenkonditionen merken
      LOOP AT XKOMV WHERE KPOSN = VBAP-POSNR AND
                        ( KNTYP = 'O' OR
                          KNTYP = 'Q' ).
        APPEND XKOMV TO DA_XKOMV.
      ENDLOOP.
* alle Konditionen aus dem Vorgänger übernehmen außer Kalkulation
      CLEAR XKOMV.
      DELETE XKOMV WHERE KPOSN = VBAP-POSNR.

* delete the existing knumv(order specific) & the formula details from CPE buffer
      CALL FUNCTION 'CPE_ERP_FORMULA_DELETE'
        EXPORTING
          IV_KNUMV                = VBAK-KNUMV
          IV_KPOSN                = VBAP-POSNR
       EXCEPTIONS
          CPE_NOT_ACTIVE          = 1
          FORMULA_NOT_FOUND       = 2
          OTHERS                  = 3.


      PERFORM KONV_KOPIEREN(SAPFV45C) USING CVBAP-POSNR
                                            VBAP-POSNR
                                            TVCPA-KNPRS.
      DELETE XKOMV WHERE KPOSN = VBAP-POSNR AND
                         KNTYP = 'Q'.
      LOOP AT DA_XKOMV WHERE KPOSN = VBAP-POSNR AND
                             KNTYP = 'Q'.
        READ TABLE XKOMV WITH KEY KNUMV = DA_XKOMV-KNUMV
                                  KPOSN = DA_XKOMV-KPOSN
                                  STUNR = DA_XKOMV-STUNR
                                  ZAEHK = DA_XKOMV-ZAEHK
                                  BINARY SEARCH.
        INSERT DA_XKOMV INTO XKOMV INDEX SY-TABIX.
      ENDLOOP.

* Wenn konfiguriertes Material vorliegt und die Vorlagekonfiguration
* mit der Zielkonfiguration identisch ist, VA00 Konditionen
* des Vorlagebeleges übernehmen
* Wenn Konfiguration abweicht, sollen die Konditionen des Zielbeleges
* bestehen bleiben
      IF VBAP-MATNR = CVBAP-MATNR AND
         NOT VBAP-CUOBJ IS INITIAL AND
         NOT CVBAP-CUOBJ IS INITIAL AND
         VBAP-CUOBJ NE CVBAP-CUOBJ.
        CLEAR XKOMV.
        DELETE XKOMV WHERE KPOSN = VBAP-POSNR AND
                           KNTYP = 'O'.
        LOOP AT DA_XKOMV WHERE KPOSN = VBAP-POSNR AND
                               KNTYP = 'O'.
          READ TABLE XKOMV WITH KEY KNUMV = DA_XKOMV-KNUMV
                                    KPOSN = DA_XKOMV-KPOSN
                                    STUNR = DA_XKOMV-STUNR
                                    ZAEHK = DA_XKOMV-ZAEHK
                                    BINARY SEARCH.
          INSERT DA_XKOMV INTO XKOMV INDEX SY-TABIX.
        ENDLOOP.
      ENDIF.
* recover product selection relevant fields
      VBAP-UEPVW = DA_UEPVW.
      VBAP-PROSA = DA_PROSA.
      VBAP-SUGRD = DA_SUGRD.

ENHANCEMENT-POINT FCODE_ANWD_11 SPOTS ES_SAPMV45A.

* Preisfindung erneut ablaufen lassen
      PERFORM PREISFINDUNG(SAPFV45P) USING TVCPA-KNPRS.
      MESSAGE I209.

* Bearbeitung vollenden
      PERFORM VBAP_BEARBEITEN(SAPFV45P).
      PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).
ENHANCEMENT-POINT FCODE_ANWD_01 SPOTS ES_SAPMV45A.
      MESSAGE S730 WITH CVBAP-VBELN CVBAP-POSNR VBAP-POSNR.
      EXIT.
    ENDLOOP.
    CLEAR KOPIEREN.
  ENDIF.

ENDFORM.