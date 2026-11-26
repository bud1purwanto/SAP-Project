*eject
*---------------------------------------------------------------------*
*       FORM T003P_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftragsart PP mit Text lesen                                 *
*---------------------------------------------------------------------*
FORM T003P_SELECT USING US_AUART
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_AUART NE T003P-AUART,
         NOT VBEP-AUFNR IS INITIAL.

  IF US_AUART = SPACE.
    CLEAR: T003P.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T003P WHERE SPRAS = SY-LANGU
                               AND AUART = US_AUART.
  IF SY-SUBRC NE 0.
    CLEAR: T003P.
    IF US_ERROR NE SPACE.
      MESSAGE E457 WITH US_AUART.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.