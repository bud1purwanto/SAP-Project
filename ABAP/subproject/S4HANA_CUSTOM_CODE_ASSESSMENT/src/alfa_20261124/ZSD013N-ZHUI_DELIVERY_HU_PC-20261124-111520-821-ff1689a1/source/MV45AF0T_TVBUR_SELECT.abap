*eject
*---------------------------------------------------------------------*
*       FORM TVBUR_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkaufsbüro lesen                                            *
*---------------------------------------------------------------------*
FORM TVBUR_SELECT USING US_VKBUR
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VKBUR NE TVBUR-VKBUR.

  IF US_VKBUR = SPACE.
    CLEAR: TVBUR, TVKBT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVBUR WHERE VKBUR = US_VKBUR.
  IF SY-SUBRC NE 0.
    CLEAR: TVBUR, TVKBT.
    IF US_ERROR NE SPACE.
      MESSAGE E407 WITH US_VKBUR.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.