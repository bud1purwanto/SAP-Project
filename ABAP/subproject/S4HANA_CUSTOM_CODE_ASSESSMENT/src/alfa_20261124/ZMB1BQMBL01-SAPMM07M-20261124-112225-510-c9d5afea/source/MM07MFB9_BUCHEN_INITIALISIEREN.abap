*eject
*---------------------------------------------------------------------*
*       FORM BUCHEN_INITIALISIEREN                                    *
*---------------------------------------------------------------------*
*       Zum Buchen werden Arbeitsbereiche initialisiert.              *
*---------------------------------------------------------------------*

* refresh working tables for PO history with MAA, to        "MAA EhP4

FORM BUCHEN_INITIALISIEREN.

  DATA: BEGIN OF LBTAB OCCURS 0,
          ZEILE LIKE MSEG-ZEILE.
  DATA: END OF LBTAB.
  DATA: BEGIN OF STTAB OCCURS 0,
          ZEILZ LIKE MSEG-ZEILE,  "zeilz marks the original head of a
                                  "structured article:
                                  "if zeilz = 0000  -> original head
                                  "in all other cases -> zeilz is
                                  "populated and identical to zeile
          ZEILE LIKE MSEG-ZEILE,
          URZEI LIKE MSEG-URZEI,
          XAUTO LIKE MSEG-XAUTO,
          XHEAD LIKE PXVAF-XHEAD.
  DATA: END OF STTAB.
* vsa struct. article
  DATA: BEGIN OF SUTAB OCCURS 0,
          ZEILE LIKE MSEG-ZEILE,
          ZEIUM LIKE MSEG-ZEILE,     "line number of '101' transfer line
          WRBTR LIKE PXVAF-WRBTR,
          HDEXP TYPE C.                "head exploded (at sender's)
  DATA: END OF SUTAB.
* vsa struct. article
*begin of note 396879
* table for short lock:
  DATA: LT_ENQUEUE_EXCEPTIONS LIKE ENQUEUES_EXCEPTION_S OCCURS 0.
  DATA: SHORT_LOCK TYPE C VALUE 'Y',
        EXCLUSIVE_LOCK TYPE C VALUE 'E',
        SHORT_OR_EXCLUSIVE TYPE C VALUE 'X'.
* meaning of field lt_enqueue_exceptions-BSX_POSTING:
*  'E' => exclusive lock necessary
*  'X' =>
*  'Y' => short lock possible
*end of note 396879
  FREE: FUSS, BILD, BIWE.
  CLEAR: DRUCK, RW_POSNR, LBTAB, STTAB, ZMBUZ, XDBEFU, XNEBE,
         UPD_UM03B, UPD_XLIFO, UPD_RW, INDEX_M, INDEX_INV, SUTAB.
  REFRESH: ZMSEG, ZVM07M, ZDM07M, ZEKLB,
           XACCHD, XACCIT, XACCCR, EMBEW, IMBEW, XPXVAF, YPXVAF,
           XVSTAT, XMDCP, XLIFO, XCHVW, XFABE, XPBAT, XMBQSSZ,
           ZMBUZ, YMDEL, YFBUZ, BUKRS, LFBNR, LBTAB, STTAB,
*          xmbew, xebew, xqbew, xfaws, xfawv,                       "kaz
           XMBEW, XEBEW, XQBEW, XOBEW, XFAWS, XFAWV,        "kaz
           XMCMSEG, XMCMRES, XMCBEST, XMCWMHD, XMCWMIT,
           XLK01, XLK02, XLTBUB, XDBEFU, XVBFA,
           YISEG, YVM07I, YIBUZ, YCM07I, XAUFM,
           XEKWS, XEKWV, XEKBN, XEKBV, XEKBE, XEKBZ, XAUWEI, WEKBE,

*          clear these  MAA tables for each MM posting         "MAA EhP4
           xekbe_ma, xekbz_ma,                                 "MAA EhP4

*          xekbe_cr, yekbe_cr, xekbz_cr, xrkwa, xexop, wekbe_cr,    "kaz
           XEKBE_CR, YEKBE_CR, XEKBZ_CR, XRKWA, XROWA, XEXOP, WEKBE_CR,"
           XAUFBE, XAUFBE_CR, YAUFBE_CR, ZAUFBE_CR, SUTAB,
           GT_FTRADE,
*          prefetch04, prefetch21, prefetch22.                      "kaz
           prefetch04, prefetch21, prefetch22, prefetch29.

* Clear also the headerline. Otherwise it could result in errors via
* IDOC-Processing, because there is still old data in here
  CLEAR:   XMSEG, XVM07M, XVM07M, ZMSEG, ZVM07M, ZDM07M, ZEKLB,
           XACCHD, XACCIT, XACCCR, EMBEW, IMBEW, XPXVAF, YPXVAF,
           XVSTAT, XMDCP, XLIFO, XCHVW, XFABE, XPBAT, XMBQSSZ,
           ZMBUZ, YMBUZ, YMDEL, YFBUZ, BUKRS, LFBNR, LBTAB, STTAB,
*          xmbew, xebew, xqbew, xfaws, xfawv,                       "kaz
           XMBEW, XEBEW, XQBEW, XOBEW, XFAWS, XFAWV,        "kaz
           XMCMSEG, XMCMRES, XMCBEST, XMCWMHD, XMCWMIT,
           XLK01, XLK02, XLTBUB, XDBEFU, XVBFA,
           YISEG, YVM07I, YIBUZ, YCM07I, XAUFM,
           XEKWS, XEKWV, XEKBN, XEKBV, XEKBE, XEKBZ, XAUWEI, WEKBE,
           xekbe_ma, xekbz_ma,                              "MAA EhP4
*          xekbe_cr, yekbe_cr, xekbz_cr, xrkwa, xexop, wekbe_cr,    "kaz
           XEKBE_CR, YEKBE_CR, XEKBZ_CR, XRKWA, XROWA, XEXOP, WEKBE_CR,"
           XAUFBE, XAUFBE_CR, YAUFBE_CR, ZAUFBE_CR, SUTAB,
           GT_FTRADE, GS_ACCIT_EXT, GT_ACCIT_EXT,                "593240
*          prefetch04, prefetch21, prefetch22.                      "kaz
           prefetch04, prefetch21, prefetch22, prefetch29.
  FBELNR = NULLEN.
ENHANCEMENT-POINT BUCHEN_INITIALISIEREN_01 SPOTS ES_SAPMM07M .
* IF NOT TCURM-MBEQU IS INITIAL.                            "note 311658
  CALL FUNCTION 'CKML_BUFFER_REFRESH_ALL'                   "note 934326
    EXPORTING
      I_CALLED_BY       = 'MMIM  '.
* ENDIF.                      "note 311658

* Die Einträge, für die neue Bestellungen anzulegen sind, sind aus
* den Währungstabellen zu löschen, da diese später erzeugt werden.
  DELETE YEKBNK_CR WHERE EBELN = AUTO_BEST.                 "0438401
  DELETE YEBEFU_CR WHERE EBELN = AUTO_BEST.                 "0438401

  DATA: MS-ZEILE LIKE MSEG-ZEILE.
  CLEAR: MS-ZEILE.
  TYPES: BEGIN OF TY_OLD_TO_NEW_URZEI,
         OLD LIKE MSEG-URZEI,
         NEW LIKE MSEG-URZEI,
         END OF TY_OLD_TO_NEW_URZEI.
  DATA: OLD_TO_NEW_URZEI TYPE HASHED TABLE OF TY_OLD_TO_NEW_URZEI
                         WITH UNIQUE KEY OLD
                         WITH HEADER LINE.
  LOOP AT OMSEG WHERE XAUTO <> D.
    READ TABLE OVM07M INDEX OMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'OVM07M' OMSEG-ZEILE.
    ENDIF.
    READ TABLE ODM07M INDEX OMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'ODM07M' OMSEG-ZEILE.
    ENDIF.
    ZMSEG = OMSEG.
    ZVM07M = OVM07M.
    ZDM07M = ODM07M.
*   Note 329696 reverses part of note 181851. Note 181851 changed the
*   behavior of ZMBUZ-ZEILY (ZMBUZ counter instead of ref to YMSEG)
*   which caused problems in serial numbers. Behavior with new note:
*   - ZMBUZ-ZEILY and ZMBUZ-ZEILO receive the old YMSEG and OMSEG line
*     in order to be able to find YMSEG and OMSEG from ZMBUZ
*   - ZMBUZ-URZEY is not the URZEI from YMSEG but from ZMSEG and is
*     already determined correctly here, even for subitems, if some
*     items are deleted because of F12. Zero lines are deleted later
*     in M-SEGMENTE_GENERIEREN.
    ZMBUZ-ZEILO = ZMSEG-ZEILE.                            "note 329696
*   ZMBUZ-URZEY = ZMSEG-URZEI.                             "note 181851
    MS-ZEILE = MS-ZEILE + 1.
    ZMSEG-ZEILE = ZVM07M-ZEILV = ZDM07M-ZEILD = MS-ZEILE.

    READ TABLE OLD_TO_NEW_URZEI WITH TABLE KEY             "note 181851
                             OLD = ZMSEG-URZEI.            "note 181851
    IF NOT SY-SUBRC IS INITIAL.                            "note 181851
      OLD_TO_NEW_URZEI-OLD = ZMSEG-URZEI.                  "note 181851
      OLD_TO_NEW_URZEI-OLD = ZMSEG-URZEI.                  "note 181851
      ZMSEG-URZEI = ZMSEG-ZEILE.                           "note 181851
      OLD_TO_NEW_URZEI-NEW = ZMSEG-URZEI.                  "note 181851
      INSERT TABLE OLD_TO_NEW_URZEI.                       "note 181851
    ELSE.                                                  "note 181851
      ZMSEG-URZEI = OLD_TO_NEW_URZEI-NEW.                  "note 181851
    ENDIF.                                                 "note 181851
*   ZMBUZ-ZEILO = ZMSEG-ZEILE.                             "note 329696
    ZMBUZ-URZEY = ZMSEG-URZEI.                             "note 181851
    APPEND ZMBUZ.                                          "note 181851
    PERFORM BUCHEN_MAT_PREFETCH
            TABLES  LT_ENQUEUE_EXCEPTIONS                   "396879
             USING ZDM07M
                   ZVM07M
                   ZMSEG .
    ZDM07M-VMENG = ZDM07M-VERMG = ZDM07M-VBPMG = 0.
    ZDM07M-VWERT = ZDM07M-VWERE = ZDM07M-UMVWE = ZDM07M-VWERR = 0.
    ZDM07M-VWALT = ZDM07M-UMVWA = ZDM07M-UMVWR = ZDM07M-VBSMG = 0.
    ZDM07M-VVKWR = 0.
    APPEND ZMSEG.
    APPEND ZVM07M.
    APPEND ZDM07M.
  ENDLOOP.
  CLEAR ZMBUZ.

*                           * testing consitency of YMSEG  "note 328675
*                           * for Retail specific articles "note 328675
* PERFORM RETAIL_STRUCT_CHECK USING X.                     "note 328675
  PERFORM RETAIL_STRUCT_CHECK_IT USING X.                  "note 356129

  LOOP AT YMSEG WHERE XAUTO <> D.
    PERFORM CHECK_MOVEMENT     USING XWERT MBVAL
                                     YMSEG-KZBEW
                                     MKPF-VGART
                                     BRAZIL
                                     INVENTUR.
    READ TABLE YVM07M INDEX YMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'YVM07M' YMSEG-ZEILE.
    ENDIF.
* note 137861
* if goods receipt with automatic creation of po and neither qty nor
* sales value (context of value-only mat.) exist -> skip item
    CHECK YVM07M-XNEBE IS INITIAL OR NOT YMSEG-KZBEW = B OR
       NOT YMSEG-ERFMG IS INITIAL OR NOT YMSEG-VKWRT IS INITIAL OR
       NOT YMSEG-MENGE IS INITIAL OR NOT YMSEG-BSTMG IS INITIAL.
* note 137861
    READ TABLE YDM07M INDEX YMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'YDM07M' YMSEG-ZEILE.
    ENDIF.
    ZMSEG = YMSEG.
    ZVM07M = YVM07M.
    ZDM07M = YDM07M.
*   Note 329696: see comment above
    ZMBUZ-ZEILY = ZMSEG-ZEILE.
*    ZMBUZ-URZEY = ZMSEG-URZEI.                            "note 181851
*    APPEND ZMBUZ.                                         "note 181851
    MS-ZEILE = MS-ZEILE + 1.
    ZMSEG-ZEILE = ZVM07M-ZEILV = ZDM07M-ZEILD = MS-ZEILE.

    READ TABLE OLD_TO_NEW_URZEI WITH TABLE KEY             "note 181851
                              OLD    = ZMSEG-URZEI.        "note 181851
    IF NOT SY-SUBRC IS INITIAL.                            "note 181851
      OLD_TO_NEW_URZEI-OLD = ZMSEG-URZEI.                  "note 181851
      ZMSEG-URZEI = ZMSEG-ZEILE.                           "note 181851
      OLD_TO_NEW_URZEI-NEW = ZMSEG-URZEI.                  "note 181851
      INSERT TABLE OLD_TO_NEW_URZEI.                       "note 181851
    ELSE.                                                  "note 181851
      ZMSEG-URZEI = OLD_TO_NEW_URZEI-NEW.                  "note 181851
    ENDIF.                                                 "note 181851
*  ZMBUZ-ZEILY = ZMSEG-ZEILE.                             "note 329696
    ZMBUZ-URZEY = ZMSEG-URZEI.                              "note 32969
    APPEND ZMBUZ.                                          "note 181851

*   note 380695: in case of F12 for SC component, DM07M-ZEILO needs
*   to be renumbered like MSEG-URZEI because we need it for XEKLB
*   parent/child relationship. ZEILO is set for components only.
*   Only renumber ZEILO if not initial because we do not want a ZEILO
*   for other processes like transfers.
    IF NOT ZDM07M-ZEILO IS INITIAL.                        "note 380695
      ZDM07M-ZEILO = ZMSEG-URZEI.                          "note 380695
    ENDIF.                                                 "note 380695

    IF ZMSEG-BUSTW = BUSTW_WA04 AND ZMSEG-KZBWS IS INITIAL AND  "MI note
       ( ZMSEG-SOBKZ = E OR ZMSEG-SOBKZ = Q ).           "MI note wg PC
      ZMSEG-PRCTR = ZMSEG-PPRCTR.      "MI note wg PC
      ZMSEG-PPRCTR = ZDM07M-UMPRC.     "MI note wg PC
    ENDIF.                             "MI note wg PC
    IF ZMSEG-KZBEW IS INITIAL AND ZVM07M-PSTYP = DREI.      "204573
      LBTAB-ZEILE = MS-ZEILE.
      APPEND LBTAB.
    ENDIF.
    IF NOT ZMSEG-BUSTW IS INITIAL AND NOT ZMSEG-BUSTW = BUSTW_WE06.
*     structured article handling
      IF ZMSEG-XAUTO = S OR ZMSEG-XAUTO = U.
        IF NOT ZVM07M-XSTOR = ZWEI.
          IF NOT STTAB-URZEI = ZMSEG-URZEI.
*         enter the original head in sttab; this will always be done
*         while processing the copied head (mvmt type 317 or 319);
*         conclusion: the original head is ALWAYS in sttab
            CLEAR: STTAB-ZEILZ, STTAB-XAUTO.
            STTAB-ZEILE = STTAB-URZEI = ZMSEG-URZEI.
            STTAB-XHEAD = X.
            APPEND STTAB.
          ENDIF.
*         at this point: enter a copied head or a component in sttab
          STTAB-ZEILZ = MS-ZEILE.  "ms-zeile is identical to zmseg-zeile
          STTAB-ZEILE = ZMSEG-ZEILE.
          STTAB-URZEI = ZMSEG-URZEI.
          STTAB-XAUTO = ZMSEG-XAUTO.
          STTAB-XHEAD = ZVM07M-XHEAD.
          APPEND STTAB.
        ENDIF.
*    sales price handling for non structured articles
     ELSEIF ( NOT ZVM07M-XVKBW IS INITIAL AND ZVM07M-XHEAD IS INITIAL )
       OR ( NOT ZDM07M-UMXVK IS INITIAL AND ZDM07M-UMXHEAD IS INITIAL ).
        CLEAR YPXVAF.
        MOVE-CORRESPONDING ZDM07M TO YPXVAF.
        MOVE-CORRESPONDING ZVM07M TO YPXVAF.
        MOVE-CORRESPONDING ZMSEG TO YPXVAF.
        YPXVAF-BUDAT = MKPF-BUDAT.
        CLEAR: YPXVAF-XSTRU, YPXVAF-XHEAD.
        APPEND YPXVAF.
      ENDIF.
    ENDIF.
    IF NOT ZVM07M-XNEBE IS INITIAL.
      IF ZMSEG-KZBEW = B.
        MOVE-CORRESPONDING ZDM07M TO XDBEFU.
        MOVE-CORRESPONDING ZMSEG TO XDBEFU.
        MOVE-CORRESPONDING ZVM07M TO XDBEFU.
        APPEND XDBEFU.
      ELSE.
        CLEAR ZVM07M-XNEBE.
      ENDIF.
    ENDIF.
    PERFORM BUCHEN_MAT_PREFETCH
                        TABLES  LT_ENQUEUE_EXCEPTIONS       "396879
                                USING ZDM07M
                                      ZVM07M
                                      ZMSEG.
    ZDM07M-VMENG = ZDM07M-VERMG = ZDM07M-VBPMG = 0.
    ZDM07M-VWERT = ZDM07M-VWERE = ZDM07M-UMVWE = ZDM07M-VWERR = 0.
    ZDM07M-VWALT = ZDM07M-UMVWA = ZDM07M-UMVWR = ZDM07M-VBSMG = 0.
    ZDM07M-VVKWR = 0.
    IF NOT ZMSEG-AUFNR IS INITIAL AND ZMSEG-KZBEW NE F.
      CALL FUNCTION 'CKMO_CHECK_GI_RELEVANT'
        EXPORTING
          I_AUFNR    = ZMSEG-AUFNR
          I_BUDAT    = MKPF-BUDAT
        IMPORTING
          E_RELEVANT = ZVM07M-MLCCS_RELEVANT.
      .
    ENDIF.
    APPEND ZMSEG.
    APPEND ZVM07M.
    APPEND ZDM07M.
* vsa struct. article
    IF NOT ZDM07M-ORUML IS INITIAL  AND  ZVM07M-KZBWA = KZBWA-05  AND
       ZVM07M-XHEAD IS INITIAL.
* transfer: head of struct. article not exploded at sender's; get value
      CLEAR SUTAB-HDEXP.
      PERFORM STRUC_ARTICLE_HEADER_VALUE CHANGING SUTAB-ZEILE
                                                  SUTAB-ZEIUM
                                                  SUTAB-WRBTR.
      IF NOT SUTAB-ZEILE IS INITIAL.
        APPEND SUTAB.
      ENDIF.
    ENDIF.
    IF NOT ZDM07M-ORUML IS INITIAL  AND  ZVM07M-KZBWA = KZBWA-05  AND
       ZVM07M-XHEAD = X.
* transfer: head of struct. article is exploded at sender's: memorize
      DATA: H_YDM07M LIKE YDM07M.
      CLEAR: SUTAB-WRBTR, SUTAB-ZEIUM.
      SUTAB-HDEXP = X.
      SUTAB-ZEILE = ZMSEG-ZEILE.
      LOOP AT YDM07M INTO H_YDM07M WHERE ORUML = ZDM07M-ZEILD  AND
                                         NOT ZEILD = ZDM07M-ZEILD.
        SUTAB-ZEIUM = H_YDM07M-ZEILD.
        EXIT.
      ENDLOOP.
      APPEND SUTAB.
    ENDIF.
* vsa struct. article
  ENDLOOP.
  IF_FIRST.
  REFRESH: XMKPF, XMSEG, XVM07M, YMBUZ.
  READ TABLE XDBEFU INDEX 1.
  IF SY-SUBRC IS INITIAL.
    PERFORM AUTOMATISCHE_BESTELLUNG.
    XNEBE = X.
  ENDIF.
  END_FIRST.
  CHECK_SECON.
  IF MBVAL IS INITIAL.
    DATA: XLOCK.                                           "note 316622
    IF NOT XMBWL IS INITIAL AND XLOCK_ALLP IS INITIAL.     "note 316622
      "No lock on EM07W because lock already exists        "note 316622
      XLOCK = X.                                           "note 316622
    ELSE.                                                  "note 316622
      "Lock EM07MW in exclusive mode                       "note 316622
      CLEAR XLOCK.                                         "note 316622
    ENDIF.                                                 "note 316622
    CALL FUNCTION 'MB_PREREAD_MATERIAL_VALUES'
         EXPORTING
              MBEQU = TCURM-MBEQU
              XONLY = XLOCK                                "note 316622
         TABLES
              PRE04 = PREFETCH04
              PRE21 = PREFETCH21
*          pre22 = prefetch22.                                     "kaz
              PRE22 = PREFETCH22                            "kaz
              PRE29 = PREFETCH29                           "kaz
              IT_ENQUEUE_EXCEPTION = LT_ENQUEUE_EXCEPTIONS. "396879
  ELSE.
    IF SPERRVERSUCHE_MAT IS INITIAL OR WAIT_MAT IS INITIAL.
      SPERRVERSUCHE_MAT = 1. WAIT_MAT = 10.
    ENDIF.
    DO.
      CALL FUNCTION 'MB_PREREAD_MATERIAL_VALUES'
        EXPORTING
          MBEQU                = TCURM-MBEQU
          XONLY                = XLOCK                      "note 316622
        TABLES
          PRE04                = PREFETCH04
          PRE21                = PREFETCH21
          PRE22                = PREFETCH22
          PRE29                = PREFETCH29                  "kaz
          IT_ENQUEUE_EXCEPTION = LT_ENQUEUE_EXCEPTIONS      "396879
        EXCEPTIONS
          ERROR_MESSAGE        = 1.
      IF NOT SY-SUBRC IS INITIAL.
        IF SY-INDEX > SPERRVERSUCHE_MAT.
          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
                   WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4
                   RAISING ERROR_MESSAGE.
        ENDIF.
        WAIT UP TO WAIT_MAT SECONDS.
        MBVAL = X.
      ELSE.
        EXIT.
      ENDIF.
    ENDDO.
  ENDIF.
ENHANCEMENT-POINT BUCHEN_INITIALISIEREN_02 SPOTS ES_SAPMM07M.
  CALL FUNCTION 'J_1B_IM_TX_YMSEG'                "note 870572
       TABLES                                     "note 870572
            i_ymseg = ymseg.                      "note 870572
  LOOP AT LBTAB.
    READ TABLE ZMSEG INDEX LBTAB-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'ZMSEG' LBTAB-ZEILE.
    ENDIF.
    READ TABLE ZVM07M INDEX ZMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'ZVM07M' ZMSEG-ZEILE.
    ENDIF.
    READ TABLE ZDM07M INDEX ZMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'ZDM07M' ZMSEG-ZEILE.
    ENDIF.
ENHANCEMENT-POINT BUCHEN_INITIALISIEREN_05 SPOTS ES_SAPMM07M.

ENHANCEMENT-SECTION     BUCHEN_INITIALISIEREN_03 SPOTS ES_SAPMM07M.

    CALL FUNCTION 'MB_CALCULATE_VALUES'
      EXPORTING
        DM07M     = ZDM07M
        VM07M     = ZVM07M
        MKPF      = MKPF
        MSEG      = ZMSEG
        MBEQU     = TCURM-MBEQU
        GLVOR     = RW_VORGANG
        KURST     = T003-KURST
        BRAZIL    = BRAZIL
        XMBWL     = XMBWL
      IMPORTING
        DM07M     = DM07M
        VM07M     = VM07M
        MSEG      = MSEG
        X_FWDIF   = FWDIF
        X_SHFWDIF = SHFWDIF
      TABLES
        XEKBN     = XEKBN
        XEKBV     = XEKBV
        XEKWS     = XEKWS
        XEKWV     = XEKWV
        XMBEW     = XMBEW
        XEBEW     = XEBEW
        XQBEW     = XQBEW
        XOBEW     = XOBEW                             "kaz
        XEKLB     = ZEKLB
        XEKLS     = XEKLS
        XFAWS     = XFAWS
        XFAWV     = XFAWV
        X156W     = X156W
        XZCXCB    = XZCXCB
        XZCXCM    = XZCXCM
        YEKBNK    = YEKBNK
        YEKBNK_CR = YEKBNK_CR
        YEBEFU_CR = YEBEFU_CR
        YFBEFU_CR = YFBEFU_CR
        ZEKBE_CR  = ZEKBE_CR
        zaufbe_cr = zaufbe_cr
        xekbnk_kdm = yekbnk_kdm.                   "N1027899 + 1520698
END-ENHANCEMENT-SECTION.


ENHANCEMENT-SECTION EHP604_BUCHEN_INITIALISIEREN01 SPOTS ES_SAPMM07M .
    CALL FUNCTION 'MB_UPDATE_SUBCONTRACTING_VALUE'
      EXPORTING
        DM07M = ZDM07M
        VM07M = ZVM07M
        MSEG  = ZMSEG
      TABLES
        XEKLB = ZEKLB
        XEKLS = XEKLS.
END-ENHANCEMENT-SECTION.
ENHANCEMENT-POINT BUCHEN_INITIALISIEREN_06 SPOTS ES_SAPMM07M.
ENDLOOP.
* init table with components of finished product          "note 870572
DATA: BEGIN OF lt_ymseg OCCURS 0.                         "note 870572
        INCLUDE STRUCTURE mseg.                           "note 870572
DATA: END OF lt_ymseg.                                    "note 870572
CALL FUNCTION 'J_1B_IM_TX_YMSEG'                          "note 870572
     TABLES                                               "note 870572
          i_ymseg = lt_ymseg.                             "note 870572
* begin of note 578964 --> delete note 543174
** note 543174
** During the loop over the subcontracting components, the enqueue
** tables XMBEW, XEBEW, XQBEW and XOBEW must also be updated.
** Afterwards they have tp be refreshed and cleared.
*    call function 'MB_UPDATE_VALUE_ENQUEUE_TAB_LB'
*        EXPORTING
*              dm07m     = dm07m
*              vm07m     = zvm07m
*              mkpf      = mkpf
*              mseg      = zmseg
*              aktyp     = space
*         IMPORTING
*              dm07m     = dm07m
*              upd_um03b = vw
*              vkwrt  = mseg-vkwrt                         " 203679
*              vkwra  = mseg-vkwra                         " 203679
*         TABLES
*              xekbn     = xekbn
*              xekbv     = xekbv
*              xekws     = xekws
*              xekwv     = xekwv
*              xeklb     = zeklb
*              xekls     = xekls
*              xfaws     = xfaws
*              xfawv     = xfawv
*              x156w     = x156w
*              xmbew     = xmbew
*              xebew     = xebew
*              xqbew     = xqbew
*              xobew     = xobew
*              xzcxcb    = xzcxcb
*              xzcxcm    = xzcxcm
*              yekbnk    = yekbnk
*              yekbnk_cr = yekbnk_cr
*              yebefu_cr = yebefu_cr
*              yfbefu_cr = yfbefu_cr.
*  ENDLOOP.
** note 543174
** refresh of the value enqueue tables
*  clear:   xmbew, xebew, xqbew, xobew.
*  refresh: xmbew, xebew, xqbew, xobew.
* end of note 578964

  DATA: L_KWERT LIKE KOMV-KWERT,
        L_STAKO LIKE EKKO-KNUMV.
*loop at zeklb.
*  on change of zeklb-ebeln or zeklb-ebelp.
*    clear l_kwert.
*    select single stako into l_stako
*                        from ekko where ebeln eq zeklb-ebeln.
*    if sy-subrc <> 0.
*      select single knumv into l_knumv
*                          from ekbe
*  endon.
*  if xeklb-dmbtr < 0.
*    xeklb-dmbtr = 0 - xeklb-dmbtr.
*  endif.
*  l_kwert = l_kwert + xeklb-dmbtr.
*
*endloop.

* structured article handling
  DATA XBUSTW. CLEAR XBUSTW.
  LOOP AT STTAB.
    DATA: XWROB LIKE PXVAF-XWROB,  "stands for 'Wert obligatorisch'
                                   "(value is obligatory) and means that
                                   "WB_STOCK_VALUES_FIND shall not
                                   "propose any external value for that
                                   "item
          EXWRT LIKE PXVAF-EXWRT,
          UMEXW LIKE PXVAF-EXWRT,
          ORSHK LIKE PXVAF-SHKZG,
          UMSHK LIKE PXVAF-SHKZG.
    IF STTAB-ZEILZ IS INITIAL.
*     zeilz is initial -> we are dealing with the original head;
*     get original head from zmseg
      LOOP AT ZMSEG WHERE ZEILE = STTAB-ZEILE
                    AND   URZEI = STTAB-URZEI.
        EXIT.
      ENDLOOP.
      IF NOT SY-SUBRC IS INITIAL.
        MESSAGE E001 WITH 'ZMSEG' STTAB-ZEILE STTAB-URZEI.
      ENDIF.
*     original head is not valuated or object to account assignment;
*     it is doubtful whether the programm can ever get here!
* begin note 409343
*   IF zmseg-bustw IS INITIAL OR zmseg-bustw = bustw_we06.
      IF ZMSEG-BUSTW IS INITIAL OR ZMSEG-BUSTW = BUSTW_WE06  OR
         ZMSEG-BUSTW = BUSTW_TXBR.
* end note 409343
        XBUSTW = X.
        CHECK A = B.
      ENDIF.
*     check if there exists a kind of external value -> don't change it
      IF NOT ZMSEG-EXBWR IS INITIAL OR
         ZMSEG-KZBEW = B OR ZMSEG-KZBEW = O OR ZMSEG-KZBEW = F.
        XWROB = X.
      ELSE.
        CLEAR XWROB.
      ENDIF.
    ELSE.
*     we are dealing with a copied head (317 or 319) or a component;
*     get the belonging entry in zmseg
      READ TABLE ZMSEG INDEX STTAB-ZEILE.
      IF NOT SY-SUBRC IS INITIAL.
        MESSAGE E001 WITH 'ZMSEG' STTAB-ZEILE.
      ENDIF.
*     copied head in a stock transfer (at receiver's) -> idea: take over
*     the value of the original head (at sender's)
      IF NOT STTAB-XHEAD IS INITIAL AND STTAB-XAUTO = U.
        XWROB = X.
      ENDIF.
    ENDIF.
    READ TABLE ZVM07M INDEX ZMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'ZVM07M' ZMSEG-ZEILE.
    ENDIF.
    READ TABLE ZDM07M INDEX ZMSEG-ZEILE.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E001 WITH 'ZDM07M' ZMSEG-ZEILE.
    ENDIF.
    CLEAR XPXVAF.
    MOVE-CORRESPONDING ZDM07M TO XPXVAF.
    MOVE-CORRESPONDING ZVM07M TO XPXVAF.
    MOVE-CORRESPONDING ZMSEG TO XPXVAF.
    XPXVAF-BUDAT = MKPF-BUDAT.
    XPXVAF-XHEAD = STTAB-XHEAD.
    XPXVAF-XSTRU = X.               "this can still be object to change;
    "xstru = x means to be part of an
    "exploded structured bom; original
    "head is the only one who gets
    "xstru = space
    IF STTAB-ZEILZ IS INITIAL OR ZVM07M-XHEAD IS INITIAL OR
       NOT XBUSTW IS INITIAL.
*     one of the following cases: original head, component, unvaluated
*     item or item is object to account assignment;
*     i.e.: I don't enter here in case of a copied head (317 or 319)
*     because a copied head shall 'inherit' its value from the original
*     head
ENHANCEMENT-SECTION     BUCHEN_INITIALISIEREN_04 SPOTS ES_SAPMM07M.
      CALL FUNCTION 'MB_CALCULATE_VALUES'
        EXPORTING
          DM07M     = ZDM07M
          VM07M     = ZVM07M
          MKPF      = MKPF
          MSEG      = ZMSEG
          MBEQU     = TCURM-MBEQU
          XMBWL     = XMBWL
        IMPORTING
          DM07M     = ZDM07M
          VM07M     = ZVM07M
          MSEG      = ZMSEG
          X_FWDIF   = FWDIF
          X_SHFWDIF = SHFWDIF
        TABLES
          XEKBN     = XEKBN
          XEKBV     = XEKBV
          XEKWS     = XEKWS
          XEKWV     = XEKWV
          XMBEW     = XMBEW
          XEBEW     = XEBEW
          XQBEW     = XQBEW
          XOBEW     = XOBEW                           "kaz
          XEKLB     = ZEKLB
          XEKLS     = XEKLS
          XFAWS     = XFAWS
          XFAWV     = XFAWV
          X156W     = X156W
          XZCXCB    = XZCXCB
          XZCXCM    = XZCXCM
          YEKBNK    = YEKBNK
          YEKBNK_CR = YEKBNK_CR
          YEBEFU_CR = YEBEFU_CR
          YFBEFU_CR = YFBEFU_CR
          ZEKBE_CR  = ZEKBE_CR
          zaufbe_cr = zaufbe_cr
          xekbnk_kdm = yekbnk_kdm.                   "N1027899 + 1520698
END-ENHANCEMENT-SECTION.

      LOOP AT XZCXCM WHERE VORSL = VORSL_BSX
                     AND   CURTP = CURTP10
                     AND   XUMBW = SPACE.
        IF XZCXCM-BUZID = M.
          IF STTAB-XAUTO = U.
            XPXVAF-KZUML = X.
          ELSE.
            CLEAR XPXVAF-KZUML.
          ENDIF.
          XPXVAF-SHKZG = ORSHK = XZCXCM-SHKZG.
          XPXVAF-WRBTR = EXWRT = XZCXCM-DMBTR.
          IF XPXVAF-XHEAD IS INITIAL.
*           components shall be valuated normally
            CLEAR XPXVAF-XWROB.
          ELSE.
            XPXVAF-XWROB = XWROB.
          ENDIF.
          IF NOT ZVM07M-KZBWA = KZBWA-SZ.
*         'SZ' comes from mvmt types 317, 318, 319, 320 -> not 'SZ'
*         means to be the original head
            CLEAR XPXVAF-XSTRU.
            CLEAR XPXVAF-KZUML.
          ENDIF.
*         IF ZVM07M-KZBWA = KZBWA-SZ OR ZDM07M-KZUML IS INITIAL."188328
          IF ZVM07M-KZBWA = KZBWA-SZ   " note 188328
             OR NOT ZMSEG-BUSTW = BUSTW_WA04.             " note 188328
            APPEND XPXVAF.
          ENDIF.
        ELSEIF XZCXCM-BUZID = U.
*         this must be an original head: all other lines have mvmt type
*         317/318/319 or 320 -> bustw = WA01, WA01 doesn't have a line
*         with buzid = u;
*         buzid = u: stock transfer -> record transfer value umexw
          UMSHK = XZCXCM-SHKZG.
          UMEXW = XZCXCM-DMBTR.
          XPXVAF-XWROB = X.
          CLEAR XPXVAF-XSTRU.
          CLEAR XPXVAF-KZUML.
          IF NOT ZVM07M-XHEAD IS INITIAL.
            APPEND XPXVAF.
          ENDIF.
        ENDIF.
      ENDLOOP.
      IF NOT SY-SUBRC IS INITIAL.
        MESSAGE E001 WITH 'XZCXCM' 'BSX' CURTP10.
      ENDIF.
*     Abgeberzeile einer Umlagerung                         "note 526720
      IF NOT zdm07m-kzuml IS INITIAL.                       "note 526720
*     zu der Position wurde keine Stückliste aufgelöst      "note 526720
         IF zvm07m-xhead IS INITIAL.                        "note 526720
*        strukt. Artikel in Umlagerung, der nicht aufgeloest"note 526720
*        wurde; muss hier gemacht werden, da innerhalb des  "note 526720
*        loops über xzcxcm nicht behandelt wird.            "note 526720
            CLEAR xpxvaf-kzuml.                             "note 526720
            xpxvaf-shkzg = zmseg-shkzg.                     "note 526720
            xpxvaf-wrbtr = exwrt.                           "note 526720
            xpxvaf-xwrob = x.                               "note 526720
            append xpxvaf.                                  "note 526720
         ENDIF.                                             "note 526720
      ENDIF.                                                "note 526720
      CLEAR XBUSTW.
    ELSE.
*     we are dealing with a copied head (317 or 319): copy its value
*     (field exwrt or umexw) from the original head
      IF STTAB-XAUTO = U.
*       in xpxvaf the receiver's lines of a stock transfer will get
*       kzuml = x  (the sender's lines won't)
        XPXVAF-KZUML = X.
        XPXVAF-WRBTR = UMEXW.
        XPXVAF-SHKZG = UMSHK.
      ELSE.
        CLEAR XPXVAF-KZUML.
        XPXVAF-WRBTR = EXWRT.
        XPXVAF-SHKZG = ORSHK.
      ENDIF.
*     turn round the sign because copied head shall make 'undone' the
*     effects done by original head
      IF XPXVAF-SHKZG = H.
        XPXVAF-SHKZG = S.
      ELSEIF XPXVAF-SHKZG = S.
        XPXVAF-SHKZG = H.
      ELSE.
        CLEAR XPXVAF-SHKZG.
      ENDIF.
      XPXVAF-XWROB = XWROB.
      APPEND XPXVAF.
    ENDIF.
  ENDLOOP.
* vsa struct. article
  LOOP AT SUTAB.
    IF SUTAB-HDEXP IS INITIAL.
* bom of head at sender's is not exploded
* get line number of '319' head at receiver's
    READ TABLE STTAB WITH KEY URZEI = SUTAB-ZEIUM  XHEAD = X  XAUTO = S.
      IF SY-SUBRC IS INITIAL.
        READ TABLE XPXVAF WITH KEY ZEILE = STTAB-ZEILE.
        IF SY-SUBRC IS INITIAL.
          XPXVAF-WRBTR = SUTAB-WRBTR.
          MODIFY XPXVAF INDEX SY-TABIX.
        ENDIF.
      ENDIF.
    ELSE.
* bom of head at sender's is exploded
* get zeile of '317' head at sender's and use it as ergze
      READ TABLE STTAB WITH KEY URZEI = SUTAB-ZEILE  XHEAD = X
                                XAUTO = S.
      IF SY-SUBRC IS INITIAL.
        DATA: H_ERGZE LIKE MSEG-ZEILE.
        MOVE STTAB-ZEILE TO H_ERGZE.
* get '647' head at sender's and record ergze
        READ TABLE XPXVAF WITH KEY ZEILE = SUTAB-ZEILE.
        IF SY-SUBRC IS INITIAL.
          XPXVAF-ERGZE = H_ERGZE.
          MODIFY XPXVAF INDEX SY-TABIX.
          IF SY-SUBRC IS INITIAL.
* get '319' head at receiver's (if exists) and record ergze
            READ TABLE STTAB WITH KEY URZEI = SUTAB-ZEIUM  XHEAD = X
                                      XAUTO = S.
            IF SY-SUBRC IS INITIAL.
              READ TABLE XPXVAF WITH KEY ZEILE = STTAB-ZEILE.
              IF SY-SUBRC IS INITIAL.
                XPXVAF-ERGZE = H_ERGZE.
                MODIFY XPXVAF INDEX SY-TABIX.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.
* vsa struct. article

* IF SY-SUBRC IS INITIAL.                             'UWS
*   CALL FUNCTION 'WB_STOCK_VALUES_FIND'              'UWS
*        EXPORTING                                    'UWS
*             PI_AUFRUF  = ZWEI                       'UWS
*        TABLES                                       'UWS
*             PX_T_PXVAF = XPXVAF.                    'UWS
* ENDIF.                                              'UWS
  CALL FUNCTION 'WB_STOCK_VALUES_FIND'
    EXPORTING
      PI_AUFRUF  = ZWEI
    TABLES
      PX_T_PXVAF = XPXVAF
      PY_T_PXVAF = YPXVAF.
*   record proposed values (xpxvaf-exwrt) as zmseg-exbwr; this is needed
*   when doing the reversal
  PERFORM STRUCT_EXBWR_RECORD TABLES XPXVAF.

ENDFORM.                    "BUCHEN_INITIALISIEREN