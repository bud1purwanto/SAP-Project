*---------------------------------------------------------------------*
*       FORM T176T_SELECT                                             *
*---------------------------------------------------------------------*
*       Bestellart mit Text lesen                                     *
*---------------------------------------------------------------------*
FORM T176T_SELECT USING US_BSARK
                        US_ERROR
                        CH_SUBRC
                        US_TEXT.
  CH_SUBRC = 0.
* check: us_bsark ne t176t-bsark.

  IF US_BSARK = SPACE.
    CLEAR: T176T, US_TEXT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T176T WHERE SPRAS = SY-LANGU
                               AND BSARK = US_BSARK.
  IF SY-SUBRC NE 0.
    CLEAR: T176T.
    IF US_ERROR NE SPACE.
      MESSAGE E458 WITH US_BSARK.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ELSE.
    US_TEXT = T176T-VTEXT.
  ENDIF.

ENDFORM.