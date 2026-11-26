*eject
*---------------------------------------------------------------------*
*       FORM KONTIERUNG_SETZEN                                        *
*---------------------------------------------------------------------*
*       Kontierungsdaten aus Blockerfassungsbild merken               *
*---------------------------------------------------------------------*
form kontierung_setzen.

  if fcausw-xselp is initial.
    check not mseg-matnr is initial.
    move-corresponding msegk to mseg.
    move-corresponding msegk to vm07m.
    move-corresponding msegk to dm07m.
  else.
    t_index = mseg-zeile - m_zeile.
    read table fuss index t_index.
    if not sy-subrc is initial.
      message e001 with 'FUSS' t_index.
    endif.
    data: konto like dm07m-konto.
    data: parbu like mseg-parbu.
    konto = fuss-konto.
    parbu = fuss-parbu.
    move-corresponding msegk to fuss.
    fuss-konto = konto.
    if fuss-parbu is initial.
      fuss-parbu = parbu.
    endif.
    modify fuss index t_index.
    clear t_index.
  endif.

endform.