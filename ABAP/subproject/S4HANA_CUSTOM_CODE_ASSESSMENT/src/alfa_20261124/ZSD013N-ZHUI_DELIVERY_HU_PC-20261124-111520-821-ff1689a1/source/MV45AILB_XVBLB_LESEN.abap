*&---------------------------------------------------------------------*
*&      Module  XVBLB_LESEN  INPUT
*&---------------------------------------------------------------------*
*       XVBLB lesen
*----------------------------------------------------------------------*
MODULE XVBLB_LESEN INPUT.

  PERFORM XVBLB_LESEN(SAPFV45L) USING VBAK-VBELN
                                      VBAP-POSNR
                                      VBLB-ABART.

ENDMODULE.                             " XVBLB_LESEN  INPUT