*eject
*---------------------------------------------------------------------*
*       FORM T178T_SELECT                                             *
*---------------------------------------------------------------------*
*       Materialgruppe mit Text lesen                                 *
*---------------------------------------------------------------------*
FORM T178T_SELECT USING US_KONDM
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KONDM NE T178T-KONDM.

  IF US_KONDM = SPACE.
    CLEAR: T178T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T178T WHERE SPRAS = SY-LANGU
                               AND KONDM = US_KONDM.
  IF SY-SUBRC NE 0.
    CLEAR: T178T.
    IF US_ERROR NE SPACE.
      MESSAGE E087 WITH US_KONDM.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.