*eject
*---------------------------------------------------------------------*
*       FORM PPS_AUFTRAG_UEBERNEHMEN                                  *
*---------------------------------------------------------------------*
*       Der Auftrag wird in die Tabelle FUSS übernommen.              *
*---------------------------------------------------------------------*
FORM pps_auftrag_uebernehmen USING pps_aufnr LIKE mseg-aufnr
                                   pps_aufps LIKE mseg-aufps
                                   pps_werks LIKE mseg-werks.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
  DATA: index_p LIKE index_l. CLEAR index_p.
  DESCRIBE TABLE fuss LINES index_p.
  IF index_p IS INITIAL.
    DESCRIBE TABLE ymseg LINES index_p.
    IF index_p IS INITIAL.
      CLEAR km07r-waers.
    ENDIF.
  ENDIF.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
  CLEAR:   fuss,
           index_l.
  REFRESH: yfuss,
           prefetch01,
           prefetch02,
           prefetch03.
  LOOP AT xfbefu WHERE NOT matnr IS initial.
    MOVE-CORRESPONDING xfbefu TO prefetch02.
    COLLECT prefetch02.
    MOVE-CORRESPONDING xfbefu TO prefetch03.
    COLLECT prefetch03.
  ENDLOOP.
  PERFORM prefetch_ausfuehren USING x
                                    space.
  LOOP AT xfbefu.
    IF NOT pps_werks IS INITIAL.
      CHECK xfbefu-werks = pps_werks.
    ENDIF.
    CLEAR: dm07m, vm07m, mseg.
    MOVE-CORRESPONDING xfbefu TO mseg.
    MOVE-CORRESPONDING xfbefu TO dm07m.
    dm07m-cuobj_refdoc = xfbefu-cuobj.                          "630576
    MOVE-CORRESPONDING xfbefu TO vm07m.
    PERFORM pps_daten_01.
    IF sy-tabix = 1.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
      PERFORM werk_pruefen(sapfm07m) USING    x
                                         xfbefu-werks
                                          vm07m-bwkey
                                          dm07m-bwmod
                                          dm07m-xeink
                                          dm07m-xbkng
                                          vm07m-xvkbw
                                           mseg-bukrs
                                          dm07m-ktopl
                                          dm07m-periv
                                           mseg-waers
                                           mkpf-budat
                                           mseg-gjahr
                                          vm07m-monat
                                           mseg-xruem
                                           mseg-xruej
                                          vm07m-lfgja
                                          vm07m-lfmon
                                          dm07m-fabkl
                                          dm07m-kzxab.
      IF km07r-waers IS INITIAL.
        km07r-waers = mseg-waers.
        km07r-ktopl = dm07m-ktopl.
        km07r-periv = dm07m-periv.
      ELSE.
        IF NOT km07r-waers = t001-waers OR NOT km07r-ktopl = t001-ktopl
           OR NOT km07r-periv = t001-periv.
          MESSAGE e516.
        ENDIF.
      ENDIF.
      IF NOT xfbefu-bwaer = mseg-waers
        AND NOT mseg-waers IS INITIAL
        AND NOT xfbefu-bwaer IS INITIAL.
        CALL FUNCTION 'FI_TYPE_OF_RATE_CHECK'
             EXPORTING
                  i_blart = mkpf-blart
                  i_kurst = t003-kurst
                  i_waers = xfbefu-bwaer
                  i_hwaer = mseg-waers.
      ENDIF.
    ENDIF.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
    CHECK xfbefu-posnr >= pps_aufps.
    IF NOT pps_werks IS INITIAL.
      IF pps_aufps NE 0 AND pps_werks NE xfbefu-werks.
        MESSAGE e034 WITH xfbefu-aufnr xfbefu-posnr xfbefu-werks.
      ENDIF.
      CHECK xfbefu-werks = pps_werks.
    ENDIF.
    PERFORM segmentdaten_t156_setzen(sapfm07m).
    PERFORM pps_daten_03.
    PERFORM pps_daten_02.
    IF rm07m-xnuvo IS INITIAL.
      CHECK NOT mseg-erfmg IS INITIAL.
    ENDIF.
    index_l = index_l + 1.
    mseg-kzbew = rm07m-kzbew.
    IF mseg-lgort IS INITIAL.
      mseg-lgort = rm07m-lgort.
    ENDIF.
    IF NOT mseg-matnr IS INITIAL.
      dm07m-xlort = x.
      dm07m-xchar = x.
      dm07m-bwtor = mseg-bwtar.
      IF dm07m-maktx IS INITIAL.
        PERFORM kurztext_lesen(sapfm07m) USING mseg-matnr.
        dm07m-maktx = mbefu-maktx.
      ENDIF.
    ENDIF.
    IF t159l-werks NE mseg-werks.
      SELECT SINGLE * FROM t159l WHERE werks = mseg-werks.
    ENDIF.
    dm07m-xwmhd = t159l-xwmhd.
    MOVE-CORRESPONDING dm07m TO fuss.
    MOVE-CORRESPONDING vm07m TO fuss.
    MOVE-CORRESPONDING mseg TO fuss.
    fuss-rewrt = xfbefu-arwrt.
    fuss-remng = xfbefu-armng.
    fuss-fcode = fcod-np.
    fuss-xselp = fcausw-xselp.
    fuss-xsels = fcausw-xselp.
    IF fcausw-xlist IS INITIAL.
      fuss-xselk = x.
      fuss-xhell = x.
    ELSE.
      IF fuss-erfmg = 0 OR
         ( NOT fuss-elikz IS INITIAL AND fuss-shkzg = s ).
        CLEAR fuss-xselk.
      ELSE.
        fuss-xselk = t158-xsele.
      ENDIF.
    ENDIF.
    PERFORM fuss_nach_yfuss.
  ENDLOOP.
  FREE xfbefu.
  PERFORM fuss_aus_yfuss.
  READ TABLE fuss INDEX 1.
  IF NOT sy-subrc IS INITIAL.
    MESSAGE e064 WITH pps_aufnr.
  ENDIF.
  IF xaktiv IS INITIAL.
    xaktiv = x.
  ENDIF.
  IF xconfirm IS INITIAL.
    IF t158-trtyp = h.
      xconfirm = x.
    ENDIF.
  ENDIF.
  IF index_l < 1.
    MESSAGE e035 WITH pps_aufnr pps_werks.
  ENDIF.
ENDFORM.