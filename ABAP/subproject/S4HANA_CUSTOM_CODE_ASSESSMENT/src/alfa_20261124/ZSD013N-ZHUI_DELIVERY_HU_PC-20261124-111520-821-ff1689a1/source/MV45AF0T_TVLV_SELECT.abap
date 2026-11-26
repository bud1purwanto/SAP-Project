*---------------------------------------------------------------------*
*       FORM TVLV_SELECT                                              *
*---------------------------------------------------------------------*
*       Abrufe Verwendungskennzeichen                                 *
*---------------------------------------------------------------------*
FORM TVLV_SELECT USING US_ABRVW
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_ABRVW NE TVLV-ABRVW.

  IF US_ABRVW = SPACE.
    CLEAR: TVLV, TVLVT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVLV WHERE ABRVW = US_ABRVW.
  IF SY-SUBRC NE 0.
    CLEAR: TVLV, TVLVT.
    IF US_ERROR NE SPACE.
      MESSAGE E833 WITH US_ABRVW.
    ELSE.
      CH_SUBRC = 4.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.