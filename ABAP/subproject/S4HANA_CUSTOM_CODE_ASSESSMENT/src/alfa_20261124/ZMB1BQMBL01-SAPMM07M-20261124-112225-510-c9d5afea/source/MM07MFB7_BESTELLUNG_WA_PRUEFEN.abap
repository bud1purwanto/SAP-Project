*eject
*---------------------------------------------------------------------*
*       FORM   BESTELLUNG_WA_PRUEFEN                                  *
*---------------------------------------------------------------------*
*       Die Bestellung wird für den Warenausgang zur Umlagerbestel-   *
*       lung gelesen.                                                 *
*---------------------------------------------------------------------*
  FORM BESTELLUNG_WA_PRUEFEN USING B-EBELN LIKE MSEG-EBELN
                                   B-EBELP LIKE MSEG-EBELP
                                   B-WERKS LIKE MSEG-WERKS
                                   B-LFSCH TYPE C.
    CLEAR VW.
    DATA: E_XSTOR   LIKE VM07M-XSTOR. CLEAR E_XSTOR.
    IF FCODE = FCOD-ST OR FCODE = FCOD-SS.
      E_XSTOR = X.
    ENDIF.

    STATICS: RC_KBEFU LIKE SY-SUBRC.

* begin of note 167017
    IF NOT KBEFU-EBELN = B-EBELN OR NOT RC_KBEFU IS INITIAL.
      CALL FUNCTION 'ME_READ_HEADER_GOODS_RECEIPT'
           EXPORTING
                EBELN      = B-EBELN
                DISPLAY    = VW
           IMPORTING
                KBEFU      = KBEFU
           EXCEPTIONS
                NOT_ACTIV  = 01
                NOT_FOUND  = 02
                WRONG_TYPE = 03.
      RC_KBEFU = SY-SUBRC.

      IF T158-TRTYP = H.               "Transaktion type = Add
        IF NOT RC_KBEFU IS INITIAL.
          CASE RC_KBEFU.
            WHEN 1.
              PERFORM NACO_ERMITTELN_V4(SAPFM07M) USING 'M7' '031'
                      B-EBELN KBEFU-LOEKZ SPACE SPACE.
            WHEN 2.
              MESSAGE E030 WITH B-EBELN.
            WHEN 3.
              MESSAGE E032 WITH B-EBELN.
            WHEN OTHERS.
              MESSAGE E030 WITH B-EBELN.
          ENDCASE.
        ENDIF.

*Conversion between currencies necessary and possible ?
        IF NOT KBEFU-BWAER = MSEG-WAERS
           AND NOT MSEG-WAERS IS INITIAL
           AND NOT KBEFU-BWAER IS INITIAL.
          CALL FUNCTION 'FI_TYPE_OF_RATE_CHECK'
               EXPORTING
                    I_BLART = MKPF-BLART
                    I_KURST = T003-KURST
                    I_WAERS = KBEFU-BWAER
                    I_HWAER = MSEG-WAERS.
        ENDIF.
      ENDIF.
    ENDIF.                             "End of note 167017
ENHANCEMENT-POINT BESTELLUNG_WA_PRUEFEN_02 SPOTS ES_SAPMM07M.


ENHANCEMENT-SECTION     BESTELLUNG_WA_PRUEFEN_01 SPOTS ES_SAPMM07M.
    CALL FUNCTION 'ME_READ_ITEM_TRANSFER'
         EXPORTING
              BUDAT         = MKPF-BUDAT
              EBELN         = B-EBELN
              EBELP         = B-EBELP
              RESWK         = B-WERKS
              XBBEFU_FLAG   = XEBEFU_FLAG
              DISPLAY       = VW
              DELIVERY      = B-LFSCH
              I_KURSTYP     = T003-KURST
              XSTOR         = E_XSTOR
              I_SMBLN       = MSEG-MBLNR
              I_SMBLP       = MSEG-ZEILE
              I_SJAHR       = MSEG-MJAHR
              I_VBELN       = VM07M-VBELN
              I_VBELP       = VM07M-VBELP
         IMPORTING
              LIFNR         = KBEFU-LIFNR
         TABLES
              XBBEFU        = XBBEFU
              TEKSEL        = XEKSEL
              XEKBNK        = XEKBNK
              XEKBNK_CR     = XEKBNK_CR
        xekbnk_kdm    = xekbnk_kdm                        "N1027899
      EXCEPTIONS
              NOT_ACTIV     = 01       "Position gelöscht
              NOT_FOUND     = 02       "ohne Pos - keinen gefun.
              NOT_FOUND_ANY = 03       "mit Pos - Pos nicht da
              NOT_FOUND_ONE = 04       "mit Pos - Pos nicht da
              NOT_VALID_ANY = 05       "ohne Pos - keine guelt.
              NOT_VALID_ONE = 06       "mit Pos - Pos nicht gültig
              WRONG_TYPE    = 07.      "keine UmlagerPos. vorhanden
END-ENHANCEMENT-SECTION.

    def_break 'ME_READ_ITEM_TRANSFER'.                            "#EC *
    BREAK-POINT ID mb_me_read_item_transfer.

    IF T158-TRTYP = H.
      CASE SY-SUBRC.
        WHEN 1.
          PERFORM NACO_ERMITTELN_V4(SAPFM07M) USING 'M7' '031'
                                       B-EBELN KBEFU-LOEKZ SPACE SPACE.
        WHEN 2.
          MESSAGE E030 WITH B-EBELN.
        WHEN 3.
          MESSAGE E033 WITH B-EBELN.
        WHEN 4.
          MESSAGE E150 WITH B-EBELN B-EBELP.
        WHEN 5.
          MESSAGE E151 WITH B-EBELN.
        WHEN 6.
          IF NOT B-EBELP IS INITIAL.
            MESSAGE E152 WITH B-EBELP B-EBELN.
          ELSE.
            MESSAGE E153 WITH B-EBELN.
          ENDIF.
        WHEN 7.
          MESSAGE E153 WITH B-EBELN.
      ENDCASE.
ENHANCEMENT-SECTION     BESTELLUNG_WA_PRUEFEN_03 SPOTS ES_SAPMM07M.
      CASE T156-KZBWA.
        WHEN KZBWA-01 OR KZBWA-05.
*        Movement types 351/641/647: Purchase order must be UB-logic.
         READ TABLE xbbefu WITH KEY bsakz = space                "sdp462
                            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            MESSAGE e153 WITH b-ebeln.
          ENDIF.
        WHEN kzbwa-03 OR kzbwa-04 or kzbwa-k3.        "ST-PO-consignment
*        Movement types 643/645: Purchase order must be NB-logic.
         READ TABLE xbbefu WITH KEY bsakz = t                    "sdp462
                            TRANSPORTING NO FIELDS.
          IF sy-subrc = 0.
            MESSAGE e153 WITH b-ebeln.
          ENDIF.
        WHEN OTHERS.
          MESSAGE e153 WITH b-ebeln.
      ENDCASE.
END-ENHANCEMENT-SECTION.
    ENDIF.
  ENDFORM.                    "BESTELLUNG_WA_PRUEFEN