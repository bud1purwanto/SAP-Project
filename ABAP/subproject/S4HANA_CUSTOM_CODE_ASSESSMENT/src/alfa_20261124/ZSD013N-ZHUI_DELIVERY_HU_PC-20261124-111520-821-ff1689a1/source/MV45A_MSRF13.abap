*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM msr_map_fields_pai .
  CHECK tvak-vbtyp EQ if_msr_trc_c=>gc_doc_cat_ro.
  gs_msr_sales_item-replace_matnr   = msr_s_sales_item-replace_matnr.
  gs_msr_sales_item-paying_plant    = msr_s_sales_item-paying_plant.
ENDFORM.                    " MSR_MAP_FIELDS_PAI