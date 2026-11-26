*----------------------------------------------------------------------
*       FORM FELDAUSWAHL_STATUS                                       *
*----------------------------------------------------------------------
*       Feste Feldmodifikation gemäß Status                           *
*       FE das Ausblenden von Tablecontrol-Zeilen muß das            *
*       Feld ausgeblendet werden und in der Form                      *
*       TCTRL_SPALTENAUSWAHL der Feldname aufgenommen werden          *
*                                                                     *
*----------------------------------------------------------------------
FORM feldauswahl_status USING value(us_name)
                        CHANGING ch_display_status.

ENHANCEMENT-POINT MV45AFFE_FELDAUSWAHL_STATUS_12 SPOTS ES_SAPMV45A.


  FIELD-SYMBOLS: <feld>, <mname>.



  DATA: da_regel(5),
        da_regel_s(5),                 "neue Sonderregel
        da_name LIKE screen-name,
        da_mengev LIKE vbap-kbmeng,
        da_subrc,
        da_fixed(1) TYPE c,
        da_uepos LIKE vbap-uepos,
        da_uepos_cuobj LIKE vbap-cuobj,
        da_uepos_objnr LIKE vbap-objnr,
        da_vbak LIKE vbak,
        da_vbap LIKE vbap,
        da_tvak LIKE tvak,
        da_mname LIKE rv45a-mnam01,
        da_fieldname(50),
        da_lfdnr LIKE tstl-lfdnr,
        da_lfdpv(2)  TYPE n,
        da_progname  LIKE shdsvci-progname,
        da_dynpro    LIKE shdsvci-dynpro,
        da_scvariant LIKE shdsvci-scvariant,
        da_len(4) TYPE n VALUE '1',
        da_bukrs LIKE tvko-bukrs,
        da_businessobjekt LIKE nast-objtype,
        da_help_menge LIKE xvbapf-omenge.

  DATA: lv_xin_reorg TYPE flag.

  CLEAR: da_regel_s.

  da_name = us_name.
  IF da_name(1) = '*'.
    SHIFT da_name LEFT.
  ENDIF.
* Routinen fE nicht eingabebereite Felder
  CLEAR sy-subrc.

*---------------------------------------------------------------------
* Felder nur fE Kontrakte
  IF tvak-vbtyp NE vbtyp_kont.
    IF da_name EQ 'VBAK-VBELN_GRP'  OR
       da_name EQ 'VBAK-ABRUF_PART' OR
       da_name EQ 'RV46G_DOC-KTEXT' OR
       da_name EQ 'RV45A-TXT_ABRUF_PART'.
      screen-active = 0.
    ENDIF.
  ENDIF.

*-Transaktionstyp 'A' keine Eingabe
*----------------------------------------------------------------------
  CASE t180-trtyp.
    WHEN chara.
      IF screen-group3 NE 'SEL' AND
        sy-dyngr NE 'ANFO'.
* die Drucktasten zum Springen auf die Detaildaten (Gruppe DET)
* sollen auch beim Anzeigen aktiv sein.
        IF screen-group2 EQ 'DET'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
      ENDIF.
* Auswahl der Merkmalsanzeige ist immer möglich
      IF screen-name = 'RV45A-MUEBS'.
        screen-input = 1.
      ENDIF.
ENHANCEMENT-POINT FELDAUSWAHL_STATUS_01 SPOTS ES_SAPMV45A.
  ENDCASE.
* Einspielen der Screenvarianten wenn sich die Dynpronummer
* geändert hat
  IF active_screen NE sy-dynnr.
    IF tvak-variant IS INITIAL AND NOT tvak-vbtyp IS INITIAL.
      CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
        EXPORTING
          i_document_type   = tvak-vbtyp
          i_tvak            = tvak
        IMPORTING
          e_business_object = da_businessobjekt
        EXCEPTIONS
          OTHERS            = 0.
      MOVE da_businessobjekt TO da_scvariant.
    ELSE.
      MOVE tvak-variant TO da_scvariant.
    ENDIF.
* Nur wenn eine Variante vorhanden ist soll RS_HDSYS_SET_SC_VARIANT
* gerufen werden
    IF NOT da_scvariant IS INITIAL AND NOT da_scvariant EQ 'NO_VARIANT'.
      MOVE sy-repid TO da_progname.
      MOVE sy-dynnr TO da_dynpro.
      MOVE sy-dynnr TO active_screen.
      da_len = strlen( da_scvariant ).
      WRITE '_' TO da_scvariant+da_len.
      da_len = da_len + 1.
      WRITE da_dynpro TO da_scvariant+da_len.

      CALL FUNCTION 'RS_HDSYS_SET_SC_VARIANT'
        EXPORTING
          progname            = da_progname
          dynpro              = da_dynpro
          scvariant           = da_scvariant
          overwrite_scvariant = 'X'
          batch_input         = 'X'
          set_immediately     = 'X'.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------
* Produktselektion/NatRab: Unterpositionen nicht eingabebereit
*             Einteilungsdatum bei Unterpositionen nicht eingabebereit
* bei Reparaturabwicklung und Cross-Selling ist alles änderbar
*----------------------------------------------------------------------
  IF ( NOT vbap-uepvw IS INITIAL AND
       NOT vbap-uepvw EQ chard   AND
       NOT vbap-uepvw EQ charf   AND
       NOT vbap-uepvw EQ chari ) OR
       ( vbapd-mlgut EQ charx AND
         NOT vbap-uepos IS INITIAL ).
    IF da_name(4) EQ 'VBAP' OR
       da_name(4) EQ 'VBEP' OR
       da_name(4) EQ 'VBKD'.
      LOOP AT xvbuv WHERE tbnam EQ da_name(4) AND
                          fdnam EQ da_name+5.
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0 AND
        NOT ( vbap-uepvw CA  naturalrabatt AND
              ( da_name(10) EQ 'VBAP-ABGRU' OR
                da_name(10) EQ 'VBAP-WERKS' OR
                da_name(10) EQ 'VBAP-LGORT' OR
                da_name(10) EQ 'VBAP-CHARG' OR
                da_name(10) EQ 'VBAP-BRGEW' OR
                da_name(10) EQ 'VBAP-NTGEW' OR
                da_name(10) EQ 'VBAP-GEWEI' OR
                da_name(10) EQ 'VBAP-VOLUM' OR
                da_name(10) EQ 'VBAP-VOLEH' OR
                da_name(10) EQ 'VBEP-WMENG' ) ) AND
        NOT ( vbap-uepvw EQ produktselektion AND
              vbapd-srcps EQ srcps_subitem AND
              da_name(10) EQ 'VBAP-FAKSP' ).
        IF call_bapi = charx AND vbak-vbkla(2) = 'CR'.
          screen-input = 1.
        ELSE.
          screen-input = 0.
        ENDIF.
      ENDIF.
    ELSEIF da_name(11) EQ 'RV45A-ETDAT'  OR
           da_name(11) EQ 'RV45A-MABNR'  OR
           da_name(11) EQ 'RV45A-PRGBZ'.
      screen-input = 0.
    ELSEIF da_name(11) EQ 'KUWEV-ABLAD'.
      screen-input = 0.
* Menge bei Naturalrabatt-UPOS ist eingabebereit
    ELSEIF da_name(12) EQ 'RV45A-KWMENG'.
      IF vbap-uepvw CN naturalrabatt.
        screen-input = 0.
      ENDIF.
    ENDIF.
  ENDIF.

* no input for unloading point for sourcing item
  IF da_name(11) EQ 'KUWEV-ABLAD' AND
     NOT vbapd-srcps IS INITIAL.
    screen-input = 0.
  ENDIF.

* no input of component quantities for Sourcing and product selektion
  IF vbap-uepvw = chara AND
     da_name(11) EQ 'RV45A-KMPMG'.
    screen-input = 0.
  ENDIF.

* no change of FIXMG when completely delivered
  IF da_name = 'VBAP-FIXMG' AND
     NOT vbap-posnr IS INITIAL AND
     xvbup-lfgsa EQ charc.
    screen-input = 0.
  ENDIF.

*----------------------------------------------------------------------
* Anfrage-/Angebotspositionen nicht eingabebereit wenn voll referiert
  IF vbak-vbtyp CA vbtyp_agan AND
    xvbup-rfsta CA charc.
    IF NOT vbap-posnr IS INITIAL AND
       ( da_name(4) EQ 'VBAP' OR
         da_name(4) EQ 'VBEP' OR
         da_name(4) EQ 'VBKD' OR
         da_name(11) EQ 'RV45A-ETDAT'  OR
         da_name(12) EQ 'RV45A-KWMENG' OR
         da_name(11) EQ 'RV45A-PRGBZ'  OR
         da_name(11) EQ 'KUWEV-ABLAD' ) .
      LOOP AT xvbep WHERE posnr = vbap-posnr AND
                                  ( NOT aufnr IS INITIAL OR
                                        plnum IS INITIAL ) .
        EXIT.
      ENDLOOP.
      IF sy-subrc = 0.
        screen-input = 0.
      ENDIF.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------
* Rechnungskorrektur (Gut-oder Lastschriftsposition nicht eingabebereit)
* gilt nur fE Positionen mit Vorgängerbel
  IF vbak-vbklt = vbklt_rech_korr.
    IF ( vbak-vbtyp = vbtyp_ganf AND vbap-shkzg = charx AND
         NOT vbap-vgpos IS INITIAL                          ) OR
       ( vbak-vbtyp = vbtyp_lanf AND vbap-shkzg = charx AND
         NOT vbap-vgpos IS INITIAL                          ).
      IF da_name(4) EQ 'VBAP' AND NOT da_name EQ 'VBAP-ABGRU'.
        LOOP AT xvbuv WHERE tbnam EQ da_name(4) AND
                            fdnam EQ da_name+5  AND
                            posnr EQ vbap-posnr.
          EXIT.
        ENDLOOP.
        IF sy-subrc NE 0.
          screen-input = 0.
        ENDIF.
      ENDIF.
    ENDIF.

* if all items are already fixed, the target quantity may not be changed
* any more
    IF da_name(11) EQ 'VBAP-ZMENG' OR
       da_name(11) EQ 'VBAP-BRGEW' OR
       da_name(11) EQ 'VBAP-NTGEW' OR
       da_name(11) EQ 'VBAP-VOLUM' OR
       da_name(11) EQ 'VBAP-GEWEI' OR
       da_name(11) EQ 'VBAP-VOLEH'.
      da_fixed = charx.
      LOOP AT xkomv.
        IF xkomv-ksteu NE chare.
          CLEAR da_fixed.
          EXIT.
        ENDIF.
      ENDLOOP.

      IF NOT da_fixed IS INITIAL.
        screen-input = 0.
      ENDIF.
    ENDIF.

  ENDIF.

*----------------------------------------------------------------------
* Fakturierungsplan
  IF da_name EQ 'PUSH_BUTTON_FPLAN' AND
   NOT ( vbap-fkrel EQ con_fkrel_fplan OR
         ( vbap-fkrel IS INITIAL AND   "oder Angebote
           NOT tvap-fpart IS INITIAL ) ).
    screen-active = 0.
  ENDIF.
  IF da_name EQ 'VBKD-FKDAT' AND
   ( vbap-fkrel EQ con_fkrel_fplan OR
     ( vbap-fkrel IS INITIAL AND       "oder Angebote
       NOT tvap-fpart IS INITIAL ) ) AND
     vbkd-posnr NE 0.
    screen-input = 0.
  ENDIF.

ENHANCEMENT-POINT MV45AFFE_FELDAUSWAHL_STATUS_10 SPOTS ES_SAPMV45A.

*----------------------------------------------------------------------
* Bei Komplettlieferung bzw. Produktselektion/NatRab ist die
* Liefergruppe nicht eingabebereit
  IF ( da_name = 'VBAP-GRKOR' OR
       da_name = 'RV45A-GRETD' ) AND
    ( vbak-autlf NE space OR
      vbap-prosa CA 'AC'  OR
      vbap-uepvw CA naturalrabatt ).
    screen-input = 0.
    EXIT.
  ENDIF.

*---------------------------------------------------
* Referenzschema nicht eingabebereit wenn bereits referenziert
  IF tvak-vbtyp EQ vbtyp_gruko.
    IF da_name EQ 'VBAK-SCHEME_GRP'.
      DESCRIBE TABLE gruko LINES sy-tfill.
      IF NOT sy-tfill IS INITIAL.
        screen-input = 0.
      ENDIF.
    ENDIF.
  ENDIF.

*----------------------------------------------------------------------
* Profit Center der Faktura nur anzeigen bei Cross Company
  IF da_name EQ 'VBAP-PCTRF'.
    CALL FUNCTION 'SD_GET_KOKRS_BUKRS_FROM_WERKS'
      EXPORTING
        i_werks = vbap-werks
        i_gsber = vbap-gsber
      IMPORTING
        e_bukrs = da_bukrs
      EXCEPTIONS
        OTHERS  = 0.
    IF NOT da_bukrs IS INITIAL AND
       tvko-bukrs NE da_bukrs.
      screen-active = 1.
    ELSE.
      screen-active = 0.
    ENDIF.
  ENDIF.

*---------------------------------------------------
* Reparaturabwicklung:
* Gerätematerial und Gerätemenge nur wenn Serviceprodukt fE
  IF tvak-vbklt NA charg.
    IF da_name EQ 'VBAPD-MATNR_G' OR
       da_name EQ 'VBAPD-ARKTX_G' OR
       da_name EQ 'VBAPD-MENGE_G'.
      screen-active = 0.
    ENDIF.
    IF tvak-vbklt CA charf.
*     Gerätematerial fEre
      IF da_name EQ 'RV45A-KWMENG' OR
         da_name EQ 'VBAP-PSTYV'   OR
         da_name EQ 'VBAP-VRKME'.
        IF vbap-vkgru EQ vkgru_rep_reparaturanfo.
*         gibt es schon Unterpositionen ?
          READ TABLE uvbap WITH KEY uepos = vbap-posnr BINARY SEARCH.
          IF sy-subrc = 0.
            screen-input = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ELSE.
    IF da_name EQ 'VBAPD-MATNR_G' OR
       da_name EQ 'VBAPD-ARKTX_G' OR
       da_name EQ 'VBAPD-MENGE_G'.
      IF vbap-vkgru EQ vkgru_rep_reparaturanfo.
*       Reparaturanforderung: Änderung nur wenn Objektliste es erlaubt
        IF NOT vbapd-matnr_g IS INITIAL.
          PERFORM repair_matnr_g_input(sapfv45p) USING     vbap-vbeln
                                                           vbap-posnr
                                                  CHANGING sy-subrc.
          IF NOT sy-subrc IS INITIAL.
            screen-input = 0.
          ENDIF.
        ENDIF.
*       gibt es schon Unterpositionen ?
        READ TABLE uvbap WITH KEY uepos = vbap-posnr BINARY SEARCH.
        IF sy-subrc = 0.
          screen-input = 0.
        ENDIF.
      ELSEIF vbap-vkgru EQ vkgru_rep_reparatur.
*       Reparaturen nur zur Anzeige
        screen-input  = 0.
      ELSEIF NOT vbap-vkgru IS INITIAL.
*       Geräte-UPs haben diese Felder nur inaktiv
        screen-active = 0.
      ENDIF.
    ENDIF.
  ENDIF.

*---------------------------------------------------
* Aufwandsbezogene Fakturierung: Berechnungsmotiv nur anzeigen, wenn
* Position aus dyn. Posten entstanden ist oder das Feld gefElt ist
  IF da_name EQ 'VBKD-BEMOT'.
    IF ( vbap-vkgru NE vkgru_dyn_posten OR
         vbap-vkgru NE vkgru_dyn_posten_ag ) AND
       vbkd-bemot IS INITIAL.
      screen-active = 0.
    ENDIF.
  ENDIF.

*---------------------------------------------------
* Button 'Währung neuermitteln' nur möglich, wenn Währung än
  IF da_name(7) EQ 'BT_WNEU'.
    da_regel = 'WAERK'.
  ENDIF.

*---------------------------------------------------
* Alternative Auftragsarten ausblenden
  IF tvak-aauart1 IS INITIAL AND
     tvak-aauart2 IS INITIAL.
    IF da_name  EQ 'RV45A-TXT_RB_AUART' OR
       da_name  EQ 'RV45A-RB_AUART'     OR
       screen-group3 EQ 'AAT'           AND
     ( da_name  EQ 'VBAK-AUART'         OR
       da_name  EQ 'TVAKT-BEZEI' ).
      screen-active = 0.
    ENDIF.
  ENDIF.
  IF tvak-aauart1 IS INITIAL AND
     ( da_name EQ 'RV45A-RB_AAUART1' OR
       da_name EQ 'RV45A-TXT_RB_AAUART1' ).
    screen-active = 0.
  ENDIF.
  IF tvak-aauart2 IS INITIAL AND
     ( da_name EQ 'RV45A-RB_AAUART2' OR
       da_name EQ 'RV45A-TXT_RB_AAUART2' ).
    screen-active = 0.
  ENDIF.
* Radiobuttons fE alternative Auftragsarten nicht eingabebereit
  IF NOT tvak-aauart1 IS INITIAL OR
     NOT tvak-aauart2 IS INITIAL.
    IF da_name EQ 'RV45A-RB_AAUART1' OR
       da_name EQ 'RV45A-RB_AAUART2'.
* ... wenn der Auftrag aus einem anderen Beleg erzeugt wird
      IF NOT call_dialog    IS INITIAL OR
         NOT vbak-aufnr     IS INITIAL OR
         NOT vbak-qmnum     IS INITIAL OR
         NOT vbak-vbeln_grp IS INITIAL.
        screen-input = 0.
      ENDIF.
* ... wenn es bereits Folgebelege gibt oder der Beleg selbst ein FB ist
      LOOP AT xvbfa
        WHERE ( vbelv EQ vbak-vbeln OR vbeln EQ vbak-vbeln )
          AND ( plmin CA '+-' OR vbtyp_n CA vbtyp_bestell ).
        screen-input = 0.
        EXIT.
      ENDLOOP.
* .. bei VA02 die alternative Auftragsart einen anderen Nummernkreis hat
      IF t180-trtyp EQ charv.
        IF da_name EQ 'RV45A-RB_AAUART1'.
          SELECT SINGLE * INTO da_tvak FROM tvak
                          WHERE auart = tvak-aauart1.
          IF da_tvak-numki NE tvak-numki OR
             da_tvak-numke NE tvak-numke.
            screen-input = 0.
          ENDIF.
        ENDIF.
        IF da_name EQ 'RV45A-RB_AAUART2'.
          SELECT SINGLE * INTO da_tvak FROM tvak
                          WHERE auart = tvak-aauart2.
          IF da_tvak-numki NE tvak-numki OR
             da_tvak-numke NE tvak-numke.
            screen-input = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

*---------------------------------------------------
* Merkmalswerte nicht wenn mehrwertig oder wenn Merkmal generell
*  nicht eingabebereit
  IF da_name(11) = 'RV45A-MWERT'.
** mit Rel. 99 ist eine Änderung von Merkmalswerten noch nicht
** vorgesehen
    screen-input = '0'.
* PrEen ob die Konfiguration änderbar i
*** wenn Merkmalswerte geändert werden laufen weitere (hier zu teure)
*** PrEungen ab
**  if ( t459k-konfi na config_t459k and
**       tvap-strum  na config_tvap ) or
**       xvbup-lfsta ca 'BC'   or
**       xvbup-fksaa ca 'C'    or
**       not xvbap-abgru is initial or
**       ( ( vbak-vbtyp ca vbtyp_anfo or
**           vbak-vbtyp ca vbtyp_retour ) and
**           not vbap-vgbel is initial and
**           vbap-matnr eq vvbap-matnr ) or
**       ( vbak-vbtyp ca vbtyp_agan and
**         xvbup-rfsta ca 'C' ) .
**    screen-input = '0'.
**  else.
* PrEen ob das Merkmal eine Eingabe erlaubt
**    clear: da_fieldname.
**    concatenate 'RV45A-MNAM' da_name+11(1) into da_fieldname.
**    assign (da_fieldname) to <mname>.
**    da_mname = <mname>.
**    read table xmerkmal with key atnam = da_mname.
**    if sy-subrc <> 0             or
**       xmerkmal-atein is initial or
**       not xmerkmal-atinp is initial.
**      screen-input = '0'.
**    endif.
**  endif.
  ENDIF.

*---------------------------------------------------
*------------------*
* Statuspflege im Übersichtsbild
*   - Eingabebereitschaft der Ankreuzfelder ermitteln
*   - Spalten ausblenden, wenn nicht im Customizing gepflegt
  IF da_name CP 'RV45A-STAT++' OR      " Ankreuzfeld
     da_name CP 'STTXT-T++'.           " SpaltenEerschrift
    PERFORM feldauswahl_rv45a_status USING da_name
                                     CHANGING screen-invisible
                                              screen-input
                                              screen-active.
  ENDIF.

*---------------------------------------------------
*------------------*
* Wunschlieferdatum als Mussfeld
  IF da_name = 'RV45A-KETDAT' OR
     da_name = 'RV45A-KPRGBZ'.
    CASE businessobjekt.
      WHEN 'BUS2030' OR 'BUS2031' OR
           'BUS2032' OR 'BUS2103'.
        screen-required = 1.
      WHEN OTHERS.
        screen-required = 0.
    ENDCASE.
  ENDIF.

*---------------------------------------------------
*------------------*
* bei Lieferplänen VersandEersicht modifizieren - Einteilungsdat
* wegblenden
  IF vbak-vbtyp CA vbtyp_lp AND
         t185v-panel EQ 'UVER'.
    IF da_name(4) EQ 'VBEP' OR
       da_name(5) EQ '*VBEP'.
      screen-active = 0.
    ENDIF.
  ENDIF.



*======================================================================*
  CASE da_name(4).
    WHEN 'AD01'.
      da_regel = 'FFPRF'.
    WHEN 'KOMV'.
      da_regel = 'KOMV '.
    WHEN 'KUAG'.
      CASE da_name.
        WHEN 'KUAGV-KUNNR'.
          da_regel = 'KUNNR'.
      ENDCASE.
    WHEN 'KUWE'.
      CASE da_name.
        WHEN 'KUWEV-KUNNR'.
          da_regel = 'KUNWE'.
      ENDCASE.
    WHEN 'RV45'.
      CASE da_name.
        WHEN 'RV45A-ETDAT'.
          da_regel = 'VSM=B'.
        WHEN 'RV45A-MABNR'.
          da_regel = 'MATNR'.          " wie vbap-matnr
        WHEN 'RV45A-PRGBZ'.
          da_regel = 'VSM=B'.
        WHEN 'RV45A-KWMENG'.           " wie vbep-wmeng
          da_regel = 'ABSTC'.
        WHEN 'RV45A-TXT_ANGDT'.
          da_regel = 'ANGEB'.
        WHEN 'RV45A-TXT_BNDDT'.
          da_regel = 'ANGEB'.
        WHEN 'RV45A-KOEIN'.
          da_regel = 'KOMV'.
        WHEN 'RV45S-KUNNR'.
          PERFORM feldauswahl_rv45s-kunnr.
        WHEN 'RV45S-BSTNK'.
          PERFORM feldauswahl_rv45s-bstnk.
        WHEN 'RV45S-PSPID'.
          PERFORM feldauswahl_rv45s-pspid.
        WHEN 'RV45Z-LFNKD'.
          PERFORM feldauswahl_rv45z-lfnkd.
        WHEN 'RV45S-FAKKD'.
          PERFORM feldauswahl_rv45s-fakkd.
        WHEN 'RV45Z-ABHOR'.
          da_regel = 'FAB  '.
        WHEN OTHERS.
      ENDCASE.

    WHEN 'VBAK'.
      CASE da_name.
        WHEN 'VBAK-ABDIS'.
          da_regel = 'ABDIS'.
          da_regel_s = 'G3022'.
        WHEN 'VBAK-AUTLF'.
          da_regel = 'AUTLF'.
        WHEN 'VBAK-FAKSK'.
          da_regel = 'FAKSK'.
        WHEN 'VBAK-ANGDT'.
          da_regel = 'ANGEB'.
        WHEN 'VBAK-BNDDT'.
          da_regel = 'ANGEB'.
        WHEN 'VBAK-GUEBG'.
          da_regel = 'GUELT'.
        WHEN 'VBAK-GUEEN'.
          da_regel = 'GUELT'.
        WHEN 'VBAK-KOSTL'.
          da_regel = 'KOSTL'.
        WHEN 'VBAK-LIFSK'.
          da_regel = 'AKLFC'.
        WHEN 'VBAK-WAERK'.
          da_regel = 'WAERK'.
        WHEN 'VBAK-VBELN'.
          da_regel = 'VBELN'.
        WHEN 'VBAK-BUKRS_VF'.
          da_regel = 'BUKRS'.
        WHEN 'VBAK-ABHOD'.
          da_regel = 'ABFEN'.
        WHEN 'VBAK-ABHOV'.
          da_regel = 'ABFEN'.
        WHEN 'VBAK-ABHOB'.
          da_regel = 'ABFEN'.
        WHEN 'VBAK-PROLI'.
          da_regel = 'PROLI'.
        WHEN 'VBAK-CONT_DG'.
          da_regel = 'PROLI'.
      ENDCASE.
    WHEN 'VBAP'.
      CASE da_name.
*       when 'xxxx-xxxxx'.
*         da_regel_s = 'g3nnn'.
        WHEN 'VBAP-ABGRS'.
          da_regel_s = 'G3021'.
        WHEN 'VBAP-ABGRU'.
          da_regel = 'ABGRU'.
        WHEN 'VBAP-ABSFZ'.
          da_regel_s = 'G3022'.
        WHEN 'VBAP-ANTLF'.
          da_regel = 'AUTLF'.
        WHEN 'VBAP-AWAHR'.
          da_regel = 'ANGEB'.
        WHEN 'VBAP-BEDAE'.
          da_regel = 'BEDAE'.
        WHEN 'VBAP-BRGEW'.
          da_regel = 'G3009'.          "gewichtsrelevant
        WHEN 'VBAP-BWTAR'.
          da_regel = 'BWTAR'.
        WHEN 'VBAP-CHARG'.
          da_regel = 'CHARG'.
        WHEN 'VBAP-FAKSP'.
          da_regel = 'FAKSP'.
        WHEN 'VBAP-GEWEI'.
          da_regel = 'G3009'.          "gewichtsrelevant
        WHEN 'VBAP-GRPOS'.
          da_regel = 'VSTEL'.
        WHEN 'VBAP-KBVER'.
          da_regel_s = 'G3022'.
        WHEN 'VBAP-KDMAT'.
          da_regel = 'KDMAT'.
        WHEN 'VBAP-KEVER'.
          da_regel_s = 'G3022'.
        WHEN 'VBAP-KWMENG'.            " wie vbep-wmeng
          da_regel = 'ABSTC'.
        WHEN 'VBAP-KZTLF'.
          da_regel = 'AUTLF'.
        WHEN 'VBAP-LGORT'.
          da_regel = 'LGORT'.
        WHEN 'VBAP-LPRIO'.
          da_regel = 'LFSTC'.
        WHEN 'VBAP-LSTANR'.
          da_regel = 'VSTEL'.
        WHEN 'VBAP-MATNR'.
          da_regel = 'MATNR'.
        WHEN 'VBAP-MFRGR'.             "neu fE frachtklassen
          da_regel = 'VSM>0'.
        WHEN 'VBAP-NTGEW'.
          da_regel = 'G3009'.          "gewichtsrelevant
        WHEN 'VBAP-PLAVO'.
          da_regel_s = 'G3022'.
        WHEN 'VBAP-PS_PSP_PNR'.
          da_regel = 'PROJN'.
        WHEN 'VBAP-POSNR'.
          da_regel = 'POSNR'.
        WHEN 'VBAP-PSTYV'.
          da_regel = 'MATNR'.
        WHEN 'VBAP-ROUTE'.
          da_regel = 'VSTEL'.
        WHEN 'VBAP-SERNR'.
          IF vbak-abdis IS INITIAL.
            da_regel = 'SERNR'.
          ENDIF.
        WHEN 'VBAP-TAXM1'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM2'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM3'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM4'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM5'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM6'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM7'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM8'.
          da_regel = 'G3019'.
        WHEN 'VBAP-TAXM9'.
          da_regel = 'G3019'.
        WHEN 'VBAP-UEPOS'.
          da_regel = 'MATNR'.
        WHEN 'VBAP-UMVKN'.
          PERFORM feldauswahl_vbap-umvkz CHANGING sy-subrc.
          PERFORM feldauswahl_setzen USING sy-subrc.
        WHEN 'VBAP-UMVKZ'.
          PERFORM feldauswahl_vbap-umvkz CHANGING sy-subrc.
          PERFORM feldauswahl_setzen USING sy-subrc.
        WHEN 'VBAP-UMZIN'.
          PERFORM feldauswahl_vbap-umziz CHANGING sy-subrc.
          PERFORM feldauswahl_setzen USING sy-subrc.
        WHEN 'VBAP-UMZIZ'.
          PERFORM feldauswahl_vbap-umziz CHANGING sy-subrc.
          PERFORM feldauswahl_setzen USING sy-subrc.
        WHEN 'VBAP-VOLEH'.
          da_regel = 'G3009'.          "gewichtsrelevant
        WHEN 'VBAP-VOLUM'.
          da_regel = 'G3009'.          "gewichtsrelevant
        WHEN 'VBAP-VRKME'.
          PERFORM feldauswahl_vbap-vrkme CHANGING sy-subrc.
          PERFORM feldauswahl_setzen USING sy-subrc.
        WHEN 'VBAP-VSTEL'.
          da_regel = 'VSTEL'.
        WHEN 'VBAP-WERKS'.
          da_regel = 'WERKS'.
        WHEN 'VBAP-ZMENG'.
          PERFORM feldauswahl_vbap-zieme CHANGING sy-subrc.
          PERFORM feldauswahl_setzen USING sy-subrc.
        WHEN 'VBAP-ZIEME'.
          PERFORM feldauswahl_vbap-zieme CHANGING sy-subrc.
          PERFORM feldauswahl_setzen USING sy-subrc.
      ENDCASE.
    WHEN 'VBEP'.
      CASE da_name.
        WHEN 'VBEP-EDATU'.
          IF call_function = charx.
            da_regel = 'VSM=B'.
          ENDIF.
        WHEN 'VBEP-BDDAT'.
          da_regel = 'VSM>0'.
        WHEN 'VBEP-BDART'.
          da_regel = 'VSM>0'.
        WHEN 'VBEP-BMENG'.
          da_regel = 'ABSTC'.
          da_regel_s = 'G3013'.
        WHEN 'VBEP-CMENG'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-ETTYP'.
          da_regel = 'LFSTC'.
        WHEN 'VBEP-EZEIT'.
          da_regel = 'VSM=B'.
        WHEN 'VBEP-LDDAT'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-LDUHR'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-LIFSP'.
          da_regel = 'LFSTC'.
        WHEN 'VBEP-LMENG'.
          da_regel = 'ABSTC'.
          da_regel_s = 'G3013'.
        WHEN 'VBEP-MBDAT'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-MBUHR'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-PLART'.
          da_regel = 'VSM>0'.
        WHEN 'VBEP-TDDAT'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-TDUHR'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-UMVKN'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-UMVKZ'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-VERFP'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-WADAT'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-WAUHR'.
          da_regel = 'ABSTC'.
        WHEN 'VBEP-WMENG'.             " wie vbap-kwmeng
          da_regel = 'ABSTC'.
      ENDCASE.
    WHEN 'VBKD'.
      CASE da_name.
        WHEN 'VBKD-FAKTF'.
          da_regel = 'FAKTF'.
        WHEN 'VBKD-FBUDA'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-FFPRF'.
          da_regel = 'FFPRF'.
        WHEN 'VBKD-FKDAT'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-GJAHR'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-INCO1'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-INCO2'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-KURRF'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-KURSK'.
          da_regel = 'KDFKC'.
          da_regel_s = 'G3045'.
        WHEN 'VBKD-MRNKZ'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-POPER'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-PRSDT'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-VALDT'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-VALTG'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-ZLSCH'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-ZTERM'.
          da_regel = 'KDFKC'.
        WHEN 'VBKD-WAKTION'.
          da_regel = 'WAKTI'.
      ENDCASE.
    WHEN 'VBLB'.
      CASE da_name.
*       Abrufnummer kein Mußfeld bei Planabrufen
        WHEN 'VBLB-LABNK'.
          IF vblb-abart EQ abart_pab.
            screen-required = 0.
          ENDIF.
*       Abrufdatum  kein Mußfeld bei Planabrufen
        WHEN 'VBLB-ABRDT'.
          IF vblb-abart EQ abart_pab.
            screen-required = 0.
          ENDIF.
      ENDCASE.
    WHEN 'VBSN'.
      CASE da_name.
        WHEN 'VBSN-AESKD'.
          IF vbak-abdis IS INITIAL.
            da_regel = 'AEND'.
          ENDIF.
      ENDCASE.

    WHEN OTHERS.                                            "IS2ERP
ENHANCEMENT-POINT FELDAUSWAHL_STATUS_03 SPOTS ES_SAPMV45A STATIC.

ENHANCEMENT-POINT FELDAUSWAHL_STATUS_02 SPOTS ES_SAPMV45A.
  ENDCASE.
* nicht zuordenbar aus der Überarbeitung der Sonderregel
  CASE da_name.
    WHEN 'BLOCK_GEWICHT'.
      da_regel   = 'G3009'.
    WHEN 'TKKAD-TEXTA'.
      da_regel_s = 'G3021'.
  ENDCASE.


  CASE da_regel.
    WHEN space.
    WHEN 'ABDIS'.
      IF tvak-abdis IS INITIAL AND
         vbak-abdis IS INITIAL.
        screen-active = 0.
      ENDIF.
    WHEN 'ABGRU'.
      IF vbap-abgru IS INITIAL AND
         xvbup-gbsta EQ charc.
        screen-input = 0.
      ENDIF.
    WHEN 'ABSTC'.
      IF vbap-posnr > 0.
        IF xvbup-absta = charc.
          screen-input = 0.
        ENDIF.
*       Z.B. Fakturierter Barverkauf, Menge nicht mehr änderbar
        IF xvbup-fksaa = charc AND
           vbap-fkrel = charb.
          screen-input = 0.
        ENDIF.
*       Position aus dynamischen Posten(Service) --> Menge dichtmachen
        IF vbap-vkgru = vkgru_dyn_posten OR
           vbap-vkgru = vkgru_dyn_posten_ag.
          screen-input = 0.
        ENDIF.
*       UPOS aus Konfiguration
        PERFORM xvbap_loeschen_pruefen_upos(sapfv45p)
                                                USING    vbap-posnr
                                                         space
                                                CHANGING da_uepos
                                                         da_uepos_cuobj
                                                         da_uepos_objnr
                                                         da_subrc.
        IF da_subrc = charx AND
           ( call_bapi IS INITIAL OR
           vbak-vbkla(2) NE 'CR' ).
          screen-input = 0.
        ENDIF.
*       Wenn Vertrag und Position ohne Einteilung
        IF tvak-vbtyp NA vbtyp_kont AND
           tvap-eterl = ' '         AND
           vbap-kwmeng IS INITIAL   AND
           vbapd-pvpos EQ space.
          screen-active = 0.
        ENDIF.
*       Fakturierungsplan
        IF vbap-fkrel EQ con_fkrel_fplan AND
           xvbup-fksaa CA 'C'.
          screen-input = 0.
        ENDIF.
      ENDIF.
*     Bei Product Selection, Sourcing Menge & Co zu
      IF (  vbap-prosa   EQ charc
           OR
            ( vbap-prosa   EQ chara         OR
              vbapd-natrab CA naturalrabatt OR
              vbap-uepvw   CA naturalrabatt )
             AND
            ( xvbup-lfsta CN 'A ' OR
              xvbup-rfsta CN 'A ' )
          )
          AND NOT
          ( vbapd-srcps = 'A' AND xvbup-lfsta = 'B' ) .
        " AND NOT ( vbapd-srcps = 'A' AND xvbup-lfsta = 'B' )
        " is the same as:
        " AND    ( vbapd-srcps NE 'A' OR xvbup-lfsta NE 'B' )
        screen-input = 0.
      ENDIF.
    WHEN 'AEND'.
      IF xvbup-lfsta CA 'BC' OR
         xvbup-absta CA 'C'.
        screen-input = 0.
      ENDIF.
    WHEN 'AKFKC'.
      IF xvbuk-fkstk CA 'C' AND
         xvbuk-fksak CA 'C' OR
         xvbuk-fkstk CA ' ' AND
         xvbuk-fksak CA 'C' OR
         xvbuk-fkstk CA 'C' AND
         xvbuk-fksak CA ' '.
        screen-input = 0.
      ENDIF.
    WHEN 'AKLFC'.
      IF xvbuk-lfgsk = 'C' AND
         vbak-lifsk IS INITIAL AND
         NOT tvak-vbklt CA vbklt_reparatur.
        screen-input = 0.
      ENDIF.
    WHEN 'ANGEB'.
      IF vbak-vbtyp CN vbtyp_ange AND
         vbak-vbtyp CN vbtyp_anfr.
        screen-active = 0.
      ENDIF.
    WHEN 'AUTLF'.
* Überschrift immer anzeigen
      IF vbak-vbtyp CA vbtyp_lp AND us_name NE '*VBAP-ANTLF'.
        screen-active = 0.
      ENDIF.
    WHEN 'BEDAE'.
      IF xvbup-rfsta CA 'BC'  OR
         xvbup-lfsta CA 'BC'  OR
         xvbup-absta CA 'C'   OR
         xvbapf-vmenge > 0    OR
         vbap-anzsn  >  0     OR
         vbap-prosa  EQ charc OR
         vbap-vkgru  EQ vkgru_dyn_posten OR
         vbap-vkgru  EQ vkgru_dyn_posten_ag OR
         NOT vbap-stlnr IS INITIAL AND vbap-bedae IS INITIAL OR
         vbap-kzvbr NE space AND t180-trtyp EQ charv
                             AND vbapd-updkz NE updkz_new OR
         NOT vbap-kalnr IS INITIAL AND t180-trtyp EQ charv
                             AND vbapd-updkz NE updkz_new.
        screen-input = 0.
      ENDIF.
    WHEN 'BUKRS'.
*      if not xvbap_high_posnr is initial or           "v_n_718535
*         not vbak-kostl is initial.
      screen-input = 0.
*      endif.                                          "^_n_718535
    WHEN 'BWTAR'.
ENHANCEMENT-SECTION MV45AFFE_FELDAUSWAHL_STATUS_13 SPOTS ES_SAPMV45A .
      IF xvbup-lfgsa CA 'C' OR
         xvbup-rfgsa CA 'C' OR
         xvbup-fksta CA 'C' OR
         xvbup-fksaa CA 'C' OR
       ( vbap-prosa  EQ charc AND
         vbap-bwtex IS INITIAL ) OR
         NOT vbap-charg IS INITIAL.
        screen-input = 0.
      ENDIF.
      IF NOT vbap-vgbel IS INITIAL AND
         vbap-upflu NE space AND
         NOT vbap-bwtar IS INITIAL.
        screen-input = 0.
      ENDIF.
      IF vbap-bwtex = space.
        screen-active = 0.
      ENDIF.
END-ENHANCEMENT-SECTION.
    WHEN 'FAB  '.
      IF vblb-abart NE abart_fab.
        screen-input = 0.
      ENDIF.
    WHEN 'GUELT'.
      IF tvak-vterl NE space  OR       "Vertragsdaten nicht erlaubt
         ( vbak-vbtyp CN vbtyp_lp    AND    "Kein Lieferplan
           vbak-vbtyp CN vbtyp_sort  AND    "Kein Sortiment
           vbak-vbtyp CN vbtyp_kont  AND    "Kein Kontrakt
           vbak-vbtyp CN vbtyp_gruko AND    "Kein Gruppenkontrakt
           rv45a-amode NE charc ).     "Nicht beim Kopieren
        screen-active = 0.
      ENDIF.
* hier folgen, entsprechend der Sortierung die Regeln, die vormals in
* Sonderregel waren.

* gewichtsrelevant
    WHEN 'G3009'.
      IF tvap-gwrel = space OR
         NOT vbap-uepos IS INITIAL AND
         sy-stepl NE 0.
        screen-input = 0.
      ENDIF.
* Steuerindikatoren länderspezifisch auf Positionsebene ausblenden
    WHEN 'G3019'.
      da_lfdnr = da_name+9.
      PERFORM tstl_select USING vbapd-wklnd
                                da_lfdnr
                                space
                                sy-subrc.
      IF sy-subrc > 0 OR
         vbapd-wklnd = space.
        screen-active = 0.
      ENDIF.


    WHEN 'KDFKC'.
      IF vbkd-posnr > 0 OR
         svbkd-tabix = 0.
        da_mengev = 0.
        IF vbap-umvkz > 0.
          IF vbap-kzfme IS INITIAL.
            da_mengev = xvbapf-faklmeng * vbap-umvkn / vbap-umvkz.
          ELSE.
            da_mengev = xvbapf-faklmengv.
          ENDIF.
        ENDIF.
        IF xvbup-fksta CA 'C' OR
           xvbup-fksaa CA 'C' OR
           ( da_mengev GE vbap-lsmeng AND
             da_mengev GT 0 AND
             vbap-fkrel CA con_fkrel_liefer ).
          screen-input = 0.
        ENDIF.
      ELSE.
        IF xvbuk-fkstk CA 'C' AND
           xvbuk-fksak CA 'C' OR
           xvbuk-fkstk CA ' ' AND
           xvbuk-fksak CA 'C' OR
           xvbuk-fkstk CA 'C' AND
           xvbuk-fksak CA ' '.
          screen-input = 0.
        ENDIF.
      ENDIF.
    WHEN 'FAKSK'.
      IF ( xvbuk-fkstk CA 'C' AND
         xvbuk-fksak CA 'C' OR
         xvbuk-fkstk CA ' ' AND
         xvbuk-fksak CA 'C' OR
         xvbuk-fkstk CA 'C' AND
         xvbuk-fksak CA ' ' ) AND
         vbak-faksk IS INITIAL.
        screen-input = 0.
      ENDIF.
    WHEN 'FAKTF'.
* Fakturierform nur eingabebereit, wenn nötig
      IF ( vbap-vbelv NE vbap-vbeln OR
           vbap-posnv NE vbap-posnr ) AND
         vbap-ps_psp_pnr IS INITIAL   AND
         vbap-aufnr IS INITIAL        AND
         vbak-vbtyp NA vbtyp_agan.
        screen-input = 0.
      ENDIF.
      IF ( vbap-posnv IS INITIAL      AND
           vbap-ps_psp_pnr IS INITIAL AND
           vbap-aufnr IS INITIAL      AND
           vbak-vbtyp NA vbtyp_agan )    OR
         ( vbap-vkgru EQ vkgru_rep_reparaturanfo AND
           vbak-vbtyp CA vbtyp_agan ).
        screen-active = 0.
      ENDIF.
* Is it a sales order for CC billing (RRICB) ?
      if tvak-vbklt = charr.
        screen-active = 1.
        if t180-trtyp = charv or t180-trtyp = charh.
          screen-input = 1.
        endif.
      endif.
    when 'FFPRF'.
* Profil fE dynamische Einzelposten nur eingabebereit, wenn nöt
      IF ( vbap-vbelv NE vbap-vbeln OR
           vbap-posnv NE vbap-posnr ) AND
         vbap-ps_psp_pnr IS INITIAL   AND
         vbap-aufnr IS INITIAL        AND
         vbak-vbtyp NA vbtyp_agan.
        screen-input = 0.
      ENDIF.
      IF vbap-posnv IS INITIAL      AND
         vbap-ps_psp_pnr IS INITIAL AND
         vbap-aufnr IS INITIAL      AND
         vbak-vbtyp NA vbtyp_agan   AND
         vbkd-ffprf IS INITIAL.
        screen-active = 0.
      endif.
* Is it a sales order for CC billing (RRICB) ?
      if tvak-vbklt = charr.
        screen-active = 1.
        if t180-trtyp = charv or t180-trtyp = charh.
          screen-input = 1.
        endif.
      endif.
    when 'KOMV '.
      da_help_menge = xvbapf-omenge - xvbapf-smenge.
      IF ( xvbup-fksaa = charc OR
           xvbup-fksaa = charb OR
         ( vbap-fkrel CA con_fkrel_liefer AND
           vbak-vbtyp CA vbtyp_reto AND
           da_help_menge NE 0 ) OR
         ( vbap-fkrel CA con_fkrel_liefer AND
           xvbapf-faklmeng NE 0 ) ) AND
           vbap-fkrel NE con_fkrel_fplan.
        screen-input = 0.
      ENDIF.
    WHEN 'KOSTL'.
*   Kostenstelle nur für kostenlose Lieferungen oder wenn sie von
*   außen vorgegeben wurde
      IF vbak-kostl IS INITIAL AND
         vbak-vbtyp NA vbtyp_kl.
        screen-input = 0.
        screen-active = 0.
      ENDIF.
    WHEN 'KUNNR'.
      IF kuagv-kunnr IS INITIAL AND
         screen-name = 'KUAGV-KUNNR' AND
         screen-active = 1.
        SET CURSOR FIELD 'KUAGV-KUNNR'.
      ENDIF.
      CHECK screen-input = 1.
      IF NOT kuagv-kunnr IS INITIAL.
        screen-input = 1.
        DESCRIBE TABLE gruko LINES sy-tfill.
        IF NOT call_dialog IS INITIAL OR
           NOT vbak-aufnr IS INITIAL OR
           NOT vbak-qmnum IS INITIAL OR
           NOT vbak-vbeln_grp IS INITIAL OR
           NOT sy-tfill IS INITIAL OR
           t180-trtyp = chara.
          screen-input = 0.
        ENDIF.
        LOOP AT xvbfa
          WHERE ( vbelv EQ vbak-vbeln OR vbeln EQ vbak-vbeln )
            AND ( plmin CA '+-' OR vbtyp_n CA vbtyp_bestell ).
          screen-input = 0.
          EXIT.
        ENDLOOP.
      ENDIF.
      PERFORM tpaer_select USING tvak-pargr
                                 'AG'
                                 space
                                 sy-subrc.
      IF tpaer-papfl IS INITIAL.
        screen-input = 0.
      ENDIF.
*     field not changeable if successor was created via DP90
      IF NOT kuagv-kunnr IS INITIAL AND screen-input = 1.
        IF gsv_screen_input NE 2.
*         screen input has already been determined
          screen-input = gsv_screen_input.
        ELSE.
          LOOP AT xvbap.
            CHECK ( ( xvbap-vbelv EQ xvbap-vbeln AND
                      xvbap-posnv EQ xvbap-posnr AND
                      xvbap-kzvbr EQ kzvbr_e )
               OR NOT xvbap-ps_psp_pnr IS INITIAL ).
*           check document flow
            read table xvbfa with key vbelv = xvbap-vbeln
                                      posnv = xvbap-posnr
                                      binary search.
            if sy-subrc = 0.
              LOOP AT xvbfa
                WHERE vbelv EQ xvbap-vbeln
                  AND posnv EQ xvbap-posnr
                  AND stufe = '00'
                  AND vbtyp_n CA vbtyp_anfo.
*             document might have been created via DP90
*             read XVBKD to determine which transaction
                READ TABLE xvbkd WITH KEY posnr = xvbap-posnr
                     BINARY SEARCH.
                IF sy-subrc EQ 0 AND NOT xvbkd-ffprf IS INITIAL.
*               might be DP90
                  SELECT SINGLE * FROM vbap INTO da_vbap
                         WHERE vbeln = xvbfa-vbeln
                         AND   posnr = xvbfa-posnn.
                  IF da_vbap-vkgru EQ vkgru_dyn_posten.
                    screen-input = 0.
                    EXIT.
                  ENDIF.
                ELSE.
*               could be VA90
                  SELECT SINGLE * FROM vbak INTO da_vbak
                         WHERE vbeln EQ xvbfa-vbeln.
                  IF da_vbak-vbklt EQ vbklt_fakt_anf.
                    screen-input = 0.
                    EXIT.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            endif.
            IF screen-input NE 1.
              EXIT.
            ENDIF.
          ENDLOOP.
          gsv_screen_input = screen-input.
        ENDIF.
      ENDIF.
    WHEN 'KUNWE'.
      PERFORM tpaer_select USING tvak-pargr
                                 'WE'
                                 space
                                 sy-subrc.
      IF t180-trtyp <> chara AND sy-subrc <> 0.

        screen-input = 1.
      ENDIF.

      IF t180-trtyp <> 'H' AND NOT tpaer-aendb IS INITIAL.
        screen-input = 0.
      ENDIF.




* Wenn der AG auf dem Übersichtsbild zu ist muß der WE ebenso zu sein
      PERFORM tpaer_select USING tvak-pargr
                                 'AG'
                                 space
                                 sy-subrc.
      IF tpaer-papfl IS INITIAL.
        screen-input = 0.
      ENDIF.
    WHEN 'LFSTC'.
      IF xvbup-lfgsa CA 'C' OR
         xvbup-absta CA 'C' OR
         vbap-prosa  EQ charc.
        screen-input = 0.
      ENDIF.
      IF da_name = 'VBEP-ETTYP' AND
         vbak-vbkla+2(1) CA 'A' AND
         call_bapi IS INITIAL.
        screen-input = 0.
      ENDIF.
    WHEN 'LGORT'.
      IF vbap-posnr > 0.
        IF ( xvbup-rfsta CA 'C'   OR
             xvbup-absta CA 'C'   OR
             xvbup-lfsta CA 'BC'  OR
             xvbapf-vmenge > 0    OR
             vbap-uepvw EQ chara  OR
             vbap-prosa EQ charc  OR
             vbap-vkgru EQ vkgru_dyn_posten OR
             vbap-vkgru EQ vkgru_dyn_posten_ag ).
          screen-input = 0.
        ENDIF.
      ENDIF.
    WHEN 'MATNR'.
      PERFORM feldauswahl_vbap-matnr CHANGING sy-subrc.
      IF sy-subrc > 0.
        screen-input = 0.
      ENDIF.
* Kundenmaterialnummer
    WHEN 'KDMAT'.
      IF vbap-posnr > 0.
        IF xvbup-absta CA 'C'.
          screen-input = 0.
        ENDIF.
      ENDIF.
* Projektnummer
    WHEN 'PROJN'.
      screen-active = 0.
      IF vbap-kzvbr NE kzvbr_e.
        screen-active = 1.
        IF t180-trtyp  NE chara AND
           vbapd-pvpos IS INITIAL.
          screen-input  = char1.
        ENDIF.
      ENDIF.
* bei einer Rechnungskorrektur keine Eingabe gem. Bedingung
      IF vbak-vbklt = vbklt_rech_korr.
        IF ( vbak-vbtyp = vbtyp_ganf AND vbap-shkzg = charx ) OR
           ( vbak-vbtyp = vbtyp_lanf AND vbap-shkzg = charx ).
          screen-input  = char1.
        ENDIF.
      ENDIF.
* Bei dynamischen Posten darf Projekt nicht mehr geändert werden
      IF vbap-vkgru EQ vkgru_dyn_posten OR
         vbap-vkgru EQ vkgru_dyn_posten_ag.
        screen-input = 0.
      ENDIF.
* Bei erledigtem Angebot, Projekt dichtmachen
      IF vbak-vbtyp CA vbtyp_ange AND
         xvbup-gbsta EQ 'C'.
        screen-input = 0.
      ENDIF.
    WHEN 'POSNR'.
      IF NOT vbap-posnr IS INITIAL.
        screen-input = 0.
      ENDIF.
    WHEN 'PROLI'.
      CALL FUNCTION 'EHS002_CHECK_EHS_ACTIVE'
        EXCEPTIONS
          ehs_not_exist = 1
          OTHERS        = 2.
      IF sy-subrc <> 0.
        screen-active = 0.
      ENDIF.
    WHEN 'SERNR'.
      IF xvbup-lfsta CA 'BC' OR
         xvbup-absta CA 'C'.
        screen-input = 0.
      ENDIF.
    WHEN 'VBELN'.
      IF NOT sy-dyngr = 'ANFO'.
        IF NOT vbak-vbeln IS INITIAL OR
           tvak-numke = space.
          screen-input = 0.
        ENDIF.
        IF tvak-numki IS INITIAL AND
           vbak-vbeln IS INITIAL.
          screen-required = 1.
        ENDIF.
      ENDIF.
    WHEN 'VSM>0'.
      IF vbepd-vsmng > 0 OR
         vbap-prosa  EQ charc OR
         xvbup-lfgsa CA 'C'.
        screen-input = 0.
      ENDIF.
    WHEN 'VSM=B'.
      IF ( vbepd-vsmng >= vbep-bmeng AND
           vbepd-vsmng > 0           AND
           vbep-wmeng  = 0 )                 OR
           vbap-prosa  EQ charc OR
         ( vbap-prosa  EQ chara AND
           xvbup-lfsta CN 'A ' )  OR
         xvbup-lfgsa CA 'C' OR
         xvbup-absta CA 'C'.
        screen-input = 0.
        IF ( NOT call_bapi IS INITIAL AND      " change comes from MW
                 vbak-vbkla(2) EQ 'CR' ) AND   " CRM document
           da_name EQ 'VBEP-EZEIT' AND         " only field EZEIT
           ( xvbup-lfgsa CA 'C' OR             " delivered
             xvbup-absta CA 'C' ) .            " canceled
          screen-input = 1.                    " CHANGEABLE !!!!
        ENDIF.
      ENDIF.
      IF da_name EQ 'VBEP-EZEIT' AND
         t185v-panel EQ fcode_detail1_einteilung AND NOT
         vbak-abdis IS INITIAL.
* Einteilungsdetailbild Verkauf
* bei Lieferplänen fE Zulieferer sind die Sekunden in der Uhrze
* nicht erlaubt -> das Feld wird entsprechend dynamisch verkEzt
        screen-length = '05'.
      ENDIF.
    WHEN 'VSTEL'.
      IF xvbup-rfsta CA 'C' OR
         xvbup-absta CA 'C' OR
         xvbup-lfsta CA 'C' OR
         vbap-prosa  EQ charc.
        screen-input = 0.
      ENDIF.
    WHEN 'WAERK'.
      IF xvbuk-fkstk CA 'C' AND
         xvbuk-fksak CA 'C' OR

         xvbuk-fkstk CA ' ' AND
         xvbuk-fksak CA 'C' AND
         ( rv45a-banfn IS INITIAL OR xvbuk-gbstk EQ 'C' ) OR

         xvbuk-fkstk CA 'C' AND
         xvbuk-fksak CA ' ' OR

         xvbuk-rfgsk CA 'C'.

        screen-input = 0.
      ENDIF.
* Sonderbehandlung EURO bei teilfakturierten Aufträgen
      IF xvbuk-fksak = charb AND
         euro_active NE chary.
        screen-input = 0.
      ENDIF.
*     Währung im Wertkontrakt nach Abruf dichtmachen
      IF t180-trtyp EQ charv.
        IF wk_abruf_exist IS INITIAL.
          wk_abruf_exist = char0.
*         Kontrakt oder Rechnung als Folgebeleg ohne Auswirkung erlaubt
          LOOP AT xvbfa WHERE vbelv = vbak-vbeln AND
                              NOT posnv IS INITIAL AND
                              vbtyp_n NA 'GMN'.
            CLEAR da_subrc.
            READ TABLE xvbap WITH KEY posnr = xvbfa-posnv
                                      updkz = updkz_old
                                      erlre = con_erlre_wertkontrakt.
            IF sy-subrc > 0.
              READ TABLE xvbap WITH KEY posnr = xvbfa-posnv
                                        updkz = updkz_update
                                        erlre = con_erlre_wertkontrakt.
              da_subrc = sy-subrc.
            ENDIF.
*           Wenn ein Abrufbeleg gefunden wurde --> dichtmachen
            IF da_subrc = 0.
              wk_abruf_exist = char1.
              EXIT.
            ENDIF.
          ENDLOOP.
        ENDIF.
        IF wk_abruf_exist = char1.
          screen-input = 0.
        ENDIF.
      ENDIF.
* Button 'Währung neuermitteln' deaktivieren, wenn Währung deakt
      IF ( xvbuk-fksak CA 'BC' OR screen-input = 0 ) AND
           da_name(7) EQ 'BT_WNEU'.
        screen-input = 0.
        screen-active = 1.
      ENDIF.

    WHEN 'WAKTI'.
      PERFORM feldauswahl_vbkd-waktion CHANGING sy-subrc.
      PERFORM feldauswahl_setzen USING sy-subrc.
    WHEN 'WERKS'.
      PERFORM feldauswahl_vbap-werks CHANGING sy-subrc.
      PERFORM feldauswahl_setzen USING sy-subrc.
    WHEN 'WMENG'.
      IF vbap-posnr > 0.
        IF xvbup-absta CA 'C'.
          screen-input = 0.
        ENDIF.
* UPOS aus Konfiguration
        PERFORM xvbap_loeschen_pruefen_upos(sapfv45p) USING
vbap-posnr
                                                            space
                                                   CHANGING da_uepos
                                                        da_uepos_cuobj
                                                        da_uepos_objnr
                                                            da_subrc.
        IF da_subrc = charx AND
           ( call_bapi IS INITIAL OR
           vbak-vbkla(2) NE 'CR' ) .
          screen-input = 0.
        ENDIF.
        IF NOT vbep-banfn IS INITIAL.
          PERFORM eban_freigabestatus(sapfv45e) USING sy-subrc.
          IF sy-subrc > 0.
            screen-input = 0.
          ENDIF.
          IF NOT eban-ebeln IS INITIAL AND
             tvap-alekz IS INITIAL.
            screen-input = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    WHEN 'CHARG'.
      IF NOT vbap-posnr IS INITIAL.    "SpaltenEerschrift nicht
        IF xvbup-lfgsa CA 'C'   OR
           xvbup-rfgsa CA 'C'   OR
           xvbup-fksta CA 'C'   OR
           xvbup-fksaa CA 'C'   OR
           vbap-prosa  EQ charc OR
           vbap-anzsn > 0.
          screen-input = 0.
        ENDIF.
        IF vbap-xchpf  IS INITIAL AND
           vbapd-pvpos IS INITIAL.
          screen-active = 0.
        ENDIF.
      ENDIF.
* Abholfenster ist nicht mehr eingabebereit, wenn der
* Auslieferungsauftrag bereits beliefert wurde
    WHEN 'ABFEN'.
      IF xvbuk-lfgsk CA 'BC'.
        screen-input = 0.
      ENDIF.

    WHEN 'FAKSP'.
      IF ( xvbup-fksta EQ charc OR
           xvbup-fksaa EQ charc ) AND
          vbap-faksp IS INITIAL.
        screen-input = 0.
      ENDIF.

  ENDCASE.
****************************************************
********************
* Diese Regeln waren ehemals in der Sonderregel                        *
****************************************************
********************
  CASE da_regel_s.
* Die bestätigte Menge ist bei maschineller VerfEbarkeitsprEu
* (diese Regel gilt auch fE Felder der Gruppe 42,44)
    WHEN 'G3013'.
      IF vbep-verfp NE space OR xvbup-lfgsa EQ charc.
        screen-input = 0.
      ENDIF.
* Keine Änderung der Menge beim Sammelartikel
      IF vbapd-attyp EQ sam_typ.
        screen-input = 0.
      ENDIF.
* Feld ausblenden, wenn nicht Einzelfertigung mit Kostensammlung auf
* dem Kundenauftrag
    WHEN 'G3021'.
      IF vbap-kzvbr NE kzvbr_e   AND
          NOT vbap-posnr IS INITIAL.
        screen-active = 0.
      ENDIF.
* Feld ausblenden, wenn keine Lieferabrufe erlaubt sind
    WHEN 'G3022'.
      IF tvak-abdis IS INITIAL.
        screen-active = 0.
      ENDIF.
* Felder ausblenden, wenn Belegwährung = Hauswährung
* da dann Umrechnungsfaktor immer = 1,000000
    WHEN 'G3045'.
      IF call_bapi IS INITIAL.
        IF vbak-waerk = t001-waers.
          screen-input = 0.
        ENDIF.
      ENDIF.

  ENDCASE.
* Berechtigung fE Sperren/Entsperren
  IF da_name = 'VBAK-FAKSK' OR
     da_name = 'VBAP-FAKSP' OR
     da_name = 'VBAK-LIFSK' OR
     da_name = 'VBEP-LIFSP' OR
     da_name = 'RV45A-S_LIFSK' OR
     da_name = 'RV45A-S_LIFSK' OR
     da_name = 'RV45A-S_LIFSP' OR
     da_name = 'RV45A-S_FAKSK' OR
     da_name = 'RV45A-S_FAKSP'.
    ASSIGN (da_name) TO <feld>.
    IF berechtigung_block IS INITIAL AND
       <feld> IS INITIAL.
      screen-input = 0.
    ENDIF.
  ENDIF.

* Alle VBEP-Felder ausblenden, wenn Einteilungen nicht erlaubt
  IF tvap-eterl EQ space AND
     da_name(4) EQ 'VBEP'.
    screen-input = 0.
  ENDIF.

* VBKD Felder dichtmachen, wenn kaufm. Daten auf Position nicht erlaubt
  IF da_name(4) EQ 'VBKD' AND
     tvap-kderl IS INITIAL    AND
     vbap-posnr > 0 AND
     call_activity NE activity_gruko_pushdata.
    screen-input = 0.
  ENDIF.

* If VBKD-TRMTYP is filled, do not allow VBKD-TRATY to be changed
  IF NOT ( vbkd-trmtyp IS INITIAL ) AND
     da_name EQ 'VBKD-TRATY'.
    screen-input = 0.
  ENDIF.

* Felder Absicherungsschema, Finanzdokumentnummer und Abschreibungs-
*        prozentsatz nicht-eingabebereit, wenn Auftrag teilbeliefert
  IF vbap-posnr IS INITIAL.
* Kopfebene
    IF ( screen-group2 EQ 'LOC' ) AND  " Felder Risikomgmt
       ( ( vbuk-lfstk  CA 'BC' ) OR    " (teil-)beliefert
         ( vbuk-fksak  CA 'BC' ) ).    " (teil-)fakturiert auftr.
      screen-input = 0.
    ENDIF.
  ELSE.
* Positionsebene
    IF ( screen-group2  EQ 'LOC' ) AND " Felder Risikomgmt
       ( ( xvbup-lfgsa  CA 'BC'  ) OR  " (teil-)beliefert
         ( xvbup-fksta  CA 'BC'  ) OR  " (teil-)fakturiert liefer.
         ( xvbup-fksaa  CA 'BC'  ) ).  " (teil-)fakturiert auftr.
      screen-input = 0.
    ENDIF.
  ENDIF.

* Order is already delivered or invoiced
  IF da_name EQ 'VBAP-PRCTR'.
    if xvbup-lfsta ca 'BC' or xvbup-fksaa ca 'BC'.
      screen-input = 0.
    ENDIF.
    IF screen-input = 1.
      LOOP AT xvbfa WHERE
           posnv = vbap-posnr AND
           stufe = char00     AND
         ( vbtyp_n = charl OR       "Lastschriftsanforderung
           vbtyp_n = chark OR       "Gutschriftsanforderung
           vbtyp_n = charo OR       "Gutschrift
           vbtyp_n = charp ).       "Lastschrift
        IF vbak-vbeln = xvbfa-vbelv.
          screen-input = 0.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
    IF NOT vbak-vbeln IS INITIAL AND
       NOT vbap-posnr IS INITIAL AND
       NOT vbapd-updkz EQ chari.
      IF screen-input = 1.
        IF cl_fagl_switch_check=>fagl_fin_reorg_prctr_rs( ) EQ charx.
          CLEAR lv_xin_reorg.
          CALL FUNCTION 'FAGL_R_CHECK_OBJ_NOT_IN_REORG'
            EXPORTING
              iv_vbeln     = vbap-vbeln
              iv_posnr     = vbap-posnr
              iv_plan_type = '001'
            IMPORTING
              ev_xin_reorg = lv_xin_reorg.
          IF lv_xin_reorg EQ charx.
            screen-input = 0.
          ENDIF.
        ENDIF.
        IF cl_fagl_switch_check=>fagl_fin_reorg_seg( ) EQ charx.
          CLEAR lv_xin_reorg.
          CALL FUNCTION 'FAGL_R_CHECK_OBJ_NOT_IN_REORG'
            EXPORTING
              iv_vbeln     = vbap-vbeln
              iv_posnr     = vbap-posnr
              iv_plan_type = '003'
            IMPORTING
              ev_xin_reorg = lv_xin_reorg.
          IF lv_xin_reorg EQ charx.
            screen-input = 0.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

* replicated order from CRM: if external account assignment object is
* allocated, no changes in R/3 are allowed
  IF da_name EQ 'VBAP-PS_PSP_PNR' OR
     da_name EQ 'VBAP-AUFNR' OR
     da_name EQ 'VBAP-PRCTR'.
    PERFORM vbap_pruefen_iaom(sapfv45p) CHANGING sy-subrc.
    IF sy-subrc EQ 0.
      screen-input = 0.
    ENDIF.
  ENDIF.

  IF da_name EQ 'VBAP-AUFNR'.
    IF ( vbap-vkgru EQ vkgru_dyn_posten OR
         vbap-vkgru EQ vkgru_dyn_posten_ag ) AND
       NOT vbap-aufnr IS INITIAL.
      screen-input = 0.
    ENDIF.
  ENDIF.

* Revenue Recognition: currency/exchange rate changeability
  if ( screen-name = 'VBAK-WAERK' OR
       screen-name = 'VBKD-KURSK' OR
       screen-name = 'BT_WNEU' ) AND
       gvf_waerk_disp IS NOT INITIAL.
    screen-input = '0'.
  ENDIF.

* Pflege der Abrechnungsvorschrift nur zulassen, wenn die Position
* ein CO-Objekt besitzt
  IF da_name = 'BT_PAUF'.
    IF vbap-kzvbr NE kzvbr_e.
      screen-active = 0.
    ENDIF.
  ENDIF.

  IF da_name = 'HHM_VBAP-BTN_HHM' AND
    NOT vbak-bukrs_vf IS INITIAL.
    DATA:
    l_f_fmzuco     LIKE fmzuco.
    CALL FUNCTION 'FM_CO_ASS_INPUT_DEMAND_SD'
      EXPORTING
        i_bukrs        = vbak-bukrs_vf
      IMPORTING
        e_fmzuco       = l_f_fmzuco
      EXCEPTIONS
        no_entry_found = 1
        OTHERS         = 2.
    IF  sy-subrc <> 0
     OR l_f_fmzuco-xact_onl = ' '.
      screen-active   = '0'.
    ELSE.
      screen-active   = '1'.
      screen-input    = '1'.
    ENDIF.
  ENDIF.

  IF da_name = 'VBLB-LABNK' OR
     da_name = 'VBLB-ABRDT' OR
     da_name = 'VBLB-ABHOR' OR
     da_name = 'VBLB-LFNKD' OR
     da_name = 'VBLB-LFMAIS' OR
     da_name = 'VBLB-ABEFZ' OR
     da_name = 'RV45Z-ABHOR'.
    IF xvbup-absta CA 'C'.
      screen-input = 0.
    ENDIF.
  ENDIF.

*------------------*
* Produktvorschlag
  IF da_name(8) = 'VBAPD-PV' OR
     da_name(9) = 'RV45A-PVS'.
* Falls kein Produktvorschlag aktiv ist, entsprechende Felder ausbl.
    IF dpp_active IS INITIAL.
      screen-invisible = 1.
    ELSE.
* nur soviele Mengenspalten anzeigen, wie im Schema definiert
      screen-invisible = 0.
      MOVE da_name TO da_lfdpv.
      IF da_lfdpv GT tpvsm-pvanz.
        screen-invisible = 1.
      ENDIF.
    ENDIF.
  ENDIF.

* bei Positionen aus PV ist nur die Menge und der PSTYV eingabebereit
  IF NOT vbapd-pvpos IS INITIAL    AND
     da_name(12) NE 'RV45A-KWMENG' AND
     da_name(10) NE 'VBAP-ZMENG'   AND
     da_name(10) NE 'VBAP-PSTYV'   AND
     da_name(10) NE 'VBAP-VRKME'   AND
     sy-stepl NE 0.
    IF da_name(4)    EQ 'VBAP'        OR
       da_name(4)    EQ 'VBEP'        OR
       da_name(4)    EQ 'VBKD'        OR
       da_name(10)   EQ 'VBSN-AESKD'  OR
       da_name(11)   EQ 'RV45A-PRGBZ' OR
       da_name(11)   EQ 'RV45A-ETDAT' OR
       da_name(11)   EQ 'RV45A-KFREL' OR
       da_name(11)   EQ 'KUWEV-ABLAD' OR
       da_name(11)   EQ 'TVSTT-VTEXT' OR
       screen-group2 EQ 'LOO'.
      screen-input = 0.
    ENDIF.
    IF da_name(10) EQ 'VBAP-POSNR'.
      screen-invisible = 1.
    ENDIF.
    IF da_name(10) EQ 'VBAP-LPRIO' OR
       da_name(10) EQ 'VBAP-ANTLF'.
      screen-input = 1.
      screen-invisible = 1.
    ENDIF.
  ENDIF.

* field control for advanced returns management
  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) EQ charx.
    IF screen-name EQ 'RV45A-KWMENG' OR
       screen-name EQ 'VBAP-KWMENG' OR
       screen-name EQ 'VBAP-VRKME' OR
       screen-name EQ 'VBAP-ZMENG' OR
       screen-name EQ 'VBAP-ZIEME'.
      IF NOT gs_msr_sales_item-display_only IS INITIAL AND
         xvbup-lfgsa CA ' C'.
        screen-input = 0.
      ENDIF.
    ENDIF.
    IF call_activity NE gc_activity_lord AND
       tctrl_name EQ 'TCTRL_U_ERF_AUFTRAG' and
       not gr_msr_sales is initial.
      IF screen-name EQ 'RV45A-KWMENG' OR
         screen-name EQ 'VBAP-KWMENG' OR
         screen-name EQ 'VBAP-VRKME'.
        IF tvak-kopgr EQ 'GA'.
          screen-active = 0.
          screen-invisible = 1.
        ELSE.
          screen-active = 1.
          screen-invisible = 0.
        ENDIF.
      ENDIF.
      IF screen-name EQ 'VBAP-ZMENG' OR
         screen-name EQ 'VBAP-ZIEME'.
        IF tvak-kopgr EQ 'GA'.
          screen-active = 1.
          screen-invisible = 0.
        ELSE.
          screen-active = 0.
          screen-invisible = 1.
        ENDIF.
      ENDIF.
    ENDIF.
    IF da_name EQ 'VBEP-WMENG' OR
       da_name EQ 'VBEP-CMENG'.
      IF NOT gs_msr_sales_item-display_only IS INITIAL AND
         xvbup-lfgsa CA ' C'.
        screen-input = 0.
      ENDIF.
    ENDIF.
    IF da_name EQ 'RV45A-MABNR' OR
       da_name EQ 'VBAP-MATNR' OR
       da_name EQ 'VBAP-ARKTX'.
      IF NOT gs_msr_sales_item-display_only IS INITIAL OR
         ( NOT gs_msr_sales_item-posnr IS INITIAL AND
           tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_cmr ).
        screen-input = 0.
      ENDIF.
    ENDIF.
    IF da_name EQ 'VBAP-WERKS'.
      IF t180-trtyp = charv                                     AND
         ( vbak-vbtyp = vbtyp_reto OR vbak-vbtyp = vbtyp_ganf ) AND
         NOT vbak-msr_id IS INITIAL                             AND
         NOT gs_msr_sales_item-posnr IS INITIAL                 AND
         NOT screen-input = 0.
        SELECT COUNT( * ) FROM msr_d_executed
                         WHERE msr_id = vbak-msr_id
                           AND item   = gs_msr_sales_item-posnr
                           AND werks  = vbap-werks.
        IF sy-subrc EQ 0 AND
           sy-dbcnt GE 2.
          screen-input = 0.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.

  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
    perform feldauswahl_paysp1.
  endif.

*Subscreen EXPAND, COMPRESS button
* Enjoy SAP
*  IF DA_NAME = 'COMPRESS_ITEM'.
*    IF ITEM_DETAIL_COUNTER =  '0'.
*      SCREEN-INPUT = 0.
*    ENDIF.
*  ENDIF.

*  IF DA_NAME = 'EXPAND_ITEM'.
*    IF ITEM_DETAIL_COUNTER =  '6'.
*      SCREEN-INPUT = 0.
*    ENDIF.
*  ENDIF.

*  IF DA_NAME = 'COMPRESS_HEADER'.
*    IF HEADER_DETAIL_COUNTER =  '0'.
*      SCREEN-INPUT = 0.
*    ENDIF.
*  ENDIF.

*  IF DA_NAME = 'EXPAND_HEADER'.
*    IF HEADER_DETAIL_COUNTER =  '6'.
*      SCREEN-INPUT = 0.
*    ENDIF.
*  ENDIF.


  " End enjoy SAP
ENHANCEMENT-POINT MV45AFFE_FELDAUSWAHL_STATUS_11 SPOTS ES_SAPMV45A.

  IF screen-input = 0.
    MODIFY SCREEN.
    gs_screen = screen.
  ENDIF.

* Um fE den Gruppenkontrakt festzustellen, ob Felder eingabebereit
* sind, REkgabewert fEl
  IF screen-active = 0.
    ch_display_status = 2.
  ELSE.
    IF screen-input = 0.
      ch_display_status = 1.
    ENDIF.
  ENDIF.

ENDFORM.                    "feldauswahl_status