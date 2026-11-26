*----------------------------------------------------------------------*
*   INCLUDE LMIGOKS2                                                   *
*----------------------------------------------------------------------*

************************************************************************
* Shipping elements
************************************************************************
METHOD shippingelement_select.
  DATA: ls_vepwe TYPE ty_s_vepwe,
        lt_vepwe TYPE ty_t_vepwe.

  CLEAR et_vepwe.

  CALL FUNCTION 'MB_SELECT_SHIPPING_UNITS'
    EXPORTING
      i_vbeln            = i_vbeln
    TABLES
      t_vepwe            = et_vepwe
    EXCEPTIONS
      no_shipping_units  = 1
      ccode_missing      = 2
      delivery_not_found = 3
      OTHERS             = 4.
  IF sy-subrc <> 0.
    def_msg_add oref_doc_log sy-msgty sy-msgid sy-msgno
                             sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    EXIT.
  ENDIF.
ENDMETHOD.

************************************************************************
* Shipping contructions
************************************************************************
METHOD shipping_construction_maintain.
  DATA: ls_goitem TYPE goitem,
        l_display TYPE ty_s_action-display,
        l_evere   TYPE goitem-evere.
* get the current line
  CALL METHOD line_get
              EXPORTING i_line   = i_line
              IMPORTING es_goitem = ls_goitem.
  IF s_action-display = abap_true OR
     s_action-cancel  = abap_true.
    l_display = x.
  ENDIF.
  CALL FUNCTION 'ME_SHIPPING_INSTRUCTIONS'
       EXPORTING
            i_cuatx = text-200
            i_evers = ls_goitem-evers
            i_evere = ls_goitem-evere
            display = l_display
            dircall = abap_true
       IMPORTING
            e_evere = l_evere.
  IF l_display = space.
    ls_goitem-evere = l_evere.
  ENDIF.
* modify the data in goitem
  CALL METHOD line_modify
              EXPORTING i_line            = i_line
                        i_authority_check = abap_false
              CHANGING  cs_goitem         = ls_goitem.
ENDMETHOD.