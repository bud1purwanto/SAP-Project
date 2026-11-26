*&---------------------------------------------------------------------*
*&      Form  J_1AGICDU_SELECT                                         *
*&---------------------------------------------------------------------*
*       Text zu Steuerbefreiungsgrund lesen                            *
*----------------------------------------------------------------------*
*  -->  US_LAND1   : Steuerart                                         *
*  -->  US_J_1AGICD: Tätigkeitskennzeichen für Lohnsteuer              *
*  <--  CH_SUBRC   : Returncode                                        *
*----------------------------------------------------------------------*
FORM J_1AGICDU_SELECT USING US_LAND1    LIKE T005U-LAND1
                            US_J_1AGICD LIKE VBKD-J_1AGICD
                            CH_SUBRC    LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF     US_LAND1 IS INITIAL
     OR  US_J_1AGICD IS INITIAL.
    CLEAR: J_1AGICDU.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1AGICDU WHERE SPRAS    EQ SY-LANGU
                                 AND   LAND1    EQ US_LAND1
                                 AND   J_1AGICD EQ US_J_1AGICD.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1AGICDU.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1AGICDU_SELECT