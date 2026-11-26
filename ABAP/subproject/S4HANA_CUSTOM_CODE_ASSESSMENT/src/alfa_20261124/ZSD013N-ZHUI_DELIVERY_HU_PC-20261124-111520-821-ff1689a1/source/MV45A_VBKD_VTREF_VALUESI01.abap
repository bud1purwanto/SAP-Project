*----------------------------------------------------------------------*
***INCLUDE MV45A_VBKD_VTREF_VALUESI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VBKD_VTREF_VALUES  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VBKD_VTREF_VALUES INPUT.

 DATA: L_SD_ITEM_EXIT_VTREF_VALUES TYPE REF TO IF_EX_BADI_SD_SALES_ITEM,
       BADI_ACTIVE_VTREF_VALUES TYPE XFELD.

* Call SD Sales BAdI
  CALL FUNCTION 'GET_HANDLE_SD_SALES_ITEM'
    IMPORTING
      HANDLE = L_SD_ITEM_EXIT_VTREF_VALUES
      ACTIVE = BADI_ACTIVE_VTREF_VALUES.
  IF BADI_ACTIVE_VTREF_VALUES = CHARX.
    CALL METHOD L_SD_ITEM_EXIT_VTREF_VALUES->ITEM_VTREF_VALUES
      EXPORTING
        I_VBAK   = VBAK
        I_VBAP   = VBAP
        IT_XVBPA = XVBPA[]
        I_TRTYP  = T185F-TRTYP.
  ENDIF.

ENDMODULE.                 " VBKD_VTREF_VALUES  INPUT