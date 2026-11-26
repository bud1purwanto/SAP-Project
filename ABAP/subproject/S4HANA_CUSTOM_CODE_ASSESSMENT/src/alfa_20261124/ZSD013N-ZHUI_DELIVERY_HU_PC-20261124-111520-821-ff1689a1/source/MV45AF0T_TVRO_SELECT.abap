*eject
*---------------------------------------------------------------------*
*       FORM TVRO_SELECT                                              *
*---------------------------------------------------------------------*
*       Route lesen                                                   *
*---------------------------------------------------------------------*
FORM TVRO_SELECT USING US_ROUTE
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ROUTE NE TVRO-ROUTE.

  IF US_ROUTE = SPACE.
    CLEAR: TVRO, TVROT.
    EXIT.
  ENDIF.

* generischer zugriff
  SELECT SINGLE * FROM TVRO WHERE ROUTE = US_ROUTE.

  IF SY-SUBRC NE 0.
    CLEAR: TVRO, TVROT.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAP-ROUTE' LINE SY-STEPL.
      MESSAGE E402 WITH US_ROUTE.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.

ENDFORM.