*---------------------------------------------------------------------*
*       FORM FCODE_ABBA                                               *
*---------------------------------------------------------------------*
*       Bei Abbrechen wird die Verarbeitung verlassen und der         *
*       Beleg initialisiert.                                          *
*---------------------------------------------------------------------*
FORM FCODE_ABBA.

* APO-Deltasätze löschen
  CALL FUNCTION 'EXTERNAL_DELTA_REMOVE'
       EXCEPTIONS
            OTHERS  = 1.
  LEAVE.
  PERFORM BELEG_INITIALISIEREN.

ENDFORM.