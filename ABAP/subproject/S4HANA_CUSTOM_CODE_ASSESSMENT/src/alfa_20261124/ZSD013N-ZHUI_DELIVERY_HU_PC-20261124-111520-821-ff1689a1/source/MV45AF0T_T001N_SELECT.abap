*---------------------------------------------------------------------*
*       FORM T001N_SELECT                                             *
*---------------------------------------------------------------------*
*       Steuernummern des Buchungskreises lesen                       *
*---------------------------------------------------------------------*
FORM T001N_SELECT USING US_BUKRS
                        US_LAND1
                        US_ERROR
                        CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_BUKRS NE T001N-BUKRS OR US_LAND1 NE T001N-LAND1.

  SELECT SINGLE * FROM T001N WHERE BUKRS = US_BUKRS
                               AND LAND1 = US_LAND1.


  IF SY-SUBRC NE 0.
    CLEAR: T001N.
    IF US_ERROR = CHARX.
      MESSAGE W694 WITH US_BUKRS US_LAND1.
    ENDIF.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.