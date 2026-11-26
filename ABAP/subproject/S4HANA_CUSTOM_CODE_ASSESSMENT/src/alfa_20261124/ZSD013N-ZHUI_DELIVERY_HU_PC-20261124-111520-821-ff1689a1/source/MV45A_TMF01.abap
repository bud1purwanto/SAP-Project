*----------------------------------------------------------------------*
***INCLUDE MV45A_TMF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  TM_INIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM tm_init .

  DATA:
    lv_doc_type        TYPE tms_doc_type,
    lv_doc_nr          TYPE tms_doc_nr,
    ls_tms_c_control_t TYPE tms_c_control_t.

  CALL METHOD cl_tm_sales=>create_instance
    EXPORTING
      is_vbak     = vbak
    IMPORTING
      er_tm_sales = gr_tm_sales.

  IF gr_tm_sales IS BOUND.
    gv_tm_ctrl_key = vbak-tm_ctrl_key.
    SELECT SINGLE * FROM tms_c_control_t INTO ls_tms_c_control_t WHERE
                            tm_ctrl_key = gv_tm_ctrl_key AND
                            spras       = sy-langu.
    gv_tm_ctrl_key_desc = ls_tms_c_control_t-tm_ctrl_key_desc.

    IF gr_tm_docflow IS BOUND.
      gr_tm_docflow->clear_docflow( ).
    ENDIF.

    IF vbak-vbtyp eq 'C'.  " Sales Order
      gv_tm_doc_type = if_tms_docflow_c=>doc_type_so.
    ELSE.                  " Customer Returns
      gv_tm_doc_type = if_tms_docflow_c=>doc_type_ro.
    ENDIF.
    gv_tm_doc_nr   = vbak-vbeln.
    gr_tm_docflow = cl_tms_docflow_data=>get_instance_for_application(
                                        iv_doc_type   = gv_tm_doc_type
                                        iv_doc_nr     = gv_tm_doc_nr ).

    IF g_tm_cont_head IS NOT INITIAL.
      g_tm_cont_head->free( ).
      CLEAR g_tm_cont_head.
    ENDIF.
    IF g_tm_cont_item IS NOT INITIAL.
      g_tm_cont_item->free( ).
      CLEAR g_tm_cont_item.
    ENDIF.

  ENDIF.

ENDFORM.                    " TM_INIT