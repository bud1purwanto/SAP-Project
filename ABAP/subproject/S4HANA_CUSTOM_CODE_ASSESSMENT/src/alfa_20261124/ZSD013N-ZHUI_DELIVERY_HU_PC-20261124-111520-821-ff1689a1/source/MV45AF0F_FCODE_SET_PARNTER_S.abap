*----------------------------------------------------------------------*
*   INCLUDE MV45AF0F_FCODE_SET_PARNTER_S                               *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  FCODE_SET_PARTNER_SUB
*&---------------------------------------------------------------------*
*       Fcode des Partner-Subscreen abfangen
*----------------------------------------------------------------------*
FORM fcode_set_partner_sub.

  DATA da_fcode_par LIKE sy-ucomm.

* FCODE zurückholen
  CALL FUNCTION 'SD_PARTNER_SUBSCREEN_GET_FCODE'
       EXPORTING
            fif_set   = space
       IMPORTING
            fef_fcode = da_fcode_par.

  fcode = da_fcode_par.

ENDFORM.                               " FCODE_SET_PARTNER_SUB