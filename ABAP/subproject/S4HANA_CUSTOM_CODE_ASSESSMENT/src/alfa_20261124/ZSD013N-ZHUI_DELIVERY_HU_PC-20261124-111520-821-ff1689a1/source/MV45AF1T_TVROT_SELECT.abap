*eject
*---------------------------------------------------------------------*
*       FORM TVROT_SELECT                                             *
*---------------------------------------------------------------------*
*       Route lesen                                                   *
*---------------------------------------------------------------------*
FORM TVROT_SELECT USING US_ROUTE
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ROUTE NE TVROT-ROUTE.

  IF US_ROUTE = SPACE.
    CLEAR: TVROT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVROT WHERE SPRAS = SY-LANGU
                               AND ROUTE = US_ROUTE.

  IF SY-SUBRC NE 0.
    CLEAR: TVROT.
    IF US_ERROR = CHARX.
      MESSAGE E402 WITH US_ROUTE.
    ELSE.
      CH_SUBRC = SY-SUBRC.
    ENDIF.
  ENDIF.
ENDFORM.