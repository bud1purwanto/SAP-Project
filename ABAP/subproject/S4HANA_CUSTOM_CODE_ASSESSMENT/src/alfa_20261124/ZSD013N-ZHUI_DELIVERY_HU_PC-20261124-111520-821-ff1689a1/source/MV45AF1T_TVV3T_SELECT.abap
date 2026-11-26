*eject
*---------------------------------------------------------------------*
*       FORM TVV3T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 3 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVV3T_SELECT USING US_KVGR3
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_KVGR3 = SPACE.
    CLEAR: TVV3T.
    EXIT.
  ENDIF.
  CHECK: US_KVGR3 NE TVV3T-KVGR3.

  SELECT SINGLE * FROM TVV3T WHERE SPRAS = SY-LANGU
                               AND KVGR3 = US_KVGR3.
  IF SY-SUBRC NE 0.
    CLEAR: TVV3T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.