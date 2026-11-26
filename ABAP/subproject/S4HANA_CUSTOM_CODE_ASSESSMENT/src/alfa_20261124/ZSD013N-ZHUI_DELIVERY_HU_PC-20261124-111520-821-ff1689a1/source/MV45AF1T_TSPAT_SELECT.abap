*eject
*---------------------------------------------------------------------*
*       FORM TSPAT_SELECT                                             *
*---------------------------------------------------------------------*
*       Sparte lesen Text                                             *
*---------------------------------------------------------------------*
FORM TSPAT_SELECT USING US_SPART
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_SPART NE TSPAT-SPART.

  IF US_SPART = SPACE.
    CLEAR: TSPAT.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM TSPAT WHERE SPRAS = SY-LANGU
                               AND SPART = US_SPART.
  IF SY-SUBRC NE 0.
    CLEAR: TSPAT.
    IF US_ERROR NE SPACE.
      message e157(V2) with us_spart sy-langu.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.