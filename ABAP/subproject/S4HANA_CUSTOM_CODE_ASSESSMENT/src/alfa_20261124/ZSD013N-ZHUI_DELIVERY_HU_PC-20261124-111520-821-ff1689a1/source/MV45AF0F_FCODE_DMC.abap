*----------------------------------------------------------------------*
***INCLUDE MV45AF0F_FCODE_DMC .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FCODE_DMC
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fcode_dmc .

* BADI call for debit/credit linkage
  IF fcode = '+DMC'.
    CALL FUNCTION 'GET_HANDLE_SD_DMC_ORDER'
      IMPORTING
        handle = l_sd_dmc_order_exit
        active = dmc_active.

    IF dmc_active = charx.
      CALL METHOD l_sd_dmc_order_exit->sd_dmc1
        EXPORTING
          fvbak  = vbak
          fxkomv = xkomv[]
          fxvbpa = xvbpa[]
          ftrtyp = t180-trtyp
          fxvbap = xvbap[]
        CHANGING
          fcflag = dmc_cflag.
      IF NOT dmc_cflag IS INITIAL.
        r185d-dataloss = charx.
        CLEAR: dmc_cflag.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.                    " FCODE_DMC