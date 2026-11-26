*---------------------------------------------------------------------*
*       FORM WSOH_SELECT                                             *
*---------------------------------------------------------------------*
*       Sortiments-Bausteine R/3 Retail prüfen
*---------------------------------------------------------------------*
FORM WSOH_SELECT USING US_SKOPF
                        US_ERROR
                        CH_SUBRC.


  CH_SUBRC = 0.
  CHECK: US_SKOPF NE WSOH-SKOPF.

  IF US_SKOPF = SPACE.
    CLEAR: WSOH.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM WSOH WHERE SKOPF = US_SKOPF.

  IF SY-SUBRC NE 0.
    CLEAR: WSOH.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E843 WITH US_SKOPF.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.