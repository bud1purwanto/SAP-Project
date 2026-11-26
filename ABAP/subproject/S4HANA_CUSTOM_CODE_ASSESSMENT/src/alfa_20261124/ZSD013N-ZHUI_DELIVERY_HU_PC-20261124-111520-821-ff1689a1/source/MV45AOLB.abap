***********************************************************************
*  Unterroutinen RV-Auftragsabwicklung                                *
*
*  PBO-Module für Lieferabrufe                                        *
*                                                                     *
***********************************************************************

*---------------------------------------------------------------------*
*       MODULE VBLB_BEARBEITEN_VOR(bereiten)                          *
*---------------------------------------------------------------------*
*       Bearbeiten des Abrufs     vorbereiten                         *
*---------------------------------------------------------------------*
MODULE VBLB_BEARBEITEN_VOR OUTPUT.

  PERFORM XVBLB_LESEN(SAPFV45L) USING VBAK-VBELN
                                      VBAP-POSNR
                                      VBLB-ABART.

  PERFORM VBLB_BEARBEITEN_VORBEREITEN(SAPFV45L).

ENDMODULE.
*eject