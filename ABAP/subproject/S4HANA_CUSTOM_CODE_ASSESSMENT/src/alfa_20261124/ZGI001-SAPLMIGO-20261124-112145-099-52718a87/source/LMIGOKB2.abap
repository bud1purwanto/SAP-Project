*&---------------------------------------------------------------------*
*&  INCLUDE LMIGOKB2 Documentary batch
*&---------------------------------------------------------------------*


************************************************************************
*   Determine whether documentary batch is used for this
*   material/ plant/ process
************************************************************************
METHOD doc_batch_get_control_for_item.

  DATA: ls_goitem_parent TYPE goitem,
        ls_docubatch_com TYPE docubatch_com,
        l_aufnr          TYPE aufnr,
        l_posnr          TYPE co_posnr,
        l_ebeln          TYPE ebeln,
        l_ebelp          TYPE ebelp,
        lt_process_ids   TYPE docubatch_process_id_t.

* performance: determine documentary batch only when activated in client
  CHECK lcl_migo_globals=>doc_batch_active = abap_true.
* documentary batch are not handled by MIGO in case of a cancellation
*  CHECK s_control-action <> 'A03'.                            "1571409
* documentary batch are not handled in case of transfer orders "1226408
  CHECK i_goitem-reswk IS INITIAL.                             "1226408

* check whether there were sufficient data available
  IF i_goitem-matnr IS INITIAL OR i_goitem-werks IS INITIAL.
    CLEAR e_docubatch_control.
    EXIT.
  ENDIF.

* fill communication structure
  oref_detail_doc_batch->doc_batch_move_goitem_to_com(
        EXPORTING
          i_goitem = i_goitem
        IMPORTING
          e_docubatch_com = ls_docubatch_com ).
  ls_docubatch_com-CANCEL = lcl_migo_globals=>kernel->s_action-cancel.   "1571409

* determine business process and reference documents
  oref_detail_doc_batch->doc_batch_set_process_id(
        EXPORTING
          i_goitem       = i_goitem
        IMPORTING
          et_process_ids = lt_process_ids
          e_ebeln        = l_ebeln
          e_ebelp        = l_ebelp
          e_aufnr        = l_aufnr
          e_posnr        = l_posnr ).

* ask whether to use documentary batches for this item
  CALL FUNCTION 'VBDBDM_ACTIVE_CHECK_DETAIL'
    EXPORTING
      i_matnr            = i_goitem-matnr
      i_werks            = i_goitem-werks
      i_application_id   = '01'
      it_process_ids     = lt_process_ids
      i_ebeln            = l_ebeln
      i_ebelp            = l_ebelp
      i_aufnr            = l_aufnr
      i_aufps            = l_posnr
      is_docubatch_com   = ls_docubatch_com
    IMPORTING
      e_control          = e_docubatch_control
    EXCEPTIONS
      process_not_active = 1
      OTHERS             = 99.
  IF sy-subrc = 1 AND e_docubatch_control = abap_true OR
     sy-subrc = 99.
    MESSAGE a899 WITH 'VBDBDM_ACTIVE_CHECK_DETAIL' space space space.
  ENDIF.

ENDMETHOD.                    "doc_batch_get_control_for_item


***********************************************************************
* get documentary batches for material document line
***********************************************************************
METHOD doc_batch_get_data_for_matdoc.

  DATA:
    ls_control          TYPE lcl_migo_kernel=>ty_s_control,
    lv_display_only     type xfeld.                          "1571409

  ls_control = lcl_migo_globals=>kernel->mode_get( ).

* performance: do check for doc. batch only when activated in client
  CHECK lcl_migo_globals=>doc_batch_active = abap_true.
* this method only handles 'show material documents'
  CHECK ls_control-action = 'A04' or
* and with note  1571409 also cancellations
        ls_control-action = 'A03' or                          "1571409
        ls_control-action = 'A02'.                            "1571409
* only for materials handling documentary batches - determined before
  CHECK i_goitem-docubatch_control IS NOT INITIAL.
* already showed documentary batch information for in MIGO    "1302682
* displayed material documents should not be cleared through  "1302682

* shifting the positions                                      "1302682
  CHECK e_docubatch_charg IS INITIAL.                         "1302682

  if ls_control-action = 'A04' or "1571409
     ls_control-action = 'A03'.
    lv_display_only = x.
  elseif ls_control-action = 'A02'.
    clear lv_display_only.
  endif.

  CALL FUNCTION 'VBDBDM_DATA_READ_FOR_MATDOC_IM'
    EXPORTING
      i_key             = i_goitem-global_counter
      i_matnr           = i_goitem-matnr
      i_werks           = i_goitem-werks
      i_mblnr           = i_goitem-mblnr
      i_mjahr           = i_goitem-mjahr
      i_zeile           = i_goitem-zeile
      i_display_only    = lv_display_only
    IMPORTING
      e_docubatch_control = e_docubatch_control               "1302682
      e_docubatch_charg   = e_docubatch_charg                 "1302682
      e_mult_entries      = e_mult_entries.                   "1302682

ENDMETHOD.                    "doc_batch_get_data_for_matdoc

***********************************************************************
* call function modules from VBDOCUBATCH_DM to post documentary batch
***********************************************************************
METHOD doc_batch_post.

  DATA: ls_goitem           TYPE goitem,
        l_docubatch_control TYPE docubatch_control,
        ls_docubatch_com    TYPE docubatch_com,
        it_process_ids      TYPE docubatch_process_id_t,
        l_ebeln             TYPE ebeln,
        l_ebelp             TYPE ebelp,
        l_aufnr             TYPE aufnr,
        l_posnr             TYPE co_posnr.

  BREAK-POINT ID migo_doc_batch_post.

* performance: do check for doc. batch only when activated in client
  CHECK lcl_migo_globals=>doc_batch_active = abap_true.
* documentary batch are not handled by MIGO in case of a cancellation
  CHECK s_control-action <> 'A03'.
* documentary batch are not handled by MIGO in show document
  CHECK s_control-action <> 'A04'.

  LOOP AT pt_goitem INTO ls_goitem
                   WHERE take_it = abap_true.
* documentary batch are not handled in case of transfer orders "1226408
  CHECK ls_goitem-reswk IS INITIAL.                            "1226408
*   fill communication structure
    oref_detail_doc_batch->doc_batch_move_goitem_to_com(
      EXPORTING
        i_goitem = ls_goitem
      IMPORTING
        e_docubatch_com = ls_docubatch_com ).
*   again: get business process(es), get reference document numbers
    oref_detail_doc_batch->doc_batch_set_process_id(
      EXPORTING
        i_goitem       = ls_goitem
      IMPORTING
        et_process_ids = it_process_ids
        e_ebeln        = l_ebeln
        e_ebelp        = l_ebelp
        e_aufnr        = l_aufnr
        e_posnr        = l_posnr ).
*   do the check
    CALL FUNCTION 'VBDBDM_DATA_CHECK_IM'
      EXPORTING
        i_key             = ls_goitem-global_counter
        i_matnr           = ls_goitem-matnr
        i_werks           = ls_goitem-werks
        i_docubatch_charg = ls_goitem-docubatch_charg
        i_quantity        = ls_goitem-erfmg
        i_uom             = ls_goitem-erfme
        it_process_ids    = it_process_ids
        i_ebeln           = l_ebeln
        i_ebelp           = l_ebelp
        i_aufnr           = l_aufnr
        i_aufps           = l_posnr
        is_docubatch_com  = ls_docubatch_com
      IMPORTING
        e_docubatch_charg = ls_goitem-docubatch_charg        "1114886
        e_mult_entries    = ls_goitem-docubatch_mult_entries "1114886
      EXCEPTIONS
        OTHERS            = 0.

    IF sy-subrc EQ 0.                                        "1114886
*     take over results                                      "1114886
      MODIFY TABLE pt_goitem FROM ls_goitem                  "1114886
             TRANSPORTING docubatch_charg                    "1114886
                          docubatch_mult_entries.            "1114886
    endif.                                                   "1114886

*   subcontracting documentary batches: check whether the functionality
*   was active for a component that wasn't expanded
*   no difference in behaviour for GR/ subsequent adjustment
    IF ls_goitem-xlbtype = p.
      me->doc_batch_check_components( ls_goitem ).
    ENDIF.

  ENDLOOP.

ENDMETHOD.                    "doc_batch_post


************************************************************************
* subcontracting: check whether any of the components is relevant for
* docu batches but was't expanded yet
* reason for check: MIGO only considers expanded items only; if the
* component items were added within MB_CREATE only, there wasn't any
* communication with documentary batch functionality (that's the
* intended design, to keep it outside!). Therefore, a check has to be
* done in MIGO, before calling MB_CREATE.
************************************************************************
METHOD doc_batch_check_components.

  DATA: lt_mdvw             TYPE STANDARD TABLE OF mdvw,
        l_sum_we            TYPE bstmg,
        l_act_we            TYPE bstmg,
        lt_process_ids      TYPE docubatch_process_id_t,
        ls_docubatch_com    TYPE docubatch_com,
        l_docubatch_control TYPE docubatch_control,
        ls_tcudb_process    TYPE tcudb_process,
        l_rc_t160m          TYPE sy-subrc,
*       expanding components is required
        l_expand_req        TYPE xfeld.

  FIELD-SYMBOLS: <ls_mdvw>  TYPE mdvw.
*
* performance: determine documentary batch only when activated in client
  CHECK lcl_migo_globals=>doc_batch_active = abap_true.
* documentary batch are not handled by MM-IM in case of a cancellation
  CHECK s_control-action <> 'A03'.

* process check inside MIGO subcontracting - expanding
* of sublines required can only take over EBELN and EBELP from
* main item - all oter information is confusing and shoul not
* taken over in the communiction structure  (note 1563638)
  ls_docubatch_com-ebeln = is_goitem-ebeln.        "1563638
  ls_docubatch_com-ebelp = is_goitem-ebelp.        "1563638

* are documentary batches active for SC consumption?
  CALL FUNCTION 'VBDBDM_ACTIVE_CHECK_PROCESS'
    EXPORTING
      i_process_id       = '03'
      is_docubatch_com   = ls_docubatch_com        "1563638
    IMPORTING
      es_process         = ls_tcudb_process
    EXCEPTIONS
      process_not_active = 1
      OTHERS             = 2.
  IF sy-subrc = 2.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.

  IF ls_tcudb_process-record = 1.
*   documentary batches are generally active for subcontracting
*   components, go on checking:
*   were the items expanded and checks therefore are already done?
    READ TABLE pt_goitem WITH KEY parent = is_goitem-global_counter
                                 take_it = abap_true
                         TRANSPORTING NO FIELDS.
    IF sy-subrc <> 0.
*     it wasn't expanded yet, does it have to be? To do the check, get
*     components and check all of them until the first one with
*     documentary batches has been found.
      APPEND '03' TO lt_process_ids.
      l_act_we = is_goitem-bstmg.
      l_sum_we = is_goitem-wemng + l_act_we.

      CALL FUNCTION 'ME_REFRESH_COMP_GOODS_MOVEMENT'.

      CALL FUNCTION 'ME_READ_COMP_GOODS_RECEIPT'
        EXPORTING
          aktwe          = is_goitem-bstmg
          display        = abap_true
          ebeln          = is_goitem-ebeln
          ebelp          = is_goitem-ebelp
          lfbnr          = is_goitem-lfbnr
          lfgja          = is_goitem-lfbja
          lfpos          = is_goitem-lfpos
          shkzg          = is_goitem-shkzg
          sumwe          = l_sum_we
          no_batch       = abap_true
        TABLES
          t_bbefu        = lt_mdvw
        EXCEPTIONS
          not_found_any  = 1
          not_found_one  = 2
          not_valid_any  = 3
          not_valid_one  = 4
          enqueue_failed = 5
          OTHERS         = 6.
      IF sy-subrc <> 0.
      ENDIF.

      LOOP AT lt_mdvw ASSIGNING <ls_mdvw>
                          WHERE NOT matnr IS INITIAL.
        MOVE-CORRESPONDING <ls_mdvw> TO ls_docubatch_com.
*       ask whether to use documentary batches for this item
        CALL FUNCTION 'VBDBDM_ACTIVE_CHECK_DETAIL'
          EXPORTING
            i_matnr            = <ls_mdvw>-matnr
            i_werks            = <ls_mdvw>-werks
            i_application_id   = '01'
            it_process_ids     = lt_process_ids
            i_ebeln            = is_goitem-ebeln
            i_ebelp            = is_goitem-ebelp
            is_docubatch_com   = ls_docubatch_com
          IMPORTING
            e_control          = l_docubatch_control
          EXCEPTIONS
            process_not_active = 1
            OTHERS             = 99.
        IF sy-subrc <> 0 AND l_docubatch_control = abap_true.
          MESSAGE a899 WITH 'VBDBDM_ACTIVE_CHECK_DETAIL'
                            space space space.
        ENDIF.
        IF l_docubatch_control <> space.                    "1559668
          l_expand_req = abap_true.
          EXIT.
        ENDIF.
      ENDLOOP.

*     the GR item hasn't been expanded yet, check whether item has
*     to be expanded
      IF l_expand_req = abap_true.
        CALL METHOD oref_log->context_set(
          i_global_counter = is_goitem-global_counter ).
        def_msg_add oref_log e 'VBDOCUBATCH' '115'
                    is_goitem-zeile space space space.
      ENDIF.
    ENDIF.
  ENDIF.

ENDMETHOD.                    "doc_batch_check_components