*---------------------------------------------------------------------*
*       FORM T188_SELECT                                              *
*---------------------------------------------------------------------*
*       Konditionsgruppe lesen                                        *
*---------------------------------------------------------------------*
FORM T188_SELECT USING US_KONDA
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KONDA NE T188-KONDA.

  IF US_KONDA = SPACE.
    CLEAR: T188, T188T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T188 WHERE KONDA = US_KONDA.
  IF SY-SUBRC NE 0.
    CLEAR: T188, T188T.
    IF US_ERROR NE SPACE.
      MESSAGE E429 WITH US_KONDA.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.