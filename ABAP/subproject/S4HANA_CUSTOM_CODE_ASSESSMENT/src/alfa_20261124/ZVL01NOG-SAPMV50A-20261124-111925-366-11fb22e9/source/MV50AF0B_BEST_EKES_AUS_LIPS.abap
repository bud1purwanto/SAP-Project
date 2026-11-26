*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BEST_EKES_AUS_LIPS                                *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BEST_EKES_AUS_LIPS                                       *
*---------------------------------------------------------------------*
*       Für eine Lieferavisposition wird die Bestellung via           *
*       EKES fortgeschrieben                                          *
*---------------------------------------------------------------------*
FORM BEST_EKES_AUS_LIPS USING LEP_VORGANG LIKE LIPSD-UPDKZ
                   IS_ENHANCEMENT TYPE ISU_BEST_EKES_AUS_LIPS."IS2ERP

  DATA: LF_LEP_VORGANG TYPE C.                              "IS2ERP

* SPE No EKES entries for temporary inbound deliveries
  READ TABLE XVBUK WITH KEY VBELN = XLIKP-VBELN.
  CHECK XVBUK-SPE_TMPID EQ SPACE.

  IF V50AGL-COMPLETE_DELIVERY NE SPACE.                     "v_n_1226602
    READ TABLE XVBAPF WITH KEY VBELN = XLIPS-VBELN
                               POSNR = XLIPS-POSNR
                      BINARY SEARCH.
   IF NOT SY-SUBRC IS INITIAL.                              "v_n_1595336
      CLEAR XVBAPF.
   ENDIF.                                                   "^_n_1595336
  ENDIF.                                                    "^_n_1226602


ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_06 SPOTS es_sapmv50a STATIC.

  CLEAR XUEKES.
  LF_LEP_VORGANG = LEP_VORGANG.

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_07 SPOTS es_sapmv50a.

  CLEAR XEKESU.                                             "713023
*
*  case lep_vorgang.
  CASE LF_LEP_VORGANG.                                      "IS2ERP
    WHEN UPDKZ_NEW.                    "Position wird hinzugefügt
      XUEKES-MANDT = XLIPS-MANDT.
      XUEKES-EBELN = XLIPS-VGBEL.
      XUEKES-EBELP = XLIPS-VGPOS.
      XUEKES-EINDT = XLIKP-LFDAT.
      XUEKES-LPEIN = '1'.
      XUEKES-UZEIT = XLIKP-LFUHR.
      XUEKES-ERDAT = XLIPS-ERDAT.
      XUEKES-EZEIT = XLIPS-ERZET.
      XUEKES-MENGE = XLIPS-LFIMG.

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_01 SPOTS es_sapmv50a.

      XUEKES-VBELN = XLIPS-VBELN.
      XUEKES-VBELP = XLIPS-POSNR.
      XUEKES-XBLNR = XLIKP-LIFEX.
      XUEKES-EMATN = XLIPS-EMATN.
      XUEKES-EKPOMEINS = XLIPS-VRKME.

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_02 SPOTS es_sapmv50a.

      XUEKES-CHARG = XLIPS-CHARG.
      XUEKES-UECHA = XLIPS-UECHA.
      XUEKES-WERKS = XLIPS-WERKS.                           "n_905551
      XUEKES-LGORT = XLIPS-LGORT.                           "n_905551

*     SPE 03.08.2005 Set the In yard indicator from the Delivery line item
      XUEKES-IMWRK = XLIPS-SPE_IMWRK.

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_08 SPOTS es_sapmv50a.

* Spezialfall: eine neu angelegte Chargensplittposition,  "v_n_666176
* die zugleich auch WE gebucht wurde, braucht zur Korrektur
* für die EKES/EKBE-Verbuchung die Materialbelegnummer und -position
* in der UEKES. Damit wird die ETENS korrekt fortgeschrieben.
      IF  NOT XLIPS-UECHA IS INITIAL AND
          NOT XLIPS-LFIMG IS INITIAL AND
        ( NOT XLIPS-LICHN IS INITIAL OR
          NOT XLIPS-CHARG IS INITIAL ) AND
              XLIPS-KCMENG IS INITIAL  AND
              XLIPS-XCHAR  EQ CHARX    AND
              XLIPS-XCHPF  EQ CHARX.
* neue Chargensplittposition
        READ TABLE XVBFA WITH KEY VBELV   = XLIPS-VBELN
                                  POSNV   = XLIPS-POSNR
                                  VBTYP_N = 'R'
                                  UPDKZ   = UPDKZ_NEW.
* es gibt dazu einen neuen WE-Satz
        IF SY-SUBRC = 0.
*          xuekes-belnr = xvbfa-vbeln.                       "713023
*          xuekes-belpo = xvbfa-posnn.                       "713023
          MOVE-CORRESPONDING XUEKES TO XEKESU.              "713023
          XEKESU-BELNR = XVBFA-VBELN.                       "713023
          XEKESU-BELPO = XVBFA-POSNN.                       "713023
          APPEND XEKESU.                                    "713023
        ENDIF.
      ENDIF.                                                "^_n_666176
    WHEN UPDKZ_UPDATE.                 "Position wurde verändert
      XUEKES-MANDT = XLIPS-MANDT.
      XUEKES-EBELN = XLIPS-VGBEL.
      XUEKES-EBELP = XLIPS-VGPOS.
      XUEKES-EINDT = XLIKP-LFDAT.
      XUEKES-LOEKZ = XLIKP-SPE_LOEKZ. "Copy delete indicator from the DLV
      XUEKES-LPEIN = '1'.
      XUEKES-UZEIT = XLIKP-LFUHR.
      XUEKES-ERDAT = XLIPS-ERDAT.
      XUEKES-EZEIT = XLIPS-ERZET.
*     If inbound delivery is completed through VL_COMPLETE set EKES quantity
*     to actual GR posted quantity                          "v_n_1226602
      IF V50AGL-COMPLETE_DELIVERY EQ SPACE.
        XUEKES-MENGE = XLIPS-LFIMG.
      ELSE.
        XUEKES-MENGE = XVBAPF-RMENGEV.
      ENDIF.                                                "^_n_1226602

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_03 SPOTS es_sapmv50a.

      XUEKES-VBELN = XLIPS-VBELN.
      XUEKES-VBELP = XLIPS-POSNR.
      XUEKES-XBLNR = XLIKP-LIFEX.
      XUEKES-EMATN = XLIPS-EMATN.
      XUEKES-EKPOMEINS = XLIPS-VRKME.

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_04 SPOTS es_sapmv50a.

      XUEKES-CHARG = XLIPS-CHARG.
      XUEKES-UECHA = XLIPS-UECHA.
      XUEKES-IMWRK = XLIKP-IMWRK.                           "n_605460
      XUEKES-WERKS = XLIPS-WERKS.                           "n_905551
      XUEKES-LGORT = XLIPS-LGORT.                           "n_905551

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_09 SPOTS es_sapmv50a.

    WHEN UPDKZ_DELETE.                 "Position wurde gelöscht
      XUEKES-MANDT = YLIPS-MANDT.
      XUEKES-EBELN = YLIPS-VGBEL.
      XUEKES-EBELP = YLIPS-VGPOS.
      XUEKES-EINDT = XLIKP-LFDAT.
      XUEKES-LPEIN = '1'.
      XUEKES-UZEIT = XLIKP-LFUHR.
      XUEKES-ERDAT = YLIPS-ERDAT.
      XUEKES-EZEIT = YLIPS-ERZET.
      XUEKES-MENGE = YLIPS-LFIMG.

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_05 SPOTS es_sapmv50a.

      XUEKES-VBELN = YLIPS-VBELN.
      XUEKES-VBELP = YLIPS-POSNR.
      XUEKES-XBLNR = XLIKP-LIFEX.
      XUEKES-EMATN = YLIPS-EMATN.                        "v_n_1229227
      XUEKES-CHARG = YLIPS-CHARG.
      XUEKES-UECHA = YLIPS-UECHA.                        "^_n_1229227
      XUEKES-IMWRK = XLIKP-IMWRK.                           "n_605460

ENHANCEMENT-POINT mv50af0b_best_ekes_aus_lips_10 SPOTS es_sapmv50a.
  ENDCASE.
* Fill up STO/SIT replenishment information into EKES    "v_n_1657162
  IF XLIKP-SPE_LIFEX_TYPE EQ GC_LIFEX_TYPE-STOCKTRANSFER.
    XUEKES-VBELN_ST = XLIKP-LIFEX.
    XUEKES-VBELP_ST = XLIPS-LIFEXPOS.
  ENDIF.                                                 "^_n_1657162

* update-kennzeichen wird in ELIKZ übergeben
  XUEKES-KZ    = LF_LEP_VORGANG.                            "IS2ERP
  APPEND XUEKES.
* conversion factors                                           "v457360
  CLEAR XEKES_CONV_QTY.

  XEKES_CONV_QTY-EBELN = XLIPS-VGBEL.
  XEKES_CONV_QTY-EBELP = XLIPS-VGPOS.
  XEKES_CONV_QTY-EINDT = XLIKP-LFDAT.
  XEKES_CONV_QTY-VBELN = XLIPS-VBELN.
  XEKES_CONV_QTY-VBELP = XLIPS-POSNR.
  IF ( XLIPS-UMVKZ = XLIPS-UMREZ AND                   "v566027 "611487
       XLIPS-UMVKN = XLIPS-UMREN ) OR XLIPS-KZFME CA 'AB'.  "611487
* same conversion factors
    XEKES_CONV_QTY-UMREZ = 1.
    XEKES_CONV_QTY-UMREN = 1.
  ELSEIF XLIPS-UMVKZ = 1 AND XLIPS-UMVKN = 1.
* base unit in delivery
    XEKES_CONV_QTY-UMREZ = XLIPS-UMREZ.
    XEKES_CONV_QTY-UMREN = XLIPS-UMREN.
  ELSEIF XLIPS-UMREZ = 1 AND XLIPS-UMREN = 1.
* base unit in purchase order
    XEKES_CONV_QTY-UMREZ = XLIPS-UMVKN.
    XEKES_CONV_QTY-UMREN = XLIPS-UMVKZ.
  ELSEIF XLIPS-UMVKN = 1 AND XLIPS-UMREN = 1.
* whole-numbered multiples
    XEKES_CONV_QTY-UMREZ = XLIPS-UMREZ.                     "589711
    XEKES_CONV_QTY-UMREN = XLIPS-UMVKZ.                     "589711
  ELSE.
    CALL FUNCTION 'ME_CONVERSION_MULTIPLY'                    "v_880756
      EXPORTING
        I_UMREN1       = XLIPS-UMVKN
        I_UMREN2       = XLIPS-UMREN
        I_UMREZ1       = XLIPS-UMVKZ
        I_UMREZ2       = XLIPS-UMREZ
      IMPORTING
        UMREN          = XEKES_CONV_QTY-UMREN
        UMREZ          = XEKES_CONV_QTY-UMREZ.                "^_880756
* lines deleted
  ENDIF.                                                    "^566027

  APPEND XEKES_CONV_QTY.                                    "^457360


ENDFORM.                    "BEST_EKES_AUS_LIPS