*----------------------------------------------------------------------*
*   INCLUDE MV45AOSN_IVBSN_AUFBAUEN_POSI                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  IVBSN_AUFBAUEN_POSITION  OUTPUT
*&---------------------------------------------------------------------*
*       IVBSN wird aufgebaut
*----------------------------------------------------------------------*
MODULE IVBSN_AUFBAUEN_POSITION OUTPUT.

  PERFORM IVBSN_AUFBAUEN_POSITION(SAPFV45L) USING VBAP-POSNR.

ENDMODULE.                             " IVBSN_AUFBAUEN_POSITION  OUTPUT