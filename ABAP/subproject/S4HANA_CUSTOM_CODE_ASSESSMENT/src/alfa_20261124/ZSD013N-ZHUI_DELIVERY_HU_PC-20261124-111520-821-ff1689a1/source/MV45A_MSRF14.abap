*----------------------------------------------------------------------*
***INCLUDE MV45A_MSRF14 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  F4_REPLACE_UNIT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM f4_replace_unit .

  DATA: lv_output_unit  TYPE meins,
        lv_replace_qty  TYPE msr_replace_qty.

  CALL FUNCTION 'MATERIAL_UNIT_CONVERSION'
    EXPORTING
      input  = gs_msr_sales_item-replace_qty
      matnr  = msr_s_sales_item-replace_matnr
      meinh  = msr_s_sales_item-replace_unit
    IMPORTING
      meins  = lv_output_unit
      output = lv_replace_qty
    EXCEPTIONS
      OTHERS = 0.                                       "#EC ARGCHECKED

  CALL FUNCTION 'RV_HELP'
    EXPORTING
      key      = msr_s_sales_item-replace_matnr
      key2     = lv_output_unit
      key3     = da_vtber
      key4     = da_kunnr
      key5     = da_infls
      number   = '001'
      trtyp    = t180-trtyp
      field_in = gs_msr_sales_item-replace_unit
    IMPORTING
      field    = gs_msr_sales_item-replace_unit.

ENDFORM.                    " F4_REPLACE_UNIT