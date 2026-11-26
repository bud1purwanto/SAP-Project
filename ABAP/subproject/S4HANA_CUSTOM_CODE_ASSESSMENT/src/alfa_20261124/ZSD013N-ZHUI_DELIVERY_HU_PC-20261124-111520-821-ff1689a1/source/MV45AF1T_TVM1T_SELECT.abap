*---------------------------------------------------------------------*
*       FORM TVM1T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 1 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVM1T_SELECT USING US_MVGR1
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_MVGR1 = SPACE.
    CLEAR: TVM1T.
    EXIT.
  ENDIF.
  CHECK: US_MVGR1 NE TVM1T-MVGR1.

  SELECT SINGLE * FROM TVM1T WHERE SPRAS = SY-LANGU
                               AND MVGR1 = US_MVGR1.
  IF SY-SUBRC NE 0.
    CLEAR: TVM1T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.