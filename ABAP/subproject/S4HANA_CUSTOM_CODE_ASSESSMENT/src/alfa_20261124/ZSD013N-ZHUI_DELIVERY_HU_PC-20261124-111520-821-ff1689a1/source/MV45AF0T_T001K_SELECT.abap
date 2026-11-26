*---------------------------------------------------------------------*
*       FORM T001K_SELECT                                             *
*---------------------------------------------------------------------*
*       Kostenkreistabelle lesen                                      *
*---------------------------------------------------------------------*
FORM T001K_SELECT USING US_BWKEY
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BWKEY NE T001K-BWKEY.

  IF US_BWKEY = SPACE.
    CLEAR: T001K.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T001K WHERE BWKEY = US_BWKEY.

  IF SY-SUBRC NE 0.
    CLEAR: T001K.
    IF US_BWKEY NE SPACE.
      IF US_ERROR = CHARX.
        MESSAGE E116 WITH US_BWKEY.
      ELSE.
        CH_SUBRC = 4.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.