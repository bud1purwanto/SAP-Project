*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_WA_POP                                        *
*---------------------------------------------------------------------*
*       Die Bestellung wird für den Warenausgang zur Umlagerbestel-   *
*       lung gelesen.                                                 *
*---------------------------------------------------------------------*
  FORM BESTELLUNG_WA_POP.
    DATA: WERKS LIKE RM07M-WERKS.
    WERKS = RM07M-WERKS.
    IF NOT AM07M-RESWK IS INITIAL.
      WERKS = AM07M-RESWK.
    ENDIF.
    PERFORM BESTELLUNG_WA_PRUEFEN USING RM07M-EBELN
                                        RM07M-EBELP
                                              WERKS
                                              SPACE.
    CLEAR:   FUSS,
             INDEX_L.
    REFRESH: YFUSS,
             PREFETCH01,
             PREFETCH02,
             PREFETCH03.
    LOOP AT XBBEFU WHERE NOT UMMAT IS INITIAL.
      MOVE-CORRESPONDING XBBEFU TO PREFETCH02.
      PREFETCH02-MATNR = XBBEFU-UMMAT.
      COLLECT PREFETCH02.
      MOVE-CORRESPONDING XBBEFU TO PREFETCH03.
      PREFETCH03-MATNR = XBBEFU-UMMAT.
      COLLECT PREFETCH03.
    ENDLOOP.
    PERFORM PREFETCH_AUSFUEHREN USING X
                                      SPACE.
    LOOP AT XBBEFU.
      CHECK XBBEFU-EBELP >= RM07M-EBELP AND XBBEFU-LOEKZ IS INITIAL.
      IF NOT WERKS IS INITIAL.
        IF NOT RM07M-EBELP IS INITIAL AND WERKS NE XBBEFU-WERKS.
          MESSAGE E034 WITH XBBEFU-EBELN XBBEFU-EBELP XBBEFU-WERKS.
        ENDIF.
        CHECK XBBEFU-WERKS = WERKS.
      ENDIF.
      PERFORM bbefu_check.       "note 305582
      CLEAR DM07M.
      CLEAR VM07M.
      CLEAR MSEG.
      INDEX_L = INDEX_L + 1.
      MOVE-CORRESPONDING XBBEFU TO DM07M.
      dm07m-umbar_po = xbbefu-umbar.                           "801097
      MOVE-CORRESPONDING XBBEFU TO VM07M.
      MOVE KBEFU-BWAER TO VM07M-BWAER.                     "note 167017
      MOVE-CORRESPONDING XBBEFU TO MSEG.
      MSEG-BSTME = XBBEFU-ERFME.
      MSEG-BSTMG = XBBEFU-ERFMG.
      PERFORM PARAMETER_BEW_SOND_SETZEN USING MSEG MSEGK DM07M XBBEFU.
      PERFORM WERK_PRUEFEN(SAPFM07M) USING    X
                                           MSEG-WERKS
                                           VM07M-BWKEY
                                           DM07M-BWMOD
                                           DM07M-XEINK
                                           DM07M-XBKNG
                                           VM07M-XVKBW
                                           MSEG-BUKRS
                                           DM07M-KTOPL
                                           DM07M-PERIV
                                           MSEG-WAERS
                                           MKPF-BUDAT
                                           MSEG-GJAHR
                                           VM07M-MONAT
                                           MSEG-XRUEM
                                           MSEG-XRUEJ
                                           VM07M-LFGJA
                                           VM07M-LFMON
                                           DM07M-FABKL
                                           DM07M-KZXAB.
      MSEG-PARGB  = XBBEFU-GSBER.
      MSEG-PPRCTR = XBBEFU-PRCTR.
      MSEG-MATNR = XBBEFU-UMMAT.
      PERFORM SEGMENTDATEN_T156_SETZEN(SAPFM07M).
      MSEG-KZBEW = RM07M-KZBEW.
      MSEG-KZZUG = X.
      VM07M-BUMRZ = XBBEFU-UMREZ.                          "note 181297
      VM07M-BUMRN = XBBEFU-UMREN.                          "note 181297
      DM07M-BSMNG = MSEG-ERFMG.
      IF MSEG-SHKZG = H.
        MSEG-ERFMG  = MSEG-ERFMG - XBBEFU-WAMNG.
      ELSE.
        MSEG-ERFMG  = XBBEFU-WAMNG - XBBEFU-WEMNG.
      ENDIF.
      IF MSEG-ERFMG < 0.
        CLEAR MSEG-ERFMG.
      ENDIF.
      CLEAR MSEG-MENGE.
      IF NOT MSEG-MEINS IS INITIAL.
        CALL FUNCTION 'MB_UNIT_CONVERSION'
             EXPORTING
                  MEINS                = MSEG-MEINS
                  ERFME                = MSEG-ERFME
                  MENGE                = MSEG-MENGE
                  ERFMG                = MSEG-ERFMG
                  UMREZ                = DM07M-UMREZ
                  UMREN                = DM07M-UMREN
             IMPORTING
                  O_MENGE              = MSEG-MENGE
                  O_ERFMG              = MSEG-ERFMG
                  O_UMREZ              = DM07M-UMREZ
                  O_UMREN              = DM07M-UMREN
             EXCEPTIONS
                  CONVERSION_NOT_FOUND = 4.
        IF NOT SY-SUBRC IS INITIAL.
          MESSAGE E026 WITH MSEG-ERFME MSEG-MEINS.
        ENDIF.
      ENDIF.
      IF NOT MSEG-MATNR IS INITIAL.
        DM07M-XLORT = X.
        DM07M-XCHAR = X.
      ENDIF.
      IF MSEG-LGORT IS INITIAL.
        MSEG-LGORT = RM07M-LGORT.
      ENDIF.
      IF DM07M-MAKTX IS INITIAL.
        PERFORM KURZTEXT_LESEN(SAPFM07M) USING MSEG-MATNR.
      ENDIF.
      PERFORM FUSSZEILE_BEW_PRUEFEN.
      PERFORM FUSS_ERGAENZEN.
      CLEAR FUSS-XPRUE.
*-- muß hier XSELP auf X setzen, da auch nach NL (F7) die Verarbeitung
*-- ausgelöst werden kann.
      FUSS-XSELP = X.
      IF NOT FCAUSW-XLIST IS INITIAL.
        IF FUSS-ERFMG IS INITIAL.
          CLEAR FUSS-XSELK.
        ELSE.
          FUSS-XSELK = T158-XSELE.
        ENDIF.
      ENDIF.
      PERFORM FUSS_NACH_YFUSS.
      PERFORM BEZUGSNEBENKOSTEN_UEBERNEHMEN USING XBBEFU-EBELN
                                                  XBBEFU-EBELP
                                                    MSEG-WEUNB
                                                    MSEG-KZBEW
                                                         SPACE.
    ENDLOOP.
    FREE: XBBEFU, XEKBNK, XEKBNK_CR.
    CLEAR BCODE.
    PERFORM FUSS_AUS_YFUSS.
    READ TABLE FUSS INDEX 1.
    IF NOT SY-SUBRC IS INITIAL.
      MESSAGE E064 WITH RM07M-EBELN.
    ENDIF.
    IF XAKTIV IS INITIAL.
      XAKTIV = X.
    ENDIF.
    IF XCONFIRM IS INITIAL.
      IF T158-TRTYP = H.
        XCONFIRM = X.
      ENDIF.
    ENDIF.
    IF INDEX_L < 1.
      MESSAGE E035 WITH RM07M-EBELN RM07M-WERKS.
    ENDIF.
  ENDFORM.