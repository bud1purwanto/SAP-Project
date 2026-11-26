*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PARTNER_FCODE_PASS                                *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PARTNER_FCODE_PASS
*&---------------------------------------------------------------------*
FORM PARTNER_FCODE_PASS.

  DATA: LF_FCODE LIKE SY-UCOMM.

  IF FCODE EQ SPACE.
    FCODE = FCODE_GLEICHE_SEITE.
  ENDIF.

* Save original FCODE
  GF_SAVE_FCODE = FCODE.

* Check whether function key F2 has been released
  PERFORM TRANSFORM_DOUBLECLICK CHANGING FCODE.

  LF_FCODE = FCODE.
  CALL FUNCTION 'SD_PARTNER_SUBSCREEN_GET_FCODE'
       EXPORTING
            FIF_FCODE = LF_FCODE
            FIF_SET   = 'X'.

ENDFORM.                               " PARTNER_FCODE_PASS

























