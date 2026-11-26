*eject
*---------------------------------------------------------------------*
*       FORM TVM4T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 4 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVM4T_SELECT USING US_MVGR4
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_MVGR4 = SPACE.
    CLEAR: TVM4T.
    EXIT.
  ENDIF.
  CHECK: US_MVGR4 NE TVM4T-MVGR4.

  SELECT SINGLE * FROM TVM4T WHERE SPRAS = SY-LANGU
                               AND MVGR4 = US_MVGR4.
  IF SY-SUBRC NE 0.
    CLEAR: TVM4T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.