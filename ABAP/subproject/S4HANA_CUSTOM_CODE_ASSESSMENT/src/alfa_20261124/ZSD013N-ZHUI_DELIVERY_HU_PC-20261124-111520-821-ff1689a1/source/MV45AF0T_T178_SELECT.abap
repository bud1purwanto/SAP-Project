*eject
*---------------------------------------------------------------------*
*       FORM T178_SELECT                                              *
*---------------------------------------------------------------------*
*       Materialgruppe lesen                                          *
*---------------------------------------------------------------------*
FORM T178_SELECT USING US_KONDM
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KONDM NE T178-KONDM.

  IF US_KONDM = SPACE.
    CLEAR: T178, T178T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T178 WHERE KONDM = US_KONDM.
  IF SY-SUBRC NE 0.
    CLEAR: T178, T178T.
    IF US_ERROR NE SPACE.
      MESSAGE E087 WITH US_KONDM.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.