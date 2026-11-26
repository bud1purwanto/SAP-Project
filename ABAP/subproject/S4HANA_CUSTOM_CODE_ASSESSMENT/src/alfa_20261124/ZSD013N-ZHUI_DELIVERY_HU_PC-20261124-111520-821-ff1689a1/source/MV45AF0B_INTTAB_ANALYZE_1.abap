*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_INTTAB_ANALYZE_1
*&---------------------------------------------------------------------*
* MV45AF0B_BELEG_LÖSCHEN
* MV45AFZZ, FORM USEREXIT_DELETE_DOCUMENT

* INTTAB_ANALYZE
  CALL FUNCTION 'SD_ORDER_CHECK_XYTAB'
    EXPORTING
      IV_T180_TRTYP  = T180-TRTYP
      IS_VBAK        = VBAK
      IV_TEXT_STRING = 'USEREXIT_DELETE_DOCUMENT'
      IT_XVBUP       = XVBUP[]
      IT_YVBUP       = YVBUP[]
      IT_XVBAP       = XVBAP[]
      IT_YVBAP       = YVBAP[]
      IT_XVBKD       = XVBKD[]
      IT_YVBKD       = YVBKD[]
      IT_XVBEP       = XVBEP[]
      IT_YVBEP       = YVBEP[] .