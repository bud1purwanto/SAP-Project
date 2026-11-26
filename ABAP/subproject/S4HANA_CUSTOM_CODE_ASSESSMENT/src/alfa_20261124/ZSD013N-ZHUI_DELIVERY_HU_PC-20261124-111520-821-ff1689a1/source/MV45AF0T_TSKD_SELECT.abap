*eject
*---------------------------------------------------------------------*
*       FORM TSKD_SELECT                                              *
*---------------------------------------------------------------------*
*       Steuerindikator Kunde    lesen                                *
*---------------------------------------------------------------------*
FORM TSKD_SELECT USING US_TATYP
                       US_TAXKD
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_TATYP NE TSKD-TATYP OR
         US_TAXKD NE TSKD-TAXKD.

  IF US_TATYP = SPACE.
    CLEAR: TSKD.
    EXIT.
  ENDIF.


  SELECT SINGLE * FROM TSKD WHERE TATYP = US_TATYP
                              AND TAXKD = US_TAXKD.
  IF SY-SUBRC NE 0.
    CLEAR: TSKD.
    IF US_ERROR NE SPACE.
      MESSAGE E089 WITH US_TATYP US_TAXKD.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.