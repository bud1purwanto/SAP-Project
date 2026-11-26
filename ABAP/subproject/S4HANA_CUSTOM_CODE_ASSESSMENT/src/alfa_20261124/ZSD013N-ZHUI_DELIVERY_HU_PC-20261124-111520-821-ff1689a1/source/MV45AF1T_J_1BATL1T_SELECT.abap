*&---------------------------------------------------------------------*
*&      Form  J_1BATL1T_SELECT                                         *
*&---------------------------------------------------------------------*
*       Text zu Steuergesetz ICMS lesen (Brasilien)                    *
*----------------------------------------------------------------------*
*  -->  US_J_1BTAXLW1: Steuergesetz ICMS                               *
*  <--  CH_SUBRC     : Returncode                                      *
*----------------------------------------------------------------------*
FORM J_1BATL1T_SELECT USING US_J_1BTAXLW1 LIKE VBAP-J_1BTAXLW1
                          CH_SUBRC      LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF US_J_1BTAXLW1 IS INITIAL.
    CLEAR: J_1BATL1T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1BATL1T WHERE LANGU    EQ SY-LANGU
                                 AND   TAXLAW   EQ US_J_1BTAXLW1.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1BATL1T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1BATL1T_SELECT