*eject
*---------------------------------------------------------------------*
*       FORM TVST_SELECT                                              *
*---------------------------------------------------------------------*
*       Versandstelle lesen                                           *
*---------------------------------------------------------------------*
FORM TVST_SELECT USING US_VSTEL
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VSTEL NE TVST-VSTEL.

  IF US_VSTEL = SPACE.
    CLEAR: TVST, TVSTT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVST WHERE VSTEL = US_VSTEL.

  IF SY-SUBRC NE 0.
    CLEAR: TVST, TVSTT.
    IF US_ERROR = CHARX.
      MESSAGE E240 WITH US_VSTEL.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.