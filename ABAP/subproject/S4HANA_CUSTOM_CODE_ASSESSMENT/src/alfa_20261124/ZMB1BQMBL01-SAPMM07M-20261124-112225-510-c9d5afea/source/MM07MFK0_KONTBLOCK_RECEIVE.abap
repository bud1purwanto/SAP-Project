*eject
*---------------------------------------------------------------------*
*       FORM KONTBLOCK_RECEIVE                                        *
*---------------------------------------------------------------------*
*       Rückgabe des Kontierungsblocks zum Hauptdynpro                *
*       Hier muß sichergestellt werden, daß keine wichtigen           *
*       MM-Daten überschrieben werden. Deshalb werden diese           *
*       'sensiblen Daten' in COBL_MB gesichert.                       *
*---------------------------------------------------------------------*
form kontblock_receive.

  check aktyp = h or aktyp = k.
  data: gsber like mseg-gsber,
        prctr like mseg-prctr,
        kdauf like mseg-kdauf,
        kdpos like mseg-kdpos,
        pspnr like mseg-ps_psp_pnr,
        kzbws like mseg-kzbws.
  data: cancelled like dkacb-xfeld.
  clear: cobl,
         cobl_mb.
  call function 'COBL_RECEIVE'
       importing
            ecobl    = cobl
            esc_used = cancelled
       tables
            icoblf   = int_coblf.
* In case cost center will be changed in MBSL, this should be    "783338
* taken over also for the following pages                        "783338
if sy-tcode = 'MBSL' and cobl-kostl ne space.                    "783338
 if cobl-kostl <> mseg-kostl.                                    "783338
    mseg-kostl = cobl-kostl.                                     "783338
  Loop at fuss.                                                  "783338
   fuss-kostl = cobl-kostl.                                      "783338
   modify fuss.                                                  "783338
  endloop.                                                       "783338
 endif.                                                          "783338
endif.                                                           "783338
  if not sy-binpt is initial and
     not cancelled is initial.
    message a225(ki).
  endif.
* CHECK NOT COBL-HKONT IS INITIAL OR NOT COBL-KDAUF IS INITIAL
*                                 OR NOT COBL-ANLN1 IS INITIAL
*                                 OR NOT COBL-PS_PSP_PNR IS INITIAL
*                                 OR NOT FCAUSW-XLIST IS INITIAL
*                                 OR ( MSEG-WERTU IS INITIAL
*                                      AND FCAUSW-XLIST IS INITIAL ) .
  if cobl-vbtyp = w and not cobl-kdauf is initial and aktyp = h.
    if not dm07m-xstbw is initial
     and mseg-shkzg = s
     and not vm07m-xpbed is initial.
      perform naco_ermitteln_v4(sapfm07m) using 'M7' '132'
                           cobl-kdauf cobl-kdpos space space.
    endif.
  endif.
  if cobl-autyp = sa_autyp and t158-vgart ne vgart_ws.
    message e162 with cobl-aufnr.
  endif.
  if fcausw-xlist is initial or not mseg-kzbew is initial.
    gsber = mseg-gsber.
    prctr = mseg-prctr.
    if mseg-sobkz = e or mseg-umsok = e.
      kdauf = mseg-kdauf.
      kdpos = mseg-kdpos.
    endif.
    if mseg-sobkz = t or mseg-umsok = t.                       "SIT
      kdauf = mseg-kdauf.                                      "SIT
      kdpos = mseg-kdpos.                                      "SIT
    endif.
    if mseg-sobkz = q or mseg-umsok = q.
      pspnr = mseg-ps_psp_pnr.
    endif.
    kzbws = mseg-kzbws.
    move-corresponding mseg    to cobl_mb.
    move-corresponding dm07m   to cobl_mb.
    move-corresponding vm07m   to cobl_mb.
    move-corresponding cobl    to mseg.
    move-corresponding cobl    to dm07m.
    move-corresponding cobl    to vm07m.
    move-corresponding cobl_mb to mseg.
    move-corresponding cobl_mb to dm07m.
    move-corresponding cobl_mb to vm07m.
    if not cobl-objnr_real is initial.
      vm07m-objnr = cobl-objnr_real.
    endif.
    if not dm07m-kzuml is initial and mseg-wertu is initial. "note210182
      clear mseg-kokrs.                                      "note210182
    endif.                                                   "note210182
* If no cost element in COBL, do not derive Company Code
    if cobl-hkont is initial and not cobl-kzbws is initial.  "935865
       if not cobl-bukrs = mseg-bukrs.                       "935865
         cobl-bukrs = mseg-bukrs.                            "935865
      endif.                                                 "935865
    endif.                                                   "935865
*   IF NOT MSEG-PARBU = COBL-BUKRS.
    if not mseg-parbu = cobl-bukrs and dm07m-kzuml is initial.
      mseg-parbu = cobl-bukrs.
      perform buchungskreis_pruefen(sapfm07m) using mseg-parbu
                                                   dm07m-umkpl
                                                   dm07m-umper
                                                   dm07m-umwae
                                                    mkpf-budat
                                                   dm07m-umgja
                                                   dm07m-ummon.
    endif.
    IF ( NOT fcausw-xneup IS INITIAL OR fcausw-xaenp = x )      "882441
      AND fcausw-xlist IS INITIAL                               "882441
      AND xmbwl IS INITIAL AND mseg-umwrk IS INITIAL            "882441
      AND not mseg-parbu is initial AND mseg-parbu <> mseg-bukrs. "882441
       PERFORM naco_ermitteln_v4(sapfm07m) USING 'M7' '517'     "882441
                     mseg-parbu mseg-bukrs mseg-werks space.    "882441
    ENDIF.                                                      "882441
    mseg-gsber = gsber.
    mseg-pargb = cobl-gsber.
    mseg-prctr = prctr.
    mseg-pprctr = cobl-prctr.
*   Der Kdauf wird durch Mat_kdauf im COBL überschrieben
*   Deshalb muß er hier immer zurückgesetzt werden.
*   if mseg-umsok = e or ( mseg-sobkz = e and mseg-kzvbr is initial ).
    if mseg-umsok = e or mseg-sobkz = e.
      mseg-kdauf = kdauf.
      mseg-kdpos = kdpos.
    endif.
    if mseg-umsok = t or mseg-sobkz = t.                       "SIT
      mseg-kdauf = kdauf.                                      "SIT
      mseg-kdpos = kdpos.                                      "SIT
    endif.
*   In case where there is a PSP element assigned to the sales order,
*   clear PSP field. PSP is not necessary for umsok = 'e' postings.
*   But make sure WBS element is not cleared during a Goods issue 791798
    if ( not dm07m-kzuml is initial and mseg-sobkz = e ) OR    "791798
      mseg-umsok = e.                                          "791798
      mseg-ps_psp_pnr = pspnr.                             "Note 127483
    endif.
*   if mseg-umsok = q or ( mseg-sobkz = q and mseg-kzvbr is initial ).
    if mseg-umsok = q or mseg-sobkz = q.
      mseg-ps_psp_pnr = pspnr.
    endif.
ENHANCEMENT-SECTION MM07MFK0_KONTBLOCK_RECEIVE_01 SPOTS ES_SAPMM07M .
    if not mseg-umsok = e and not mseg-umsok = q and not mseg-umsok = t. "SIT
      clear dm07m-umkzbws.
    endif.
END-ENHANCEMENT-SECTION.
    mseg-kzbws = kzbws.
    if not cobl-hkont is initial.
      dm07m-konto = cobl-hkont.
    endif.
  else.
    if msegk-sobkz = e.
      kdauf = msegk-kdauf.
      kdpos = msegk-kdpos.
    endif.
    if msegk-sobkz = t.                                        "SIT
      kdauf = msegk-kdauf.                                     "SIT
      kdpos = msegk-kdpos.                                     "SIT
    endif.
    if msegk-sobkz = q.
      pspnr = msegk-ps_psp_pnr.
    endif.
    kzbws = msegk-kzbws.
    move-corresponding msegk   to cobl_mb.
    move-corresponding cobl    to msegk.
    move-corresponding cobl_mb to msegk.
    msegk-pargb  = cobl-gsber.
    msegk-parbu  = cobl-bukrs.
    msegk-pprctr = cobl-prctr.
    if not cobl-hkont is initial.
      msegk-konto = cobl-hkont.
    endif.
    if msegk-sobkz = e.
      msegk-kdauf = kdauf.
      msegk-kdpos = kdpos.
    endif.
    if msegk-sobkz = t.                                        "SIT
      msegk-kdauf = kdauf.                                     "SIT
      msegk-kdpos = kdpos.                                     "SIT
    endif.
    if msegk-sobkz = q.
      msegk-ps_psp_pnr = pspnr.
    endif.
    msegk-kzbws = kzbws.
  endif.
*  Attention: This correction is a continuation                "n1091578
*  of note 1066863. There was a follow up error                "n1091578
*  needs to get solved with this new correction.               "n1091578
*  restore the value for BEMOT from the OLD MM                 "n1091578
*  document during cancellation. If BEMOT was                  "n1091578
*  changed in the order in the meantime, it                    "n1091578
*  differs in cancellation from the original doc               "n1091578
   IF vm07m-xstor = '2' and mseg-aufnr is not initial          "n1091578
   and fuss-bemot <> cobl-bemot.                               "n1091578
      mseg-bemot = fuss-bemot.                                 "n1091578
   ENDIF.                                                      "n1091578
   perform qm_kontierung.

endform.