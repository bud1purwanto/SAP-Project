*eject
*---------------------------------------------------------------------*
*       FORM tvm1_SELECT                                              *
*---------------------------------------------------------------------*
*       Positionsgruppe prüfen                                        *
*---------------------------------------------------------------------*
FORM TVM1_SELECT USING US_MVGR1
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MVGR1 NE TVM1-MVGR1.

  IF US_MVGR1 = SPACE.
    CLEAR: TVM1.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVM1 WHERE MVGR1 = US_MVGR1.

  IF SY-SUBRC NE 0.
    CLEAR: TVM1.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-MVGR1' LINE SY-STEPL.
      MESSAGE E573 WITH US_MVGR1.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.