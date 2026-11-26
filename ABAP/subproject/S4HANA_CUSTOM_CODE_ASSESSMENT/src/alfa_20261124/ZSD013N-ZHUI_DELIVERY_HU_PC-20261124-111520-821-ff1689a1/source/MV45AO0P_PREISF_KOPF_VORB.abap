*----------------------------------------------------------------------*
***INCLUDE MV45AO0P_PREISF_KOPF_VORB .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Module  PREISFINDUNG_VORBEREITEN_KOPF  OUTPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
module preisfindung_vorbereiten_kopf output.

* reset global display_mode variable which has to be redetermined
* by every new module call
  clear display_mode.

  pricing_header = charx.

  perform preisfindung_vorbereiten(sapfv45p) using 'K'.

* set global display_mode variable if not in transaction types
*   B (edit),  H (add),  V (change)
  if tkomk-trtyp na 'BHV'.
    display_mode = 'X'.
  endif.

endmodule.                 " PREISFINDUNG_VORBEREITEN_KOPF  OUTPUT