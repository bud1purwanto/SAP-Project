*----------------------------------------------------------------------*
***INCLUDE MV45AF0F_FCODE_DSD .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FCODE_Dsd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM fcode_dsd .

* BADI call for direct store delivery
  IF fcode = '+DSD'.
    CALL FUNCTION 'GET_HANDLE_SD_DSD_ORDER'
      IMPORTING
        handle = l_sd_dsd_order_exit
        active = dsd_active.

    IF dsd_active = charx.
      CALL METHOD l_sd_dsd_order_exit->sd_dsd1
        EXPORTING
          fvbak  = vbak
          fxvbap = xvbap[].
    ENDIF.
  ENDIF.

ENDFORM.                    " FCODE_Dsd