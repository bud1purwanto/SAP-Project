*eject
*---------------------------------------------------------------------*
*       FORM tvm2_SELECT                                              *
*---------------------------------------------------------------------*
*       Positionsgruppe prüfen                                        *
*---------------------------------------------------------------------*
FORM TVM2_SELECT USING US_MVGR2
                       US_ERROR
                       CH_SUBRC.

  CH_SUBRC = 0.
  CHECK: US_MVGR2 NE TVM2-MVGR2.

  IF US_MVGR2 = SPACE.
    CLEAR: TVM2.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM TVM2 WHERE MVGR2 = US_MVGR2.

  IF SY-SUBRC NE 0.
    CLEAR: TVM2.
    IF US_ERROR = CHARX.
* internes Fehlerhandling
      SET CURSOR FIELD 'VBAK-MVGR2' LINE SY-STEPL.
      MESSAGE E574 WITH US_MVGR2.
    ELSE.
* externes Fehlerhandling
      CH_SUBRC = SY-SUBRC.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.