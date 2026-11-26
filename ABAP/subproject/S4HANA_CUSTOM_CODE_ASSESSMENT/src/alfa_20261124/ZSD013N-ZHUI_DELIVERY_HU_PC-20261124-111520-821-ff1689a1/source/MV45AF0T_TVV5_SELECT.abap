*eject
*---------------------------------------------------------------------*
*       FORM tvv5_SELECT                                              *
*---------------------------------------------------------------------*
*       Kopfgruppe 5 prüfen                                           *
*---------------------------------------------------------------------*
FORM TVV5_SELECT USING US_KVGR5
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KVGR5 NE TVV5-KVGR5.

  IF US_KVGR5 = SPACE.
    CLEAR: TVV5.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVV5 WHERE KVGR5 = US_KVGR5.

  IF SY-SUBRC NE 0.
    CLEAR: TVV5.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-KVGR5' LINE SY-STEPL.
      MESSAGE E572 WITH US_KVGR5.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.