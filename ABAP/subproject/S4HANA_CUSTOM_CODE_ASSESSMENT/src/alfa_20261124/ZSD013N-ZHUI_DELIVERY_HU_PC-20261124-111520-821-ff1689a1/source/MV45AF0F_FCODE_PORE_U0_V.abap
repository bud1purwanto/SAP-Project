*---------------------------------------------------------------------*
*       FORM FCODE_PORE_U0_V                                          *
*---------------------------------------------------------------------*
*       Manueller Aufruf der Verfügbarkeitsprüfung über T185V         *
*       Retten der Bildfolge wegen Montage mit Fertigungsauftrag      *
*---------------------------------------------------------------------*
FORM FCODE_PORE_U0_V USING H185F STRUCTURE T185F
                           H185  STRUCTURE T185
                           H185V STRUCTURE T185V.

  T185  = H185.
  T185F = H185F.
  T185V = H185V.

* prüfe, ob es markierte Positionen gibt
  LOOP AT IVBAP WHERE SELKZ EQ CHARX.
    EXIT.
  ENDLOOP.

* wenn nicht, evtl. steht der Cursor auf einer gültigen Zeile
  IF SY-SUBRC > 0.
    PERFORM XVBAP_MARKIEREN(SAPFV45P).
    PERFORM XVBAP_BEREITSTELLEN(SAPFV45P) USING SY-SUBRC.
    IF SY-SUBRC > 0.
* Cursor steht auch nicht auf einer Zeile
      MESSAGE S323.
    ENDIF.
  ENDIF.

* gültige Zeile am Wickel
  IF SY-SUBRC = 0.
    PERFORM FCODE_PORE_U0.
    PERFORM XVBAP_UEBERSICHT_ANSTEUERN(SAPFV45P).
  ENDIF.

  T185F-FCODE = FCODE_ZURUECK2.
  H185  = T185.
  H185F = T185F.
  H185V = T185V.

ENDFORM.