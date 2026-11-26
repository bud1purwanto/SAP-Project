*eject
*---------------------------------------------------------------------*
*       FORM KOPFZEILE_MERKEN                                         *
*---------------------------------------------------------------------*
*       Retten der Kopfpositionen bei Stücklisten (für Mengen-        *
*       korrelation bei Leergut,...) und bei Sammelartikel; beide     *
*       Kopfzeilen müssen getrennt gehalten werden, da Varianten eines*
*       Sammelartikels Leergut beinhalten können                      *
*---------------------------------------------------------------------*
form kopfzeile_merken using i_lfbnr like mseg-lfbnr
                            i_ebeln like mseg-ebeln
                            i_ebelp like mseg-ebelp
                            i_zeile like mseg-zeile
                            i_yzeile like mseg-zeile.

  if dm07m-upvor = uptyp_var.
* ersetzen durch: if vm07m-attyp = attyp-sam
    SAMMAT-LFBNR = I_LFBNR.
    sammat-ebeln = i_ebeln.
    sammat-ebelp = i_ebelp.
    sammat-zeile = i_zeile.
  else.
    sl_kopf-lfbnr = i_lfbnr.
    sl_kopf-ebeln = i_ebeln.
    sl_kopf-ebelp = i_ebelp.
    sl_kopf-zeile = i_zeile.
    sl_kopf-yzeile = i_yzeile.
  endif.

endform.