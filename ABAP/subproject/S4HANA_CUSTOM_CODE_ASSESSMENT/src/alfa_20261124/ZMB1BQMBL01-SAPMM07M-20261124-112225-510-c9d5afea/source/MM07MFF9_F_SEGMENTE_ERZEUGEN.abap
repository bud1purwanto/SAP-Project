*eject
*---------------------------------------------------------------------*
*       FORM F-SEGMENTE_ERZEUGEN                                      *
*---------------------------------------------------------------------*
*       Die Wertzeilen zur Buchhaltungsbelegposition werden erzeugt.  *
*---------------------------------------------------------------------*
FORM F-SEGMENTE_ERZEUGEN USING F-SHKZG LIKE MSEG-SHKZG
                               F-VORSL LIKE T156W-VORSL
                               F-KOMOK LIKE T030-KOMOK
                               F-BWMOD LIKE DM07M-BWMOD
                               F-XBNK  TYPE C
                               L_SHKZG TYPE C.                 "HW578078
  DATA bklas LIKE dm07m-bklas.                                   "862723

  DATA: f_function_active TYPE fm_function_active.              "1621998

  MOVE-CORRESPONDING XACCIT TO WRMOD.



ENHANCEMENT-SECTION     MM07MFF9_F_SEGMENTE_ERZEUGE_01 SPOTS ES_SAPMM07M.

  IF BRAZIL   = X AND F-XBNK = SPACE.
    CALL FUNCTION 'J_1B_IM_TX_ACCOUNT_ASSIGNMENT'
         EXPORTING
              I_MKPF   = MKPF
              I_MSEG   = MSEG
              I_DM07M  = DM07M
              I_VM07M  = VM07M
              I_X156W  = X156W
              I_XACCIT = XACCIT
              I_SHKZG  = F-SHKZG
              I_VORSL  = F-VORSL
              I_KOMOK  = F-KOMOK
              I_KTOPL  = BUKRS-KTOPL
              I_WRXMOD = WRMOD
         IMPORTING
              I_XACCIT = XACCIT.
  ELSE.
    bklas = dm07m-bklas.                                         "862723
*   valuation class may be different in other plant              "862723
    IF x156w-xbgbb = x AND                                       "862723
       mseg-kzbew = f AND                                        "862723
       mseg-werks NE xaccit-werks AND                            "862723
       NOT dm07m-parwk IS INITIAL AND                            "862723
       NOT xaccit-bklas IS INITIAL.                              "862723
      bklas = xaccit-bklas.                                      "862723
    ENDIF.                                                       "862723
    PERFORM KONTO_ERMITTELN(SAPFM07M) USING BUKRS-KTOPL
                                                F-VORSL
                                                F-BWMOD
                                                F-KOMOK
                                                  BKLAS          "862723
                                                F-SHKZG
                                           XACCIT-HKONT
                                           XACCIT-BSCHL
                                                  WRMOD.
  ENDIF.
  IF RC = 0 AND NOT DM07M-KONTO IS INITIAL
            AND NOT T156X-XPKON IS INITIAL
* OM in time consump.:GBB MVT 521 mustn't get PO account assign"1531770
            AND NOT ( F-VORSL        = VORSL_GBB AND           "1531770
                      DM07M-CO_ORDER = ABAP_TRUE ).            "1531770
    PERFORM JV_F_SEG_ERZEUGEN_1.

    XACCIT-HKONT = DM07M-KONTO.

    PERFORM JV_F_SEG_ERZEUGEN_2.
  ENDIF.


END-ENHANCEMENT-SECTION.



* Even if account is given manually in dm07m-konto, it is
* necessary to call mr_account_assignment to get BSCHL.
* If GBB has account blank, no exception from mr_account, so it
* is necessary to issue message here instead of unclear message from
* konto_lesen (account space not found).               "204567
  if xaccit-hkont is initial.                          "204567
    CALL FUNCTION 'MB_EDIT_MESSAGE'                    "204567
         EXPORTING T1 = bukrs-ktopl                    "204567
                   T2 = f-vorsl                        "204567
                   T3 = f-bwmod                        "204567
                   T4 = f-komok                        "204567
                   T5 = dm07m-bklas                    "204567
         IMPORTING MESSAGE = MESSAGE_TEXT.             "204567
    MESSAGE E147(m8) WITH MESSAGE_TEXT.                "204567
  endif.                                               "204567
  PERFORM KONTO_LESEN(SAPFM07M) USING BUKRS-KTOPL
                                     XACCIT-BUKRS
                                     XACCIT-HKONT
                                      BUKRS-WAERS
                                            SPACE.
  CASE SKB1-MITKZ.
    WHEN SPACE.
      IF F-VORSL = VORSL_ANL.
        MESSAGE E114 WITH XACCIT-HKONT F-VORSL.
      ENDIF.
    WHEN A.
      IF NOT F-VORSL = VORSL_ANL.
        MESSAGE E108 WITH XACCIT-HKONT F-VORSL SKB1-MITKZ.
      ENDIF.
      XACCIT-BZDAT = MKPF-BUDAT.
*       WHEN M.     " Diesen Fall gibt's voraussichtlich ab 2.1
    WHEN OTHERS.
      MESSAGE E108 WITH XACCIT-HKONT F-VORSL SKB1-MITKZ.
  ENDCASE.
  IF F-VORSL = VORSL_BSX.
    CLEAR XACCIT-KOKRS.
    IF SKB1-XINTB IS INITIAL.
      MESSAGE E109 WITH XACCIT-HKONT F-VORSL.
    ENDIF.
  ENDIF.
  XACCIT-KTOSL = F-VORSL.
  XACCIT-SHKZG = F-SHKZG.
  XACCIT-BUZID = X156W-BUZID.

* Since ECC 5.00 the new general ledger is available in FI. Functional
* area (FKBER) should be updated for profit and loss acounts
* (SKA1-XBILK = ' ') only. FKBER should NOT be updated for balance
* sheet accounts (SKA1-XBILK = 'X'). In case FKBER is active in public
* sector fill FKBER also for balance sheet accounts.
* (Similar logic in MM-IV fm MRM_INVOICE_POST)
  CLEAR: f_function_active.                                     "1621998

  IF NOT xaccit-hkont IS INITIAL AND NOT xaccit-fkber IS INITIAL "1621998
     AND ska1-xbilk = 'X'.   "balance sheet account             "1621998
*   Check whether FKBER is active in public sector              "1621998
    CALL FUNCTION 'FM_DC_GET_ACTIVE_DIMENSIONS'                 "1621998
      EXPORTING                                                 "1621998
        i_company_code    = xaccit-bukrs                        "1621998
      IMPORTING                                                 "1621998
        e_function_active = f_function_active                   "1621998
      EXCEPTIONS                                                "1621998
        error_occured       = 1                                 "1621998
        input_error         = 2                                 "1621998
        no_fm_area_assigned = 3                                 "1621998
        OTHERS              = 4.                                "1621998

    IF f_function_active = space  "FKBER is not active in public sector  "1621998
      OR sy-subrc NE 0.                                         "1621998
*     FKBER must NOT be filled for balance sheet accounts       "1621998
      CLEAR xaccit-fkber.                                       "1621998
    ENDIF.                                                      "1621998
  ENDIF.                                                        "1621998

  IF F-VORSL = VORSL_GBB OR F-VORSL = VORSL_KBS.
    YMBUZ_KEY-ZEILZ = ZMSEG-ZEILE.
    CLEAR YMBUZ_KEY-XAUTO.
    READ TABLE YMBUZ WITH KEY YMBUZ_KEY BINARY SEARCH.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'YMBUZ' YMBUZ_KEY-ZEILZ YMBUZ_KEY-XAUTO.
    ENDIF.
    YMBUZ-SAKTO = XACCIT-HKONT.
    PERFORM JV_MAINTAIN_ACCOUNT.                               "N1472370
    MODIFY YMBUZ INDEX SY-TABIX.
  ENDIF.
* Fill YFBUZ only in the right debit/credit case               "HW578078
  IF F-SHKZG = L_SHKZG.                                        "HW578078
    CLEAR YFBUZ.
    IF F-XBNK IS INITIAL.
      YFBUZ-BNBTR = MSEG-BNBTR.
      YFBUZ-AWEWR = VM07M-AWEWR.
      YFBUZ-AWEWW = VM07M-AWEWW.
      YFBUZ-LBBTR = XZCXCM-LBBTR.
    ELSE.
      YFBUZ-STUNR = XZCXCB-STUNR.
      YFBUZ-ZAEHK = XZCXCB-ZAEHK.
      YFBUZ-XAUTO = XZCXCB-XAUTO.
    ENDIF.
    YFBUZ-ZEILE = ZMSEG-ZEILE.
    YFBUZ-BUKRS = XACCIT-BUKRS.
    YFBUZ-XUMBW = X156W-XUMBW.
    YFBUZ-BUZID = X156W-BUZID.
    YFBUZ-KTOSL = X156W-VORSL.
    YFBUZ-HKONT = XACCIT-HKONT.
    YFBUZ-GSBER = XACCIT-GSBER.
    YFBUZ-PRCTR = XACCIT-PRCTR.
    YFBUZ-MONAT = BUKRS-MONAT.
  ENDIF.                                                       "HW578078
  RW_POSNR = RW_POSNR + 1.
  DATA ML10. CLEAR: ML10.
  DATA VALUE. CLEAR: VALUE.
  LOOP AT YACCCR WHERE XSUBS = SPACE.                           " 635226
    XACCCR = YACCCR.
    IF ( XACCCR-WRBTR < 0 AND XACCIT-SHKZG = S ) OR
       ( XACCCR-WRBTR > 0 AND XACCIT-SHKZG = H ).
      CLEAR: XACCCR-WRBTR, XACCCR-BUALT.
    ENDIF.
    IF NOT XACCCR-WRBTR = 0.
      VALUE = X.
    ENDIF.
    IF XACCCR-CURTP = CURTP10.
      ML10 = X.
      XACCCR-WAERS = BUKRS-WAERS.
      IF F-SHKZG = L_SHKZG.                                    "HW578078
        YFBUZ-SHKZG = XACCIT-SHKZG.
      ENDIF.                                                   "HW578078
      IF XACCIT-SHKZG = S.
        IF F-SHKZG = L_SHKZG.                                  "HW578078
          YFBUZ-DMBTR = XACCCR-WRBTR.
          YFBUZ-BUALT = XACCCR-BUALT.
        ENDIF.                                                 "HW578078
        BUKRS-SUMME_S = BUKRS-SUMME_S + XACCCR-WRBTR.
        BUKRS-SALDO   = BUKRS-SALDO   + XACCCR-WRBTR.
        RM07M-SUMME_S = RM07M-SUMME_S + XACCCR-WRBTR.
        RM07M-SALDO   = RM07M-SALDO   + XACCCR-WRBTR.
      ELSE.
        IF F-SHKZG = L_SHKZG.                                  "HW578078
          YFBUZ-DMBTR = 0 - XACCCR-WRBTR.
          YFBUZ-BUALT = 0 - XACCCR-BUALT.
        ENDIF.                                                 "HW578078
        BUKRS-SUMME_H = BUKRS-SUMME_H - XACCCR-WRBTR.
        BUKRS-SALDO   = BUKRS-SALDO   + XACCCR-WRBTR.
        RM07M-SUMME_H = RM07M-SUMME_H - XACCCR-WRBTR.
        RM07M-SALDO   = RM07M-SALDO   + XACCCR-WRBTR.
      ENDIF.
    ENDIF.
    XACCCR-AWTYP = RW_AWTYP.
    XACCCR-POSNR = RW_POSNR.
ENHANCEMENT-POINT F-SEGMENTE_ERZEUGEN_04 SPOTS ES_SAPMM07M.
    APPEND XACCCR.
  ENDLOOP.
  IF NOT SY-SUBRC IS INITIAL OR ML10 IS INITIAL.
    MESSAGE E001 WITH 'YACCCR'.
  ENDIF.
ENHANCEMENT-SECTION     F-SEGMENTE_ERZEUGEN_05 SPOTS ES_SAPMM07M.
  IF VALUE IS INITIAL.
    XACCIT-KSTAT = U.
  ELSE.
    CLEAR XACCIT-KSTAT.
  ENDIF.
END-ENHANCEMENT-SECTION.
  XACCIT-AWTYP = RW_AWTYP.
  XACCIT-POSNR = RW_POSNR.
  gs_accit_ext-awtyp = rw_awtyp.                                 "593240
  gs_accit_ext-posnr = rw_posnr.                                 "593240
  XACCIT-LOGVO = ZMSEG-ZEILE.
  XACCIT-LOGVO+4(1) = X156W-XUMBW.
  XACCIT-XMFRW = X156W-XMFRW.
  IF NOT ZMSEG-XOBEW IS INITIAL.
    XACCIT-MAT_LIFNR = ZMSEG-EMLIF.                         "kaz
  ELSE.
    CLEAR XACCIT-MAT_LIFNR.
  ENDIF.
  IF F-VORSL = VORSL_KON.
*   Zuordnungsnummer mit * (später Materialbeleg) füllen
    XACCIT-ZUONR = STERN.
    XACCIT-ZUONR+10(4) = MKPF-MJAHR.
  ENDIF.
ENHANCEMENT-POINT F-SEGMENTE_ERZEUGEN_06 SPOTS ES_SAPMM07M.
* Fill assignment number for cross system movements.
  IF NOT x156w-settlement IS INITIAL AND                         "sdp462
     'CSS CSR' CS f-komok.                                       "sdp462
    CALL METHOD cl_mmim_cross_system=>fill_zuonr_xaccit          "sdp462
      EXPORTING                                                  "sdp462
        i_line_id = zmseg-line_id                                "sdp462
      CHANGING                                                   "sdp462
        c_zuonr   = xaccit-zuonr.                                "sdp462
  ENDIF.                                                         "sdp462
  PERFORM JV_DETERMINE_RECID.
  IF ( X156W-VORSL = VORSL_GBB OR  X156W-VORSL = VORSL_KBS  )
                             AND DM07M-KSTAR IS INITIAL.

    READ TABLE ZDM07M INDEX DM07M-ZEILD.
    DM07M-KSTAR = XACCIT-HKONT.
    ZDM07M-KSTAR = DM07M-KSTAR.
    MODIFY ZDM07M INDEX DM07M-ZEILD.
  ENDIF.
  PERFORM J_1B_XACCIT USING XACCIT
                            BRAZIL
                            X156W-CNT02
                            XZCXCM-VORSL.
  APPEND XACCIT.
  APPEND gs_accit_ext TO gt_accit_ext.                           "593240
  CLEAR: gs_accit_ext.                                           "593240

ENDFORM.