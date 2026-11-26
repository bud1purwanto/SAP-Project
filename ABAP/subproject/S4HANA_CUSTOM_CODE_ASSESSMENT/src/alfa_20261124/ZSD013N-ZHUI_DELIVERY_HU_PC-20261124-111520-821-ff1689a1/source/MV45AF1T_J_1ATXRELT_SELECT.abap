*&---------------------------------------------------------------------*
*&      Form  J_1A_TAXRELT_SELECT                                      *
*&---------------------------------------------------------------------*
*       Text zu Steuerbefreiungsgrund lesen                            *
*----------------------------------------------------------------------*
*  -->  US_J_1ATXREL  : Klassifizierung Steuerrelevanz                 *
*  <--  CH_SUBRC      : Returncode                                     *
*----------------------------------------------------------------------*
FORM J_1ATXRELT_SELECT USING US_J_1ATXREL LIKE VBKD-J_1ATXREL
                             CH_SUBRC     LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF US_J_1ATXREL IS INITIAL.
    CLEAR: J_1ATXRELT.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM J_1ATXRELT WHERE SPRAS      EQ SY-LANGU
                                  AND   J_1ATXREL  EQ US_J_1ATXREL.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: J_1ATXRELT.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " J_1ATXRELT_SELECT