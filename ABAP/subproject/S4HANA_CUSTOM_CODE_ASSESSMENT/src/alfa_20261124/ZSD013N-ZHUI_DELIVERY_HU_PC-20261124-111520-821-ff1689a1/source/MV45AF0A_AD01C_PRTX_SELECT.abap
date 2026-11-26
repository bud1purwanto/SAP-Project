*----------------------------------------------------------------------*
*   INCLUDE MV45AF0A_AD01C_PRTX_SELECT                                 *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  AD01C_PRTX_SELECT
*&---------------------------------------------------------------------*
*       Selektieren des Textes zum DP-Profil
*----------------------------------------------------------------------*
FORM AD01C_PRTX_SELECT.

  IF VBKD-FFPRF IS INITIAL.
    CLEAR AD01C_PRTX.
    EXIT.
  ENDIF.

  READ TABLE XAD01C_PRTX WITH KEY PROFNR = VBKD-FFPRF
                                  SPRAS  = SY-LANGU.
  IF SY-SUBRC = 0.
    AD01C_PRTX = XAD01C_PRTX.
  ELSE.
    SELECT SINGLE * FROM AD01C_PRTX WHERE PROFNR = VBKD-FFPRF AND
                                          SPRAS  = SY-LANGU.
    IF SY-SUBRC = 0.
      XAD01C_PRTX = AD01C_PRTX.
      APPEND XAD01C_PRTX.
    ELSE.
      CLEAR AD01C_PRTX.
    ENDIF.
  ENDIF.

ENDFORM.                    " AD01C_PRTX_SELECT