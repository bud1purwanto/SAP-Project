*---------------------------------------------------------------------*
*       FORM TVCPA_SELECT                                             *
*---------------------------------------------------------------------*
*       Kopiertabelle lesen                                           *
*---------------------------------------------------------------------*
FORM TVCPA_SELECT USING US_AUARN
                        US_AUARV
                        US_FKARV
                        US_PSTYV
                        US_ETTYV
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
ENHANCEMENT-POINT TVCPA_SELECT_11 SPOTS ES_SAPMV45A STATIC.


ENHANCEMENT-SECTION     TVCPA_SELECT_10 SPOTS ES_SAPMV45A.
  CHECK: US_AUARN NE TVCPA-AUARN OR
         US_FKARV NE TVCPA-FKARV OR
         US_AUARV NE TVCPA-AUARV OR
         US_PSTYV NE TVCPA-PSTYV OR
         US_ETTYV NE TVCPA-ETTYV.

  IF US_AUARN = SPACE AND
     US_FKARV = SPACE AND
     US_AUARV = SPACE AND
     US_PSTYV = SPACE AND
     US_ETTYV = SPACE.
    CLEAR: TVCPA.
    EXIT.
  ENDIF.
END-ENHANCEMENT-SECTION.

  SELECT SINGLE * FROM TVCPA WHERE AUARN = US_AUARN AND
                                   AUARV = US_AUARV AND
                                   FKARV = US_FKARV AND
                                   PSTYV = US_PSTYV AND
                                   ETTYV = US_ETTYV.

  IF SY-SUBRC NE 0.
    CLEAR TVCPA.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      MESSAGE E471 WITH US_AUARN US_AUARV US_FKARV US_PSTYV.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENHANCEMENT-POINT TVCPA_SELECT_01 SPOTS ES_SAPMV45A.
ENDFORM.