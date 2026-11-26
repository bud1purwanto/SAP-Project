*---------------------------------------------------------------------*
*       FORM FPLAN_PRUEFEN_EURO                                       *
*---------------------------------------------------------------------*
*       Prüfen ob Beleg mit Fakturierungsplan auf EURO umgestellt     *
*       werden darf.                                                  *
*---------------------------------------------------------------------*
form fplan_pruefen_euro changing ch_euro_active.

  check ch_euro_active eq chary.

* Check billing plan dates

endform.