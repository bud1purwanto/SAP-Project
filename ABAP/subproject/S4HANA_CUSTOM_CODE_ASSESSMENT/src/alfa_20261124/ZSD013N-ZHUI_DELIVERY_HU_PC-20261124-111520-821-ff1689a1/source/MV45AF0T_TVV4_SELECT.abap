*eject
*---------------------------------------------------------------------*
*       FORM tvv4_SELECT                                              *
*---------------------------------------------------------------------*
*       Kopfgruppe 4 prüfen                                           *
*---------------------------------------------------------------------*
FORM TVV4_SELECT USING US_KVGR4
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KVGR4 NE TVV4-KVGR4.

  IF US_KVGR4 = SPACE.
    CLEAR: TVV4.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVV4 WHERE KVGR4 = US_KVGR4.

  IF SY-SUBRC NE 0.
    CLEAR: TVV4.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-KVGR4' LINE SY-STEPL.
      MESSAGE E571 WITH US_KVGR4.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.