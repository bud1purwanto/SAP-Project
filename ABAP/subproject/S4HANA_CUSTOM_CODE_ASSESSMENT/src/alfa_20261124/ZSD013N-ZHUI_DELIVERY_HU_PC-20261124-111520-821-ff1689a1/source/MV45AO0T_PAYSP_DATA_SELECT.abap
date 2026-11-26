*----------------------------------------------------------------------*
***INCLUDE MV45AO0T_PAYSP_DATA_SELECT .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PAYSP_DATA_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE paysp_data_select OUTPUT.
* Payment Service Provider

  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true AND
     vbak-sppaym IS NOT INITIAL.
    PERFORM lord_lpaysp_pbo(sapmv45a).
    PERFORM lord_lpaysp_pbo_ro(sapmv45a).
  ENDIF.

ENDMODULE.                 " PAYSP_DATA_SELECT  OUTPUT