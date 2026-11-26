*eject
*---------------------------------------------------------------------*
*       FORM TVAPT_SELECT                                             *
*---------------------------------------------------------------------*
*       Auftragspositionstypentabelle Text                            *
*---------------------------------------------------------------------*
FORM TVAPT_SELECT USING US_PSTYV
                        US_ERROR
                        CH_SUBRC.


  CH_SUBRC = 0.
  CHECK: US_PSTYV NE TVAPT-PSTYV.

  IF US_PSTYV = SPACE.
    CLEAR: TVAPT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVAPT WHERE SPRAS = SY-LANGU
                               AND PSTYV = US_PSTYV.
  IF SY-SUBRC NE 0.
    CLEAR: TVAPT.
    IF US_ERROR NE SPACE.
      MESSAGE E324 WITH US_PSTYV.
    ELSE.
      CH_SUBRC = 12.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.