*&---------------------------------------------------------------------*
*&      Form  f4_nfu_code
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM f4_nfu_code .

  DATA: ls_insp_item   TYPE msr_s_insp_item,
        lt_fu_codes    TYPE msr_t_codes.


* request the follow-up codes from tracking
  CHECK cl_msr_insp=>gr_msr_insp IS BOUND.
  CALL METHOD cl_msr_insp=>gr_msr_insp->mr_trc_controller->get_valid_codes
    EXPORTING
      is_insp_item   = ls_insp_item
      iv_application = if_msr_trc_c=>gc_application_ro
    IMPORTING
      et_codes       = lt_fu_codes.

  SORT lt_fu_codes BY fu_code.
  DELETE lt_fu_codes WHERE fu_code = if_msr_trc_c=>gc_code_backtoplant.

* Set drop down list
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'FU_CODE'
      value_org       = chars
    TABLES
      value_tab       = lt_fu_codes
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  IF sy-subrc = 0.

  ENDIF.

ENDFORM.                    " F4_NFU_CODE