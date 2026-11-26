*eject
*---------------------------------------------------------------------*
*       MODULE XVBAP_LESEN                                            *
*---------------------------------------------------------------------*
*       Tabelle XVBAP fuer Bildschirmanzeige lesen, es wird die erste *
*       Einteilung mit Wunschmenge zur Verfügung gestellt             *
*---------------------------------------------------------------------*
module xvbap_lesen output.

  perform xvbap_lesen(sapfv45p) using char1.

  perform item_exit_from_loop(sapfv45p).

ENHANCEMENT-POINT XVBAP_LESEN_01 SPOTS ES_SAPMV45A.
endmodule.                    "XVBAP_LESEN OUTPUT