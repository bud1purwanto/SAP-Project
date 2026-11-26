*---------------------------------------------------------------------*
*       FORM T040S_SELECT                                             *
*---------------------------------------------------------------------*
*       Mahnsperre lesen                                              *
*---------------------------------------------------------------------*
FORM T040S_SELECT USING US_MANSP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MANSP NE T040S-MANSP.

  IF US_MANSP = SPACE.
    CLEAR: T040S, T040T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T040S WHERE MANSP = US_MANSP.
  IF SY-SUBRC NE 0.
    CLEAR: T040S, T040T.
    IF US_ERROR NE SPACE.
      MESSAGE E831 WITH US_MANSP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.