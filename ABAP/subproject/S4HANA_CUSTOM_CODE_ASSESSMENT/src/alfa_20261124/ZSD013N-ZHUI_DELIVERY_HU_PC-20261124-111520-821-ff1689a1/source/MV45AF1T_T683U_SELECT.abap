*eject
*---------------------------------------------------------------------*
*       FORM T683U_SELECT                                             *
*---------------------------------------------------------------------*
*       Text zum Kalkulationsschema lesen                             *
*---------------------------------------------------------------------*
FORM T683U_SELECT USING US_KVEWE
                        US_KAPPL
                        US_KALSM
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KVEWE NE T683U-KVEWE OR
         US_KAPPL NE T683U-KAPPL OR
         US_KALSM NE T683U-KALSM.

  IF US_KALSM = SPACE.
    CLEAR: T683U.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T683U WHERE SPRAS = SY-LANGU
                               AND KVEWE = US_KVEWE
                               AND KAPPL = US_KAPPL
                               AND KALSM = US_KALSM.
  IF SY-SUBRC NE 0.
    CLEAR: T683U.
    CH_SUBRC = 4.
    EXIT.
  ENDIF.

ENDFORM.