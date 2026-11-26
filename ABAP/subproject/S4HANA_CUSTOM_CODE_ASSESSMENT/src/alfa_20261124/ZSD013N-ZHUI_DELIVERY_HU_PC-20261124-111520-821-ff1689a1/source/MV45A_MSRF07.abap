*----------------------------------------------------------------------*
***INCLUDE MV45A_MSRF07 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  MSR_READ_MATNR_TXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM msr_get_matnr_txt .

  CALL METHOD cl_msr_trc_helper=>get_matnr_text
    EXPORTING
      iv_matnr = gs_msr_sales_item-replace_matnr
    IMPORTING
      ev_maktx = gs_msr_sales_item-replace_matnrtxt.

ENDFORM.                    " MSR_READ_MATNR_TXT