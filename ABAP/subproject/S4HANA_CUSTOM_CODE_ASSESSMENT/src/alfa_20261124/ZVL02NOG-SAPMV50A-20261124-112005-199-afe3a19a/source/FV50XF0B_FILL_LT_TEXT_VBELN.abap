*----------------------------------------------------------------------*
***INCLUDE FV50XF0B_FILL_LT_TEXT_VBELN .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FILL_LT_TEXT_VBELN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->PT_VBELN[]  text
*----------------------------------------------------------------------*
FORM FILL_LT_TEXT_VBELN USING    PT_VBELN TYPE LV70T_TY_APPL_TABLE.

  DATA: LS_VBELN_WA TYPE LV70T_TY_APPL.

  IF V50AGL-SOFAUFTRAG IS INITIAL.
    CLEAR LS_VBELN_WA.
    if v50agl-sammelgang ne space or                         "hp_325253
       v50agl-mult       ne space    .
      LS_VBELN_WA-VBELN = '*'.
    ELSE.
      LS_VBELN_WA-VBELN = LIKP-VBELN.
    ENDIF.
    APPEND LS_VBELN_WA TO PT_VBELN.
  ELSE.
    LOOP AT XLIKP.
      CLEAR LS_VBELN_WA.
      LS_VBELN_WA-VBELN = XLIKP-VBELN.
      APPEND LS_VBELN_WA TO PT_VBELN.
    ENDLOOP.
    IF SY-SUBRC NE 0.                                       "v_n_1379929
*     Create dummy entry so that SD_DELETE_TEXT_FROM_CATALOG does
*     not delete all text catalog entries in case rush order
      CLEAR LS_VBELN_WA.
      APPEND LS_VBELN_WA TO PT_VBELN.
    ENDIF.                                                  "^_n_1379929
  ENDIF.

ENDFORM.                               " FILL_LT_TEXT_VBELN