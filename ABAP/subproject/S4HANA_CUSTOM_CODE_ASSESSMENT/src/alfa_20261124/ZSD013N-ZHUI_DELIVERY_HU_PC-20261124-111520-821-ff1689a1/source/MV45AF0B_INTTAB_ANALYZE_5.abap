*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_INTTAB_ANALYZE_5
*&----------------------------------------------------------------

* MV45AF0B_BELEG_SICHERN
* MV45AFZZ, FORM USEREXIT_NUMBER_RANGE

* INTTAB_ANALYZE
  CALL FUNCTION 'SD_ORDER_CHECK_XYTAB'
    EXPORTING
      IV_T180_TRTYP  = T180-TRTYP
      IS_VBAK        = VBAK
      IV_TEXT_STRING = 'USEREXIT_NUMBER_RANGE'
      IT_XVBUP       = XVBUP[]
      IT_YVBUP       = YVBUP[]
      IT_XVBAP       = XVBAP[]
      IT_YVBAP       = YVBAP[]
      IT_XVBKD       = XVBKD[]
      IT_YVBKD       = YVBKD[]
      IT_XVBEP       = XVBEP[]
      IT_YVBEP       = YVBEP[] .