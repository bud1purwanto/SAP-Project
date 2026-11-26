*----------------------------------------------------------------------*
*   INCLUDE LMIGOKL2                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Expand or collapse a line.
* This routine is called from outside and handles the messages to
* the viewers and the line number mapping.
************************************************************************
METHOD line_expand_collapse.
  DATA: l_tabix   TYPE sytabix,
        ls_goitem TYPE goitem.
  def_sms 'MODEL_CHANGE_BEGIN' space space.
* Line mapping
  CALL METHOD line_mapping
    EXPORTING
      i_line  = i_line
    IMPORTING
      e_tabix = l_tabix.
* Read line
  CALL METHOD line_get
    EXPORTING
      i_tabix   = l_tabix
    IMPORTING
      es_goitem = ls_goitem.
* Collapse a line recursively
  IF ls_goitem-expand = c_icon_collapse.
    CALL METHOD line_collapse( l_tabix ).
  ELSE.
* Expand node
    CALL METHOD line_expand
      EXPORTING
        i_tabix  = l_tabix
        i_okcode = i_okcode.
  ENDIF.
* Status derivation (mapping table!)
  CALL METHOD status_derive.
* Model change complete.
  def_sms 'MODEL_CHANGE_COMPLETE' space space.
ENDMETHOD.                    "line_expand_collapse

************************************************************************
* Collapse a line and all subitems
************************************************************************
METHOD line_collapse.
  FIELD-SYMBOLS: <ls_goitem> TYPE goitem.
  READ TABLE pt_goitem ASSIGNING <ls_goitem> INDEX i_tabix.
  CHECK sy-subrc = 0.
* Set the current line to "collapsed" if currently open
  IF <ls_goitem>-expand = c_icon_collapse.
    <ls_goitem>-expand = c_icon_expand.
    IF <ls_goitem>-xvastype = p OR <ls_goitem>-xvgtype = p.
      CALL METHOD screen_modify_line( <ls_goitem> ).
    ENDIF.
  ENDIF.
* Loop over all children, make them invisible, and if they are
* parents themself, recurse.
ENHANCEMENT-SECTION     line_collapse_01 SPOTS es_saplmigo.
  LOOP AT pt_goitem ASSIGNING <ls_goitem>
                    WHERE parent = <ls_goitem>-global_counter
*                      AND xlbtype <> space.      " Note 1624720
                      AND ( xlbtype <> space OR xvgtype <> space OR xsttype <> space OR xgatype <> space ).     "Note 164720
    <ls_goitem>-invisible = abap_true.
    IF <ls_goitem>-expand <> space.
*     Caution: Using SY-TABIX directly is only permitted because
*     I_TABIX is used "BY VALUE" (note 381320).
      CALL METHOD line_collapse
        EXPORTING
          i_tabix = sy-tabix.
    ENDIF.
  ENDLOOP.
END-ENHANCEMENT-SECTION.

ENDMETHOD.                    "line_collapse

************************************************************************
* Expand a line (internal use only)
************************************************************************
METHOD line_expand.
  FIELD-SYMBOLS: <ls_goitem_top>   TYPE goitem,
                 <ls_goitem_child> TYPE goitem.
  DATA:          l_lines_old       TYPE sytabix,
                 l_lines_new       TYPE sytabix,
                 l_clear_struct    TYPE abap_bool.
  READ TABLE pt_goitem ASSIGNING <ls_goitem_top> INDEX i_tabix.
  CHECK sy-subrc = 0.
* Set top level icon to "expanded"
  <ls_goitem_top>-expand = c_icon_collapse.
* Check for children.
ENHANCEMENT-SECTION     line_expand_01 SPOTS es_saplmigo.
  LOOP AT pt_goitem ASSIGNING <ls_goitem_child>
                   WHERE parent = <ls_goitem_top>-global_counter
*                     AND xlbtype <> space.     "Note 1624720
                     AND ( xlbtype <> space OR xvgtype <> space OR xsttype <> space OR xgatype <> space ).      "Note 1624720
    CLEAR <ls_goitem_child>-invisible.
  ENDLOOP.
END-ENHANCEMENT-SECTION.
* If no children, expand the line by reading the components
  IF sy-subrc <> 0.
    DESCRIBE TABLE pt_goitem LINES l_lines_old.
    IF <ls_goitem_top>-pstyp = '3'.
      CALL METHOD line_expand_subcontracting( i_tabix ).
    ELSEIF i_okcode = 'MIGO_OK_EXPAND_BOM'
      AND <ls_goitem_top>-xvgtype IS INITIAL.
* expand BOM
      CALL METHOD line_expand_bom( i_tabix ).
    ELSEIF <ls_goitem_top>-xvgtype = p.
* Corrections of Note 1350454 reverted using Note 1624720
*Start of correction for NOTE: 1350454
* expand <LG>
      CALL METHOD line_expand_full_product
        EXPORTING
          i_tabix     = i_tabix
          i_invisible = space.
*     message i073(migo) with <ls_goitem_top>-matnr.
*END of correction for NOTE: 1350454
* generic article
    ELSEIF <ls_goitem_top>-xgatype = p.
      CALL METHOD ga_variants_edit
        EXPORTING
          i_line    = i_tabix
          is_goitem = <ls_goitem_top>.
* structured article
    ELSEIF <ls_goitem_top>-xsttype = '10' OR
           <ls_goitem_top>-xsttype = '11' OR
           <ls_goitem_top>-xsttype = '12'.
* in case of stocktype <> unrestricted use delete the expand button
      IF <ls_goitem_top>-migo_insmk = abap_false.
        CALL METHOD line_expand_structured_article( i_tabix ).
      ELSE.
        CLEAR <ls_goitem_top>-expand.
        l_clear_struct = abap_true.
      ENDIF.
    ENDIF.
    DESCRIBE TABLE pt_goitem LINES l_lines_new.
*   If no new lines could be inserted, issue message and reset the
*   icon in the top line.
    IF l_lines_old = l_lines_new.
      MESSAGE s023.
      IF i_okcode = 'MIGO_OK_EXPAND_BOM'.
        CLEAR <ls_goitem_top>-expand.
      ELSE.
        IF l_clear_struct = abap_false.
          <ls_goitem_top>-expand = c_icon_expand.
        ENDIF.
      ENDIF.
    ELSEIF i_okcode = 'MIGO_OK_EXPAND_BOM'.
      <ls_goitem_top>-xbomtype = p.
    ENDIF.
  ENDIF.
* Screen modification for this line to react on XBOMTYPE = P -->
* all fields input only.
  CALL METHOD screen_modify_line( <ls_goitem_top> ).
  CALL METHOD screen_modify_transfer_fields( <ls_goitem_top> ).
ENDMETHOD.                    "line_expand

************************************************************************
* Expand a subcontracting line
************************************************************************
METHOD line_expand_subcontracting.
  DATA: lt_mdvw TYPE STANDARD TABLE OF mdvw,
        ls_mdvw TYPE mdvw,
        ls_goitem_top  TYPE goitem,
        ls_goitem_comp TYPE goitem,
        l_current_tabix TYPE sytabix,
        l_fcode TYPE fcode.

  DATA: l_sum_we TYPE bstmg,
        l_act_we TYPE bstmg.

ENHANCEMENT-POINT LINE_EXPAND_SUBCON_01 SPOTS ES_SAPLMIGO STATIC .

* Read the line to be expanded
  CALL METHOD line_get
    EXPORTING
      i_tabix   = i_tabix
    IMPORTING
      es_goitem = ls_goitem_top.

* Goods receipt quantity in order unit
  l_act_we = ls_goitem_top-bstmg.
* Sum of all goods receipts until now: This calculation is only
* a weak replacement of the XEKPO lock table, but this is not
* feasibly in MIGO. A COLLECT for all positions with the same
* EBELN and EBELP also does not work.
  l_sum_we = ls_goitem_top-wemng + l_act_we.
* Latest info from G. Fuchs: SUMWE not longer necessary, as the
* function module buffers the quantities internally. Not so
* good for us. We need a refresh.
* Well, here it is...
  CALL FUNCTION 'ME_REFRESH_COMP_GOODS_MOVEMENT'.
* Now the quantity proposal will be the same again and again. This
* is documented and no system error.
  CALL FUNCTION 'ME_READ_COMP_GOODS_RECEIPT'
    EXPORTING
      aktwe         = l_act_we
      ebeln         = ls_goitem_top-ebeln
      ebelp         = ls_goitem_top-ebelp
      lfbnr         = ls_goitem_top-lfbnr
      lfgja         = ls_goitem_top-lfbja
      lfpos         = ls_goitem_top-lfpos
      shkzg         = ls_goitem_top-shkzg
      sumwe         = l_sum_we
      kzbew         = ls_goitem_top-kzbew
    TABLES
      t_bbefu       = lt_mdvw
    EXCEPTIONS
      not_found_any = 01
      not_found_one = 02
      not_valid_any = 03
      not_valid_one = 04.
  IF sy-subrc <> 0.
    sy-subrc = sy-subrc.
  ENDIF.
* Insertion position
  l_current_tabix = i_tabix.
* Insert lines
  LOOP AT lt_mdvw INTO ls_mdvw WHERE NOT matnr IS INITIAL.
ENHANCEMENT-POINT EHP604_LINE_EXPAND_SUBCON_01 SPOTS ES_SAPLMIGO.
*   Normal goods isuues. Delete LGPRO and set SOBKZ
    IF ls_mdvw-sobkz IS INITIAL.
      ls_mdvw-sobkz = o.
      CLEAR ls_mdvw-lgpro.
    ENDIF.
    CLEAR ls_goitem_comp.
*   Business data
    MOVE-CORRESPONDING ls_mdvw TO ls_goitem_comp.
    MOVE-CORRESPONDING ls_goitem_top-group_cobl TO ls_goitem_comp.
    ls_goitem_comp-take_it = ls_goitem_top-take_it.
    ls_goitem_comp-lgort   = ls_mdvw-lgpro.
    ls_goitem_comp-wamme   = ls_mdvw-erfme.
*   I will never understand the need for ugly things like
*   sign encrypted in letters.
*   In case of subsequent adjustment the default for the movement types
*   for the components should be equal to the 101 movements. But 121 has
*   a different debit-/credit indicator. The default should be the same
*   movement type like in MB04 with a positive entered quantity.
    IF ls_goitem_top-shkzg = h AND ls_goitem_top-kzbew <> o.
      IF ls_goitem_comp-shkzg = h.
        l_fcode = 'LBWS'.
      ELSE.
        l_fcode = 'LBNS'.
      ENDIF.
    ELSE.
      IF ls_goitem_comp-shkzg = h.
        l_fcode = 'LBWA'.
      ELSE.
        l_fcode = 'LBNA'.
      ENDIF.
    ENDIF.

* fill fields for special stock indicator subscreens:
* in case of sobkz E and Q the ordered material will as
* well be receipted in the corresponding special stock.
* Therefore we have to fill the mat_kdauf and mat_pspnr from
* the corresponding mat_-fields of the top item.
* In case of supplier and customer, the mat_-fields of the
* top line are not filled, because only the issue items are
* with special stock indicator.
    ls_goitem_comp-mat_kdauf = ls_goitem_top-mat_kdauf.
    ls_goitem_comp-mat_kdpos = ls_goitem_top-mat_kdpos.
    ls_goitem_comp-mat_pspnr = ls_goitem_top-mat_pspnr.
* in case of account assignment with special stock q and e, the fields
* kdauf and ps_psp_pnr are cleared after we have read the PO. As the
* following source assumes that the fields are already filled, we have
* to fill the fields by the corresponding mat_-fields of ls_goitem_top
* which have been originally the fields without mat_ in the referenced
* PO. It is necessary to have those fields filled for the component as
* well in MIGO directly as otherwise account assignment might differ as
* we would use default from OKB9 if ps_psp_pnr and kdauf is not passed
* to SAPMM07M.
    IF ls_goitem_top-sobkz = e.                             "444836
      ls_goitem_comp-kdauf = ls_goitem_top-mat_kdauf.       "402360
      ls_goitem_comp-kdpos = ls_goitem_top-mat_kdpos.       "402360
    ENDIF.                                                  "444836
    IF ls_goitem_top-sobkz = q.                             "444836
      ls_goitem_comp-ps_psp_pnr = ls_goitem_top-mat_pspnr.  "402360
    ENDIF.                                                  "444836
** begin of insertion note 339452
    IF ls_goitem_comp-sobkz = q.
      IF ls_goitem_top-kzbws = 'M'.
        DATA: l_pspnr TYPE grpga-grpnr.
        CALL FUNCTION 'GRPG_FIND_GRPNR_WITH_MATNR'
          EXPORTING
            i_pspnr              = ls_goitem_comp-ps_psp_pnr
            i_werks              = ls_goitem_comp-werks
            i_matnr              = ls_goitem_comp-matnr
          IMPORTING
            e_grpnr              = l_pspnr
          EXCEPTIONS
            wrong_input          = 1
            no_valid_grpnr_found = 2.
        IF sy-subrc = 0.
          IF ls_goitem_comp-ps_psp_pnr <> l_pspnr AND
             NOT l_pspnr IS INITIAL.
*             update only changed wbs element
            ls_goitem_comp-ps_psp_pnr = l_pspnr.
          ENDIF.
        ENDIF.
      ENDIF.
      ls_goitem_comp-mat_pspnr = ls_goitem_comp-ps_psp_pnr.
      CALL CUSTOMER-FUNCTION '001'
           EXPORTING
                i_mdvw      = ls_mdvw
           CHANGING
                i_mat_pspnr = ls_goitem_comp-mat_pspnr.
    ELSEIF ls_goitem_comp-sobkz = e.
      ls_goitem_comp-mat_kdauf = ls_goitem_top-mat_kdauf.
      ls_goitem_comp-mat_kdpos = ls_goitem_top-mat_kdpos.
    ENDIF.
** end of insertion note 339452
* lifnr and kunnr has to be filled in lifnr without mat_,
* because the switch from lifnr and mat_lifnr has to take
* place in line_check
    ls_goitem_comp-lifnr = ls_goitem_top-lifnr.
    ls_goitem_comp-kunnr = ls_goitem_top-kunnr.

ENHANCEMENT-POINT EHP604_LINE_EXPAND_SUBCON_02 SPOTS ES_SAPLMIGO .

    CALL METHOD lcl_migo_buffer=>move_type_next_get
      EXPORTING
        i_move      = space
        i_fcode     = l_fcode
      RECEIVING
        e_move_next = ls_goitem_comp-bwart.

*   Organizational data
    ls_goitem_comp-parent = ls_goitem_top-global_counter.
    ls_goitem_comp-depth  = ls_goitem_top-depth + 1.
    ls_goitem_comp-zeile  = ls_goitem_top-zeile.
    ls_goitem_comp-xlbtype = c.      "Line is child of subcontracting
    l_current_tabix = l_current_tabix + 1.
*  Begin Outsourced Manufacturing EhP 4
    IF ls_goitem_top-xco_order = abap_true AND ( s_action-migo_mode <> 'GS'
       OR s_action-subsequent = abap_false ).
      ls_goitem_comp-xco_order = ls_goitem_top-xco_order.
      ls_goitem_comp-erfmg = 0.
ENHANCEMENT-POINT EHP606_LMIGOKL2_01 SPOTS ES_SAPLMIGO .
      CLEAR ls_goitem_comp-take_it.
    ENDIF.
* end Outsourced Manufacturing EhP 4

ENHANCEMENT-POINT LINE_EXPAND_SUBCON_02 SPOTS ES_SAPLMIGO .

    CALL METHOD line_modify
      EXPORTING
        i_tabix          = l_current_tabix
        i_insert         = abap_true
        i_status_delayed = abap_true
      CHANGING
        cs_goitem        = ls_goitem_comp.
  ENDLOOP.
  CALL METHOD status_derive.
ENDMETHOD.                    "line_expand_subcontracting

************************************************************************
* Expand a bill of material
************************************************************************
METHOD line_expand_bom.
  DATA: lt_stpox        TYPE STANDARD TABLE OF stpox,
        lt_matcat       TYPE STANDARD TABLE OF cscmat,
        lt_prefetch02   TYPE ty_t_prefetch02,
        ls_prefetch02   TYPE ty_s_prefetch02,
        ls_stpox        TYPE stpox,
        ls_gohead       TYPE gohead,
        ls_goitem_top   TYPE goitem,
        ls_goitem_comp  TYPE goitem,
        ls_gobom        TYPE gobom,
        ls_mtcom        TYPE mtcom,
        ls_mtcor        TYPE mtcor,
        ls_mbefu        TYPE mbefu,
        l_kzbsf         TYPE kzbsf,
        l_current_tabix TYPE sytabix.
* Read the line to be expanded
  CALL METHOD line_get
    EXPORTING
      i_tabix   = i_tabix
    IMPORTING
      es_goitem = ls_goitem_top.
* Expansion of BOMs only for manually entered positions.
* Furthermore, expansion is only possible for lines of the highest
* hierarchy level (DEPTH = 0). We do no allow multi-level expansion.
  IF ls_goitem_top-xmanu IS INITIAL        OR
     NOT ls_goitem_top-xbomtype IS INITIAL OR
     ls_goitem_top-depth <> 0.
    EXIT.
  ENDIF.
* BOM explosion only possible, if entered quantity <> 0.
  IF ls_goitem_top-erfmg IS INITIAL.
    MESSAGE i040(m7).
    EXIT.
  ENDIF.
* Read the header data
  CALL METHOD header_get
    IMPORTING
      e_gohead = ls_gohead.
* Popup for BOM explosion parameters?
  IF s_defaults-xbom = abap_true.
    CALL METHOD oref_bom->gobom_popup
      EXPORTING
        i_werks = ls_goitem_top-werks.
  ELSE.
    CALL METHOD oref_bom->gobom_fill
      EXPORTING
        i_werks = ls_goitem_top-werks.
  ENDIF.
* In case of CANCEL on BOM-popup -> exit this method
  IF sy-ucomm = 'OK_EXIT'.
    EXIT.
  ENDIF.
* Only possible with any of CAPID or STLAN filled
  IF oref_bom->s_gobom-capid IS INITIAL AND                 "311543
     oref_bom->s_gobom-stlan IS INITIAL.                    "311543
    MESSAGE i042(migo).                                     "311543
    EXIT.                                                   "311543
  ENDIF.                                                    "311543
* Read the bom for a material
  IF ls_goitem_top-matnr IS INITIAL.
    CALL FUNCTION 'CS_BOM_EXPL_EQU_V2'
      EXPORTING
        mehrs                 = abap_true
        bgixo                 = abap_true
        delnl                 = abap_false
        ehndl                 = '1'
        auskz                 = oref_bom->s_gobom-auskz
        brems                 = oref_bom->s_gobom-brems
        mdmps                 = oref_bom->s_gobom-brems
        capid                 = oref_bom->s_gobom-capid
        stlal                 = oref_bom->s_gobom-stlal
        stlan                 = oref_bom->s_gobom-stlan
        datuv                 = ls_gohead-budat
        emeng                 = ls_goitem_top-erfmg
        eqnrv                 = ls_goitem_top-equnr
        werks                 = ls_goitem_top-werks
      TABLES
        stb                   = lt_stpox
        matcat                = lt_matcat
      EXCEPTIONS
        alt_not_found         = 01
        call_invalid          = 02
        equipment_not_found   = 03
        missing_authorization = 04
        no_bom_found          = 05
        no_plant_data         = 06
        no_suitable_bom_found = 07.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.
  ELSE.
    CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
      EXPORTING
        ftrel                 = abap_true
        mehrs                 = abap_true
        bgixo                 = abap_true
        delnl                 = abap_false
        ehndl                 = '1'
        auskz                 = oref_bom->s_gobom-auskz
        brems                 = oref_bom->s_gobom-brems
        mdmps                 = oref_bom->s_gobom-brems
        capid                 = oref_bom->s_gobom-capid
        stlal                 = oref_bom->s_gobom-stlal
        stlan                 = oref_bom->s_gobom-stlan
        datuv                 = ls_gohead-budat
*             emeng                 = ls_goitem_top-erfmg        "754809
              emeng                 = ls_goitem_top-menge   "754809
        mtnrv                 = ls_goitem_top-matnr
        werks                 = ls_goitem_top-werks
      TABLES
        stb                   = lt_stpox
        matcat                = lt_matcat
      EXCEPTIONS
        alt_not_found         = 01
        call_invalid          = 02
        material_not_found    = 03
        missing_authorization = 04
        no_bom_found          = 05
        no_plant_data         = 06
        no_suitable_bom_found = 07.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.
  ENDIF.
* Prefetch material
  LOOP AT lt_stpox INTO ls_stpox WHERE NOT idnrk IS INITIAL.
    ls_prefetch02-matnr = ls_stpox-idnrk.
    ls_prefetch02-werks = ls_goitem_top-werks.
    ls_prefetch02-lgort = ls_goitem_top-lgort.
    COLLECT ls_prefetch02 INTO lt_prefetch02.
  ENDLOOP.
  CALL METHOD material_prefetch_read
    EXPORTING
      it_prefetch02 = lt_prefetch02.
* Insertion position
  l_current_tabix = i_tabix.
* Insert lines
  LOOP AT lt_stpox INTO ls_stpox WHERE NOT idnrk IS INITIAL.
*   Item itself is a bom: no multiple bom explosion available
*   Exclude of Dummy-Items
    CHECK ls_stpox-dumps = abap_false.
    IF oref_bom->s_gobom-brems = abap_false.
*   Exclude assembly in 'unlimited explosion'
      CHECK ls_stpox-xtlnr = abap_false.
    ENDIF.
*   bulk material relevant?
    IF oref_bom->s_gobom-schgt = abap_true.
      CHECK ls_stpox-schgt = abap_false AND
            ls_stpox-mschg = abap_false.
    ENDIF.
*   item with provide indicator relevant?
    IF oref_bom->s_gobom-beikz = abap_true.
      CHECK ls_stpox-beikz <> l.
    ENDIF.
    CLEAR ls_goitem_comp.
*   Pipeline?
    CALL METHOD lcl_migo_buffer=>item_cat_get
      EXPORTING
        i_postp = ls_stpox-postp
      IMPORTING
        e_kzbsf = l_kzbsf
      EXCEPTIONS
        OTHERS  = 1.
    IF sy-subrc <> 0.
      sy-subrc = sy-subrc.
    ENDIF.
    IF l_kzbsf = abap_false.
      ls_mtcom-kenng = 'MBEFU'.
      ls_mtcom-matnr = ls_stpox-idnrk.
      ls_mtcom-werks = ls_goitem_top-werks.
      CALL FUNCTION 'MATERIAL_READ'
           EXPORTING
                schluessel   = ls_mtcom
           IMPORTING
                matdaten     = ls_mbefu
                return       = ls_mtcor
           EXCEPTIONS
                error_message.
      IF sy-subrc <> 0.
        sy-subrc = sy-subrc.
      ELSE.
*       Do not take item, if inventory management not relevant   "548942
*       (KZBSF) and pipeline handling not mandatory (KZPIP)      "548942
        CHECK NOT ls_mbefu-kzpip IS INITIAL.                "548942
*       kzpip = T134  Material type: Pipeline mandatory
*       xpizu = T134M Material type: Pipeline possible
        CHECK ls_mbefu-mengu = abap_true OR
              ls_mbefu-xpizu = abap_true OR
             ( ls_mbefu-kzpip = abap_true AND ls_goitem_top-shkzg = h ).
      ENDIF.
    ENDIF.
    ls_goitem_comp = ls_goitem_top.
    CLEAR ls_goitem_comp-erfmg.
    IF ls_stpox-nfgrp = abap_false.
      ls_goitem_comp-erfmg = ls_stpox-mngko.
    ENDIF.
    CHECK ls_goitem_comp-erfmg >= 0.
    ls_goitem_comp-matnr = ls_stpox-idnrk.
*   Storage location from BOM if entered there
    IF ls_stpox-lgort <> space.
      ls_goitem_comp-lgort = ls_stpox-lgort.
    ENDIF.
    ls_goitem_comp-erfme = ls_stpox-meins.
    ls_goitem_comp-maktx = ls_stpox-ojtxp.
*   Organizational data
    CLEAR ls_goitem_comp-expand.
    CLEAR ls_goitem_comp-global_counter.   " to get a new global_counter
    " in line_modify.
    ls_goitem_comp-xbomtype = c.
    ls_goitem_comp-parent   = ls_goitem_top-global_counter.
    ls_goitem_comp-depth    = ls_goitem_top-depth + 1.
    ls_goitem_comp-zeile    = ls_goitem_top-zeile.
    l_current_tabix         = l_current_tabix + 1.
    CALL METHOD line_modify
      EXPORTING
        i_tabix          = l_current_tabix
        i_insert         = abap_true
        i_status_delayed = abap_true
      CHANGING
        cs_goitem        = ls_goitem_comp.
  ENDLOOP.
  CALL METHOD status_derive.

ENDMETHOD.                    "line_expand_bom

************************************************************************
*                               <LG>
* Expand bill of material of a full product
*
* input:
*     i_tabix : Index of the actual full product in pt_goitem
*     i_invisible : flag which indicates whether the empties bom shall
*                   be invisible
************************************************************************
METHOD line_expand_full_product.

  DATA: ls_goitem_top   TYPE goitem,   "full product line
        ls_goitem_comp  TYPE goitem,   "empty line
        l_current_tabix TYPE sytabix,
        lt_slcomp       TYPE ty_t_slcomp,            "table of empty bom
        ls_slcomp       TYPE ty_s_slcomp,
        lt_prefetch02   TYPE ty_t_prefetch02,        "material prefetch
        ls_prefetch02   TYPE ty_s_prefetch02,
        lt_prefetch03   TYPE ty_t_prefetch03,
        ls_prefetch03   TYPE ty_s_prefetch03.

  CLEAR:   lt_slcomp,
           lt_prefetch02,
           lt_prefetch03.
  CLEAR ls_goitem_top.

* Read the line to be expanded
  CALL METHOD line_get
    EXPORTING
      i_tabix   = i_tabix
    IMPORTING
      es_goitem = ls_goitem_top.
* get all components of empties bom
  CALL METHOD bom_empties_read
    EXPORTING
      is_goitem_full_product = ls_goitem_top
    IMPORTING
      et_slcomp              = lt_slcomp
    EXCEPTIONS
      not_found              = 01.
  IF sy-subrc = 0.
* SOBKZ is not allowed if there are items with tied empties
    IF NOT ls_goitem_top-sobkz IS INITIAL.
      MESSAGE i054(migo) WITH ls_goitem_top-sobkz.
      CLEAR: ls_goitem_top-sobkz, ls_goitem_top-umsok.
      MODIFY pt_goitem FROM ls_goitem_top INDEX i_tabix.
    ENDIF.
* full product has an empties bom -> set upvor(or respectively hpos_wws)
    ls_goitem_top-hpos_wws = c_upvor_vg.
    MODIFY pt_goitem FROM ls_goitem_top INDEX i_tabix
      TRANSPORTING hpos_wws.
  ENDIF.
* remember position of full product
  l_current_tabix = i_tabix.
* prefetch material
  LOOP AT lt_slcomp INTO ls_slcomp.
    ls_prefetch02-matnr = ls_slcomp-idnrk.
    ls_prefetch02-werks = ls_goitem_top-werks.
    ls_prefetch02-lgort = ls_goitem_top-lgort.
    COLLECT ls_prefetch02 INTO lt_prefetch02.
    ls_prefetch03-matnr = ls_slcomp-idnrk.
    COLLECT ls_prefetch03 INTO lt_prefetch03.
  ENDLOOP.
  CALL METHOD material_prefetch_read
    EXPORTING
      it_prefetch02 = lt_prefetch02
      it_prefetch03 = lt_prefetch03.
* process each empty
  LOOP AT lt_slcomp INTO ls_slcomp.
    CLEAR ls_goitem_comp.
* copy certain data from full product to tied empty
    CALL METHOD full_product_data_copy
      EXPORTING
        is_goitem_full  = ls_goitem_top
      CHANGING
        cs_goitem_empty = ls_goitem_comp.
* pointer to parent
    ls_goitem_comp-parent = ls_goitem_top-global_counter.
    ls_goitem_comp-depth  = ls_goitem_top-depth + 1.
* Line is child of full product
    ls_goitem_comp-xvgtype = 'C'.
    CLEAR: ls_goitem_comp-umrez,
           ls_goitem_comp-umren,
           ls_goitem_comp-maktx,
           ls_goitem_comp-matkl,
           ls_goitem_comp-umbar,
           ls_goitem_comp-lgpbe.
    ls_goitem_comp-matnr     = ls_slcomp-idnrk.
    ls_goitem_comp-erfmg     = ls_goitem_top-erfmg * ls_slcomp-menge .
    ls_goitem_comp-erfme     = ls_slcomp-meins.
    ls_goitem_comp-uptyp     = c_uptyp_lg.
    ls_goitem_comp-invisible = i_invisible.
* insert empties right after full product into table-control
    l_current_tabix = l_current_tabix + 1.
    CALL METHOD line_modify
      EXPORTING
        i_tabix          = l_current_tabix
        i_insert         = abap_true
        i_status_delayed = abap_true
      CHANGING
        cs_goitem        = ls_goitem_comp.
  ENDLOOP.
  CALL METHOD status_derive.

ENDMETHOD.                    "line_expand_full_product
************************************************************************
************************************************************************
* get parent item for component item
************************************************************************
METHOD get_parent_item.
  READ TABLE pt_goitem INTO e_goitem
                   WITH KEY global_counter = i_global_counter.
ENDMETHOD.                    "get_parent_item

************************************************************************
* Subcontracting: Component consumption before GR
* Outsourced Manufacturing EhP 4
************************************************************************
METHOD sc_line_modify.
  DATA: ls_change_po_elikz   TYPE ty_s_change_po_elikz,
        ls_goitem_top        TYPE goitem,
        ls_goitem_comp       TYPE goitem,
        lt_sc_total          TYPE TABLE OF ekbe_sc,
        ls_sc_total          TYPE ekbe_sc,
        ls_ekbe_sc           TYPE ekbe_sc,
        ls_control           TYPE ty_s_control,
        l_autyp              TYPE auftyp,
        l_current_tabix      TYPE sytabix.
  DATA: l_strategy           TYPE i,                      "n1503506
        l_converted_alt_qty  TYPE menge_d,                "n1503506
        l_converted_base_qty TYPE menge_d.                "n1503506

  IF is_new_goitem-xco_order IS INITIAL.
    RETURN.
  ENDIF.
  READ TABLE pt_ekbe_sc WITH KEY ebeln = is_new_goitem-ebeln
                                  ebelp = is_new_goitem-ebelp
                        TRANSPORTING NO FIELDS.
  IF sy-subrc IS NOT INITIAL.
    TRY.
        cl_mmpur_mepo_db_utility=>get_ekbe_sc(
              EXPORTING iv_ebeln = is_new_goitem-ebeln
                        iv_ebelp = is_new_goitem-ebelp
              IMPORTING et_ekbe_sc = pt_ekbe_sc ).
      CATCH cx_mmpur_not_found.
        CLEAR pt_ekbe_sc.
    ENDTRY.
  ENDIF.
  LOOP AT pt_ekbe_sc INTO ls_ekbe_sc
        WHERE ebeln = is_new_goitem-ebeln
          AND ebelp = is_new_goitem-ebelp
          AND lfbnr = is_new_goitem-lfbnr
          AND lfpos = is_new_goitem-lfpos.
    CLEAR l_current_tabix.
    READ TABLE lt_sc_total INTO ls_sc_total
        WITH KEY ebeln = is_new_goitem-ebeln
                 ebelp = is_new_goitem-ebelp
                 lfbnr = is_new_goitem-lfbnr
                 lfpos = is_new_goitem-lfpos
                 matnr = ls_ekbe_sc-matnr.
    l_current_tabix = sy-tabix.
* -------------- Start of note 1503506 -------------------------------------- *
* Design error of Outsourced Manufacturing EhP 4
* The ERFMG was just summed without taking care about the UOM!
* ls_ekbe_sc-erfme could be different and must converted in this case
* Of course the UOM must be included in the ERFMG calculation
* Similiar correction was done in include LMIGOKP1
* ----------------------------------------------------------------------------*
* Determine calculation strategy           (i.e. examples BME = ST)
* 1 - old calculation - same unit          (i.e. MIGO = ST  & EKBE_SC = ST  )
* 2 - From alternative unit to base unit   (i.e. MIGO = ST  & EKBE_SC = KAR )
* 3 - From base unit to alternative unit   (i.e. MIGO = KAR & EKBE_SC = ST  )
* 4 - From alternative to alternative unit (i.e. MIGO = KAR & EKBE_SC = BOX )
* ----------------------------------------------------------------------------*
*     Determine strategy
*     are both units the same?
      IF is_new_goitem-erfme = ls_ekbe_sc-erfme.
        l_strategy = 1.
      ELSE.
*     is one of them a base unit?
        IF ls_ekbe_sc-lagme = is_new_goitem-erfme OR
           ls_ekbe_sc-lagme = ls_ekbe_sc-erfme.
*          is the MIGO/PO unit the base unit?
             IF is_new_goitem-erfme = ls_ekbe_sc-lagme.
              l_strategy = 2.
             ELSE.
              l_strategy = 3.
             ENDIF.
         ELSE.
*        both units are alternative units but not the same
           l_strategy = 4.
         ENDIF.
      ENDIF.
*    Old logic which was wrong. lt_sc_total will be created with the ERFME
*    of the first entry in ls_ekbe_sc which was the first posting for the PO.
*    The total should be cummulated in the ERFMG which is derived by BSTME.
*    IF l_current_tabix = 0.
*      APPEND ls_ekbe_sc TO lt_sc_total.
*    ELSE.
    IF l_current_tabix = 0.
      CLEAR ls_sc_total.
      MOVE-CORRESPONDING ls_ekbe_sc TO ls_sc_total.
      IF is_new_goitem-erfme <> ls_ekbe_sc-erfme.
*     In this case, lt_sc_total should be built up in MIGO ERFME!
         CASE l_strategy.
           WHEN '1'. "can never be '1'
           WHEN '2'.
*          From alternative unit to base unit(i.e. MIGO = ST & EKBE_SC = KAR)
             CALL FUNCTION 'MB_UNIT_CONVERSION'
                   EXPORTING
                        erfme                = ls_ekbe_sc-erfme
                        erfmg                = ls_ekbe_sc-erfmg
                        matnr                = ls_ekbe_sc-matnr
                        meins                = is_new_goitem-erfme
*                        menge                = ...-menge
                        charg                = is_new_goitem-charg
                        werks                = is_new_goitem-werks
                   IMPORTING
                        o_menge              = l_converted_base_qty
                   EXCEPTIONS error_message  = 0.
             ls_sc_total-erfme = is_new_goitem-erfme.
             ls_sc_total-erfmg = l_converted_base_qty.
            WHEN '3'.
*           From base unit to alternative unit   (i.e. MIGO = KAR & EKBE_SC = ST  )
             CALL FUNCTION 'MB_UNIT_CONVERSION'
                   EXPORTING
                        erfme                = is_new_goitem-erfme
*                        erfmg                = ...-erfmg
                        matnr                = is_new_goitem-matnr
                        meins                = ls_ekbe_sc-erfme
                        menge                = ls_ekbe_sc-erfmg
                        charg                = is_new_goitem-charg
                        werks                = is_new_goitem-werks
                   IMPORTING
                        o_erfmg              = l_converted_alt_qty
                   EXCEPTIONS error_message  = 0.
             ls_sc_total-erfme = is_new_goitem-erfme.
             ls_sc_total-erfmg = l_converted_alt_qty.
            WHEN '4'.
*           From alternative to alternative unit (i.e. MIGO = KAR & EKBE_SC = BOX )
*           Conversion from alternative 1 to base unit to alternative 2.
             CALL FUNCTION 'MB_UNIT_CONVERSION'
                   EXPORTING
                        erfme                = ls_ekbe_sc-erfme
                        erfmg                = ls_ekbe_sc-erfmg
                        matnr                = is_new_goitem-matnr
                        meins                = ls_ekbe_sc-lagme
*                        menge                = ...-menge
                        charg                = is_new_goitem-charg
                        werks                = is_new_goitem-werks
                   IMPORTING
                        o_menge              = l_converted_base_qty
                   EXCEPTIONS error_message  = 0.
              CALL FUNCTION 'MB_UNIT_CONVERSION'
                    EXPORTING
                        erfme                = is_new_goitem-erfme
*                        erfmg                = ...-erfmg
                        matnr                = is_new_goitem-matnr
                        meins                = ls_ekbe_sc-erfme
                        menge                = l_converted_base_qty
                        charg                = is_new_goitem-charg
                        werks                = is_new_goitem-werks
                   IMPORTING
                        o_erfmg              = l_converted_alt_qty
                   EXCEPTIONS error_message  = 0.
             ls_sc_total-erfme = is_new_goitem-erfme.
             ls_sc_total-erfmg = l_converted_alt_qty.
         ENDCASE.
      ENDIF.
      APPEND ls_sc_total TO lt_sc_total.
    ELSE.
            CLEAR l_converted_base_qty.
            CLEAR l_converted_alt_qty.
*           Execute determined strategy
            CASE l_strategy.
              WHEN '1'.
*             old logic which was used for all strategies
                IF ls_ekbe_sc-shkzg = h.
*                 consumed component
        ls_sc_total-erfmg = ls_sc_total-erfmg + ls_ekbe_sc-erfmg.
      ELSE.  "Reversal of consumption
        ls_sc_total-erfmg = ls_sc_total-erfmg - ls_ekbe_sc-erfmg.
                ENDIF.
              WHEN '2'.
*             From alternative unit to base unit(i.e. MIGO = ST & EKBE_SC = KAR)
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_ekbe_sc-erfme
                          erfmg                = ls_ekbe_sc-erfmg
                          matnr                = is_new_goitem-matnr
                          meins                = is_new_goitem-erfme
*                          menge                = ...-menge
                          charg                = is_new_goitem-charg
                          werks                = is_new_goitem-werks
                     IMPORTING
                          o_menge              = l_converted_base_qty
                     EXCEPTIONS error_message  = 0.
                IF ls_ekbe_sc-shkzg = h.
*                 consumed component
                  ls_sc_total-erfmg = ls_sc_total-erfmg + l_converted_base_qty.
                ELSE.  "Reversal of consumption
                  ls_sc_total-erfmg = ls_sc_total-erfmg - l_converted_base_qty.
                ENDIF.
              WHEN '3'.
*             From base unit to alternative unit   (i.e. MIGO = KAR & EKBE_SC = ST  )
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = is_new_goitem-erfme
*                          erfmg                = ...-erfmg
                          matnr                = is_new_goitem-matnr
                          meins                = ls_ekbe_sc-erfme
                          menge                = ls_ekbe_sc-erfmg
                          charg                = is_new_goitem-charg
                          werks                = is_new_goitem-werks
                     IMPORTING
                          o_erfmg              = l_converted_alt_qty
                     EXCEPTIONS error_message  = 0.
                IF ls_ekbe_sc-shkzg = h.
*                 consumed component
                  ls_sc_total-erfmg = ls_sc_total-erfmg + l_converted_alt_qty.
                ELSE.  "Reversal of consumption
                  ls_sc_total-erfmg = ls_sc_total-erfmg - l_converted_alt_qty.
                ENDIF.
              WHEN '4'.
*             From alternative to alternative unit (i.e. MIGO = KAR & EKBE_SC = BOX )
*             Conversion from alternative 1 to base unit to alternative 2.
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = ls_ekbe_sc-erfme
                          erfmg                = ls_ekbe_sc-erfmg
                          matnr                = is_new_goitem-matnr
                          meins                = ls_ekbe_sc-lagme
*                          menge                = ...-menge
                          charg                = is_new_goitem-charg
                          werks                = is_new_goitem-werks
                     IMPORTING
                          o_menge              = l_converted_base_qty
                     EXCEPTIONS error_message  = 0.
               CALL FUNCTION 'MB_UNIT_CONVERSION'
                     EXPORTING
                          erfme                = is_new_goitem-erfme
*                          erfmg                = ...-erfmg
                          matnr                = is_new_goitem-matnr
                          meins                = ls_ekbe_sc-erfme
                          menge                = l_converted_base_qty
                          charg                = is_new_goitem-charg
                          werks                = is_new_goitem-werks
                     IMPORTING
                          o_erfmg              = l_converted_alt_qty
                     EXCEPTIONS error_message  = 0.
                IF ls_ekbe_sc-shkzg = h.
*                 consumed component
                  ls_sc_total-erfmg = ls_sc_total-erfmg + l_converted_alt_qty.
                ELSE.  "Reversal of consumption
                  ls_sc_total-erfmg = ls_sc_total-erfmg - l_converted_alt_qty.
                ENDIF.
            ENDCASE.
* -------------- End of note 1503506 -------------------------------------- *
      MODIFY TABLE lt_sc_total FROM ls_sc_total.
    ENDIF.
  ENDLOOP.
  IF is_new_goitem-xlbtype = p AND is_new_goitem-migo_elikz = '1'.
    IF lt_sc_total IS INITIAL.
      REFRESH pt_change_po_elikz.
      ls_change_po_elikz-ebeln = is_new_goitem-ebeln.
      ls_change_po_elikz-ebelp = is_new_goitem-ebelp.
      ls_change_po_elikz-migo_elikz = '3'.
      CALL METHOD change_elikz_later
        EXPORTING
          is_change_po_elikz = ls_change_po_elikz.
    ELSE.
      LOOP AT lt_sc_total INTO ls_sc_total.
        READ TABLE pt_ekbe_sc INTO ls_ekbe_sc
            WITH KEY ebeln = is_new_goitem-ebeln
                    ebelp = is_new_goitem-ebelp
                    lfbnr = is_new_goitem-lfbnr
                    lfpos = is_new_goitem-lfpos
                    matnr = ls_sc_total-matnr
                    bdmng = ls_sc_total-erfmg.
        IF sy-subrc <> 0.
          REFRESH pt_change_po_elikz.
          ls_change_po_elikz-ebeln = is_new_goitem-ebeln.
          ls_change_po_elikz-ebelp = is_new_goitem-ebelp.
          ls_change_po_elikz-migo_elikz = '3'.
          CALL METHOD change_elikz_later
            EXPORTING
              is_change_po_elikz = ls_change_po_elikz.
          EXIT.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
  IF is_new_goitem-xlbtype = c or s_action-migo_mode = 'GS'
     OR s_action-cancel = abap_true OR s_action-display = abap_true.
    RETURN.
  ENDIF.

*the old 521 lines have to be deleted after batch split
  LOOP AT pt_goitem INTO ls_goitem_comp
                    WHERE xco_order = abap_true
                      AND xlbtype   = abap_false
                      AND aufnr     = is_new_goitem-aufnr.
    l_current_tabix = sy-tabix.
    READ TABLE pt_goitem INTO ls_goitem_top
      WITH KEY xco_order      = abap_true
               xlbtype        = P
               aufnr          = ls_goitem_comp-aufnr
               global_counter = ls_goitem_comp-parent.
    IF sy-subrc <> 0.
      DELETE pt_goitem WHERE xco_order = abap_true
                         AND parent    = ls_goitem_comp-global_counter.
    ELSE.
      ls_goitem_comp-erfmg = ls_goitem_top-erfmg.
      ls_goitem_comp-erfme = ls_goitem_top-erfme.
      ls_goitem_comp-matnr = ls_goitem_top-matnr.
      ls_goitem_comp-charg = ls_goitem_top-charg.
      ls_goitem_comp-aufnr = ls_goitem_top-aufnr.
      ls_goitem_comp-bwtar = ls_goitem_top-bwtar.
ENHANCEMENT-POINT EHP606_LMIGOKL2_02 SPOTS ES_SAPLMIGO .
      IF ls_goitem_top-bwart <> is_old_goitem-bwart
         AND is_old_goitem-xlbtype = p.
        SELECT SINGLE autyp FROM aufk INTO l_autyp
            WHERE aufnr = is_new_goitem-aufnr.
        IF sy-subrc IS INITIAL AND l_autyp = '04'.
          SELECT SINGLE bwart FROM t156 INTO ls_goitem_comp-bwart
              WHERE bustr = '501'
                AND shkzg = is_new_goitem-shkzg
                AND rstyp = f.
          IF sy-subrc <> 0.
            CLEAR ls_goitem_comp-bwart.
          ENDIF.
        ENDIF.
      ENDIF.
      ls_goitem_comp-migo_insmk = ls_goitem_top-migo_insmk.
      MODIFY pt_goitem FROM ls_goitem_comp INDEX l_current_tabix.
      CALL METHOD change_takeit_later
        EXPORTING
          i_glc    = ls_goitem_comp-global_counter
          i_takeit = ls_goitem_top-take_it.
    ENDIF.
  ENDLOOP.
  CLEAR: ls_goitem_comp, ls_goitem_top.
  LOOP AT pt_goitem INTO ls_goitem_comp
                    WHERE xco_order = abap_true
                      AND xlbtype   = p
                      AND aufnr     = is_new_goitem-aufnr.
    l_current_tabix = sy-tabix.
    IF ls_goitem_comp-expand = c_icon_collapse.
      READ TABLE pt_goitem WITH KEY
                     parent    = ls_goitem_comp-global_counter
                     invisible = abap_false
                     TRANSPORTING NO FIELDS.
      IF sy-subrc <> 0.
        ls_goitem_comp-expand = c_icon_expand.
        MODIFY pt_goitem FROM ls_goitem_comp INDEX l_current_tabix
                     TRANSPORTING expand.
      ENDIF.
    ENDIF.
    READ TABLE pt_goitem WITH KEY
                      xco_order = abap_true
                      xlbtype   = space
                      aufnr     = ls_goitem_comp-aufnr
                      parent    = ls_goitem_comp-global_counter
                      TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
      SELECT SINGLE autyp FROM aufk INTO l_autyp
          WHERE aufnr = is_new_goitem-aufnr.
      IF sy-subrc IS INITIAL AND l_autyp = '04'.
        SELECT SINGLE bwart FROM t156 INTO ls_goitem_comp-bwart
            WHERE bustr = '501'
              AND shkzg = ls_goitem_comp-shkzg
              AND rstyp = f.
        IF sy-subrc <> 0.
          CLEAR ls_goitem_comp-bwart.
        ENDIF.
        ls_goitem_comp-parent = ls_goitem_comp-global_counter.
        CLEAR: ls_goitem_comp-expand, ls_goitem_comp-xlbtype, ls_goitem_comp-xpoitem,
               ls_goitem_comp-global_counter, ls_goitem_comp-pstyp, ls_goitem_comp-ebeln,
               ls_goitem_comp-ebelp, ls_goitem_comp-kzbew, ls_goitem_comp-knttp,
               ls_goitem_comp-bprme, ls_goitem_comp-bpmng, ls_goitem_comp-bstmg,
               ls_goitem_comp-bstme, ls_goitem_comp-sernp.
        ls_goitem_comp-xlort = abap_true.
*   Insert line
        CALL METHOD line_modify
          EXPORTING
            i_status_delayed  = abap_true
          CHANGING
            cs_goitem         = ls_goitem_comp.
        CALL METHOD screen_modify_line( ls_goitem_comp ).
        CALL METHOD screen_modify_transfer_fields( ls_goitem_comp ).
        SORT pt_goitem BY global_counter zeile.
        CLEAR ls_goitem_comp.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDMETHOD.                    "sc_line_modify