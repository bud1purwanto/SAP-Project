FORM AKKP_SELECT USING US_LCNUM
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_LCNUM NE AKKP-LCNUM.

  IF US_LCNUM = SPACE.
    CLEAR: AKKP.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM AKKP WHERE LCNUM = US_LCNUM.

  IF SY-SUBRC NE 0.
    CLEAR AKKP.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E836 WITH US_LCNUM.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.