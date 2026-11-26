*&---------------------------------------------------------------------*
*&      Module  TVKGGT_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TVKGGT_SELECT OUTPUT.

  PERFORM TVKGGT_SELECT USING VBKD-KDKG1  VBKD-KDKG2
                              VBKD-KDKG3  VBKD-KDKG4
                              VBKD-KDKG5
                              SY-SUBRC.

ENDMODULE.                             " TVKGGT_SELECT  OUTPUT