*eject
*---------------------------------------------------------------------*
*       FORM T188T_SELECT                                             *
*---------------------------------------------------------------------*
*       Konditionsgruppe mit Text lesen                               *
*---------------------------------------------------------------------*
FORM T188T_SELECT USING US_KONDA
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KONDA NE T188T-KONDA.

  IF US_KONDA = SPACE.
    CLEAR: T188T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T188T WHERE SPRAS = SY-LANGU
                               AND KONDA = US_KONDA.
  IF SY-SUBRC NE 0.
    CLEAR: T188T.
    IF US_ERROR NE SPACE.
      MESSAGE E430 WITH US_KONDA.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.