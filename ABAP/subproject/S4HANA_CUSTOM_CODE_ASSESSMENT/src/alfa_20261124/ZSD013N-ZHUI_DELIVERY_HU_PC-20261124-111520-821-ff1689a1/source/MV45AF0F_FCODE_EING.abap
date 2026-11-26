*---------------------------------------------------------------------*
*       FORM FCODE_EING                                               *
*---------------------------------------------------------------------*
*       Bei Anlegen Auftrag in Bezug auf Wertkontrakt Matzerialien    *
*       eingeben                                                      *
*---------------------------------------------------------------------*
FORM FCODE_EING.

  DATA: DA_WKKOP LIKE TVCPA-WKKOP,
        DA_PSTYN LIKE TVCPA-PSTYN.

  PERFORM XVBAP_DETAIL(SAPFV45P).

  IF FCODE EQ FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    MESSAGE S678.
    LEAVE SCREEN.
  ENDIF.

* Darf ein Material außer dem Wertkontraktmaterial kopiert werden?
  PERFORM WERTKONTRAKT_KOPIEREN_PRUEFEN USING DA_WKKOP
                                              TVCPA-AUARN
                                              TVCPA-AUARV
                                              TVCPA-FKARV
                                              SPACE
                                              VBAP-PSTYV
                                              DA_PSTYN.

  IF DA_WKKOP EQ CHARB.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    MESSAGE S678.
    LEAVE SCREEN.
  ENDIF.

* Ist der Zielwert bereits erreicht?
  PERFORM WK_ABRUF_PRUEFEN_KOPIEREN USING SY-SUBRC
                                          VBAP.
  IF SY-SUBRC > 0.
    FCODE = FCODE_GLEICHE_SEITE.
    PERFORM FCODE_BEARBEITEN(SAPMV45A).
    LEAVE SCREEN.
  ENDIF.

* Die verwendeten Felder der Struktur RV45A müssen gefüllt werden:
  RV45A-SKOPF = VBAP-SKOPF.
  RV45A-POSNR = VBAP-POSNR.
  RV45A-PSTYV = VBAP-PSTYV.
  RV45A-WAERS = VBAP-WAERK.
  RV45A-PRODH = VBAP-PRODH.
  RV45A-SPART = VBAP-SPART.
  RV45A-PS_PSP_PNR = VBAP-PS_PSP_PNR.

* Zielpositionstyp muß gefüllt werden zur Bestimmung von KZFME bei
* Materialeingabe (in VBAP_UMRECHNUNGSFAKTOREN im PAI von Dynpro 471)
  SELECT SINGLE * FROM TVAP WHERE PSTYV = DA_PSTYN.

* Die Positionen des Vorgängerbelegs sollen nicht angezeigt werden,
* daher nur neue Positionen in IVBAP stellen
  PERFORM IVBAP_AUFBAUEN_WK_ABRUF_NEUE(SAPFV45P) USING RV45A-POSNR.
  IVBAP_TABIX_ZEILE_1 = 1.
  LOOP AT IVBAP.
    IVBAP-SELKZ = CHARX.
    MODIFY IVBAP.
  ENDLOOP.
ENDFORM.