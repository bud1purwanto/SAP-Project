*----------------------------------------------------------------------*
*   INCLUDE MV50AF0S                                                   *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM SYNCHRON                                                 *
*---------------------------------------------------------------------*
* Diese Routine setzt das Kenzeichen für synchrone Buchung im
* SD_DELIVERY_UPDATE_PICKING
* Hinweis:  Korrektur: P30K124029  Release: 3.0F
*---------------------------------------------------------------------*
FORM synchron.

  DATA: lf_in_update_task LIKE sy-subrc.

  CALL FUNCTION 'TH_IN_UPDATE_TASK'
    IMPORTING
      in_update_task = lf_in_update_task
    EXCEPTIONS
      error_message  = 1
      OTHERS         = 2.

  IF sy-subrc = 0 AND lf_in_update_task = 0.
*   Falls nicht alle Updatebausteine synchron aufgerufen werden
*   Wenn man schon in der Verbuchung ist, darf dies nicht mehr
*   gemacht werden
    SET UPDATE TASK LOCAL.
  ENDIF.

* Es soll nicht in UPDATE TASK verbucht werden
  v50agl-synchron = charx.

ENDFORM.                    "synchron

*&---------------------------------------------------------------------*
*&      Form  SHIPMENT_INFO_CHECK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM shipment_info_check USING    value(if_trmtyp) LIKE likp-trmtyp
                                  value(if_error)  TYPE c
                         CHANGING if_traty LIKE likp-traty  "HP_323165
                                  cf_subrc TYPE sysubrc.

  CALL FUNCTION 'SD_SHIPMENT_MOT_TYPE_CHECK'
    EXPORTING
      i_trmtyp                   = if_trmtyp
    CHANGING
      c_traty                    = if_traty
    EXCEPTIONS
      mot_type_inconsistent      = 1
      transp_type_not_maintained = 2
      OTHERS                     = 3.
  IF if_error EQ space.
    cf_subrc = sy-subrc.
  ELSE.
    CASE sy-subrc.
      WHEN 1.
        MESSAGE ID 'VW' TYPE 'E' NUMBER '812' WITH if_trmtyp.
      WHEN 2.
        IF likp-trmtyp IS INITIAL.
          MESSAGE ID 'VW' TYPE 'E' NUMBER '813' WITH if_traty.
        ELSE.
          MESSAGE ID 'VW' TYPE 'E' NUMBER '814'
            WITH if_traty if_trmtyp.
        ENDIF.
    ENDCASE.
  ENDIF.

ENDFORM.                               " SHIPMENT_INFO_CHECK
*&---------------------------------------------------------------------*
*&      Form  SUBSCREEN_FCODE_FILTER
*&---------------------------------------------------------------------*
*       Some FCODES coming from included subscreens can not be
*       processed by the main dialog. They are replaced by the
*       neutral command 'ENT1' which keeps the current screen active
*       without doing anything else.
*----------------------------------------------------------------------*
FORM subscreen_fcode_filter CHANGING cf_fcode TYPE fcode.

  CHECK t180-bldgr EQ gc_new_dialog_outb
     OR t180-bldgr EQ gc_new_dialog_inb.

  IF cf_fcode NS '_T'   AND            "usual fcode (new dialog)
     cf_fcode NS 'T\'   AND            "fcode coming from the tab strip
     cf_fcode NE 'UCNX' AND            "process next incompleteness
     cf_fcode NE 'UCBK' AND            "process prev. incompleteness
     cf_fcode NE 'UCCL' AND            "close incompleteness screen
     cf_fcode NE 'ENT1'.               "neutral fcode
    cf_fcode = 'ENT1'.
  ENDIF.

ENDFORM.                               " SUBSCREEN_FCODE_FILTER
*&---------------------------------------------------------------------*
*&      Form  SALES_ORDER_ITEM_VALUES
*&---------------------------------------------------------------------*
*       Search help for the item numbers of a sales order to be
*       delivered in transaction VL01N
*----------------------------------------------------------------------*
FORM sales_order_item_values CHANGING cf_posnr TYPE posnr.

  DATA: lt_dynpfields LIKE dynpread OCCURS 1 WITH HEADER LINE,
        BEGIN OF lt_seltab OCCURS 10,
          vbeln LIKE lips-vbeln,
          posnr LIKE lips-posnr,
          matnr LIKE lips-matnr,
        END OF lt_seltab,
        lt_fields LIKE help_value OCCURS 1 WITH HEADER LINE,
        ls_select LIKE help_info-fldvalue,
        lf_dyname LIKE d020s-prog,
        lf_dynumber LIKE sy-dynnr,
        lf_help(10) TYPE n,
        lf_vbeln LIKE lips-vbeln VALUE '0000000000',
        lf_vbeln_text(10) TYPE c,
        lf_title(40) TYPE c.

* Get item number form dynpro (RETURN has not yet been processed)
  REFRESH lt_dynpfields.
  CLEAR lt_dynpfields.
  lt_dynpfields-fieldname = 'LV50C-VBELN'.
  APPEND lt_dynpfields.
  lf_dyname = sy-repid.
  lf_dynumber = sy-dynnr.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      dyname               = lf_dyname
      dynumb               = lf_dynumber
    TABLES
      dynpfields           = lt_dynpfields
    EXCEPTIONS
      invalid_abapworkarea = 1
      invalid_dynprofield  = 2
      invalid_dynproname   = 3
      invalid_dynpronummer = 4
      invalid_request      = 5
      no_fielddescription  = 6
      invalid_parameter    = 7
      undefind_error       = 8
      double_conversion    = 9
      OTHERS               = 10.
  IF sy-subrc NE 0.
    EXIT.
  ENDIF.
  LOOP AT lt_dynpfields WHERE fieldname EQ 'LV50C-VBELN'.
    IF lt_dynpfields-fieldvalue CO ' 0123456789'.          "v_n_1021814
      MOVE lt_dynpfields-fieldvalue TO lf_help.
      MOVE lf_help TO lf_vbeln.
    ELSE.
      MOVE lt_dynpfields-fieldvalue TO lf_vbeln.
    ENDIF.                                                 "^_n_1021814
    EXIT.
  ENDLOOP.
* No sales order number given: nothing to do
  IF lt_dynpfields-fieldvalue EQ space.
    EXIT.
  ENDIF.

* Read items of selected sales order
  REFRESH lt_seltab.
  CLEAR lt_seltab.
  SELECT vbeln posnr matnr FROM vbap
                           INTO CORRESPONDING FIELDS OF lt_seltab
                           WHERE vbeln EQ lf_vbeln.
    APPEND lt_seltab.
  ENDSELECT.
  IF sy-subrc NE 0.
    MESSAGE i303 WITH lf_vbeln.        "Sales order does not exist
  ENDIF.

* Assign selected fields to the data dictionary
  REFRESH lt_fields.
  CLEAR lt_fields.
  lt_fields-tabname = 'VBAP'.
  lt_fields-fieldname = 'VBELN'.
  lt_fields-selectflag = space.
  APPEND lt_fields.

  lt_fields-tabname = 'VBAP'.
  lt_fields-fieldname = 'POSNR'.
  lt_fields-selectflag = charx.
  APPEND lt_fields.

  lt_fields-tabname = 'VBAP'.
  lt_fields-fieldname = 'MATNR'.
  lt_fields-selectflag = space.
  APPEND lt_fields.

  WRITE lf_vbeln TO lf_vbeln_text NO-ZERO.
  lf_title = 'Positionen zum Auftrag &1'(070).
  REPLACE '&1' WITH lf_vbeln_text INTO lf_title.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      selectfield                  = 'LT_SELTAB-POSNR'
      titel                        = lf_title
      no_pers_help_select          = 'X'
      write_selectfield_in_colours = 'X'
      reduced_status_only          = 'X'
    IMPORTING
      select_value                 = ls_select
    TABLES
      fields                       = lt_fields
      full_table                   = lt_seltab
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.
  IF sy-subrc EQ 0.
    MOVE ls_select TO cf_posnr.
  ENDIF.

ENDFORM.                               " SALES_ORDER_ITEM_VALUES

*&---------------------------------------------------------------------*
*&      Form  SHIPMENT_VSART_CHECK
*&---------------------------------------------------------------------*
*       Check Business Data Shipping Type against Route table
*----------------------------------------------------------------------*
*      -->P_LIKP_VSART  text
*      -->P_LIKP_ROUTE  text
*----------------------------------------------------------------------*
FORM shipment_vsart_check USING    value(if_vsart) LIKE likp-vsart
                                   value(if_route) LIKE likp-route
                                   value(if_error) TYPE c
                          CHANGING cf_subrc TYPE sy-subrc.

  cf_subrc = 0.

  CHECK NOT if_vsart IS INITIAL.
  CHECK NOT if_route IS INITIAL.

  PERFORM tvro_select USING if_route
                            if_error
                            cf_subrc.

  CHECK NOT tvro-vsart IS INITIAL.

  IF tvro-vsart NE if_vsart.
    IF if_error EQ charx.
      MESSAGE e290 WITH if_vsart tvro-vsart tvro-route.
      cf_subrc = 4.
    ELSE.
      cf_subrc = 4.
    ENDIF.

  ENDIF.

ENDFORM.                               " SHIPMENT_VSART_CHECK
*eject

* Moved to its own include, included in SAPMV50A
* For the sake of clarity concerning note 167672
* (coding here) and 4.6C (coding in its own include)
* INCLUDE  mv50af0s_set_global_data.
*
*FORM set_global_data_mhpar_glomd  USING if_glomd TYPE t160mvl_glomd.
*
*  gs_mhpar-glomd = if_glomd.
*
*ENDFORM.
*&---------------------------------------------------------------------*
*&      Form  select_purchase_orders
*&---------------------------------------------------------------------*
FORM select_purchase_orders
     TABLES   ct_wueb      STRUCTURE wueb
     USING    if_lifnr     LIKE likp-lifnr
              if_selscreen TYPE c
     CHANGING cf_subrc     LIKE sy-subrc.

  DATA: lf_ekorg LIKE ekko-ekorg,
        lf_msgtxt TYPE c.

* Initialize memory
  SET PARAMETER ID 'EKO' FIELD lf_ekorg.

* Purchase orders
  CALL FUNCTION 'ME_QUERY_CALL_LIST_VL31'
    EXPORTING
      im_lifnr        = if_lifnr
      im_selscreen    = if_selscreen
    TABLES
      ex_wueb_tab     = ct_wueb
    EXCEPTIONS
      nothingselected = 1
      cancelled       = 2
      notfound        = 3
      OTHERS          = 4.

  cf_subrc = sy-subrc.
  IF sy-subrc NE 0.
    CASE sy-subrc.
      WHEN 1 OR 2.                    "keine Bestellungen ausgewählt
        MESSAGE e147 INTO lf_msgtxt.
      WHEN 3.                    "keine Bestellungen gefunden
        MESSAGE e146 INTO lf_msgtxt.
      WHEN 4.                         "Fehler Verarbeitung ABAP-Query
    ENDCASE.
  ENDIF.

ENDFORM.                    " select_purchase_orders

*&---------------------------------------------------------------------*
*&      Form  status_message_cm                                n_539607
*&---------------------------------------------------------------------*
FORM status_message_cm.
  IF t180-trtyp EQ charv AND NOT likp-verursys IS INITIAL.
* DWM in change mode
    CASE likp-vlstk.
      WHEN 'A'.
        IF NOT v50agl-dlv_change IS INITIAL AND
           NOT v50agl-dlv_change_off IS INITIAL.
* ERP cannot be called but Chg Mgmt requested  -> no Chg Mgmt
          MESSAGE s489(vl) DISPLAY LIKE 'W' WITH likp-verursys.
        ENDIF.
      WHEN 'E'.
* DWM splitted -> no Chg Mgmt
        MESSAGE s493(vl).
      WHEN 'F'.
* DWM deactivated Chg Mgmt for this delivery -> no Chg Mgmt
        MESSAGE s492(vl).
    ENDCASE.
  ENDIF.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  serialnumber_profile_check                       n_598948
*&---------------------------------------------------------------------*
FORM serialnumber_profile_check USING is_likp TYPE likp
                                      is_lips TYPE lips
                                      if_status LIKE tj01-vrgng
                                      if_trtyp LIKE t180-trtyp
                                CHANGING cf_anzsn LIKE lips-anzsn
                                       cf_dataloss LIKE r185d-dataloss.
  DATA:
    lf_xopera(04) TYPE c,
    lf_werks LIKE lips-werks,
    lf_iuid_relevant TYPE iuid_relevant,                    "EHP603 IUID
    lf_lgort LIKE lips-lgort,
      lf_charg LIKE lips-charg,                             "n_1059918
    lf_xanzsn LIKE risa0-anzahl,
    lf_cuobj  LIKE lips-cuobj,                              "v_n_930204
    ls_object TYPE ibxx_business_object,
    ls_marc   TYPE marc.                                    "^_n_930204

ENHANCEMENT-POINT MV50AF0S_01 SPOTS ES_SAPMV50A STATIC.

ENHANCEMENT-POINT MV50AF0S_02 SPOTS ES_SAPMV50A.

  lf_cuobj  = is_lips-cuobj.          "set initial value from lips
  lf_xanzsn = is_lips-lgmng.

* CUOBJ might differ between plants in STO precesses
  IF NOT is_lips-cuobj IS INITIAL AND "change only if cuobj is set
     NOT is_likp-werks IS INITIAL AND "only for STOs...
         is_likp-vbtyp EQ charj   AND
         is_lips-vgtyp EQ charv .

    CALL FUNCTION 'CUCB_GET_OWNER_OF_CFG'
      EXPORTING
        i_instance                   = is_lips-cuobj
      IMPORTING
        e_owner                      = ls_object
      EXCEPTIONS
        invalid_instance             = 1
        instance_is_a_classification = 2
        unknown_owner                = 3
        OTHERS                       = 4.

    IF sy-subrc = 0 AND ls_object-object_type CS 'MARC'.

      CALL FUNCTION 'MARC_SINGLE_READ'
        EXPORTING
          matnr             = is_lips-matnr
          werks             = is_lips-werks
        IMPORTING
          wmarc             = ls_marc
        EXCEPTIONS
          lock_on_marc      = 1
          lock_system_error = 2
          wrong_call        = 3
          not_found         = 4
          OTHERS            = 5.

      IF sy-subrc = 0 AND NOT ls_marc-cuobj IS INITIAL.
        CALL FUNCTION 'CEI0_COMPARE_CONFIGURATIONS'
          EXPORTING
            iv_cuobj1 = lf_cuobj
            iv_cuobj2 = ls_marc-cuobj
          EXCEPTIONS
            OTHERS    = 1.
        IF sy-subrc <> 0.
*         Should configuration not be compatible give a Warning
          MESSAGE ID   sy-msgid
                TYPE   charw
                NUMBER sy-msgno
                WITH   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        ENDIF.

        lf_cuobj = ls_marc-cuobj.    "get cuobj from current plant

      ENDIF.
    ENDIF.
  ENDIF.                                                    "^_n_930204

  IF is_likp-vbtyp CA vbtyp_retour.
    lf_xopera = 'SDRE'.
  ELSE.
ENHANCEMENT-POINT MV50AF0S_03 SPOTS ES_SAPMV50A.
    lf_xopera   = 'SDLS'.
  ENDIF.

ENHANCEMENT-POINT EHP603_MV50AF0S_01 SPOTS ES_SAPMV50A.

ENHANCEMENT-SECTION     MV50AF0S_04 SPOTS ES_SAPMV50A.

* take over valuation type into batch                      "v_n_1059918
  lf_charg = is_lips-charg.
  IF NOT is_lips-bwtex IS INITIAL AND NOT is_lips-xchar IS INITIAL AND
         is_lips-xchpf IS INITIAL AND     is_lips-charg IS INITIAL AND
     NOT is_lips-bwtar IS INITIAL.
    lf_charg = is_lips-bwtar.
  ENDIF.                                                   "^_n_1059918

  CALL FUNCTION 'SERIALPROFILE_CHECK'
    EXPORTING
      operation     = lf_xopera
      j_vorgang     = if_status
      activity      = if_trtyp
      document      = is_likp-vbeln
      item          = is_lips-posnr
      material      = is_lips-matnr
*     m_charge      = is_lips-charg
      m_charge      = lf_charg                              "n_1059918
      profile       = is_lips-serail
      quantity      = lf_xanzsn
      debitor       = is_likp-kunnr
      cuobj         = lf_cuobj                              "n_930204
      vbtyp         = is_likp-vbtyp
      bwart         = is_lips-bwart
      m_werk        = lf_werks
      m_lager       = lf_lgort
      iuid_relevant = lf_iuid_relevant                         "EHP603 IUID
    IMPORTING
      anzsn         = cf_anzsn
      serial_commit = cf_dataloss.
END-ENHANCEMENT-SECTION.

ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  serialnumber_checks                              n_598948
*&---------------------------------------------------------------------*
FORM serialnumber_checks  TABLES   it_xlips STRUCTURE lipsvb
                          USING    is_likp TYPE likp
                                   is_lips TYPE lips
                                   is_tvlk TYPE tvlk
                                   if_status LIKE tj01-vrgng
                                   if_trtyp LIKE t180-trtyp
                          CHANGING cf_trtyp LIKE t180-trtyp
                                   cf_rc TYPE sysubrc.
  DATA:
    lf_msg(100) TYPE c,
    ls_t340d LIKE t340d,
    ls_t377 TYPE t377,
    lf_xanzsn LIKE risa0-anzahl,
    lf_skip_check.                                          "EHP603

*                                                        delete_n_646208

  cf_rc = 1.

  IF NOT is_lips-xchar IS INITIAL.
    IF is_lips-charg IS INITIAL AND
       is_lips-bwtar IS INITIAL.
      MESSAGE e427 INTO lf_msg.
      RETURN.
    ENDIF.
    IF NOT is_lips-xchpf IS INITIAL AND
       NOT is_lips-bwtex IS INITIAL AND
           is_lips-charg IS INITIAL.
      MESSAGE e189 INTO lf_msg.
      RETURN.
    ENDIF.
*   Lines of notes 646208 and 1500524 deleted                 "n_1536130
  ENDIF.

ENHANCEMENT-POINT EHP603_MV50AF0S_02 SPOTS ES_SAPMV50A.

  IF lf_skip_check IS INITIAL.                              "EHP603
    IF is_lips-werks IS INITIAL.
      MESSAGE e420 INTO lf_msg.
      RETURN.
    ENDIF.
    IF is_lips-serail IS INITIAL.
      MESSAGE e421 WITH is_lips-matnr is_lips-werks INTO lf_msg.
      RETURN.
    ENDIF.
  ENDIF.
  lf_xanzsn = is_lips-lgmng MOD 1.
  IF lf_xanzsn <> 0.
    MESSAGE e426 INTO lf_msg.
    RETURN.
  ENDIF.

  lf_xanzsn = is_lips-lgmng.
  cf_trtyp = if_trtyp.

  IF is_likp-vbeln NE xvbup-vbeln OR
     is_lips-posnr NE xvbup-posnr.

    READ TABLE xvbup WITH KEY mandt = sy-mandt              "v_n_646208
                              vbeln = is_likp-vbeln
                              posnr = is_lips-posnr
                              BINARY SEARCH.

  ENDIF.

*  Serial number changes are not allowed after posting goods movement
*  IF XVBUP-WBSTA = CHARC.                                      "n_654875
  IF XVBUP-WBSTA = CHARC AND LIKPD-MDIFF_BUCH NE CHARX.         "n_1603528
    cf_trtyp = chara.
  ENDIF.                                                    "^_n_646208

  IF cf_trtyp = chara.
    IF is_lips-anzsn = 0 AND is_lips-hupos EQ space. " HUMSER
      MESSAGE e425 WITH lips-posnr INTO lf_msg.
      RETURN.
    ENDIF.
  ELSE.
    IF lf_xanzsn = 0 AND is_lips-hupos EQ space.     " HUMSER
      MESSAGE e425 WITH is_lips-posnr INTO lf_msg.
      RETURN.
    ENDIF.
  ENDIF.
*  No serial number changes are possible in decentralized WMS
  IF is_likp-verursys NE space AND is_likp-vlstk = chara.
    SELECT SINGLE * FROM t340d
                    INTO ls_t340d
                    WHERE lgnum EQ is_likp-lgnum.
    IF ls_t340d-sndec IS INITIAL.
      cf_trtyp = chara.
    ENDIF.
  ENDIF.
*  If this is a HUM item the serialnumbers have to be assigned in the
*  packing dialog
  IF NOT is_lips-hupos IS INITIAL AND if_trtyp CA 'HV' AND
     NOT xvbup-wbsta EQ charc.
    CALL FUNCTION 'SERIAL_PROFILE_READ'
      EXPORTING
        profile_r      = is_lips-serail
        operation_r    = 'HUSL'
      IMPORTING
        t_377          = ls_t377
      EXCEPTIONS
        no_t377p_entry = 1
        no_t377_entry  = 2
        OTHERS         = 3.
    IF sy-subrc IS INITIAL AND ls_t377-serpflicht CA '23'.
      MESSAGE e433 WITH lips-posnr INTO lf_msg.
      RETURN.
    ENDIF.
  ENDIF.

  CLEAR cf_rc.
ENDFORM.                    " serialnumber_checks
*&---------------------------------------------------------------------*
*&      Form  sales_area_shippoint_check (n_606000)
*&---------------------------------------------------------------------*
*       Check consistency of sales area and shipping point (VL01NO)
*----------------------------------------------------------------------*
FORM sales_area_shippoint_check  USING    if_vstel LIKE likp-vstel
                                          if_vkorg LIKE likp-vkorg
                                          if_vtweg LIKE rv50a-vtweg
                                          if_spart LIKE rv50a-spart
                                 CHANGING cf_subrc LIKE sy-subrc.

  DATA: lt_tvswz  TYPE STANDARD TABLE OF tvswz WITH HEADER LINE,
        lf_count  TYPE i,
        lf_msgtxt TYPE c.

* Default: Inconsistent entries
  cf_subrc = 4.

* Read sales area
  PERFORM tvta_select USING if_vkorg
                            if_vtweg
                            if_spart.

* Get assignment between plants and the given shipping point
  SELECT * FROM tvswz
           INTO TABLE lt_tvswz
           WHERE vstel EQ if_vstel.

  IF NOT lt_tvswz[] IS INITIAL.
    SELECT COUNT( * ) FROM tvkwz
                      INTO lf_count
                      FOR ALL ENTRIES IN lt_tvswz
                       WHERE vkorg EQ tvta-vkorg
                         AND vtweg EQ tvta-vtwku
                         AND werks EQ lt_tvswz-werks.    "#EC CI_BYPASS
    IF lf_count GT 0.
*     There is at least one plant assigned to the shipping point that
*     matches the given sales area
      cf_subrc = 0.
    ENDIF.
  ENDIF.
  IF cf_subrc NE 0.
*   Not a single plant assigned to the shipping point is defined in the
*   given sales area: error message because item creation is not
*   possible
    MESSAGE e588 WITH if_vstel INTO lf_msgtxt.
  ENDIF.

ENDFORM.                    " sales_area_shippoint_check
*&---------------------------------------------------------------------*
*&      Form  SN_UPDATE_DEACTIVATION
*&---------------------------------------------------------------------*
*       Take back all serial number updates if items will be deleted
*----------------------------------------------------------------------*

FORM sn_update_deactivation.                                "v_n_637909

  DATA: lf_vorgang TYPE tj01-vrgng,
        lf_status_error,
        ls_lips   TYPE lips.                                "n_933408

* Are there any items for deletion in the delivery?
  READ TABLE xlips WITH KEY vbeln = xlikp-vbeln
                            updkz = updkz_delete.
  CHECK sy-subrc EQ 0.

* Take back all serial number updates for deleted serialized items
  LOOP AT xlips WHERE vbeln  EQ xlikp-vbeln AND
                      anzsn  GT 0           AND
                NOT   serail IS INITIAL     AND
                      updkz  EQ updkz_delete.

    MOVE-CORRESPONDING xlips TO ls_lips.                    "n_933408
    PERFORM sn_status_operation_determine(sapfv50w)
                                  USING    xlikp-vbtyp
                                           tvlk-aufer
                                           ls_lips          "n_933408
                                           charx
                                  CHANGING lf_vorgang.
    CLEAR lf_status_error.
    CALL FUNCTION 'DELETE_SERNR_LS'
      EXPORTING
        vbeln              = xlips-vbeln
        posnr              = xlips-posnr
        j_vorgang          = lf_vorgang
      IMPORTING
        status_not_allowed = lf_status_error.

*... One or more assigned serial numbers cannot be deleted ?!
    IF NOT lf_status_error IS INITIAL.
      MESSAGE a436(vl) WITH xlips-posnr.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " SN_UPDATE_DEACTIVATION          ^_n_637909

*&---------------------------------------------------------------------*
*&      Form  set_lfdat_at_xs073                           "v_n_1072322
*&---------------------------------------------------------------------*
*       Set delivery date in internal table of S073 -> FG V45L
*----------------------------------------------------------------------*
FORM set_lfdat_at_xs073.

  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.

  LOOP AT xlips ASSIGNING <ls_xlips> WHERE vbeln EQ likp-vbeln AND
                                           vgtyp CA vbtyp_lp AND
                                           updkz NE updkz_delete.
    CALL FUNCTION 'SD_DELIVERY_CUMULATIVE_SET_DAT'
      EXPORTING
        if_lfdat_new = likp-lfdat
        if_lfdat_old = *likp-lfdat
        is_xlips     = <ls_xlips>
        is_kuwev     = kuwev
        is_likp      = likp
      .                                            "^_n_1072322
  ENDLOOP.

ENDFORM.