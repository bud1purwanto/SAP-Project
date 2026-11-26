*eject
*---------------------------------------------------------------------*
*       FORM tvm4_SELECT                                              *
*---------------------------------------------------------------------*
*       Positionsgruppe prüfen                                        *
*---------------------------------------------------------------------*
FORM TVM4_SELECT USING US_MVGR4
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MVGR4 NE TVM4-MVGR4.

  IF US_MVGR4 = SPACE.
    CLEAR: TVM4.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVM4 WHERE MVGR4 = US_MVGR4.

  IF SY-SUBRC NE 0.
    CLEAR: TVM4.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-MVGR4' LINE SY-STEPL.
      MESSAGE E576 WITH US_MVGR4.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.