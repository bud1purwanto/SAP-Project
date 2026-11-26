*eject
*---------------------------------------------------------------------*
*        FORM FUSSZEILE_WE                                            *
*---------------------------------------------------------------------*
*        Die Fusszeile fuer die Transaktionen Wareneingang zur        *
*        Bestellung wird bearbeitet.                                  *
*---------------------------------------------------------------------*
FORM fusszeile_we USING IS_ENHANCEMENT TYPE ISU_FUSSZEILE_WE."IS2ERP

  CHECK xpf02 IS INITIAL OR xpf02 = x.
  CHECK t158-trtyp = h.
  CLEAR: xkzbew, next_xkzbew.

  DATA: LS_ISU_UMRECHNEN_ME         TYPE ISU_UMRECHNEN_ME,  "IS2ERP
     LS_ISU_FUSSZEILE_WA_PRUEFEN TYPE ISU_FUSSZEILE_WA_PRUEFEN,"IS2ERP
     LS_ISU_FUSSZEILE_WE_PRUEFEN TYPE ISU_FUSSZEILE_WE_PRUEFEN."IS2ERP

ENHANCEMENT-POINT FUSSZEILE_WE_01 SPOTS ES_SAPMM07M.

  IF NOT fcausw-xneup IS INITIAL.
    IF mseg-bwart IS INITIAL.
      mseg-bwart = rm07m-bwart.
    ENDIF.
    IF NOT mseg-bwart = t156-bwart.
      PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                   mseg-xauto.
*     IF dm07m-xlort is initial.
      IF dm07m-xlort is initial and mseg-kzbew ne o.     "338232
        PERFORM mengenstring_finden(sapfm07m) USING mseg-bwart
                                                    mseg-wertu
                                                    mseg-mengu
                                                    mseg-sobkz
                                                    mseg-kzbew
                                                    mseg-kzzug
                                                    mseg-kzvbr
                                                    mseg-matnr
                                                    mseg-kzbws.
      ENDIF.
      IF NOT mseg-ebeln IS INITIAL AND mseg-ebeln NE auto_best.
        CLEAR vm07m-xnebe.
      ENDIF.
    ENDIF.
    IF fuss-xprue IS INITIAL.
      PERFORM fusszeile_we_pruefen USING x
                                         LS_ISU_FUSSZEILE_WE_PRUEFEN."IS2ERP
    ENDIF.
*SPE ST 27.05.2005 VL-MM Consistency
    IF /spe/cl_cust=>is_vl_mm_active( ) = 'X'.
      PERFORM fusszeile_asn_we_pruefen.
    ENDIF.
  ENDIF.
  IF NOT fcausw-xselp IS INITIAL.
*                  * im Anzeigemodus T156-Daten zu aktueller    "311583
*                  * Zeile nachlesen. Notwendig bei Zeilen-     "311583
*                  * unterstrukturen mit eigener BWA (z.B.      "311583
*                  * strukturierte Artikel)                     "311583
    IF     NOT MSEG-BWART IS INITIAL                            "311583
       AND NOT MSEG-BWART = T156-BWART.                         "311583
      PERFORM BEWEGUNGSART_PRUEFEN(SAPFM07M) USING MSEG-BWART   "311583
                                                   MSEG-XAUTO.  "311583
    ENDIF.                                                      "311583
    IF NOT t063o-auswa IS INITIAL AND t063o-auswa NE p.
      rm07m-xselk = kreuz.
    ENDIF.
    READ TABLE biwe INDEX 1.
    IF sy-subrc IS INITIAL.
      IF biwe-zeile NE mseg-zeile.
        MESSAGE e001 WITH 'BIWE' mseg-zeile.
      ENDIF.
      mseg-xauto = biwe-xauto.
      mseg-urzei = biwe-urzei.
      a_zeile = mseg-zeile - m_zeile.
* im Falle Sammelartikel: a_zeile anders bestimmen
      IF mseg-zeile <= m_zeile  AND  mseg-zeile = mseg-urzei.
        PERFORM fusszeile_samat_index.
      ENDIF.
      PERFORM segment_lesen USING i.
      IF NOT fuss-mekor IS INITIAL.
        PERFORM uebernahme_hauptpos.
      ENDIF.
      IF rc NE 0.
        MESSAGE e001 WITH 'FUSS' mseg-zeile.
      ENDIF.
      IF mseg-xauto = s OR mseg-xauto = u. "or mseg-xauto = l.
        rm07m-xselk = fuss-xselk.
      ENDIF.
      IF mseg-lgort NE fuss-lgort AND NOT mseg-lgort IS INITIAL
                                  AND mseg-lgort NA stern.
        CLEAR xt001l.
        xt001l-werks = mseg-werks.
        xt001l-lgort = mseg-lgort.
        xt001l-xlong = dm07m-xlong.
        PERFORM lagerort_pruefen(sapfm07m) USING xt001l
                                                 mseg-bwart.
        dm07m-xlong = xt001l-xlong.
      ENDIF.
      DATA kzbew LIKE mseg-kzbew.
*     Not clear when GI items processed by FUSSZEILE_WE in dialog
      IF fuss-kzbew IS INITIAL AND im_process IS INITIAL    "note 216916
      OR ( ( NOT fuss-kzbew = b AND im_process = l )        "note 216916
      AND fuss-vbeln IS INITIAL ).                          "note 216916
        MOVE-CORRESPONDING mseg TO bild.
        MOVE-CORRESPONDING bild TO fuss.
        IF fuss-xprue IS INITIAL AND NOT rm07m-xselk IS INITIAL.
          MOVE-CORRESPONDING fuss TO dm07m.
          MOVE-CORRESPONDING fuss TO vm07m.
          MOVE-CORRESPONDING fuss TO mseg.
          kzbew = rm07m-kzbew.
          rm07m-kzbew = fuss-kzbew.
          PERFORM fusszeile_wa_pruefen USING x
                                             LS_ISU_FUSSZEILE_WA_PRUEFEN."IS2ERP
          rm07m-kzbew = kzbew.
          MOVE-CORRESPONDING dm07m TO fuss.
          MOVE-CORRESPONDING vm07m TO fuss.
          MOVE-CORRESPONDING mseg TO fuss.
          fuss-xprue = x.
        ENDIF.
      ELSE.
* LS-Menge und Einheit ist in Dynpro 221 nicht vorhanden; Basismenge und
* Basismengeneinheit ist umgekehrt bei den Dynpros 222,223 und 224 nicht
* vorhanden !
        IF sy-dynnr = 221.
          mseg-lsmng = fuss-lsmng.
          mseg-lsmeh = fuss-lsmeh.
        ENDIF.
        IF sy-dynnr = 222 OR
           sy-dynnr = 223 OR
           sy-dynnr = 224.
          mseg-menge = fuss-menge.
          mseg-meins = fuss-meins.
        ENDIF.
        IF NOT mseg-matnr IS INITIAL AND
           ( mseg-erfmg NE fuss-erfmg OR mseg-erfme NE fuss-erfme ).
          mseg-menge = 0.
          IF fuss-bstme = mseg-erfme.
            dm07m-umrez = fuss-bumrz.
            dm07m-umren = fuss-bumrn.
          ELSE.
            CLEAR: dm07m-umrez, dm07m-umren.
          ENDIF.
ENHANCEMENT-POINT OI_MM07MFF0_FUSSZEILE_WE SPOTS ES_SAPMM07M .
          PERFORM umrechnen_me(sapfm07m) USING mseg-matnr
                                               mseg-charg  "ALR014884 SW
                                               mseg-werks  "ALR014884 SW
*                                               mseg-cuobj "ALR014884 SW
                                               mseg-meins
                                               mseg-erfme
                                               mseg-menge
                                               mseg-erfmg
                                              dm07m-umrez
                                              dm07m-umren
                                              LS_ISU_UMRECHNEN_ME."IS2ERP
        ENDIF.
* Umrechnung Lieferscheinmenge prüfen
        IF NOT mseg-lsmng IS INITIAL AND
           ( mseg-lsmng NE fuss-lsmng OR mseg-lsmeh NE fuss-lsmeh ).
          IF mseg-lsmeh IS INITIAL.
            mseg-lsmeh = mseg-erfme.
          ENDIF.
          DATA: h_lsbmg LIKE mseg-menge.
          IF mseg-lsmeh  NE  mseg-bstme.
            CALL FUNCTION 'MB_UNIT_CONVERSION'
                 EXPORTING
                      matnr                = mseg-matnr
                      charg                = mseg-charg   "ALR014884 SW
                      werks                = mseg-werks   "ALR014884 SW
*                      cuobj                = mseg-cuobj  "ALR014884 SW
                      meins                = mseg-meins
                      erfme                = mseg-lsmeh
                      menge                = h_lsbmg
                      erfmg                = mseg-lsmng
                 IMPORTING
                      o_menge              = h_lsbmg
                      o_erfmg              = mseg-lsmng
                 EXCEPTIONS
                      conversion_not_found = 4.
          ELSE.
            CALL FUNCTION 'MB_UNIT_CONVERSION'
                 EXPORTING
                      erfme                = mseg-lsmeh
                      erfmg                = mseg-lsmng
                      matnr                = mseg-matnr
                      meins                = mseg-meins
                      menge                = h_lsbmg
                      umren                = dm07m-umren
                      umrez                = dm07m-umrez
                      charg                = mseg-charg
                      werks                = mseg-werks
                 IMPORTING
                      o_erfmg              = mseg-lsmng
                      o_menge              = h_lsbmg
                 EXCEPTIONS
                      conversion_not_found = 4.
          ENDIF.
          IF NOT sy-subrc IS INITIAL.
            SET CURSOR FIELD 'MSEG-LSMEH' LINE sy-stepl.
            MESSAGE e026 WITH mseg-lsmeh mseg-meins.
          ENDIF.
        ENDIF.
        MOVE-CORRESPONDING mseg TO biwe.
        biwe-elikz_input = dm07m-elikz_input.
        IF sy-dynnr = 222.
          biwe-idnlf = dm07m-idnlf.
        ELSEIF sy-dynnr = 223.
          biwe-ean11_bme = dm07m-ean11_bme.
        ELSEIF sy-dynnr = 224.
          biwe-vfdat_input = dm07m-vfdat_input.
          biwe-hsdat_input = dm07m-hsdat_input.
        ENDIF.
        MOVE-CORRESPONDING biwe TO fuss.
        IF fuss-xprue IS INITIAL AND NOT rm07m-xselk IS INITIAL AND
           xmbwl IS INITIAL.
* warning about special services
          PERFORM vas_relevanz_pruefen.
        ENDIF.
        IF fuss-xprue IS INITIAL AND NOT rm07m-xselk IS INITIAL.
          MOVE-CORRESPONDING fuss TO dm07m.
          MOVE-CORRESPONDING fuss TO vm07m.
          MOVE-CORRESPONDING fuss TO mseg.
          maktx = fuss-maktx.
*         Not clear when GI items processed by FUSSZEILE_WE in dialog
          IF NOT fuss-kzbew = b AND im_process = l    "note 216916
          AND NOT fuss-vbeln IS INITIAL.              "note 216916
            kzbew = rm07m-kzbew.
            rm07m-kzbew = fuss-kzbew.
            PERFORM fusszeile_wa_pruefen USING x
                                               LS_ISU_FUSSZEILE_WA_PRUEFEN.   "IS2ERP
            rm07m-kzbew = kzbew.
          ELSE.
            PERFORM fusszeile_we_pruefen USING x
                                               LS_ISU_FUSSZEILE_WE_PRUEFEN. "IS2ERP
*SPE ST 27.05.2005 VL-MM Consistency
            IF /spe/cl_cust=>is_vl_mm_active( ) = 'X'.
              PERFORM fusszeile_asn_we_pruefen.
            ENDIF.
          ENDIF.
          MOVE-CORRESPONDING dm07m TO fuss.
          MOVE-CORRESPONDING vm07m TO fuss.
          MOVE-CORRESPONDING mseg TO fuss.
*         Clear ist erforderlich, da BIWE-ELIKZ_INPUT nicht auf
*         dem Dynpro ist und daher nicht initialsiert wird.
*         Daher wurde für alle Positionen ELIKZ_INPUT gesetzt, die
*         auf die Position gefolgt sind, in der ELIKZ geändert wurde.
          clear dm07m-elikz_input.
          fuss-maktx = maktx.
          fuss-xprue = x.
        ENDIF.
      ENDIF.
      IF fuss-xselk = rm07m-xselk.
        CLEAR vw.
      ELSE.
        fuss-xselk = rm07m-xselk.
        vw = x.
      ENDIF.
      MODIFY fuss INDEX a_zeile.
      DELETE biwe INDEX 1.
      CLEAR DM07M-ELIKZ_INPUT.
      IF NOT vw IS INITIAL.
        LOOP AT fuss WHERE urzei = mseg-urzei
                     AND   xauto <> space.
          fuss-xselk = rm07m-xselk.
          MODIFY fuss INDEX sy-tabix.
        ENDLOOP.
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT fcausw-xaenp IS INITIAL.
    READ TABLE biwe INDEX 1.
    IF sy-subrc IS INITIAL.
      IF biwe-zeile NE mseg-zeile.
        MESSAGE e001 WITH 'BIWE' mseg-zeile.
      ENDIF.
      mseg-xauto = biwe-xauto.
      mseg-urzei = biwe-urzei.
      a_zeile = mseg-zeile.
      PERFORM segment_lesen USING i.
      IF rc NE 0.
        MESSAGE e001 WITH 'YMSEG' mseg-zeile.
      ENDIF.
* LS-Menge und Einheit ist in Dynpro 221 nicht vorhanden; Basismenge und
* Basismengeneinheit ist umgekehrt bei den Dynpros 222,223 und 224 nicht
* vorhanden !
      IF sy-dynnr = 221.
        mseg-lsmng = biwe-lsmng.
        mseg-lsmeh = biwe-lsmeh.
      ENDIF.
      IF sy-dynnr = 222 OR
         sy-dynnr = 223 OR
         sy-dynnr = 224.
        mseg-menge = biwe-menge.
        mseg-meins = biwe-meins.
      ENDIF.
      IF ( mseg-erfmg NE ymseg-erfmg OR mseg-elikz NE ymseg-elikz ) OR
         ( mseg-lsmng NE ymseg-lsmng OR mseg-lsmeh NE ymseg-lsmeh ) OR
           dm07m-mhdat NE ydm07m-mhdat OR
           dm07m-vfdat_input NE ydm07m-vfdat_input OR
           dm07m-hsdat_input NE ydm07m-hsdat_input OR
          ( DM07M-EAN11_BME NE YDM07M-EAN11_BME AND
            DM07M-ZEILD EQ YDM07M-ZEILD )  OR
*        ( CCODE = CCOD-MATR AND MATRIX_KOPF = MSEG-ZEILE ).      " PPF
         ( ( ccode = ccod-matr OR ccode = ccod-reac )             " PPF
             AND matrix_kopf = mseg-zeile ).                      " PPF
        MOVE-CORRESPONDING dm07m TO biwe.
        IF sy-dynnr NE 222.
          biwe-idnlf = ydm07m-idnlf.
        ENDIF.
        IF sy-dynnr NE 223.
          biwe-ean11_bme = ydm07m-ean11_bme.
        ENDIF.
        IF sy-dynnr NE 224.
          biwe-mhdat = ydm07m-mhdat.
          biwe-vfdat_input = ydm07m-vfdat_input.
          biwe-hsdat_input = ydm07m-hsdat_input.
        ENDIF.
        MOVE-CORRESPONDING mseg   TO biwe.
        MOVE-CORRESPONDING ymseg  TO mseg.
        MOVE-CORRESPONDING yvm07m TO vm07m.
        MOVE-CORRESPONDING ydm07m TO dm07m.
        MOVE-CORRESPONDING biwe   TO mseg.
        MOVE-CORRESPONDING biwe   TO dm07m.
        fuss-xselp = x.
*       IF CCODE = CCOD-MATR AND MATRIX_KOPF = MSEG-ZEILE.        " PPF
        IF ( ccode = ccod-matr OR ccode = ccod-reac )             " PPF
           AND matrix_kopf = mseg-zeile.                          " PPF
          fuss-xmatrix = x.
          CLEAR matrix_kopf.
        ENDIF.
        kzbew = rm07m-kzbew.
        rm07m-kzbew = ymseg-kzbew.
        PERFORM fuss_fuellen USING space.
        rm07m-kzbew = kzbew.
      ENDIF.
      DELETE biwe INDEX 1.
    ENDIF.
  ENDIF.

ENDFORM.