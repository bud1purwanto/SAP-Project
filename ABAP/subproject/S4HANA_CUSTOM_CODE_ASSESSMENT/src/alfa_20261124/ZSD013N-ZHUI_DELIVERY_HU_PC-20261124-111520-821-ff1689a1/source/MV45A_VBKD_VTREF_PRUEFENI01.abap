*----------------------------------------------------------------------*
***INCLUDE MV45A_VBKD_VTREF_PRUEFENI01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  VBKD_VTREF_PRUEFEN  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VBKD_VTREF_PRUEFEN INPUT.

  DATA: L_SD_BASIC_EXIT_VTREF TYPE REF TO IF_EX_BADI_SD_SALES_BASIC,
        BADI_ACTIVE_VTREF TYPE XFELD.

* Call SD Sales BAdI
  CALL FUNCTION 'GET_HANDLE_SD_SALES_BASIC'
    IMPORTING
      HANDLE = L_SD_BASIC_EXIT_VTREF
      ACTIVE = BADI_ACTIVE_VTREF.
  IF BADI_ACTIVE_VTREF = CHARX.
    CALL METHOD L_SD_BASIC_EXIT_VTREF->VTREF_CHECK
      EXPORTING
        I_VBAK   = VBAK
        I_VBAP   = VBAP
        I_VBKD   = VBKD
        IT_XVBPA = XVBPA[].
  ENDIF.

ENDMODULE.                 " VBKD_VTREF_PRUEFEN  INPUT