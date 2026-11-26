*&---------------------------------------------------------------------*
*&      Form  TAXI_FILTER_AND_CONVERT_FCODE
*&---------------------------------------------------------------------*
*       Prüfen und ggf. Umsetzen des eingegangenen FCodes.
*       Wird im PAI jedes Trägerdynpros aufgerufen.
*
*       Funktion:
*       Falls eingegangener Funktionscode Tabstrip-Funktionscode,
*       Umsetzung in echten Funktionscode
*----------------------------------------------------------------------*
FORM TAXI_FILTER_AND_CONVERT_FCODE.

DATA: TAXI_FCODE_FLAG LIKE TAXI_PARAMS-FLAG.

* Check, ob Funktionscode von Tabstrip-Reiter stammt
  CALL FUNCTION 'TAXI_FILTER_FCODE'
       EXPORTING
            FCODE         = FCODE
       IMPORTING
            IS_TAXI_FCODE = TAXI_FCODE_FLAG
       EXCEPTIONS
            OTHERS        = 0.

* Eingangener Funktionscode stammt von Tabstrip:
*     Reiterfunktionscode in echten Funktionscode umsetzen
  IF TAXI_FCODE_FLAG = 'X'.

    CALL FUNCTION 'TAXI_CONVERT_FCODE'
         EXPORTING
              FCODE_IN        = FCODE
         IMPORTING
              FCODE_OUT       = FCODE
         EXCEPTIONS
              FCODE_NOT_FOUND = 1
              OTHERS          = 2.
  ENDIF.

ENDFORM.                               " TAXI_FILTER_AND_CONVERT_FCODE