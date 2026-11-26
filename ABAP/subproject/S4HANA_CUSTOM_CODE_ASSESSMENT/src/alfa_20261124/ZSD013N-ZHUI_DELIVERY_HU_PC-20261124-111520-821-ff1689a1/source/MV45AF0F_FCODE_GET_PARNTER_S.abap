*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_GET_PARNTER_S                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FCODE_GET_PARTNER_SUB
*&---------------------------------------------------------------------*
*       Fcode des des Trägerdynpros merken
*----------------------------------------------------------------------*
FORM FCODE_GET_PARTNER_SUB.

  DATA DA_FCODE_PAR LIKE SY-UCOMM.

  DA_FCODE_PAR = FCODE.

* FCODE merken
  CALL FUNCTION 'SD_PARTNER_SUBSCREEN_GET_FCODE'
       EXPORTING
            FIF_FCODE = DA_FCODE_PAR
            FIF_SET   = CHARX.

ENDFORM.                               " FCODE_GET_PARTNER_SUB



















