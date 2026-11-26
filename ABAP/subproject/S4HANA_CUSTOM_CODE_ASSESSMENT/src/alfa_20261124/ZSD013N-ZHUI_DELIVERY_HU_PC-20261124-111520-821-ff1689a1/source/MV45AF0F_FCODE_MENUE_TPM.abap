*&---------------------------------------------------------------------*
*&  Include           MV45AF0F_FCODE_MENUE_TPM                         *
*&---------------------------------------------------------------------*

FORM FCODE_MENUE_TPM.
* Call SD BAdI
  DATA: L_SD_SALES_EXIT   TYPE REF TO IF_EX_BADI_SD_MENUE_TPM,
        ACTIVE_TPM TYPE XFELD.

  CALL FUNCTION 'GET_HANDLE_SD_MENUE_TPM'
    IMPORTING
      HANDLE = L_SD_SALES_EXIT
      ACTIVE = ACTIVE_TPM.

  IF ACTIVE_TPM = CHARX.
    CALL METHOD L_SD_SALES_EXIT->CALL_FCODE_TPM.
  ENDIF.
ENDFORM.