*eject
*---------------------------------------------------------------------*
*       FORM TVV5T_SELECT                                             *
*---------------------------------------------------------------------*
*       Kundengrupppe 5 Text lesen                                    *
*---------------------------------------------------------------------*
FORM TVV5T_SELECT USING US_KVGR5
                        CH_SUBRC.

  CH_SUBRC = 0.

  IF US_KVGR5 = SPACE.
    CLEAR: TVV5T.
    EXIT.
  ENDIF.
  CHECK: US_KVGR5 NE TVV5T-KVGR5.

  SELECT SINGLE * FROM TVV5T WHERE SPRAS = SY-LANGU
                               AND KVGR5 = US_KVGR5.
  IF SY-SUBRC NE 0.
    CLEAR: TVV5T.
    CH_SUBRC = 5.
  ENDIF.

ENDFORM.