*----------------------------------------------------------------------*
*   INCLUDE LMIGOKC2                                                   *
*----------------------------------------------------------------------*
* METHOD CHANGE_ALL_ITEMS
* Mass changes for all items in pt_goitem
* Has to run after all line_modify calls have been done because a
* line_modify may affect other lines as well (e.g. ELIKZ)
* This method is called in pai_0001_end after all subscreens
* External callers should call the method themselves if they
* use line_modify.
*----------------------------------------------------------------------*
METHOD change_all_items.
  CALL METHOD change_takeit_all_items.
  CALL METHOD change_elikz_all_items.
  CALL METHOD change_quantity_all_items.
  CALL METHOD change_batch_all_items.  " note 624076
  CALL METHOD change_children.

ENDMETHOD.                    "change_all_items
*----------------------------------------------------------------------*
* METHOD CHANGE_ELIKZ_ALL_ITEMS
* Changes all items for a PO/order/reservation item.
* This method is called in change_all_items.
* The change tables are filled during line_check with change_elikz_later
*----------------------------------------------------------------------*
METHOD change_elikz_all_items.
  DATA: ls_change_po_elikz  TYPE ty_s_change_po_elikz,
        ls_change_ord_elikz TYPE ty_s_change_ord_elikz,
        ls_change_res_kzear TYPE ty_s_change_res_kzear,
        ls_goitem TYPE goitem.

* Change ELIKZ for all items with the same PO item
  LOOP AT pt_change_po_elikz INTO ls_change_po_elikz.
    ls_goitem-migo_elikz = ls_change_po_elikz-migo_elikz.
    MODIFY pt_goitem FROM ls_goitem TRANSPORTING migo_elikz
          WHERE ebeln = ls_change_po_elikz-ebeln
          AND   ebelp = ls_change_po_elikz-ebelp.
  ENDLOOP.

* Change ELIKZ for all items with the same order item
  LOOP AT pt_change_ord_elikz INTO ls_change_ord_elikz.
    ls_goitem-migo_elikz = ls_change_ord_elikz-migo_elikz.
    MODIFY pt_goitem FROM ls_goitem TRANSPORTING migo_elikz
          WHERE pps_aufnr = ls_change_ord_elikz-pps_aufnr
          AND   pps_posnr = ls_change_ord_elikz-pps_posnr.
  ENDLOOP.

* Change KZEAR for all items with the same reservation item
  LOOP AT pt_change_res_kzear INTO ls_change_res_kzear.
    ls_goitem-kzear = ls_change_res_kzear-kzear.
    MODIFY pt_goitem FROM ls_goitem TRANSPORTING kzear
          WHERE rsnum = ls_change_res_kzear-rsnum
          AND   rspos = ls_change_res_kzear-rspos
          AND   rsart = ls_change_res_kzear-rsart.          "411472
  ENDLOOP.

* Clear change tables after pt_goitem update
  CLEAR: pt_change_po_elikz,
         pt_change_ord_elikz,
         pt_change_res_kzear.
ENDMETHOD.                    "change_elikz_all_items

*----------------------------------------------------------------------*
* METHOD CHANGE_ELIKZ_LATER
* if elikz or kzear is changed in one item, it has to be changed later
* for all items of the same PO/order/reservation item
* In this method we create an entry in the change table.
* The entries are inserted during line_check.
* The mass change is done in change_all_items with method
* change_elikz_all_items.
* The key fields have to be filled by caller.
* We only make inserts, so the first change will be the right one.
*----------------------------------------------------------------------*
METHOD change_elikz_later.
  IF NOT is_change_po_elikz IS INITIAL.
    INSERT is_change_po_elikz INTO TABLE pt_change_po_elikz.
  ENDIF.
  IF NOT is_change_ord_elikz IS INITIAL.
    INSERT is_change_ord_elikz INTO TABLE pt_change_ord_elikz.
  ENDIF.
  IF NOT is_change_res_kzear IS INITIAL.
    INSERT is_change_res_kzear INTO TABLE pt_change_res_kzear.
  ENDIF.
ENDMETHOD.                    "change_elikz_later

************************************************************************
*   Change_quantity_all_items
*   Changes of conversion factors for batches.
************************************************************************
METHOD change_quantity_all_items.
*   adapt changed conversion factors to all related items
  DATA: ls_change_batch TYPE ty_s_change_batch,
        l_batch_level   TYPE tcuch-kzdch.

  FIELD-SYMBOLS: <ls_goitem> TYPE goitem.

  l_batch_level   = lcl_migo_globals=>batch_level.

* Change new quantity MENGE for all items with the same batch
* by calling the unit_conversion for pt_change_batch_uom entries
  IF NOT pt_change_batch_uom IS INITIAL.
    LOOP AT pt_change_batch_uom INTO ls_change_batch.

      CASE l_batch_level.
        WHEN '0'.                      "batch level at plant level
*         whole key is needed
          LOOP AT pt_goitem ASSIGNING <ls_goitem>
              WHERE charg = ls_change_batch-charg
                AND matnr = ls_change_batch-matnr
                AND werks = ls_change_batch-werks.
            CALL METHOD unit_conversion
              CHANGING
                cs_goitem = <ls_goitem>.
          ENDLOOP.
        WHEN '1'.                      "batch level at material level
*          key for batch is material and batch number
          LOOP AT pt_goitem ASSIGNING <ls_goitem>
              WHERE charg = ls_change_batch-charg
                AND matnr = ls_change_batch-matnr.
            CALL METHOD unit_conversion
              CHANGING
                cs_goitem = <ls_goitem>.
          ENDLOOP.
        WHEN '2'.                      "batch level at mandt level
*       key for batch is batchnumber only
          LOOP AT pt_goitem ASSIGNING <ls_goitem>
              WHERE charg = ls_change_batch-charg.
            CALL METHOD unit_conversion
              CHANGING
                cs_goitem = <ls_goitem>.
          ENDLOOP.
        WHEN OTHERS.
      ENDCASE.

    ENDLOOP.
  ENDIF.

  CLEAR pt_change_batch_uom.
ENDMETHOD.                    "change_quantity_all_items



************************************************************************
*   Change_quantity_later.
*   New conversion factor from batch classification --> adapt all
*   other lines with this batch later on.
************************************************************************
METHOD change_quantity_later.
*   create change table for quantity
  DATA: l_batch_level   TYPE tcuch-kzdch,
        ls_change_batch TYPE ty_s_change_batch.

  l_batch_level   = lcl_migo_globals=>batch_level.
  ls_change_batch = is_change_batch.

*  set right key depending on batch level
  CASE l_batch_level.
    WHEN '0'.                          "batch level at plant level
*       whole key is needed
    WHEN '1'.                          "batch level at material level
*       key for batch is material and batch number
      CLEAR ls_change_batch-werks.
    WHEN '2'.                          "batch level at mandt level
*       key for batch is batchnumber only
      CLEAR: ls_change_batch-werks, ls_change_batch-matnr.
    WHEN OTHERS.
  ENDCASE.

  IF NOT ls_change_batch IS INITIAL.
    INSERT ls_change_batch INTO TABLE pt_change_batch_uom.
  ENDIF.

ENDMETHOD.                    "change_quantity_later

************************************************************************
*   change_batch_all_items
*   Changes of batch master data
*   note 624076
************************************************************************
METHOD change_batch_all_items.
*- adapt changed batch data to all related items
  DATA:
    ls_change_batch         TYPE ty_s_change_batch,
    ls_mcha                 TYPE mcha,
    ls_batch_act_data       TYPE ty_s_batch_relevant_data,
    ls_batch_act_trans_data TYPE ty_s_batch_relevant_trans_data.

  FIELD-SYMBOLS:
    <ls_goitem>             TYPE goitem.

  IF NOT pt_change_batch IS INITIAL.
    LOOP AT pt_change_batch
      INTO ls_change_batch.

      CALL FUNCTION 'VB_BATCH_READ_BUFFER_DB'
        EXPORTING
          matnr            = ls_change_batch-matnr
          charg            = ls_change_batch-charg
          werks            = ls_change_batch-werks
          read_from_buffer = x
          read_from_db     = space
        IMPORTING
          batch_buffer     = ls_mcha
        EXCEPTIONS
          OTHERS           = 99.
      CHECK sy-subrc IS INITIAL.

      MOVE-CORRESPONDING ls_mcha
        TO ls_batch_act_data.
      ls_batch_act_trans_data = ls_batch_act_data.

*- batch level at plant level
      IF lcl_migo_globals=>batch_level EQ '0'.
        LOOP AT pt_goitem
          ASSIGNING <ls_goitem>
          WHERE charg EQ ls_change_batch-charg
            AND matnr EQ ls_change_batch-matnr
            AND werks EQ ls_change_batch-werks.
          MOVE-CORRESPONDING ls_batch_act_data
            TO <ls_goitem>.
        ENDLOOP.
        IF s_action-migo_mode EQ 'GT'.
          LOOP AT pt_goitem
            ASSIGNING <ls_goitem>
            WHERE umcha EQ ls_change_batch-charg
              AND ummat EQ ls_change_batch-matnr
              AND umwrk EQ ls_change_batch-werks.
            MOVE-CORRESPONDING ls_batch_act_trans_data
              TO <ls_goitem>.
          ENDLOOP.
        ENDIF.
*- batch level at material or client level
      ELSE.
*- key for batch is material and batch number
        LOOP AT pt_goitem
          ASSIGNING <ls_goitem>
          WHERE charg EQ ls_change_batch-charg
            AND matnr EQ ls_change_batch-matnr.
          MOVE-CORRESPONDING ls_batch_act_data
            TO <ls_goitem>.
        ENDLOOP.
        IF s_action-migo_mode EQ 'GT'.
          LOOP AT pt_goitem
            ASSIGNING <ls_goitem>
            WHERE umcha EQ ls_change_batch-charg
              AND ummat EQ ls_change_batch-matnr.
            MOVE-CORRESPONDING ls_batch_act_trans_data
              TO <ls_goitem>.
          ENDLOOP.
        ENDIF.
      ENDIF.

    ENDLOOP.
  ENDIF.

  CLEAR pt_change_batch.

ENDMETHOD.                    "change_batch_all_items

************************************************************************
*   change_batch_later.
*   New batch master data --> adapt all
*   other lines with this batch later on.
*   note 624076
************************************************************************
METHOD change_batch_later.
*- create change table for quantity
  DATA:
    ls_change_batch TYPE ty_s_change_batch.

  ls_change_batch = is_batch_key.

*- set right key depending on batch level
*- batch level at material/client level
  IF lcl_migo_globals=>batch_level NE '0'.
    CLEAR ls_change_batch-werks.
  ENDIF.

  CHECK NOT ls_change_batch IS INITIAL.

  INSERT ls_change_batch
    INTO TABLE pt_change_batch.

ENDMETHOD.                    "change_batch_later

************************************************************************
* Set the change flag for a line
************************************************************************
METHOD change_takeit_later.
  DATA: ls_change_takeit TYPE ty_s_change_takeit.
  ls_change_takeit-glc    = i_glc.
  ls_change_takeit-takeit = i_takeit.
* Insert the data. If it already exists, modify the entry.
* I can't imagine a case in which LINE_CHECK is called twice
* within the same PAI, but in R/3 you can never know...
  INSERT ls_change_takeit INTO TABLE pt_change_takeit.
  IF sy-subrc <> 0.
    MODIFY TABLE pt_change_takeit FROM ls_change_takeit.
  ENDIF.
ENDMETHOD.                    "change_takeit_later

************************************************************************
* Execute the recursive change of the TAKEIT-indicator
************************************************************************
METHOD change_takeit_all_items.
  DATA: ls_change_takeit TYPE ty_s_change_takeit.
* Process items in the buffer table if it is empty
  DO.
    READ TABLE pt_change_takeit INTO ls_change_takeit INDEX 1.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    CALL METHOD change_takeit_process
      EXPORTING
        i_glc    = ls_change_takeit-glc
        i_takeit = ls_change_takeit-takeit.
  ENDDO.
* Refresh buffer to be ready for the next shot
  CLEAR pt_change_takeit.
ENDMETHOD.                    "change_takeit_all_items

************************************************************************
* Change recursively
************************************************************************
METHOD change_takeit_process.
  FIELD-SYMBOLS: <ls_goitem> TYPE goitem.

* Delete this line in the worklist as we are now processing it
  DELETE TABLE pt_change_takeit WITH TABLE KEY glc = i_glc.
* Execute the change
  READ TABLE pt_goitem ASSIGNING <ls_goitem>
             WITH TABLE KEY global_counter = i_glc.
  CHECK sy-subrc = 0.
  <ls_goitem>-take_it = i_takeit.
* Loop over all chilren and do the same
  LOOP AT pt_goitem ASSIGNING <ls_goitem> WHERE parent = i_glc.
    CALL METHOD change_takeit_process
      EXPORTING
        i_glc    = <ls_goitem>-global_counter
        i_takeit = i_takeit.
  ENDLOOP.
  IF NOT <ls_goitem>-xgatype IS INITIAL.
    CALL METHOD ga_line_modify( <ls_goitem> ).
  ENDIF.
ENDMETHOD.                    "change_takeit_process

************************************************************************
* Execute the recursive change fields of childen items according to the
* parent item
************************************************************************
METHOD change_children.
  DATA: ls_change_children TYPE ty_s_change_children.
  CHECK NOT pt_change_children IS INITIAL.
  SORT pt_change_children BY glc.
* Process items in the buffer table if it is empty
  DO.
    READ TABLE pt_change_children INTO ls_change_children INDEX 1.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    CALL METHOD change_children_process
      EXPORTING
        i_glc       = ls_change_children-glc
        i_fieldname = ls_change_children-fieldname.
  ENDDO.
* Refresh buffer to be ready for the next shot
  CLEAR pt_change_children.
ENDMETHOD.                    "change_children

************************************************************************
* Change recursively
************************************************************************
METHOD change_children_process.
  FIELD-SYMBOLS: <l_value_source> TYPE ANY,
                 <l_value_target> TYPE ANY.
  DATA: l_sourceline     TYPE sytabix,
        l_targetline     TYPE sytabix,
        ls_source_goitem TYPE goitem,
        ls_target_goitem TYPE goitem,
        l_field          TYPE scrfname,
        l_field_source   TYPE scrfname,
        l_field_target   TYPE scrfname,
        l_status         TYPE migo_fs_status,
        l_checkfield     TYPE migo_fieldname.

* Delete this line in the worklist as we are now processing it
  DELETE TABLE pt_change_children WITH TABLE KEY glc = i_glc.
* Execute the change
  READ TABLE pt_goitem INTO ls_target_goitem
             WITH TABLE KEY global_counter = i_glc.
  CHECK sy-subrc = 0.
  l_targetline = sy-tabix.
  READ TABLE pt_goitem INTO ls_source_goitem
             WITH TABLE KEY global_counter = ls_target_goitem-parent.
  CHECK: sy-subrc = 0, ls_source_goitem-expand <> space.
  . l_sourceline = sy-tabix.
  IF i_fieldname = 'GOITEM-PARENT'.
    DELETE pt_goitem WHERE parent  = ls_source_goitem-global_counter.
    IF ls_source_goitem-expand = c_icon_collapse.
      ls_source_goitem-expand = c_icon_expand.
      MODIFY pt_goitem FROM ls_source_goitem INDEX l_sourceline
        TRANSPORTING expand.
      CALL METHOD line_expand( l_sourceline ).
    ENDIF.
    EXIT.
  ENDIF.

  l_field      = i_fieldname.
  l_checkfield = l_field.
  CASE l_field.
    WHEN 'GOITEM-MAKTX'.            l_field = 'GOITEM-MATNR'.
    WHEN 'GOITEM-NAME1'.            l_field = 'GOITEM-WERKS'.
    WHEN 'GOITEM-LGOBE'.            l_field = 'GOITEM-LGORT'.
    WHEN 'GOITEM-VENDORNAME'.       l_field = 'GOITEM-LIFNR'.
    WHEN 'GOITEM-CUSTNAME'.         l_field = 'GOITEM-KUNNR'.
    WHEN 'GOITEM-MAT_VENDORNAME'.   l_field = 'GOITEM-MAT_LIFNR'.
    WHEN 'GOITEM-MAT_CUSTNAME'.     l_field = 'GOITEM-MAT_KUNNR'.
    WHEN 'GOITEM-UMMAKTX'.          l_field = 'GOITEM-UMMAT'.
    WHEN 'GOITEM-UMNAME1'.          l_field = 'GOITEM-UMWRK'.
    WHEN 'GOITEM-UMLGOBE'.          l_field = 'GOITEM-UMLGO'.
    WHEN 'GOITEM-UMMAT_VENDORNAME'. l_field = 'GOITEM-UMMAT_LIFNR'.
    WHEN 'GOITEM-UMMAT_CUSTNAME'.   l_field = 'GOITEM-UMMAT_KUNNR'.
    WHEN 'GODYNPRO-DETAIL_TAKE'.    l_field = 'GOITEM-TAKE_IT'.         "965675
  ENDCASE.
  CONCATENATE 'LS_SOURCE_' l_field INTO l_field_source.
  CONCATENATE 'LS_TARGET_' l_field INTO l_field_target.
  ASSIGN (l_field_source) TO <l_value_source>.
  CHECK sy-subrc = 0.
*   Overwrite the selected field with the new value
  ASSIGN (l_field_target) TO <l_value_target>.
  CHECK sy-subrc = 0.
  <l_value_target> = <l_value_source>.
* Update the model
  CALL METHOD lcl_migo_globals=>kernel->line_modify
    EXPORTING
      i_tabix           = l_targetline
      i_authority_check = abap_false
      i_status_delayed  = abap_true
    CHANGING
      cs_goitem         = ls_target_goitem.
* Derive new status
  CALL METHOD lcl_migo_globals=>kernel->status_derive.
ENDMETHOD.                    "change_children_process