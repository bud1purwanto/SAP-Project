*&---------------------------------------------------------------------*
*&  Include           LMIGOKL3                                         *
*&---------------------------------------------------------------------*

************************************************************************
* METHOD line_modify_badi:
* Call BAdI MB_MIGO_BADI with changing parameter GOITEM. After that
* check all fields of GOITEM for unallowed changes.
************************************************************************
METHOD line_modify_badi.
  DATA: descr_ref       TYPE REF TO cl_abap_structdescr,
        ls_goitem_badi  TYPE goitem,
        ls_new_goitem   TYPE goitem,
        l_change        TYPE abap_bool,
        l_status        TYPE migo_fs_status,
        l_name1(50)     TYPE c,
        l_name2(50)     TYPE c,
        l_fieldname     TYPE migo_fieldname.
  FIELD-SYMBOLS: <comp> TYPE abap_compdescr,
                 <f1>   TYPE ANY,
                 <f2>   TYPE ANY.
* Process method only if there is an active implementation
  CHECK NOT lcl_migo_globals=>if_badi IS INITIAL.           "552774

* Call BAdI
  ls_goitem_badi = cs_goitem.
  CALL METHOD lcl_migo_globals=>if_badi->line_modify
    EXPORTING
      i_line_id = ls_goitem_badi-global_counter
    CHANGING
      cs_goitem = ls_goitem_badi.

* Are there any changes?
* - If NO:  Leave this method.
* - If YES: Check fieldselection, whether field is 'visible + input'.
  CHECK cs_goitem <> ls_goitem_badi.

* Are we in display mode?                                    "1477221
* - If YES: ignore changes and leave                         "1477221
* - If NO:  process the checks                               "1477221
  CHECK s_action-display IS INITIAL.                         "1477221

  descr_ref ?= cl_abap_typedescr=>describe_by_data( ls_goitem_badi ).
  LOOP AT descr_ref->components ASSIGNING <comp>.
*   Following fields are checked in method line_badi_special_fields
    CHECK NOT <comp>-name = 'LGORT'.
    CHECK NOT <comp>-name = 'LGOBE'.
    CHECK NOT <comp>-name = 'WERKS'.
    CHECK NOT <comp>-name = 'NAME1'.
    CHECK NOT <comp>-name = 'MATNR'.
    CHECK NOT <comp>-name = 'MAKTX'.
    CHECK NOT <comp>-name = 'LIFNR'.
    CHECK NOT <comp>-name = 'VENDORNAME'.
    CHECK NOT <comp>-name = 'KUNNR'.
    CHECK NOT <comp>-name = 'CUSTNAME'.
    CONCATENATE 'CS_GOITEM-'      <comp>-name INTO l_name1.
    CONCATENATE 'LS_GOITEM_BADI-' <comp>-name INTO l_name2.
    ASSIGN (l_name1) TO <f1>.
    ASSIGN (l_name2) TO <f2>.
    IF <f1> <> <f2>.
      l_fieldname = <comp>-name.
      CONCATENATE 'GOITEM-' <comp>-name INTO l_fieldname.
      CALL METHOD lcl_migo_screenmodification=>get
        EXPORTING
          i_field          = l_fieldname
          i_global_counter = cs_goitem-global_counter
          i_badi           = x
        RECEIVING
          r_status         = l_status.
      CASE l_status.
*       Field is 'visible + input' (-> change in BAdI allowed)
        WHEN 6.
          <f1> = <f2>.
          l_change = x.
*       Field is not used on any screen in MIGO
        WHEN 8.
ENHANCEMENT-SECTION     lmigokl3_01 SPOTS es_saplmigo.
          IF s_action-display IS INITIAL.                  "1477221
*            issue message only if not in display mode     "1477221
             MESSAGE w049 WITH l_fieldname.
          ENDIF.                                           "1477221
END-ENHANCEMENT-SECTION.
*       Field was not 'on input' (l_status = 0 or 2)
        WHEN OTHERS.
ENHANCEMENT-SECTION     lmigokl3_02 SPOTS es_saplmigo.
          IF s_action-display IS INITIAL.                  "1477221
*            issue message only if not in display mode     "1477221
             MESSAGE w050 WITH l_fieldname.
          ENDIF.                                           "1477221
END-ENHANCEMENT-SECTION.
      ENDCASE.
    ENDIF.
  ENDLOOP.
* Check changes of special fields
  CALL METHOD line_badi_special_fields
    EXPORTING
      is_goitem_badi = ls_goitem_badi
    CHANGING
      c_change       = l_change
      cs_goitem      = cs_goitem.

  IF l_change = abap_true.
*   In case of allowed changes of GOITEM-fields in BAdI, the derive of
*   dependent data and all checks have to be done again.
*   A recursiv call of LINE_MODIFY is not useful (-> Danger of: Double
*   entries in PT_GOITEM or 'Endless Loop')
    ls_new_goitem = cs_goitem.
    CHECK line_add_authority_check( ls_new_goitem ) = abap_true.
*   Checks on the item level
    CALL METHOD line_check
      EXPORTING
        is_old_goitem = ls_new_goitem
      CHANGING
        cs_goitem     = cs_goitem.
  ENDIF.
ENDMETHOD.                    "line_modify_badi

************************************************************************
* METHOD line_modify_badi2:
*   Call BAdI MB_MIGO_ITEM_BADI with changing parameter GOITEM.
*   Following fields can be changed by this BADI:
*   - LGORT (Storage location)
*   - SGTXT (Item Text)
************************************************************************
METHOD line_modify_badi2.
  DATA: l_stge_loc          TYPE goitem-lgort,
        l_item_text         TYPE goitem-sgtxt,
        lt_badi_return      TYPE ty_t_bapiret2,
        ls_badi_return      TYPE bapiret2,
        l_fieldname         TYPE migo_fieldname,
        l_status            TYPE migo_fs_status,
        ls_got001l          TYPE got001l.

* Process method only if there is an active implementation
  CHECK NOT lcl_migo_globals=>if_badi_item IS INITIAL.      "552774

* Do not process when a material document is being displayed   "n1020876
  CHECK s_action-display is initial.                           "n1020876

* Delete any old messages from the log that have been added for the
* current item
  CALL METHOD oref_badi_log->messages_delete_for_item
    EXPORTING
      i_global_counter = cs_goitem-global_counter.

* Call BAdI MB_MIGO_ITEM_BADI
  CALL METHOD lcl_migo_globals=>if_badi_item->item_modify
    EXPORTING
      is_goitem   = cs_goitem
      is_gohead   = ps_gohead
    IMPORTING
      e_stge_loc  = l_stge_loc
      e_item_text = l_item_text
      et_return   = lt_badi_return.                         "ERP2005

* Add the messages returned by the badi to the oref_badi_log
* - at the time a reference document is being read regardless whether
*   the item has been selected if the message is an informative message
* - else do it only if the item has been selected
* This is to make sure that a message can at least be displayed
* once if i.e. storage locations are to be replaced when reference
* documents are being read to make sure that the user sees the
* changed locations before selecting the ones to be posted.
* For error messages this makes no sense, as it is not sure at this moment
* if the item is being selected and posted or not.
  LOOP AT lt_badi_return INTO ls_badi_return.

    IF  ( okcode IS INITIAL AND NOT
          ( ls_badi_return-type = 'E' OR
            ls_badi_return-type = 'A' OR
            ls_badi_return-type = 'X'
          )
         ) OR
        NOT cs_goitem-take_it IS INITIAL.

      CALL METHOD oref_badi_log->context_set
        EXPORTING
          i_global_counter = cs_goitem-global_counter.

      CALL METHOD oref_badi_log->message_add
        EXPORTING
          i_msgty = ls_badi_return-type
          i_msgid = ls_badi_return-id
          i_msgno = ls_badi_return-number
          i_msgv1 = ls_badi_return-message_v1
          i_msgv2 = ls_badi_return-message_v2
          i_msgv3 = ls_badi_return-message_v3
          i_msgv4 = ls_badi_return-message_v4.
    ENDIF.

  ENDLOOP.


* STORAGE LOCATION
  IF NOT l_stge_loc IS INITIAL AND ( cs_goitem-lgort <> l_stge_loc ) .
*   In MIGO LGOBE and not LGORT has to be checked as you enter the
*   storage location into field LGOBE.
    l_fieldname = 'GOITEM-LGOBE'.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = l_fieldname
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    CASE l_status.
*     Field is 'visible + input' (-> change in BAdI allowed)
      WHEN 6.
        cs_goitem-lgort = l_stge_loc.
*       Read storage location
        CLEAR ls_got001l.
        CALL METHOD lcl_migo_buffer=>storage_loc_get
          EXPORTING
            i_plant       = cs_goitem-werks
            i_storage_loc = cs_goitem-lgort
          RECEIVING
            e_storage_loc = ls_got001l
          EXCEPTIONS
            OTHERS        = 1.
        cs_goitem-lgobe = ls_got001l-lgobe.
*       Determine if new storage location is WM managed.       "n1090278
*       if yes, get WM data and set WM tab in MIGO visible,    "n1090278
*       otherwise no changes                                   "n1090278
        CALL METHOD wm_data_prepare                            "n1090278
          CHANGING                                             "n1090278
            cs_goitem = cs_goitem.                             "n1090278
*     Field was not 'on input' (l_status = 0 or 2)
      WHEN OTHERS.
        MESSAGE w051 WITH 'LGORT'.
    ENDCASE.
  ENDIF.

* ITEM TEXT
  IF NOT l_item_text IS INITIAL AND ( cs_goitem-sgtxt <> l_item_text ).
    l_fieldname = 'GOITEM-SGTXT'.
    CALL METHOD lcl_migo_screenmodification=>get
      EXPORTING
        i_field          = l_fieldname
        i_global_counter = cs_goitem-global_counter
      RECEIVING
        r_status         = l_status.
    CASE l_status.
*     Field is 'visible + input' (-> change in BAdI allowed)
      WHEN 6.
        cs_goitem-sgtxt = l_item_text.
*     Field was not 'on input' (l_status = 0 or 2)
      WHEN OTHERS.
        MESSAGE w051 WITH 'SGTXT'.
    ENDCASE.
  ENDIF.
ENDMETHOD.                    "line_modify_badi2

************************************************************************
* METHOD line_badi_special_fields
************************************************************************
METHOD line_badi_special_fields.
  TYPES: BEGIN OF ty_s_fields,
           input_field TYPE migo_fieldname,
           check_field TYPE migo_fieldname,
         END OF ty_s_fields.
  FIELD-SYMBOLS: <f1> TYPE ANY,
                 <f2> TYPE ANY,
                 <f3> TYPE ANY,
                 <f4> TYPE ANY.
  DATA: lt_fields     TYPE STANDARD TABLE OF ty_s_fields,
        ls_fields     TYPE ty_s_fields,
        l_field1      TYPE migo_fieldname,
        l_field2      TYPE migo_fieldname,
        l_field3      TYPE migo_fieldname,
        l_field4      TYPE migo_fieldname,
        l_status      TYPE migo_fs_status.

* Fill internal table with 'special fields'
  ls_fields-input_field = 'LGORT'. ls_fields-check_field = 'LGOBE'.
  APPEND ls_fields TO lt_fields.
  ls_fields-input_field = 'WERKS'. ls_fields-check_field = 'NAME1'.
  APPEND ls_fields TO lt_fields.
  ls_fields-input_field = 'MATNR'. ls_fields-check_field = 'MAKTX'.
  APPEND ls_fields TO lt_fields.
  ls_fields-input_field = 'LIFNR'. ls_fields-check_field = 'VENDORNAME'.
  APPEND ls_fields TO lt_fields.
  ls_fields-input_field = 'KUNNR'. ls_fields-check_field = 'CUSTNAME'.
  APPEND ls_fields TO lt_fields.

* Check fieldselection for these 'special fields'
  LOOP AT lt_fields INTO ls_fields.
    CONCATENATE 'CS_GOITEM-'      ls_fields-input_field INTO l_field1.
    CONCATENATE 'IS_GOITEM_BADI-' ls_fields-input_field INTO l_field2.
    ASSIGN (l_field1) TO <f1>.
    ASSIGN (l_field2) TO <f2>.
    IF <f1> <> <f2>.
*     Field was changed in BAdI
      CONCATENATE 'GOITEM-' ls_fields-check_field INTO l_field3.
      CALL METHOD lcl_migo_screenmodification=>get
        EXPORTING
          i_field          = l_field3
          i_global_counter = cs_goitem-global_counter
          i_badi           = x
        RECEIVING
          r_status         = l_status.
      CASE l_status.
*       Field is 'visible + input' (-> change in BAdI allowed)
        WHEN 6.
          CONCATENATE 'CS_GOITEM-' ls_fields-check_field INTO l_field4.
          ASSIGN (l_field4) TO <f4>.
          <f1> = <f4> = <f2>.
          c_change = x.
*       Field was not 'on input' (l_status = 0 or 2)
        WHEN OTHERS.
          MESSAGE w050 WITH ls_fields-input_field.
      ENDCASE.
    ENDIF.
  ENDLOOP.

ENDMETHOD.                    "line_badi_special_fields