*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WA                                            *
*---------------------------------------------------------------------*
*        Die Fusszeile fuer die Transaktionen Warenbewegungen ohne    *
*        Referenzbeleg wird bearbeitet.                               *
*---------------------------------------------------------------------*
FORM FUSSZEILE_WA USING IS_ENHANCEMENT TYPE ISU_FUSSZEILE_WA."IS2ERP

  CHECK xpf02 IS INITIAL OR xpf02 = x.
  CHECK t158-trtyp = h.
  DATA: LS_ISU_FUSSZEILE_WA_PRUEFEN TYPE ISU_FUSSZEILE_WA_PRUEFEN."IS2ERP

ENHANCEMENT-POINT FUSSZEILE_WA_03 SPOTS ES_SAPMM07M.
* if mseg-kzear has been set on the screen dm07m-kzear_inp       "533295
* will help to avoid the check which automatically delete        "533295
* mseg-kzear in case of return delivery and cancellation.        "533295
  DM07M-KZEAR_INP = MSEG-KZEAR.                                  "533295
  READ TABLE bild INDEX 1.
  IF NOT sy-subrc IS INITIAL AND NOT fcausw-xaenp IS INITIAL AND
     NOT fcausw-xlist IS INITIAL AND NOT mseg-matnr IS INITIAL.
    fcode = fcod-nl.
    PERFORM fcode_lesen USING fcode.
  ENDIF.
  IF NOT fcausw-xneup IS INITIAL.
    IF fuss-xprue IS INITIAL OR
       ( mseg-rsnum IS INITIAL AND mseg-mblnr IS INITIAL
         AND mseg-kzzug IS INITIAL ).
      MOVE-CORRESPONDING dm07m TO dm07m_merken.
      ENHANCEMENT-POINT FUSSZEILE_WA_01 SPOTS ES_SAPMM07M.
      MOVE-CORRESPONDING VM07M TO VM07M_MERKEN.
* für später evtl. zu erzeugende Unterpositionen (Nat.rabatt, Leergut)
      MOVE-CORRESPONDING mseg TO mseg_merken.
      CLEAR: dm07m, vm07m, mseg-bwtar, mseg-matbf.
      perform j_1b_tax_proc_set.  "localization Brazil note 205012
      MOVE-CORRESPONDING dm07m_merken TO dm07m.
      ENHANCEMENT-POINT FUSSZEILE_WA_02 SPOTS ES_SAPMM07M.
      MOVE-CORRESPONDING VM07M_MERKEN TO VM07M.
      PERFORM FUSSZEILE_WA_PRUEFEN USING X
                                         LS_ISU_FUSSZEILE_WA_PRUEFEN."IS2ERP

    ELSEIF     NOT MSEG-BWART IS INITIAL                         "524472
           AND NOT MSEG-BWART  = T156-BWART                      "524472
           and     t156-kzbwa  = 'SZ'.        "sub item of str. art.
*     T156 still has data from previous sub item (317, 319...)   "524472
      PERFORM BEWEGUNGSART_PRUEFEN(SAPFM07M) USING MSEG-BWART    "524472
                                                   MSEG-XAUTO.   "524472
    ENDIF.
    fuss-xselp = x.
    IF NOT fcausw-xlist IS INITIAL.
*     APPEND auf FUSS beim autom. Anlegen von Bestellungen in
*     KONDITIONSSATZ_SUCHEN
      IF NOT t156-xnebe IS INITIAL.
        CHECK rm07m-kzbew NE b.
      ENDIF.
      PERFORM fuss_fuellen USING space.
    ENDIF.
  ENDIF.
  IF NOT fcausw-xselp IS INITIAL AND NOT fcausw-xlist IS INITIAL.
    IF NOT t063o-auswa IS INITIAL AND t063o-auswa NE p.
      rm07m-xselk = kreuz.
      IF rm07m-zeile IS INITIAL.
        rm07m-zeile = mseg-zeile.
      ENDIF.
    ENDIF.
    READ TABLE bild INDEX 1.
    IF sy-subrc IS INITIAL.
      IF bild-zeile NE mseg-zeile.
        MESSAGE e001 WITH 'BILD' mseg-zeile.
      ENDIF.
      mseg-xauto = bild-xauto.
      mseg-urzei = bild-urzei.
      mseg-sgtxt = bild-sgtxt.                             "n_755299
      a_zeile = mseg-zeile - m_zeile.
      PERFORM segment_lesen USING i.
      IF rc NE 0.
        MESSAGE e001 WITH 'FUSS' mseg-zeile.
      ENDIF.
      IF NOT fuss-mekor IS INITIAL.
        PERFORM uebernahme_hauptpos.
      ENDIF.
      IF mseg-xauto = s OR mseg-xauto = u OR mseg-xauto = l.
        rm07m-xselk = fuss-xselk.
      ENDIF.
      MOVE-CORRESPONDING mseg TO bild.
      MOVE-CORRESPONDING bild TO fuss.
ENHANCEMENT-POINT MM07MFF0_FUSSZEILE_WA_01 SPOTS ES_SAPMM07M.
      IF fuss-xprue IS INITIAL AND NOT rm07m-xselk IS INITIAL.
        MOVE-CORRESPONDING fuss TO dm07m.
        MOVE-CORRESPONDING fuss TO vm07m.
        MOVE-CORRESPONDING fuss TO mseg.
        PERFORM FUSSZEILE_WA_PRUEFEN USING X
                                    LS_ISU_FUSSZEILE_WA_PRUEFEN."IS2ERP

        MOVE-CORRESPONDING dm07m TO fuss.
        MOVE-CORRESPONDING vm07m TO fuss.
        MOVE-CORRESPONDING mseg TO fuss.
        fuss-xprue = x.
      ENDIF.
      IF fuss-xselk = rm07m-xselk.
        CLEAR vw.
      ELSE.
        fuss-xselk = rm07m-xselk.
        vw = x.
      ENDIF.
      MODIFY fuss INDEX a_zeile.
      DELETE bild INDEX 1.
      IF NOT vw IS INITIAL.
        LOOP AT fuss WHERE urzei = mseg-urzei
                     AND   xauto <> space.
          fuss-xselk = rm07m-xselk.
          MODIFY fuss INDEX sy-tabix.
        ENDLOOP.
      ENDIF.
ENHANCEMENT-POINT MM07MFF0_FUSSZEILE_WA_02 SPOTS ES_SAPMM07M.
    ELSE.
      CLEAR xkont.
    ENDIF.
  ENDIF.
  IF NOT fcausw-xaenp IS INITIAL.
    READ TABLE bild INDEX 1.
    IF sy-subrc IS INITIAL.
      IF bild-zeile NE mseg-zeile.
        MESSAGE e001 WITH 'BILD' mseg-zeile.
      ENDIF.
      mseg-xauto = bild-xauto.
      mseg-urzei = bild-urzei.
      IF mseg-sgtxt IS initial.                            "n_837447
       mseg-sgtxt = bild-sgtxt.                            "n_837447
      ENDIF.                                               "n_837447
      a_zeile = mseg-zeile.
      PERFORM segment_lesen USING i.
      IF NOT rc IS INITIAL.
        MESSAGE e001 WITH 'YMSEG' mseg-zeile.
      ENDIF.
      IF mseg-erfmg NE ymseg-erfmg OR
         mseg-kzear NE ymseg-kzear AND NOT fcausw-xlist IS INITIAL OR
*        ( CCODE = CCOD-MATR AND MATRIX_KOPF = MSEG-ZEILE ).      " PPF
         ( ( ccode = ccod-matr OR ccode = ccod-reac ) AND         " PPF
          matrix_kopf = mseg-zeile ).  " PPF
        MOVE-CORRESPONDING mseg TO bild.
        MOVE-CORRESPONDING ymseg TO mseg.
        MOVE-CORRESPONDING yvm07m TO vm07m.
        MOVE-CORRESPONDING ydm07m TO dm07m.
        MOVE-CORRESPONDING bild TO mseg.
        fuss-xselp = x.
*       IF CCODE = CCOD-MATR AND MATRIX_KOPF = MSEG-ZEILE.        " PPF
        IF ( ccode = ccod-matr OR ccode = ccod-reac )             " PPF
            AND matrix_kopf = mseg-zeile.                         " PPF
          CLEAR matrix_kopf.
          fuss-xmatrix = x.
        ENDIF.
        PERFORM fuss_fuellen USING space.
      ENDIF.
      DELETE bild INDEX 1.
    ELSE.
      CLEAR xkont.
      READ TABLE biwe INDEX 1.
      IF sy-subrc IS INITIAL.
        IF NOT biwe-zeile = mseg-zeile.
          MESSAGE e001 WITH 'BIWE' mseg-zeile.
        ENDIF.
        DELETE biwe INDEX 1.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    "fusszeile_wa