***INCLUDE MV50AF0F_FCODE_QUIT_AND_SAVE .
*---------------------------------------------------------------------*
*       FORM FCODE_QUIT_AND_SAVE                                      *
*---------------------------------------------------------------------*
FORM FCODE_QUIT_AND_SAVE.
  PERFORM FCODE_QUIT.
  PERFORM BELEG_SICHERN USING CHARX.
* APO:
  PERFORM NMODUL_FOR_TCODE_APO.
ENDFORM.