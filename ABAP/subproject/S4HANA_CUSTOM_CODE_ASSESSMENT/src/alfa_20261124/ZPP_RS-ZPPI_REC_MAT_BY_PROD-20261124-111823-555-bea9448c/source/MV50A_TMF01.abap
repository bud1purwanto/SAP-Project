*----------------------------------------------------------------------*
***INCLUDE MV50A_TMF01 .
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

  CALL METHOD cl_tm_delivery=>create_instance
    EXPORTING
      is_likp        = likp
    IMPORTING
      er_tm_delivery = gr_tm_delivery.

  IF gr_tm_delivery IS BOUND.
    gv_tm_ctrl_key = likp-tm_ctrl_key.
    SELECT SINGLE * FROM tms_c_control_t INTO ls_tms_c_control_t WHERE
                            tm_ctrl_key = gv_tm_ctrl_key AND
                            spras       = sy-langu.
    gv_tm_ctrl_key_desc = ls_tms_c_control_t-tm_ctrl_key_desc.

    IF gr_tm_docflow IS BOUND.
      gr_tm_docflow->clear_docflow( ).
    ENDIF.

    CASE likp-vbtyp.
      WHEN '7'.
        gv_tm_doc_type = if_tms_docflow_c=>doc_type_ibdlv.
      WHEN 'g'.
        gv_tm_doc_type = if_tms_docflow_c=>doc_type_ibdlv.
      WHEN 'T'.
        gv_tm_doc_type = if_tms_docflow_c=>doc_type_obdlv.
      WHEN 'J'.
        gv_tm_doc_type = if_tms_docflow_c=>doc_type_obdlv.
    ENDCASE.

    gv_tm_doc_nr   = likp-vbeln.
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