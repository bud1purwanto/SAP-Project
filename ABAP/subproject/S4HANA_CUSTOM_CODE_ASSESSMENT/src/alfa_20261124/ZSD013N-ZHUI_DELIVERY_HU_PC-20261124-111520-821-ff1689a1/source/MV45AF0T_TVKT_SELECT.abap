*---------------------------------------------------------------------*
*       FORM TVKT_SELECT                                              *
*---------------------------------------------------------------------*
*       Kontierungsgruppe Debitor lesen                               *
*---------------------------------------------------------------------*
FORM TVKT_SELECT USING US_KTGRD
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KTGRD NE TVKT-KTGRD.

  IF US_KTGRD = SPACE.
    CLEAR: TVKT, TVKTT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVKT WHERE KTGRD = US_KTGRD.
  IF SY-SUBRC NE 0.
    CLEAR: TVKT, TVKTT.
    IF US_ERROR NE SPACE.
      MESSAGE E828 WITH US_KTGRD.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.