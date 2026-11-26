*----------------------------------------------------------------------*
*   INCLUDE LMIGODO2                                                   *
*   Detail object implementation
*----------------------------------------------------------------------*

CLASS lcl_migo_detailobject IMPLEMENTATION.

************************************************************************
* If the cursor is in this object, what's the current line
************************************************************************
METHOD cursor_position_resolve.
  e_name  = 'DETAIL'.                                        "#EC NEEDED
  e_tabix = oref_detail->current_line.
ENDMETHOD.

************************************************************************
* PBO: Cursor position information
*      Dynpro modification
************************************************************************
METHOD pbo.
  DATA: l_glc TYPE migo_global_counter.
* GLC to access fieldselection. From GOITEM or template.
  l_glc = goitem-global_counter.
  IF l_glc IS INITIAL.
    l_glc = lcl_migo_screenmodification=>c_item_template.
  ENDIF.
  CALL METHOD super->pbo
    EXPORTING i_global_counter = l_glc.
* CALL METHOD lcl_migo_screenmodification=>screen_modify_detail
*                                          EXPORTING is_goitem = goitem.
* CALL METHOD lcl_migo_screenmodification=>screen_modify_push
*                                          EXPORTING is_goitem = goitem.
ENHANCEMENT-POINT LMIGODO2_01 SPOTS ES_SAPLMIGO.
ENDMETHOD.

ENDCLASS.