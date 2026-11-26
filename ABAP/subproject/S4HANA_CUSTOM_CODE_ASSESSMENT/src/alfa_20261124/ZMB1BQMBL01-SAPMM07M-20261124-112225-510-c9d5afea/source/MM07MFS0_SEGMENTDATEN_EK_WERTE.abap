*eject
*---------------------------------------------------------------------*
*       FORM SEGMENTDATEN_EK_WERTE                                    *
*---------------------------------------------------------------------*
*       Zur Bestellposition werden die Werte uebernommen.             *
*---------------------------------------------------------------------*
FORM SEGMENTDATEN_EK_WERTE.
  IF NOT KBEFU-ZBD1P IS INITIAL AND NOT T003-XNETB IS INITIAL
     AND XEBEFU-SKTOF IS INITIAL.
    VM07M-NETWR = VM07M-NETWR
                  - ( KBEFU-ZBD1P * VM07M-NETWR / 100000 ).
    VM07M-NETWW = VM07M-NETWW
                  - ( KBEFU-ZBD1P * VM07M-NETWW / 100000 ).
  ENDIF.
  READ TABLE XEBEFU_CR WITH KEY EBELN = XEBEFU-EBELN
                                EBELP = XEBEFU-EBELP
                                LFBJA = XEBEFU-LFBJA
                                LFBNR = XEBEFU-LFBNR
                                LFPOS = XEBEFU-LFPOS
                                BINARY SEARCH
                                TRANSPORTING NO FIELDS.
  LOOP AT XEBEFU_CR FROM SY-TABIX.
    IF  XEBEFU_CR-EBELN NE XEBEFU-EBELN
       OR  XEBEFU_CR-EBELP NE XEBEFU-EBELP
       OR   XEBEFU_CR-LFBJA NE XEBEFU-LFBJA
       OR   XEBEFU_CR-LFBNR NE XEBEFU-LFBNR
       OR   XEBEFU_CR-LFPOS NE XEBEFU-LFPOS.
      EXIT.
    ENDIF.
    READ TABLE YEBEFU_CR WITH KEY EBELN = XEBEFU_CR-EBELN
                             EBELP = XEBEFU_CR-EBELP
                               LFBJA = XEBEFU_CR-LFBJA
                               LFBNR = XEBEFU_CR-LFBNR
                               LFPOS = XEBEFU_CR-LFPOS
                               CURTP = XEBEFU_CR-CURTP
                               BINARY SEARCH
                               TRANSPORTING NO FIELDS.
    IF NOT SY-SUBRC IS INITIAL.
      YEBEFU_CR = XEBEFU_CR.
      IF NOT KBEFU-ZBD1P IS INITIAL AND NOT T003-XNETB IS INITIAL
         AND XEBEFU-SKTOF IS INITIAL.
        YEBEFU_CR-NETWR = YEBEFU_CR-NETWR
                      - ( KBEFU-ZBD1P * YEBEFU_CR-NETWR / 100000 ).
      ENDIF.
ENHANCEMENT-SECTION     MM07MFS0_SEGM_EK_WERTE_01 SPOTS ES_SAPMM07M.
      IF NOT VM07M-WEBRE IS INITIAL AND XEBEFU-LFBNR IS INITIAL.
        YEBEFU_CR-REWRT = YEBEFU_CR-AREWR = YEBEFU_CR-WEWRT.
      ENDIF.
END-ENHANCEMENT-SECTION.
      INSERT YEBEFU_CR INDEX SY-TABIX.
    ENDIF.
  ENDLOOP.

ENDFORM.