*eject
*---------------------------------------------------------------------*
*       FORM RES_POSITIONEN_UEBERNEHMEN                               *
*---------------------------------------------------------------------*
*       Die gefundenen Reservierungspositionen werden übernommen.     *
*---------------------------------------------------------------------*
FORM res_positionen_uebernehmen.
  DESCRIBE TABLE fuss LINES index_z.
  DATA: BEGIN OF reskey,
          rsnum LIKE rm07m-rsnum,
          rspos LIKE rm07m-rspos,
        END OF reskey.
  DATA: nprue.
  DATA: l_rc LIKE sy-subrc.                                      "534257
  CLEAR reskey.
  reskey-rsnum = rm07m-rsnum.
  READ TABLE seltab1 WITH KEY reskey BINARY SEARCH.
  IF sy-subrc IS INITIAL.
    nprue = x.
  ENDIF.
  REFRESH yfuss.
  DATA: l_werks LIKE rm07m-werks.
  l_werks = rm07m-werks.
  bwart_res = t156n-bwart_next.
  REFRESH: prefetch01,
           prefetch02,
           prefetch03.
  LOOP AT seltab2 WHERE rsnum = seltab1-rsnum.
    IF seltab2-rspos IS INITIAL.
      LOOP AT xrbefu.
        MOVE-CORRESPONDING xrbefu TO prefetch02.
        COLLECT prefetch02.
        MOVE-CORRESPONDING xrbefu TO prefetch03.
        COLLECT prefetch03.
      ENDLOOP.
    ELSE.
      LOOP AT xrbefu WHERE rspos = seltab2-rspos.
        MOVE-CORRESPONDING xrbefu TO prefetch02.
        COLLECT prefetch02.
        MOVE-CORRESPONDING xrbefu TO prefetch03.
        COLLECT prefetch03.
      ENDLOOP.
    ENDIF.
  ENDLOOP.
  PERFORM prefetch_ausfuehren USING x
                                    space.
  LOOP AT xrbefu.
*   In case of reservation bdart 'AR' check for AFFW entries     "534257
*   same check for orders in MM07MPPS_PPS_AUFTRAG_WA_POP         "534257
    IF xord_check IS INITIAL.      "order already checked?       "534257
      IF xrbefu-bdart = 'AR'.                                    "534257
        CALL FUNCTION 'CO_FW_CHECK_AFFW_BY_RSNUM'                "534257
          EXPORTING                                              "534257
            I_RSNUM           = rm07m-rsnum                      "534257
            I_RSPOS           = xrbefu-rspos                     "534257
          EXCEPTIONS                                             "534257
            INPUT_ERROR       = 1                                "534257
            NOT_FOUND         = 2                                "534257
            OTHERS            = 3.                               "534257
*  If AFFW entry exits sy-subrc = 0                              "534257
        IF sy-subrc = 0.                                         "534257
          CALL FUNCTION 'MB_CHECK_T160M'                         "534257
            EXPORTING                                            "534257
              I_ARBGB          = 'M7'                            "534257
              i_msgnr          =  '397'                          "534257
            IMPORTING                                            "534257
              rc               = l_rc .                          "534257
          CASE l_rc.                                             "534257
            WHEN '01'.                                           "534257
              MESSAGE W397(m7) WITH rm07m-rsnum xrbefu-rspos.    "534257
            WHEN '02'.                                           "534257
              MESSAGE S397(m7) WITH rm07m-rsnum xrbefu-rspos.    "534257
              CONTINUE.                                          "534257
          ENDCASE.                                               "534257
        ENDIF.                                                   "534257
      ENDIF.                                                     "534257
    ENDIF.                                                       "534257

    IF nprue IS INITIAL.
      reskey-rspos = xrbefu-rspos.
      READ TABLE seltab1 WITH KEY reskey BINARY SEARCH.
      CHECK sy-subrc IS INITIAL.
    ENDIF.
    IF rm07m-xnuvr IS INITIAL.
      CHECK NOT xrbefu-offen IS INITIAL.
    ENDIF.
    IF NOT rm07m-xausw IS INITIAL.
*------erweiterte Selection über SOBKZ?
      IF NOT rm07m-sobkzs IS INITIAL .
        CHECK xrbefu-sobkz = rm07m-sobkzs.
      ENDIF.
      IF NOT l_werks IS INITIAL.
        CHECK xrbefu-werks = l_werks.
        IF NOT rm07m-lgors IS INITIAL .
          IF NOT xrbefu-lgort IS INITIAL.
            CHECK xrbefu-lgort = rm07m-lgors.
          ELSE.
            CHECK rm07m-lgort = rm07m-lgors.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF sy-tabix = 1.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
      PERFORM werk_pruefen(sapfm07m) USING      space
                                         xrbefu-werks
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
    ENDIF.
*-  Buchungskreisprüfung mit 2.0 rausnehmen --------------------------*
    CLEAR: mseg, dm07m, vm07m.
    IF NOT rm07m-xausw IS INITIAL AND NOT rm07m-bdter IS INITIAL.
      CASE rm07m-option_mb.
        WHEN '<>'.
          CHECK xrbefu-bdter NE rm07m-bdter.
        WHEN 'NE'.
          CHECK xrbefu-bdter NE rm07m-bdter.
        WHEN '>'.
          CHECK xrbefu-bdter GT rm07m-bdter.
        WHEN 'GT'.
          CHECK xrbefu-bdter GT rm07m-bdter.
        WHEN '>='.
          CHECK xrbefu-bdter GE rm07m-bdter.
        WHEN 'GE'.
          CHECK xrbefu-bdter GE rm07m-bdter.
        WHEN '<'.
          CHECK xrbefu-bdter LT rm07m-bdter.
        WHEN 'LT'.
          CHECK xrbefu-bdter LT rm07m-bdter.
        WHEN '<='.
          CHECK xrbefu-bdter LE rm07m-bdter.
        WHEN 'LE'.
          CHECK xrbefu-bdter LE rm07m-bdter.
        WHEN OTHERS.
          CHECK xrbefu-bdter EQ rm07m-bdter.
      ENDCASE.
    ENDIF.
    dm07m-xwmhd = t159l-xwmhd.
    PERFORM res_positionen_uebernehmen_01.
    PERFORM res_positionen_uebernehmen_02.
ENHANCEMENT-POINT RES_POSITIONEN_UEBERNEHMEN_01 SPOTS ES_SAPMM07M.
    IF mseg-sobkz IS INITIAL.
      mseg-sobkz = rm07m-sobkz.
    ENDIF.
    IF NOT rm07m-xausw IS INITIAL AND NOT rm07m-lifnr IS INITIAL.
      mseg-lifnr = rm07m-lifnr.
    ENDIF.
    IF dm07m-maktx IS INITIAL.
      PERFORM kurztext_lesen(sapfm07m) USING mseg-matnr.
      dm07m-maktx = mbefu-maktx.
    ENDIF.
    PERFORM fusszeile_bew_pruefen.
*   In case of a cancellation mseg-kzear is cleared. Otherwise
*   cancellation with reference to order/reservation would work
*   differently than document cancellation
    IF dm07m-rshkz NE mseg-shkzg AND                             "924729
       ( aktyp = H OR vgart = 'WA' ).                            "924729
      CLEAR mseg-kzear.                                          "579664
    ENDIF.                                                       "579664
    PERFORM fuss_ergaenzen.
    CLEAR fuss-xprue.
    fuss-xselp = fcausw-xselp.
    fuss-xsels = fcausw-xselp.
    IF NOT fcausw-xlist IS INITIAL.
      fuss-xselk = t158-xsele.
      IF mseg-menge IS INITIAL OR
         ( NOT xrbefu-kzear IS INITIAL AND dm07m-rshkz = mseg-shkzg ).
        CLEAR fuss-xselk.
      ENDIF.
    ENDIF.
    PERFORM fuss_nach_yfuss.
  ENDLOOP.
  PERFORM fuss_aus_yfuss.
  FREE xrbefu.
  CHECK t158-trtyp = h.
  CLEAR: rm07m-istmg,
         rm07m-wempf_vor,
         rm07m-lifnr.
  IF rm07m-solmg IS INITIAL.
    rm07m-solmg = 100000.
  ENDIF.
  DESCRIBE TABLE fuss LINES index_l.
  IF index_l = index_z.
    IF index_a <= 1 OR index_a = index_k.
*---- bei der letzten Position muß eine Fehlermeldung gesendet werden,
*---- da sonst kein kontrollierter Abbruch des PopUp's möglich ist.
      PERFORM DEQUEUE_RKPF(SAPLMBRE) USING rm07m-rsnum.          "614432
      IF NOT rm07m-aufnr IS INITIAL.
        MESSAGE e064 WITH rm07m-aufnr '/' rm07m-rsnum.
      ELSE.
        MESSAGE e064 WITH rm07m-rsnum.
      ENDIF.
    ELSE.
      IF NOT rm07m-aufnr IS INITIAL.
        MESSAGE w064 WITH rm07m-aufnr '/' rm07m-rsnum.
      ELSE.
        MESSAGE w064 WITH rm07m-rsnum.
      ENDIF.
    ENDIF.
  ENDIF.
  CLEAR: index_l, index_z.
  CLEAR rm07m-bdter.
  IF xaktiv IS INITIAL.
    xaktiv = x.
  ENDIF.
ENDFORM.