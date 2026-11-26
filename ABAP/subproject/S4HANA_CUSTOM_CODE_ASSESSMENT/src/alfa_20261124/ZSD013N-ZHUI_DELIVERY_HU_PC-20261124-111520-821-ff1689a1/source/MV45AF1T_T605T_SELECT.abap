*eject
*&---------------------------------------------------------------------*
*&      Form  T605T_SELECT
*&---------------------------------------------------------------------*
*       Test zur Geschäftsart lesen                                    *
*----------------------------------------------------------------------*
*  -->  US_EXART : Geschäftstart                                       *
*  -->  US_WERKS : Lieferndes Werk                                     *
*  <--  CH_SUBRC : Returncode                                          *
*----------------------------------------------------------------------*
FORM T605T_SELECT USING US_EXART LIKE VBAP-EXART
                        US_WERKS LIKE XVBAP-WERKS
                        US_LAND1 LIKE XVBAP-WKLND
                        CH_SUBRC LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF    US_WERKS IS INITIAL
     OR US_EXART IS INITIAL.
    CLEAR: T605T.
    EXIT.
  ENDIF.

  IF ( T605T-SPRAS EQ SY-LANGU ) AND
     ( T605T-LAND1 EQ US_LAND1 ) AND
     ( T605T-EXART EQ US_EXART ) .
*------- Nada

  ELSE.
    SELECT SINGLE * FROM T605T WHERE SPRAS EQ SY-LANGU
                               AND   LAND1 EQ US_LAND1
                               AND   EXART EQ US_EXART.

    IF NOT ( SY-SUBRC IS INITIAL ).
      CLEAR: T605T.
      CH_SUBRC = 4.
    ENDIF.

  ENDIF.

ENDFORM.                               " T605T_SELECT