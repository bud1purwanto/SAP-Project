*---------------------------------------------------------------------*
*     FORM tvrmas_SELECT                                              *
*---------------------------------------------------------------------*
*       Substitutionsgrund lesen                                      *
*---------------------------------------------------------------------*
FORM TVRMAS_SELECT USING    US_SCHEME LIKE TVRMAS-SCHEME
                            US_ERROR
                   CHANGING CH_SUBRC
                            CH_TVRMAS LIKE TVRMAS.

  CH_SUBRC = 0.
  CHECK: US_SCHEME NE TVRMAS-SCHEME.

  IF US_SCHEME = SPACE.
    CLEAR: TVRMAS.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVRMAS WHERE SCHEME = US_SCHEME.

  IF SY-SUBRC EQ 0.
    MOVE TVRMAS TO CH_TVRMAS.
  ELSE.
    CLEAR: TVRMAS, CH_TVRMAS.
    IF US_ERROR = CHARX.
*     MESSAGE E??? WITH US_SCHEME.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.