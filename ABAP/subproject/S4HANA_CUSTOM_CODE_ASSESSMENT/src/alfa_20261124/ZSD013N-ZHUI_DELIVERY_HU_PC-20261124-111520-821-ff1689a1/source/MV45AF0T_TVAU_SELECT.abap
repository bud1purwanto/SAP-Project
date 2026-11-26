*---------------------------------------------------------------------*
*       FORM TVAU_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftragsgrund lesen                                           *
*---------------------------------------------------------------------*
FORM TVAU_SELECT USING US_AUGRU
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_AUGRU NE TVAU-AUGRU.

  IF US_AUGRU = SPACE.
    CLEAR: TVAU, TVAUT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVAU WHERE AUGRU = US_AUGRU.
  IF SY-SUBRC NE 0.
    CLEAR: TVAU, TVAUT.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBAK-AUGRU' LINE SY-STEPL.
      MESSAGE E435 WITH US_AUGRU.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.