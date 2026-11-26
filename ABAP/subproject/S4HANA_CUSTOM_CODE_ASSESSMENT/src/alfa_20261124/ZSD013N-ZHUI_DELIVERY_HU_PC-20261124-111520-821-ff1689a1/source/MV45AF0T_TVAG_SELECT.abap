*---------------------------------------------------------------------*
*       FORM TVAG_SELECT                                              *
*---------------------------------------------------------------------*
*       Absagegrund lesen                                             *
*---------------------------------------------------------------------*
FORM TVAG_SELECT USING US_ABGRU
                       US_DRAGR
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.

  IF US_ABGRU = SPACE.
    US_DRAGR = SPACE.
    CLEAR: TVAG, TVAGT.
    EXIT.
  ENDIF.
  CHECK: US_ABGRU NE TVAG-ABGRU.

  SELECT SINGLE * FROM TVAG WHERE ABGRU = US_ABGRU.
  IF SY-SUBRC NE 0.
    US_DRAGR = SPACE.
    CLEAR: TVAG, TVAGT.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBAP-ABGRU' LINE SY-STEPL.
      MESSAGE E415 WITH US_ABGRU.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ELSE.
    US_DRAGR = TVAG-DRAGR.
  ENDIF.

ENDFORM.