*----------------------------------------------------------------------*
*   INCLUDE LMIGODB4                                                   *
*   Detail tabstrip documentary batch implementation
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_doc_batch IMPLEMENTATION.

************************************************************************
* constructor: initialize documentary batch data
************************************************************************
  METHOD constructor.
    DATA: lt_okcodes TYPE lif_migo_frame=>ty_t_okcodes.

*   screenobject constructor needed to instance variables
    CALL METHOD super->constructor.

    CALL FUNCTION 'VBDBDM_INIT'.

  ENDMETHOD.                    "constructor


************************************************************************
*
************************************************************************
  METHOD lif_migo_frame~okcode_handler.
  ENDMETHOD.                    "lif_migo_frame~okcode_handler


************************************************************************
*
************************************************************************
  METHOD lif_migo_frame~message_handler.
  ENDMETHOD.                    "lif_migo_frame~message_handler


************************************************************************
* PBO documentary batch subscreen: send data to VBDOCUBATCH_DM
************************************************************************
  METHOD pbo.

    DATA: it_process_ids   TYPE docubatch_process_id_t, " business proc.
          is_docubatch_com TYPE docubatch_com, " communication structure
          l_ebeln          TYPE ebeln,        " used to export PO number
          l_ebelp          TYPE ebelp,
          l_aufnr          TYPE aufnr,
          l_posnr          TYPE co_posnr,
          ls_goitem_parent TYPE goitem,
          ls_control       TYPE lcl_migo_kernel=>ty_s_control,
          lv_display_only  TYPE xfeld.

    CALL METHOD super->pbo.

    BREAK-POINT ID migo_doc_batch.

*   determine business process
    me->doc_batch_set_process_id(
          EXPORTING
            i_goitem        = goitem
          IMPORTING
            et_process_ids  = it_process_ids
            e_ebeln         = l_ebeln
            e_ebelp         = l_ebelp
            e_aufnr         = l_aufnr
            e_posnr         = l_posnr ).

*   fill communication structure
    me->doc_batch_move_goitem_to_com(
          EXPORTING
            i_goitem        = goitem
          IMPORTING
            e_docubatch_com = is_docubatch_com ).

*   documentary batch set display mode
    ls_control = lcl_migo_globals=>kernel->mode_get( ).
    IF ls_control-action EQ 'A04' or
       lcl_migo_globals=>kernel->s_action-cancel is not initial or    "1571409
       goitem-smbln is not initial.                                   "1571409
      lv_display_only = abap_true.
    ENDIF.

    CALL FUNCTION 'VBDBDM_DATA_GET_FROM_IM'
      EXPORTING
        i_key              = goitem-global_counter
        i_matnr            = goitem-matnr
        i_werks            = goitem-werks
        i_docubatch_charg  = goitem-docubatch_charg
        i_quantity         = goitem-erfmg
        i_uom              = goitem-erfme
        it_process_ids     = it_process_ids
        i_ebeln            = l_ebeln
        i_ebelp            = l_ebelp
        i_aufnr            = l_aufnr
        i_aufps            = l_posnr
        i_display_only     = lv_display_only
        is_docubatch_com   = is_docubatch_com
      EXCEPTIONS
        process_not_active = 1
        material_not_found = 2
        OTHERS             = 99.

    CASE sy-subrc.
      WHEN 0.
      WHEN 1.
*       In this case, the function module should not have been called or
*       the result is different when calling VBDBDM_DATA_GET_FROM_IM and
*       VBDBDM_ACTIVE_CHECK_DETAIL. This must not happen.
        MESSAGE a899 WITH 'VBDBDM_DATA_GET_FROM_IM' space space space.
      WHEN 2.
*       also: should never happen
        MESSAGE e530(m7) WITH goitem-matnr.
      WHEN OTHERS.
*       whatever else: issue the message
        MESSAGE ID sy-msgid TYPE s NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDCASE.

  ENDMETHOD.                    "pbo


************************************************************************
* PAI documentary batch subscreen: get data from VBDOCUBATCH_DM;
* transfer to table control if possible
************************************************************************
  METHOD pai.

    DATA: l_mult_entries    TYPE xfeld,                " >1 docu batch?
          l_global_counter  TYPE migo_global_counter,
*         there is exactly 1 docu batch for item to put it in GOITEM/
*         the symbol for multiple documentary batches is set
          l_docubatch_charg TYPE docubatch_charg.

    CALL METHOD super->pai.

    BREAK-POINT ID migo_doc_batch.

    CALL FUNCTION 'VBDBDM_DATA_PUT_TO_IM'
      IMPORTING
        e_key             = l_global_counter
        e_docubatch_charg = l_docubatch_charg
        e_mult_entries    = l_mult_entries.

*   check whether it is really the correct item
    CHECK NOT l_global_counter IS INITIAL.                  "888095
    IF l_global_counter <> goitem-global_counter.
      MESSAGE a899 WITH 'lcl_migo_detail_doc_batch->PAI'    "#EC NOTEXT
                        'l_global_counter'
                        'goitem-global_counter'
                        space.
    ENDIF.

*   take over results
    goitem-docubatch_charg        = l_docubatch_charg.
    goitem-docubatch_mult_entries = l_mult_entries.

  ENDMETHOD.                    "pai


************************************************************************
* initialize class; when button 'Restart' is pressed
************************************************************************
  METHOD reset.
    CALL FUNCTION 'VBDBDM_INIT'.
    CLEAR pt_process_buffer[].
  ENDMETHOD.                    "reset


************************************************************************
* Method does approximately the same as MOVE-CORRESPONDING, but has to
* handle structures field by field
************************************************************************
  METHOD doc_batch_move_goitem_to_com.

    MOVE-CORRESPONDING i_goitem TO e_docubatch_com.
    IF e_docubatch_com-aufnr IS INITIAL.
      e_docubatch_com-aufnr = i_goitem-pps_aufnr.
      e_docubatch_com-aufps = i_goitem-pps_posnr.
    ENDIF.

  ENDMETHOD.                    "doc_batch_move_goitem_to_com


************************************************************************
* Documentary batch: Determine IM process (as business process) before
* calling fuction modules in VBDOCUBATCH_DM
************************************************************************
  METHOD doc_batch_set_process_id.

    FIELD-SYMBOLS: <ls_process_buffer> TYPE pty_db_process_buffer.

*   first call of documentary batch detail screen for this item
    DATA: l_first_call      TYPE xfeld,
          ls_process_id     TYPE docubatch_process_id_s,
          ls_process_buffer TYPE pty_db_process_buffer,
          ls_buffer_compare TYPE pty_db_buffer_compare,
          ls_goitem_compare TYPE pty_db_buffer_compare,
          ls_goitem_parent  TYPE goitem.

    CLEAR et_process_ids.

*   check, if entry was already buffered -------------------------------
    READ TABLE pt_process_buffer
                     ASSIGNING <ls_process_buffer>
                      WITH KEY global_counter = i_goitem-global_counter.
    IF sy-subrc = 0.
      l_first_call = abap_false.
      MOVE-CORRESPONDING i_goitem TO ls_goitem_compare.
      MOVE-CORRESPONDING <ls_process_buffer> TO ls_buffer_compare.
      IF i_goitem-xlbtype = c.
*       get EBELN/ EBELP from parent item for subcontracting component
        lcl_migo_globals=>kernel->get_parent_item(
          EXPORTING
            i_global_counter = i_goitem-parent
          IMPORTING
            e_goitem         = ls_goitem_parent ).
        ls_goitem_compare-ebeln = ls_goitem_parent-ebeln.
        ls_goitem_compare-ebelp = ls_goitem_parent-ebelp.
      ENDIF.
*     no changes concerning business process, use buffered information
      IF ls_goitem_compare = ls_buffer_compare.
        et_process_ids = <ls_process_buffer>-process_ids.
        e_ebeln = <ls_process_buffer>-ebeln.
        e_ebelp = <ls_process_buffer>-ebelp.
        IF NOT <ls_process_buffer>-pps_aufnr IS INITIAL.
          e_aufnr = <ls_process_buffer>-pps_aufnr.
          e_posnr = <ls_process_buffer>-pps_posnr.
        ELSE.
          e_aufnr = <ls_process_buffer>-aufnr.
          CLEAR e_posnr.
        ENDIF.
        EXIT.
      ENDIF.
    ELSE.
      l_first_call = abap_true.
      ASSIGN ls_process_buffer TO <ls_process_buffer>.
      MOVE-CORRESPONDING i_goitem TO <ls_process_buffer>.
    ENDIF.

*   set business process purchase order/ subcontracting ----------------
*   no changes possible concerning EBELN/ EBELP/ SC components -> check
*   only for first call
    IF l_first_call = abap_true.
      IF i_goitem-xlbtype = p OR               " might not be set yet...
         i_goitem-xpoitem = abap_true AND i_goitem-pstyp = '3'.
*       GR for subcontracting PO
        ls_process_id-process_id = '02'.
        INSERT ls_process_id INTO TABLE <ls_process_buffer>-process_ids.
        <ls_process_buffer>-ebeln = e_ebeln = i_goitem-ebeln.
        <ls_process_buffer>-ebelp = e_ebelp = i_goitem-ebelp.

      ELSEIF i_goitem-xlbtype = c.
*       GI subcontracting component
        ls_process_id-process_id = '03'.
        INSERT ls_process_id INTO TABLE <ls_process_buffer>-process_ids.
*       get EBELN/ EBELP from parent item
        lcl_migo_globals=>kernel->get_parent_item(
          EXPORTING
            i_global_counter = i_goitem-parent
          IMPORTING
            e_goitem         = ls_goitem_parent ).
        <ls_process_buffer>-ebeln = e_ebeln = ls_goitem_parent-ebeln.
        <ls_process_buffer>-ebelp = e_ebelp = ls_goitem_parent-ebelp.

      ELSEIF i_goitem-xpoitem = abap_true.
*       GR for non-subcontracting PO
        ls_process_id-process_id = '01'.
        INSERT ls_process_id INTO TABLE <ls_process_buffer>-process_ids.
        <ls_process_buffer>-ebeln = e_ebeln = i_goitem-ebeln.
        <ls_process_buffer>-ebelp = e_ebelp = i_goitem-ebelp.
      ENDIF.
    ENDIF.
* Display material document in MIGO, documentary batch        "s1302682
* information for subcontracting components should be
* displayed in case they exists
    IF i_goitem-xpoitem IS INITIAL AND i_goitem-sobkz = 'O' AND
        i_goitem-xlbtype IS INITIAL.
*       get EBELN/ EBELP from parent item
        lcl_migo_globals=>kernel->get_parent_item(
          EXPORTING
            i_global_counter = i_goitem-parent
          IMPORTING
            e_goitem         = ls_goitem_parent ).
*       process id 03 only allowed in relation with POs        "1435873
        IF ls_goitem_parent-ebeln IS NOT INITIAL AND           "1435873
           ls_goitem_parent-ebelp IS NOT INITIAL.              "1435873
*         display subcontracting component                     "1435873
          ls_process_id-process_id = '03'.                     "1435873
          INSERT ls_process_id INTO                            "1435873
           TABLE <ls_process_buffer>-process_ids.              "1435873
          <ls_process_buffer>-ebeln = e_ebeln = ls_goitem_parent-ebeln.
          <ls_process_buffer>-ebelp = e_ebelp = ls_goitem_parent-ebelp.
        ENDIF.                                                 "1435873
     ENDIF.                                                   "e1302682

*   set business process for orders ------------------------------------
*   attention: it might become necessary to set the business process for
*   the order depending on the order type. In this case, either put
*   AUTYP in GOITEM or implement a method that can be called from here
*   but also from elsewhere in an appropriate class.
*   Up to now, there is no process known which posts a GR for an order
*   to consumption for another order. If this came up, the method needs
*   exporting parameters for both of them as well as the function
*   modules for documentary batches.
    IF NOT i_goitem-aufnr IS INITIAL.
*     consumption for order
      ls_process_id-process_id = '05'.
      INSERT ls_process_id INTO TABLE <ls_process_buffer>-process_ids.
      <ls_process_buffer>-aufnr = e_aufnr = i_goitem-aufnr.
      CLEAR e_posnr.
    ELSE.
      DELETE <ls_process_buffer>-process_ids WHERE process_id = '05'.
    ENDIF.
    IF i_goitem-xorditem = abap_true.
*     GR for order
      ls_process_id-process_id = '04'.
      INSERT ls_process_id INTO TABLE <ls_process_buffer>-process_ids.
      <ls_process_buffer>-pps_aufnr = e_aufnr = i_goitem-pps_aufnr.
      <ls_process_buffer>-pps_posnr = e_posnr = i_goitem-pps_posnr.
    ELSE.
      DELETE <ls_process_buffer>-process_ids WHERE process_id = '04'.
    ENDIF.

*   export result
    et_process_ids = <ls_process_buffer>-process_ids.

*   for first call: insert data to buffer
    IF l_first_call = abap_true.
      INSERT ls_process_buffer INTO TABLE pt_process_buffer.
    ENDIF.

  ENDMETHOD.                    "doc_batch_set_process_id


************************************************************************
* delete entry from buffer when item is deleted
************************************************************************
  METHOD doc_batch_item_delete.
    DELETE pt_process_buffer WHERE global_counter = i_global_counter.
  ENDMETHOD.                    "doc_batch_item_delete

ENDCLASS.                    "lcl_migo_detail_doc_batch IMPLEMENTATION