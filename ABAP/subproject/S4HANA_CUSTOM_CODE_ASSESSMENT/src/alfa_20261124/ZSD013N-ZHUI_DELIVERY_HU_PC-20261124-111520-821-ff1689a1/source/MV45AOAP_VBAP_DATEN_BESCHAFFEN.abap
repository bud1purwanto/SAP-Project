*----------------------------------------------------------------------*
*       Module  VBAP_DATEN_BESCHAFFEN  OUTPUT
*----------------------------------------------------------------------*
*       Positionsdatenbeschaffung zur Anzeige auf dem Pos.subscreen
*----------------------------------------------------------------------*
MODULE VBAP_DATEN_BESCHAFFEN OUTPUT.

PERFORM VBAP_BEARBEITEN_VORBEREITEN(SAPFV45P).
IF VBKD-POSNR IS INITIAL.
  PERFORM XVBKD_LESEN_DIREKT(SAPFV45K) USING VBKD-POSNR
                                             SVBKD-TABIX.
ENDIF.

ENDMODULE.                 " VBAP_DATEN_BESCHAFFEN  OUTPUT