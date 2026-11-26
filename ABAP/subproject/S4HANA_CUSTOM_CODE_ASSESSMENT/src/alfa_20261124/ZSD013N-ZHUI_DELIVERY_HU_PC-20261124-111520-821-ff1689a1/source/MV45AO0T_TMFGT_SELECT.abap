*&---------------------------------------------------------------------*
*&      Module  TMFGT_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE TMFGT_SELECT OUTPUT.

  PERFORM TMFGT_SELECT USING VBAP-MFRGR
                             SPACE
                             SY-SUBRC.

ENDMODULE.                             " TMFGT_SELECT  OUTPUT