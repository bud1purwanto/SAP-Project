*eject
*---------------------------------------------------------------------*
*       FORM tvm3_SELECT                                              *
*---------------------------------------------------------------------*
*       Positionsgruppe prüfen                                        *
*---------------------------------------------------------------------*
FORM TVM3_SELECT USING US_MVGR3
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MVGR3 NE TVM3-MVGR3.

  IF US_MVGR3 = SPACE.
    CLEAR: TVM3.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVM3 WHERE MVGR3 = US_MVGR3.

  IF SY-SUBRC NE 0.
    CLEAR: TVM3.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-MVGR3' LINE SY-STEPL.
      MESSAGE E575 WITH US_MVGR3.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.