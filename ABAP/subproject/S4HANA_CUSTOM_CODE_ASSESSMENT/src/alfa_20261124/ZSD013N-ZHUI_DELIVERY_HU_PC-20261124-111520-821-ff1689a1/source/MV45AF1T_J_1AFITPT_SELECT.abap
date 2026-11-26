*&---------------------------------------------------------------------*
*&      Form  J_1AFITPT_SELECT                                         *
*&---------------------------------------------------------------------*
*       Text zur Steuerart lesen                                       *
*----------------------------------------------------------------------*
*  -->  US_J_1AFITP: Steuerart                                         *
*  <--  CH_SUBRC   : Returncode                                        *
*----------------------------------------------------------------------*
FORM J_1AFITPT_SELECT USING US_J_1AFITP LIKE VBKD-J_1AFITP
                            CH_SUBRC    LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF    US_J_1AFITP IS INITIAL.
    CLEAR: J_1AFITPVT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1AFITPVT WHERE SPRAS EQ SY-LANGU
                                  AND   J_1AFITP EQ US_J_1AFITP.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1AFITPVT.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1AFITPT_SELECT