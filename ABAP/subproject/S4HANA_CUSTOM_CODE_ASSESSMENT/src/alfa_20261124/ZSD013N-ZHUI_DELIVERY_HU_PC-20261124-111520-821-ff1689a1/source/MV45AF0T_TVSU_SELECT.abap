*eject
*---------------------------------------------------------------------*
*       FORM TVSU_SELECT                                              *
*---------------------------------------------------------------------*
*       Substitutionsgrund lesen                                      *
*---------------------------------------------------------------------*
FORM TVSU_SELECT USING US_SUGRD
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_SUGRD NE TVSU-SUGRD.

  IF US_SUGRD = SPACE.
    CLEAR: TVSU.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVSU WHERE SUGRD = US_SUGRD.

  IF SY-SUBRC NE 0.
    CLEAR: TVSU.
    IF US_ERROR = CHARX.
      MESSAGE E276 WITH US_SUGRD.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.