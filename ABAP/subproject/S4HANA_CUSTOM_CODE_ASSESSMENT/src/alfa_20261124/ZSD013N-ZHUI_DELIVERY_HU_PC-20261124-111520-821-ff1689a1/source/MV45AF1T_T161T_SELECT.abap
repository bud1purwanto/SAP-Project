*eject
*---------------------------------------------------------------------*
*       FORM T161T_SELECT                                              *
*---------------------------------------------------------------------*
*       Einkaufsbelegtyp(Bestellart) mit Text lesen                   *
*---------------------------------------------------------------------*
FORM T161T_SELECT USING US_BSART
                        US_BSTYP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BSART NE T161T-BSART AND
         US_BSTYP NE T161T-BSTYP.

  IF US_BSART = SPACE.
    CLEAR: T161T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T161T WHERE SPRAS = SY-LANGU
                               AND BSART = US_BSART
                               AND BSTYP = US_BSTYP.
  IF SY-SUBRC NE 0.
    CLEAR: T161T.
    IF US_ERROR NE SPACE.
      MESSAGE E458 WITH US_BSART.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.