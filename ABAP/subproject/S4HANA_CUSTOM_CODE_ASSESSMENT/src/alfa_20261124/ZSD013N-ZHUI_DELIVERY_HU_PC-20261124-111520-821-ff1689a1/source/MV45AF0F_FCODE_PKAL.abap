*---------------------------------------------------------------------*
*       FORM FCODE_PKAL                                               *
*---------------------------------------------------------------------*
*       Übergang zur Positionskalkulation via Dialogbaustein          *
*---------------------------------------------------------------------*
FORM FCODE_PKAL USING US_T185F STRUCTURE T185F
                      US_T185  STRUCTURE T185
                      US_T185V STRUCTURE T185V.

  DATA: DA_UPDATE.
  DATA: DA_DUNKEL.
  DATA: DA_CHECK_VO.

* Beim Sprung auf einige Tabreiter der Positionsdaten wird die
* *vbap nicht gesetzt
  PERFORM vbap_bearbeiten_vorbereiten(sapfv45p).

* Aufruf des Dialogbausteines
  PERFORM KALKULATION_AUFRUFEN(SAPFV45P) USING DA_UPDATE
                                               DA_DUNKEL
                                               DA_CHECK_VO.
  IF R185D-DATALOSS EQ SPACE.
    R185D-DATALOSS = DA_UPDATE.
  ENDIF.

ENDFORM.