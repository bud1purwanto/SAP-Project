*eject
*---------------------------------------------------------------------*
*       FORM T001_SELECT                                              *
*---------------------------------------------------------------------*
*       Auftragsartentabelle lesen                                    *
*---------------------------------------------------------------------*
FORM T001_SELECT USING US_BUKRS
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BUKRS NE T001-BUKRS.

  SELECT SINGLE * FROM T001 WHERE BUKRS = US_BUKRS.

  IF SY-SUBRC NE 0.
    CLEAR: T001.
    IF US_ERROR = CHARX.
      MESSAGE E037 WITH US_BUKRS.
    ELSE.
      CH_SUBRC = 4.
    ENDIF.
  ENDIF.

ENDFORM.