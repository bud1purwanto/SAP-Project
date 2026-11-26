*eject
*---------------------------------------------------------------------*
*       FORM TVV1_SELECT                                              *
*---------------------------------------------------------------------*
*       Kopfgruppe 1 prüfen                                           *
*---------------------------------------------------------------------*
FORM TVV1_SELECT USING US_KVGR1
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KVGR1 NE TVV1-KVGR1.

  IF US_KVGR1 = SPACE.
    CLEAR: TVV1.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVV1 WHERE KVGR1 = US_KVGR1.

  IF SY-SUBRC NE 0.
    CLEAR: TVV1.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-KVGR1' LINE SY-STEPL.
      MESSAGE E568 WITH US_KVGR1.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.