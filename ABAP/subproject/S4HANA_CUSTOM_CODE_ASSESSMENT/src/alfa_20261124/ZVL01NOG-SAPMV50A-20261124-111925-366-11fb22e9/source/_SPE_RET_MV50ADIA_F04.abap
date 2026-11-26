*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50ADIA_F04
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  /spe/output_item_fields
*&---------------------------------------------------------------------*
FORM /spe/output_item_fields   TABLES   xlips
                                        xvbup
                                        xvbapf            "n_1245044
                               USING    is_likp      TYPE likp
                                        is_lips      TYPE lips
                               CHANGING cs_ret_dia   TYPE /spe/ret_dia.

  DATA: ls_cumulated_quantities TYPE /spe/ret_cumulated_quantities,
        ls_delivery_relations   TYPE /spe/ret_delivery_relations.

* Do not process empty table control lines                  "n_895494
  CHECK  is_lips-posnr <> '000000'.                         "n_895494

* Fill output structure for dynpro processing
  cs_ret_dia-vrkme         = lips-vrkme.
  cs_ret_dia-follow_up     = lips-spe_follow_up.
  cs_ret_dia-source_exidv  = lips-spe_lifexpos2+10(20).
  cs_ret_dia-source_dlv_no = lips-spe_lifexpos2(10).
  CONVERT TIME STAMP lips-spe_bxp_date_ext
                     TIME ZONE sy-zonlo
                     INTO DATE cs_ret_dia-expbeg_date
                          TIME cs_ret_dia-expbeg_time.
  CONVERT TIME STAMP lips-spe_exp_date_ext
                     TIME ZONE sy-zonlo
                     INTO DATE cs_ret_dia-expiry_date
                          TIME cs_ret_dia-expiry_time.

  CALL FUNCTION '/SPE/RET_DIALOG_PREPARE'
    EXPORTING
      is_likp                 = is_likp
      is_lips                 = is_lips
      it_xvbapf               = xvbapf[]                   "n_1245044
    IMPORTING
      es_cumulated_quantities = ls_cumulated_quantities
      es_delivery_relations   = ls_delivery_relations
    TABLES
      ct_xlips                = xlips
      it_xvbup                = xvbup
    EXCEPTIONS
      acc_app_not_determined  = 1.

  IF sy-subrc = 0.
*   transfer (dynamic) calculated quantities
    cs_ret_dia-acc_qty    = ls_cumulated_quantities-acc_qty.
    cs_ret_dia-app_qty    = ls_cumulated_quantities-app_qty.
    cs_ret_dia-rec_qty    = ls_cumulated_quantities-rec_qty.
    cs_ret_dia-open_qty   = ls_cumulated_quantities-opn_qty.
*   transfer original delivery reference
    cs_ret_dia-orig_vbeln = ls_delivery_relations-orig_vbeln.
    cs_ret_dia-orig_posnr = ls_delivery_relations-orig_posnr.
  ENDIF.

ENDFORM.                    " /spe/output_item_fields