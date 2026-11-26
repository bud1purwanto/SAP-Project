*eject
*---------------------------------------------------------------------*
*       FORM TVM3T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 3 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVM3T_SELECT USING US_MVGR3
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_MVGR3 = SPACE.
    CLEAR: TVM3T.
    EXIT.
  ENDIF.
  CHECK: US_MVGR3 NE TVM3T-MVGR3.

  SELECT SINGLE * FROM TVM3T WHERE SPRAS = SY-LANGU
                               AND MVGR3 = US_MVGR3.
  IF SY-SUBRC NE 0.
    CLEAR: TVM3T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.