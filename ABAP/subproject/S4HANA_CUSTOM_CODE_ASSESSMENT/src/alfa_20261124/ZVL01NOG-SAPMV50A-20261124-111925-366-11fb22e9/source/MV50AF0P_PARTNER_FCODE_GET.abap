*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PARTNER_FCODE_GET                                 *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PARTNER_FCODE_GET
*&---------------------------------------------------------------------*
FORM PARTNER_FCODE_GET.

  DATA: LF_FCODE LIKE SY-UCOMM.

  CALL FUNCTION 'SD_PARTNER_SUBSCREEN_GET_FCODE'
       EXPORTING
            FIF_SET   = ' '
       IMPORTING
            FEF_FCODE = LF_FCODE.

  FCODE = LF_FCODE.

* Workaround: Filter invalid FCODES
  PERFORM SUBSCREEN_FCODE_FILTER CHANGING FCODE.

ENDFORM.                               " PARTNER_FCODE_GET

























