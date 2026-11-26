*eject.
*----------------------------------------------------------------------*
*       Form  Lagerort_komponenten
*----------------------------------------------------------------------*
*   Aufruf der Lagerortauswahlpopups bei WA der Komponenten zur        *
*   Lohnbearbeitung. Dieses Popup muß nur gesendet werden, wenn        *
*   die Komponenten aus dem E oder P Bestand kommen und noch kein      *
*   Lagerort sitzt.
*----------------------------------------------------------------------*
*  -->  XLGORT
*----------------------------------------------------------------------*
FORM LAGERORT_KOMPONENTEN USING XLGORT.

  CHECK XMBWL IS INITIAL.
  CHECK OMSEG-MBLNR IS INITIAL.
  CHECK NOT XLGORT IS INITIAL.
  SELECT SINGLE * FROM T063C WHERE CCODE EQ 'LGOR'.
  IF NOT SY-SUBRC IS INITIAL.
    PERFORM WRONG_INPUT(SAPFM07M) USING 'T063C' 'CCODE' 'LGOR' E.
  ELSE.
    CALL SCREEN T063C-DYNNR STARTING AT T063C-WINX1 T063C-WINY1
                            ENDING   AT T063C-WINX2 T063C-WINY2.
  ENDIF.
  IF RM07M-LGORT CA STERN.
    MESSAGE E116.
*    Die Funktion Lagerort / Charge - '*' ist hier nicht vorgesehen.
  ENDIF.
  CLEAR XLGORT.

ENDFORM.