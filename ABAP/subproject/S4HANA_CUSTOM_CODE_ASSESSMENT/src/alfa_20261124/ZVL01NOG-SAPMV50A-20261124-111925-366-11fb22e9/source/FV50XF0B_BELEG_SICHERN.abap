***INCLUDE FV50XF0B_BELEG_SICHERN .
*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN                                            *
*---------------------------------------------------------------------*
*       Posting delivery documents
*---------------------------------------------------------------------*
FORM beleg_sichern USING iv_final_check_durchfuehren TYPE c.

  DATA:
     lf_subrc TYPE sysubrc.

enhancement-point beleg_sichern_10 spots es_fv50xf0b_beleg_sichern include bound.


* 4.6C New shell for the sake of switches for partial functionality
  PERFORM beleg_sichern_01 USING iv_final_check_durchfuehren
                                    charx
                                    charx
                                    charx
                           CHANGING lf_subrc.

ENDFORM.                    "beleg_sichern



*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN_01                                         *
*---------------------------------------------------------------------*
* to make functionality switchable: now use parameters without
* disturbing old performs
*---------------------------------------------------------------------*
FORM beleg_sichern_01 USING    if_final_check     TYPE c
                               if_determine_check TYPE c
                               if_renumber        TYPE c
                               if_post            TYPE c
                      CHANGING cf_subrc           LIKE sy-subrc.
  DATA:
    lf_flag_docnum_new
   ,lf_only_final   TYPE c
   ,lf_only_prepare TYPE c.
* SPE INB RG 03.12.2004 Write back tables into the ID handling
  DATA: lo_asn TYPE REF TO /spe/cl_id_handling.             "n_1237014

  FIELD-SYMBOLS:                                            "n_v_126102
    <at_lips>      LIKE LINE OF xlips,
    <xlips>        LIKE LINE OF xlips,
    <at_vbadr>     LIKE LINE OF xvbadr,
    <xvbadr>       LIKE LINE OF xvbadr,
    <at_vbapf>     LIKE LINE OF xvbapf,
    <xvbapf>       LIKE LINE OF xvbapf,
    <at_vbfa>      LIKE LINE OF xvbfa,
    <xvbfa>        LIKE LINE OF xvbfa,
    <at_vbpa>      LIKE LINE OF xvbpa,
    <xvbpa>        LIKE LINE OF xvbpa,
    <at_vbup>      LIKE LINE OF xvbup,
    <xvbup>        LIKE LINE OF xvbup,
    <at_vbuv>      LIKE LINE OF xvbuv,
    <xvbuv>        LIKE LINE OF xvbuv.                      "n_^_126102

  _break_vl10.

* for rush orders we need to do delivery_final_check in
* RV_DELIVERY_CREATE_SINGLE while we must no do requirements handling
* there (beleg_sichern_vorbereiten is done in RV...SINGLE_POST)
  CLEAR lf_only_final.
  CLEAR lf_only_prepare.
  IF NOT v50agl-sofauftrag IS INITIAL.
    IF NOT if_final_check IS INITIAL AND
           if_post        IS INITIAL.
      lf_only_final = charx.
    ELSE.
      lf_only_prepare = charx.
    ENDIF.
  ENDIF.


* last determinations and checks, message_handling allowed
  IF NOT if_determine_check IS INITIAL OR
     NOT lf_only_prepare    IS INITIAL.

    PERFORM beleg_sichern_det_check USING    if_final_check
                                             lf_only_final
                                             lf_only_prepare
                                    CHANGING lf_flag_docnum_new
                                             cf_subrc.
    CHECK cf_subrc = 0.
  ENDIF.

* no more changes in the delivery are to be done in there !!!
* Only saving
  IF NOT if_renumber IS INITIAL.

    PERFORM beleg_sichern_renumber USING    lf_flag_docnum_new
                                   CHANGING cf_subrc.
    CHECK cf_subrc = 0.

  ENDIF.


* Post database updates
  IF NOT if_post IS INITIAL.

    PERFORM beleg_sichern_post.

  ELSE.

    IF ( /spe/cl_ctrl=>is_ewm( i_lgnum = xlikp-lgnum ) = gc_true OR           "v_n_1237014
      /spe/cl_ctrl=>is_active_vl60_dispatch( i_lgnum = xlikp-lgnum ) = gc_true )
       AND xlikp-vbtyp CA vbtyp_liav
       OR xlikp-spe_le_scenario EQ gc_le_scenario-tpop.
*   Write back was already done during the dispatching
    ELSEIF xlikp-spe_le_scenario EQ chare.
*   SPE INB ST/RG Write back tables into the ID handling
      lo_asn ?= /spe/cl_inb_action_info=>get_object(
         i_name = /spe/cl_inb_action_info=>c_obj_delivery ).
      IF NOT lo_asn IS INITIAL.
*     Fill the delivery tables from the CORE
        READ TABLE xlikp INTO lo_asn->as_likp INDEX 1.
        READ TABLE xvbuk INTO lo_asn->as_vbuk INDEX 1.

        LOOP AT xlips ASSIGNING <xlips>                             "n_v_1261024
          WHERE updkz = updkz_new OR
                updkz = updkz_update.
          READ TABLE lo_asn->at_lips ASSIGNING <at_lips>
            WITH KEY   vbeln = <xlips>-vbeln
                       posnr = <xlips>-posnr.
          IF sy-subrc = 0.
            MOVE <xlips> TO <at_lips>.
          ELSE.
            APPEND <xlips> TO lo_asn->at_lips.
          ENDIF.
        ENDLOOP.

        LOOP AT xvbapf ASSIGNING <xvbapf>.
          READ TABLE lo_asn->at_vbapf ASSIGNING <at_vbapf>
            WITH KEY   vbeln = <xvbapf>-vbeln
                       posnr = <xvbapf>-posnr.
          IF sy-subrc = 0.
            MOVE <xvbapf> TO <at_vbapf>.
          ELSE.
            APPEND <xvbapf> TO lo_asn->at_vbapf.
          ENDIF.
        ENDLOOP.

        LOOP AT xvbfa ASSIGNING <xvbfa>
          WHERE updkz = updkz_new OR
                updkz = updkz_update.
          READ TABLE lo_asn->at_vbfa ASSIGNING <at_vbfa>
            WITH KEY   vbelv = <xvbfa>-vbelv
                       posnv = <xvbfa>-posnv
                       vbeln = <xvbfa>-vbeln
                       posnn = <xvbfa>-posnn
                       vbtyp_n = <xvbfa>-vbtyp_n.
          IF sy-subrc = 0.
            MOVE <xvbfa> TO <at_vbfa>.
          ELSE.
            APPEND <xvbfa> TO lo_asn->at_vbfa.
          ENDIF.
        ENDLOOP.

        LOOP AT xvbup ASSIGNING <xvbup>
          WHERE updkz = updkz_new OR
                updkz = updkz_update.
          READ TABLE lo_asn->at_vbup ASSIGNING <at_vbup>
            WITH KEY   vbeln = <xvbup>-vbeln
                       posnr = <xvbup>-posnr.
          IF sy-subrc = 0.
            MOVE <xvbup> TO <at_vbup>.
          ELSE.
            APPEND <xvbup> TO lo_asn->at_vbup.
          ENDIF.
        ENDLOOP.

        SORT lo_asn->at_lips BY vbeln posnr.
        SORT lo_asn->at_vbapf BY vbeln posnr.
        SORT lo_asn->at_vbfa BY vbelv posnv vbeln posnn vbtyp_n.
        SORT lo_asn->at_vbup BY vbeln posnr.

        lo_asn->at_vbadr[]  = xvbadr[].
        lo_asn->at_vbpa[]   = xvbpa[].
        lo_asn->at_vbuv[]   = xvbuv[].                             "n_^_1261024
      ENDIF.
    ENDIF.                                                                    "^_n_1237014

  ENDIF.

ENDFORM.                    "beleg_sichern_01





*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN_DET_CHECK                                 *
*---------------------------------------------------------------------*
FORM beleg_sichern_det_check
     USING    iv_final_check_durchfuehren TYPE c
              if_only_final               TYPE c
              if_only_prepare             TYPE c
     CHANGING cf_flag_docnum_new          TYPE c
              cf_subrc                    TYPE sysubrc.

  DATA:
    local_rcode                TYPE sysubrc,
    lf_subrc                   TYPE sysubrc.

  CLEAR cf_subrc.

* get SD-monitor control flags
  IF t180-aktyp = aktyp-create.
    IF xsdctrlflag IS INITIAL.
      CALL FUNCTION 'SD_MONITOR_CONTROL_FLAGS_GET'
        IMPORTING
          fsdctrlflag = xsdctrlflag
        EXCEPTIONS
          OTHERS      = 1.
    ENDIF.
  ENDIF.

* Sort of delivery tables
  IF v50agl-sammelgang NE space OR
     v50agl-mult       NE space.
    PERFORM lieferungstabellen_sortieren.
  ENDIF.

  IF if_only_prepare IS INITIAL.

* Fill XLIKP

    PERFORM xlikp_aus_likp_fuellen.

* Lean Kit-to-order                                                   "v_n_1634714
    IF cl_ops_switch_check=>le_sfws_sc3( ) = gc_true.
      PERFORM lips_tab_fuellen_kit_to_order(sapfv50p) TABLES xlikp[]
                                                             xlips[].
    ENDIF.                                                            "^_n_1634714

* Aktualisieren Kopfstati aller beteiligten Vorgänge
    PERFORM xvbuk_pflegen(sapfv50k).

    IF v50agl-sammelgang NE space.
      PERFORM xvbuk_vbtyp_pflegen IN PROGRAM (kopfprogramm).
    ENDIF.

* KEINE LEERE VERBUCHUNG IM SAMMELGANG
    IF v50agl-sammelgang NE space AND
       xlikp[] IS INITIAL.
*     @Begin note 1087178 - BAdI LE_SHP_SAVE_WO_DELIVERY    "v_n_1087178
      DATA: li_save_wo_delivery TYPE REF TO le_shp_save_wo_delivery.
      GET BADI li_save_wo_delivery.
      IF li_save_wo_delivery IS BOUND.
        CALL BADI li_save_wo_delivery->save_wo_delivery
          EXPORTING
            is_v50agl = v50agl
            if_trtyp  = t180-trtyp
            if_tcode  = t180-tcode
          CHANGING
            ct_vbfs   = cvbfs[].
      ENDIF.
*     @End   note 1087178 - BAdI LE_SHP_SAVE_WO_DELIVERY    "^_n_1087178
      PERFORM text_memory_init.
      IF v50agl-sofauftrag EQ space.
        PERFORM sammelgangsprotokoll_schreiben.
        IF v50agl-no_commit = space.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
      cf_subrc = 1.
      EXIT.
    ENDIF.

* Löschen Status wenn Löschen Lieferung
enhancement-section     beleg_sichern_det_check_12 spots es_fv50xf0b_beleg_sichern include bound .
    IF xlikp_updkz = updkz_delete.
      CALL FUNCTION 'RV_XVBUK_DELETE'
        EXPORTING
          f_vbeln = likp-vbeln
        TABLES
          fxvbuk  = xvbuk
          fyvbuk  = yvbuk.
    ENDIF.
end-enhancement-section.

* Serialnummern automatisch vorschlagen lassen (nicht WMS, Transport)
    IF aufrufer NE chart                AND
       v50agl-create_decentral EQ space AND
       v50agl-split            EQ space.
      PERFORM serialnumber_automatically.
    ENDIF.

* Abschliessende Prüfungen durchführen
    BREAK-POINT ID /spe/inb_hold.
    IF iv_final_check_durchfuehren = charx AND
       xvbuk-hdall IS INITIAL.
      PERFORM delivery_final_check USING local_rcode
                                         space
                                         space.             "n_979614
    ENDIF.

* Terminate delivery saving procedure if delivery can not be saved
    IF NOT local_rcode IS INITIAL
       AND (        v50agl-sammelgang      IS INITIAL
             OR NOT v50agl-extend_delivery IS INITIAL ) .
      IF gs_mhpar-glomd NA gc_glomd-backgr_all.             "n_962351
        fcode = fcode_gleiche_seite.
        PERFORM fcode_bearbeiten(sapmv50a).
      ENDIF.
      cf_subrc = 1.
      EXIT.
    ENDIF.

* Stop the processing if no delivery can be saved
    IF v50agl-sammelgang NE space AND
       xlikp[] IS INITIAL.
      PERFORM text_memory_init.
      IF v50agl-sofauftrag EQ space.
        PERFORM sammelgangsprotokoll_schreiben.
        IF v50agl-no_commit = space.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
      cf_subrc = 1.
      EXIT.
    ENDIF.

  ENDIF. "if_only_prepare

  IF if_only_final IS INITIAL.

* In case of collective processing the text determination
* must be processed after the complete delivery check
    IF v50agl-sammelgang EQ charx AND
       v50agl-sofauftrag EQ space AND
     ( t180-trtyp EQ charh OR
       v50agl-extend_delivery EQ charx AND
       t180-trtyp EQ charv ).
      PERFORM text_determination_complete
              USING iv_final_check_durchfuehren.
      IF xlikp[] IS INITIAL.
        PERFORM text_memory_init.
        PERFORM sammelgangsprotokoll_schreiben.
        IF v50agl-no_commit = space.
          COMMIT WORK AND WAIT.
        ENDIF.
        cf_subrc = 1.
        EXIT.
      ENDIF.
    ENDIF.

* Neuterminierung der zu sichernden Lieferungen
* performance: not during picking confirmation
    IF v50agl-no_rescheduling IS INITIAL.
*   SPE OUTB new scheduling only if no georoute/scheduling active
*   no rescheduling for unchecked in CRM-R/3 scenario only
      IF      v50agl-mass_atpcheck IS INITIAL
        AND ( v50agl-create_uclief IS INITIAL
              OR likp-spe_le_scenario NA 'CR'). " order or complaint in CRM
        PERFORM beleg_neuterminieren.
      ENDIF.
    ENDIF.

* XSI-Data (Trackingnumber, Routeinfo, Shipper-Account,..)
    IF NOT tvshp-xsiactive IS INITIAL.
      PERFORM xsi_get_carrier_data.
    ENDIF.

ENHANCEMENT-POINT EHP_BELEG_SICHERN_DET_CHECK_01 SPOTS ES_FV50XF0B_BELEG_SICHERN INCLUDE BOUND .

* EhP6 Advanced Returns Management: Set Scenario Flag for EWM Integration
*    IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) = gc_true.
*      CALL METHOD cl_msr_ewm_int=>set_scenario
*        CHANGING
*          ct_xlikp = xlikp[].
*    ENDIF.
*  relocated in BADI call IF_EX_LE_SHP_DELIVERY_PROC~SAVE_DOCUMENT_PREPARE

* Check consistency of x- and y-tables                        "n_1636529
    PERFORM check_x_y_tables USING 'BELEG_SICHERN - before UserExits'.

* Call BAdI for final determinations
    PERFORM call_badi_save_doc_prep.

* Userexit
    PERFORM userexit_save_doc_before_prep(sapmv50a) IF FOUND.

* Die zu buchenden Tabellen werden vorbereitet
    PERFORM beleg_sichern_vorbereiten.

* Split: no processing of order requirements
    IF v50agl-split NE space.
      DELETE xvbbe WHERE vbtyp NA vbtyp_lief.
      DELETE yvbbe WHERE vbtyp NA vbtyp_lief.
      DELETE xvbbs WHERE vbtyp NA vbtyp_lief.
      DELETE yvbbs WHERE vbtyp NA vbtyp_lief.
    ENDIF.

enhancement-point beleg_sichern_det_check_11 spots es_fv50xf0b_beleg_sichern include bound.

* Userexit
    PERFORM userexit_save_document_prepare(sapmv50a).

* Check consistency of x- and y-tables                        "n_1636529
    PERFORM check_x_y_tables USING 'BELEG_SICHERN - after UserExits'.

* Stop the processing if no delivery can be saved
    IF v50agl-sammelgang NE space AND
       xlikp[] IS INITIAL.
      PERFORM text_memory_init.
      IF v50agl-sofauftrag EQ space.
        PERFORM sammelgangsprotokoll_schreiben.
        IF v50agl-no_commit = space.
          COMMIT WORK AND WAIT.
        ENDIF.
      ENDIF.
      cf_subrc = 1.
      EXIT.
    ENDIF.

* Check whether document number can be taken from central system
* Flag = space: number is taken from ERP, other character: new number
    IF v50agl-create_decentral NE space.                    "40C WMS
      PERFORM gn_check_docnum_flag(saplv50s)
                               CHANGING cf_flag_docnum_new.
*   Check whether document number exists already
      IF cf_flag_docnum_new EQ space.
        PERFORM gn_check_document_number(saplv50s) CHANGING lf_subrc.
        IF lf_subrc NE 0.
          cf_subrc = 1.
          EXIT.
        ENDIF.
      ENDIF.
    ENDIF.

  ENDIF. "if_final_only

*.Fill XLIPS-ORMNG with XLIPS_LFIMG in case of UPDKZ = 'I'   "v_XAN-SPE
  PERFORM beleg_sichern_ormng_dat.                           "^_XAN-SPE




*... Order Integration ERP TM II -------------------------------DEV EhP6
  IF cl_ops_switch_check=>aci_sfws_sc_erptms_ii( ) EQ abap_true.
    FIELD-SYMBOLS: <fs_xlikp> TYPE likpvb.
*... check all delivery headers
    LOOP AT xlikp ASSIGNING <fs_xlikp>.
*... check for TM distributions relevanz
      IF <fs_xlikp>-tm_ctrl_key IS NOT INITIAL.
*... delivery head was inserted, updated or deleted
        IF <fs_xlikp>-updkz CA 'IUD'.
          ADD 1 TO <fs_xlikp>-dlv_version.
        ELSE.
*... delivery header has no update flag then check for items that are inserted, updated or deleted
          LOOP AT xlips TRANSPORTING NO FIELDS WHERE vbeln = <fs_xlikp>-vbeln AND updkz CA 'UID'.
            EXIT.
          ENDLOOP.
*... Stop the loop with the first hit for and item that was inserted, updated or deleted
          IF sy-subrc = 0.
*... Add increment for delivery version
            ADD 1 TO <fs_xlikp>-dlv_version.
            <fs_xlikp>-updkz = 'U'.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "beleg_sichern_det_check



*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN_RENUMBER_DO                                *
*---------------------------------------------------------------------*
FORM beleg_sichern_renumber USING    if_flag_docnum_new TYPE c
                            CHANGING cf_subrc           TYPE sysubrc.
*
* No messages are allowed to be sent to Dialog-Screen from now on !
* No more checks, no more determinations, no more message_handling
* only saving !
*
* For checks and determinations see: FORM beleg_sichern_det_check
*
  DATA:
    kopf_tabix                 TYPE sytabix
  , temp_vbeln                 TYPE vbeln
  , lf_subrc                   TYPE sysubrc
  , lt_docnum_publish          TYPE shp_docnum_publish_t
  , ls_docnum_publish          TYPE shp_docnum_publish
  , lf_od_before_numbering  TYPE c VALUE space
  , lf_no_po_update            TYPE xfeld                   "n_1589704
.

  FIELD-SYMBOLS: <lfs_lips> TYPE lipsvb,                    "n_1589704
                 <xlikp>    TYPE likpvb.                    "n_1651466

enhancement-point fv50xf0b_beleg_sichern_02 spots es_fv50xf0b_beleg_sichern static include bound.

  CLEAR cf_subrc.

  PERFORM delivery_system_check.

*---------------------------------------------------------------------*
* Je erzeugter Lieferung wird                                         *
*   1. eine Nummer vergeben falls erforderlich                        *
*   2. Tabelle VBSK fortgeschrieben                                   *
*   3. Tabelle VBSS fortgeschrieben                                   *
*   4. die Liefernummer in die abhängigen Tabellen eingesetzt         *
*   5. die Texte umbenannt                                            *
*    . das Kommissionierdatum im Lieferkopf angepaßt                  *
*    . der Routenfahrplan bestimmt                                    *
*   6. die Anforderung für eine Kommiliste erzeugt                    *
*   7. die Lagernummer im Lieferkopf gesetzt                          *
*    . Tor und Bereitstellungszone im Lieferkopf gesetzt              *
*   8. die V2-Nachrichten ermittelt                                   *
*   9. die Nachrichten umbenannt                                      *
*  10. die Lieferungen gesperrt beim Hinzufuegen                      *
*  11. Für das Lieferavis bzw. für Lieferung zur Bestellung:          *
*      Kommunikation zur Bestellung aufnehmen                         *
*  12. Die Objektliste zu den Serialnummern umbenannt                 *
*---------------------------------------------------------------------*

* Determine if output determination must be done before or
* after determination of delivery document number
  PERFORM userexit_early_output_determ IN PROGRAM sapmv50a IF FOUND
                                       CHANGING lf_od_before_numbering.

  IF lf_od_before_numbering NE space.
    LOOP AT xlikp.
*     V2 (delivery) output messages determination
      PERFORM beleg_nachrichten_v2 USING xlikp-vbeln.
*     V6 (Handle Unit) Output messages determination
      PERFORM nachrichten_vse_buchen.
    ENDLOOP.
  ENDIF.

* Main loop
  LOOP AT xlikp.

    kopf_tabix    = sy-tabix.
    temp_vbeln = xlikp-vbeln.

*   Nummernvergabe für Preiskonditionen
    IF aufrufer NE chart.              ">>>> NICHT, falls Transport
      PERFORM nummernvergabe_konditionen USING kopf_tabix.
    ENDIF.

*   Nummervergabe XBLNR (Referenznummer des Geschäftspartners)
*   performance: not during picking-confirmation without posting
*   goods issue
    IF aufrufer NE chart.              ">>>> NICHT, falls Transport
      IF     NOT v50agl-no_glob_numb IS INITIAL
        AND  NOT v50agl-warenausgang IS INITIAL.
      ELSE.
        PERFORM nummernvergabe_xblnr USING kopf_tabix.
      ENDIF.
    ENDIF.

*   Nummernvergabe Lieferung
    PERFORM nummernvergabe_lieferung USING kopf_tabix
                                         if_flag_docnum_new. "40C WMS

*   Save old and new delivery number for publishing
    IF temp_vbeln NE xlikp-vbeln.
      ls_docnum_publish-vbeln_old = temp_vbeln.
      ls_docnum_publish-vbeln_new = xlikp-vbeln.
      APPEND ls_docnum_publish TO lt_docnum_publish.
    ENDIF.

*   Tabelle VBSK fortgeschrieben
*   SPE OUTB fill vbsk only if the delivery is not marked for deletion
*   or if it is not an unchecked, which is not deleted
    IF v50agl-sammelgang = charx AND xlikp-updkz NE updkz_delete
                                 AND xlikp-updkz NE updkz_mark_del
                                 AND xlikp-updkz NE updkz_old.
      PERFORM vbsk_aktualisieren USING temp_vbeln.
    ENDIF.

*   Liefernummer in die abhängigen Tabellen einsetzen
    IF aufrufer NE chart.              ">>>> NICHT, falls Transport
      PERFORM lieferung_rename USING temp_vbeln
                                    if_flag_docnum_new.     "40C WMS
    ENDIF.

*   Letzte Neuermittlungen im BELEG Sichern
    IF aufrufer NE chart AND           ">>>> NICHT, falls Transport
       v50agl-split EQ space.          "no final determinations
      PERFORM delivery_final_determinations
                USING xlikp-vbeln kopf_tabix.
    ENDIF.

*   SPE: Update document flow for transportation cross-docking
    IF aufrufer NE chart.
      CALL FUNCTION '/SPE/CD_DOCFLOW_UPDATE'
        EXPORTING
          is_xlikp           = xlikp
          if_goods_issue     = v50agl-warenausgang
          if_goods_issue_rev = v50agl-warenausg_storno
          if_delivery_split  = v50agl-split
          if_synchron        = v50agl-synchron              "n_1310553
        IMPORTING
          es_xlikp           = xlikp                        "n_1389316
        TABLES
          it_xlikp           = xlikp[]
          it_xlips           = xlips[]
          it_xvbpa           = xvbpa[].
    ENDIF.

    IF lf_od_before_numbering EQ space.
*     V2 (delivery) output messages determination
      PERFORM beleg_nachrichten_v2 USING xlikp-vbeln.
*     V6 (Handle Unit) Output messages determination
      PERFORM nachrichten_vse_buchen.
    ENDIF.

*   Sperren der Lieferungen beim Hinzufügen
    IF t180-trtyp  EQ 'H' AND
       v50agl-mult EQ space         OR
       xlikp-updkz EQ updkz_new AND
       v50agl-mult NE space.
      PERFORM lieferung_sperren(sapmv50a) USING xlikp-vbeln.
enhancement-point fv50xf0b_beleg_sichern_01 spots es_fv50xf0b_beleg_sichern include bound.
    ENDIF.

    CLEAR: lf_no_po_update.                                 "v_n_1589704
    IF xlikp-vbtyp      EQ vbtyp_liav AND
       xlikp-kzebu EQ charx      AND
       wa_zaehl    EQ 0.
      LOOP AT xlips ASSIGNING <lfs_lips>
                    WHERE     vbeln = xlikp-vbeln
                    AND NOT   updkz IS INITIAL.
*       Check all update relevant delivery items
        IF <lfs_lips>-updkz         = charu AND
           <lfs_lips>-spe_gen_elikz = charx AND
           <lfs_lips>-ebumg IS INITIAL.
          READ TABLE ylips WITH KEY vbeln = <lfs_lips>-vbeln
                                    posnr = <lfs_lips>-posnr
                                    lgmng = <lfs_lips>-lgmng
                                    BINARY SEARCH.
          IF sy-subrc IS INITIAL.
*           In case only completion indicator is set=> Skip PO update!
            lf_no_po_update = charx.
          ELSE.
*           Qantity changed!
            CLEAR: lf_no_po_update.
            EXIT.
          ENDIF.
        ELSE.
*         Any other update...
          CLEAR: lf_no_po_update.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.                                                  "^_n_1589704

*   Für das Lieferavis/Grob-WE bzw. für Lieferung zur Bestellung:
*   Kommunikation zur Bestellung aufnehmen
    IF ( aufrufer NE chart OR             ">>>> NICHT, falls Transport
         v50agl-force_po_update NE space )                  "n_1226602
     AND lf_no_po_update IS INITIAL.                        "n_1589704
      PERFORM bestellung_aktualisieren.
    ENDIF.

  ENDLOOP.


ENHANCEMENT-POINT EP_FV50XF0B_BELEG_SICHERN_01 SPOTS ES_FV50XF0B_BELEG_SICHERN INCLUDE BOUND .

  IF NOT lt_docnum_publish[] IS INITIAL AND
    NOT gi_badi_delivery IS INITIAL.
    CALL METHOD gi_badi_delivery->document_number_publish
      EXPORTING
        it_docnum_publish = lt_docnum_publish
        is_v50agl         = v50agl
        if_trtyp          = t180-trtyp
        if_tcode          = t180-tcode
      CHANGING
        cs_v50agl_cust    = v50agl_cust.
  ENDIF.


* Tabellen nach Einsetzen der Belegnummer neu sortieren
  PERFORM lieferungstabellen_sortieren.

  READ TABLE xlikp INDEX 1.
  likp = xlikp.

  IF xlikp-vbeln = space.
    MESSAGE a845(vl).
  ENDIF.

* SPE Returns: renumber SPE carrier data with actual delivery number
  IF xlikp-vbtyp = vbtyp_lire AND
    ( xlikp-spe_le_scenario = gc_le_scenario-return OR
    xlikp-spe_le_scenario = gc_le_scenario-tpop ).
    CALL FUNCTION '/SPE/RET_RENUM_CARRIER_LIST'
      TABLES
        it_lips = xlips.
    CALL FUNCTION '/SPE/RET_RENUM_PACKPROP_LIST'
      TABLES
        it_lips = xlips.
  ENDIF.

* Verify and post classification (selection criteria)       "n_v_1509744
* classification must be posted without Perform On Commit
* due to dirty reads of messages (QM certificates)
* is not longer valid because in the meantime (since note 601968)
* the order of calles (Classification - Messages) was changed
  LOOP AT xlikp ASSIGNING <xlikp>.                          "n_1651466
    CALL FUNCTION 'V01F_BDSEL_OBJECTS_VERIFY'
      EXPORTING
        i_vbeln_vl = <xlikp>-vbeln                          "n_1651466
*       i_no_poc   = 'X'
      TABLES
        t_lips     = xlips[].                               "n_^_1509744
  ENDLOOP.                                                  "n_1651466

ENDFORM.                               " BELEG_SICHERN_RENUMBER


*&---------------------------------------------------------------------*
*&      Form  BELEG_SICHERN_POST
*&---------------------------------------------------------------------*
FORM beleg_sichern_post.

* VPRS Update process
  DATA: lo_vprs_update_process TYPE REF TO cl_vprs_update_process.

  DATA:
        vbeln_von     LIKE likp-vbeln,
        vbeln_bis     LIKE likp-vbeln,
        lf_in_update_task LIKE sy-subrc,                    "n_1126620
        lt_text_vbeln TYPE lv70t_ty_appl_table.
  DATA: merk_ahbas    LIKE eikp-ahbas.
  DATA: lt_hu_header TYPE hum_hu_header_t,
        lt_hu_item   TYPE hum_hu_item_t,
        ls_objects   TYPE hum_object,
        lt_objects   TYPE hum_object_t,
        lf_mblnr     TYPE mblnr.                            "EhP4
  FIELD-SYMBOLS: <fs_likp> TYPE likpvb.

enhancement-point beleg_sichern_post_10 spots es_fv50xf0b_beleg_sichern static include bound.

*-begin of AIP
* no post if there is any error message in log and caller wants no
* posting, insert of A-message is done outside
  IF v50agl-error_tolerance CA chara.
    LOOP AT cvbfs TRANSPORTING NO FIELDS
                  WHERE msgty EQ chare.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
*     deliveries will not be created -> do not save vbls
      REFRESH cvbls.
      CLEAR vbsk-vbnum.
      CLEAR vbsk-anzlp.
*     set updkz to D to prevent item related vbls
      xlips-updkz = chard.
      MODIFY xlips TRANSPORTING updkz WHERE updkz <> chard.
      EXIT.
    ENDIF.
  ENDIF.
*-end   of AIP

* SPE Memorize current HU data, as it will be refreshed in the MM posting.
* We need to have the HU data available for the CRM Billing interface
* which is called later.
  ls_objects-object = gc_pacobj-obdlvry.
  LOOP AT xlikp ASSIGNING <fs_likp>
                WHERE vbtyp CA vbtyp_lief
                AND   updkz <> chard
                AND   updkz <> space.
    ls_objects-objkey = <fs_likp>-vbeln.
    APPEND ls_objects TO lt_objects.
  ENDLOOP.

  IF lt_objects IS NOT INITIAL.
    CALL FUNCTION '/SPE/HU_X_GET_HUS_FROM_ITVBFA'
      EXPORTING
        it_objects  = lt_objects
        it_xvbfa    = xvbfa[]
      IMPORTING
        et_header   = lt_hu_header[]
        et_items    = lt_hu_item[]
      EXCEPTIONS
        hus_locked  = 0
        no_hu_found = 0
        hu_changed  = 0
        fatal_error = 4
        OTHERS      = 5.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE type_a NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  "Line deleted with note 976740
  IF kz_lieferavis EQ charx OR
     t180-tcode EQ 'VL31N'.
    CLEAR: vbeln_von, vbeln_bis.
    LOOP AT xlikp.
      IF vbeln_von IS INITIAL OR xlikp-vbeln LT vbeln_von.
        vbeln_von = xlikp-vbeln.
        CONTINUE.
      ENDIF.
      IF vbeln_bis IS INITIAL      OR
         vbeln_bis LT xlikp-vbeln.
        vbeln_bis = xlikp-vbeln.
      ENDIF.
    ENDLOOP.
  ENDIF.
  READ TABLE xlikp INDEX 1.

* Inspection lots
  CALL FUNCTION 'QMHU_QMHUTAB_POSTING'.

* Renumber and post adresses (46A)
  PERFORM address_renumber_and_post.

* Call all BAPIs for deliveries (now in seperate routine)   4.6c, ULa
  PERFORM call_bapi_delivery.

*---------------------------------------------------------------------*
*    Texte werden auf die Datenbank geschrieben                       *
*    Prüflose werden abgesetzt                                        *
*---------------------------------------------------------------------*
  IF aufrufer NE chart.                ">>>> NICHT, falls Transport

    PERFORM fill_lt_text_vbeln USING lt_text_vbeln[].
    READ TABLE xlikp INDEX 1.

* Performance: not during picking confirmation
    IF v50agl-no_texts IS INITIAL.
      CALL FUNCTION 'SD_COMMIT_TEXT'
        EXPORTING
          fi_caller = gc_text_appl_id-delivery
          fit_vbeln = lt_text_vbeln[]
        EXCEPTIONS
          OTHERS    = 1.
    ENDIF.

  ENDIF.

  BREAK-POINT ID /spe/inb_hold.
  IF aufrufer NE chart AND                ">>>> NICHT, falls Transport
    ( xvbuk-hdall IS INITIAL AND xvbuk-hdals IS INITIAL ).
*   SPE INB RG 16.11.2004 HOLD status in item level
    PERFORM qm_qals_buchen(sapfv50p).
  ENDIF.

*---------------------------------------------------------------------*
*    Bei einzelner Lieferung wird die Belegnr. in Parameter gesetzt   *
*---------------------------------------------------------------------*
  IF aufrufer NE chart.                ">>>> NICHT, falls Transport
    IF v50agl-sammelgang NE charx AND
      v50agl-no_commit = ' '.
      PERFORM lieferung_set_get_setzen.
    ENDIF.
  ENDIF.

*---------------------------------------------------------------------*
*    Aufruf der Verbuchungs-Routine beim Hinzufügen oder Ändern
*---------------------------------------------------------------------*
*    Im Ändern und Hinzufügen gleiche Updatefunktionsbausteine werden *
*    nicht mehr doppelt codiert                                       *
*---------------------------------------------------------------------*

  IF aufrufer NE chart.                ">>>> NICHT, falls Transport
*------- Außenhandel
*------- Setzen des korrekten Außenhandelsbasisbelegs
    IF ( likp-vbtyp EQ vbtyp_liav ) OR
       ( likp-vbtyp EQ vbtyp_grwe ) .
      merk_ahbas = '1LA'.
    ELSE.
      merk_ahbas = '2LI'.
    ENDIF.
    CALL FUNCTION 'EXPIMP_POSTING_TRIGGER'
      EXPORTING
        i_ahbas   = merk_ahbas
      TABLES
        i_t_xlikp = xlikp.
    CALL FUNCTION 'FT_SLS_PARTNER_FTRADE_PREPARE'
      EXPORTING
        i_base_document              = merk_ahbas
        i_document_number            = likp-vbeln
      TABLES
        i_t_lipsvb_del_line_item_new = xlips
        i_t_vbpavb_partner_new       = xvbpa
        i_t_vbpavb_partner_old       = yvbpa
        i_t_sadrvb_address_new       = xvbadr
        i_t_sadrvb_address_old       = yvbadr.

*   Transfer Inbound / Outbound deliveries to SAP GTS
    PERFORM sll_document_transfer USING t180-trtyp
                                        xlikp[]
                                        xlips[]
                                        ylips[]
                                        xvbpa[]
                                        yvbpa[]
                                        xvbup[]
                                        yvbup[]
                                        xvbadr[].

*   Versandtermine verbuchen
*   performance: not during picking confirmation
    IF v50agl-no_deadlines IS INITIAL.
      PERFORM versandtermine_buchen.
    ENDIF.

*   Torbelegungen verbuchen / nur im Beleg Ändern
    PERFORM appointments_buchen.

*   eXpress Ship Interface-Daten verbuchen
    IF NOT tvshp-xsiactive IS INITIAL.
      LOOP AT xlikp WHERE updkz NE chard.                  "v_n_1081640
        READ TABLE xvbuk WITH KEY vbeln = xlikp-vbeln.
        CLEAR yvbuk.
        READ TABLE yvbuk WITH KEY vbeln = xlikp-vbeln.
        EXIT.
      ENDLOOP.
      IF xvbuk-wbstk CA ' AB' OR         "no gi
         xvbuk-wbstk EQ charc AND        "gi posting - deli change
         yvbuk-wbstk CA ' AB' AND
         NOT yvbuk-vbeln IS INITIAL OR
         xvbuk-wbstk EQ charc AND        "gi posting - deli creation
         xvbuk-updkz EQ chari.                             "^_n_1081640
        CALL FUNCTION 'XSI_TABLE_UPDATE'
          EXPORTING
            i_update_task = 'X'.
      ENDIF.                                                "n_1081640
    ENDIF.
  ENDIF.

* Ggf. XAB-Nummer ziehen und in die Lieferung fortschreiben
  IF wa_zaehl EQ char1 AND emkpf-subrc EQ char1.
    READ TABLE xlikp INDEX 1.
    IF sy-subrc EQ char0 AND NOT xlikp-updkz EQ updkz_delete.
      IF xlikp-xabln EQ space.
        CALL FUNCTION 'MB_XAB_NUMBER_GET'
          IMPORTING
            mkpf_xabln = xlikp-xabln.
        MODIFY xlikp INDEX 1 TRANSPORTING xabln.
      ENDIF.
    ENDIF.
  ENDIF.

enhancement-point beleg_sichern_post_11 spots es_fv50xf0b_beleg_sichern include bound.

  PERFORM lieferungen_verbuchen_db.
enhancement-point beleg_sichern_post_15 spots es_fv50xf0b_beleg_sichern include bound.


* Verbuchen des Fehlerprotokolls und der Gruppe, falls Sammelgangnummer
* von außen mitgegeben
  IF v50agl-sammelgang = charx  AND
     v50agl-sofauftrag EQ space AND
     NOT vbsk-sammg IS INITIAL.
    CALL FUNCTION 'RV_DELIVERY_CC_ERRORLOG_ADD' IN UPDATE TASK
      EXPORTING
        fvbsk = vbsk
      TABLES
        fvbfs = cvbfs
        fvbss = cvbss.
  ENDIF.

* Verbuchen der Findungsdaten
  IF lepad_pakti-uname = sy-uname AND
     lepad_pakti-kzakt CA 'L'.
    CALL FUNCTION 'LE_PAD_SAVE'
      EXPORTING
        is_likp   = likp
        is_v50agl = v50agl
        is_vbsk   = vbsk.
  ENDIF.
*---------------------------------------------------------------------*
*    Warenausgang verbuchen (neu 4.0)                                 *
*---------------------------------------------------------------------*
* WA-Verbuchung nur aufrufen, wenn tatsächlich der Funktionsbaustein  *
* MB_CREATE_GOODS_MOVEMENT erfolgreich durchlaufen wurde.             *
*---------------------------------------------------------------------*
enhancement-point beleg_sichern_post_40 spots es_fv50xf0b_beleg_sichern include bound .
  DATA: lt_inb_cifext TYPE TABLE OF /spe/inb_cifext.
enhancement-section     beleg_sichern_post_16 spots es_fv50xf0b_beleg_sichern include bound.
  IF wa_zaehl EQ char1 AND emkpf-subrc EQ char1.
    IF aufrufer NE chart.
      LOOP AT xlips TRANSPORTING NO FIELDS
                    WHERE updkz NE updkz_delete AND
                          kzbew EQ 'B'.
        CALL FUNCTION 'EXPIMP_TABLES_REFRESH'.
        EXIT.
      ENDLOOP.
    ENDIF.
    LOOP AT xlikp WHERE updkz NE updkz_delete.

* SPE ST 22.03.2005 Collect selected delivery data for CIF

      CALL FUNCTION '/SPE/CIF_IBDLV_INFO_GET'
        EXPORTING
          i_likp        = xlikp
        TABLES
          it_xlips      = xlips
          ot_inb_cifext = lt_inb_cifext.


      CALL FUNCTION 'MB_POST_GOODS_MOVEMENT'
        EXPORTING
          xblnr_sd = xlikp-vbeln
        IMPORTING
          emkpf    = emkpf
        EXCEPTIONS
          OTHERS   = 0.
      EXIT.
    ENDLOOP.
  ELSE.
* Handling Units verbuchen
    IF NOT packdaten_verbuchen IS INITIAL.
      IF vpobj = '03'.
        LOOP AT xlips TRANSPORTING NO FIELDS
                      WHERE updkz NE updkz_delete AND
                            NOT ummat IS INITIAL.
          EXIT.
        ENDLOOP.
      ENDIF.
      IF vpobj = '01' OR sy-subrc IS INITIAL.
        PERFORM wm_update_packing.
      ENDIF.
      CALL FUNCTION 'HU_PACKING_UPDATE'
        EXPORTING
          if_synchron = v50agl-synchron.
      CALL FUNCTION 'HU_PACKING_REFRESH'.
    ENDIF.
  ENDIF.
end-enhancement-section.

ENHANCEMENT-POINT EHP_BELEG_SICHERN_POST_01 SPOTS ES_FV50XF0B_BELEG_SICHERN INCLUDE BOUND .
*--> real time co-fi integration in REM: note 1410355
* shall be called after mb_post_goods_movement and before commit work
  CALL FUNCTION 'K40C_CODOCS_TO_ACC_TRANSFER'
    EXCEPTIONS
      error_occurred = 1
      OTHERS         = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
         WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
*-----------------------------------------------------------------
*    Create INbound Delivery
*-----------------------------------------------------------------
* create inbound delivery from outbound delivery
* if a following delivery type is given
* and the outbound delivery goods movement is booked
  PERFORM wf_ibdlv_from_obdlv.

*SPE MP 25.01.2005 Returns: post new carrier data
  IF xlikp-vbtyp EQ vbtyp_lire AND
     xlikp-spe_le_scenario = gc_le_scenario-return.
    CALL FUNCTION '/SPE/RET_START_CARRIER_POSTING'
      EXPORTING
        if_synchron = v50agl-synchron.
    CALL FUNCTION '/SPE/RET_START_PACPROP_POSTING'
      EXPORTING
        if_synchron = v50agl-synchron.
  ENDIF.

* SPE BEY 18.02.05 Cross-Docking: Update CD document flow
  CALL METHOD /spe/cl_cd_docflow=>post
    EXPORTING
      if_synchron = v50agl-synchron.

* SPE VB 15.02.2005 Cross-Docking: Process item information update
  CALL FUNCTION '/SPE/CD_PROCESS_UPD'
    EXPORTING
      iv_synchron        = v50agl-synchron
      iv_goods_issue     = v50agl-warenausgang
      iv_goods_issue_rev = v50agl-warenausg_storno
      iv_delivery_split  = v50agl-split
    TABLES
      it_xlikp           = xlikp[]
      it_xlips           = xlips[]
      it_ylips           = ylips[]
      it_vbpa            = xvbpa[].

* end SPE

*---------------------------------------------------------------------*
*    Serialnummern verbuchen                                          *
*---------------------------------------------------------------------*

  IF aufrufer NE chart.                ">>>> NICHT, falls Transport
* Teil-WE: Serialnumber_update must be performed for partial GR .
    LOOP AT xlips TRANSPORTING NO FIELDS
                  WHERE   anzsn > 0 OR
                        ( lgmng > xlips-ebumg_bme AND NOT
                          hupos IS INITIAL ) .
      EXIT.
    ENDLOOP.
*   needed just in case of assigned and/or deleted serial numbers
    IF sy-subrc IS INITIAL.
      PERFORM serialnumber_update.
    ELSE.
      LOOP AT ylips TRANSPORTING NO FIELDS
                    WHERE anzsn > 0.
        EXIT.
      ENDLOOP.
      IF sy-subrc IS INITIAL.
        PERFORM serialnumber_update.
      ENDIF.
    ENDIF.
  ENDIF.

*---------------------------------------------------------------------*
*    POD verbuchen                                                    *
*---------------------------------------------------------------------*

  IF aufrufer NE chart.                ">>>> NICHT, falls Transport

enhancement-point beleg_sichern_post_17 spots es_fv50xf0b_beleg_sichern include bound.

* Performance: not during picking confirmation
    IF v50agl-no_pod IS INITIAL.
ENHANCEMENT-POINT BELEG_SICHERN_POST_25 SPOTS ES_FV50XF0B_BELEG_SICHERN INCLUDE BOUND .
      CALL FUNCTION 'LE_POD_TVPOD_SAVE_DB'
        EXPORTING
          if_synchron = v50agl-synchron                     "n_1058191
          if_vbeln    = xlikp-vbeln.
    ENDIF.
ENHANCEMENT-POINT EHP4_FV50WF0B_BELEG_SICHERN SPOTS ES_FV50XF0B_BELEG_SICHERN INCLUDE BOUND .
  ENDIF.

*---------------------------------------------------------------------*
*    LIPS-Referenzdaten verbuchen                                     *
*---------------------------------------------------------------------*

  PERFORM lr_reference_data_update.

*---------------------------------------------------------------------*
*    Nicht änderbare Felder verbuchen                                 *
*---------------------------------------------------------------------*
  PERFORM dlfld_update.

*---------------------------------------------------------------------*
*    Gefahrgutzusatzdaten verbuchen                                   *
*---------------------------------------------------------------------*
  IF aufrufer NE chart.                ">>>> NICHT, falls Transport
    PERFORM gg_lipsdg_update.
*   Verbuchen der Gefahrgutbelegtabelle (Template-Material-Abwicklung)
    CALL FUNCTION 'EHS003_DGMSD_UPDATE'
      EXPORTING
        i_vbeln    = likp-vbeln
        i_synchron = v50agl-synchron
        i_vbtyp    = likp-vbtyp
      EXCEPTIONS
        others_    = 1.
  ENDIF.

* start Revenue Recognition Project
  IF NOT v50agl-warenausgang     IS INITIAL  OR
     NOT v50agl-warenausg_storno IS INITIAL  OR
     NOT xvbuk-pdstk             IS INITIAL.

*   Determine company code data
    IF tvko-vkorg EQ xlikp-vkorg.
      IF t001-bukrs NE tvko-bukrs.
        SELECT SINGLE * FROM  t001
                        WHERE bukrs = tvko-bukrs.
      ENDIF.
    ELSE.
      SELECT SINGLE * FROM  tvko
                      WHERE vkorg = xlikp-vkorg.
      SELECT SINGLE * FROM  t001
                      WHERE bukrs = tvko-bukrs.
    ENDIF.

    CALL FUNCTION 'SD_REV_REC_EVENT'
      EXPORTING
        fis_t001k            = t001k
        fis_t001             = t001
        fif_warenausgang     = v50agl-warenausgang
        fif_warenausg_storno = v50agl-warenausg_storno
        fit_tvpod            = gt_tvpod[]
        fit_xvbup            = xvbup[]
        fit_yvbup            = yvbup[]
        fit_sitbw            = gt_sitbw[]
      TABLES
        fit_xlikp            = xlikp
        fit_xlips            = xlips
        fit_xvbap            = xvbap
        fit_xvbapf           = xvbapf
        fit_xvbfa            = xvbfa.
  ENDIF.
* end revenue recognition project

  IF NOT v50agl-warenausgang     IS INITIAL  OR
     NOT v50agl-warenausg_storno IS INITIAL.
*   Call VPRS-Update process if it is activated
    lo_vprs_update_process =
       cl_vprs_update_process=>get_vprs_update_process( ).
    lo_vprs_update_process->handle_vprs_update_process(
                  EXPORTING iv_caller         = cl_rr_constants=>gc_caller_d
                            it_vbap           = xvbap[]
                            it_vbuk           = xvbuk[]
                            it_vbup           = xvbup[]
                            it_lips           = xlips[]
                            it_vbfa           = xvbfa[]
                            iv_bukrs          = t001-bukrs ).
  ENDIF.

* lines deleted                                               "n_1509744

* documentary batch
  IF gf_docubatch_active EQ 'X' AND
     v50agl-late_delivery_upd IS INITIAL AND                "n_1589850
   ( likp-vbtyp EQ vbtyp_lino   OR
     likp-vbtyp EQ vbtyp_liav ).
    DATA:
      lv_process_id    TYPE docubatch_process_id.
    IF xlips-vgtyp EQ vbtyp_bestell.
      lv_process_id = '01'. " GR for purchasing
    ELSE.
      lv_process_id = '06'. " GI for delivery
    ENDIF.
    CALL FUNCTION 'VBDBDM_DATA_POST_LE'
      EXPORTING
        i_process_id = lv_process_id
        i_likp       = xlikp
        it_lips      = xlips[].
  ENDIF.

* BAdI method for saving own data and for delivery publishing
  IF NOT gi_badi_delivery IS INITIAL.                       "v_n_974915
    CALL METHOD gi_badi_delivery->save_and_publish_before_output
      EXPORTING
        it_xlikp       = xlikp[]
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        it_vbfs        = cvbfs[]                            "SPE
        if_tcode       = t180-tcode
      CHANGING
        cs_v50agl_cust = v50agl_cust.
  ENDIF.                                                    "^_n_974915

* Kanban update
  IF  cl_ewm_switch_check=>le_sfws_sc_ewm_man( ) = gc_true.
    CALL METHOD /spe/cl_ewm_kanban_intf=>status_update
      EXPORTING
        it_xlikp = xlikp[]
        it_xlips = xlips[]
        it_ylips = ylips[]
        it_xvbuk = xvbuk[]
        it_yvbuk = yvbuk[]
        it_xvbup = xvbup[]
        it_yvbup = yvbup[].
  ENDIF.

*---------------------------------------------------------------------*
*    Nachrichten verbuchen                                            *
*---------------------------------------------------------------------*
*   Nachrichten müssen als letztes in die V1 gestellt werden TSCH
*   Ansonsten würden beim Hinzufügen von Lieferungen im Druckprogramm
*   Daten gelesen werden, die noch nicht mit COMMIT auf der Datenbank
*   stehen (dirty read, nicht immer so erlaubt) und ggf. Papiere
*   gedruckt werden, obwohl kein Beleg erzeugt wurde.
*   Ferner gibt es bei Nachrichten mit Zeitpunkt 4 keinen Ärger mehr,
*   weil die Lieferungen schon gesichert sind (z.B. WMTA oder EK00).
*   Im Fall von fehlerhaften Nachrichten muß man wie bei mit RSNAST00
*   fehlerhaft erzeugten Nachrichten neu drucken       JH
  IF v50agl-sofauftrag IS INITIAL.                          "v_n_885688
    CALL FUNCTION 'TH_IN_UPDATE_TASK'                      "v_n_1126620
         IMPORTING
             in_update_task = lf_in_update_task.
    IF NOT lf_in_update_task IS INITIAL OR
       sy-oncom EQ 'N'          OR                          "n_1320109
       NOT kz_grobwe IS INITIAL OR                          "n_1244154
       cl_system_transaction_state=>get_on_commit( ) NE 0.  "n_1141271
      PERFORM nachrichten_buchen.
    ELSE.
      PERFORM nachrichten_buchen ON COMMIT LEVEL level_msg_post.
    ENDIF.
  ELSE.                                                    "^_n_1126620
    PERFORM nachrichten_buchen ON COMMIT LEVEL level_msg_post. "n_946479
  ENDIF.                                                    "^_n_885688
enhancement-point beleg_sichern_post_18 spots es_fv50xf0b_beleg_sichern include bound.


*** Call Interface monitor for Confirmation channel to CRM        SPE
  CALL FUNCTION '/SPE/OUTB_LOGFILE_XB'
    EXPORTING
      i_mcapp      = 'XB'
      i_v50agl     = v50agl
      i_t180_trtyp = t180-trtyp
      i_vbsk       = vbsk
    TABLES
      xlikp        = xlikp
      ylikp        = ylikp
      xvbuk        = xvbuk
      yvbuk        = yvbuk
      xvbup        = xvbup
      yvbup        = yvbup
      xlips        = xlips
      ylips        = ylips
      xvbpa        = xvbpa
      yvbpa        = yvbpa
      xvbfa        = xvbfa
      yvbfa        = yvbfa
      xvbadr       = xvbadr
      cvbfs        = cvbfs.

* BAdI method for saving own data and for delivery publishing
  IF NOT gi_badi_delivery IS INITIAL.
    CALL METHOD gi_badi_delivery->save_and_publish_document
      EXPORTING
        it_xlikp       = xlikp[]
        it_ylikp       = ylikp[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        it_vbfs        = cvbfs[]                            "SPE
        if_tcode       = t180-tcode
      CHANGING
        cs_v50agl_cust = v50agl_cust.
  ENDIF.

* Userexit
  PERFORM userexit_save_document(sapmv50a).

enhancement-point fv50xf0b_beleg_sichern_03 spots es_fv50xf0b_beleg_sichern static include bound.

enhancement-point fv50xf0b_beleg_sichern_04 spots es_fv50xf0b_beleg_sichern include bound.

* SPE INB RG 16.11.2004 HOLD status in item level
  BREAK-POINT ID /spe/inb_hold.
  IF xvbuk-hdall IS INITIAL AND
    xvbuk-hdals  IS INITIAL AND
    v50agl-only_doc_flow_upd IS INITIAL.                    "n_1638338
*   Statistic update, but not for deliveries on hold
*                     and not for GR for replenishment deliveries
    PERFORM lieferung_statistiken_buchen.
  ENDIF.
enhancement-point beleg_sichern_post_24 spots es_fv50xf0b_beleg_sichern include bound.

* Sichern der separaten externen Belegtabellen Absicherungsmanagement
  IF aufrufer NE chart.                ">>>> NICHT, falls Transport
    PERFORM kreditdokument_save(sapfv50k).
  ENDIF.

* Änderungsbeleg erstellen
  PERFORM beleg_change_documents(sapmv50a).

  IF xlikp-vbtyp CA vbtyp_mmli OR
     xlikp-vbtyp CA vbtyp_lief   .                          "n_1034017
    LOOP AT xlips TRANSPORTING NO FIELDS
                  WHERE     updkz NE updkz_delete AND
                        NOT qplos IS INITIAL.
      CALL FUNCTION 'QMHU_ON_COMMIT'.
      EXIT.
    ENDLOOP.
  ENDIF.

enhancement-point beleg_sichern_post_19 spots es_fv50xf0b_beleg_sichern include bound.

  PERFORM sd_mob_client_update.

* Transfering delivery-informations to CRM-middleware via plug-in
* for delivery-based invoicing in CRM
  PERFORM bte_00501015_call TABLES lt_hu_header
                                   lt_hu_item.

enhancement-point fv50xf0b_beleg_sichern_05 spots es_fv50xf0b_beleg_sichern include bound.

*** SPE 100 Transfer document number to recycling buffer
  CALL FUNCTION '/SPE/DLVRY_TRANS_TO_REC'
    EXPORTING
      iv_synchron = v50agl-synchron
    TABLES
      it_likp     = xlikp[].

enhancement-point beleg_sichern_post_23 spots es_fv50xf0b_beleg_sichern static include bound.


enhancement-section     beleg_sichern_post_21 spots es_fv50xf0b_beleg_sichern include bound.
  IF v50agl-no_commit = ' '  AND
     v50agl-sofauftrag NE charx.
*   Bei Aufruf aus Verpacken wird der Commit extern gesetzt
    PERFORM sd_monitor_protocol_save.
    IF v50agl-synchron NE charx.
      COMMIT WORK.
    ELSE.
      COMMIT WORK AND WAIT.
    ENDIF.
  ENDIF.
end-enhancement-section.

  PERFORM text_memory_init.
* pubish delivery via BADI
  PERFORM delivery_publish_after_save.
* refresh delivery buffer
  IF v50agl-no_buffer_refresh EQ space.
    PERFORM buffer_refresh_delivery TABLES xlikp.
  ENDIF.

enhancement-point fv50xf0b_beleg_sichern_06 spots es_fv50xf0b_beleg_sichern include bound.

*---------------------------------------------------------------------*
*    Abschlußarbeiten
*    beim Sammelgang erfolgt die Rückkehr in den rufenden Modul
*---------------------------------------------------------------------*
ENHANCEMENT-SECTION FV50XF0B_BELEG_SICHERN_23 SPOTS ES_FV50XF0B_BELEG_SICHERN_1 INCLUDE BOUND .
  IF v50agl-sammelgang NE charx AND v50agl-no_commit = ' '.

    PERFORM dialog_protocol TABLES xlikp
                                   cvbfs.

    IF ylikp_updkz = updkz_delete.
      MESSAGE s310 WITH tvlkt-vtext xlikp-vbeln.
    ELSE.
      IF kz_wareneingang NE charx.
        IF ( kz_lieferavis EQ charx OR t180-tcode EQ 'VL31N' ) AND
           NOT vbeln_bis IS INITIAL.
          MESSAGE s139 WITH tvlkt-vtext vbeln_von vbeln_bis.
        ELSE.
          IF xlikp-vlstk EQ 'B' AND
             xlikp-verursys IS INITIAL AND
             v50agl-dlv_change EQ space.
            MESSAGE s337 WITH tvlkt-vtext xlikp-vbeln.
          ELSE.
            IF xlikp-vlstk EQ chara AND
               xlikp-verursys IS INITIAL.
              MESSAGE s589 DISPLAY LIKE 'W'
                WITH tvlkt-vtext xlikp-vbeln xlikp-lgnum.
            ELSEIF xlikp-sakes EQ charb.     "GTS Safe Keeping Status
              MESSAGE s593
                WITH tvlkt-vtext xlikp-vbeln.
            ELSE.
*             Get material document no. (EhP4)
              IF v50agl-warenausgang EQ charx AND
                 xlikp-vbtyp EQ vbtyp_liav     AND
                cl_ops_switch_check=>le_sfws_om_1( ) EQ abap_true.
                lf_mblnr = cl_shp_lecomp_control=>gf_mblnr.
              ENDIF.
              IF lf_mblnr IS INITIAL.
                IF gv_sit_doc_num IS INITIAL.
                  IF gv_sit_flag IS NOT INITIAL.            "n1453081
                    MESSAGE s749 WITH tvlkt-vtext xlikp-vbeln. "n1453081
                  ELSE.
                    MESSAGE s311 WITH tvlkt-vtext xlikp-vbeln.
                  ENDIF.
                ELSE.
                  MESSAGE s746 WITH tvlkt-vtext xlikp-vbeln gv_sit_doc_num.
                ENDIF.
              ELSE.
                MESSAGE s234(vlsc) WITH xlikp-vbeln lf_mblnr.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE s611 WITH tvlkt-vtext xlikp-vbeln.
      ENDIF.
    ENDIF.

*   On some FCODES, BELEG_SICHERN is left here
    IF fcode EQ 'SAVE&EXIT'.
      EXIT.
    ENDIF.

    IF sy-calld = charx AND v50agl-no_commit = ' '.
      LEAVE.
    ENDIF.

*   nur bei Aufruf aus Rückmeldung Verpacken und Kommissionierung
    IF v50agl-no_commit = 'X'.
      EXIT.
    ENDIF.

*   Folgefunktion LT06 nach WA aufrufen
    IF sy-binpt EQ space                  AND
       sy-batch EQ space                  AND
       v50agl-kommirueckmeldung EQ space  AND
       v50agl-fo_fkt_lt06 EQ charx.
      fcode = 'LT06'.
      PERFORM fcode_bearbeiten(sapmv50a).
    ENDIF.

*---------------------------------------------------------------------*
*    Beim Veraendern oder Liefern mit Auftragsbezug wird
*    auf das erste Dynpro gesprungen
*---------------------------------------------------------------------*
    CHECK fcode(4) NE 'FT41'
      AND fcode(4) NE 'WETA'
      AND fcode(4) NE 'VL70'
      AND fcode(4) NE 'VL71'.
    CHECK fcode(4) NE 'SI03'.
    CHECK fcode(4) NE 'SI04'.
    IF lieferung_or NE charx
                    OR t180-trtyp EQ charv
                    OR sy-tcode = 'VL11'.
      IF gf_param_tcode IS INITIAL.
        fcode      = 'SIC1'.
        PERFORM fcode_bearbeiten(sapmv50a).
      ELSE.
        LEAVE TO TRANSACTION gf_param_tcode.
      ENDIF.
    ENDIF.
    IF lieferung_or EQ charx.

       *likp-vstel  = likp-vstel.
       *likp-vkorg  = likp-vkorg.
       *likp-lfart  = likp-lfart.
       *rv50a-vtweg = rv50a-vtweg.
       *rv50a-spart = rv50a-spart.
       *rv50a-txt_titcua = rv50a-txt_titcua.
      PERFORM beleg_daten_init.
      likp-vstel  = *likp-vstel.
      likp-vkorg  = *likp-vkorg.
      likp-lfart  = *likp-lfart.
      rv50a-vtweg = *rv50a-vtweg.
      rv50a-spart = *rv50a-spart.
      rv50a-txt_titcua = *rv50a-txt_titcua.

      lieferung_or = charx.
      or_erste_position = charx.

    ENDIF.

  ENDIF.
END-ENHANCEMENT-SECTION.
ENDFORM.                               " BELEG_SICHERN_POST
"v_XAN-SPE
*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN_ORMNG_DAT                                  *
*---------------------------------------------------------------------*
*       Determination original delivery quantity                      *
*---------------------------------------------------------------------*
FORM beleg_sichern_ormng_dat.

  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.

  LOOP AT xlips ASSIGNING <ls_xlips> WHERE updkz = updkz_new.
    <ls_xlips>-ormng = <ls_xlips>-lfimg.
  ENDLOOP.

ENDFORM.                                                    "^_XAN-SPE

*&---------------------------------------------------------------------*
*&      Form  CHECK_X_Y_TABLES
*&---------------------------------------------------------------------*

FORM check_x_y_tables USING if_caller TYPE string.          "n_1636529

* read log settings
  CALL FUNCTION 'SD_READ_TPARAMS_SD'
    EXPORTING
      i_parkey           = 'XYTAB_ANA'
      i_parname1         = 'SHIPPING'
    EXCEPTIONS
      invalid_parameters = 1
      not_found          = 2
      off                = 3
      OTHERS             = 4.

  CHECK sy-subrc EQ 0.

  CALL FUNCTION 'SD_DELIVERY_CHECK_XYTAB'
    EXPORTING
      it_xvbup  = xvbup[]
      it_yvbup  = yvbup[]
      it_xlips  = xlips[]
      it_ylips  = ylips[]
      is_v50agl = v50agl
      it_xlikp  = xlikp[].

ENDFORM.                    " CHECK_X_Y_TABLES