*eject
*---------------------------------------------------------------------*
*       FORM TVRL_SELECT                                              *
*---------------------------------------------------------------------*
*       Liefersperre lesen                                            *
*---------------------------------------------------------------------*
FORM TVRL_SELECT USING US_RVREL
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_RVREL NE TVRL-RVREL.

  IF US_RVREL = SPACE.
    CLEAR: TVRL.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVRL WHERE RVREL = US_RVREL.
  IF SY-SUBRC NE 0.
    CLEAR: TVRL.
    CH_SUBRC = 4.
    EXIT.
  ENDIF.


ENDFORM.