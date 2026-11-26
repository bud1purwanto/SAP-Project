*----------------------------------------------------------------------*
*   INCLUDE MV45AO0T_TVSAKT_SELECT                                     *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Module  TVSAKT_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       Read Special Processing Indicator: Texts
*----------------------------------------------------------------------*
MODULE TVSAKT_SELECT OUTPUT.

  PERFORM TVSAKT_SELECT USING VBKD-SDABW
                              SPACE
                              SY-SUBRC.

ENDMODULE.                 " TVSAKT_SELECT  OUTPUT



















