*---------------------------------------------------------------------*
*       FORM KURS_ERMITTELN                                           *
*---------------------------------------------------------------------*
*       Kurs einer Währung zur Hauswährung ermitteln                  *
*       US_SUBRC = 1  --> Fehlschlag                                  *
*---------------------------------------------------------------------*
FORM KURS_ERMITTELN USING    US_BUKRS
                             US_DATUM
                             US_WAERK
                    CHANGING VALUE(CH_SUBRC)
                             CH_KURSK.

  CH_SUBRC = 0.
* Hauswährung ermitteln
  PERFORM T001_SELECT(SAPMV45A) USING US_BUKRS
                                      SPACE
                                      SY-SUBRC.
  IF SY-SUBRC <> 0.
    CH_SUBRC = 1.
  ELSE.
* Umrechnungskurs zwischen Hauswährung und Kontraktwährung ermitteln
    CALL FUNCTION 'CONVERT_TO_FOREIGN_CURRENCY'
        EXPORTING
          DATE             = US_DATUM
          FOREIGN_CURRENCY = US_WAERK
          LOCAL_AMOUNT     = 1000
          LOCAL_CURRENCY   = T001-WAERS
        IMPORTING
          EXCHANGE_RATE    = CH_KURSK
        EXCEPTIONS
          NO_RATE_FOUND    = 1
          OVERFLOW         = 2
          NO_FACTORS_FOUND = 3
          NO_SPREAD_FOUND  = 4
          DERIVED_2_TIMES  = 5.
    IF SY-SUBRC <> 0.
      CH_SUBRC = 1.
    ENDIF.
  ENDIF.

ENDFORM.