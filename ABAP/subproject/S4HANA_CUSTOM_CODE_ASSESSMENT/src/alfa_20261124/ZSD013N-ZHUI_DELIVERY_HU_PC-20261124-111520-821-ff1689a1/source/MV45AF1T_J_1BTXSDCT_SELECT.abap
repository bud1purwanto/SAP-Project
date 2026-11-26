*&---------------------------------------------------------------------*
*&      Form  J_1BTXSDCT_SELECT                                        *
*&---------------------------------------------------------------------*
*       Text zu SD-Steuerkennzeichen lesen                             *
*----------------------------------------------------------------------*
*  -->  US_J_1BTXSDC: SD-Steuerkennzeichen                             *
*  <--  CH_SUBRC    : Returncode                                       *
*----------------------------------------------------------------------*
FORM J_1BTXSDCT_SELECT USING US_J_1BTXSDC  LIKE VBAP-J_1BTXSDC
                             CH_SUBRC      LIKE SY-SUBRC.

ENHANCEMENT-POINT J_1BTXSDCT_SELECT_10 SPOTS ES_SAPMV45A.
  CLEAR: CH_SUBRC.

  IF    US_J_1BTXSDC IS INITIAL.
    CLEAR: J_1BTXSDCT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1BTXSDCT WHERE LANGU    EQ SY-LANGU
                                  AND   TAXCODE  EQ US_J_1BTXSDC.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1BTXSDCT.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1BTXSDCT_SELECT