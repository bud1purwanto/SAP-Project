*eject
*---------------------------------------------------------------------*
*       MODULE BESTELLUNG_SUCHEN                                      *
*---------------------------------------------------------------------*
*       Selektion von Bestellungen entweder                           *
*       - direkt über Kriterien für Bestellpositionen (Material, EAN, *
*         Materialnr. Lieferant, etc. oder                            *
*       - indirekt über Vorgängerbelege wie Avis, Grob-WE oder        *
*         Umlagerlieferung                                            *
*---------------------------------------------------------------------*
MODULE BESTELLUNG_SUCHEN.

  IF CCODE = CCOD-NFBL OR CCODE = CCOD-NFBS OR
     CCODE = CCOD-NFML OR CCODE = CCOD-NFMS OR
     CCODE = CCOD-NFBU.
    EXIT.
  ENDIF.
  IF NOT XAKTIV IS INITIAL OR XKZBEW = 1.
    CLEAR XAKTIV.
    PERFORM SUCHFELDER_INIT.
    EXIT.
  ENDIF.
* Plausiprüfungen bzgl. Kombination der Selektionskriterien
  PERFORM BEST_SUCHEN_PLAUSIS.

  REFRESH VAR_FUSS.
* CLEAR: WUEB, XWUEB.                                       "note197073
  CLEAR: WUEB, XWUEB, XSPLIT.                               "note197073
  REFRESH: WUEB, XWUEB.
  WUEB-NRCFD = X.
  WUEB-CALKZ = X.
  EXPORT WUEB-CALKZ WUEB-NRCFD WUEB TO MEMORY ID 'WUEB'.
  DATA: EKORG LIKE EKKO-EKORG.
  CLEAR EKORG.
  SET PARAMETER ID 'EKO' FIELD EKORG.
  IF T158-KZBEW = O AND PSTYP IS INITIAL.
    CALL FUNCTION 'ME_ITEM_CATEGORY_OUTPUT'
         EXPORTING
              PSTYP = DREI
         IMPORTING
              EPSTP = PSTYP.
  ENDIF.
* Aufbau der Ranges, falls Bestellkriterien direkt eingegeben
  IF NOT ( AM07M-LIFNR IS INITIAL AND AM07M-MATNV IS INITIAL AND
           RM07M-EAN11 IS INITIAL AND RM07M-IDNLF IS INITIAL AND
           RM07M-EINDT IS INITIAL AND RM07M-EINDB IS INITIAL AND
           AM07M-RESWK IS INITIAL AND RM07M-WERKS IS INITIAL AND
           VM07M-PSTYP IS INITIAL ) .
    PERFORM BEST_SUCHEN_RANGES.
  ENDIF.

  CLEAR: X_AVIS, X_GROBWE, H_LIEFK.
  IF NOT RM07M-XVERS IS INITIAL.
* Selektion von Versandelementen
    PERFORM BEST_SUCHEN_VERSELEM.
* Lieferungen... (alte VL07)
    IF RM07M-LFSNR IS INITIAL AND MKPF-XBLNR IS INITIAL.
      RM07M-LFSNR = MKPF-XBLNR = RM07M-VBELN.
    ENDIF.
  ENDIF.
  IF RM07M-XVERS IS INITIAL AND
     NOT ( RM07M-VLIEF IS INITIAL AND RM07M-TRAID IS INITIAL AND
           RM07M-GWELF IS INITIAL AND RM07M-GWELS IS INITIAL AND
           RM07M-VBELN IS INITIAL AND RM07M-TKNUM IS INITIAL AND
           RM07M-PABNUM IS INITIAL ).
* Selektion von Vorgängerbelegen
    IF NOT RM07M-VBELN IS INITIAL.
* Lieferungen... (alte VL07)
      PERFORM BEST_SUCHEN_LIEF.
      IF RM07M-LFSNR IS INITIAL AND MKPF-XBLNR IS INITIAL.
        RM07M-LFSNR = MKPF-XBLNR = RM07M-VBELN.
      ENDIF.
    ENDIF.
    IF NOT RM07M-VLIEF IS INITIAL OR NOT RM07M-TRAID IS INITIAL OR
       NOT RM07M-TKNUM IS INITIAL.
* Lieferavise
      PERFORM BEST_SUCHEN_AVIS.
    ENDIF.
    IF NOT RM07M-GWELF IS INITIAL OR NOT RM07M-GWELS IS INITIAL.
* Grob-WE
      PERFORM BEST_SUCHEN_GROBWE.
    ENDIF.
* Abrufnummer Kanban
    IF NOT RM07M-PABNUM IS INITIAL.
      PERFORM BEST_SUCHEN_PABNUM.
    ENDIF.
  ENDIF.
* Bestellkriterien
  IF RM07M-XVERS IS INITIAL AND
     ( RM07M-VLIEF IS INITIAL AND RM07M-TRAID IS INITIAL AND
       RM07M-GWELF IS INITIAL AND RM07M-GWELS IS INITIAL AND
       RM07M-VBELN IS INITIAL AND RM07M-TKNUM IS INITIAL AND
       RM07M-PABNUM IS INITIAL ).
    PERFORM BEST_SUCHEN_BEST.
  ENDIF.

* RESWK = AM07M-RESWK.
* VLIEF = RM07M-VLIEF.
* VBELP = RM07M-VBELP.
* H_GWELF = RM07M-GWELF.
* PERFORM SUCHFELDER_INIT.
* RM07M-VLIEF = VLIEF.
* RM07M-VBELP = VBELP.
* RM07M-GWELF = H_GWELF.
* AM07M-RESWK = RESWK.
  DATA: OLD_FRBNR LIKE WUEB-FRBNR_AVIS,
        OLD_XBLNR LIKE WUEB-XBLNR_AVIS.
* bei Versandeinheiten erfolgt Abarbeitung von XVEPWE; ansonsten WUEB
  IF NOT RM07M-XVERS IS INITIAL.
    DESCRIBE TABLE XVEPWE LINES INDEX_Z.
    IF INDEX_Z IS INITIAL.
      MESSAGE E083.
    ENDIF.
    LOOP AT XVEPWE.
      IF NOT XVEPWE-EBELN IS INITIAL.
        RM07M-EBELN = XVEPWE-EBELN.
        RM07M-EBELP = XVEPWE-EBELP.
* H_LIEFK soll nur bei der Suche über eine Anlieferung,
* NICHT jedoch bei der Suche über eine Auslieferung gesetzt werden
        IF X_AVIS = X OR X_GROBWE = X.                     "note 197073
          H_LIEFK = XVEPWE-VBELN.
        ENDIF.                                             "note 197073
        IF NOT RM07M-VLIEF IS INITIAL AND WUEB IS INITIAL.      "676853
          H_LIEFK = XVEPWE-VBELN.                               "676853
          RM07M-VBELP = XVEPWE-POSNR.                           "676853
        ENDIF.                                                  "676853
        H_VEMNG = XVEPWE-VEMNG.
        H_VEMEH = XVEPWE-VEMEH.                            "note 388707
        H_CHARG = XVEPWE-CHARG.                            "note 388707
        PERFORM STEUERFLAGS_INITIALISIEREN(SAPFM07M).
        IF T158-KZBEW IS INITIAL.
          IF T156-KZBWA = KZBWA-02.
            PERFORM BESTELLUNG_WA_LB_POP.
          ELSE.
            PERFORM BESTELLUNG_WA_POP.
          ENDIF.
        ELSE.
          IF NOT ANF_BILD IS INITIAL.
            PERFORM FCODE_LESEN USING FCODE.
          ENDIF.
          PERFORM FUSSZEILE_WE
                               USING LS_ISU_FUSSZEILE_WE. "IS2ERP.
          PERFORM FUSSZEILE_WE_NEU.
        ENDIF.
      ELSE.
* Versandelement ohne zugehörige Bestellposition
        REFRESH WUEB.
        CALL FUNCTION 'SD_DELIVERY_ITEMS_RECEIVE'
             EXPORTING
                  VBELN = XVEPWE-VBELN
                  POSNR = XVEPWE-POSNR
                  WERKS = RM07M-WERKS
                  IF_LOCK = 'X'                   "435772
                  TABLES
                  WUEB  = WUEB
             EXCEPTIONS
                  NO_DELIVERY            = 1
                  DELIVERY_NOT_SUITABLE  = 2
                  DELIVERY_NOT_POSTED_GI = 3
                  NO_ITEMS_RECEIVING     = 4
                  NO_RECEIVING_PLANT     = 5
                  NO_DELIVERY_ITEM       = 6
                  NO_MOVEMENT_TYPE       = 7      "435772
                  DELIVERY_LOCKED        = 8.
        IF NOT SY-SUBRC IS INITIAL.
          SET CURSOR FIELD 'RM07M-VBELN'.
          MESSAGE E865 WITH RM07M-VBELN SY-SUBRC.
        ENDIF.
        READ TABLE WUEB INDEX 1.
        IF SY-SUBRC IS INITIAL.
          WUEB-ERFMG = XVEPWE-VEMNG.
          WUEB-ERFME = XVEPWE-VEMEH.
          PERFORM FUSSZEILE_WL_NEU.
        ENDIF.
      ENDIF.
    ENDLOOP.
* im Falle von Versandeinheiten kann in einem Schritt die gleiche
* Bestellposition in mehreren Teilmengen übernommen werden; es erfolgt
* dann eine Mengenkorrelation bei Leergut, da die FBSt des Einkauf
* sonst immer die komplette Menge übermitteln
    DATA: H_MENGE LIKE MSEG-ERFMG,
          H_BSMNG LIKE DM07M-BSMNG,
          H_ZEILE LIKE MSEG-ZEILE.
    LOOP AT FUSS.
      IF NOT FUSS-UPVOR IS INITIAL.
        H_MENGE = FUSS-ERFMG.
        H_BSMNG = FUSS-BSMNG.
        H_ZEILE = FUSS-ZEILE.
      ENDIF.
      IF FUSS-MEKOR = X AND
        FUSS-URZEI = H_ZEILE.
        FUSS-ERFMG = H_MENGE * FUSS-BSMNG / H_BSMNG.
        MODIFY FUSS.
      ENDIF.
    ENDLOOP.
  ELSE.
* Abarbeiten von WUEB
    DESCRIBE TABLE WUEB LINES INDEX_Z.
    IF INDEX_Z IS INITIAL.
      PERFORM AUSNAHME_BEARBEITEN.
      EXIT.
    ENDIF.
    LOOP AT WUEB.
      IF NOT WUEB-EBELN IS INITIAL.
        RM07M-EBELN = WUEB-EBELN.
        RM07M-EBELP = WUEB-EBELP.
        clear: rm07m-vbelp.                                      "734411
* Unterschiedliche Frachtbriefe/XBLNR aus WUEB?
        IF NOT WUEB-FRBNR_AVIS = OLD_FRBNR.
          IF OLD_FRBNR IS INITIAL.
            MOVE WUEB-FRBNR_AVIS TO OLD_FRBNR.
          ELSE.
            MULTI_FRBNR = X.
          ENDIF.
        ENDIF.
        IF NOT WUEB-XBLNR_AVIS = OLD_XBLNR.
          IF OLD_XBLNR IS INITIAL.
            MOVE WUEB-XBLNR_AVIS TO OLD_XBLNR.
          ELSE.
            MULTI_XBLNR = X.
          ENDIF.
        ENDIF.
*
        IF NOT X_AVIS IS INITIAL.
          IF RM07M-VLIEF IS INITIAL.
            H_LIEFK = WUEB-VBELN.
          ELSE.
            H_LIEFK = RM07M-VLIEF.
          ENDIF.
* rm07m-vbelp must not be changed in case of tied empties       "563110
          if not wueb-vbelp is initial                          "457797
            and wueb-upvor <> 3.                                "563110
            rm07m-vbelp = wueb-vbelp.                           "457797
          endif.                                                "457797
        ENDIF.
        IF NOT X_GROBWE IS INITIAL.
          IF RM07M-GWELF IS INITIAL.
            H_LIEFK = WUEB-VBELN.
          ELSE.
            H_LIEFK = RM07M-GWELF.
          ENDIF.
        ENDIF.
        PERFORM STEUERFLAGS_INITIALISIEREN(SAPFM07M).
        IF T158-KZBEW IS INITIAL.
          IF T156-KZBWA = KZBWA-02.
            PERFORM BESTELLUNG_WA_LB_POP.
          ELSE.
            PERFORM BESTELLUNG_WA_POP.
          ENDIF.
        ELSE.
* Leergutzeilen werden immer eliminiert, da später durch ME_READ_
* ITEM_GOODS_RECEIPT nochmal erzeugt; VAS subitems analog
          IF WUEB-UPTYP = UPTYP_LG AND
             NOT WUEB-UEBPO IS INITIAL  or
             wueb-uptyp = uptyp_vas.
             CHECK 1 = 2.
          ENDIF.
* Chargensplitpositionen in der Anlieferung werden in WUEB "note 314598
* eliminiert, da sie vom FB ME_READ_ITEM_GOODS_RECEIPT     "note 314598
* über die Hauptposition selektiert werden                 "note 314598
          IF ( X_AVIS = X OR X_GROBWE = X ) AND            "note 314598
             NOT WUEB-UECHA IS INITIAL.                    "note 314598
             CHECK 1 = 2.                                  "note 314598
          ENDIF.                                           "note 314598
          PERFORM FUSSZEILE_WE
                               USING LS_ISU_FUSSZEILE_WE. "IS2ERP.
          PERFORM FUSSZEILE_WE_NEU.
        ENDIF.
      ELSE.
* hier Positionen aus Lieferschein ohne zugehörige Umlagerbestellung...
* Änderung am 15.07.96...
        PERFORM FUSSZEILE_WL_NEU.
      ENDIF.
    ENDLOOP.
  ENDIF.
* Lieferschein übernehmen, wenn eindeutig und nicht manuell
  IF RM07M-LFSNR IS INITIAL AND MKPF-XBLNR IS INITIAL.
    IF NOT OLD_XBLNR IS INITIAL AND MULTI_XBLNR IS INITIAL.
      RM07M-LFSNR = MKPF-XBLNR = OLD_XBLNR.
      AUTO_XBLNR = X.
    ENDIF.
  ELSE.
    IF ( RM07M-LFSNR NE OLD_XBLNR OR MKPF-XBLNR NE OLD_XBLNR ) AND
       NOT AUTO_XBLNR IS INITIAL.
      CLEAR: RM07M-LFSNR, MKPF-XBLNR.
      MULTI_XBLNR = X.
    ENDIF.
  ENDIF.
* Frachtbrief übernehmen, wenn eindeutig und nicht manuell
  IF MKPF-FRBNR IS INITIAL.
    IF NOT OLD_FRBNR IS INITIAL AND MULTI_FRBNR IS INITIAL.
      MKPF-FRBNR = OLD_FRBNR.
      AUTO_FRBNR = X.
    ENDIF.
  ELSE.
    IF MKPF-FRBNR NE OLD_FRBNR AND NOT AUTO_FRBNR IS INITIAL.
      CLEAR MKPF-FRBNR.
      MULTI_FRBNR = X.
    ENDIF.
  ENDIF.

*perform j_1b_im_tf_check.             "Localization Brazil

  CLEAR: RM07M-EBELN,
         RM07M-EBELP,
         RM07M-VLIEF,
         RM07M-VBELN,
         RM07M-VBELP,
         RM07M-GWELF,
         RM07M-GWELS,
         RM07M-XVERS,
         RM07M-TKNUM,
         RM07M-PABNUM,
         AM07M-RESWK,
         H_LIEFK.
  CLEAR ZWUEB.
ENDMODULE.