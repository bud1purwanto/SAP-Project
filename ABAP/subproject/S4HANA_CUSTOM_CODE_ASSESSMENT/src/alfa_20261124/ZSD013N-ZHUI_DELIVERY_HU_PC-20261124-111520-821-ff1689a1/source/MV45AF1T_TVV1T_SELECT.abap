*eject
*---------------------------------------------------------------------*
*       FORM TVV1T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 1 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVV1T_SELECT USING US_KVGR1
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_KVGR1 = SPACE.
    CLEAR: TVV1T.
    EXIT.
  ENDIF.
  CHECK: US_KVGR1 NE TVV1T-KVGR1.

  SELECT SINGLE * FROM TVV1T WHERE SPRAS = SY-LANGU
                               AND KVGR1 = US_KVGR1.
  IF SY-SUBRC NE 0.
    CLEAR: TVV1T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.