*eject
*---------------------------------------------------------------------*
*       FORM TVEPT_SELECT                                             *
*---------------------------------------------------------------------*
*       Die Einteilungstypentabelle wird gelesen                      *
*---------------------------------------------------------------------*
FORM TVEPT_SELECT USING US_ETTYP
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ETTYP NE TVEPT-ETTYP.

  IF US_ETTYP = SPACE.
    CLEAR: TVEPT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVEPT WHERE SPRAS = SY-LANGU
                               AND ETTYP = US_ETTYP.
  IF SY-SUBRC NE 0.
    CLEAR: TVEPT.
    IF US_ERROR NE SPACE.
      MESSAGE E354 WITH US_ETTYP.
    ELSE.
      CH_SUBRC = 12.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.