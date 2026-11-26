*---------------------------------------------------------------------*
*       FORM TVEP_SELECT                                              *
*---------------------------------------------------------------------*
*       Die Einteilungstypentabelle wird gelesen                      *
*---------------------------------------------------------------------*
FORM TVEP_SELECT USING US_ETTYP
                       US_ERROR
                       CH_SUBRC.

ENHANCEMENT-POINT TVEP_SELECT_01 SPOTS ES_SAPMV45A.
  CH_SUBRC = 0.
  CHECK: US_ETTYP NE TVEP-ETTYP.

  IF US_ETTYP = SPACE.
    CLEAR: TVEPT, TVEP.
    EXIT.
  ENDIF.
  SELECT SINGLE * FROM TVEP WHERE ETTYP = US_ETTYP.
ENHANCEMENT-SECTION     TVEP_SELECT_02 SPOTS ES_SAPMV45A.
  IF SY-SUBRC NE 0.
    CLEAR: TVEP, TVEPT.
    IF US_ERROR NE SPACE.
      MESSAGE E353 WITH US_ETTYP.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.
END-ENHANCEMENT-SECTION.
ENDFORM.