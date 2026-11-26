*&---------------------------------------------------------------------*
*&  Include           MV45AF0T_REFRESH_XYTAB
*&---------------------------------------------------------------------*

* MV45AF0T_TRANSAKTION_INIT

* INTTAB_ANALYZE
  IF T180-TRTYP NE CHARA AND
     CALL_FUNCTION IS INITIAL.
*   Refresh data in function group INTTAB_ANALYZE
    CALL FUNCTION 'SD_ORDER_REFRESH_XYTAB' .
  ENDIF.