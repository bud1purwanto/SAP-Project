*eject
*---------------------------------------------------------------------*
*       FORM TVKBT_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkaufsbüro Text lesen                                       *
*---------------------------------------------------------------------*
FORM TVKBT_SELECT USING US_VKBUR
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VKBUR NE TVKBT-VKBUR.

  IF US_VKBUR = SPACE.
    CLEAR: TVKBT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVKBT WHERE SPRAS = SY-LANGU
                             AND   VKBUR = US_VKBUR.
  IF SY-SUBRC NE 0.
    CLEAR TVKBT.
    IF US_ERROR NE SPACE.
      MESSAGE E407 WITH US_VKBUR.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.