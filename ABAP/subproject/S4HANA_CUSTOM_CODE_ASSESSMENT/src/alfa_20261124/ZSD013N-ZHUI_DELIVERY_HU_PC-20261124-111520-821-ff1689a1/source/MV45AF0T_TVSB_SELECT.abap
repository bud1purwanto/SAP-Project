*eject
*---------------------------------------------------------------------*
*       FORM TVSB_SELECT                                              *
*---------------------------------------------------------------------*
*       Versandbedingung lesen                                        *
*---------------------------------------------------------------------*
FORM TVSB_SELECT USING US_VSBED
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VSBED NE TVSB-VSBED.

  IF US_VSBED = SPACE.
    CLEAR: TVSB, TVSBT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVSB WHERE VSBED = US_VSBED.

  IF SY-SUBRC NE 0.
    CLEAR TVSB.
    CLEAR TVSBT.
    IF US_ERROR = CHARX.
      MESSAGE E015 WITH US_VSBED.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.