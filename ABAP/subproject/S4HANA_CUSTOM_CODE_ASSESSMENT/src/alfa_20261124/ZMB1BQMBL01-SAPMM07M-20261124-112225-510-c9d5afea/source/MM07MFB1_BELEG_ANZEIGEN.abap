*---------------------------------------------------------------------*
*       FORM BELEG_ANZEIGEN                                           *
*---------------------------------------------------------------------*
*       Module for exit-command                                       *
*---------------------------------------------------------------------*
FORM BELEG_ANZEIGEN USING B-TABIX LIKE SY-TABIX.
  FIELD-SYMBOLS: <FUSS>  LIKE FUSS.

  IF NOT DM07M-XEXIT IS INITIAL.
    MESSAGE A061.
  ENDIF.

* Item with QM-data has been sacked on detail screen
  IF NOT mseg-zeile IS INITIAL.
    READ TABLE ymseg WITH KEY zeile = mseg-zeile.
    IF NOT sy-subrc IS INITIAL.
    CALL FUNCTION 'QAAT_CANCEL_MATERIAL_DOC_ITEM'
         EXPORTING
              I_ZEILE = mseg-zeile.
    ENDIF.
  ENDIF.

* has a position with existing serial numbers been sacked?
  IF NOT DM07M-ANZSN  IS INITIAL AND                        "note388608
*     NOT FCAUSW-XLIST IS INITIAL AND                       "note869791
     NOT MSEG-MATNR IS INITIAL.                             "note459682
    READ TABLE YMSEG WITH KEY ZEILE = MSEG-ZEILE.           "note388608
    IF NOT SY-SUBRC IS INITIAL.                             "note388608
      MESSAGE A175.                                         "note388608
    ENDIF.                                                  "note388608
  ENDIF.                                                    "note388608
  IF OK-CODE IS INITIAL.
    IF NOT ANF_BILD IS INITIAL.
      IF SY-CALLD IS INITIAL.
        SET SCREEN 0.
        LEAVE SCREEN.
      ELSE.
        LEAVE.
      ENDIF.
    ELSE.
      ABBRUCH = X.
    ENDIF.
    FREE BIWE.
    FREE BILD.
    IF FCAUSW-XNEUP IS INITIAL AND FCAUSW-XAENP IS INITIAL AND
       FCAUSW-XSELP IS INITIAL AND NOT FCAUSW-XLIST IS INITIAL.
      PERFORM TRANSAKTION_VERLASSEN.
      CASE CONFIRM.
        WHEN N.
          IF SY-CALLD IS INITIAL.
            LEAVE TO TRANSACTION TCODE.
          ELSE.
            LEAVE.
          ENDIF.
        WHEN J.
          FCODE_NEXT = FCOD-BU.
      ENDCASE.
    ELSE.
      IF NOT FCAUSW-XSELP IS INITIAL.
        PERFORM AUSWAHL_PRUEFEN.
        IF RC = 4.
          CLEAR CONFIRM.
          CLEAR RC.
          A_ZEILE = 1.
          EXIT.
        ENDIF.
     ELSEIF NOT FCAUSW-XBEAP IS INITIAL AND FCAUSW-XLIST IS INITIAL AND
         ( NOT FCAUSW-XNEUP IS INITIAL OR NOT FCAUSW-XAENP IS INITIAL ).
        CALL FUNCTION 'L_IM_DEQUEUE'
          EXPORTING
            LEIT   = X
            GEGEN  = X
            UMBU1  = X
            UMBU2  = X
          EXCEPTIONS
            OTHERS = 1.
        CALL FUNCTION 'MB_MODIFY_STOCK_ENQUEUE_ENTRY'
          EXPORTING
            XNEUP = FCAUSW-XNEUP
            XAENP = FCAUSW-XAENP
            MBEQU = TCURM-MBEQU
            BASMG = DM07M-VMENG
            BASWR = DM07M-VVKWR
            MSEG  = MSEG
            VM07M = VM07M
          TABLES
            X156M = X156M
            X156W = X156W
            XMCHB = XMCHB
          CHANGING
            DM07M = DM07M.
      ENDIF.
* F12 for a subcontracting component in subsequent adjustment MB04
* => we have to delete all components for that PO item. This is
*    standard behavior since 4.0A (described in note 35882)
* Note 382705: to recognize a component, do not compare ZEILE and
* URZEI here as ZEILE refers to FUSS/YMSEG (0001 for the 1st component)
* and URZEI refers to OMSEG (0001 for first PO item).
* In MB04 ZEILE and URZEI are only correct after BUCHEN_INITIALISIEREN,
* where we merge OMSEG and YMSEG to ZMSEG and renumber all lines.
* Before 4.6C we use MSEG-KZBEW=space to recognize the components before
* BUCHEN_INITIALISIEREN. In 4.6C we may now use LINE_ID/PARENT_ID.
      IF T158-KZBEW = O AND MSEG-LINE_ID <> MSEG-PARENT_ID  "382705
         AND AKTYP = H.                                     "382705
*      Change components that have not been processed yet
        CLEAR FUSS-XSELK.                                   "0438401
        MODIFY FUSS TRANSPORTING XSELK                      "0438401
                    WHERE URZEI = MSEG-URZEI.               "0438401
*      Change components that have already been processed and put them
*      back to fuss with KP to be deleted in SEGMENT_SCHREIBEN. It is
*      not possible to change main item as it is not in YMSEG but OMSEG.
*      OMSEG gets no XAUTO=D otherwise problems in BUCHEN_INITIALISIEREN
        LOOP AT YMSEG WHERE URZEI = MSEG-URZEI.
*        Read YDM07M and YVM07M as well because needed for FUSS
          READ TABLE YDM07M INDEX YMSEG-ZEILE.
          IF SY-SUBRC <> 0.
            MESSAGE E001 WITH 'YDM07M' YMSEG-ZEILE.
          ENDIF.
          READ TABLE YVM07M INDEX YMSEG-ZEILE.
          IF SY-SUBRC <> 0.
            MESSAGE E001 WITH 'YVM07M' YMSEG-ZEILE.
          ENDIF.
*        Set exit flag
          YDM07M-XEXIT = X.
*        Put item back to FUSS with XAUTO and KP
          CLEAR FUSS.
          MOVE-CORRESPONDING YDM07M TO FUSS.
          MOVE-CORRESPONDING YVM07M TO FUSS.
          MOVE-CORRESPONDING YMSEG TO FUSS.
          FUSS-ERFMG = 0.
          FUSS-MENGE = 0.
          FUSS-BPMNG = 0.
          FUSS-BSTMG = 0.
          FUSS-ELIKZ = FUSS-ELIKZ_OLD.
          FUSS-XSELK = X.
          FUSS-XSELP = X.
          FUSS-XSELS = X.
          FUSS-XPRUE = X.
          FUSS-TABIX = B-TABIX.
          FUSS-FCODE = FCOD-KP.
          FUSS-XAUTO = D.
          APPEND FUSS.
        ENDLOOP.
* F12 on subcontracting component or struct. article in MB01
      ELSEIF ( ( VM07M-PSTYP = DREI AND AKTYP = H ) OR
         NOT MSEG-XAUTO IS INITIAL ) AND
         NOT MSEG-ZEILE = MSEG-URZEI AND NOT MSEG-URZEI IS INITIAL
                                     AND NOT MSEG-ZEILE IS INITIAL
*        XAUTO=D not allowed, if enqueue tables already filled  "366681
         AND FCAUSW-XBUCH IS INITIAL.                       "366681
*       Find main item in YMSEG
        A_ZEILE = MSEG-URZEI.
        PERFORM SEGMENT_LESEN USING SPACE.
        IF NOT RC IS INITIAL.
          MESSAGE A001 WITH 'YMSEG, YVM07M, YDM07M' A_ZEILE.
        ENDIF.
*       set exit flag in main item as all components will be deleted
        IF FCODE = FCOD-NP.
          YDM07M-XEXIT = DM07M-XEXIT = X.
        ENDIF.
        IF AKTYP = H AND YMSEG-XAUTO IS INITIAL.
          YMSEG-XAUTO = D.
          YMSEG-ELIKZ = VM07M-ELIKZ_OLD.
          MODIFY YMSEG INDEX YMSEG-ZEILE.
        ENDIF.
        OMSEG = YMSEG.
        OVM07M = YVM07M.
        ODM07M = YDM07M.
*       Now it gets tricky: the related components will be deleted from
*       FUSS as there is no append to FUSS. The main item will be put
*       back to FUSS through YFUSS with correction mode KP. Items that
*       are not related will be saved in ZFUSS and put again in FUSS
*       in the right order.
*       The FUSS counter has to be reduced by current line
        REFRESH: YFUSS, ZFUSS.
        LOOP AT FUSS assigning <fuss>.
          IF MSEG-URZEI = <FUSS>-URZEI.
            IF <FUSS>-FCODE = FCOD-NP.
              F_ZEILE = F_ZEILE - 1.
              S_ZEILE = S_ZEILE - 1.
            ENDIF.
          ELSE.
            ZFUSS = <FUSS>.
            APPEND ZFUSS.
          ENDIF.
        ENDLOOP.
        IF AKTYP <> V.                                     "note 426528
*         don't reset erfmg in MB02! (dm07m-urvermg = 0)   "note 426528
          YMSEG-ERFMG = DM07M-URVERMG.
        ENDIF.                                             "note 426528
        CLEAR YFUSS.
        MOVE-CORRESPONDING YDM07M TO YFUSS.
        MOVE-CORRESPONDING YVM07M TO YFUSS.
        MOVE-CORRESPONDING YMSEG TO YFUSS.
*       Set quantities to zero only if main item will be deleted
        IF AKTYP = H AND YMSEG-XAUTO = D.
          YFUSS-ERFMG = 0.
          YFUSS-MENGE = 0.
          YFUSS-BPMNG = 0.
          YFUSS-BSTMG = 0.
          YFUSS-ELIKZ = YVM07M-ELIKZ_OLD.
        ENDIF.
        YFUSS-XSELK = X.
        YFUSS-XSELP = X.
        YFUSS-XPRUE = X.
        YFUSS-TABIX = B-TABIX.
        YFUSS-FCODE = FCOD-KP.
        APPEND YFUSS.
        MODIFY YDM07M INDEX YDM07M-ZEILD.
        REFRESH FUSS.
        LOOP AT YFUSS.
          FUSS = YFUSS.
          APPEND FUSS.
        ENDLOOP.
        LOOP AT ZFUSS.
          FUSS = ZFUSS.
          APPEND FUSS.
        ENDLOOP.
        FREE: YFUSS, ZFUSS.
      ENDIF.
* Here common code again
      CHECK XMBWL IS INITIAL.
      DESCRIBE TABLE FUSS LINES INDEX_Z.
      IF FCAUSW-XLIST IS INITIAL OR FCAUSW-XNEUP IS INITIAL
         OR INDEX_Z IS INITIAL.
        IF FCODE_NEXT = ECODE AND INDEX_Z IS INITIAL.
          FCODE_NEXT  = FCOD-AB.
          CLEAR XSELE.
          AUFSETZEN_1 = 1.
          F_ZEILE     = 0.
          REFRESH: FUSS, VAR_FUSS.
          FREE YLGORT.
        ELSE.
* Current item will be deleted. So set back fuss line number.
* URZEI may not be changed in FUSS in case of subsequent adjustment
* as FUSS has no main items. They are all in OMSEG only.
*  das Abbrechen zu einem Sammelartikel erzwingt das Löschen
*  seiner Variantenpositionen aus var_fuss
          IF FUSS-ATTYP = ATTYP-SAM.
            LOOP AT VAR_FUSS WHERE KOPF_ZEILE = FUSS-ZEILE.
              DELETE VAR_FUSS.
            ENDLOOP.
          ENDIF.
          LOOP AT FUSS WHERE NOT FCODE = FCOD-KP.
*  das Abbrechen zu einer Variante eines Sammelartikel erzwingt
*  das Herunterzählen auch der kopf_zeile in var_fuss
            IF FUSS-ATTYP = ATTYP-SAM.
              LOOP AT VAR_FUSS WHERE KOPF_ZEILE = FUSS-ZEILE.
                VAR_FUSS-KOPF_ZEILE = VAR_FUSS-KOPF_ZEILE - 1.
                MODIFY VAR_FUSS.
              ENDLOOP.
            ENDIF.
            FUSS-ZEILE = FUSS-ZEILE - 1.
*  Referenzen wie urzei dürfen zur aktuellen Variante nicht
*  mehr geändert werden, da der SA unverändert bleibt
            IF NOT FUSS-URZEI IS INITIAL AND T158-KZBEW <> O
               AND NOT FUSS-ATTYP = ATTYP-VAR.
              FUSS-URZEI = FUSS-URZEI - 1.
            ENDIF.
            MODIFY FUSS.
          ENDLOOP.
          LOOP AT YLGORT WHERE NOT XSELP IS INITIAL
                         AND   NOT ZEILE IS INITIAL.
            READ TABLE FUSS INDEX 1.
            FUSS-ZEILE = YLGORT-ZEILE.
            MODIFY FUSS INDEX 1.
            EXIT.
          ENDLOOP.
          READ TABLE FUSS INDEX 1.
          IF NOT SY-SUBRC IS INITIAL.
            FCODE_NEXT = FCOD-AB.
            CLEAR XSELE.
            CLEAR VW.
            AUFSETZEN_1 = 1.
            F_ZEILE     = 0.
            FREE YLGORT.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
    IF FCODE_NEXT = FCOD-BU.
      FCODE_NEXT = FCOD-AB.
    ENDIF.
    PERFORM FCODE_PRUEFEN.
    PERFORM DYNPRO_VORBEREITEN.
    PERFORM FCODE_BEARBEITEN.
    LEAVE SCREEN.
  ELSE.
    PERFORM OK-CODE_PRUEFEN.
    CLEAR OK-CODE.
  ENDIF.

ENDFORM.                    "BELEG_ANZEIGEN