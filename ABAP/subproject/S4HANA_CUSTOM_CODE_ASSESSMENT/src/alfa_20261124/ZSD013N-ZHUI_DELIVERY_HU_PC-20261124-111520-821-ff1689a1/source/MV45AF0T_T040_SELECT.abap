*---------------------------------------------------------------------*
*       FORM T040_SELECT                                              *
*---------------------------------------------------------------------*
*       Mahnschlüssel lesen                                           *
*---------------------------------------------------------------------*
FORM T040_SELECT USING US_MSCHL
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MSCHL NE T040-MSCHL.

  IF US_MSCHL = SPACE.
    CLEAR: T040, T040A.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T040 WHERE MSCHL = US_MSCHL.
  IF SY-SUBRC NE 0.
    CLEAR: T040, T040A.
    IF US_ERROR NE SPACE.
      MESSAGE E830 WITH US_MSCHL.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.