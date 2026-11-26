*&---------------------------------------------------------------------*
*&  Include           MV45AI0V_VBKD_VKONT_PRUEFEN                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VBKD_VKONT_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       Prüfung des Vertragskontos
*----------------------------------------------------------------------*
MODULE VBKD_VKONT_PRUEFEN INPUT.

  DATA: L_SD_BASIC_EXIT_VKONT TYPE REF TO IF_EX_BADI_SD_SALES_BASIC,
        BADI_ACTIVE_VKONT TYPE XFELD.

* Call SD Sales BAdI
  CALL FUNCTION 'GET_HANDLE_SD_SALES_BASIC'
    IMPORTING
      HANDLE = L_SD_BASIC_EXIT_VKONT
      ACTIVE = BADI_ACTIVE_VKONT.
  IF BADI_ACTIVE_VKONT = CHARX.
    CALL METHOD L_SD_BASIC_EXIT_VKONT->VKONT_CHECK
      EXPORTING
        I_VBAK   = VBAK
        I_VBAP   = VBAP
        I_VBKD   = VBKD
        IT_XVBPA = XVBPA[].
  ENDIF.

ENDMODULE.                 " VBKD_VKONT_PRUEFEN  INPUT