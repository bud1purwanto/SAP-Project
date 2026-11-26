*---------------------------------------------------------------------*
*       FORM BESTANDSFINDUNG
*---------------------------------------------------------------------*
*       Der Funktionsbaustein zur Bestandsfindung wird aufgerufen.    *
*---------------------------------------------------------------------*
FORM BESTANDSFINDUNG.
  CLEAR XBFCOM.
  CLEAR YLGORT.
  REFRESH YLGORT.
  REFRESH E_BFSTOCK.
* Special procedure: Stock determination with LGORT=' ' and      "428438
*                    CHARG='*'.                                  "428438
* The determination can only work with an initial field CHARG.   "428438
  IF mseg-charg CA stern.                                        "428438
    CLEAR mseg-charg.                                            "428438
  ENDIF.                                                         "428438
  MOVE-CORRESPONDING MSEG TO XBFCOM.
  MOVE-CORRESPONDING DM07M TO XBFCOM.
  MOVE-CORRESPONDING VM07M TO XBFCOM.
  MOVE MSEG-MAT_KDAUF TO XBFCOM-VBELN.
  MOVE MSEG-MAT_KDPOS TO XBFCOM-POSNR.
  MOVE MSEG-MAT_PSPNR TO XBFCOM-PSPNR.
  IF VM07M-XCHPF IS INITIAL AND NOT DM07M-XCHAR IS INITIAL
     AND MSEG-CHARG NP STERN.
    XBFCOM-BWTAR = MSEG-CHARG.
  ENDIF.
  XBFCOM-PRREG = T158-PRREG.
  IF NOT XMBWL IS INITIAL.
    XBFCOM-NODIA = X.
  ENDIF.
  XBFCOM-NODEL = SPACE.
  XBFCOM-NOLCK = X.
  XBFCOM-XMORE = X.
  XBFCOM-STCHK = X.
  XBFCOM-LBBSA = T156M-LBBSA.
  XBFCOM-MBDAT = MKPF-BUDAT.
  XBFCOM-KAPPL = 'ME'.
  IF NOT mseg-ebeln IS INITIAL AND
     NOT mseg-kzzug IS INITIAL AND
     mseg-kzbew IS INITIAL AND im_process IS INITIAL.
    xbfcom-delnr = mseg-ebeln.
    xbfcom-delps = mseg-ebelp.
    xbfcom-delkz = 'U1'.
  ENDIF.


* ATP-Deltamanagement
  IF NOT MSEG-RSNUM IS INITIAL.
    CLEAR ATPDT.
    ATPDT-ATPTK = 'RE'.
    ATPDT-ATPAP = 'MB'.
    ATPDT-DELST = C.
    ATPDT-DELNR = MSEG-RSNUM.
    ATPDT-DELPS = MSEG-RSPOS.
    ATPDT-RSART = MSEG-RSART.
    CALL FUNCTION 'DELTA_MANAGEMENT'
         EXPORTING
              P_ATPDT  = ATPDT
         EXCEPTIONS
              OTHERS   = 0.
  ENDIF.

* Aufbau der Korrekturtabellen und ATP auf Werksebene
  IF DM07M-KZUML IS INITIAL OR
     ( NOT DM07M-KZUML IS INITIAL AND MSEG-SHKZG = H ).
    IF MSEG-SHKZG = H AND NOT DM07M-KZVBP IS INITIAL AND NOT
       VM07M-MTVFP IS INITIAL.
      PERFORM DYNAMISCHE_VERFPRUEFUNG(SAPFM07M) USING DM07M-KZVBP
                                                      VM07M-MTVFP
                                                      MSEG-MATNR
                                                      MSEG-WERKS
                                                      SPACE
                                                      MSEG-CHARG
                                                      DM07M-FABKL
                                                      SPACE
                                                    dm07m-berid. "454320
    ENDIF.
    IF VM07M-MTVFP IS INITIAL.
      CLEAR XBFCOM-KZVBP.
    ELSE.
      XBFCOM-MTVFP = VM07M-MTVFP.
    ENDIF.
  ELSE.
    IF MSEG-SHKZG = S AND NOT DM07M-KZVBP IS INITIAL AND NOT
       DM07M-UMMTV IS INITIAL.
      PERFORM DYNAMISCHE_VERFPRUEFUNG(SAPFM07M) USING DM07M-KZVBP
                                                      DM07M-UMMTV
                                                      MSEG-UMMAT
                                                      MSEG-UMWRK
                                                      SPACE
                                                      MSEG-UMCHA
                                                      DM07M-UMFAB
                                                      X
                                                 dm07m-umberid. "454320
    ENDIF.
    IF DM07M-UMMTV IS INITIAL.
      CLEAR XBFCOM-KZVBP.
    ELSE.
      XBFCOM-MTVFP = DM07M-UMMTV.
    ENDIF.
  ENDIF.

* Korrektursätze überprüfen
  LOOP AT ATPCSX.
    ATPCSX-CORFLG = X.
    ATPCSX-ENQFLG = SPACE.
    ATPCSX-CHKFLG = SPACE.
    IF ATPCSX-LGORT IS INITIAL.
      ATPCSX-IDXATP = 0.
    ELSE.
      ATPCSX-IDXATP = 1.
    ENDIF.
    MODIFY ATPCSX.
  ENDLOOP.

* combination movement type and SOBKZ = K possible?
  SELECT SINGLE * FROM T156B WHERE BWART = XBFCOM-BWART     "note 376620
                             AND   SOBKZ = K.               "note 376620
  IF NOT SY-SUBRC IS INITIAL.                               "note 376620
*   BF_STOCK_DETERMINATION does not return consignment stock if
*   XNCSG = F.
    XBFCOM-XNCSG = F.                                       "note 376620
  ENDIF.                                                    "note 376620

  CALL FUNCTION 'BF_STOCK_DETERMINATION'
       TABLES
            E_BFSTOCK = E_BFSTOCK
            I_ATPCSX  = ATPCSX
       CHANGING
            X_BFCOM   = XBFCOM
       EXCEPTIONS
            OTHERS    = 4.
  IF NOT SY-SUBRC IS INITIAL.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

  CHECK SY-SUBRC IS INITIAL.
  LOOP AT E_BFSTOCK.
    YLGORT-XSELP = X.
    YLGORT-ZEILE = MSEG-ZEILE.
    YLGORT-MATNR = E_BFSTOCK-MATNR.
    YLGORT-WERKS = E_BFSTOCK-WERKS.
    YLGORT-LGORT = E_BFSTOCK-LGORT.
    YLGORT-CHARG = E_BFSTOCK-CHARG.
    YLGORT-MENGE = E_BFSTOCK-MENGE.
    YLGORT-MEINS = E_BFSTOCK-MEINS.
    YLGORT-ERFMG = E_BFSTOCK-ERFMG.
    YLGORT-ERFME = E_BFSTOCK-ERFME.
    YLGORT-SOBKZ = E_BFSTOCK-SOBKZ.
    YLGORT-LIFNR = E_BFSTOCK-LIFNR.
    YLGORT-BWTAR = E_BFSTOCK-BWTAR.
*   BF_STOCK_DETERMINATION might return a different SOBKZ than
*   MSEG-SOBKZ. Therefore we have to read T156B to find the correct
*   UMSOK. This ensures that our quantity enqueue tables are build up.
    CLEAR: YLGORT-UMSOK.                                    "note 376620
    SELECT SINGLE UMSOK FROM T156B                          "note 376620
                        INTO YLGORT-UMSOK                   "note 376620
                        WHERE BWART = MSEG-BWART            "note 376620
                        AND   SOBKZ = E_BFSTOCK-SOBKZ.      "note 376620
    APPEND YLGORT.
    XBFCOM-ERFMG = XBFCOM-ERFMG - YLGORT-ERFMG.
  ENDLOOP.

*-- Konnte die angeforderte Menge befiedigt werden?
  IF XBFCOM-ERFMG > 0.
    DATA: LOC_TEXT(20) TYPE C.
    DATA: LOC_TEXT2(3) TYPE C.                              "note 390777
    WRITE XBFCOM-ERFMG TO LOC_TEXT NO-ZERO LEFT-JUSTIFIED.
    WRITE MSEG-ERFME TO LOC_TEXT2 NO-ZERO LEFT-JUSTIFIED.   "note 390777
    IF MSEG-SHKZG = 'S'.                                         "566147
      CALL FUNCTION 'MB_CHECK_T160M'                             "566147
        EXPORTING                                                "566147
          I_ARBGB          = 'M7'                                "566147
          I_msgnr          = '389'                               "566147
          I_MSGV1          = MSEG-MATNR                          "566147
          I_MSGV2          = LOC_TEXT                            "566147
          I_MSGV3          = LOC_TEXT2                           "566147
          I_OUTPUT         = X.                                  "566147
    ELSE.                                                        "566147
      CALL FUNCTION 'MB_CHECK_T160M'                        "note 390777
        EXPORTING                                           "note 390777
          I_ARBGB          = 'LB'                           "note 390777
          I_msgnr          = '031'                          "note 390777
          I_MSGV1          = MSEG-MATNR                     "note 390777
          I_MSGV2          = LOC_TEXT                       "note 390777
          I_MSGV3          = LOC_TEXT2                      "note 390777
          I_OUTPUT         = X.                             "note 390777
    ENDIF.                                                       "566147
  ENDIF.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM   XBLNRWA_SETZEN                                         *
*---------------------------------------------------------------------*
*       Die externe Belegnummer im Belegkopf wird aus dem Material-   *
*       schein gesetzt.                                               *
*---------------------------------------------------------------------*
FORM XBLNRWA_SETZEN.
  MKPF-XBLNR = RM07M-MTSNR.
  PERFORM OFF_NUMBER_GLOBAL_CHECK.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM   XBLNRWE_SETZEN                                         *
*---------------------------------------------------------------------*
*       Die externe Belegnummer im Belegkopf wird aus dem Liefer-     *
*       schein gesetzt.                                               *
*---------------------------------------------------------------------*
FORM XBLNRWE_SETZEN.
  MKPF-XBLNR = RM07M-LFSNR.
* Prüfung ERS-Verfahren
* only a ERS relevant purchase order should processing M7 245    "829147
 IF sy-xcode <> SPACE.                                           "829147
  CLEAR: XERSY.                                                  "829147
 ENDIF.                                                          "829147
  IF MKPF-XBLNR IS INITIAL AND NOT XERSY IS INITIAL.
    PERFORM NACHRICHTENCODE_ERMITTELN(SAPFM07M) USING 'M7' '245'. "ok
  ENDIF.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM BUCHUNGSKREIS_TESTEN
*---------------------------------------------------------------------*
*       Nur prüfen, wenn kein Umlagervorgang, der nur Bestands-       *
*       buchungen bewirkt.                                            *
*       Buchung nur zulässig wenn:                                    *
*         - gleiche Währung                                           *
*         - gleicher Kontenplan                                       *
*         - gleiches Geschäftsjahresende                              *
*       Fehlermeldung entweder mit: 'anderes Werk' oder               *
*                                   'anderer Buchungskreis'           *
*---------------------------------------------------------------------*
FORM BUCHUNGSKREIS_TESTEN.

  CHECK MSEG-UMWRK IS INITIAL AND MSEG-XAUTO IS INITIAL.
  CHECK NOT MSEG-PARBU IS INITIAL OR NOT RM07M-BUKRS IS INITIAL.
  CHECK NOT KM07R-WAERS IS INITIAL.
  CHECK MSEG-BWART NE BWART_341.
  CHECK MSEG-BWART NE BWART_342.
  IF KM07R-KTOPL NE T001-KTOPL.
    MESSAGE E513 WITH TEXT-020.
  ENDIF.
  IF T001-WAERS NE KM07R-WAERS.
    PERFORM NACO_ERMITTELN_V1(SAPFM07M) USING 'M7' '514' text-020.
  ENDIF.
  IF KM07R-PERIV NE T001-PERIV.
    MESSAGE E515 WITH TEXT-020.
  ENDIF.

ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM   BWART_WA                                               *
*---------------------------------------------------------------------*
*       Die Bewegungsart wird für WA's gesetzt.                       *
*---------------------------------------------------------------------*
FORM BWART_WA.
  CLEAR OK-CODE.
  IF NOT ANF_BILD IS INITIAL AND NOT BCODE-BWART IS INITIAL.
    RM07M-BWARTWA = BCODE-BWART.
    RM07M-SOBKZ   = BCODE-SOBKZ.
    CLEAR: BCODE-BWART, BCODE-SOBKZ.
    IF NOT T063O-BWART IS INITIAL.
      MESSAGE W015.
    ENDIF.
  ENDIF.
  IF RM07M-BWARTWA IS INITIAL.
    RM07M-BWART = BCODE-BWART.
    IF RM07M-SOBKZ IS INITIAL.
      RM07M-SOBKZ = BCODE-SOBKZ.
    ENDIF.
  ELSE.
    RM07M-BWART = RM07M-BWARTWA.
  ENDIF.
  IF CCODE IS INITIAL.
    PERFORM BEWEGUNGSART_LESEN(SAPFM07M) USING RM07M-BWART.
    IF NOT T156-KZBWA IS INITIAL.
ENHANCEMENT-POINT BWART_WA_01 SPOTS ES_SAPMM07M.
* Bei UmlagBest und Lohnbearb. KZBWA =/ 0, SOBKZ aus der Bestellung
* Begin note 663537
*\      CLEAR RM07M-SOBKZ.
      DATA: l_cons_hnd TYPE WRF_CONS_HND. "Konsi-Abwicklung
      IF NOT tcurm IS INITIAL.
        l_cons_hnd = tcurm-cons_hnd.
      ELSE.
* Ermittele TCURM-CONS_HND
        SELECT SINGLE CONS_HND INTO l_cons_hnd FROM TCURM.
        IF NOT sy-subrc IS INITIAL.
          CLEAR l_cons_hnd.
        ENDIF.
      ENDIF.
      IF NOT ( T156-KZBWA = KZBWA-SZ AND RM07M-SOBKZ = K AND
               NOT l_cons_hnd IS INITIAL ).
        CLEAR RM07M-SOBKZ.
      ENDIF.
* end note 663537
      IF XKZBW IS INITIAL.
* Note 423971:
* For movement type 351 we send a popup to enter the PO in MB1B.
* This is controlled by the entry 351 in T063O. With release 4.6 it
* is possible to copy 351 to 9xx, so we need to work with T156-BUSTR.
        SELECT SINGLE * FROM T063O WHERE OK_CODE = T156-BUSTR.  "423971
        IF SY-SUBRC IS INITIAL.
          IF NOT T063O-CCODE IS INITIAL.
            SELECT SINGLE * FROM T063C WHERE CCODE = T063O-CCODE.
            IF SY-SUBRC IS INITIAL.
              CCODE      = T063C-CCODE.
              FCODE_NEXT = T063O-FCODE.
            ENDIF.
          ENDIF.
        ENDIF.
      ELSE.
        IF XKZBW = N AND T156-KZBWA NE KZBWA-02.
          MESSAGE E019 WITH RM07M-BWART RM07M-SOBKZ.
        ENDIF.
      ENDIF.
    ELSE.
      IF XKZBW = X.
        MESSAGE E019 WITH RM07M-BWART RM07M-SOBKZ.
      ENDIF.
    ENDIF.
  ELSE.
    IF NOT RM07M-BWART IS INITIAL.
      IF CCODE = CCOD-NFUL.
        PERFORM BEWEGUNGSART_LESEN(SAPFM07M) USING RM07M-BWART.
        IF T156-KZBWA IS INITIAL.
          MESSAGE E019 WITH RM07M-BWART RM07M-SOBKZ.
        ENDIF.
      ELSEIF CCODE = CCOD-NFSL.
        PERFORM BEWEGUNGSART_LESEN(SAPFM07M) USING RM07M-BWART.
        IF NOT T156-KZBWA IS INITIAL AND T156-KZBWA NE KZBWA-02.
          MESSAGE E019 WITH RM07M-BWART RM07M-SOBKZ.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
  IF NOT T063C-AUFRUF IS INITIAL.
    BCODE-BWART = RM07M-BWARTWA.
    BCODE-SOBKZ = RM07M-SOBKZ.
  ENDIF.
  SET PARAMETER ID 'BWA' FIELD RM07M-BWARTWA.
ENDFORM.
*eject
*---------------------------------------------------------------------*
*       FORM   BWART_WE                                               *
*---------------------------------------------------------------------*
*       Die Bewegungsart wird für WE's gesetzt.                       *
*---------------------------------------------------------------------*
FORM BWART_WE.
  CLEAR OK-CODE.
  IF NOT ANF_BILD IS INITIAL AND NOT BCODE-BWART IS INITIAL.
    RM07M-BWARTWE = BCODE-BWART.
    CLEAR: BCODE-BWART.
    IF T063C-AUFRUF IS INITIAL.
      MESSAGE W015.
    ENDIF.
  ENDIF.
  IF RM07M-BWARTWE IS INITIAL.
    RM07M-BWART = BCODE-BWART.
    RM07M-SOBKZ = BCODE-SOBKZ.
  ELSE.
    RM07M-BWART = RM07M-BWARTWE.
  ENDIF.
  IF CCODE IS INITIAL.
    PERFORM BEWEGUNGSART_LESEN(SAPFM07M) USING RM07M-BWART.
  ELSE.
    BCODE-BWART = RM07M-BWARTWE.
  ENDIF.
  SET PARAMETER ID 'BWE' FIELD RM07M-BWARTWE.
ENDFORM.
*eject