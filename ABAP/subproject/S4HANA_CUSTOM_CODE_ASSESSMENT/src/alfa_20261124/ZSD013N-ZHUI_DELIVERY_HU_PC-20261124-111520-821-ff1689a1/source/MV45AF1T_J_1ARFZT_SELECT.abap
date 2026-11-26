*&---------------------------------------------------------------------*
*&      Form  J_1ARFZT_SELECT                                          *
*&---------------------------------------------------------------------*
*       Text zu Steuerbefreiungsgrund lesen                            *
*----------------------------------------------------------------------*
*  -->  US_J_1ARFZ : Steuerbefreiungsgrund                             *
*  <--  CH_SUBRC   : Returncode                                        *
*----------------------------------------------------------------------*
FORM J_1ARFZT_SELECT USING US_J_1ARFZ  LIKE VBKD-J_1ARFZ
                           CH_SUBRC    LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF US_J_1ARFZ IS INITIAL.
    CLEAR: J_1ARFZT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1ARFZT WHERE SPRAS   EQ SY-LANGU
                                AND   J_1ARFZ EQ US_J_1ARFZ.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1ARFZT.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1ARFZT_SELECT