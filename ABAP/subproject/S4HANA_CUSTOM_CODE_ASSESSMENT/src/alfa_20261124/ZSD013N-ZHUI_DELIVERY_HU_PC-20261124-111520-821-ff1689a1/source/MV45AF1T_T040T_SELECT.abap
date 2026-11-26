*eject
*---------------------------------------------------------------------*
*       FORM T040T_SELECT                                             *
*---------------------------------------------------------------------*
*       Mahnsperre    Text                                            *
*---------------------------------------------------------------------*
FORM T040T_SELECT USING US_MANSP
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MANSP NE T040T-MANSP.

  IF US_MANSP = SPACE.
    CLEAR: T040A.
    CLEAR: T040T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T040T WHERE MANSP = US_MANSP
                               AND SPRAS = SY-LANGU.
  IF SY-SUBRC NE 0.
    CLEAR: T040T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.