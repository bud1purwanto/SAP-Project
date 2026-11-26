FUNCTION Z_MMUR_ROUND_FOR_FRACT5.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VALUE) DEFAULT 1
*"     VALUE(I_DECIMALS) LIKE  CABN-ANZDZ DEFAULT 3
*"  EXPORTING
*"     VALUE(O_NOMINATOR)
*"     VALUE(O_DENOMINATOR)
*"     VALUE(O_VALUE)
*"     VALUE(O_VALUE_CHANGED)
*"  EXCEPTIONS
*"      INPUT_INVALID
*"      OUTPUT_INVALID
*"      OVERFLOW
*"----------------------------------------------------------------------
* Local Data
 DATA: L_RESULT(2),
       L_UMREZ_F TYPE F,
       L_UMREN_F TYPE F,
       L_CHAR_F  TYPE F,
       L_ROUND_F TYPE F,
       L_OLD_FRACTION_F TYPE F,
       L_NEW_FRACTION_F TYPE F,
       L_ROUND_DECIMALS TYPE I,
       L_UMREZ LIKE MARM-UMREZ,
       L_UMREN LIKE MARM-UMREN,
       T,                         "Datentyp des aktuellen Feldes
       T_OUT.                     "Datentyp des Feldes Output

* Prüfen, ob INPUT eine Zahl ist.
  DESCRIBE FIELD I_VALUE TYPE T.
  IF T NE 'F' AND T NE 'P' AND T NE 'I'.
    MESSAGE E102(MM) WITH 'INPUT' RAISING INPUT_INVALID.
  ELSE.
    L_CHAR_F = I_VALUE.
  ENDIF.

* Prüfen, ob OUTPUT eine Zahl ist.
  DESCRIBE FIELD O_VALUE TYPE T_OUT.       "ab 3.0d Hilfsvar. T_OUT
  IF T_OUT NE 'F' AND T_OUT NE 'P' AND T_OUT NE 'I'.
     MESSAGE E102(MM) WITH 'OUTPUT' RAISING OUTPUT_INVALID.
  ENDIF.

* Round with decreasing number of decimals until value is ok
  L_RESULT = 'NE'.
  L_ROUND_DECIMALS = I_DECIMALS.
  WHILE ( L_RESULT EQ 'NE' AND
          L_ROUND_DECIMALS GE 0 ).

*-----Round
      CALL FUNCTION 'ROUND'
           EXPORTING
                DECIMALS      = L_ROUND_DECIMALS
                INPUT         = L_CHAR_F
                SIGN          = 'X'
           IMPORTING
                OUTPUT        = L_ROUND_F
           EXCEPTIONS
                OVERFLOW      = 1.

      IF SY-SUBRC NE 0.
        RAISE OVERFLOW.
      ENDIF.

*-----Convert to five-digit nominator-denominator for Erfme-BasMe
      CALL FUNCTION 'CONVERT_TO_FRACT5'
           EXPORTING
               NOMIN               = L_ROUND_F
               DENOMIN             = 1
          IMPORTING
               NOMOUT              = L_UMREZ
               DENOMOUT            = L_UMREN
          EXCEPTIONS
               CONVERSION_OVERFLOW = 1.

      IF SY-SUBRC NE 0.
        RAISE OVERFLOW.
      ENDIF.
*-----Check whether 5 digits had been enough to describe the fraction
*-----exactly
      L_OLD_FRACTION_F = L_ROUND_F / 1.
      L_NEW_FRACTION_F = L_UMREZ  /  L_UMREN.
      PERFORM Z_FLOAT_VERGLEICH
         USING    L_OLD_FRACTION_F
                  L_NEW_FRACTION_F
         CHANGING L_RESULT.

*-----If not, do the same, but round with one digit less
      L_ROUND_DECIMALS = L_ROUND_DECIMALS - 1.
  ENDWHILE.

*-Fill Export and warn User
  PERFORM Z_FLOAT_VERGLEICH
    USING  L_ROUND_F     "Rounded Value
           L_CHAR_F      "Import Value
    CHANGING L_RESULT.
IF L_RESULT EQ 'NE'.
     O_VALUE_CHANGED = 'X'.
  ENDIF.

* Set Output values
  O_VALUE       = L_ROUND_F.
  O_NOMINATOR   = L_UMREZ.
  O_DENOMINATOR = L_UMREN.

ENDFUNCTION.
*&---------------------------------------------------------------------*
*&      Form  Z_FLOAT_VERGLEICH
*&---------------------------------------------------------------------*
* Compares two float values                                            *
*----------------------------------------------------------------------*
FORM Z_FLOAT_VERGLEICH USING     I_FLOAT_1 TYPE F
                               I_FLOAT_2 TYPE F
                     CHANGING  O_RESULT.

  DATA: SMALL_NUMBER TYPE F,
        DIFFERENCE   TYPE F.

  SMALL_NUMBER = 10 ** ( -15 ).

* Beide Werte sehr klein
  IF I_FLOAT_1 LE SMALL_NUMBER AND
     I_FLOAT_2 LE SMALL_NUMBER.
         O_RESULT = 'EQ'.
         O_RESULT = 'EQ'.
* Nur ein Wert sehr klein
  ELSEIF I_FLOAT_1 LT SMALL_NUMBER AND
         I_FLOAT_2 GE SMALL_NUMBER.
         O_RESULT = 'NE'.
  ELSEIF I_FLOAT_1 GE SMALL_NUMBER AND
         I_FLOAT_2 LT SMALL_NUMBER.
         O_RESULT = 'NE'.
* Beide Wert groß
  ELSE.
         DIFFERENCE = ABS( ( I_FLOAT_1 - I_FLOAT_2 ) / I_FLOAT_1 ).
         IF DIFFERENCE LT SMALL_NUMBER.
            O_RESULT = 'EQ'.
         ELSE.
            O_RESULT = 'NE'.
         ENDIF.

  ENDIF.
ENDFORM.                    " FLOAT_VERGLEICH