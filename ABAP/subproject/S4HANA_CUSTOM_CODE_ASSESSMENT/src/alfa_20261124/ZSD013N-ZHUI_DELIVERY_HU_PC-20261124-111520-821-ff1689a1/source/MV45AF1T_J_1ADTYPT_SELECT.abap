*&---------------------------------------------------------------------*
*&      Form  J_1ADTYPT_SELECT                                         *
*&---------------------------------------------------------------------*
*       Text zu Steuerbefreiungsgrund lesen                            *
*----------------------------------------------------------------------*
*  -->  US_BUKRS   : Buchungskreis                                     *
*  -->  US_J_1ADTYP: Verteilungsart                                    *
*  <--  CH_SUBRC   : Returncode                                        *
*----------------------------------------------------------------------*
FORM J_1ADTYPT_SELECT USING US_BUKRS    LIKE T001-BUKRS
                            US_J_1ADTYP LIKE VBKD-J_1ADTYP
                            CH_SUBRC    LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF     US_BUKRS    IS INITIAL
     OR  US_J_1ADTYP IS INITIAL.
    CLEAR: J_1ADTYPT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1ADTYPT WHERE SPRAS    EQ SY-LANGU
                                 AND   BUKRS    EQ US_BUKRS
                                 AND   J_1ADTYP EQ US_J_1ADTYP.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1ADTYPT.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1ADTYPT_SELECT