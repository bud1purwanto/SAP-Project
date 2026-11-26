*----------------------------------------------------------------------*
*   INCLUDE MV45AO0T_TVTYT_SELECT                                      *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  TVTYT_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       Read Shipping Material Types: Designations
*----------------------------------------------------------------------*
MODULE TVTYT_SELECT OUTPUT.

  PERFORM TVTYT_SELECT USING VBKD-TRATY
                             SPACE
                             SY-SUBRC.

ENDMODULE.                 " TVTYT_SELECT  OUTPUT



















