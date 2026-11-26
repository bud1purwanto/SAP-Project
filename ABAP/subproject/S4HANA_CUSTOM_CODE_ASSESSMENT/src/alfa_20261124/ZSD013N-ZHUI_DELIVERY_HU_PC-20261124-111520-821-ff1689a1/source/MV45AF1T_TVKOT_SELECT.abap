*eject
*---------------------------------------------------------------------*
*       FORM TVKOT_SELECT                                             *
*---------------------------------------------------------------------*
*       Verkaufsorganisation lesen                                    *
*---------------------------------------------------------------------*
FORM TVKOT_SELECT USING US_VKORG
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VKORG NE TVKOT-VKORG.

  IF US_VKORG = SPACE.
    CLEAR: TVKOT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVKOT WHERE SPRAS = SY-LANGU
                               AND VKORG = US_VKORG.
  IF SY-SUBRC NE 0.
    CLEAR: TVKOT.
    IF US_ERROR NE SPACE.
      MESSAGE E313 WITH US_VKORG.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.