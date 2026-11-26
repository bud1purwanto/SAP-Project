*---------------------------------------------------------------------*
*       FORM TSKM_SELECT                                              *
*---------------------------------------------------------------------*
*       Steuerindikator Material lesen                                *
*---------------------------------------------------------------------*
FORM TSKM_SELECT USING US_TATYP
                       US_TAXKM
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_TATYP NE TSKM-TATYP OR
         US_TAXKM NE TSKM-TAXKM.

  IF US_TATYP = SPACE.
    CLEAR: TSKM.
    EXIT.
  ENDIF.

  check not us_taxkm is initial.

  SELECT SINGLE * FROM TSKM WHERE TATYP = US_TATYP
                              AND TAXKM = US_TAXKM.
  IF SY-SUBRC NE 0.
    CLEAR: TSKM.
    IF US_ERROR NE SPACE.
      MESSAGE E089 WITH US_TATYP US_TAXKM.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.