*---------------------------------------------------------------------*
*       FORM T003N_SELECT                                             *
*---------------------------------------------------------------------*
*       Auftragsart lesen                                             *
*---------------------------------------------------------------------*
FORM T003O_SELECT USING US_AUART
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_AUART NE T003O-AUART.

  SELECT SINGLE * FROM T003O WHERE AUART = US_AUART.

  IF SY-SUBRC NE 0.
    CLEAR: T003O.
    IF US_ERROR = CHARX.
      MESSAGE E005(CO) WITH US_AUART.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.