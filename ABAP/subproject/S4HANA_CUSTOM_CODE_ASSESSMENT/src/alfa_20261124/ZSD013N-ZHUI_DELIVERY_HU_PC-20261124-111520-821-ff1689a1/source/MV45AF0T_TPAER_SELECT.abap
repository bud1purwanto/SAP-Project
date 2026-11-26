*---------------------------------------------------------------------*
*       FORM TPAER_SELECT                                             *
*---------------------------------------------------------------------*
*       Erlaubte Partner prüfen                                       *
*---------------------------------------------------------------------*
FORM TPAER_SELECT USING US_PARGR
                        US_PARVW
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_PARGR NE TPAER-PARGR OR
         US_PARVW NE TPAER-PARVW.

  IF US_PARGR = SPACE AND US_PARVW = SPACE.
    CLEAR: TPAER.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TPAER WHERE PARGR = US_PARGR
                               AND PARVW = US_PARVW.

  IF SY-SUBRC NE 0.
    CLEAR TPAER.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E372 WITH US_PARGR
                        US_PARVW.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.