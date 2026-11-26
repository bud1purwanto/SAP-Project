*&---------------------------------------------------------------------*
*&      Form  msr_default_replace_fields
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM msr_set_replace_defaults.

* set defaults for replacement fields
* refund type = 1 = Replacement Material
  CHECK gs_msr_sales_item-refund_type IS NOT INITIAL AND
        vbap-posnr IS NOT INITIAL.

  IF gs_msr_sales_item-replace_qty   IS INITIAL AND
     gs_msr_sales_item-replace_matnr IS INITIAL AND
     gs_msr_sales_item-replace_unit  IS INITIAL AND
     gs_msr_sales_item-paying_plant  IS INITIAL.

    gs_msr_sales_item-replace_qty   = rv45a-kwmeng.
    IF NOT kopieren IS INITIAL.
      gs_msr_sales_item-replace_qty = cvbap-orfmng.
    ENDIF.
    gs_msr_sales_item-replace_unit  = vbap-vrkme.
    gs_msr_sales_item-replace_matnr = vbap-matnr.
    msr_s_sales_item-replace_matnr  = vbap-matnr.
    gs_msr_sales_item-paying_plant  = vbap-werks.
    msr_s_sales_item-paying_plant   = vbap-werks.
    MESSAGE s107(cx_msr_trc).
  ENDIF.

ENDFORM.                    "msr_set_replace_defaults

*&---------------------------------------------------------------------*
*&      Form  msr_set_nfu_defaults
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM msr_set_nfu_defaults.
ENDFORM.                  "msr_set_nfu_defaults