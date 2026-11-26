*eject
*&---------------------------------------------------------------------*
*&      Form  PROJEKT_PRUEFEN
*&---------------------------------------------------------------------*
*  Projekt prüfen
*----------------------------------------------------------------------*
FORM projekt_pruefen.

  DATA: aufnr LIKE mseg-aufnr.
  DATA: nplnr LIKE mseg-nplnr.
  DATA: kdauf LIKE mseg-kdauf,                                   "957312
        kdpos LIKE mseg-kdpos.                                   "957312
  DATA: l_pspnr LIKE grpga-grpnr.
* IS ADEC GPD declarations
  DATA: ls_st156s TYPE st156s,
        lv_grpnr  TYPE prps-pspnr.
* The EHP604 condition variable has no effect for the core code
* conditions, it's value changes only in the switched code. This
* usage makes possible to avoid enh. sections.
  DATA: EHP604_MM07MFP0_PROJEKT_PRU_01 VALUE space,
        EHP604_MM07MFP0_PROJEKT_PRU_02 VALUE space.

  aufnr = mseg-aufnr.
  nplnr = mseg-nplnr.
  kdauf = mseg-kdauf.                                            "957312
  kdpos = mseg-kdpos.                                            "957312
  CLEAR mseg-aufnr.
  CLEAR mseg-nplnr.
  IF mseg-sobkz = q.                                             "957312
*   sales order not relevant when project stock                  "957312
    CLEAR: mseg-kdauf, mseg-kdpos.                               "957312
  ENDIF.                                                         "957312
  IF fcausw-xlist IS INITIAL.

ENHANCEMENT-POINT EHP604_MM07MFP0_PROJEKT_PRU_01 SPOTS ES_SAPMM07M. "DT071219
    IF mseg-sobkz = q OR
       EHP604_MM07MFP0_PROJEKT_PRU_01 IS NOT INITIAL.          "DT071219
      IF mseg-bukrs IS INITIAL.
        IF t001k-bwkey = vm07m-bwkey.
          mseg-bukrs = t001k-bukrs.
        ELSE.
          IF vm07m-bwkey IS INITIAL.
            SELECT SINGLE * FROM t001w WHERE werks = mseg-werks.
            IF NOT sy-subrc IS INITIAL.
              MESSAGE e001 WITH '001W' mseg-werks.
            ENDIF.
            vm07m-bwkey = t001w-bwkey.
          ENDIF.
          SELECT SINGLE * FROM t001k WHERE bwkey = vm07m-bwkey.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE e001 WITH '001K' vm07m-bwkey.
          ENDIF.
          mseg-bukrs = t001k-bukrs.
        ENDIF.
      ENDIF.
      PERFORM projektpruefung USING mseg
                                    mkpf
                                    mseg-mat_pspnr
                                    mseg-kzbws.
    ENDIF.

ENHANCEMENT-POINT EHP604_MM07MFP0_PROJEKT_PRU_02 SPOTS ES_SAPMM07M. "DT071219
    IF mseg-umsok = q OR
       EHP604_MM07MFP0_PROJEKT_PRU_02 IS NOT INITIAL.          "DT071219
      PERFORM projektpruefung USING mseg
                                    mkpf
                                    mseg-ps_psp_pnr
                                   dm07m-umkzbws.
      dm07m-setkzbws = x.
    ENDIF.

  ELSEIF fcausw-xselp IS INITIAL.
*   This coding is executed during the header accounting processing
*   (XLIST = X).
*   However, even after a "correction" here it does
*   not derive the correct KZBWS. This only happens during the
*   call to PROJEKTPRUEFUNG during item processing. Reason are
*   probably the differences in filled fields in MSEG and MKPF.
    PERFORM projektpruefung USING mseg
                                  mkpf
                                 msegk-ps_psp_pnr
                                  mseg-kzbws.
    IF mseg-bwart = '557' OR                                     "389484
       mseg-bwart = '558'.                                       "389484
*     The movement types 557 and 558 (correction of stock in transit)
*     have been created without dummy entries with KZVBR = P in order
*     to avoid beeing able to post unvaluated project stocks.
*     Set to M so that MENGENSTRING_FINDEN does not set KZVBR = P.
*     That's the only reason. The real KZBWS is determined in the
*     detail screen.
      msegk-kzbws = 'M'.                                         "389484
    ENDIF.                                                       "389484
  ENDIF.

ENHANCEMENT-POINT EHP604_MM07MFP0_PROJEKT_PRU_03 SPOTS ES_SAPMM07M.

* Check (... but not change!!) WBS-element manually entered in
* MB-transactions or transaction MIGO regarding the topic 'Grouping'.
* Based on the customizing-settings in 'Grouping' a message might be
* sent.
  DATA: BEGIN OF grint.
          INCLUDE STRUCTURE grint.
  DATA: END OF grint.
  MOVE-CORRESPONDING mseg TO grint.
  grint-ps_psp_pnr = mseg-mat_pspnr.
  CALL FUNCTION 'GRPG_MAT_MOVEM_MANUAL_INPUT'
       EXPORTING
            i_grint = grint.

ENHANCEMENT-SECTION     PROJEKT_PRUEFEN_01 SPOTS ES_SAPMM07M.

*---> Start of note 751594

* Automatic determination of grouping WBS-element with material/plant
* only if ...
  IF MSEG-KZBWS = 'M' AND
* a) project stock is valuated as 'grouping' in standard-systems is only
*    valid for valuated project stocks.
  NOT XMBWL IS INITIAL AND
* b) goods movement is posted via function MB_CREATE_GOODS_MOVEMENT
*    as the relevant/calling application has not carried out an
*    automatic determination by itself (for example the backflushing-
*    transactions or a customer-specific program calling
*    BAPI_GOODSMVT_CREATE).
  QSS_AUFRUF IS INITIAL.
* c) goods movement is not posted from QM-module (transactions QAC2 /
*    QA11 / QA12 / QA14 / QA16) as it's not possible to enter a
*    WBS-element there.

*---> End of note 751594

* Im Stornofall soll auch GRPG_FIND_GRPNR_WITH_MATNR durchlaufen
* werden, damit auch mseg-ps_psp_pnr richtig gefuellt wird
* (mseg-ps_psp_pnr ist nicht im Mat.-Beleg gespeichert).
*-- In case of transfer posting from mseg-mat_pspnr to ----------"401945
*-- mseg-ps_psp_pnr, don't change input data.          ----------"401945
    if not ( mseg-mat_pspnr <> mseg-ps_psp_pnr                   "401945
       and not mseg-mat_pspnr  is initial                        "401945
       and not mseg-ps_psp_pnr is initial )                      "401945
       and mseg-sobkz = q.                                       "1333314
*     do not replace WBS element ( with grouping ) during   "n715171
*     quantity transfer posting within inspection lot       "n715171
*     release  :                                            "n715171
*     - this kind of stock transfer has to be carried out   "n715171
*       for the WBS element of the inspection lot and not   "n715171
*       for the grouping WBS element                        "n715171
*     - criterion to detect such a case : use the update    "n715171
*       string for quantities MSEG-BUSTM = 'MQQF'           "n715171
                                                            "n715171
      if  MSEG-BUSTM  ne 'MQQF'.                            "n715171

    CALL FUNCTION 'GRPG_FIND_GRPNR_WITH_MATNR'
         EXPORTING
              i_pspnr     = mseg-ps_psp_pnr
              i_werks     = mseg-werks
              i_matnr     = mseg-matnr
         IMPORTING
              e_grpnr     = l_pspnr
         EXCEPTIONS
              wrong_input          = 1
              no_valid_grpnr_found = 2.
    IF sy-subrc = 0.
      IF NOT l_pspnr IS INITIAL.
        mseg-mat_pspnr = mseg-ps_psp_pnr = l_pspnr.
      ENDIF.
    ENDIF.
    endif.                                                       "401945

    endif.                                                  "n715171
  ENDIF.
END-ENHANCEMENT-SECTION.

  mseg-aufnr = aufnr.
  mseg-nplnr = nplnr.
  IF mseg-sobkz = q.                                             "957312
    mseg-kdauf = kdauf.                                          "957312
    mseg-kdpos = kdpos.                                          "957312
  ENDIF.                                                         "957312

ENDFORM.