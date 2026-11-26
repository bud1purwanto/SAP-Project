*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_PUT_XTAB
*&---------------------------------------------------------------------*

* MV45AF0B_BELEG_LESEN

* INTTAB_ANALYZE
  IF T180-TRTYP NE CHARA.
*   Buffer read tables in function group INTTAB_ANALYZE
    CALL FUNCTION 'SD_ORDER_PUT_XTAB'
      EXPORTING
        IT_XVBUP = XVBUP[]
        IT_XVBAP = XVBAP[]
        IT_XVBKD = XVBKD[]
        IT_XVBEP = XVBEP[].
  ENDIF.