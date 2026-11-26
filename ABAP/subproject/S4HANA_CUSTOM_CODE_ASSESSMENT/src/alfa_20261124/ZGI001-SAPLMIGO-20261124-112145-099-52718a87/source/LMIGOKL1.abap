*----------------------------------------------------------------------*
*   INCLUDE LMIGOKL1 Line operations                                   *
*----------------------------------------------------------------------*

************************************************************************
* Add a line to the internal table or modify it.
* Parameters:
* I_TABIX: Line number (SY-TABIX) in PT_GOITEM
* I_LINE:  Line number visible on screen. Can differ from I_TABIX if
*          preceeding positions have subitems which are collapsed.
* IS_GOITEM: Data
* I_INSERT: ABAP_FALSE: TABIX/LINE = 0 : Append line to the model
*                       TABIX/LINE <> 0: Treat as new position
*                                        (entry mode)
*           ABAP_TRUE:  Insert line before given TABIX/LINE
************************************************************************
METHOD line_modify.
  DATA: ls_old_goitem        TYPE goitem,
        ls_new_goitem        TYPE goitem,
        ls_cobl_goitem       TYPE goitem,
        l_tabix              TYPE sytabix,
        l_change             TYPE abap_bool,
        ls_goserial_kernel   TYPE ty_s_goserial_kernel,
        ls_change_po_elikz   TYPE ty_s_change_po_elikz,
        ls_change_ord_elikz  TYPE ty_s_change_ord_elikz,
        ls_change_res_kzear  TYPE ty_s_change_res_kzear,
        ls_change_batch      TYPE ty_s_change_batch,
        lt_coblfields        TYPE ty_t_fieldname,
        l_coblfields         TYPE migo_fieldname,
        l_lines              TYPE i,
        l_copycobl           TYPE abap_bool,
        l_sc_tabix           TYPE sytabix,
        lv_subrc_500         TYPE sysubrc.

ENHANCEMENT-POINT EHP604_LINE_MODIFY_05 SPOTS ES_SAPLMIGO STATIC .

  FIELD-SYMBOLS: <ls_goitem>      TYPE goitem,
                 <it_gofreight>   TYPE gofreight,
                 <ls_new_goitem>  TYPE ANY,
                 <ls_cobl_goitem> TYPE ANY.
* Convert external number to internal number
  l_tabix = i_tabix.
  IF l_tabix IS INITIAL.
    CALL METHOD line_mapping
      EXPORTING
        i_line  = i_line
      IMPORTING
        e_tabix = l_tabix.
  ENDIF.

* Read line to be modified. If not present, l_old_line is initial.
  IF l_tabix <> 0 AND i_insert = abap_false.
    READ TABLE pt_goitem INTO ls_old_goitem INDEX l_tabix.
    IF sy-subrc <> 0.
*     New line to be inserted. Check whether some fields have changed
*     with respect to the default values.  To do this, we
*     fill L_OLD_LINE with the default value set and set L_TABIX to
*     zero so that the line is inserted.
*     IF the only thing that has changed is the TAKE_IT-indicator,
*     this is not considered as a change.
      ls_old_goitem = default_line_get( ).
*     UMSOK was derived from T156B. This field should never be used to
*     compare old and new GOITEM, because it was not entered manually.
*     Same logic for special stock texts.
      ls_old_goitem-umsok   = cs_goitem-umsok.
      ls_old_goitem-sotxt   = cs_goitem-sotxt.
      ls_old_goitem-umsotxt = cs_goitem-umsotxt.
      ls_new_goitem = cs_goitem.
      CLEAR: ls_old_goitem-take_it, ls_new_goitem-take_it.
      CHECK ls_old_goitem <> ls_new_goitem.
*     If survived, the data in CS_GOITEM are significant to be appended
*     Mark as manual position
      cs_goitem-xmanu = abap_true.
      l_tabix = 0.
    ENDIF.
  ENDIF.
* No component exist anymore after batch determination
  IF s_action-migo_mode = 'GS' AND i_insert = abap_true.
    ls_old_goitem-sc_adjust = cs_goitem-sc_adjust.
  ENDIF.
ENHANCEMENT-POINT line_modify_04 SPOTS es_saplmigo.
* Only, if something has changed
  IF cs_goitem <> ls_old_goitem OR i_force_change = abap_true.
    ls_new_goitem = cs_goitem.
ENHANCEMENT-POINT line_modify_02 SPOTS es_saplmigo STATIC.

ENHANCEMENT-POINT line_modify_03 SPOTS es_saplmigo.
*   Append/modify
    IF l_tabix = 0 OR i_insert = abap_true.
*     Execute authority check when adding a new line.
*     If not successful, the line is not added.
*     A caller can find this out by checking e.g. GLOBAL_COUNTER.
      IF i_authority_check = abap_true.
        CHECK line_add_authority_check( ls_new_goitem ) = abap_true.
      ENDIF.
*     Global counter always new, if not set by external (read material
*     document)
      IF ls_new_goitem-global_counter IS INITIAL.
        ADD 1 TO p_line_id.
        ls_new_goitem-global_counter = p_line_id.
      ENDIF.
*     New "ZEILE" only if not filled by caller
      IF ls_new_goitem-zeile IS INITIAL.
        ADD 1 TO s_status-max_zeile.
        ls_new_goitem-zeile          = s_status-max_zeile.
      ENDIF.
*     Create a new entry in the fieldselectoin table
*     copying the current template set
      CALL METHOD lcl_migo_screenmodification=>template_copy
        EXPORTING
          i_global_counter = ls_new_goitem-global_counter.
*     Checks on the item level
      CALL METHOD line_check
        EXPORTING
          is_old_goitem = ls_old_goitem
        CHANGING
          cs_goitem     = ls_new_goitem.
*     BAdI: line modify
      CALL METHOD line_modify_badi
        CHANGING
          cs_goitem = ls_new_goitem.
*     BAdI MB_MIGO_ITEM_BAdI: method ITEM_MODIFY
      CALL METHOD line_modify_badi2
        CHANGING
          cs_goitem = ls_new_goitem.

*     If certain criterias are met -> copy COBL fields to next item
      IF s_defaults-xkto       = abap_true   AND
          s_control-action     = 'A07'       AND
          s_control-refdoc     = 'R10'       AND
          s_control-vgart      = 'WA'        AND
          ls_new_goitem-zeile <> 1.
*       checks for copying of the COBL fields
        IF i_insert = abap_false.
          DESCRIBE TABLE pt_goitem LINES l_lines.
        ELSE.
          l_lines = l_tabix - 1.
        ENDIF.
        READ TABLE pt_goitem INDEX l_lines INTO ls_cobl_goitem.
        IF sy-subrc = 0.
          CALL METHOD cl_mmim_migo_move_fields=>get_cobl_fields
            EXPORTING
              i_bwart      = ls_new_goitem-bwart
              i_with_konto = abap_true
            IMPORTING
              et_fields    = lt_coblfields.
*         if one of the cobl fields has been filled for the new item
*         -> do not copy the cobl fields from the previousw item
          l_copycobl = abap_true.
          LOOP AT lt_coblfields INTO l_coblfields.
            ASSIGN COMPONENT l_coblfields OF STRUCTURE
                  ls_new_goitem TO <ls_cobl_goitem>.
            IF NOT <ls_cobl_goitem> IS INITIAL.
              l_copycobl = abap_false.
              EXIT.
            ENDIF.
          ENDLOOP.
          IF l_copycobl = abap_true.
            LOOP AT lt_coblfields INTO l_coblfields.
              CALL FUNCTION 'MIGO_CUST_FIELD_ALLOWED'
                EXPORTING
                  i_bwart     = ls_new_goitem-bwart
                  i_field     = l_coblfields
                EXCEPTIONS
                  not_allowed = 1
                  OTHERS      = 2.
              IF sy-subrc = 0.
                ASSIGN COMPONENT l_coblfields OF STRUCTURE
                      ls_cobl_goitem TO <ls_cobl_goitem>.
                ASSIGN COMPONENT l_coblfields OF STRUCTURE
                      ls_new_goitem TO <ls_new_goitem>.
                IF <ls_new_goitem> = abap_false.
                  <ls_new_goitem> = <ls_cobl_goitem>.
                ENDIF.
              ENDIF.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.                           " Copy cobl fields

      IF i_insert = abap_false.
        APPEND ls_new_goitem TO pt_goitem.
      ELSE.
        INSERT ls_new_goitem INTO pt_goitem INDEX l_tabix.
      ENDIF.

*   expand subcontracting items in case derivation for PO is
*   activated and header line requires batch         "1485885
    CALL FUNCTION 'VBDRV_EVENT_ACTIVE_CHECK'         "1485885
      EXPORTING
        i_event              = '500'
      EXCEPTIONS
        not_active           = 1
        not_active_for_event = 2
        OTHERS               = 3.

      lv_subrc_500         = sy-subrc.

      IF ls_new_goitem-expand = C_ICON_EXPAND and     "1485885
        lv_subrc_500          = 0             and
        ls_new_goitem-xchpf   = abap_true     and
        ls_new_goitem-PSTYP   = '3'           and
        s_action-display      = abap_false.
        l_sc_tabix = LS_NEW_GOITEM-global_counter.
        CALL METHOD line_expand( l_sc_tabix ).
      ENDIF.
    ELSE.                              "l_tabix <> 0
*     Checks on the item level.
*     Now you may believe that these two calls to LINE_CHECK
*     could have been done before the separation into INSERT and
*     MODIFY. Wrong! a) Some things in LINE_CHECK need the
*     GLC, b) The fieldselection needs the GLC.
      CALL METHOD line_check
        EXPORTING
          is_old_goitem = ls_old_goitem
        CHANGING
          cs_goitem     = ls_new_goitem.
ENHANCEMENT-POINT line_modify_01 SPOTS es_saplmigo.
*     Tied empties
      IF NOT ls_new_goitem-xvgtype IS INITIAL.
        CALL METHOD vg_line_modify
          EXPORTING
            is_old_goitem = ls_old_goitem
          CHANGING
            cs_goitem     = ls_new_goitem.
      ENDIF.
*     Subcontracting
      IF ls_new_goitem-expand = c_icon_expand
         AND ls_new_goitem-xlbtype = P
         AND ls_new_goitem-xco_order IS INITIAL
         AND ls_old_goitem-erfmg <> ls_new_goitem-erfmg.
        DELETE pt_goitem WHERE parent = ls_new_goitem-global_counter.
      ENDIF.
*     BAdI: line_modify
      CALL METHOD line_modify_badi
        CHANGING
          cs_goitem = ls_new_goitem.
*     BAdI MB_MIGO_ITEM_BAdI: method ITEM_MODIFY
      CALL METHOD line_modify_badi2
        CHANGING
          cs_goitem = ls_new_goitem.
      MODIFY pt_goitem FROM ls_new_goitem INDEX l_tabix.
    ENDIF.
*   Quantity of  a generic article has to be equal the total of its
*   variants
    IF NOT ls_new_goitem-xgatype IS INITIAL.
      CALL METHOD ga_line_modify
        EXPORTING
          is_old_goitem = ls_old_goitem
          is_new_goitem = ls_new_goitem.
    ENDIF.
*   Cross Docking
    IF NOT ls_new_goitem-xcdtype IS INITIAL
      AND i_line > 0.
      CALL METHOD cd_lgort_distribution_get
        CHANGING
          cs_goitem = ls_new_goitem.
    ENDIF.
*   Value added services
    IF NOT ls_new_goitem-xvastype IS INITIAL.
      CALL METHOD vas_line_modify
        EXPORTING
          is_old_goitem = ls_old_goitem
          is_new_goitem = ls_new_goitem.
    ENDIF.
*   If a structured article has been changed explode the bom again
    IF NOT ls_new_goitem-xsttype IS INITIAL AND
           ls_new_goitem-xsttype <> c.
      CALL METHOD st_line_modify
        EXPORTING
          is_new_goitem = ls_new_goitem
          is_old_goitem = ls_old_goitem.
    ENDIF.
* begin Outsourced Manufacturing EhP 4
    IF NOT ls_new_goitem-xco_order IS INITIAL.
      CALL METHOD sc_line_modify
        EXPORTING
          is_new_goitem = ls_new_goitem
          is_old_goitem = ls_old_goitem.
    ENDIF.
* end Outsourced Manufacturing EhP 4
*   Derive new status data if necessary.
*   The DELAYED flag is set by the routines which enter a lot of data
*   with LINE_MODIFY (e.g. purchase order read). These routines are
*   supposed to call STATUS_DERIVE themself.
    IF i_status_delayed = abap_false.
      CALL METHOD status_derive.
    ENDIF.
    cs_goitem = ls_new_goitem.
  ENDIF.                               " IF cs_goitem <> ls_old_goitem.

* The following will be changed soon! Please be patient...______________
*   units of messure: quantities have changed ???
*   KZWSM a ---> menge can be changed in classification and
*   therefore we have to take it as well in that case.
*   No unit_conversion should be done for action cancel or
*   display. Probably conversion factors have changed in the
*   meanwhile, but we want to have the former once ?
*  IF NOT cs_goitem-kzwsm IS INITIAL AND
*     NOT ( s_action-display = abap_true OR
*           s_action-cancel = abap_true ).
**   You may expect a statement like: IF ls_new_goitem-menge <>
**   ls_goitem-menge here, but this is not possible, because
**   quantity might have been changed during classification as
**   well for materials with kzwsm = a. In that case ls_new_
**   goitem-menge is still equal to the former menge.
**   If you insert a statement like that here, please note that
**   you have to call the change_later in that case in method
**   batch_maintain.
*    ls_change_batch-charg = cs_goitem-charg.
*    ls_change_batch-matnr = cs_goitem-matnr.
*    ls_change_batch-werks = cs_goitem-werks.
*    CALL METHOD change_quantity_later
*        EXPORTING is_change_batch = ls_change_batch.
*  ENDIF.
*____end of will be changed soon_________________________________
* changing dependent tables like serial numbers e.g.
  IF i_dependent_tables = abap_true.
*   I.) Serial numbers:
*       Clear pt_goserial_kernel-t_goserial, if the material number
*       is changed / plant is changed to not serial number managed.
    ls_goserial_kernel-global_counter = cs_goitem-global_counter.
    ls_goserial_kernel-t_goserial     = it_goserial.
    IF cs_goitem-sernp IS INITIAL.
      CLEAR ls_goserial_kernel-t_goserial.
    ENDIF.
    MODIFY TABLE pt_goserial_kernel FROM ls_goserial_kernel.
    IF sy-subrc <> 0.
      INSERT ls_goserial_kernel INTO TABLE pt_goserial_kernel.
    ENDIF.
*   II.) Freight vendors:
*        For freight table there is no refresh necessary, because
*        purchase order / po item can not be changed.
    LOOP AT it_gofreight ASSIGNING <it_gofreight>.
      MODIFY pt_gofreight_kernel FROM <it_gofreight>
           TRANSPORTING kschl vtext lifnr vendorname
                        freight_line zaehk stunr
           WHERE ebeln = <it_gofreight>-ebeln
           AND   ebelp = <it_gofreight>-ebelp
           AND   zaehk = <it_gofreight>-zaehk
           AND   stunr = <it_gofreight>-stunr.
    ENDLOOP.
  ENDIF.

ENHANCEMENT-POINT EHP604_LINE_MODIFY_06 SPOTS ES_SAPLMIGO.

  CHECK NOT lcl_migo_globals=>if_badi IS INITIAL.           "733818
  CALL METHOD lcl_migo_globals=>if_badi->publish_material_item
    EXPORTING
      ls_goitem = ls_new_goitem.

ENDMETHOD.                    "line_modify

************************************************************************
* Return a requested line
************************************************************************
METHOD line_get.
  DATA: l_tabix TYPE sytabix.
  FIELD-SYMBOLS: <ls_goserial_kernel>  TYPE ty_s_goserial_kernel,
                 <ls_gofreight>        TYPE ty_s_gofreight.

  DATA cl_change TYPE REF TO /sappspro/cl_numbers.
  DATA lf_active TYPE boolean.

* Line mapping
  l_tabix = i_tabix.
  IF l_tabix IS INITIAL.
    CALL METHOD line_mapping
      EXPORTING
        i_line  = i_line
      IMPORTING
        e_tabix = l_tabix.
  ENDIF.
* Read line
  READ TABLE pt_goitem INTO es_goitem INDEX l_tabix.
  IF sy-subrc <> 0.
*   Requested non existing line: Send a line containing only default
*   values (so that the defaults are already filled in the viewers).
    CLEAR: es_goitem,
           et_goserial,
           et_gofreight.
    es_goitem = default_line_get( ).
    EXIT.
  ENDIF.

* convert field ebeln to external format and put it in longnum
  CLEAR: lf_active.
  CREATE OBJECT cl_change.

  CALL METHOD cl_change->is_active
    RECEIVING
      rv_active = lf_active.

  IF lf_active = 'X'.
    TRY.
        goitem-longnum = /sappspro/cl_numbers=>lookup( goitem-ebeln ).
      CATCH /sappspro/cx_number_not_found.
*             number does not exist.
    ENDTRY.
  ENDIF.

*   Reading data for dependent tables
  IF i_dependent_tables = abap_true.
*     Serial number table for current item
    CLEAR et_goserial.
    READ TABLE pt_goserial_kernel ASSIGNING <ls_goserial_kernel>
           WITH TABLE KEY global_counter = es_goitem-global_counter.
    IF sy-subrc = 0.
      et_goserial = <ls_goserial_kernel>-t_goserial.
    ENDIF.
*     Freight vendor table for current item
    IF NOT es_goitem-ebeln IS INITIAL AND
       NOT es_goitem-ebelp IS INITIAL.
      CLEAR et_gofreight.
      LOOP AT pt_gofreight_kernel ASSIGNING <ls_gofreight>
                                  WHERE ebeln = es_goitem-ebeln
                                    AND ebelp = es_goitem-ebelp.
        APPEND <ls_gofreight> TO et_gofreight.
      ENDLOOP.
    ENDIF.
  ENDIF.                               " if dependent_tables = abap_true
ENDMETHOD.                    "line_get

************************************************************************
* Delete a line in the model. If the line has children, delete
* them recursively.
* Exceptions:
************************************************************************
METHOD line_delete.
  DATA: l_tabix     TYPE sytabix,
        ls_goitem   TYPE goitem,
        l_nestlevel TYPE sytabix.
  FIELD-SYMBOLS: <ls_goitem> TYPE goitem.

* Line mapping
  l_tabix = i_tabix.
  IF l_tabix IS INITIAL.
    CALL METHOD line_mapping
      EXPORTING
        i_line  = i_line
      IMPORTING
        e_tabix = l_tabix.
  ENDIF.
* Read the line
  READ TABLE pt_goitem INTO ls_goitem INDEX l_tabix.
  CHECK sy-subrc = 0.
* send message to viewer, so that they save their current-line
  IF i_no_messages = abap_false AND i_nestlevel = 0.
    def_sms 'MODEL_CHANGE_BEGIN' space space.
  ENDIF.
* Loop over all children
  LOOP AT pt_goitem ASSIGNING <ls_goitem>
                    WHERE parent = ls_goitem-global_counter.
    l_nestlevel = i_nestlevel + 1.
*   Caution: Using SY-TABIX directly is only permitted because
*   I_TABIX is used "BY VALUE" (note 381320).
    CALL METHOD line_delete
      EXPORTING
        i_tabix       = sy-tabix
        i_nestlevel   = l_nestlevel
        i_no_messages = i_no_messages.
  ENDLOOP.
* Mark the current line as to be deleted and delete the fieldselection
* table immedeately.
  CALL METHOD lcl_migo_screenmodification=>delete_item
    EXPORTING
      i_global_counter = ls_goitem-global_counter.
* BAdI: Delete line
  IF NOT lcl_migo_globals=>if_badi IS INITIAL.
    CALL METHOD lcl_migo_globals=>if_badi->line_delete
      EXPORTING
        i_line_id = ls_goitem-global_counter.
  ENDIF.
* delete buffer business process for documentary batch
  CALL METHOD oref_detail_doc_batch->doc_batch_item_delete(
    ls_goitem-global_counter ).
* delete item from pt_goitem
  CLEAR ls_goitem-global_counter.
  MODIFY pt_goitem FROM ls_goitem INDEX l_tabix
                   TRANSPORTING global_counter.
* If this is the end of nestlevel 0, delete the entries physically.
* Status derive is called immedeately to ensure a correct mapping table
  IF i_nestlevel = 0.
    DELETE pt_goitem WHERE global_counter IS INITIAL.
    CALL METHOD status_derive.
  ENDIF.
* send message to viewer, so that they get back their current-line
  IF i_no_messages = abap_false AND i_nestlevel = 0.
    def_sms 'MODEL_CHANGE_COMPLETE' space space.
  ENDIF.
ENDMETHOD.                    "line_delete

************************************************************************
* Return a line containing prefilled default values.
* If the NewLineMode is inactive, deliver an empty line.
************************************************************************
METHOD default_line_get.
  DATA: ls_goplant TYPE goplant,
        ls_goitem  TYPE goitem.                             "710988
  CHECK s_control-new_line_mode <> space.
  MOVE-CORRESPONDING s_defaults TO rs_goitem.
  MOVE-CORRESPONDING s_defaults TO ls_goitem.               "710988
  rs_goitem-migo_insmk = s_defaults-insmk.
  CALL METHOD lcl_migo_buffer=>plant_get
    EXPORTING
      i_plant   = rs_goitem-werks
    RECEIVING
      e_goplant = ls_goplant
    EXCEPTIONS
      OTHERS    = 1.
  IF sy-subrc = 0.
    rs_goitem-name1 = ls_goplant-name1.
    rs_goitem-waers = ls_goplant-waers.
  ENDIF.
  rs_goitem-lgobe =
         lcl_migo_buffer=>sloc_name_get( i_werks = rs_goitem-werks
                                        i_lgort = rs_goitem-lgort ).
  CALL METHOD lcl_migo_buffer=>move_type_text_get
    EXPORTING
      i_move       = rs_goitem-bwart
      i_spec_stock = rs_goitem-sobkz
    RECEIVING
      e_move_text  = rs_goitem-btext
    EXCEPTIONS
      OTHERS       = 1.
  CALL METHOD lcl_migo_globals=>kernel->umsok_get           "710988
    EXPORTING                                               "710988
     i_error_type = 'S'                                     "710988
    CHANGING                                                "710988
     c_sobkz      = ls_goitem-sobkz                         "710988
     cs_goitem    = ls_goitem.                              "710988
  rs_goitem-umsok = ls_goitem-umsok.                        "710988
  rs_goitem-take_it = abap_true.
ENDMETHOD.                    "default_line_get

************************************************************************
* Checks for automatic lines:
* - Is the position a new line with subitems?
* - Was it one before and is not longer?
* - Any change which affects the subcomponents?
************************************************************************
METHOD line_check_automatic_lines.
* Line type for subitems: Line is new as subcontracting line
  IF cs_goitem-pstyp = '3'.
    cs_goitem-xlbtype = p.
    IF cs_goitem-expand IS INITIAL.
      cs_goitem-expand  = c_icon_expand.
    ENDIF.
  ENDIF.
* In case of subcontracting the expand button should not be
* visible during 103/109 movement.                              "1110140
  IF cs_goitem-pstyp = '3' AND cs_goitem-kzwes = s
     AND cs_goitem-expand <> c_icon_collapse
     AND NOT cs_goitem-bustr = '107'.                           "1110140
    CLEAR cs_goitem-expand.
  ENDIF.
  IF cs_goitem-pstyp = '3' AND cs_goitem-kzwes = x              "1110140
     AND cs_goitem-bustr = '109'.                               "1110140
    CLEAR cs_goitem-expand.                                     "1110140
  ENDIF.                                                        "1110140
ENHANCEMENT-POINT lmigokl1_01 SPOTS es_saplmigo.

* full product; <LG>
  IF is_old_goitem-xvgtype <> p AND cs_goitem-xvgtype = p
    OR ( is_old_goitem-xvgtype = p AND
         is_old_goitem-erfme <> cs_goitem-erfme ).
    cs_goitem-expand  = c_icon_expand.
  ENDIF.
* generic articles
  IF is_old_goitem-xgatype <> p AND cs_goitem-xgatype = p.
    cs_goitem-expand  = c_icon_expand.
  ENDIF.
* structured articles
  IF ( cs_goitem-xsttype = '10'        OR
       cs_goitem-xsttype = '11'        OR
       cs_goitem-xsttype = '12' )      AND
*      no expand button in case of structured articles together
*      with cross docking
       cs_goitem-xcdtype IS INITIAL    AND
       cs_goitem-parent  IS INITIAL    AND
       cs_goitem-xchpf   IS INITIAL.

    IF ( is_old_goitem-xsttype <> '10'   AND
         is_old_goitem-xsttype <> '11'   AND
         is_old_goitem-xsttype <> '12' ) AND
         cs_goitem-migo_insmk = abap_false.
      cs_goitem-expand  = c_icon_expand.
    ELSE.
*     expand button only if stock type = unrestricted use
      IF cs_goitem-migo_insmk <> abap_false.
        CLEAR cs_goitem-expand.
*     if article has not been expanded and stock type changed
*     again to unrestricted use display expand button
      ELSEIF cs_goitem-migo_insmk <> is_old_goitem-migo_insmk.
        cs_goitem-expand  = c_icon_expand.
      ENDIF.
    ENDIF.
  ENDIF.

  IF is_old_goitem-xvastype <> p AND cs_goitem-xvastype = p.
    cs_goitem-expand = c_icon_expand.
    CALL METHOD vas_relevance_check
      CHANGING
        cs_goitem = cs_goitem.
  ENDIF.
ENDMETHOD.                    "line_check_automatic_lines

************************************************************************
* Central mapping routine between the different ways to identify
* a line in the model.
* Feed in any single known information and the method will return
* the full set of data.
************************************************************************
METHOD line_mapping.
  DATA: l_tabix          TYPE sytabix,
        ls_line_mapping  TYPE ty_s_line_mapping,
        ls_goitem        TYPE goitem,
        l_lines          TYPE sytabix.

* Start fresh
  CLEAR: e_zeile, e_tabix, e_global_counter, e_line.
* If ZEILE given, get the first line in model with this ZEILE
  IF NOT i_zeile IS INITIAL.
    READ TABLE pt_goitem
               WITH KEY zeile = i_zeile
               TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      RAISE not_found.
    ENDIF.
    l_tabix = sy-tabix.
  ENDIF.
* If LINE given, use mapping table.
* If no hit, return a TABIX which
* exaggerates the maximum TABIX by as much as I_LINE is bigger than
* the maximum LINE. This special function is needed by entering new
* positions. Imagine you have a subcontracting PO with one component
* (collapsed) in the model. Now you enter a new position. The viewers
* will ask the kernel for LINE = 2 (as the screen only shows one line).
* We have to return TABIX = 3, as TABIX = 2 is occupied by the
* component.
  IF NOT i_line IS INITIAL.
    READ TABLE pt_line_mapping INTO ls_line_mapping
               WITH TABLE KEY line = i_line.
    IF sy-subrc <> 0.
      DESCRIBE TABLE pt_line_mapping LINES l_lines.
      e_tabix = i_line - l_lines + s_status-max_tabix.
      e_line  = i_line.
      EXIT.
    ENDIF.
    l_tabix = ls_line_mapping-tabix.
  ENDIF.
* If GLC given, determine tabix
  IF NOT i_global_counter IS INITIAL.
    READ TABLE pt_goitem
               WITH TABLE KEY global_counter = i_global_counter
               TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      RAISE not_found.
    ENDIF.
    l_tabix = sy-tabix.
  ENDIF.
* If TABIX given, use it
  IF NOT i_tabix IS INITIAL.
    l_tabix = i_tabix.
  ENDIF.
* Now we read the model and provide the requested information
  IF e_global_counter IS REQUESTED OR
     e_zeile          IS REQUESTED.
    READ TABLE pt_goitem INTO ls_goitem INDEX l_tabix
               TRANSPORTING zeile global_counter.
    IF sy-subrc <> 0.
      RAISE not_found.
    ENDIF.
    e_global_counter = ls_goitem-global_counter.
    e_zeile          = ls_goitem-zeile.
  ENDIF.
  IF e_line IS REQUESTED.
    READ TABLE pt_line_mapping INTO ls_line_mapping
               WITH KEY tabix = l_tabix.
    IF sy-subrc <> 0.
      RAISE not_found.
    ENDIF.
    e_line = ls_line_mapping-line.
  ENDIF.
  e_tabix = l_tabix.
ENDMETHOD.                    "line_mapping