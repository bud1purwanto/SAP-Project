*---------------------------------------------------------------------*
*        PAI-Module zum Modulpool SAPMM07M                            *
*---------------------------------------------------------------------*

*---------------------------------------------------------------------*
*       MODULE AB_POSITION                                            *
*---------------------------------------------------------------------*
*       Die Position aus dem PopUp wird übernommen.                   *
*---------------------------------------------------------------------*
MODULE ab_position.

  CLEAR ok-code.
  IF rm07m-zeile IS INITIAL.
    IF index_z IS INITIAL.
      MESSAGE w061.
      fcode_next = fcode.
    ELSE.
      rm07m-zeile = 1.
    ENDIF.
  ELSE.
    IF fcausw-xselp IS INITIAL.
      READ TABLE ymseg INDEX rm07m-zeile.
    ELSE.
      index_z = rm07m-zeile - m_zeile.
      READ TABLE fuss INDEX index_z.
    ENDIF.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e551 WITH rm07m-zeile.
    ENDIF.
  ENDIF.

ENDMODULE.                    "ab_position

*---------------------------------------------------------------------*
*       MODULE AKTIV_PRUEFEN                                          *
*---------------------------------------------------------------------*
*       Mindestens ein gültiger Eintrag muss in Fusszeilenbild        *
*       eingetragen sein.                                             *
*---------------------------------------------------------------------*
MODULE aktiv_pruefen.

  CLEAR ok-code.
  CLEAR ccode_next.
  IF xaktiv IS INITIAL.
    LEAVE SCREEN.
  ENDIF.
  CLEAR xaktiv.

ENDMODULE.                    "aktiv_pruefen

*---------------------------------------------------------------------*
*       MODULE ANZAHL_WESCHEIN                                        *
*---------------------------------------------------------------------*
*       Die Anzahl zu druckender WE-Scheine wird errechnet            *
*---------------------------------------------------------------------*
MODULE anzahl_weschein.

  CLEAR ok-code.
  PERFORM anzahl_weschein.

ENDMODULE.                    "anzahl_weschein

*---------------------------------------------------------------------*
*       MODULE ANZAHL_WESCHEIN_MAN                                    *
*---------------------------------------------------------------------*
*       Sobald die Anzahl manuell überschrieben wird, wird keine      *
*       maschinelle Errechnung mehr vorgenommen.                      *
*---------------------------------------------------------------------*
MODULE anzahl_weschein_man.
  CLEAR ok-code.
  IF mseg-weanz NE wanzm.
    anzma = mseg-weanz.
    dm07m-xwesc = x.
  ENDIF.

ENDMODULE.                    "anzahl_weschein_man

*---------------------------------------------------------------------*
*       MODULE AUFSETZEN_FUELLEN                                      *
*---------------------------------------------------------------------*
*       Die erste Zeile auf dem StepLoop wird gemerkt. Bzw. auf       *
*       welcher Einzelposition man sich befindet.                     *
*---------------------------------------------------------------------*
MODULE aufsetzen_fuellen.

  CLEAR ok-code.
  IF aufsetzen IS INITIAL.
    aufsetzen = mseg-zeile.
  ENDIF.

ENDMODULE.                    "aufsetzen_fuellen

*---------------------------------------------------------------------*
*       MODULE AUTOMATISCHE_ZEILEN                                    *
*---------------------------------------------------------------------*
*       Automatisch zu erzeugende Zeilen werden vorbereitet.          *
*---------------------------------------------------------------------*
MODULE automatische_zeilen.
  DATA: ls_isu_automatische_zeilen TYPE isu_automatische_zeilen. "IS2ERP

  CLEAR ok-code.
  DATA ftabix LIKE fuss-tabix. CLEAR ftabix.
  DATA fazeil LIKE fuss-azeil. CLEAR fazeil.
  PERFORM automatische_zeilen USING h
                                    ftabix
                                    fazeil
                                    ls_isu_automatische_zeilen. "IS2ERP

ENDMODULE.                    "automatische_zeilen

*---------------------------------------------------------------------*
*       MODULE BELEG_ANZEIGEN                                         *
*---------------------------------------------------------------------*
*       Dieses Modul wird bearbeitet, wenn von einer untergeordneten  *
*       auf die naechst hoehere Stufe mit PF3 = BACK verzweigt wird.  *
*---------------------------------------------------------------------*
MODULE beleg_anzeigen.

  CLEAR tabix.
  PERFORM beleg_anzeigen USING tabix.

ENDMODULE.                    "beleg_anzeigen

*---------------------------------------------------------------------*
*       MODULE BELEG_LESEN                                            *
*---------------------------------------------------------------------*
*       Der Materialbeleg wird gelesen.                               *
*---------------------------------------------------------------------*
MODULE beleg_lesen.

  DATA: et_zeile TYPE ty_t_mblpo.                           "406146
  CLEAR ok-code.
  IF t158-trtyp = h AND NOT t063c-ccode IS INITIAL.
    PERFORM fusszeile_neu.
  ELSE.
* Check possible combinations for material document and delivery note:
* --------------------------------------------------------------------
* First case: both MBLNR and LFSNR are filled. Clear field that was
* not entered manually (may be filled from previous entry)
* Clear MBLNR necessary because 1 LFSNR may have several MBLNR
* Clear LFSNR necessary because LFSNR may be filled from old document
    IF NOT rm07m-lfsnr IS INITIAL AND NOT rm07m-mblnr IS INITIAL.
      IF NOT lfsnr_input IS INITIAL.
        CLEAR rm07m-mblnr.
      ELSE.
        CLEAR rm07m-lfsnr.
      ENDIF.
    ENDIF.
* Neither MBLNR nor LFSNR are filled => error
    IF rm07m-mblnr IS INITIAL AND rm07m-lfsnr IS INITIAL.
      PERFORM no_input(sapfm07m) USING 'RM07M' 'MBLNR'.
      MESSAGE e010.
      SET CURSOR FIELD 'RM07M-MBLNR'.
* Both LFSNR and MBLNR are filled => error because conflict possible
    ELSEIF NOT rm07m-lfsnr IS INITIAL AND NOT rm07m-mblnr IS INITIAL.
      MESSAGE e246.
* Only LFSNR is filled => input field is set to X. Necessary to
* distinguish manual LFSNR from LFSNR filled from material document
    ELSEIF NOT rm07m-lfsnr IS INITIAL AND rm07m-mblnr IS INITIAL.
      lfsnr_input = x.
      PERFORM beleg_suchen_lfsnr.
* Only MBLNR is filled => input field is cleared because LFSNR might be
* filled automatically from material document in beleg_lesen
    ELSEIF NOT rm07m-mblnr IS INITIAL AND rm07m-lfsnr IS INITIAL.
      CLEAR lfsnr_input.
      PERFORM beleg_lesen TABLES et_zeile[].                "406146
    ENDIF.
  ENDIF.
* Set global field XDELIV for automatic creation of SD delivery
* instead of material document (possible from 4.5A on)
  xdeliv = rm07m-xdeliv.
* Generic object services in transaction MB03                    "357107
  IF t158-trtyp = a.                                        "357107
    DATA: BEGIN OF l_key,                                   "357107
              materialdocument TYPE mkpf-mblnr,             "357107
              matdocumentyear  TYPE mkpf-mjahr,             "357107
          END OF l_key.                                     "357107
    l_key-materialdocument = xmkpf-mblnr.                   "357107
    l_key-matdocumentyear  = xmkpf-mjahr.                   "357107
    CALL FUNCTION 'SWU_OBJECT_PUBLISH'                      "357107
         EXPORTING                                          "357107
              objtype           = 'BUS2017'                 "357107
              objkey            = l_key                     "357107
         EXCEPTIONS                                         "357107
              objtype_not_found = 1                         "357107
              OTHERS            = 2.                        "357107
  ENDIF.                                                    "357107
ENDMODULE.                    "beleg_lesen

*---------------------------------------------------------------------*
*       MODULE BELEG_LESEN_POP                                        *
*---------------------------------------------------------------------*
*       Der Materialbeleg wird gelesen. Hier: wenn der Beleg          *
*       auf einem PopUp eingegeben wird.                              *
*---------------------------------------------------------------------*
MODULE beleg_lesen_pop.

  CLEAR ok-code.
  PERFORM beleg_lesen TABLES et_zeile[].                    "406146

ENDMODULE.                    "beleg_lesen_pop

*---------------------------------------------------------------------*
*       MODULE BELEG_LESEN_POP_WEWA                                   *
*---------------------------------------------------------------------*
*       Der Materialbeleg wird gelesen. Hier: die Positionen          *
*       sind für den Wareneingang zur Bestellung aus einem            *
*       WA-Beleg vorzuschlagen. Dient zur Ermittlung von              *
*       Bestellung und Position. Einsatz: für Umlagerungsbestellung.  *
*---------------------------------------------------------------------*
MODULE beleg_lesen_pop_wewa.

  CLEAR ok-code.
  PERFORM beleg_lesen_pop_wewa.

ENDMODULE.                    "beleg_lesen_pop_wewa

*---------------------------------------------------------------------*
*       MODULE BESTELLUNG_WA_POP                                      *
*---------------------------------------------------------------------*
*       Die Bestellung wird für den Warenausgang zur Umlagerbestel-   *
*       lung (später ggf. auch Lohnbearbeiterbestellung) gelesen.     *
*---------------------------------------------------------------------*
MODULE bestellung_wa_pop.

  CLEAR ok-code.
  CHECK NOT rm07m-ebeln IS INITIAL.
  IF t156-kzbwa = kzbwa-02.
    PERFORM bestellung_wa_lb_pop.
  ELSE.
    PERFORM bestellung_wa_pop.
  ENDIF.

ENDMODULE.                    "bestellung_wa_pop

*---------------------------------------------------------------------*
*       MODULE BEWEGUNGSART_PRUEFEN                                   *
*---------------------------------------------------------------------*
*       Bewegungsart pruefen.                                         *
*---------------------------------------------------------------------*
MODULE bewegungsart_pruefen.

  DATA:  hbwart LIKE bcode-bwart,
         hsobkz LIKE bcode-sobkz.
  IF NOT bcode-bwart IS INITIAL.
    hbwart = bcode-bwart.
    hsobkz = bcode-sobkz.
  ENDIF.
  CLEAR: ok-code,
         bcode-bwart,
         bcode-sobkz.
  PERFORM bewegungsart_pruefen(sapfm07m) USING rm07m-bwart
                                               space.
  IF t158-kzbew = b.
    IF t156-xnebe IS INITIAL AND ( t158b-xkzbew = 3 OR
       t158b-xkzbew = 4 ).
      IF sy-dynnr = '1403'.
        MESSAGE e019 WITH rm07m-bwart rm07m-sobkz.
      ENDIF.
      CLEAR xkzbew.
    ENDIF.
    IF ( xkzbew IS INITIAL AND t158b-xkzbew = 1 ) OR
       ( xkzbew IS INITIAL AND t158b-xkzbew = 2 ) OR
       ( xkzbew = 1 AND t158b-xkzbew IS INITIAL ) OR
       ( xkzbew = 1 AND t158b-xkzbew = 2 ).
      MESSAGE e019 WITH rm07m-bwart rm07m-sobkz.
    ENDIF.
  ENDIF.
  IF t158b-xkzbew = 3 OR t158b-xkzbew = 4.
    IF NOT rm07m-sobkz IS INITIAL.
      CLEAR hsobkz.
      MESSAGE e019 WITH rm07m-bwart rm07m-sobkz.
    ENDIF.
    IF fcode_next = fcod-np.
      MESSAGE i889 WITH rm07m-bwart.
      fcode_next = fcod-nl.
    ENDIF.
    CLEAR rm07m-sobkz.
    rm07m-kzbew = b.
    rm07m-bwartwe = rm07m-bwart.
  ENDIF.
  next_xkzbew  = t158b-xkzbew.
  PERFORM sonderbestkz_pruefen(sapfm07m) USING rm07m-sobkz
                                               vm07m-sobfi
                                               vm07m-soblo
                                               vm07m-sobvo.
  PERFORM bildauswahl_pruefen(sapfm07m) USING rm07m-bwart
                                              rm07m-sobkz.
  IF NOT hbwart IS INITIAL.
    bcode-bwart = hbwart.
    bcode-sobkz = hsobkz.
    CLEAR: hbwart,
           hsobkz.
  ENDIF.

ENDMODULE.                    "bewegungsart_pruefen

*---------------------------------------------------------------------*
*       MODULE BPMNG_EINGABE                                          *
*---------------------------------------------------------------------*
*       Dieser Modul setzt ein Merkflag, wenn die Menge               *
*       in Bestellpreismengeneinheit eingegeben wird.                 *
*---------------------------------------------------------------------*
MODULE bpmng_eingabe.

  xbprm = x.

ENDMODULE.                    "bpmng_eingabe

*---------------------------------------------------------------------*
*       MODULE BWART_WA                                               *
*---------------------------------------------------------------------*
*       Die Bewegungsart wird für WA's gesetzt.                       *
*---------------------------------------------------------------------*
MODULE bwart_wa.

  PERFORM bwart_wa.

ENDMODULE.                    "bwart_wa

*---------------------------------------------------------------------*
*       MODULE BWART_WE                                               *
*---------------------------------------------------------------------*
*       Die Bewegungsart wird für WE's gesetzt.                       *
*---------------------------------------------------------------------*
MODULE bwart_we.

  PERFORM bwart_we.
  CHECK NOT rm07m-bwart IS INITIAL.
  CLEAR xkzbew.
  IF ( NOT anf_bild IS INITIAL AND sy-dynnr NE '1203' )
     OR ( fcode_next = fcod-nl AND sy-dynnr = '1299' ).
    PERFORM t158b_lesen(sapfm07m) USING rm07m-bwart.
    IF ( t158b-xkzbew = 1 AND
       ( ccode = ccod-nfbs OR ccode = ccod-nfbl OR
         sy-dynnr = '1201' ) ) OR
       t158b-xkzbew = 2.
      IF NOT ccode IS INITIAL.
        CLEAR bcode-bwart.
      ENDIF.
      MESSAGE e019 WITH rm07m-bwart rm07m-sobkz.
    ENDIF.
    xkzbew = next_xkzbew = t158b-xkzbew.
    IF sy-subrc IS INITIAL.
      IF xkzbew = 1.
        CLEAR rm07m-kzbew.
        rm07m-bwartwe = rm07m-bwartwa = rm07m-bwart.
        PERFORM bewegungsart_pruefen(sapfm07m) USING rm07m-bwart
                                                     space.
        PERFORM bildauswahl_pruefen(sapfm07m)  USING rm07m-bwart
                                                     rm07m-sobkz.
        PERFORM bewegungstext_lesen(sapfm07m) USING rm07m-bwart
                                                    rm07m-sobkz
                                                    rm07m-kzbew
                                                     mseg-kzzug
                                                     mseg-kzvbr
                                                    dm07m-btext.
        old_fausw = dm07m-fausw.
        old_btext = dm07m-btext.
        CLEAR dm07m-fausw.
        fcode_next = fcode = fcod-nl.
        PERFORM fcode_lesen USING fcode.
        CLEAR: rm07m-ebeln, rm07m-ebelp.
      ELSEIF ( xkzbew = 3 OR xkzbew = 4 ).
        IF NOT rm07m-ebeln IS INITIAL AND xkzbew = 4.
          MESSAGE e019 WITH rm07m-bwart rm07m-sobkz.
        ENDIF.

        IF t156-xnebe IS INITIAL OR sy-dynnr = '0201'
                                 OR sy-dynnr = '1201'.
          CLEAR xkzbew.
        ELSE.
          IF NOT rm07m-ebeln IS INITIAL.
            CLEAR xkzbew.
            rm07m-kzbew = t158-kzbew.
            IF fcode_next = fcod-nl.
              fcode = fcode_next = fcod-sl.
              PERFORM fcode_lesen USING fcode.
            ENDIF.
            EXIT.
          ENDIF.
          bcode-bwart = rm07m-bwartwe = rm07m-bwart.
          PERFORM bewegungsart_pruefen(sapfm07m) USING rm07m-bwart
                                                       space.
          IF sy-dynnr NE '1299' AND
             ccode NE ccod-nfbl AND
             ccode NE ccod-nfbs.
            fcode = fcode_next = fcod-nl.
            PERFORM fcode_lesen USING fcode.
          ENDIF.
        ENDIF.
      ELSE.
        rm07m-kzbew = t158-kzbew.
        IF fcode = fcod-nl.
          fcode = fcode_next = fcod-sl.
          PERFORM fcode_lesen USING fcode.
        ENDIF.
      ENDIF.
    ELSEIF ccode IS INITIAL.
      MESSAGE e001 WITH 'T158B' tcode.
    ENDIF.
  ENDIF.
  IF xkzbew = 3 OR xkzbew = 4.
    CLEAR rm07m-sobkz.
  ENDIF.

ENDMODULE.                    "bwart_we

*---------------------------------------------------------------------*
*       MODULE CALL_MODUS                                             *
*---------------------------------------------------------------------*
*       Der Funktionscode für das erste Dynpro wird gemerkt.          *
*       Damit wird die Funktion von 'ZURÜCK' bei CALL TRANSACTION     *
*       gewährleistet.                                                *
*---------------------------------------------------------------------*
MODULE call_modus.

  CLEAR ok-code.
  IF NOT sy-calld IS INITIAL.
    call_fcode = fcode_next.
  ENDIF.

ENDMODULE.                    "call_modus

*---------------------------------------------------------------------*
*       MODULE DRUCK_PRÜFEN                                           *
*---------------------------------------------------------------------*
*       Wenn eine Druckerdestination angegeben ist, und der           *
*       Defaultwert der Version des Warenbegleitscheins               *
*       geändert wurde, werden die Bildschirmeingaben geprüft         *
*       und die gewählte Version wird dem Materialbelegkopf           *
*       übergeben.                                                    *
*---------------------------------------------------------------------*
MODULE druck_pruefen.

  CLEAR ok-code.
  PERFORM druck_pruefen.

ENDMODULE.                    "druck_pruefen

*---------------------------------------------------------------------*
*       MODULE DYNPRO_VORBEREITEN                                     *
*---------------------------------------------------------------------*
*       Das folgende Dynpro wird vorbereitet.                         *
*---------------------------------------------------------------------*
MODULE dynpro_vorbereiten.

  CLEAR ok-code.
  CHECK abbrechen IS INITIAL.
  PERFORM dynpro_vorbereiten.

ENDMODULE.                    "dynpro_vorbereiten

*---------------------------------------------------------------------*
*       MODULE DYNPRO_VERLASSEN                                       *
*---------------------------------------------------------------------*
*       Verlassen von POP-UP-Windows bei PF03                         *
*---------------------------------------------------------------------*
MODULE dynpro_verlassen.

  CLEAR ok-code.
  IF NOT fcausw-xselp IS INITIAL.
    CLEAR aufsetzen_1.
  ENDIF.
  IF fcausw-xlist IS INITIAL AND NOT aufsetzen IS INITIAL.
    a_zeile = aufsetzen.
  ENDIF.
  CLEAR: old_pfsta, old_tit, xkzbw, xbcode.
  IF t158-kzbew IS INITIAL OR xkzbew = 1.
    old_bwartwa = rm07m-bwartwa.
    old_sobkz   = rm07m-sobkz.
  ELSE.
    old_bwartwe = rm07m-bwartwe.
  ENDIF.
  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.                    "dynpro_verlassen

*---------------------------------------------------------------------*
*       MODULE EAN_PRUEFEN.                                           *
*---------------------------------------------------------------------*
*       Die EAN-Nummern werden geprüft.                               *
*---------------------------------------------------------------------*
MODULE ean_pruefen.

  CHECK aktyp NE a.
  PERFORM ean_pruefen.

ENDMODULE.                    "ean_pruefen

*---------------------------------------------------------------------*
*       MODULE EINGABEKOMBINATION_WA                                  *
*---------------------------------------------------------------------*
*       Die Eingabekombination beim Warenausgang wird geprueft.       *
*---------------------------------------------------------------------*
MODULE eingabekomb_wa.

  CLEAR ok-code.
  IF NOT bcode IS INITIAL.
    rm07m-bwart = bcode-bwart.
    rm07m-sobkz = bcode-sobkz.
  ENDIF.
  IF t063o-ccode IS INITIAL OR t063o-ccode = ccod-lvs0.
    IF NOT rm07m-matnr IS INITIAL.
      fcode_next = fcod-np.
    ENDIF.
    PERFORM fcode_pruefen.
  ENDIF.
  ecode = fcode_next.

  IF rm07m-sobkz = 'W'.                                     "612082
    SELECT SINGLE * FROM t148t                              "612082
                   WHERE spras = sy-langu                   "612082
                     AND sobkz = rm07m-sobkz.               "612082
    IF NOT rm07m-lgort IS INITIAL.                          "612082
      PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '737'  "612082
                       rm07m-sobkz t148t-sotxt space space. "612082
      CLEAR rm07m-lgort.                                    "612082
    ENDIF.                                                  "612082
  ENDIF.                                                    "612082

ENDMODULE.                    "eingabekomb_wa

*---------------------------------------------------------------------*
*       MODULE EINGABEKOMBINATION_WE                                  *
*---------------------------------------------------------------------*
*       Die Eingabekombination beim Wareneingang wird geprueft.       *
*---------------------------------------------------------------------*
MODULE eingabekomb_we.

  CLEAR: ok-code, rc.
  IF NOT xkzbew IS INITIAL.
    DATA: l_rc LIKE sy-subrc.
    CALL FUNCTION 'MB_CHECK_T160M'
      EXPORTING
        i_arbgb  = 'M7'
        i_msgnr  = '252'
        i_nolog  = x
        i_output = space
      IMPORTING
        rc       = l_rc.
    CASE l_rc.
      WHEN 1.
        rc = 1.
      WHEN 2.
        CLEAR xkzbew.
        rc = 2.
      WHEN OTHERS.
    ENDCASE.
  ELSE.
    rc = 2.
  ENDIF.
  IF NOT bcode IS INITIAL.
    rm07m-bwart = bcode-bwart.
    CLEAR bcode.
  ENDIF.
  IF rm07m-ebeln IS INITIAL AND t063o-ccode IS INITIAL.
    IF sy-dynnr = '1299' AND xkzbew IS INITIAL.
      MESSAGE e019 WITH rm07m-bwart rm07m-sobkz.
    ENDIF.
    SET CURSOR FIELD 'RM07M-EBELN'.
    IF rc = 2.
      PERFORM no_input(sapfm07m) USING 'RM07M' 'EBELN'.
    ELSEIF ( NOT t156-xnebe IS INITIAL AND
             t063c-ccode NE ccod-nebe ).
      MESSAGE w252.                    "ok / nicht in log
    ENDIF.
  ENDIF.

ENDMODULE.                    "eingabekomb_we

*--------------------------------------------------------------------*
*       MODULE EINGABEKOMBINATION_WF                                 *
*--------------------------------------------------------------------*
*       Die Eingabekombination beim Wareneingang zum Fertigungsauf-  *
*       trag wird geprüft.                                           *
*--------------------------------------------------------------------*
MODULE eingabekomb_wf.

  CLEAR ok-code.
  IF NOT bcode IS INITIAL.
    rm07m-bwart = bcode-bwart.
    rm07m-sobkz = bcode-sobkz.
    CLEAR bcode.
  ENDIF.
  IF rm07m-aufnr IS INITIAL AND t063o-ccode IS INITIAL.
    PERFORM no_input(sapfm07m) USING 'RM07M' 'AUFNR'.
  ENDIF.

ENDMODULE.                    "eingabekomb_wf

*---------------------------------------------------------------------*
*       MODULE ELIKZ_INPUT                                            *
*---------------------------------------------------------------------*
MODULE elikz_input.
  dm07m-elikz_input = x.
ENDMODULE.                    "elikz_input

*---------------------------------------------------------------------*
*       MODULE FCODE_BEARBEITEN                                       *
*---------------------------------------------------------------------*
*       Der eingegebene Funktionscode wird ausgewertet.               *
*---------------------------------------------------------------------*
MODULE fcode_bearbeiten.

  CLEAR ok-code.
  CHECK abbrechen IS INITIAL.
  PERFORM fcode_bearbeiten.

ENDMODULE.                    "fcode_bearbeiten

*---------------------------------------------------------------------*
*       MODULE FCODE_NB_SETZEN                                        *
*---------------------------------------------------------------------*
*       Beim WE mit automatischen Anlegen von Bestellungen wird       *
*       als FCODE NB gesetzt (wie KL nur für Folgedynpro in T063...)  *
*---------------------------------------------------------------------*
MODULE fcode_ng_setzen.

  IF fcode_next = fcod-kl.
    fcode_next = fcod-ng.
  ENDIF.

ENDMODULE.                    "fcode_ng_setzen

*---------------------------------------------------------------------*
*       MODULE Frachtlieferant uebernehmen.                           *
*---------------------------------------------------------------------*
*       Der eingegebene Frachtlieferant wird übenommen.               *
*---------------------------------------------------------------------*
MODULE f_lieferant_aendern.

  PERFORM f_lieferant_uebernehmen.

ENDMODULE.                    "f_lieferant_aendern
*---------------------------------------------------------------------*
*          Module FRACHT_POPUP_VERLASSEN                              *
*          At Exit-Command wird das Pop up verlassen                  *
*---------------------------------------------------------------------*
MODULE fracht_popup_verlassen.
  CLEAR ok-code.
  SET SCREEN 0.
  LEAVE SCREEN.
ENDMODULE.                    "fracht_popup_verlassen
*---------------------------------------------------------------------*
*       MODULE FCODE_PRUEFEN                                          *
*---------------------------------------------------------------------*
*       Der Funktionscode wird geprueft.                              *
*---------------------------------------------------------------------*
MODULE fcode_pruefen.

  CLEAR ok-code.
  PERFORM fcode_pruefen.

ENDMODULE.                    "fcode_pruefen

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_NEU                                      *
*---------------------------------------------------------------------*
*       Die Fusszeile bei Warenausgaben wird bei neu eingegebener     *
*       Materialnummer geprueft.                                      *
*---------------------------------------------------------------------*
MODULE fusszeile_neu.

  CLEAR ok-code.
  PERFORM fusszeile_neu.

ENDMODULE.                    "fusszeile_neu

*---------------------------------------------------------------------*
*       MODULE FUSSZEILE_SETZEN                                       *
*---------------------------------------------------------------------*
*       Die Daten aus den RM07M-Feldern der Fusszeile werden in die   *
*       BSEG, MSEG, DM07M und VM07M-Felder uebernommen.               *
*---------------------------------------------------------------------*
MODULE fusszeile_setzen.

  CLEAR ok-code.
  PERFORM fusszeile_setzen.

ENDMODULE.                    "fusszeile_setzen

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_WA                                       *
*---------------------------------------------------------------------*
*       Die Fusszeile bei Warenbewegungen ohne Referenzbeleg          *
*       wird bearbeitet.                                              *
*---------------------------------------------------------------------*
MODULE fusszeile_wa.
  DATA: ls_isu_fusszeile_wa TYPE isu_fusszeile_wa.          "IS2ERP

  CLEAR ok-code.
  CHECK xpf02 IS INITIAL OR xpf02 = x.
  CHECK t158-trtyp = h.
  CHECK NOT mseg-matnr IS INITIAL.
  PERFORM steuerflags_initialisieren(sapfm07m).
  PERFORM fusszeile_wa USING ls_isu_fusszeile_wa.           "IS2ERP

ENDMODULE.                    "fusszeile_wa

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_WA_NEU                                   *
*---------------------------------------------------------------------*
*       Die Fusszeile bei Warenbewegungen ohne Referenzbeleg          *
*       wird bearbeitet.                                              *
*---------------------------------------------------------------------*
MODULE fusszeile_wa_neu.
  CLEAR ok-code.
  IF t063c-ccode IS INITIAL.
    IF mseg-bwart IS INITIAL.
      mseg-bwart = rm07m-bwart.
    ENDIF.
    IF mseg-sobkz IS INITIAL.
      mseg-sobkz = rm07m-sobkz.
    ENDIF.
    IF mseg-werks IS INITIAL.
      mseg-werks = rm07m-werks.
    ENDIF.
    PERFORM fusszeile_wa USING ls_isu_fusszeile_wa.         "IS2ERP
  ELSE.
    CLEAR: mseg-bwart, mseg-sobkz.
  ENDIF.

ENDMODULE.                    "fusszeile_wa_neu

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_WE                                       *
*---------------------------------------------------------------------*
*       Die Fusszeile bei Wareneingaengen zu Bestellungen             *
*       wird bearbeitet.                                              *
*---------------------------------------------------------------------*
MODULE fusszeile_we.
  DATA: ls_isu_fusszeile_we TYPE isu_fusszeile_we.          "IS2ERP
  CLEAR ok-code.
  CHECK xpf02 IS INITIAL OR xpf02 = x.
  CHECK xkzbew IS INITIAL.
  CHECK t158-trtyp = h.
  PERFORM steuerflags_initialisieren(sapfm07m).
  PERFORM fusszeile_we USING ls_isu_fusszeile_we.           "IS2ERP

ENDMODULE.                    "fusszeile_we

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_WE_NEU                                   *
*---------------------------------------------------------------------*
*       Die Fusszeile bei Wareneingaengen zu Bestellungen             *
*       wird bei neu eingegebener Bestellung geprueft.                *
*---------------------------------------------------------------------*
MODULE fusszeile_we_neu.

  CLEAR ok-code.
  IF NOT anf_bild IS INITIAL AND t156t-btext IS INITIAL AND
     NOT xkzbew IS INITIAL.
    PERFORM bewegungstext_lesen(sapfm07m) USING rm07m-bwart
                                                rm07m-sobkz
                                                rm07m-kzbew
                                                 mseg-kzzug
                                                 mseg-kzvbr
                                                  old_btext.
  ENDIF.
  CHECK NOT rm07m-ebeln IS INITIAL.
  PERFORM fusszeile_we_neu.

ENDMODULE.                    "fusszeile_we_neu

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_WF_NEU                                   *
*---------------------------------------------------------------------*
*       Die Fusszeile bei Wareneingängen zu Fertigungsaufträgen       *
*       wird bei neu eingegebenem Fertigungsauftrag geprüft.          *
*---------------------------------------------------------------------*
MODULE fusszeile_wf_neu.

  CLEAR ok-code.
  PERFORM fusszeile_wf_neu.

ENDMODULE.                    "fusszeile_wf_neu

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_WO                                       *
*---------------------------------------------------------------------*
*       Die Fusszeile für die Verrechnung von Beistellpositionen      *
*       wird bearbeitet.                                              *
*---------------------------------------------------------------------*
MODULE fusszeile_wo.

  CLEAR ok-code.
  CHECK xpf02 IS INITIAL OR xpf02 = x.
  PERFORM steuerflags_initialisieren(sapfm07m).
  PERFORM fusszeile_wo.

ENDMODULE.                    "fusszeile_wo

*---------------------------------------------------------------------*
*       MODULE     FUSSZEILE_WO_ENDE                                  *
*---------------------------------------------------------------------*
*       Die Fusszeilenbearbeitung für die Verrechnung von             *
*       Beistellpositionen wird abgeschlossen.                        *
*---------------------------------------------------------------------*
MODULE fusszeile_wo_ende.

  CLEAR ok-code.
  CHECK xpf02 IS INITIAL OR xpf02 = x.
  PERFORM fusszeile_wo_ende.

ENDMODULE.                    "fusszeile_wo_ende

*---------------------------------------------------------------------*
*       MODULE GRUND_PRUEFEN                                          *
*---------------------------------------------------------------------*
*       Der Grund für die Bewegung wird geprüft.                      *
*---------------------------------------------------------------------*
MODULE grund_pruefen.

  CLEAR ok-code.
  CHECK t158-trtyp = h.
  PERFORM grund_pruefen.

ENDMODULE.                    "grund_pruefen

*---------------------------------------------------------------------*
*           MODULE HTN_PRUEFEN                                        *
*---------------------------------------------------------------------*
MODULE htn_pruefen INPUT.
  CHECK NOT mseg-ematn IS INITIAL.
  PERFORM mpn_pruefen.
ENDMODULE.                    "htn_pruefen INPUT
*---------------------------------------------------------------------*
*       MODULE JV_price_dialog_crp                                    *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
MODULE jv_price_dialog_crp INPUT.

  PERFORM jv_price_dialog_crp.      .

ENDMODULE.                    "jv_price_dialog_crp INPUT
*---------------------------------------------------------------------*
*     MODULE JV_PRICING_CRP                                           *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
MODULE jv_pricing_crp INPUT.

  PERFORM jv_pricing_crp.           .

ENDMODULE.                    "jv_pricing_crp INPUT
*---------------------------------------------------------------------*
*       MODULE JV_read_crp_data                                       *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
MODULE jv_read_crp_data INPUT.

  PERFORM jv_read_crp_data.

ENDMODULE.                    "jv_read_crp_data INPUT
*---------------------------------------------------------------------*
*       MODULE JV_save_crpcal                                         *
*---------------------------------------------------------------------*
*       Joint Venture Accounting                                      *
*---------------------------------------------------------------------*
MODULE jv_save_crpcal INPUT.

  PERFORM jv_save_crpcal.

ENDMODULE.                    "jv_save_crpcal INPUT
*---------------------------------------------------------------------*
*       MODULE KDAUF_PRUEFEN                                          *
*---------------------------------------------------------------------*
*       Der Kundenauftrag wird explizit geprüft, wenn es sich         *
*       um Kundenauftragsbestand handelt. Dann erfolgt keine          *
*       Prüfung über den Kontierungsblock.                            *
*---------------------------------------------------------------------*
MODULE kdauf_pruefen.

  CHECK aktyp NE a.                                       "note 1433241
  CHECK NOT rm07m-kzbew = l.
ENHANCEMENT-SECTION MM07MI00_KDAUF_PRUEFEN_01 SPOTS ES_SAPMM07M .
  IF ( mseg-sobkz = e AND mseg-umsok <> t ) OR                      "SIT
     ( mseg-umsok = e AND mseg-sobkz <> t ).
    PERFORM kundenauftrag_pruefen.
  ENDIF.
END-ENHANCEMENT-SECTION.
  IF mseg-sobkz = t.                                                "SIT
    msegk-mat_kdauf = dm07m-vbeln_vl.
    msegk-mat_kdpos = dm07m-vbelp_vl.
    PERFORM lieferung_pruefen(sapmm07m)
            USING msegk-mat_kdauf msegk-mat_kdpos.
  ELSEIF mseg-umsok = t.
    mseg-kdauf = dm07m-vbeln_vl.
    mseg-kdpos = dm07m-vbelp_vl.
    PERFORM lieferung_pruefen(sapmm07m)
            USING mseg-kdauf mseg-kdpos.
  ELSEIF t156-bustr = '559' AND aktyp = 'H'.        "1657162
    IF vm07m-vbeln IS INITIAL.                      "1657162
      vm07m-vbeln = dm07m-vbeln_vl.
      vm07m-vbelp = dm07m-vbelp_vl.
    ENDIF.                                          "1657162
    PERFORM lieferung_pruefen(sapmm07m)             "1657162
            USING vm07m-vbeln vm07m-vbelp.          "1657162

  ENDIF.

ENDMODULE.                    "kdauf_pruefen

*---------------------------------------------------------------------*
*       MODULE KLASSIFIZIERUNG                                        *
*---------------------------------------------------------------------*
*       Die Klassifizierung wird aufgerufen.                          *
*---------------------------------------------------------------------*
MODULE klassifizierung.
  DATA: loc_feld(11).                                      "note 129198
  CHECK t158-trtyp = h.
  PERFORM chargen_klassifizieren USING aktyp               "note 129198
                                       loc_feld.           "note 129198
ENDMODULE.                    "klassifizierung

*---------------------------------------------------------------------*
*       MODULE KONDITIONSSATZ_SUCHEN                                  *
*---------------------------------------------------------------------*
*       Der Konditionssatz wird gesucht.                              *
*---------------------------------------------------------------------*
MODULE konditionssatz_suchen.

  PERFORM konditionssatz_suchen.

ENDMODULE.                    "konditionssatz_suchen

*---------------------------------------------------------------------*
*       MODULE KONTIERUNG_LESEN                                       *
*---------------------------------------------------------------------*
*       Das Sachkonto wird gelesen.                                   *
*---------------------------------------------------------------------*
MODULE kontierung_lesen.

  CLEAR ok-code.
  IF NOT fcausw-xlist IS INITIAL AND NOT fcausw-xneup IS INITIAL.
    dm07m-konto = msegk-konto.
  ENDIF.
  PERFORM kontierung_lesen USING  mseg-parbu
                                 dm07m-parwk
                                 dm07m-umkpl
                                 dm07m-umper
                                 dm07m-umwae
                                  mkpf-budat
                                 dm07m-umgja
                                 dm07m-ummon
                                 dm07m-konto
                                  mseg-anln1.

ENDMODULE.                    "kontierung_lesen

*---------------------------------------------------------------------*
*       MODULE KONTIERUNG_MERKEN                                      *
*---------------------------------------------------------------------*
*       Kontierungsdaten aus Blockerfassungsbild merken.              *
*---------------------------------------------------------------------*
MODULE kontierung_merken.

  CLEAR ok-code.
  PERFORM kontierung_merken.

ENDMODULE.                    "kontierung_merken

*---------------------------------------------------------------------*
*       MODULE KONTIERUNG_SETZEN                                      *
*---------------------------------------------------------------------*
*       Kontierungsdaten werden in das Segment uebernommen.           *
*---------------------------------------------------------------------*
MODULE kontierung_setzen.

  CLEAR ok-code.
  PERFORM kontierung_setzen.

ENDMODULE.                    "kontierung_setzen

*---------------------------------------------------------------------*
*       MODULE LAGERORTDATEN                                          *
*---------------------------------------------------------------------*
*       Die Daten auf Lagerort- und Chargenebene des Materials        *
*       werden geprueft und ins Segment uebernommnen.                 *
*---------------------------------------------------------------------*
MODULE lagerortdaten.
  DATA: ls_isu_lagerortdaten TYPE isu_lagerortdaten.        "IS2ERP
  CLEAR ok-code.
  PERFORM fill_erfme_erfmg_menge(sapfm07m) USING space. "INS SW
  PERFORM lagerortdaten USING ls_isu_lagerortdaten.         "IS2ERP
  CHECK xpaus IS INITIAL.              "INS SW ALRK037262
  PERFORM mindesthaltbarkeit_pruefen.  "INS SW ALRK037262

ENDMODULE.                    "lagerortdaten

*----------------------------------------------------------------------*
*       Module  LICHA_PRUEFEN  INPUT
*----------------------------------------------------------------------*
MODULE licha_pruefen INPUT.

* Material wird in Chargen geführt (auch Dummy Chargen)
  CHECK NOT mseg-charg IS INITIAL.
  CHECK aktyp EQ k.

  PERFORM licha_pruefen(sapfm07m) USING mseg-matnr
                                        mseg-werks
                                        mseg-charg
                                        space.

ENDMODULE.                    "licha_pruefen INPUT

*----------------------------------------------------------------------*
*       MODULE MENGE_PRUEFEN                                           *
*----------------------------------------------------------------------*
*       Die Menge wird geprueft.                                       *
*----------------------------------------------------------------------*
MODULE menge_pruefen.
  DATA: ls_isu_alternative_mengen TYPE isu_alternative_mengen, "IS2ERP
        ls_isu_menge_pruefen_01   TYPE isu_menge_pruefen_01. "IS2ERP
  CLEAR ok-code.
  CHECK xpaus IS INITIAL.
  IF t063c-ccode = ccod-verf.
    CALL SCREEN t063c-dynnr STARTING AT t063c-winx1 t063c-winy1
                            ENDING   AT t063c-winx2 t063c-winy2.
    CLEAR: t063c, t063o, ccode.
  ENDIF.

* Anteils-/variable Mengenumrechnung (Stahl/Wirkstoffabwicklung)
  PERFORM alternative_mengen USING space                    "ALRK014884
                                   ls_isu_alternative_mengen. "IS2ERP

  PERFORM menge_pruefen_01 USING ls_isu_menge_pruefen_01.   "IS2ERP

*  IF t158-trtyp = h.                                       "note388608
*    PERFORM serialnummern_pruefen.                         "note388608
*  ELSE.                                                    "note388608
*    IF NOT dm07m-sernp IS INITIAL.                         "note388608
*      CHECK ccode EQ ccod-nser.                            "note388608
*      PERFORM serialnummern_pflegen.                       "note388608
*    ENDIF.                                                 "note388608
*  ENDIF.                                                   "note388608
ENHANCEMENT-POINT MENGE_PRUEFEN_02 SPOTS ES_MM07MTOP.

ENHANCEMENT-POINT MENGE_PRUEFEN_01 SPOTS ES_SAPMM07M.
ENDMODULE.                    "menge_pruefen

*---------------------------------------------------------------------*
*       MODULE OK-CODE_PRUEFEN                                        *
*---------------------------------------------------------------------*
*       Die OK-CODE-Eingabe wird geprueft.                            *
*---------------------------------------------------------------------*
MODULE ok-code_pruefen.

  PERFORM ok-code_pruefen.
  CLEAR ok-code.

ENDMODULE.                    "ok-code_pruefen

*---------------------------------------------------------------------*
*       MODULE OK-CODE_POP_PRUEFEN                                    *
*---------------------------------------------------------------------*
*       Die OK-CODE-Eingabe wird geprueft.                            *
*---------------------------------------------------------------------*
MODULE ok-code_pop_pruefen.

  CHECK NOT ok-code IS INITIAL.
  PERFORM ok-code_pop_pruefen.
  CLEAR ok-code.

ENDMODULE.                    "ok-code_pop_pruefen

*---------------------------------------------------------------------*
*       MODULE PICKUP_AUSFUEHREN                                      *
*---------------------------------------------------------------------*
*       Verarbeitung bei OK-Code PF02.                                *
*---------------------------------------------------------------------*
MODULE pickup_ausfuehren.

  CLEAR ok-code.
  PERFORM pickup_ausfuehren.

ENDMODULE.                    "pickup_ausfuehren

*---------------------------------------------------------------------*
*       MODULE POPUP_VERLASSEN                                        *
*---------------------------------------------------------------------*
*       Verarbeitung bei EXIT-COMMAND auf POPUP                       *
*---------------------------------------------------------------------*
MODULE popup_verlassen.
  CLEAR: ok-code, ccode, xkzbw.
  PERFORM popup_verlassen.

ENDMODULE.                    "popup_verlassen

*---------------------------------------------------------------------*
*       MODULE POPUP_VERLASSEN_INIT                                   *
*---------------------------------------------------------------------*
*       Verarbeitung bei EXIT-COMMAND auf POPUP                       *
*       Hier: Call in zweiter Stufe verlassen, mit zurücksetzen der   *
*             internen Tabelle.                                       *
*---------------------------------------------------------------------*
MODULE popup_verlassen_init.

  CLEAR ok-code.
  IF NOT t063c-ccode_next IS INITIAL.
    CLEAR: t063c-ccode_next.
  ENDIF.
  IF NOT xpf02 IS INITIAL.
    abbrechen = x.
    CLEAR: xpf02,
           fuss,
           index_l,
           ccode.
  ENDIF.
  SET SCREEN 0.
  LEAVE SCREEN.

ENDMODULE.                    "popup_verlassen_init

*---------------------------------------------------------------------*
*       MODULE  PPS_AUFTRAG_WA_POP                                    *
*---------------------------------------------------------------------*
*       Der Auftragskopf bei Warenbewegung zum Auftrag... wird        *
*       gelesen.                                                      *
*---------------------------------------------------------------------*
MODULE pps_auftrag_wa_pop.

  CHECK NOT rm07m-aufnr IS INITIAL.
  PERFORM pps_auftrag_wa_pop.

ENDMODULE.                    "pps_auftrag_wa_pop


*---------------------------------------------------------------------*
*       MODULE RECEIVE                                                *
*---------------------------------------------------------------------*
*       Rückgabe des Kontierungsblocks zum Hauptdynpro                *
*       Hier muß sichergestellt werden, daß keine wichtigen           *
*       MM-Daten überschrieben werden. Deshalb werden diese           *
*       'sensiblen Daten' in COBL_MM gesichert.                       *
*---------------------------------------------------------------------*
MODULE receive.
ENHANCEMENT-POINT RECEIVE_01 SPOTS ES_SAPMM07M.
  PERFORM kontblock_receive.
ENHANCEMENT-POINT RECEIVE_02 SPOTS ES_SAPMM07M.
ENDMODULE.                    "receive

*---------------------------------------------------------------------*
*       MODULE RESERVIERUNG_LESEN                                     *
*---------------------------------------------------------------------*
*       Die Reservierung wird gelesen und ergänzt.                    *
*---------------------------------------------------------------------*
MODULE reservierung_lesen.

  CLEAR ok-code.
  PERFORM reservierung_lesen.

ENDMODULE.                    "reservierung_lesen

*---------------------------------------------------------------------*
*       MODULE SEGMENT_HINZUFUEGEN.                                   *
*---------------------------------------------------------------------*
*       Das Segment mit den verprobten Daten wird hinzugefuegt.       *
*---------------------------------------------------------------------*
MODULE segment_hinzufuegen.

 IF NOT mseg-xmacc = 'V'.                                  "MAA2
    CLEAR ok-code.
    PERFORM segment_hinzufuegen.
 ENDIF.                                                    "MAA2
ENDMODULE.                    "segment_hinzufuegen

*---------------------------------------------------------------------*
*       MODULE SEGMENT_INIT                                           *
*---------------------------------------------------------------------*
*       Die Segmente werden initialisiert.                            *
*---------------------------------------------------------------------*
MODULE segment_init.

  CLEAR ok-code.
  CLEAR: dm07m-xprms,
         dm07m-cuobj.                                       "774823
  IF NOT fcausw-xaenp IS INITIAL.
    PERFORM segment_init.
  ENDIF.

ENDMODULE.                    "segment_init

*---------------------------------------------------------------------*
*       MODULE SEGMENT_SCHREIBEN                                      *
*---------------------------------------------------------------------*
*       Das geaenderte Segment wird zurueckgeschrieben.               *
*---------------------------------------------------------------------*
MODULE segment_schreiben.
  IF NOT mseg-xmacc = 'V'.                                  "MAA2
    CLEAR ok-code.
    PERFORM segment_schreiben.
  ENDIF.                                                    "MAA2
ENDMODULE.                    "segment_schreiben

*---------------------------------------------------------------------*
*       MODULE SEND_PAI                                               *
*---------------------------------------------------------------------*
*       Übergabe der zum Zeitpunkt PAI auf dem Hauptdynpro gefüllten  *
*       Felder, die sich auch in der Struktur COBL befinden.          *
*       Für die Programmsteurung im Kontierungsblock muß              *
*       'Prozeß' und 'Ereignis' im RWIN mitgegeben werden.            *
*---------------------------------------------------------------------*
MODULE send_pai.

  PERFORM kontierungsblock_send_pai.
ENHANCEMENT-POINT SEND_PAI_01 SPOTS ES_SAPMM07M.

ENDMODULE.                    "send_pai

*---------------------------------------------------------------------*
*       MODULE STUECKLISTE_LESEN                                      *
*---------------------------------------------------------------------*
*       Die Stückliste wird gelesen und ergänzt.                      *
*---------------------------------------------------------------------*
MODULE stueckliste_lesen.

  PERFORM stueckliste_lesen.

ENDMODULE.                    "stueckliste_lesen

*---------------------------------------------------------------------*
*       MODULE UMLAGERUNG_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Die Daten der Umlagerung werden geprueft.                     *
*---------------------------------------------------------------------*
MODULE umlagerung_pruefen.

  CLEAR ok-code.
  PERFORM umlagerung_pruefen.
  PERFORM mhd_pruefen_umlagerung.

ENDMODULE.                    "umlagerung_pruefen

*----------------------------------------------------------------------*
*       MODULE VERSANDVORS_PRUEFEN                                     *
*----------------------------------------------------------------------*
*       Die Versandvorschrift wird geprüft.                            *
*----------------------------------------------------------------------*
MODULE versandvors_pruefen.

  CHECK t158-trtyp = h.
  CHECK mseg-shkzg = s.
  CHECK mseg-xmacc IS INITIAL OR mseg-xmacc = 'V'.               "MAA2
  CHECK vm07m-kzwes NE s.
  IF NOT mseg-evers IS INITIAL AND mseg-evere IS INITIAL.
    PERFORM versandvorschrift_pruefen.
  ENDIF.

ENDMODULE.                    "versandvors_pruefen

*----------------------------------------------------------------------*
*       MODULE VORGANGSART_PRUEFEN                                     *
*----------------------------------------------------------------------*
*       Die Vorgangsart wird geprüft.                                  *
*----------------------------------------------------------------------*
MODULE vorgangsart_pruefen.

  PERFORM vorgangsart_pruefen.

ENDMODULE.                    "vorgangsart_pruefen

*---------------------------------------------------------------------*
*       MODULE WE_DATUM_PRUEFEN                                       *
*---------------------------------------------------------------------*
*    1. Bei ERS-Verfahren wird der Lieferschein geprüft.              *
*    2. Das letztmögliche WE-Datum aus der Bestellung wird geprüft.   *
*    3. Das (früheste) Lieferdatum aus der Bestellung wird geprüft.   *
*---------------------------------------------------------------------*
MODULE we_datum_pruefen.
  PERFORM bestelldaten_pruefen.
ENDMODULE.                    "we_datum_pruefen

*---------------------------------------------------------------------*
*       MODULE WERK_PRUEFEN                                           *
*---------------------------------------------------------------------*
*       Das Werk wird geprüft bei 'Vorschlagswerte...'.               *
*---------------------------------------------------------------------*
MODULE werk_pruefen.

  IF rm07m-werks IS INITIAL.
    PERFORM no_input(sapfm07m) USING 'RM07M' 'WERKS'.
  ENDIF.
  SET CURSOR FIELD 'RM07M-LGORT'.
  PERFORM werk_pruefen(sapfm07m) USING     x
                                       rm07m-werks
                                       vm07m-bwkey
                                       dm07m-bwmod
                                       dm07m-xeink
                                       dm07m-xbkng
                                       vm07m-xvkbw
                                       rm07m-bukrs
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
  PERFORM buchungskreis_testen.
  IF km07r-waers IS INITIAL.
    mseg-parbu = msegk-parbu = ymsegk-parbu = rm07m-bukrs.
    MODIFY ymsegk INDEX 1.
  ENDIF.

ENDMODULE.                    "werk_pruefen

*---------------------------------------------------------------------*
*       MODULE XAB_NUMMER_PRUEFEN                                     *
*---------------------------------------------------------------------*
MODULE xab_nummer_pruefen.

  CHECK t158-trtyp = h.
  CHECK mseg-xauto IS INITIAL.   "no check for automtic lines
* no check for subcontracting components
  IF vm07m-pstyp = '3'.                                     "note407178
    CHECK NOT mseg-kzbew IS INITIAL.
  ENDIF.
  IF mkpf-xabln IS INITIAL.
* Deckt nicht den Fall einer Umlagerbestellung mit SHKZG = 'S' ab, d.h.
* das Umlagerwerk ist das abgebende Werk -> muß anders gebucht werden.
    IF NOT mseg-umwrk IS INITIAL AND mseg-shkzg EQ s.
      PERFORM check_ixab_number USING mseg-bwart
                                      mseg-umwrk
                                      mseg-umlgo
                                      dm07m-umkzxab.
    ELSE.                              "normaler Fall
      PERFORM check_ixab_number USING mseg-bwart
                                      mseg-werks
                                      mseg-lgort
                                      dm07m-kzxab.
    ENDIF.
  ELSE.
    PERFORM check_exab_position USING mseg-bwart
                                      mseg-werks
                                      mseg-lgort
                                      dm07m-kzxab.
  ENDIF.

ENDMODULE.                    "xab_nummer_pruefen

*---------------------------------------------------------------------*
*       MODULE XABLN-SETZEN                                           *
*---------------------------------------------------------------------*
* Bei Eingabe einer XAB-Belegnummer wird die Nummer in den Belegkopf  *
* übernommen.                                                         *
*---------------------------------------------------------------------*
MODULE xabln_setzen.

  IF rm07m-werks IS INITIAL.
    PERFORM no_input(sapfm07m) USING 'RM07M' 'WERKS'.
    SET CURSOR FIELD 'RM07M-WERKS'.
  ENDIF.
  IF rm07m-lgort IS INITIAL.
    PERFORM no_input(sapfm07m) USING 'RM07M' 'LGORT'.
    SET CURSOR FIELD 'RM07M-LGORT'.
    MESSAGE e039.
  ENDIF.
  PERFORM check_exab_number USING rm07m-bwart
                                  rm07m-werks
                                  rm07m-lgort
                                  rm07m-xabln
                                  dm07m-kzxab.
  mkpf-xabln = rm07m-xabln.

ENDMODULE.                    "xabln_setzen

*---------------------------------------------------------------------*
*       MODULE XBLNRWA_SETZEN                                         *
*---------------------------------------------------------------------*
*       Die externe Belegnummer im Belegkopf wird aus dem Material-   *
*       schein gesetzt.                                               *
*---------------------------------------------------------------------*
MODULE xblnrwa_setzen.

  PERFORM xblnrwa_setzen.

ENDMODULE.                    "xblnrwa_setzen

*---------------------------------------------------------------------*
*       MODULE XBLNRWE_SETZEN                                         *
*---------------------------------------------------------------------*
*       Die externe Belegnummer im Belegkopf wird aus dem Liefer-     *
*       schein gesetzt.                                               *
*---------------------------------------------------------------------*
MODULE xblnrwe_setzen.

  PERFORM xblnrwe_setzen.

ENDMODULE.                    "xblnrwe_setzen

*---------------------------------------------------------------------*
*       MODULE XCONFIRM_SETZEN                                        *
*---------------------------------------------------------------------*
*       Bei einer Eingabe wird XCONFIRM gesetzt.                      *
*       Damit wird gesteuert, ob ein                                  *
*       Kontroll-PopUp beim Verlassen der Transaktion gesendet wird.  *
*---------------------------------------------------------------------*
MODULE xconfirm_setzen.

  CLEAR ok-code.
  xconfirm = x.

ENDMODULE.                    "xconfirm_setzen

*----------------------------------------------------------------------*
*       Module  PSPNR_PRUEFEN  INPUT
*----------------------------------------------------------------------*
*    Explizite Prüfung des Projekts
*----------------------------------------------------------------------*
MODULE pspnr_pruefen INPUT.
  IF t158-trtyp = 'H' AND         "no check in case of MB02/MB03 934187
     NOT t156-bustr = '559'.                              "1657162
    CHECK NOT rm07m-kzbew = l.
    PERFORM projekt_pruefen.
  ENDIF.                                                    "934187

ENDMODULE.                             " PSPNR_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*&      Module  PF4HELP_ME  INPUT
*&---------------------------------------------------------------------*
MODULE pf4help_me INPUT.
  PERFORM pf4help_me USING    mseg-matnr
                     CHANGING mseg-erfme.
ENDMODULE.                             " PF4HELP_ME  INPUT
ENHANCEMENT-POINT MM07MI00_01 SPOTS ES_SAPMM07M STATIC.
*&---------------------------------------------------------------------*
*&      Module  ERFME_IMPUT  INPUT
*&---------------------------------------------------------------------*
*       Added by note 458130
*       This module is called when mseg-erfmg is changes on screen
*       210 (mb01), 310 (mb31).
*       New unit conversion is necessary -> the old
*       values of dm07m-umrez and dm07m-umren have to be cleared
*       otherwise MB_UNIT_CONVERSION would use them.
*----------------------------------------------------------------------*
MODULE erfme_input INPUT.
  PERFORM conversion_factors_clear.
ENDMODULE.                 " ERFME_IMPUT  INPUT
*&---------------------------------------------------------------------*
*&      Module  erfme_input_fuss  INPUT
*&---------------------------------------------------------------------*
*       Added by note 792756
*       This module is called when mseg-erfmg is changed on screen
*       0321 (mb31).
*----------------------------------------------------------------------*
MODULE erfme_input_fuss INPUT.
  PERFORM conversion_factors_clear_fuss.
ENDMODULE.                             " erfme_input_fuss  INPUT