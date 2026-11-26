*eject
*---------------------------------------------------------------------*
*       FORM tvv2_SELECT                                              *
*---------------------------------------------------------------------*
*       Kopfgruppe 2 prüfen                                           *
*---------------------------------------------------------------------*
FORM TVV2_SELECT USING US_KVGR2
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_KVGR2 NE TVV2-KVGR2.

  IF US_KVGR2 = SPACE.
    CLEAR: TVV2.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVV2 WHERE KVGR2 = US_KVGR2.

  IF SY-SUBRC NE 0.
    CLEAR: TVV2.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-KVGR2' LINE SY-STEPL.
      MESSAGE E569 WITH US_KVGR2.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.