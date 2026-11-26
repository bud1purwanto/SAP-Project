*eject
*---------------------------------------------------------------------*
*       FORM TVAUT_SELECT                                             *
*---------------------------------------------------------------------*
*       Auftragsgrund mit Text lesen                                  *
*---------------------------------------------------------------------*
FORM TVAUT_SELECT USING US_AUGRU
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_AUGRU NE TVAUT-AUGRU.

  IF US_AUGRU = SPACE.
    CLEAR: TVAUT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVAUT WHERE SPRAS = SY-LANGU
                               AND AUGRU = US_AUGRU.
  IF SY-SUBRC NE 0.
    CLEAR: TVAUT.
    IF US_ERROR NE SPACE.
      MESSAGE E436 WITH US_AUGRU.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.