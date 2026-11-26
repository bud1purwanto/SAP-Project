*&---------------------------------------------------------------------*
*&      Form  T005U_SELECT                                             *
*&---------------------------------------------------------------------*
*       Text zu Steuerregion lesen                                     *
*----------------------------------------------------------------------*
*  -->  US_LAND1    : Land                                             *
*  -->  US_bland    : Steuerregion                                     *
*  <--  CH_SUBRC    : Returncode                                       *
*----------------------------------------------------------------------*
FORM T005U_SELECT USING US_LAND1  LIKE T005U-LAND1
                        US_BLAND  LIKE T005U-BLAND
                      CH_SUBRC    LIKE SY-SUBRC.

  CLEAR: CH_SUBRC.

  IF    US_LAND1 IS INITIAL
     OR US_BLAND IS INITIAL.
    CLEAR: T005U.
    EXIT.
  ENDIF.

  SELECT SINGLE * FROM T005U    WHERE SPRAS EQ SY-LANGU
                                AND   LAND1 EQ US_LAND1
                                AND   BLAND EQ US_BLAND.

  IF NOT ( SY-SUBRC IS INITIAL ).
    CLEAR: T005U.
    CH_SUBRC = 4.
  ENDIF.

ENDFORM.                               " T005U_SELECT