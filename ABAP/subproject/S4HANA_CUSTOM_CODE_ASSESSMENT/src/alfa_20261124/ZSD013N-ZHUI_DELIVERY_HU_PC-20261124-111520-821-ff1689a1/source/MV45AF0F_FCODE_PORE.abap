*---------------------------------------------------------------------*
*       FORM FCODE_PORE                                               *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Verfügbarkeitsprüfung                    *
*       - ATP der Hauptposition                                       *
*       - Product Selection                                           *
*       - Montageauftrag (Komponenten)                                *
*---------------------------------------------------------------------*
FORM FCODE_PORE.

  DATA: DA_SUBRC LIKE SY-SUBRC,
        DA_CHECK_THIRD_PARTY TYPE C.

* Checking third-party or ind. purchase order items is default.
  DA_CHECK_THIRD_PARTY = CHARX.

* ProdSel-Unterposition wird immer Über Hauptposition geprüft
  CHECK VBAP-UEPVW NE CHARA.

* bereits belieferte ProdSel-Hauptposition wird nicht mehr geprüft
  PERFORM XVBUP_LESEN(SAPFV45P) USING VBAP-VBELN
                                      VBAP-POSNR.

  CHECK VBAP-PROSA NE CHARC.

  CHECK ( VBAP-PROSA NE CHARA OR
          XVBUP-LFSTA CA 'A ' OR
          NOT XVBAP-SRCPS IS INITIAL ).

* Position aus Produktvorschlag nicht pruefen
  CHECK VBAPD-PVPOS IS INITIAL.

  PERFORM TVAP_SELECT USING VBAP-PSTYV
                            SPACE
                            DA_SUBRC.

  IF DA_SUBRC = 0 AND
     TVAP-ETERL IS INITIAL.
    IF VBUK_KREDIT_VFP IS INITIAL.
      MESSAGE I763 WITH VBAP-POSNR.
    ENDIF.
    EXIT.
  ENDIF.

  IF VBAP-WERKS EQ SPACE AND
     VBAP-PROSA NE CHARA.
    MESSAGE I186 WITH VBAP-POSNR.
    EXIT.
  ENDIF.

  CHECK XVBAP-SRCPS NE SRCPS_SUBITEM.
* (M)anueller Aufruf der Verfügbarkeit, Abfrage auf 'M' in SAPFV45V
* und FV45EFMA, deswegen vor VBEP_BEARBEITEN_BESCHAFFUNG
* If the sold-to-party is changed and if in ovzj the check rule is B
* then vbap_ende_verfuegbarkeit is set to chara. In this case donot show the delivery
* proposal screen.
  IF vbap_ende_verfuegbarkeit = chara.
    vbap_ende_verfuegbarkeit = charx.
  ELSE.
    vbap_ende_verfuegbarkeit = charm.
  ENDIF.
  VBAP_ENDE_BEARBEITUNG    = CHARX.

* Montage statisch/Banf vorbereiten
  READ TABLE IVBEP1 WITH KEY POSNR = VBAP-POSNR
                    BINARY SEARCH TRANSPORTING NO FIELDS.
  LOOP AT IVBEP1 FROM SY-TABIX.
    IF IVBEP1-POSNR NE VBAP-POSNR.
      EXIT.
    ENDIF.
    READ TABLE XVBEP INDEX IVBEP1-TABIX.
    IF SY-SUBRC NE 0.
      MESSAGE A322 WITH 'IVBEP1'.
    ENDIF.

    PERFORM TVEP_SELECT USING XVBEP-ETTYP
                              SPACE
                              SY-SUBRC.
    IF SY-SUBRC NE 0.
      MESSAGE A353 WITH XVBEP-ETTYP.
    ENDIF.

*   Always check third-party if complete delivery flag is removed
    IF VBAK-AUTLF EQ *VBAK-AUTLF OR
       NOT VBAK-AUTLF IS INITIAL.
*     Detect schedule lines with confirmed PO items
      IF XVBEP-BMENG GT 0           AND
         NOT TVEP-BSART  IS INITIAL AND
         NOT XVBEP-BNFPO IS INITIAL AND
         XVBEP-WEPOS EQ CHARC       AND
         XVBEP-EDATU GE SY-DATUM.
        CLEAR DA_CHECK_THIRD_PARTY.
      ENDIF.
    ENDIF.

    SVBEP-TABIX = IVBEP1-TABIX.
    CHECK XVBEP-CMENG GT 0.
    PERFORM VBEP_BEARBEITEN_VORBEREITEN(SAPFV45E).
* TAS/TAB sollen nur einmal geprüft werden
    CHECK TVEP-BSART       IS INITIAL
       OR XVBEP-BNFPO      IS INITIAL
       OR PORE_THIRD_PARTY NE SPACE.
    IF VBEP-BNFPO IS INITIAL AND
       VBEP-AUFNR IS INITIAL AND
       TVEP-BEDSD IS INITIAL AND
       TVAK-TRTRM IS INITIAL AND
       TVAK-VSTRM IS INITIAL.
      PERFORM T459K_LESEN(SAPMV45A).
      IF   ( TVEP-ATPPR IS INITIAL OR T459K-ATPPR IS INITIAL )
       AND ( TVEP-QUOTA IS INITIAL OR T459K-QUOTA IS INITIAL
                                   OR VBAP-KOSCH  IS INITIAL )
       AND NOT ( VBUK-CMGST CA 'B' ) .
        VBEP-BMENG = VBEP-CMENG.
        PERFORM VBEP_FUELLEN(SAPFV45E).                    "note 628524
        PERFORM VBEP_BEARBEITEN_NORMAL(SAPFV45E).
      ENDIF.
    ENDIF.
    PERFORM VBEP_BEARBEITEN_BESCHAFFUNG(SAPFV45E).
    IF NOT EBAN-EBELN    IS INITIAL AND
       NOT EBAN-EPROFILE IS INITIAL.          "SRM 3.0, external PO
      CLEAR DA_CHECK_THIRD_PARTY.
    ENDIF.
  ENDLOOP.

* TAB/TAS sollen nur einmal geprüft werden
  IF NOT TVEP-BSART IS INITIAL AND
     NOT XVBEP-BNFPO IS INITIAL AND
     VBUK_KREDIT_VFP IS INITIAL AND
     ( PORE_THIRD_PARTY IS INITIAL OR
       DA_CHECK_THIRD_PARTY IS INITIAL ) AND
     VBAK-LIFSK EQ *VBAK-LIFSK.
    CLEAR: VBAP_ENDE_VERFUEGBARKEIT, VBAP_ENDE_BEARBEITUNG.
    EXIT.
  ENDIF.

  IF NOT T459K-MNTGA IS INITIAL.
    T185F-FCODE = FCODE_ZURUECK2.
    CLEAR MOAF.
  ENDIF.

* Bei Product Selection immer dunkel
  IF NOT VBAP-PROSA IS INITIAL AND XVBAP-SRCPS IS INITIAL.
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
  IF *VBAK-LIFSK NE VBAK-LIFSK.
    VBAP_ENDE_VERFUEGBARKEIT = CHARX.
  ENDIF.

* ATP und Product Selection, bestätigte Menge
  PERFORM VBAP_BEARBEITEN_ENDE(SAPFV45P).

ENDFORM.