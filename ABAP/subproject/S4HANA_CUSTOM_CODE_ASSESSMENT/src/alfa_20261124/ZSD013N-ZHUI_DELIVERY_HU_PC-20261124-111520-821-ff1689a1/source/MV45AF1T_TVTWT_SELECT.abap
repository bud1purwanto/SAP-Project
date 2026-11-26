*eject
*---------------------------------------------------------------------*
*       FORM TVTWt_SELECT                                             *
*---------------------------------------------------------------------*
*       Vertriebsweg und zugehörigen Text lesen                       *
*---------------------------------------------------------------------*
FORM TVTWT_SELECT USING US_VTWEG
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VTWEG NE TVTWT-VTWEG.

  IF US_VTWEG = SPACE.
    CLEAR: TVTW, TVTWT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVTWT WHERE SPRAS = SY-LANGU
                               AND VTWEG = US_VTWEG.
  IF SY-SUBRC NE 0.
    CLEAR: TVTWT.
    IF US_ERROR NE SPACE.
      MESSAGE E314 WITH US_VTWEG.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.