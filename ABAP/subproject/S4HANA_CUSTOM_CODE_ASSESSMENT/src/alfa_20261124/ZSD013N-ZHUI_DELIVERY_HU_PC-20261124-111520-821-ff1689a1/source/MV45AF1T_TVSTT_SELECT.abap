*eject
*---------------------------------------------------------------------*
*       FORM TVSTT_SELECT                                              *
*---------------------------------------------------------------------*
*       Versandstelle und Text lesen                                  *
*---------------------------------------------------------------------*
FORM TVSTT_SELECT USING US_VSTEL
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_VSTEL NE TVSTT-VSTEL.

  IF US_VSTEL = SPACE.
    CLEAR TVSTT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVSTT WHERE SPRAS = SY-LANGU
                               AND VSTEL = US_VSTEL.

  IF SY-SUBRC NE 0.
    CLEAR: TVSTT.
    IF US_ERROR = CHARX.
      MESSAGE E240 WITH US_VSTEL.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.