*&---------------------------------------------------------------------*
*&  Include           MV45AV0V_VBKD_VKONT_VALUES                       *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VBKD_VKONT_VALUES  INPUT
*&---------------------------------------------------------------------*
*&       Wertehilfe für das Feld Vertragskonto
*&---------------------------------------------------------------------*
MODULE VBKD_VKONT_VALUES INPUT.

 DATA: L_SD_ITEM_EXIT_VKONT_VALUES TYPE REF TO IF_EX_BADI_SD_SALES_ITEM,
       BADI_ACTIVE_VKONT_VALUES TYPE XFELD.

* Call SD Sales BAdI
  CALL FUNCTION 'GET_HANDLE_SD_SALES_ITEM'
    IMPORTING
      HANDLE = L_SD_ITEM_EXIT_VKONT_VALUES
      ACTIVE = BADI_ACTIVE_VKONT_VALUES.
  IF BADI_ACTIVE_VKONT_VALUES = CHARX.
    CALL METHOD L_SD_ITEM_EXIT_VKONT_VALUES->ITEM_VKONT_VALUES
      EXPORTING
        I_VBAK   = VBAK
        I_VBAP   = VBAP
        IT_XVBPA = XVBPA[]
        I_TRTYP  = T185F-TRTYP.
  ENDIF.

ENDMODULE.                 " VBKD_VKONT_VALUES  INPUT