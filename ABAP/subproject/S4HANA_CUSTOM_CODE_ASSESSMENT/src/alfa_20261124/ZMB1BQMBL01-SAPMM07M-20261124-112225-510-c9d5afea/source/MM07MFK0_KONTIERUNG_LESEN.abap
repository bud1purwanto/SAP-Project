*eject
*---------------------------------------------------------------------*
*       FORM KONTIERUNG_LESEN                                         *
*---------------------------------------------------------------------*
*       Kontierungsdaten aus Blockerfassungsbild werden gelesen.      *
*---------------------------------------------------------------------*
form kontierung_lesen using k-parbu like  mseg-bukrs
                            k-parwk like dm07m-parwk
                            k-ktopl like dm07m-ktopl
                            k-periv like dm07m-periv
                            k-waers like  mseg-waers
                            k-budat like  mkpf-budat
                            k-gjahr like  mseg-gjahr
                            k-monat like vm07m-monat
                            k-konto like dm07m-konto
                            k-anln1 like  mseg-anln1.

  check t158-trtyp = h and not aktyp = a and mseg-weunb is initial.
  check not fcausw-xneup is initial or fcausw-xlist is initial
        or not fcausw-xselp is initial.
  check not k-parbu is initial.
  data frpe1 like t001b-frpe1.
  DATA: bwmod LIKE dm07m-bwmod,
        bklas LIKE dm07m-bklas,                                  "789672
        eklas LIKE dm07m-eklas,                                  "981671
        qklas LIKE dm07m-qklas.                                  "981671
  bwmod = dm07m-bwmod.
  bklas = dm07m-bklas.                                           "789672
  if k-parwk is initial.
    perform buchungskreis_pruefen(sapfm07m) using k-parbu
                                                  k-ktopl
                                                  k-periv
                                                  k-waers
                                                  k-budat
                                                  k-gjahr
                                                  k-monat.
*   bwmod = dm07m-bwmod.
  elseif k-parwk <> mseg-werks and mseg-kzbew = f.
    bwmod = dm07m-parbw.
* --------------------------------- Begin notes 789672 > 862723 > 981671
* Determine valuation class from proper plant
* Consider also split valuation / valuated special stock
    IF tcurm-bwkrs_cus = 1.
      CLEAR bklas.
      SELECT SINGLE bklas eklas qklas
        INTO (bklas, eklas, qklas)
        FROM mbew
        WHERE matnr = mseg-matnr AND bwkey = k-parwk
          AND bwtar = mseg-bwtar.
      IF NOT sy-subrc IS INITIAL.
        SELECT SINGLE bklas eklas qklas
          INTO (bklas, eklas, qklas)
          FROM mbew
          WHERE matnr = mseg-matnr AND bwkey = k-parwk.
      ENDIF.
      IF mseg-sobkz = e AND mseg-kzbws = m AND NOT eklas IS INITIAL.
        bklas = eklas.
      ELSEIF mseg-sobkz = t AND mseg-kzbws = m AND NOT eklas IS INITIAL. "SIT
        bklas = eklas.
      ELSEIF mseg-sobkz = q AND mseg-kzbws = m
         AND NOT qklas IS INITIAL.
        bklas = qklas.
      ENDIF.
    ENDIF.
* ---------------------------------- End notes "789672 > 862723 > 981671
  ENDIF.
  if mseg-kzbew = f and not dm07m-bwtty is initial.
    check not mseg-bwtar is initial and not dm07m-bklas is initial.
  endif.
  if k-konto is initial.
    if fcausw-xlist is initial or t158-kzbew = f.
      perform konto_pruefen(sapfm07m) using mseg-matnr
                                            mseg-shkzg
                                               k-parbu
                                               k-konto
                                               k-ktopl
                                               k-gjahr
                                               k-monat
                                                 bwmod
                                                 bklas           "789672
                                            mseg-bwart
                                            mseg-wertu
                                            mseg-mengu
                                            mseg-sobkz
                                            mseg-kzbew
                                            mseg-kzzug
                                            mseg-kzvbr
                                            mseg-bustw
                                               k-waers
                                            mseg-kzbws.
    endif.
  else.
    data: lesen.
DATA: local-rblvs LIKE mseg-bwart.                              "n710763
 MOVE ydm07m-rblvs TO local-rblvs.                              "n710763
  IF ymseg-bwart = local-rblvs AND ymseg-bwart <> mseg-bwart    "n710763
*  AND ydm07m-rblvs <> mseg-bwart.                              "n710763
   AND local-rblvs <> mseg-bwart.                               "n979556
   CLEAR: ydm07m-konto, ymsegk-konto.                           "n710763
  ENDIF.                                                        "n710763

    IF fcausw-xlist IS INITIAL OR
    ( not mseg-kzbew IS INITIAL or not im_process is initial ).
*     IF NOT XMBWL IS INITIAL.         " PPF
*       READ TABLE YDM07M WITH KEY ZEILD = DM07M-ZEILD.         " PPF
*     ENDIF.                           " PPF
      if not k-konto = ydm07m-konto.
        lesen = x.
      endif.
    else.
      read table ymsegk index 1.
      if not k-konto = ymsegk-konto.
        lesen = x.
      endif.
    endif.
    check lesen = x.
    IF mseg-kzbew IS INITIAL AND im_process is initial
    AND mseg-rsnum IS INITIAL.
      perform konto_lesen(sapfm07m) using k-ktopl
                                          k-parbu
                                          k-konto
                                          k-waers
                                            actvt01.
    else.
      perform konto_lesen(sapfm07m) using k-ktopl
                                          k-parbu
                                          k-konto
                                          k-waers
                                            space.
    endif.
    if ( not skb1-mitkz is initial or ( not skb1-xintb is initial and
       mseg-rsnum is initial and not vm07m-xstor = zwei and
       not vm07m-xstor eq 1 and
       inventur is initial ) ) and k-anln1 is initial.
      message e059 with k-konto.
    endif.
    frpe1 = k-monat.
    call function 'FI_PERIOD_CHECK'
         exporting
              i_bukrs = k-parbu
              i_koart = s
              i_konto = k-konto
              i_gjahr = k-gjahr
              i_monat = frpe1.
    CHECK mseg-kzbew IS INITIAL and im_process is initial.
    tbsl-faus1 = dm07m-fausw.
    tbsl-faus2(38) = dm07m-fausw+90.
    data: faus1 like tbsl-faus1.
    data: faus2 like tbsl-faus2.
    perform feldauswahl(sapfm07m) using faus1 faus2.
    dm07m-fausw(50) = faus1.
    dm07m-fausw+90(38) = faus2.
  endif.

ENDFORM.                    "kontierung_lesen