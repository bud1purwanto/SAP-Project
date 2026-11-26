*----------------------------------------------------------------------*
*  -->  US_J_1AINDXP  : Indizierungstyp                                *
*  <--  CH_SUBRC      : Returncode                                     *
*----------------------------------------------------------------------*
FORM J_1AINFT21_SELECT USING US_J_1AINDXP LIKE VBKD-J_1AINDXP
                             CH_SUBRC     LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF US_J_1AINDXP IS INITIAL.
    CLEAR: J_1AINFT21.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1AINFT21 WHERE SPRACS     EQ SY-LANGU
                                  AND   J_1AINDX   EQ US_J_1AINDXP.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1AINFT21.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1AINFT21_SELECT