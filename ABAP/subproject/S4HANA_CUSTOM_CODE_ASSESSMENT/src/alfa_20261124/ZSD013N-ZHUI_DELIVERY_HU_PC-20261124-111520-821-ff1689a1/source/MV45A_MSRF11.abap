*&---------------------------------------------------------------------*
*&      Form  msr_map_fields_pbo
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM msr_map_fields_pbo .
  CHECK tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_ro.
  msr_s_sales_item-replace_matnr      = gs_msr_sales_item-replace_matnr.
  msr_s_sales_item-replace_matnrtxt  = gs_msr_sales_item-replace_matnrtxt.
  msr_s_sales_item-replace_unit       = gs_msr_sales_item-replace_unit.
  msr_s_sales_item-paying_plant       = gs_msr_sales_item-paying_plant.
ENDFORM.                    " MSR_MAP_FIELDS_PBO