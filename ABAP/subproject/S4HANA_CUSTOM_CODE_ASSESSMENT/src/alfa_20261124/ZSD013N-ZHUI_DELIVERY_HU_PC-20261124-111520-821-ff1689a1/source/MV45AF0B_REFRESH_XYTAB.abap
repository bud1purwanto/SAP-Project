*&---------------------------------------------------------------------*
*&  Include           MV45AF0B_REFRESH_XYTAB
*&---------------------------------------------------------------------*

* MV45AF0B_BELEG_INITIALISIEREN

* INTTAB_ANALYZE
  IF T180-TRTYP NE CHARA.
*   Refresh data in function group INTTAB_ANALYZE
    CALL FUNCTION 'SD_ORDER_REFRESH_XYTAB' .
  ENDIF.