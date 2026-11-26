***INCLUDE FV50XF0B_LIEFERUNG_STATISTIKEN .
*---------------------------------------------------------------------*
*       FORM LIEFERUNG_STATISTIKEN_BUCHEN                             *
*---------------------------------------------------------------------*
form lieferung_statistiken_buchen.

  ranges: mcinf for tmc4-mcinf.

* Do not update statistics for subsequent deliveries in a
* transportation cross-docking process
  if likpd-spe_cd_process ne space and                      "v_n_972553
     likpd-spe_cd_process ne likp-vbeln.
    return.
  endif.                                                    "^_n_972553

  if likp-vbtyp na vbtyp_mmli.
    call function 'MCV_STATISTICS_DELIVERY'
      exporting
        likp                = likp
        trtyp               = t180-trtyp
        ylikp               = ylikp
        ylikp_updkz         = ylikp_updkz
        keine_auftragswerte = vbuk_kredit_neuaufbau
        ip_split            = v50agl-split
        ip_mult             = v50agl-mult
        no_rwe              = v50agl-no_workload            "n_705826
        no_pw               = v50agl-no_workload            "n_705826
      tables
        xlikp               = xlikp
        xvbuk               = xvbuk
        xvbpa               = xvbpa
        yvbuk               = yvbuk
        yvbpa               = yvbpa
        xlips               = xlips
        xvbup               = xvbup
        xvbfa               = xvbfa
        ylikp_t             = ylikp
        ylips               = ylips
        yvbup               = yvbup
        yvbfa               = yvbfa
        xvbak               = cvbak
        xvbap               = xvbap
        xvbep               = xvbep
        xvbkd               = cvbkd
        mcinf               = mcinf.

    if v50agl-split is initial.                             "n_627746
*     Evtl. Lieferung(en) zur Bestellung,
*     dann auch Einkaufsinfosystem aufrufen
      loop at xlikp.
*       evtl. Lieferart nachlesen
        if xlikp-lfart ne tvlk-lfart.
          select single * from tvlk where lfart = xlikp-lfart.
        endif.
*       Lieferung zu Bestellung?
        if tvlk-aufer = charb.
*         ja
          perform bestellung_ekbe_fuellen(sapmv50a).
        endif.                           "Lieferung zu Bestellung?
      endloop.
    endif.                                                  "n_627746
  endif.

endform.                    "LIEFERUNG_STATISTIKEN_BUCHEN