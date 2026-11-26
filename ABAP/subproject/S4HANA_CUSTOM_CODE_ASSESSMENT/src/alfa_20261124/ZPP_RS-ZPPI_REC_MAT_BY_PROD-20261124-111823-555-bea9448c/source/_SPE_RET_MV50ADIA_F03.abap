*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50ADIA_F03
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  /spe/output_header_fields
*&---------------------------------------------------------------------*
FORM /spe/output_header_fields  USING    xlikp       TYPE likp
                                CHANGING cs_ret_dia  TYPE /spe/ret_dia.

  DATA: if_field_name   TYPE ddobjname,
        if_status_value TYPE ddstatus.

* Read screen texts
  if_field_name = 'VLSTK'.
  if_status_value = xlikp-vlstk.
  PERFORM /spe/desc_determine USING    if_status_value
                                       if_field_name
                              CHANGING cs_ret_dia-vlstk_desc.

  if_field_name = '/SPE/RET_ACC_APP_STS'.
  if_status_value = xlikp-spe_acc_app_sts.
  PERFORM /spe/desc_determine USING    if_status_value
                                       if_field_name
                              CHANGING cs_ret_dia-acc_app_desc.

  if_field_name = '/SPE/RET_SHP_INF_STS'.
  if_status_value = xlikp-spe_shp_inf_sts.
  PERFORM /spe/desc_determine USING    if_status_value
                                       if_field_name
                              CHANGING cs_ret_dia-shp_inf_desc.

  CASE xlikp-spe_le_scenario.
    WHEN 'R'.
      cs_ret_dia-ret_cat = 'A'.
    WHEN 'T'.
      cs_ret_dia-ret_cat = 'B'.
    WHEN 'S'.
      cs_ret_dia-ret_cat = 'C'.
  ENDCASE.

ENDFORM.                    " /spe/output_header_fields
*&---------------------------------------------------------------------*
*&      Form  /spe/desc_determine
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM /spe/desc_determine USING    if_status_value    TYPE ddstatus
                                  if_field_name      TYPE ddobjname
                         CHANGING cf_descript        TYPE ddtext.

  DATA: ls_dd07v TYPE dd07v,
        lf_value TYPE dd07v-domvalue_l.

  lf_value = if_status_value.

  CALL FUNCTION 'DDUT_DOMVALUE_TEXT_GET'
    EXPORTING
      name          = if_field_name
      value         = lf_value
      langu         = sy-langu
      texts_only    = 'X'
    IMPORTING
      dd07v_wa      = ls_dd07v
    EXCEPTIONS
      not_found     = 1
      illegal_input = 2
      OTHERS        = 3.
  IF sy-subrc NE 0.
    CLEAR cf_descript.
  ELSE.
    cf_descript = ls_dd07v-ddtext.
  ENDIF.

ENDFORM.                    " /spe/desc_determine