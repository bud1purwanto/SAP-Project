*eject
*---------------------------------------------------------------------*
*       FORM KONTIERUNGSBLOCK_SEND_PAI                                *
*---------------------------------------------------------------------*
*       Zum Zeitpunkt PAI können Felder des Hauptdynpros gefüllt      *
*       werden, die Teil der Struktur COBL sind. Die Inhalte der      *
*       Felder werden in den Kontierungsblock übernommen.             *
*---------------------------------------------------------------------*
form kontierungsblock_send_pai.
  check aktyp = h or aktyp = k.
  if fcausw-xlist is initial.
    cobl-hkont = dm07m-konto.
    move-corresponding mseg to cobl.
    if not mseg-matbf is initial.                           "note305972
      cobl-matnr = mseg-matbf.                              "note305972
    endif.                                                  "note305972
*   Note 365071 makes an attempt to improve the situation.
*   Cannot be implemented in this support package. See internal memo.
    cobl-gsber = mseg-pargb.
    if cobl-gsber is initial.
      cobl-gsber = mseg-gsber.
    endif.
*PartnerBA should be set with values of material master.    "HW 201778
*Because these are the partners for CO.                     "HW 201778
    cobl-pargb = mseg-gsber.                                "HW 201778

    cobl-prctr = mseg-pprctr.
    if cobl-prctr is initial.
      cobl-prctr = mseg-prctr.
    endif.
* PartnerPC should be set with values of material master.   "HW 201778
* Because these are the partners for CO.                    "HW 201778
    cobl-pprctr = mseg-prctr.                               "HW 201778

    cobl-bukrs = mseg-parbu.
*Clear Field SPART if it is a transfer postings - See note 309486
    if not dm07m-kzuml is initial and
       mseg-matnr <> mseg-ummat and
       not mseg-ummat is initial.
          clear vm07m-spart.
    endif.
    cobl-spart = vm07m-spart.
    cobl-hkmat = vm07m-hkmat.
    cobl-hrkft = vm07m-hrkft.
    cobl-bwkey = vm07m-bwkey.                             "526089
    if not mseg-anln1 is initial.
      cobl-koart = a.
    endif.
  else.
    check aktyp = h.
    cobl-hkont = msegk-konto.
*Keep a copy of the Partner Profit Center and Partner BA before
*they are overwritten with the values from MSEGK.
    pprctr_save = cobl-pprctr.                            "HW 201778
    pargb_save  = cobl-pargb.                             "HW 201778
    move-corresponding msegk to cobl.
    cobl-bukrs = msegk-parbu.
    cobl-gsber = msegk-pargb.
    cobl-prctr = msegk-pprctr.
    cobl-pprctr = pprctr_save.                            "HW 201778
    cobl-pargb = pargb_save.                              "HW 201778
    cobl-shkzg = mseg-shkzg.
    if not msegk-anln1 is initial.
      cobl-koart = a.
    endif.
  endif.
* COBL-BZDAT = MKPF-BUDAT.                 "Variante im FI-AA seit 4.0A
  cobl-xblnr = mkpf-xblnr.
  cobl-gjahr = mseg-gjahr.
  cobl-monat = vm07m-monat.
* transfer consumption postings between two companies should be  "964452
* possible                                                       "964452
  IF not dm07m-kzuml is initial or                               "964452
     ( dm07m-umkzvbr = 'V' or dm07m-umkzvbr = 'A' ).             "964452
  cobl-monat = dm07m-ummon.                  "note 311047
  cobl-gjahr = dm07m-umgja.                  "note 311047
  ENDIF.                                     "note 311047
  If not dm07m-kzuml is initial and          "note 1539165
     not mseg-umwrk is initial.              "note 1539165
     cobl-werks = mseg-umwrk.                "note 1539165
  endif.                                     "note 1539165
  if dm07m-fausw+11(1) = minus.
    clear: cobl-ps_psp_pnr.
* Feldauswahl ausgeschaltet und KDAUF bezieht sich nicht auf
* Umlagerzeile, dann Projekt zurücksetzten
    if mseg-umsok is initial.
      clear mseg-ps_psp_pnr.
    endif.
  elseif mseg-sobkz = q and not vm07m-xstor = zwei.
    cobl-ps_psp_pnr = mseg-mat_pspnr.
  endif.
  if dm07m-fausw+12(1) = minus.
    clear: cobl-kdauf, cobl-kdpos, cobl-kdein.
* Feldauswahl ausgeschaltet und KDAUF bezieht sich nicht auf
* Umlagerzeile, dann Kundenauftrag zurücksetzten
    if mseg-umsok is initial.
      clear: mseg-kdauf, mseg-kdpos.
    endif.
  elseif mseg-sobkz = e and not vm07m-xstor = zwei.
    cobl-kdauf = mseg-mat_kdauf.
    cobl-kdpos = mseg-mat_kdpos.
  endif.
  if dm07m-fausw+32(1) = minus.
    clear cobl-gsber.
  endif.
  if dm07m-fausw+41(1) = minus and
*For subcontracting, the logic of profit center field is explained in note 985618.
     not vm07m-pstyp = 3.            " Note 1402794
    clear cobl-prctr.
  endif.
  if t158-kzbew = f.
    clear: cobl-aufnr.
  endif.
  clear cobl-kokrs.
* CHECK NOT COBL-HKONT IS INITIAL OR NOT COBL-KDAUF IS INITIAL
*                                 OR NOT COBL-ANLN1 IS INITIAL
*                                 OR NOT COBL-PS_PSP_PNR IS INITIAL
*                                 OR NOT COBL-AUFNR IS INITIAL.
* IF NOT FCAUSW-XLIST IS INITIAL.
  check fcausw-xselp is initial.
* ENDIF.
  if not cobl-aufpl is initial.
    call function 'CO_SF_AFVG_CHECK_WITH_KEY'
         exporting
              aplzl     = cobl-aplzl
              aufpl     = cobl-aufpl
         importing
              vornr     = cobl-vornr
         exceptions
              not_exist = 01.
  endif.
  data: loc_check.                                          "note136523
  if fcausw-xlist is initial.                               "note136523
    loc_check = x.                                          "note136523
  endif.                                                    "note136523
  check xower is initial.
  call function 'COBL_SEND_PAI_ALL'
       exporting
            cobl_pai     = cobl
*           CHECK_ALWAYS = X.                               "note136523
            check_always = loc_check.                       "note136523

endform.