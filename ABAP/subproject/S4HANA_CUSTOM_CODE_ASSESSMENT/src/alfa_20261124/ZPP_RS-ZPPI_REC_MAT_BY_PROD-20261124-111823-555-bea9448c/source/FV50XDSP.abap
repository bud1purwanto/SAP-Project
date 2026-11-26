*----------------------------------------------------------------------*
***INCLUDE FV50XDSP .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DSP_VBELN_OLD_LOCK
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LIKP_VBELN  text
*----------------------------------------------------------------------*
FORM dsp_vbeln_old_lock USING if_vbeln  TYPE vbeln_vl.

DATA: lt_ledspd_flow_tree    TYPE ledspd_flow_tree_t
     ,lt_ledspd_flow         TYPE ledspd_flow_t
     ,lf_vbeln_to_lock       TYPE vbeln_vl
     .

CALL FUNCTION 'LE_DSP_READ_FLOW'
  EXPORTING
    if_vbeln                    = if_vbeln
    if_check_goods_issue        = 'X'
  IMPORTING
    et_ledspd_flow_tree         = lt_ledspd_flow_tree
    et_ledspd_flow              = lt_ledspd_flow
    ef_reference_delivery       = lf_vbeln_to_lock
  EXCEPTIONS
    internal_error              = 01
    OTHERS                      = 99
          .
IF sy-subrc IS INITIAL.
  IF NOT lf_vbeln_to_lock IS INITIAL
     AND lf_vbeln_to_lock <> if_vbeln.
    PERFORM lieferung_sperren USING lf_vbeln_to_lock.
  ENDIF.
*ELSE.
*  MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
*          WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
ENDIF.

ENDFORM.                    " DSP_VBELN_OLD_LOCK
