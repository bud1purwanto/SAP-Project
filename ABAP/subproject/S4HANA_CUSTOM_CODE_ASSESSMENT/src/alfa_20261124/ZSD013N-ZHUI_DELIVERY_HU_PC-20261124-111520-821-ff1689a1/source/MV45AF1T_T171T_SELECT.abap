*eject
*---------------------------------------------------------------------*
*       FORM T171T_SELECT                                             *
*---------------------------------------------------------------------*
*       Bezirk mit Text lesen                                         *
*---------------------------------------------------------------------*
FORM T171T_SELECT USING US_BZIRK
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BZIRK NE T171T-BZIRK.

  IF US_BZIRK = SPACE.
    CLEAR: T171T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T171T WHERE SPRAS = SY-LANGU
                               AND BZIRK = US_BZIRK.
  IF SY-SUBRC NE 0.
    CLEAR: T171T.
    IF US_ERROR NE SPACE.
      MESSAGE E425 WITH US_BZIRK.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.