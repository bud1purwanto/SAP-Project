*---------------------------------------------------------------------*
*       FORM TSPA_SELECT                                              *
*---------------------------------------------------------------------*
*       Sparte lesen                                                  *
*---------------------------------------------------------------------*
FORM TSPA_SELECT USING US_SPART
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_SPART NE TSPA-SPART.

  IF US_SPART = SPACE.
    CLEAR: TSPA, TSPAT.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM TSPA WHERE SPART = US_SPART.
  IF SY-SUBRC NE 0.
    CLEAR: TSPA, TSPAT.
    IF US_ERROR NE SPACE.
      MESSAGE E315 WITH US_SPART.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.