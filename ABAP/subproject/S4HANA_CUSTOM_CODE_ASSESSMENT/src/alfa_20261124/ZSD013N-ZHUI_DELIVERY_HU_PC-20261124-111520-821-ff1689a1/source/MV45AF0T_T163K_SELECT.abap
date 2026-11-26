*eject
*---------------------------------------------------------------------*
*       FORM T163K_SELECT                                              *
*---------------------------------------------------------------------*
*       Kontierungstabelle lesen                                      *
*---------------------------------------------------------------------*
FORM T163K_SELECT USING US_KNTTP
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KNTTP NE T163K-KNTTP.

  IF US_KNTTP = SPACE.
    CLEAR: T163K.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T163K WHERE KNTTP = US_KNTTP.
  IF SY-SUBRC NE 0.
    CLEAR: T163K.
    IF US_ERROR NE SPACE.
      MESSAGE E129 WITH US_KNTTP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.