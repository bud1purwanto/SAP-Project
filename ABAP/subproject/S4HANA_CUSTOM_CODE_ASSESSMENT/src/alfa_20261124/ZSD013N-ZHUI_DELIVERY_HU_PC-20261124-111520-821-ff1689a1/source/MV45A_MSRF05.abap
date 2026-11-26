*&---------------------------------------------------------------------*
*&  Include           MV45A_MSRF05
*&---------------------------------------------------------------------*
*&  subroutines for F4-help / filling dropdown listboxes
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  F4_FU_CODE
*&---------------------------------------------------------------------*
FORM f4_fu_code.

  DATA:
    lt_fu_codes         TYPE msr_t_codes.

* Only if sales class of Advanced Returns was instantiated
  IF gr_msr_sales IS NOT BOUND.
    RETURN.
  ENDIF.
* Get valid codes
  gr_msr_sales->get_fu_codes(
    EXPORTING
      is_vbap = vbap
      is_vbak = vbak
    IMPORTING
      et_fu_codes = lt_fu_codes ).
* Set F4 help
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
ENDFORM.                    " F4_FU_CODE

*&---------------------------------------------------------------------*
*&      Form  F4_INSP_CODE
*&---------------------------------------------------------------------*
FORM f4_insp_code.
  DATA:
    lt_insp_codes TYPE msr_t_insp_codes.

* Only if sales class of Advanced Returns was instantiated
  IF gr_msr_sales IS NOT BOUND.
    RETURN.
  ENDIF.
* Get valid codes
  gr_msr_sales->get_insp_codes(
    EXPORTING
      iv_language   = sy-langu
    IMPORTING
      et_insp_codes = lt_insp_codes ).
  SORT lt_insp_codes.
* Set F4 help
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CODE'
      value_org       = chars
    TABLES
      value_tab       = lt_insp_codes
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.                    " F4_INSP_CODE

*&---------------------------------------------------------------------*
*&      Form  F4_INSP_CODE_CUST
*&---------------------------------------------------------------------*
FORM f4_insp_code_cust.
  DATA:
    lt_insp_codes_cust TYPE msr_t_insp_codes.

* Only if sales class of Advanced Returns was instantiated
  IF gr_msr_sales IS NOT BOUND.
    RETURN.
  ENDIF.
* Get valid codes
  gr_msr_sales->get_insp_codes_cust(
    EXPORTING
      iv_language   = sy-langu
    IMPORTING
      et_insp_codes_cust = lt_insp_codes_cust ).
  SORT lt_insp_codes_cust.
* Set F4 help
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'CODE'
      value_org       = chars
    TABLES
      value_tab       = lt_insp_codes_cust
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.
ENDFORM.                    " F4_INSP_CODE_CUST