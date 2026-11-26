*eject
*---------------------------------------------------------------------*
*       FORM TVV4T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 4 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVV4T_SELECT USING US_KVGR4
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_KVGR4 = SPACE.
    CLEAR: TVV4T.
    EXIT.
  ENDIF.
  CHECK: US_KVGR4 NE TVV4T-KVGR4.

  SELECT SINGLE * FROM TVV4T WHERE SPRAS = SY-LANGU
                               AND KVGR4 = US_KVGR4.
  IF SY-SUBRC NE 0.
    CLEAR: TVV4T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.