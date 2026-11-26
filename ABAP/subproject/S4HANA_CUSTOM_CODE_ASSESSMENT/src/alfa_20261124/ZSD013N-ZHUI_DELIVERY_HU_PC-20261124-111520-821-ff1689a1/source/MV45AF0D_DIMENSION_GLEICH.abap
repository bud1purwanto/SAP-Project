*---------------------------------------------------------------------*
*       FORM DIMENSION_GLEICH                                         *
*---------------------------------------------------------------------*
*  ch_subrc = 0: beide gleiche Dimension                              *
*  ch_subrc = 1: nicht gleiche Dimension, oder keine Dimension        *
*---------------------------------------------------------------------*
FORM DIMENSION_GLEICH USING US_MEIN1
                            US_MEIN2
                      CHANGING VALUE(CH_SUBRC).

  DATA: DA_DIM1 LIKE T006-DIMID,
        DA_DIM2 LIKE T006-DIMID.
  CH_SUBRC = 1.
  CALL FUNCTION 'DIMENSIONCHECK_DIMENSIONLESS'
       EXPORTING
            MEINH                       = US_MEIN1
       EXCEPTIONS
            DIMENSION_NOT_DIMENSIONLESS = 1
            OTHERS                      = 4.
  CHECK SY-SUBRC > 0.
  CALL FUNCTION 'DIMENSIONCHECK_DIMENSIONLESS'
       EXPORTING
            MEINH                       = US_MEIN2
       EXCEPTIONS
            DIMENSION_NOT_DIMENSIONLESS = 1
            OTHERS                      = 4.
  CHECK SY-SUBRC > 0.

  CALL FUNCTION 'DIMENSION_GET_FOR_UNIT'
       EXPORTING
            UNIT                = US_MEIN1
       IMPORTING
            DIMENSION           = DA_DIM1
       EXCEPTIONS
            OTHERS              = 1.
  IF SY-SUBRC > 0.
    CH_SUBRC = 0.
    EXIT.
  ENDIF.
  CALL FUNCTION 'DIMENSION_GET_FOR_UNIT'
       EXPORTING
            UNIT                = US_MEIN2
       IMPORTING
            DIMENSION           = DA_DIM2
       EXCEPTIONS
            OTHERS              = 1.
  IF SY-SUBRC > 0.
    CH_SUBRC = 0.
    EXIT.
  ENDIF.
  IF DA_DIM1 = DA_DIM2.
    CH_SUBRC = 0.
    EXIT.
  ENDIF.

ENDFORM.