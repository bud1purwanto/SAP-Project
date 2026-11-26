*eject
*---------------------------------------------------------------------*
*       FORM KONTIERUNG_MERKEN                                        *
*---------------------------------------------------------------------*
*       Kontierungsdaten aus Blockerfassungsbild prüfen und merken.   *
*---------------------------------------------------------------------*
form kontierung_merken.

  old_fausw = dm07m-fausw.
  old_btext = dm07m-btext.
  old_kzgru = dm07m-kzgru.
  old_sobfi = vm07m-sobfi.
  old_soblo = vm07m-soblo.
  old_sobvo = vm07m-sobvo.
  old_umsof = dm07m-umsof.
  old_umsol = dm07m-umsol.
  old_umsov = dm07m-umsov.
  old_umsok = mseg-umsok.
  old_sobkz = mseg-sobkz.
  old_umkzbws = dm07m-umkzbws.
  check not fcausw-xneup is initial.
  if t158-kzbew = b and am07m-lifnr is initial.
    am07m-lifnr = msegk-lifnr.
  endif.
  clear ymsegk.
  clear index_k.
  loop at ymsegk where bwart = rm07m-bwart
                 and   sobkz = rm07m-sobkz.
    index_k = sy-tabix.
  endloop.
  if index_k is initial.
    ymsegk = msegk.
    if mseg-bwart ne rm07m-bwart.
      clear ymsegk-konto.
    endif.
    append ymsegk.
  else.
    if not fcausw-xneup is initial.
      read table ymsegk index index_k.
      ymsegk = msegk.
      modify ymsegk index index_k.
      next_fausw = dm07m-fausw.
      next_btext = dm07m-btext.
      next_kzgru = dm07m-kzgru.
      next_sobfi = vm07m-sobfi.
      next_soblo = vm07m-soblo.
      next_sobvo = vm07m-sobvo.
      next_umsof = dm07m-umsof.
      next_umsol = dm07m-umsol.
      next_umsov = dm07m-umsov.
      next_umsok = mseg-umsok.
      next_umkzbws = dm07m-umkzbws.
    endif.
  endif.

endform.