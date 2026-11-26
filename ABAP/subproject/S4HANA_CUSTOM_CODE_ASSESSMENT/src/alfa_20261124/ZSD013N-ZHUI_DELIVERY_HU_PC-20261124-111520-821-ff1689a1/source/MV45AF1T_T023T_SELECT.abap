*eject
*---------------------------------------------------------------------*
*       FORM T023T_SELECT                                             *
*---------------------------------------------------------------------*
*       Watrengruppe    Text lesen                                    *
*---------------------------------------------------------------------*
FORM T023T_SELECT USING US_MATKL
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_MATKL = SPACE.
    CLEAR: T023T.
    EXIT.
  ENDIF.
  CHECK: US_MATKL NE T023T-MATKL.

  SELECT SINGLE * FROM T023T WHERE SPRAS = SY-LANGU
                               AND MATKL = US_MATKL.
  IF SY-SUBRC NE 0.
    CLEAR: T023T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.