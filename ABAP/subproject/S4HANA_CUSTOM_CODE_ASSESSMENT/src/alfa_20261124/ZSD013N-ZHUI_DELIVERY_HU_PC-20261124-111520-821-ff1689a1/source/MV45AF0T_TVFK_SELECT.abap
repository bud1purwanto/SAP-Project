*---------------------------------------------------------------------*
*       FORM TVFK_SELECT                                              *
*---------------------------------------------------------------------*
*       Fakturaart lesen                                              *
*---------------------------------------------------------------------*
FORM TVFK_SELECT USING US_FKART
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_FKART NE TVFK-FKART.

  IF US_FKART = SPACE.
    CLEAR: TVFK.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVFK WHERE FKART = US_FKART.
  IF SY-SUBRC NE 0.
    CLEAR: TVFK.
    IF US_ERROR NE SPACE.
      MESSAGE E396 WITH US_FKART.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.