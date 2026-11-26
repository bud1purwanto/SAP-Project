*&---------------------------------------------------------------------*
*&  Include           MV45AO0B_BADI_SAPMV45A_4311                      *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  BADI_SAPMV45A_4311  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE BADI_SAPMV45A_4311 OUTPUT.

DATA: L_SD_SALES_BASIC_EXIT_4311 TYPE REF TO IF_EX_BADI_SD_SALES_BASIC,
      BADI_ACTIVE_4311 TYPE XFELD.

* Call SD Sales BAdI
  CALL FUNCTION 'GET_HANDLE_SD_SALES_BASIC'
    IMPORTING
      HANDLE = L_SD_SALES_BASIC_EXIT_4311
      ACTIVE = BADI_ACTIVE_4311.
  IF BADI_ACTIVE_4311 = CHARX.
    CALL METHOD L_SD_SALES_BASIC_EXIT_4311->PBO_SAPMV45A_4311
      EXPORTING
        I_VBAK  = VBAK
        I_VBKD  = VBKD
      CHANGING
        X_RV45A = RV45A.
  ENDIF.


ENDMODULE.                 " BADI_SAPMV45A_4311  OUTPUT