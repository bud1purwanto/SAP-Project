*eject
*---------------------------------------------------------------------*
*       FORM KONTIERUNG_INIT                                          *
*---------------------------------------------------------------------*
*       Kontierungsdaten aus Blockerfassungsbild setzen               *
*---------------------------------------------------------------------*
form kontierung_init.

ENHANCEMENT-POINT KONTIERUNG_INIT_01 SPOTS ES_SAPMM07M.
  clear index_k.
  if fcausw-xaenp is initial and fcausw-xselp is initial.
    if not fcausw-xlist is initial.
      clear msegk.
      loop at ymsegk where bwart = rm07m-bwart
                     and   sobkz = rm07m-sobkz.
        index_k = sy-tabix.
      endloop.
      if not index_k is initial.
        read table ymsegk index index_k.
        if mseg-bwart = rm07m-bwart and mseg-sobkz = rm07m-sobkz and
           ymsegk-rsnum is initial.
          msegk = ymsegk.
        endif.
      else.
        msegk-bwart = rm07m-bwart.
        msegk-sobkz = rm07m-sobkz.
      endif.
      mseg-bwart = rm07m-bwart.
      mseg-sobkz = rm07m-sobkz.
      if not next_btext is initial.
        dm07m-btext = next_btext.
      endif.
      if not next_fausw is initial.
        dm07m-fausw = next_fausw.
        dm07m-kzgru = next_kzgru.
        vm07m-sobfi = next_sobfi.
        vm07m-soblo = next_soblo.
        vm07m-sobvo = next_sobvo.
        dm07m-umsof = next_umsof.
        dm07m-umsol = next_umsol.
        dm07m-umsov = next_umsov.
        mseg-umsok  = next_umsok.
        dm07m-umkzbws = next_umkzbws.
      endif.
      if not rm07m-bukrs is initial.
        msegk-parbu = rm07m-bukrs.
      endif.
    endif.
  else.
    if next_fausw is initial.
      if fcausw-xselp is initial.
        if not ydm07m-fausw is initial.
          dm07m-fausw = ydm07m-fausw.
        endif.
      else.
        dm07m-fausw = fuss-fausw.
      endif.
    endif.
    if ymsegk-parbu is initial.
      if not rm07m-bukrs is initial.
        ymsegk-parbu = rm07m-bukrs.
      else.
        read table fuss index 1.
        if sy-subrc is initial.
          ymsegk-parbu = fuss-bukrs.
        endif.
      endif.
    endif.
    if fcausw-xselp is initial.
      if not m_zeile is initial.
        msegk = ymsegk.
        msegk-bwart = rm07m-bwart.                     "note 557339
      endif.
    else.
      msegk = ymsegk.
    endif.
  endif.

endform.