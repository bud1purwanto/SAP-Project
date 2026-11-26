*eject
*---------------------------------------------------------------------*
*       FORM tvv3_SELECT                                              *
*---------------------------------------------------------------------*
*       Kopfgruppe 3 prüfen                                           *
*---------------------------------------------------------------------*
FORM TVV3_SELECT USING US_KVGR3
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KVGR3 NE TVV3-KVGR3.

  IF US_KVGR3 = SPACE.
    CLEAR: TVV3.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVV3 WHERE KVGR3 = US_KVGR3.

  IF SY-SUBRC NE 0.
    CLEAR: TVV3.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-KVGR3' LINE SY-STEPL.
      MESSAGE E570 WITH US_KVGR3.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.