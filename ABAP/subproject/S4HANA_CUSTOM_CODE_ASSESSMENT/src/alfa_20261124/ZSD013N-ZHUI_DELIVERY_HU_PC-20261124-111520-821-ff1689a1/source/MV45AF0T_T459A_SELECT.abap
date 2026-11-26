*eject
*---------------------------------------------------------------------*
*       FORM T459A_SELECT                                             *
*---------------------------------------------------------------------*
*       Bedarfsart umschlüesseln                                      *
*---------------------------------------------------------------------*
FORM T459A_SELECT USING US_BEDAE
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BEDAE NE T459A-BEDAE.

  IF US_BEDAE = SPACE.
    CLEAR: T459A.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T459A WHERE BEDAE = US_BEDAE.
  IF SY-SUBRC NE 0.
    CLEAR: T459A.
    IF US_ERROR NE SPACE.
      SET CURSOR FIELD 'VBAP-BEDAE' LINE SY-STEPL.
      MESSAGE E246 WITH US_BEDAE.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.