*eject
*---------------------------------------------------------------------*
*       FORM T005T_SELECT                                             *
*---------------------------------------------------------------------*
*       Länderbezeichnung lesen                                       *
*---------------------------------------------------------------------*
FORM T005T_SELECT USING US_LAND1
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_LAND1 NE T005T-LAND1.

  IF US_LAND1 = SPACE.
    CLEAR: T005T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T005T WHERE SPRAS = SY-LANGU
                               AND LAND1 = US_LAND1.

  IF SY-SUBRC NE 0.
    CLEAR: T005T.
    IF US_LAND1 NE SPACE.
      IF US_ERROR = CHARX.
        MESSAGE E031 WITH US_LAND1.
      ELSE.
        CH_SUBRC = 4.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.