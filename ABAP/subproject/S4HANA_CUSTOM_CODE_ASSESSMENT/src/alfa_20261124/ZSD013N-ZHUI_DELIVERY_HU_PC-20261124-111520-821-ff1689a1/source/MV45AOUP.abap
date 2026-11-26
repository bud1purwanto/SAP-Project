
************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Kundenauftragsabwicklung            *
*     Module alphabetisch geordnet; hier Tabelle VBUP.                 *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE XVBUP_UEBERSICHT_VOR                                   *
*---------------------------------------------------------------------*
*       Anzeige der Statusfelder vorbereiten                          *
*---------------------------------------------------------------------*
MODULE XVBUP_UEBERSICHT_VOR OUTPUT.

  PERFORM XVBUP_UEBERSICHT_VORBEREITEN(SAPFV45P).

ENDMODULE.
*eject