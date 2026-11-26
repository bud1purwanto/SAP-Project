*EJECT
*---------------------------------------------------------------------*
*       FORM T683_SELECT                                              *
*---------------------------------------------------------------------*
*       Kalkulationsschema wird gelesen                               *
*---------------------------------------------------------------------*
FORM T683_SELECT USING US_KVEWE
                        US_KAPPL
                        US_KALSM
                        US_ERROR
                        CH_SUBRC.


  CH_SUBRC = 0.
  CHECK: US_KVEWE NE T683-KVEWE OR
         US_KAPPL NE T683-KAPPL OR
         US_KALSM NE T683-KALSM.

  SELECT SINGLE * FROM T683 WHERE KVEWE = US_KVEWE
                               AND KAPPL = US_KAPPL
                               AND KALSM = US_KALSM.

  IF SY-SUBRC NE 0.
    CLEAR T683.
    DATA: DA_HILFSTEXT(11).
    MOVE US_KVEWE TO DA_HILFSTEXT.
    MOVE US_KAPPL TO DA_HILFSTEXT+3.
    MOVE US_KALSM TO DA_HILFSTEXT+5.
    IF US_ERROR NE SPACE.
      MESSAGE E840 WITH DA_HILFSTEXT.
    ELSE.
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.