*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_UEBERNEHMEN_02                                *
*---------------------------------------------------------------------*
*       Weitere Daten werden übernommen. Dieser Part wurde ausge-     *
*       lagert, damit auch bei WE zur Umlagerbestellung über LMBWL    *
*       diese Routine laufen kann.                                    *
*---------------------------------------------------------------------*
  FORM BESTELLUNG_UEBERNEHMEN_02.
    IF MSEG-ERFMG < 0.
      MSEG-ERFMG = 0.
      MSEG-BPMNG = 0.
    ENDIF.
    CHECK MSEG-ERFMG > 0 OR MSEG-LFBNR IS INITIAL.
    IF MSEG-BPMNG = 0 AND NOT MSEG-ERFMG = 0
       AND NOT MSEG-BPRME IS INITIAL.
      CALL FUNCTION 'MB_UNIT_CONVERSION'
           EXPORTING
                MEINS                = MSEG-BPRME
                ERFME                = MSEG-ERFME
                MENGE                = MSEG-BPMNG
                ERFMG                = MSEG-ERFMG
                UMREZ                = DM07M-BPUMZ
                UMREN                = DM07M-BPUMN
           IMPORTING
                O_MENGE              = MSEG-BPMNG
                O_ERFMG              = MSEG-ERFMG
                O_UMREZ              = DM07M-BPUMZ
                O_UMREN              = DM07M-BPUMN
           EXCEPTIONS
                CONVERSION_NOT_FOUND = 4.
      IF NOT SY-SUBRC IS INITIAL.
        MESSAGE E026 WITH MSEG-BPRME MSEG-ERFME.
      ENDIF.
    ENDIF.
  ENDFORM.