*---------------------------------------------------------------------*
*       FORM BELEG_LESEN                                              *
*---------------------------------------------------------------------*
*       Der Vertriebsbeleg wird gelesen und folgende interne          *
*       Tabellen werden gefüllt:                                      *
*                                VBAK                                 *
*                               XVBAP                                 *
*                               XVBPA                                 *
*       Zusätzlich werden noch die Nachrichten aus der Tabelle NAST   *
*       gelesen und in die internen Tabellen XNAST und YNAST gestellt *
*---------------------------------------------------------------------*
FORM beleg_lesen.

* Tabellen mit Fehlerhandling lesen
  DATA: da_actvt(2),
        bl_error.
  DATA: da_vbeln LIKE vbak-vbeln.
  DATA: only_extern TYPE xfeld.
  DATA: da_object TYPE borident,
        da_bapi   TYPE c.
  DATA: l_sd_sales_exit   TYPE REF TO if_ex_badi_sd_sales,
        active TYPE xfeld.
  DATA: sd_swu_active TYPE c.
  DATA: da_t160m LIKE t160m.
  DATA: da_ekko LIKE ekko.
  DATA: lv_no_input TYPE xfeld.
  FIELD-SYMBOLS: <fs_vbfa> LIKE vbfavb.

  LOCAL: r185d-dataloss.

* Damit beim Kopieren die offene Referenzmenge stimmt:
  PERFORM dummy(sapfv45c).
  PERFORM programm_laden(sapfv45p).

  bl_error = charx.

  IF vbak-vbeln IS INITIAL.
    MESSAGE e045.
  ENDIF.
* Beleg initialisieren, falls erforderlich
  IF vbak-vbtyp NE space OR
     call_activity EQ gc_activity_lord.
    da_vbeln = vbak-vbeln.
    PERFORM beleg_initialisieren.
    IF call_activity EQ gc_activity_lord.
      CALL FUNCTION 'PRICING_SET_LORD'.
    ENDIF.
    vbak-vbeln = da_vbeln.
  ENDIF.
* Damit auch Änderungen von gelöschten Aufträgen angezeigt werden können
  IF fcode = 'IAEN' AND
     t180-trtyp = chara.
    EXIT.
  ENDIF.

* Auftragskopf lesen
  PERFORM vbak_select USING vbak-vbeln
                      CHANGING data_read_from_archive.  "ARCHIVE

  IF t180-trtyp = chara    AND
     vbak-vbtyp CA 'CHIKL' AND
     data_read_from_archive IS INITIAL.                 "ARCHIVE
*   Import parameter from memory (SARI).
    DATA: read_archive TYPE c.
    IMPORT read_archive FROM MEMORY ID 'SD_VBAK_READ_ARCHIVE'.
    IF sy-subrc = 0 AND read_archive = 'X'.
      data_read_from_archive = 'X'.
      CLEAR read_archive.
*     Delete parameter from memory
      DELETE FROM MEMORY ID 'SD_VBAK_READ_ARCHIVE'.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT BELEG_LESEN_02 SPOTS ES_SAPMV45A.

  IF data_read_from_archive NE 'X'.                     "ARCHIVE

     *vbak = vbak.
    yvbak = vbak.
* XVBAK = VBAK.
    svbak-tabix = 1.
    xvbak_updkz = updkz_old.
* Beim Positionsvorschlag über Sortiment darf die Berechtigung nur mit
* ACTCT_03 (Anzeigen) geprüft werden
    IF positionsvorschlag EQ charx AND
       vbak-vbtyp         EQ  chard.
      da_actvt = actvt_03.
    ENDIF.
* Berechtigung prüfen, außer beim Kopieren
    IF tvcpa-auarv EQ space AND tvcpa-auarn EQ space.
      IF positionsvorschlag IS INITIAL.
        PERFORM berechtigung_pruefen USING    da_actvt
                                              vbak-auart
                                              space
                                     CHANGING sy-subrc.
      ENDIF.
    ENDIF.

* Steuerungstabellen zum Belegkopf lesen.
    PERFORM tvak_select USING vbak-auart
                                bl_error
                                sy-subrc.
    PERFORM tvakt_select USING vbak-auart
                                 bl_error
                                 sy-subrc.
* Paßt Transaktion zur Auftragsart ?
    PERFORM tvak-trvog_pruefen USING vbak-trvog
                                     t180-trvog.
    PERFORM vbak-vbeln_set_parameter(sapfv45k).

* CRM Szenario prüfen
    CALL FUNCTION 'CRM_GET_SCENARIO'
      EXPORTING
        is_vbak     = vbak
        iv_call_fct = call_function
        iv_changing = 'AX'
      CHANGING
        cv_vbkla    = vbak-vbkla.

* Liegt das Original des Belegs im CRM
    IF rv45a-amode NE charc.
      PERFORM check_crm_document USING vbak charx
                                 CHANGING da_bapi da_object.
    ENDIF.
* Steuerungstabellen zum Belegkopf lesen.
* Verkaufsorganisation lesen
    PERFORM tvko_select USING vbak-vkorg
                              bl_error
                              sy-subrc.
ENHANCEMENT-POINT BELEG_LESEN_10 SPOTS ES_SAPMV45A.
* Vertriebsweg lesen
    PERFORM tvtw_select USING vbak-vtweg
                                bl_error
                                sy-subrc.
* Sparte lesen
    PERFORM tspa_select USING vbak-spart
                                bl_error
                                sy-subrc.
* Verkaufsbüro lesen
    PERFORM tvbur_select USING vbak-vkbur
                                bl_error
                                sy-subrc.
* Verkäufergruppe lesen
    PERFORM tvkgr_select USING vbak-vkgrp
                                bl_error
                                sy-subrc.
* Vertriebsbereich lesen
    PERFORM tvta_select USING vbak-vkorg
                              vbak-vtweg
                              vbak-spart.

* kaufmännische Daten lesen / im Dialog nach Positionen
    PERFORM vbkd_select(sapfv45k) USING vbak-vbeln.

* alle Partner zum Beleg lesen  / im Dialog nach Positionen
    CALL FUNCTION 'SD_PARTNER_READ'
      EXPORTING
        f_vbeln  = vbak-vbeln
      TABLES
        i_xvbadr = xvbadr
        i_xvbpa  = xvbpa
        i_yvbadr = yvbadr
        i_yvbpa  = yvbpa
        i_xvbpa2 = xvbpa2
        i_yvbpa2 = yvbpa2.

* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
    CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
      EXPORTING
        i_document_type        = vbak-vbtyp
        i_tvak                 = tvak
      IMPORTING
        e_business_object      = businessobjekt
        e_business_object_item = businessobjekt_pos
      EXCEPTIONS
        OTHERS                 = 0.

    IF NOT call_function = 'X' AND
       fcode NE 'IFLU' AND
       NOT businessobjekt IS INITIAL.
      GET PARAMETER ID 'SD_SWU_ACTIVE' FIELD sd_swu_active.
      IF NOT sd_swu_active IS INITIAL.
        CALL FUNCTION 'SWU_OBJECT_PUBLISH'
          EXPORTING
            objtype           = businessobjekt
            objkey            = vbak-vbeln
          EXCEPTIONS
            objtype_not_found = 1
            OTHERS            = 2.
      ENDIF.
    ENDIF.

***** DSEG *****
    IF gwa_twpa IS INITIAL.
      SELECT SINGLE * FROM twpa
            CLIENT SPECIFIED
            INTO gwa_twpa
            WHERE  mandt       = sy-mandt.
    ENDIF.

    IF NOT gwa_twpa-addis IS INITIAL.
***** DSEG *****
* Ermitteln Verkaufshilfsmittel zu einem Beleg
      CALL FUNCTION 'WTAD_ADDIS_IN_SO_READ_FROM_DB'
        EXPORTING
          fi_vbak = vbak.
***** DSEG *****
    ENDIF.
***** DSEG *****

* Beleg sperren wenn noch Workitems zu einem Gruppenkontrakt existieren
    PERFORM gruko_sperren USING businessobjekt vbak-vbeln.

* alle Partner zum Beleg lesen
* Auftraggeber lesen
    PERFORM kuagv_select_xvbpa.
    PERFORM t683v_select(sapmv45a) USING tvak-kalvg
                                         kuagv-kalks
                                         space
                                         sy-subrc.
* Warenempfänger lesen
    PERFORM kuwe2_select_xvbpa.
* Regulierer lesen
    PERFORM kurgv_select_xvbpa.
    CHECK fcode NE 'IFLU'.
* Hinweis auf Sperren
    IF rv45a-amode NE charc.
      PERFORM partner_pruefen USING space
                                    sy-subrc.
    ENDIF.

    PERFORM konv_select(sapfv45p).
ENHANCEMENT-POINT BELEG_LESEN_11 SPOTS ES_SAPMV45A.
* Beim Ändern wird das Cross-Selling Profil eingelesen
    IF t180-trtyp = charv.
      PERFORM cross_sell_ermitteln(sapmv45a).
    ENDIF.

* Default-Umfang setzen
    PERFORM uebersicht_ansteuern(sapfv45p).

* Positionen lesen und Default-Umfang in IVBAP einstellen
    PERFORM vbap_select(sapfv45p) USING vbak-vbeln.
    PERFORM material_vorstep_aenderung(sapfv45p).
    PERFORM xvbap_fuellen_maapv(sapfv45p).
* Lieferabrufe einlesen
    IF NOT vbak-abdis IS INITIAL.
      CALL FUNCTION 'SD_VBLB_SELECT'
        EXPORTING
          i_document_number = vbak-vbeln
          i_item_number     = posnr_low
          i_type            = char1.
    ENDIF.

* TVAK an SAPLV45W übergeben (z.B. für Feldauswahl)
    CALL FUNCTION 'SD_VEDA_SET_DATA'
      EXPORTING
        i_tvak = tvak.
* Vertragsdaten einlesen, wenn Auftragsart Vertragsdaten zuläßt.
ENHANCEMENT-SECTION     BELEG_LESEN_12 SPOTS ES_SAPMV45A.
    IF NOT tvak-vterl IS INITIAL.
      MOVE vbak-vbeln TO vedavb-vbeln.
      CLEAR vedavb-vposn.
      CALL FUNCTION 'SD_VEDA_SELECT'
        EXPORTING
          i_document_number = vedavb-vbeln
          i_item_number     = vedavb-vposn
          i_trtyp           = t180-trtyp.
    ENDIF.
END-ENHANCEMENT-SECTION.

    ivbap_tabix_zeile_1 = 1.

* Belegstatus zum Auftrag lesen
    PERFORM vbuk_select(sapfv45k) USING vbak-vbeln.
    IF vbuk-manek = charc.
      t180-trtyp = chara.
    ENDIF.

* Wenn der Beleg aus Kreditsicht gesperrt ist, erscheint Warnung oder
* Fehler
    IF t180-trtyp           NE chara             AND
       xvbuk-cmgst          CA 'B'               AND
*    NOT CALL_ACTIVITY    EQ ACTIVITY_ATP_AREA AND
*    NOT CALL_ACTIVITY    EQ ACTIVITY_PURCHASE AND
       NOT call_activity(2) EQ activity_credit.
      PERFORM  message_variabel(sapfv45l)
        USING  'V4'
               '134'
               rv45z-msgvs
               charx
               xvbuk-vbeln
               space
               space
               space.
    ENDIF.

* Belegstatus zum Auftrag lesen
* Bei wiederholter Kopierselektion wird die Tabelle übergeben
    vbukkey-mandt = vbak-mandt.
    vbukkey-vbeln = vbak-vbeln.
    READ TABLE xvbup WITH KEY vbukkey BINARY SEARCH.
    IF sy-subrc > 0.
      PERFORM vbup_select(sapfv45p) USING vbak-vbeln.
    ENDIF.

* Sonderbehandlung EURO bei teilfakturierten Aufträgen
* start Revenue Recognition Project
    IF vbuk-fksak = charb OR
       vbuk-rrsta CA 'BC'.
* end Revenue Recognition Project
      PERFORM tcurv_select CHANGING euro_active.
      IF euro_active EQ chary.
*     Fakturierungsplan prüfen, nur wenn eurorelevant
        PERFORM fplan_pruefen_euro CHANGING euro_active.
      ENDIF.
    ENDIF.

* Belegfluß zum Auftrag lesen
* Bei wiederholter Kopierselektion wird die Tabelle übergeben

    vbukkey-mandt = vbak-mandt.
    vbukkey-vbeln = vbak-vbeln.
    READ TABLE xvbfa WITH KEY vbukkey BINARY SEARCH.
    IF sy-subrc > 0.
      READ TABLE yvbfa WITH KEY vbukkey.
      IF sy-subrc > 0.
        PERFORM vbfa_select USING vbak-mandt
                                  vbak-vbeln.
      ENDIF.
    ENDIF.
    LOOP AT xvbfa WHERE vbelv = vbak-vbeln AND
                        NOT posnv IS INITIAL AND
                        vbtyp_n NE vbtyp_versand.
      IF xvbfa-vbtyp_v CA vbtyp_extern AND
        vbak-vbkla+2(1) NE 'S'.
        DELETE xvbfa.
        only_extern = charx.
      ELSE.
        CLEAR only_extern.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF tvcpa-auarn = space            AND
       sy-subrc    = 0                AND
       only_extern IS INITIAL         AND
       call_function IS INITIAL       AND
       fcode      NE fcode_ausgeben   AND
       fcode      NE fcode_drucken.
      IF vbak-vbtyp   CA vbtyp_lp        OR
         tvak-vbklt   CA vbklt_reparatur OR
         t180-trtyp   =  chara.
        MESSAGE s081.
      ELSE.
ENHANCEMENT-SECTION     BELEG_LESEN_25 SPOTS ES_SAPMV45A.
        MESSAGE i081.
END-ENHANCEMENT-SECTION.
      ENDIF.
    ENDIF.

    IF NOT vbak-abdis IS INITIAL.
      PERFORM get_last_abefz(saplv45l).
      PERFORM get_cqnogi(saplv45l) TABLES xvbfa.
      PERFORM get_corrdel_caraz(saplv45l) TABLES xvbfa.
    ENDIF.

* Bestellungen archiviert ?
    SELECT SINGLE * INTO da_t160m FROM t160m WHERE msgvs = space
                                               AND arbgb = 'V4'
                                               AND msgnr = '256'.
    IF sy-subrc = 0 AND da_t160m-msgtp = 'E'.
      IF vbuk-gbstk = 'C' AND t180-trtyp NE chara.
        LOOP AT xvbfa ASSIGNING <fs_vbfa> WHERE vbtyp_n = 'V'.
          SELECT SINGLE * INTO da_ekko FROM ekko WHERE ebeln = <fs_vbfa>-vbeln.
          IF sy-subrc NE 0.
            MESSAGE e256(v4).
          ENDIF.
        ENDLOOP.
      ENDIF.
    ENDIF.

* kumulierten Belegfluß aufbauen
ENHANCEMENT-SECTION     BELEG_LESEN_13 SPOTS ES_SAPMV45A.
    CALL FUNCTION 'RV_XVBAPF_CREATE'
      EXPORTING
        vbeln   = vbak-vbeln
      TABLES
        fxvbfa  = xvbfa
        fxvbapf = xvbapf.
END-ENHANCEMENT-SECTION.

* Variantenkeys einlesen
    IF t180-trtyp <> chara.
      PERFORM xvckey_lesen(sapfv45p).
    ENDIF.
* Werte aus Konfiguration einlesen
    IF t180-trtyp <> chara.
      PERFORM xvcsdpos_lesen_db(sapfv45s).
    ENDIF.
* Product Selection
    PERFORM product_selection_set(sapfv45p).

* Sourcing
    PERFORM sourcing_set(sapfv45p).

* Naturalrabatt
    PERFORM naturalrabatt_set(sapfv45p).

* Einteilungen lesen
    PERFORM vbep_select(sapfv45e) USING vbak-vbeln.

* Revenue Recognition: determine if currency change is prohibited

   if t180-trtyp ne chara.
     CALL FUNCTION 'SD_CHECK_CURRENCY_CHANGE'
       EXPORTING
         FIS_VBAK             = vbak
       IMPORTING
         FIF_WAERK_DISP       = gvf_waerk_disp
       TABLES
         FIT_XVBUK            = xvbuk
         FIT_XVBUP            = xvbup
         FIT_XVBKD            = xvbkd
         FIT_XVBAP            = xvbap.
   endif.

* Zusagedaten merken
    PERFORM vbep_zusage_leseninit(sapfv45e) USING vbak-vbeln.

* Vorgängerbelege, Bedarfe, braucht Fluß
    PERFORM xvbep_initialisieren_alle(sapfv45e).

* Kontigentierungstabellen lesen (immer erst QTVB dann QTCH)
    PERFORM qtvb_select(sapfv45v)
      USING vbak-vbeln ' '.              " Initialisierung
    PERFORM qtch_select(sapfv45v).

* Änderungsstände lesen
    IF modification_flag-no_change_status IS INITIAL.
      PERFORM vbsn_select(sapfv45l) USING vbak-vbeln.
    ENDIF.

* Bei Call-Transaktion auf gewünschter Position aufsetzen
    PERFORM xvbap_aufsetzen_call(sapfv45p).

* Fehlerprotokoll lesen
    PERFORM vbuv_select(sapfv45f) USING vbak-vbeln.

ENHANCEMENT-POINT BELEG_LESEN_14 SPOTS ES_SAPMV45A.
    IF modification_flag-no_output_control IS INITIAL.
* Fuellen Key fuer Nachrichtenstatus
      MOVE vbak-vbeln TO xobjky.
      MOVE vbak-vbeln TO xobjky_to.
      MOVE '999999'   TO xobjky_to+10.
* Nachrichten lesen
      CALL FUNCTION 'RV_MESSAGES_READ'
        EXPORTING
          msg_kappl    = tvak-kappl
          msg_objky    = xobjky
          msg_objky_to = xobjky_to.
* Nachrichtenkommunikationsblock alt aufbauen
      READ TABLE xvbkd INDEX 1.
      na_vbkd = xvbkd.
      CALL FUNCTION 'COMMUNICATION_AREA_KOMKBV1'
        EXPORTING
          msg_vbak  = vbak
          msg_vbkd  = na_vbkd
          msg_vbuk  = vbuk
          msg_old   = charx
          msg_trtyp = t180-trtyp
        TABLES
          tab_part  = part
          tab_vbpa  = xvbpa
          tab_vbap  = xvbap.
    ENDIF.

* Kopffluß zum Vorgänger lesen
    IF NOT rv45a-amode = charc.
      PERFORM vbfa_select_vbeln USING vbak-mandt
                                      vbak-vgbel
                                      charx.
    ENDIF.
* Kopffluß zum Gruppenkontrakt lesen
    IF vbak-vgbel NE vbak-vbeln_grp.  " Nicht wenn schon Vorgänger
      PERFORM vbfa_select_vbeln USING vbak-mandt
                                      vbak-vbeln_grp
                                      space.
    ENDIF.

*-------Fuellen der internen Tabelle XVBEX
    IF modification_flag-no_export_control IS INITIAL.
      IF NOT ( vbak-vbeln IS INITIAL ).
        PERFORM vbex_lesen
                TABLES xvbex
                       yvbex
                USING  vbak-vbeln.
      ENDIF.
    ENDIF.

* Originaldaten für Gruppenkontrakt einlesen und globale Daten setzen
    PERFORM gruko_vorbereiten.

* Soweit es einen Kopffakturierungsplan gibt, muß der Fakturastatus
* der einzelnen Kopffakturierungsplantermine dynamisch ermittelt, da
* dieser nicht auf der Datenbank abgelegt ist, nicht im Anzeigen
    IF t180-trtyp NE chara.
      PERFORM fplan_kopf_status_erm.
    ENDIF.

ENHANCEMENT-POINT BELEG_LESEN_15 SPOTS ES_SAPMV45A.
* Reparaturabwicklung
    PERFORM repairitems_set(sapfv45p).

* Gefahrgutprüfung
    CALL FUNCTION 'SD_VBEPDG_READ'
      EXPORTING
        i_vbak = vbak
      IMPORTING
        e_vggp = rv45a_uv-vggp
      TABLES
        xvbuv  = xvbuv.

* Gefahrgut: Template-Materialabwicklung
    CALL FUNCTION 'EHS003_DGMSD_ORDER_READ'
      EXPORTING
        i_vbak_tab = vbak
        i_trtyp    = t180-trtyp
      IMPORTING
        e_vggp     = rv45a_uv-vggp
      TABLES
        xvbuv      = xvbuv
      EXCEPTIONS
        others_    = 1.

* Shared lock for WBS-elements
    PERFORM projekte_sperren.

* Read CPE Formula Document
    CALL FUNCTION 'CPE_ERP_FORMULA_READ'
      EXPORTING
        iv_knumv          = vbak-knumv
      EXCEPTIONS
        cpe_not_active    = 0
        formula_not_found = 0.

* Replace actual CPE Formula with uploaded CPE Formula, if exists
    CALL FUNCTION 'CPE_ERP_FORMULA_REPLACE'
      EXPORTING
        iv_knumv          = vbak-knumv
        iv_knumv_buffer   = '          '
      EXCEPTIONS
        cpe_not_active    = 0
        formula_not_found = 0.

*   Advanced Returns
    PERFORM msr_init.

*  TM ERP Integration II - UI Extension
    PERFORM tm_init.

* Payment Service Provider Data
    IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
      IF vbak-sppaym EQ cv_sppaym01.
        IF NOT gr_paysp IS BOUND.
          gr_paysp = cl_sls_paysp_integration=>get_instance( ).
        ENDIF.
        CALL METHOD gr_paysp->get_data
          EXPORTING
            iv_document_id = vbak-vbeln.
        IF t180-trtyp EQ charv.
          CALL METHOD gr_paysp->get_fieldcheck_general_sls
            EXPORTING
              is_vbak     = vbak
              is_tvak     = tvak
              iv_trtyp    = t180-trtyp
            IMPORTING
              ev_no_input = lv_no_input.
          IF lv_no_input IS NOT INITIAL.
            MESSAGE i016(sls_paysp) WITH vbak-vbeln.
            message_collect_lord.
          ELSE.
            MESSAGE i028(sls_paysp) WITH vbak-vbeln.
            message_collect_lord.
          ENDIF.
        ELSEIF t180-trtyp EQ chara.
          MESSAGE s016(sls_paysp).
          message_collect_lord.
        ENDIF.
      ENDIF.
    ENDIF.

    perform lord_doc_read.

    perform beleg_lesen_logic.

ENHANCEMENT-POINT BELEG_LESEN_03 SPOTS ES_SAPMV45A.

ENHANCEMENT-POINT BELEG_LESEN_01 SPOTS ES_SAPMV45A.
* Call SD Sales BAdI
    CALL FUNCTION 'GET_HANDLE_SD_SALES'
      IMPORTING
        handle = l_sd_sales_exit
        active = active.
    IF active = charx.
      CALL METHOD l_sd_sales_exit->read_document
        EXPORTING
          ft180  = t180
        CHANGING
          fvbak  = vbak
          fxvbap = xvbap[]
          fxvbkd = xvbkd[]
          fxvbpa = xvbpa[]
          fxvbep = xvbep[]
          fxvbuk = xvbuk[]
          fxvbuv = xvbuv[].
    ENDIF.

* Userexit
    PERFORM userexit_read_document.

* Buffer read tables in function group INTTAB_ANALYZE
    INCLUDE MV45AF0B_PUT_XTAB.                        " INTTAB_ANALYZE

* Gelesene Tabellen bereits in Funktionsgruppe V45I puffern
    CALL FUNCTION 'SD_PUSH_ITEM'
      TABLES
        i_xvbap = xvbap
        i_xvbup = xvbup
        i_xvbep = xvbep
        i_xvbkd = xvbkd.

  ELSE.
    PERFORM document_read_archive     "ARCHIVE
            TABLES xkomv              "ARCHIVE
            CHANGING data_read_from_archive. "ARCHIVE
  ENDIF.                               "ARCHIVE

ENDFORM.                    "BELEG_LESEN