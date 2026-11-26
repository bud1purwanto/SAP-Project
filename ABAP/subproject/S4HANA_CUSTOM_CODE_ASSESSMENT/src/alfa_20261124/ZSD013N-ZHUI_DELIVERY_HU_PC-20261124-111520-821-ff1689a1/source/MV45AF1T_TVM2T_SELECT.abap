*eject
*---------------------------------------------------------------------*
*       FORM TVM2T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 2 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVM2T_SELECT USING US_MVGR2
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_MVGR2 = SPACE.
    CLEAR: TVM2T.
    EXIT.
  ENDIF.
  CHECK: US_MVGR2 NE TVM2T-MVGR2.

  SELECT SINGLE * FROM TVM2T WHERE SPRAS = SY-LANGU
                               AND MVGR2 = US_MVGR2.
  IF SY-SUBRC NE 0.
    CLEAR: TVM2T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.