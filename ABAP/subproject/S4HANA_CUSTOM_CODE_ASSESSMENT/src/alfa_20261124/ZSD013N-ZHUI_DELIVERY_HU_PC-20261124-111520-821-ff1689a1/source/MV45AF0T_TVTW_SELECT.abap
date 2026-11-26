*---------------------------------------------------------------------*
*       FORM TVTW_SELECT                                              *
*---------------------------------------------------------------------*
*       Vertriebsweg lesen                                            *
*---------------------------------------------------------------------*
FORM TVTW_SELECT USING US_VTWEG
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VTWEG NE TVTW-VTWEG.

  IF US_VTWEG = SPACE.
    CLEAR: TVTW, TVTWT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVTW WHERE VTWEG = US_VTWEG.
  IF SY-SUBRC NE 0.
    CLEAR: TVTW, TVTWT.
    IF US_ERROR NE SPACE.
      MESSAGE E314 WITH US_VTWEG.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.