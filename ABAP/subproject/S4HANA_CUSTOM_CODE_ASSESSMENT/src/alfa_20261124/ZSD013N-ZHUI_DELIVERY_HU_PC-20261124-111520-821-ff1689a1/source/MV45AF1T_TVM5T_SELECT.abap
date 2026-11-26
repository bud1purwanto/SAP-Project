*eject
*---------------------------------------------------------------------*
*       FORM TVM5T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 5 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVM5T_SELECT USING US_MVGR5
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_MVGR5 = SPACE.
    CLEAR: TVM5T.
    EXIT.
  ENDIF.
  CHECK: US_MVGR5 NE TVM5T-MVGR5.

  SELECT SINGLE * FROM TVM5T WHERE SPRAS = SY-LANGU
                               AND MVGR5 = US_MVGR5.
  IF SY-SUBRC NE 0.
    CLEAR: TVM5T.
    CH_SUBRC = 5.
  ENDIF.

ENDFORM.