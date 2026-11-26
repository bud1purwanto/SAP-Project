*&---------------------------------------------------------------------*
*&      Module  TVGRPT_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       Text des Gruppenreferenzschemas lesen
*----------------------------------------------------------------------*
MODULE TVGRPT_SELECT OUTPUT.

  PERFORM TVGRPT_SELECT USING VBAK-SCHEME_GRP
                              SPACE
                              SY-SUBRC.

ENDMODULE.                             " TVGRPT_SELECT  OUTPUT