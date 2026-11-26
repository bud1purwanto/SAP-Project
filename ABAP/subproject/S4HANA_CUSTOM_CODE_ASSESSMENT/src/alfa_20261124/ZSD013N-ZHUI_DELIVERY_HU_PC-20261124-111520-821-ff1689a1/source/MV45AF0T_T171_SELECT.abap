*eject
*---------------------------------------------------------------------*
*       FORM T171_SELECT                                              *
*---------------------------------------------------------------------*
*       Bezirk mit Text lesen                                         *
*---------------------------------------------------------------------*
FORM T171_SELECT USING US_BZIRK
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BZIRK NE T171-BZIRK.

  IF US_BZIRK = SPACE.
    CLEAR: T171, T171T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T171 WHERE BZIRK = US_BZIRK.
  IF SY-SUBRC NE 0.
    CLEAR: T171, T171T.
    IF US_ERROR NE SPACE.
      MESSAGE E424 WITH US_BZIRK.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.