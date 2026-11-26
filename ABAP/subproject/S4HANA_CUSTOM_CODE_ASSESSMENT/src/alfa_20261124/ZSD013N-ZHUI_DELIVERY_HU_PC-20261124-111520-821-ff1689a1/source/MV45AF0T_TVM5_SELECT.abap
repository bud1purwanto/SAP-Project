*eject
*---------------------------------------------------------------------*
*       FORM tvm5_SELECT                                              *
*---------------------------------------------------------------------*
*       Positionsgruppe prüfen                                        *
*---------------------------------------------------------------------*
FORM TVM5_SELECT USING US_MVGR5
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MVGR5 NE TVM5-MVGR5.

  IF US_MVGR5 = SPACE.
    CLEAR: TVM5.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVM5 WHERE MVGR5 = US_MVGR5.

  IF SY-SUBRC NE 0.
    CLEAR: TVM5.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-MVGR5' LINE SY-STEPL.
      MESSAGE E577 WITH US_MVGR5.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.