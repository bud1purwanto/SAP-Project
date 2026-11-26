*eject
*---------------------------------------------------------------------*
*       FORM T042Z_SELECT                                              *
*---------------------------------------------------------------------*
*       Zahlungsschluessel lesen                                      *
*---------------------------------------------------------------------*
FORM T042Z_SELECT USING US_ZLSCH
                        US_LAND1
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ZLSCH NE T042Z-ZLSCH OR
         US_LAND1 NE T042Z-LAND1.

  IF US_ZLSCH = SPACE.
    CLEAR: T042Z.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T042Z WHERE ZLSCH = US_ZLSCH
                               AND LAND1 = US_LAND1.
  IF SY-SUBRC NE 0.
    CLEAR: T042Z.
    IF US_ERROR NE SPACE.
      MESSAGE E443 WITH US_ZLSCH.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.