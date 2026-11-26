*&---------------------------------------------------------------------*
*&      Form  J_1BATL2T_SELECT                                         *
*&---------------------------------------------------------------------*
*       Text zu Steuergesetz IPI lesen (Brasilien)                     *
*----------------------------------------------------------------------*
*  -->  US_J_1BTAXLW2: Steuergesetz IPI                                *
*  <--  CH_SUBRC     : Returncode                                      *
*----------------------------------------------------------------------*
FORM J_1BATL2T_SELECT USING US_J_1BTAXLW2 LIKE VBAP-J_1BTAXLW2
                            CH_SUBRC      LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF US_J_1BTAXLW2 IS INITIAL.
    CLEAR: J_1BATL2T.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1BATL2T WHERE LANGU    EQ SY-LANGU
                                 AND   TAXLAW   EQ US_J_1BTAXLW2.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1BATL2T.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1BATL2T_SELECT