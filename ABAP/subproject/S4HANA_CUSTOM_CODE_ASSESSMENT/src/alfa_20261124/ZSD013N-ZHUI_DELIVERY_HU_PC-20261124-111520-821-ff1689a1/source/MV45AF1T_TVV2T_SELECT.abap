*eject
*---------------------------------------------------------------------*
*       FORM TVV2T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 2 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVV2T_SELECT USING US_KVGR2
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_KVGR2 = SPACE.
    CLEAR: TVV2T.
    EXIT.
  ENDIF.
  CHECK: US_KVGR2 NE TVV2T-KVGR2.

  SELECT SINGLE * FROM TVV2T WHERE SPRAS = SY-LANGU
                               AND KVGR2 = US_KVGR2.
  IF SY-SUBRC NE 0.
    CLEAR: TVV2T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.