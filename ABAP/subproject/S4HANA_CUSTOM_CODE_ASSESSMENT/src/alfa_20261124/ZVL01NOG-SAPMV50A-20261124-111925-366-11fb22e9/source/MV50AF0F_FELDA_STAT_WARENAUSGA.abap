***INCLUDE MV50AF0F_FELDA_STAT_WARENAUSGA .
*---------------------------------------------------------------------*
*       FORM FELDAUSWAHL_STAT_WARENAUSGANG                            *
*---------------------------------------------------------------------*
*       In Abhängigkeit vom bereits erfolgten Warenausgang            *
*       einer Lieferung wird die Änderbarkeit der Lieferung           *
*       eingeschränkt:                                                *
*---------------------------------------------------------------------*
form feldauswahl_stat_warenausgang changing cf_exit_flag type c.

  check: screen-input = 1.

* Positionsfelder
ENHANCEMENT-SECTION     FELDAUSWAHL_STAT_WARENAUSG_01 SPOTS ES_SAPMV50A.
  if screen-name = 'LIPS-PSTYV' or
     screen-name = 'LIPS-POSNR' or
     screen-name = 'LIPS-MATNR' or
     screen-name = 'LIPS-SERNR' or
     screen-name = 'LIPS-AESKD' or
     screen-name = 'LIPS-ARKTX' or
     screen-name = 'LIPS-WERKS' or
     screen-name = 'LIPS-LGORT' or
     screen-name = 'LIPS-LGBZO' or
     screen-name = 'LIPS-CHARG' or
     screen-name = 'LIPS-LICHN' or                          "46B
     screen-name = 'LIPS-BRGEW' or
     screen-name = 'LIPS-NTGEW' or
     screen-name = 'LIPS-GEWEI' or
     screen-name = 'LIPS-VOLUM' or
     screen-name = 'LIPS-VOLEH' or
     screen-name = 'LIPSD-G_LFIMG' or
     screen-name = 'LIPS-LFIMG' or
     screen-name = 'LIPS-LGMNG' or
     screen-name = 'LIPSD-PIKMG' or
     screen-name = 'LIPS-VRKME' or
     screen-name = 'RV50A-VRKM1' or
     screen-name = 'LIPS-VRKM1' or
     screen-name = 'LIPSD-VRKMP' or
     screen-name = 'LIPS-MEINS' or
     screen-name = 'LIPS-UMVKN' or
     screen-name = 'LIPS-UMVKZ' or
     screen-name = 'LIPS-UEPOS' or
     screen-name = 'LIPS-EMPST' or
     screen-name = 'LIPS-MBDAT' or
     screen-name = 'LIPS-MBUHR' or
     screen-name = 'LIPS-EAN11' or
     screen-name = 'LIPS-KDMAT' or
*    screen-name = 'LIPS-MFRGR' or
     screen-name = 'LIPS-PCKPF' or
     screen-name = 'LIPS-UEBTO' or
     screen-name = 'LIPS-UNTTO' or
     screen-name = 'LIPS-KZTLF' or
     screen-name = 'LIPS-UEBTK' or
     screen-name = 'LIPS-GRUND' or
     screen-name = 'LIPS-HSDAT' or
     screen-name = 'LIPS-VFDAT' or
     screen-name = 'LIPS-BWTAR' or                          "46C
     screen-name = 'LIPS-BWART' or                          "46C
     screen-name = 'LIPS-KOSTL' or                          "46C
     screen-name = 'LIPS-KONTO' or                          "46C
     screen-name = 'LIPS-SOBKZ' or                          "46C
     screen-name = 'LIPS-BESTQ' or                          "46C
     screen-name = 'LIPS-INSMK' or                          "46C
     screen-name = 'LIPS-UMWRK' or                          "46C
     screen-name = 'LIPS-UMLGO' or                          "46C
     screen-name = 'LIPS-UMMAT' or                          "46C
     screen-name = 'LIPS-UMCHA' or                          "46C
     screen-name = 'LIPS-UMBAR' or                          "46C
     screen-name = 'LIPS-UMSOK' or                          "46C
     screen-name = 'LIPS-UMBSQ' or                          "46C
     screen-name = 'LIPS-FOBWA' or                          "46C
     screen-name = 'LIPS-SHKZG_UM' or                       "46C
     screen-name = 'LIPS-LIFEXPOS' or
     screen-name = 'RV50A-KDMAT_LA' or
     screen-name = 'LIPSD-DOCUBATCH_CHARG'.                 " ERP
     if likp-vbtyp = '7' and                               "v_n_1614286
        xvbup-wbsta = 'B' and
        lips-lgnum is initial and
        xvbup-kosta eq charb and
       ( screen-name = 'LIPSD-PIKMG' or
         screen-name = 'LIPSD-G_LFIMG' or
         screen-name = 'LIPS-LFIMG' ).
*       Quantity fields should be still editable after Partial GR
        screen-input = 1.
     else.                                                 "^_n_1614286
        screen-input = 0.
        cf_exit_flag = charx.
        exit.
     endif.                                                  "n_1614286
  endif.
END-ENHANCEMENT-SECTION.

* Kopffelder
ENHANCEMENT-SECTION     FEDLAUSWAHL_STAT_WARENAUSG_02 SPOTS ES_SAPMV50A.
  if screen-name = 'LIKP-LFART' or
     screen-name = 'LIKP-AUTLF' or
     screen-name = 'LIKP-TPMID' or
     screen-name = 'LIKP-KUNNR' or
     screen-name = 'LIKP-LIFSK' or
     screen-name = 'LIKP-LPRIO' or
     screen-name = 'LIKP-VSBED' or
     screen-name = 'LIKP-VSTEL' or
     screen-name = 'LIKP-LSTEL' or
     screen-name = 'LIKP-LIFEX' or
     screen-name = 'LIKP-ABLAD' or
     screen-name = 'LIKP-ROUTE' or
     screen-name = 'LIKP-BEROT' or
     screen-name = 'LIKP-KODAT' or
     screen-name = 'LIKP-KOUHR' or
     screen-name = 'LIKP-LDDAT' or
     screen-name = 'LIKP-LDUHR' or
     screen-name = 'LIKP-TDDAT' or
     screen-name = 'LIKP-TDUHR' or
     screen-name = 'LIKP-WADAT' or
     screen-name = 'LIKP-WAUHR' or
     screen-name = 'LIKP-WADAT_IST' or
     screen-name = 'LIKP-LFDAT' or
     screen-name = 'LIKP-LFUHR' or
     screen-name = 'LIKP-ANZPK' or
     screen-name = 'LIKP-BTGEW' or
     screen-name = 'LIKP-NTGEW' or
     screen-name = 'LIKP-GEWEI' or
     screen-name = 'LIKP-VOLUM' or
     screen-name = 'LIKP-VOLEH' or
     screen-name = 'LIKP-WAQUI' or
     screen-name = 'LIKP-INCO1' or
     screen-name = 'LIKP-INCO2' or
     screen-name = 'LIKP-PROLI' or
     screen-name = 'LIKP-LGTOR' or
     screen-name = 'LIKP-LGBZO' or
     screen-name = 'LIKP-AULWE' or
     screen-name = 'LIKP-XABLN' or
*    screen-name = 'LIKP-TRATY' OR
*    screen-name = 'LIKP-TRAID' OR
*    screen-name = 'LIKP-BOLNR' OR
     screen-name = 'RV50A-VERUR_LA'     or
     screen-name = 'RV50A-LFDAT_LA'     or
     screen-name = 'RV50A-LFUHR_LA'     or
     screen-name = 'RV50A-WADAT_IST_LA' or
     screen-name = 'LIKP-BLDAT'.
    screen-input = 0.
    cf_exit_flag = charx.
    exit.
  endif.
END-ENHANCEMENT-SECTION.

ENHANCEMENT-POINT EHP_FELDA_STAT_WARENAUSGA_01 SPOTS ES_SAPMV50A .

endform.