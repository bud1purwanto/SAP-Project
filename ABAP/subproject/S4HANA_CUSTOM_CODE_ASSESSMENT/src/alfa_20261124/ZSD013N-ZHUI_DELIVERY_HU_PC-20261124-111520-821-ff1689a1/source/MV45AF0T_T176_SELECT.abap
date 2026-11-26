*eject
*---------------------------------------------------------------------*
*       FORM T176_SELECT                                              *
*---------------------------------------------------------------------*
*       Bestellart mit Text lesen                                     *
*---------------------------------------------------------------------*
FORM T176_SELECT USING US_BSARK
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BSARK NE T176-BSARK.

  IF US_BSARK = SPACE.
    CLEAR: T176, T176T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T176 WHERE BSARK = US_BSARK.
  IF SY-SUBRC NE 0.
    CLEAR: T176, T176T.
    IF US_ERROR NE SPACE.
      MESSAGE E458 WITH US_BSARK.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.