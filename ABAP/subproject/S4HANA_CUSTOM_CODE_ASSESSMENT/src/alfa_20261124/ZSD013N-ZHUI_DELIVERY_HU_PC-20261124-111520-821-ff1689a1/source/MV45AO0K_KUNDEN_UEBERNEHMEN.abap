*eject.
*&---------------------------------------------------------------------*
*&      Module  KUNDEN_UEBERNEHMEN  OUTPUT
*&---------------------------------------------------------------------*
*       Auftraggeber und Warenempfänger vom Bildschirm übernehmen
*----------------------------------------------------------------------*
MODULE KUNDEN_UEBERNEHMEN OUTPUT.

ENHANCEMENT-POINT KUNDEN_UEBERNEHMEN_10 SPOTS ES_SAPMV45A.
* Verkaufsbeleg ändern : Auftraggeber aus xvbpa lesen.
  PERFORM KUAGV_SELECT_XVBPA.
  PERFORM AG_VORSCHLAGEN.

* Verkaufsbeleg ändern : Warenempfänger aus xvbpa lesen.
  PERFORM KUWEV_SELECT_XVBPA.

* Warenempfänger merken
  IF NOT SAVE-WE = '0000000000'.
    SAVE-WE = KUWEV-KUNNR.
  ENDIF.

ENDMODULE.                 " KUNDEN_UEBERNEHMEN  OUTPUT