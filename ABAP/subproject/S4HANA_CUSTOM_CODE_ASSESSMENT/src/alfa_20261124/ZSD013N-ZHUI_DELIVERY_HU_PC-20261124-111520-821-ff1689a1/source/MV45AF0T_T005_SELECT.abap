*eject
*---------------------------------------------------------------------*
*       FORM T005_SELECT                                              *
*---------------------------------------------------------------------*
*       Ländertabelle lesen                                           *
*---------------------------------------------------------------------*
FORM T005_SELECT USING US_LAND1
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_LAND1 NE T005-LAND1.

  IF US_LAND1 = SPACE.
    CLEAR: T005, T005T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T005 WHERE LAND1 = US_LAND1.

  IF SY-SUBRC NE 0.
    CLEAR: T005, T005T.
    IF US_ERROR = CHARX.
      MESSAGE E832 WITH US_LAND1.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.