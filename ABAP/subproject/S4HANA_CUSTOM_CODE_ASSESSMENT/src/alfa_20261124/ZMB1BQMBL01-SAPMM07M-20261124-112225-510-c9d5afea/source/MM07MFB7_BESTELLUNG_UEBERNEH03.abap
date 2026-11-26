*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_UEBERNEHMEN                                   *
*---------------------------------------------------------------------*
*       Die Bestelldaten werden übernommen.                           *
*---------------------------------------------------------------------*
  FORM bestellung_uebernehmen USING b-ebeln LIKE mseg-ebeln
                                    b-ebelp LIKE mseg-ebelp
                                    b-werks LIKE mseg-werks.

*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
    DATA: index_p LIKE index_l. CLEAR index_p.
    DATA: sammat_folgezeilen TYPE c.
    DATA: kz_we_bezogen TYPE c.
    DATA: it_sawe TYPE t_it_sawe.
    DATA: wa_sawe TYPE t_sawe.
    DATA: fuss_vas LIKE fuss VALUE space.

    DESCRIBE TABLE fuss LINES index_p.
    IF index_p IS INITIAL.
      DESCRIBE TABLE ymseg LINES index_p.
      IF index_p IS INITIAL.
        CLEAR km07r-waers.
      ENDIF.
    ENDIF.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
    CLEAR fuss.
    CLEAR index_l.
    CLEAR kz_we_bezogen.
    REFRESH: prefetch01,
             prefetch02,
             prefetch03.
    LOOP AT xebefu WHERE NOT matnr IS INITIAL.
      CHECK xebefu-ebelp >= b-ebelp AND xebefu-loekz IS INITIAL
                                    AND ( xebefu-lfret IS INITIAL OR
                                          xebefu-retar EQ zwei    OR
                                          xebefu-retpo IS INITIAL ).
      IF t158-trtyp = h.
        MOVE-CORRESPONDING xebefu TO prefetch01.
        COLLECT prefetch01.
        MOVE-CORRESPONDING xebefu TO prefetch02.
        COLLECT prefetch02.
      ENDIF.
      MOVE-CORRESPONDING xebefu TO prefetch03.
      COLLECT prefetch03.
*             * über XEBEFU wird zu jeder Sammelartikel-
*             * variante und WE eine Zeile geliefert; für
*             * alle Zeilen existiert jedoch nur ein
*             * SA-Kopf
*             * -> zu SA-Varianten die verschiedenen WE's
*             * kopfbezogen in Zwischenstruktur IT_SAWE
*             * aufsammeln und später pro WE einen eigenen
*             * SA-Kopf in XEBEFU einstellen
      IF xebefu-attyp = attyp-var.
*             * nur bei WE-bezogener Rechnungsprüfung
        IF NOT xebefu-webre IS INITIAL.
          kz_we_bezogen = x.
          CLEAR wa_sawe.
          MOVE xebefu-ebeln TO wa_sawe-ebeln.
          MOVE xebefu-uebpo TO wa_sawe-uebpo.
          MOVE xebefu-lfbnr TO wa_sawe-lfbnr.
          MOVE xebefu-wesbs TO wa_sawe-wesbs.
          MOVE xebefu-bpwes TO wa_sawe-bpwes.
          MOVE xebefu-wemng TO wa_sawe-wemng.
          MOVE xebefu-bpwem TO wa_sawe-bpwem.
          MOVE xebefu-wewrt TO wa_sawe-wewrt.
          MOVE xebefu-wewwr TO wa_sawe-wewwr.
          MOVE xebefu-remng TO wa_sawe-remng.
          MOVE xebefu-bprem TO wa_sawe-bprem.
          MOVE xebefu-rewrt TO wa_sawe-rewrt.
          MOVE xebefu-rewwr TO wa_sawe-rewwr.
          MOVE xebefu-arewr TO wa_sawe-arewr.
          MOVE xebefu-areww TO wa_sawe-areww.
          COLLECT wa_sawe INTO it_sawe.
        ENDIF.
      ENDIF.
    ENDLOOP.
    PERFORM prefetch_ausfuehren USING x
                                      space.
*             * Sammelartikel-WE in XEBEFU einarbeiten
*             * -> jeder WE zu SA ergibt einen eigenen Kopf
    IF NOT kz_we_bezogen IS INITIAL.
      PERFORM sammelart_we_in_xebefu USING it_sawe.
    ENDIF.
    FREE: kz_we_bezogen.
    FREE: it_sawe.
    FREE: wa_sawe.
*
    LOOP AT xebefu.
      CHECK xebefu-ebelp >= b-ebelp AND xebefu-loekz IS INITIAL
                                    AND ( xebefu-lfret IS INITIAL OR
                                          xebefu-retar EQ zwei    OR
                                          xebefu-retpo IS INITIAL ).
* refresh on mseg-shkzg by original mvmt type
      PERFORM segmentdaten_t156_setzen(sapfm07m).          "note 138172
* Wareneingang in Sperrb. für Retourenpositionen wird nicht unterstützt
      CHECK t156-kzwes IS INITIAL OR xebefu-retpo IS INITIAL.
* Storno, falls wemng = 0, kein Sinn / insb. bei WERE-bez Reprü
      IF xebefu-retpo IS INITIAL AND NOT xebefu-webre IS INITIAL.
        IF t156-kzwes = s.
* valuated blocked stock have to be considered   "begin of note 1497752
          CASE t156-bustr.
            WHEN '103'.
              CHECK NOT ( xebefu-wesbs IS INITIAL AND mseg-shkzg = h ).
            WHEN '107'.
              CHECK NOT ( xebefu-wesbb IS INITIAL AND mseg-shkzg = h ).
          ENDCASE.
        ELSE.
          CASE t156-bustr.
            WHEN '101'.
              CHECK NOT ( xebefu-wemng IS INITIAL AND mseg-shkzg = h ).
            WHEN '105'.
              CHECK NOT ( xebefu-wemng IS INITIAL AND mseg-shkzg = h ).
              CHECK NOT ( xebefu-wesbs IS INITIAL AND mseg-shkzg = s ).
            WHEN '109'.
              CHECK NOT ( xebefu-wemng IS INITIAL AND mseg-shkzg = h ).
              CHECK NOT ( xebefu-wesbb IS INITIAL AND mseg-shkzg = s ).
          ENDCASE.
        ENDIF.                                   "end of note 1497752
      ENDIF.
* if xebefu-retpo is initial and not xebefu-webre is initial.
*   check not ( xebefu-wemng is initial and mseg-shkzg = h ).
* endif.
      IF NOT b-werks IS INITIAL.
        IF b-ebelp NE 0 AND b-werks NE xebefu-werks.
          MESSAGE e034 WITH xebefu-ebeln xebefu-ebelp xebefu-werks.
        ENDIF.
        CHECK xebefu-werks = b-werks.
      ENDIF.
*     Emergency break for UB PO's with subcontracting. If our
*     collegues from PUR do not avoid such PO's to be created, we
*     have to avoid them to be posted.
*     Such PO's can be created for cross-system goods movements.
*     As of 4.70, PSTYP = 7 is not sufficient to identify stock
*     transfer. It all is via BSAKZ. So PSTYP can be used for
*     SC. We cannot permit this.
      IF xebefu-pstyp = '3' AND xebefu-bsakz = t.
        MESSAGE e009(mb_cross_system) WITH xebefu-ebeln
                                           xebefu-ebelp.
      ENDIF.
* Unterpositionen, die durch Stücklistenauflösung in ME_READ_ITEM_GOODS_
* RECEIPT unmittelbar vorher schon in FUSS aufgenommen wurden, können
* nochmal explizit danach in WUEB bzw. XVEPWE auftauchen --> werden dann
* nicht nochmal übernommen
      DATA: h_fuss LIKE fuss.
      IF NOT xebefu-uptyp IS INITIAL AND
             xebefu-uptyp NE uptyp_var AND
             xebefu-upvor IS INITIAL   AND
             xebefu-uptyp NE uptyp_vas.
        h_fuss = fuss.
* Note 805560 - Begin
*        LOOP AT FUSS WHERE LFBNR = XEBEFU-LFBNR AND
*                           EBELN = XEBEFU-EBELN AND
*                           EBELP = XEBEFU-EBELP AND
*                           NOT URZEI = FUSS-ZEILE AND
*                           URZEI = H_URZEI.
        LOOP AT fuss WHERE lfbnr = xebefu-lfbnr AND
                           lfpos = xebefu-lfpos AND
                           ebeln = xebefu-ebeln AND
                           ebelp = xebefu-ebelp AND
                           NOT urzei = fuss-zeile AND
                           urzei = h_urzei.
* Note 805560 - End

          IF wueb-ebeln = fuss-ebeln AND
             wueb-ebelp = fuss-ebelp.
* Schlüssel der Lieferung ist durch ME_READ_ITEMS_GOODS_RECEIPT evtl.
* verlorengegangen
            fuss-vbeln = wueb-vbeln.
            fuss-vbelp = wueb-vbelp.
            MODIFY fuss INDEX sy-tabix.
          ENDIF.
          EXIT.
        ENDLOOP.
        IF sy-subrc IS INITIAL.
          CHECK 1 = 2.
        ENDIF.
        fuss = h_fuss.
      ENDIF.

*    IF NOT VAS_SWITCH IS INITIAL.                   " AL0K023871
      IF xebefu-uptyp  EQ  uptyp_vas.
* record a subitem of a value added service
        PERFORM vas_bestellpos_uebernehmen CHANGING fuss_vas.
        CHECK 1 = 2.
      ENDIF.
*     ENDIF.                                         " AL0K023871

*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
      IF sy-tabix = 1.
        PERFORM werk_pruefen(sapfm07m) USING    x
                                           xebefu-werks
                                            vm07m-bwkey
                                            dm07m-bwmod
                                            dm07m-xeink
                                            dm07m-xbkng
                                            vm07m-xvkbw
                                             mseg-bukrs
                                            dm07m-ktopl
                                            dm07m-periv
                                             mseg-waers
                                             mkpf-budat
                                             mseg-gjahr
                                            vm07m-monat
                                             mseg-xruem
                                             mseg-xruej
                                            vm07m-lfgja
                                            vm07m-lfmon
                                            dm07m-fabkl
                                            dm07m-kzxab.
        IF km07r-waers IS INITIAL.
          km07r-waers = mseg-waers.
          km07r-ktopl = dm07m-ktopl.
          km07r-periv = dm07m-periv.
        ELSE.
          IF NOT km07r-waers = t001-waers OR NOT km07r-ktopl = t001-ktopl
                     OR NOT km07r-periv = t001-periv.
            MESSAGE e516.
          ENDIF.
        ENDIF.
      ENDIF.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
      CLEAR dm07m.
      CLEAR vm07m.
      CLEAR mseg.
      index_l = index_l + 1.
      DATA bwart LIKE mseg-bwart. bwart = t156-bwart.
      PERFORM bestellung_bwa_retoure.
* Storno, wenn wemng = 0 ist Sinnlos

*     Begin of note 454080:
*     T156 needs to be reset to original movement type (see as well
*     begin of this loop at xebefu), as the original movement type is
*     needed there. Normally this is done later on within this loop, but
*     if the following checks fail, this needs to be done before leaving
*     the loop here.
      IF NOT xebefu-retpo IS INITIAL AND NOT xebefu-webre IS INITIAL.
        IF t156-kzwes = s.
          IF xebefu-wesbs IS INITIAL AND mseg-shkzg = s.
            IF NOT bwart = t156-bwart.
              PERFORM bewegungsart_lesen(sapfm07m) USING bwart.
            ENDIF.
            CONTINUE.
          ENDIF.
        ELSE.
          IF xebefu-wemng IS INITIAL AND mseg-shkzg = s.
            IF NOT bwart = t156-bwart.
              PERFORM bewegungsart_lesen(sapfm07m) USING bwart.
            ENDIF.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDIF.
*   end of changes per note 454080

*   MAA-DEV
      IF xebefu-xhistma = abap_true AND
         ( t156-bustr = bustr_107   OR t156-bustr = bustr_109 ).
        MESSAGE w448 WITH xebefu-ebeln xebefu-ebelp.
        CONTINUE.
      ENDIF.
*   MAA-DEV

*   if not xebefu-retpo is initial and not xebefu-webre is initial.
*     check not ( xebefu-wemng is initial and mseg-shkzg = s ).
*   endif.
      PERFORM segmentdaten_ek_setzen.
      vm07m-xblnr_avis = wueb-xblnr_avis.
      vm07m-frbnr_avis = wueb-frbnr_avis.
      vm07m-pabnum = wueb-pabnum.
      vm07m-pabpos = wueb-pabpos.
      vm07m-pkkey  = wueb-pkkey.
      IF NOT zwueb IS INITIAL AND wueb-ebeln = mseg-ebeln
                              AND wueb-ebelp = mseg-ebelp.
        vm07m-vbeln  = wueb-vbeln.
        vm07m-vbelp  = wueb-vbelp.
        IF NOT wueb-bwart IS INITIAL.
          mseg-bwart = wueb-bwart.
          IF bwart NE mseg-bwart.
            PERFORM bewegungsart_pruefen(sapfm07m) USING mseg-bwart
                                                         mseg-xauto.
            bwart = mseg-bwart.
          ENDIF.
        ENDIF.
        xebefu-erfmg = wueb-erfmg.
        xebefu-bstme = mseg-erfme = wueb-erfme.
        IF mseg-charg IS INITIAL.
          mseg-charg = wueb-charg.
        ENDIF.
      ENDIF.
* Übernahme Lieferscheinmenge aus Avis/Grob-WE (evtl. auch indirekt aus
* Versandelement)
      IF NOT rm07m-xvers IS INITIAL AND
         ( xvepwe-vbtyp = c_vbtyp_avis  OR
           xvepwe-vbtyp = c_vbtyp_grob ).
        mseg-lsmng = xvepwe-vemng.
        mseg-lsmeh = xvepwe-vemeh.
        IF rm07m-lgort IS INITIAL AND NOT xvepwe-lgort IS INITIAL.
          mseg-lgort = xvepwe-lgort.
        ENDIF.
      ELSEIF NOT x_grobwe IS INITIAL OR
             NOT x_avis   IS INITIAL.
        mseg-lsmng = wueb-erfmg.
        mseg-lsmeh = wueb-erfme.
* der im Avis/Grob-WE eingegebene Lagerort hat Vorrang vor dem Lagerort
* der zugrundeliegenden Bestellung, es sei denn, der Lagerort wurde im
* Einstiegsbild vorgegeben
        IF rm07m-lgort IS INITIAL AND NOT wueb-lgort IS INITIAL.
          mseg-lgort = wueb-lgort.
        ENDIF.
      ENDIF.
* Übernahme Lieferbeleg bei Versandelementen für späteren Belegfluß
* (vorläufig nur bei Lieferung, nicht bei Avis/Grob-WE)
      IF NOT rm07m-xvers IS INITIAL AND
         xvepwe-vbtyp = c_vbtyp_lief.
        vm07m-vbeln = xvepwe-vbeln.
        vm07m-vbelp = xvepwe-posnr.
      ENDIF.
      PERFORM segmentdaten_t156_setzen(sapfm07m).
      CLEAR vm07m-xnebe.
      IF t158-kzbew = o.
        CHECK vm07m-pstyp = drei AND NOT dm07m-wemng IS INITIAL.
        CLEAR: mseg-erfmg, mseg-bpmng, mseg-menge.
        mseg-kzbew = rm07m-kzbew.
        fuss-xselk = t158-xsele.
      ELSE.
        PERFORM bestellung_uebernehmen_01.
      ENDIF.
      PERFORM bestellung_uebernehmen_02.
* MAA2 Begin
* clear xhistma if bwart not relevant for we06_rechnen, mseg-bustw is also space
* don't clear xhistma for t156-bustr = t156sy-bustr with t156sy-bustw = WE06
      IF t156-bustr NE bustr_101 AND t156-bustr NE bustr_105 AND
         t156-bustr NE bustr_107 AND t156-bustr NE bustr_141 AND
         t156-bustr NE bustr_161.
        CLEAR: dm07m-xhistma.
      ELSEIF mseg-weunb IS INITIAL.
        READ TABLE xaccounting WITH KEY ebeln = mseg-ebeln
                                        ebelp = mseg-ebelp
                                  TRANSPORTING NO FIELDS.
        IF sy-subrc IS INITIAL AND mseg-xmacc IS INITIAL.
          mseg-xmacc = 'V'. "item level
          mseg-ablad = '*'.
          mseg-wempf = '*'.
        ENDIF.
      ENDIF.
* MAA2 End
      IF NOT bwart = t156-bwart.
        PERFORM bewegungsart_lesen(sapfm07m) USING bwart.
        CLEAR vm07m-xnebe.
      ENDIF.
      IF NOT t158-kzbew = o.
*     IF NOT rm07m-vlief IS INITIAL OR
*        NOT xebefu-etens IS INITIAL OR rm07m-xnuvo IS INITIAL.
*       CHECK NOT mseg-erfmg IS INITIAL.
*     ENDIF.
        CHECK NOT rm07m-xnuvo IS INITIAL OR NOT mseg-erfmg IS INITIAL.
      ENDIF.
      f_zeile = f_zeile + 1.
      mseg-zeile = f_zeile + m_zeile.
      MOVE-CORRESPONDING dm07m TO fuss.
      MOVE-CORRESPONDING vm07m TO fuss.
      MOVE-CORRESPONDING mseg TO fuss.
      IF x_mulko IS INITIAL.
        x_mulko = dm07m-mulko.
      ENDIF.

*                         *  write down Retail-specific       " 328675
*                         *  article structure infos for      " 328675
*                         *  afterwards consistency-checks    " 328675
      PERFORM retail_struct_empties_generic USING fuss-ebeln " 328675
                                                  fuss-uebpo " 328675
                                                  fuss-lfbnr. " 328675

* Mengenkorrelation bei Leergut
      IF dm07m-uptyp CA c_mekor.
        fuss-xauto = l.
        PERFORM leerg_abw_pruefen(sapfm07m).
        fuss-mekor = x.
* Note 805560 - Begin
*        PERFORM LEERG_ERMITTLE_URZEI USING FUSS-EBELN
*                                           FUSS-UEBPO
*                                           FUSS-LFBNR
*                                  CHANGING FUSS-URZEI.
        IF fuss-lfbnr IS INITIAL AND fuss-lfpos IS INITIAL.
          PERFORM leerg_ermittle_urzei USING fuss-ebeln
                                           fuss-uebpo
                                           fuss-lfbnr
                                  CHANGING fuss-urzei.
        ELSE.
          DATA: item_position LIKE mseg-urzei,
          wa_fuss LIKE fuss.

          PERFORM read_item_position USING fuss-lfbja
                                           fuss-lfbnr
                                           fuss-lfpos
                                           t158-trtyp
                                 CHANGING item_position.
          READ TABLE fuss INTO wa_fuss WITH KEY ebeln = fuss-ebeln
                                   ebelp = fuss-uebpo
                                   lfbja = fuss-lfbja
                                   lfbnr = fuss-lfbnr
                                   lfpos = item_position.
          fuss-urzei = wa_fuss-zeile.
        ENDIF.
* Note 805560 - End
      ENDIF.
*##ngr-saanf
* Verweis auf Sammelartikelzeile
      IF dm07m-uptyp = uptyp_var.
*        * das Setzen der Rückverkettung zu Sammelart.
*        * erfolgt analog zu Leergut
        PERFORM leerg_ermittle_urzei USING fuss-ebeln
                                           fuss-uebpo
                                           fuss-lfbnr
                                     CHANGING fuss-urzei.
      ENDIF.
*##ngr-saend
      IF dm07m-upvor NE space.
        PERFORM kopfzeile_merken USING fuss-lfbnr
                                       fuss-ebeln
                                       fuss-ebelp
                                       mseg-zeile
                                       0.
      ENDIF.
*##ngr-saanf
* Kennung zurücknehmen, abhängige Positionen eines Sammelartikels
* abgearbeitet (können sowohl Varianten als auch wiederum davon abhän-
* gige Leergut- oder Naturalrabattpositionen sein !!!)
      IF dm07m-uptyp IS INITIAL.
        CLEAR sammat_folgezeilen.
      ENDIF.
*##ngr-saend
      h_urzei = fuss-urzei.
      fuss-fcode = fcod-np.
      fuss-xselp = fcausw-xselp.
      fuss-xsels = fcausw-xselp.
      IF t158-kzbew = o.
        fuss-xselk = t158-xsele.
      ELSE.
        IF fcausw-xlist IS INITIAL.
          fuss-xselk = x.
          fuss-xhell = x.
        ELSE.
          IF fuss-erfmg = 0 OR ( NOT fuss-kzwes = x AND
             NOT fuss-elikz IS INITIAL AND fuss-shkzg = s  AND
             xebefu-retpo IS INITIAL ).                    "note 138770
            CLEAR fuss-xselk.
          ELSE.
            fuss-xselk = t158-xsele.
          ENDIF.
        ENDIF.
        PERFORM bezugsnebenkosten_uebernehmen USING xebefu-ebeln
                                                    xebefu-ebelp
                                                      mseg-weunb
                                                      mseg-kzbew
                                                           space.
      ENDIF.
ENHANCEMENT-POINT BESTELLUNG_UEBERNEHMEN_01 SPOTS ES_SAPMM07M.
*##ngr-saanf
      IF sammat_folgezeilen IS INITIAL.
        APPEND fuss.
      ELSE.
* abhängige Folgezeilen eines Sammelartikels werden zunächst 'geparkt'
        f_zeile = f_zeile - 1.
        CLEAR fuss-zeile.
* endgelieferte Varianten werden nicht übernommen, da in der Matrix
* keine Interaktion bzgl. Selektionskennzeichen wie in Auswahlbild
* gegeben
* Vorsicht: bei einer Stornobewegungsart tut man's natürlich sehrwohl
*     IF FUSS-ELIKZ = X.                                  "note 208966
        IF fuss-elikz = x                                  "note 208966
           AND dm07m-xstbw IS INITIAL.                     "note 208966
          CLEAR fuss-erfmg.
        ENDIF.
        MOVE-CORRESPONDING fuss TO var_fuss.
        PERFORM leerg_ermittle_urzei USING fuss-ebeln
                                           fuss-uebpo
                                           fuss-lfbnr
                            CHANGING var_fuss-kopf_zeile.
* URZEI wird erst bei Übernahme der geparkten Zeilen neu bestimmt (kann
* hier noch nicht erfolgen, wenn es sich um abhängige Zeilen einer
* Variante handelt (Leergut, Naturalrabatt))
        CLEAR var_fuss-urzei.
        APPEND var_fuss.
      ENDIF.
* Kennung setzen, daß abhängige Zeilen eines Sammelartikels folgen
* können
* Zeile...
      IF dm07m-upvor = uptyp_var AND
* ersetzen durch : if vm07m-attyp = attyp-sam !!!
         dm07m-uptyp IS INITIAL.
        sammat_folgezeilen = x.
      ENDIF.
*##ngr-saend
    ENDLOOP.
    CLEAR msegk.
    FREE: xebefu, xekbnk, xebefu_cr, xekbnk_cr.
    READ TABLE fuss INDEX 1.
    IF NOT sy-subrc IS INITIAL AND rm07m-mblnr IS INITIAL.
* no entry in fuss after loop at xebefu;
* case 1: G/R to a confirmation (like shipping notification):
*    itab xebefu is just filled with the actual po item (in this case
*    itab wueb is filled with the confirmation and processed for every
*    confirmation item ; for every such item itab xebefu is filled;
*    error message makes sense just if fuss is empty and the last item
*    of wueb has already been processed
* case 2: G/R to po: wueb is empty and xebefu contains all po items;
*    if fuss is empty -> error message
      READ TABLE wueb INDEX 1.
      IF NOT sy-subrc IS INITIAL.
        MESSAGE e064 WITH b-ebeln.
      ELSE.
* Compare actual and last line of table WUEB. If the actual line
* is the last line, this is an error.
        DATA: wueb_actual LIKE wueb.   " :-)
        wueb_actual = wueb.
        CLEAR index_l.
        DESCRIBE TABLE wueb LINES index_l.
        READ TABLE wueb INDEX index_l.
        IF wueb = wueb_actual.
          MESSAGE e064 WITH b-ebeln.
        ENDIF.
      ENDIF.
    ENDIF.
    IF xaktiv IS INITIAL.
      xaktiv = x.
    ENDIF.
    IF xconfirm IS INITIAL.
      IF t158-trtyp = h.
        xconfirm = x.
      ENDIF.
    ENDIF.
*##ngr999-anf
*  if index_l < 1 and rm07m-mblnr is initial.
*    message e035 with b-ebeln b-werks.
*  endif.
    DATA: anzzl_fuss LIKE sy-tabix.
    DESCRIBE TABLE fuss LINES anzzl_fuss.
    IF index_l < 1 AND rm07m-mblnr IS INITIAL
      AND pos_not_valid IS INITIAL
      AND anzzl_fuss = 0.
      MESSAGE e035 WITH b-ebeln b-werks.
    ENDIF.
    CLEAR pos_not_valid.
ENHANCEMENT-POINT BESTELLUNG_UEBERNEHMEN_02 SPOTS ES_SAPMM07M.
*##ngr999-end
  ENDFORM.                    "BESTELLUNG_UEBERNEHMEN