  INCLUDE MV45AO0V_VBAK-AWAHR_ERMITTELN .
  INCLUDE MV45AO0V_VBAP-PMATN_MAKT_SEL .
  INCLUDE MV45AO0V_VBAK_STATUS_LESEN .

*&---------------------------------------------------------------------*
*&      Module  VBKD-WAKTION_WAKT_SELECT  OUTPUT
*&---------------------------------------------------------------------*
*       Aktionsbezeichnung lesen
*----------------------------------------------------------------------*
MODULE VBKD-WAKTION_WAKT_SELECT OUTPUT.

  PERFORM WAKT_SELECT(SAPFV45K) USING VBKD-WAKTION
                                      SY-SUBRC.

ENDMODULE.                 " VBKD-WAKTION_WAKT_SELECT  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  VBAP_FUELLEN_TVCOM  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE VBAP_FUELLEN_TVCOM OUTPUT.

  perform vbap_fuellen_tvcom(sapfv45p).

ENDMODULE.                 " VBAP_FUELLEN_TVCOM  OUTPUT

module vbak_fuellen_tvcom output.

  perform vbak_fuellen_tvcom(sapfv45k).

endmodule.














