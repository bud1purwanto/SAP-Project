*---------------------------------------------------------------------*
*       FORM T001L_SELECT                                             *
*---------------------------------------------------------------------*
*       Lagertabelle lesen                                            *
*---------------------------------------------------------------------*
FORM T001L_SELECT USING US_WERKS
                        US_LGORT
               CHANGING CH_SUBRC.

  CHECK: US_WERKS NE T001L-WERKS OR
         US_LGORT NE T001L-LGORT.

  CH_SUBRC = 0.

  IF US_LGORT = SPACE.
    CLEAR: T001L.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T001L WHERE WERKS = US_WERKS
                               AND LGORT = US_LGORT.

  IF SY-SUBRC NE 0.
    CLEAR T001L.
    IF US_LGORT NE SPACE.
      CH_SUBRC = 2.
    ENDIF.
  ENDIF.

ENDFORM.