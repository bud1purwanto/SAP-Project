*eject
*---------------------------------------------------------------------*
*       FORM BEZUGSNEBENKOSTEN_UEBERNEHMEN                            *
*---------------------------------------------------------------------*
*       Die Bezugsnebenkosten werden uebernommen.                     *
*---------------------------------------------------------------------*
  FORM BEZUGSNEBENKOSTEN_UEBERNEHMEN USING B-EBELN LIKE MSEG-EBELN
                                           B-EBELP LIKE MSEG-EBELP
                                           B-WEUNB LIKE MSEG-WEUNB
                                           B-KZBEW LIKE MSEG-KZBEW
                                           B-XNEBE TYPE C.

    DATA EBELN LIKE MSEG-EBELN.
    IF B-XNEBE IS INITIAL.
      EBELN = B-EBELN.
    ELSE.
      CLEAR EBELN.
    ENDIF.
    READ TABLE XEKBNK WITH KEY EBELN = EBELN
                                EBELP = B-EBELP
                                BINARY SEARCH
                                TRANSPORTING NO FIELDS.
    LOOP AT XEKBNK FROM SY-TABIX.
      IF XEKBNK-EBELN NE EBELN OR XEKBNK-EBELP NE B-EBELP.
        EXIT.
      ENDIF.
      CHECK NOT XEKBNK-KVSL2 IS INITIAL AND NOT XEKBNK-KWERT IS INITIAL.
      CHECK B-WEUNB IS INITIAL OR
        ( NOT XEKBNK-KVSL1 IS INITIAL AND NOT XEKBNK-KVSL2 IS INITIAL ).
      IF NOT XMIGO IS INITIAL AND
         NOT XEKBNK-FRERF IS INITIAL.
*-- Freight vendor was entered in MMIM-ENJOY
        READ TABLE T_FREIGHT WITH KEY EBELN = XEKBNK-EBELN
                                      EBELP = XEKBNK-EBELP
                                      ZAEHK = XEKBNK-ZAEHK
                                      STUNR = XEKBNK-STUNR.
        IF SY-SUBRC IS INITIAL.
          XEKBNK-LIFNR = T_FREIGHT-LIFNR.
        ENDIF.
      ENDIF.
      READ TABLE YEKBNK WITH KEY EBELN = B-EBELN
                                 EBELP = XEKBNK-EBELP
                                 STUNR = XEKBNK-STUNR
                                 ZAEHK = XEKBNK-ZAEHK
                                 BINARY SEARCH
                                 TRANSPORTING NO FIELDS.
      IF NOT SY-SUBRC IS INITIAL.
        YEKBNK = XEKBNK.
        YEKBNK-EBELN = B-EBELN.
        IF ( B-KZBEW IS INITIAL OR B-KZBEW = L ) AND
          YEKBNK-KWERT < 0.
          YEKBNK-FNWMG = 0 - YEKBNK-FNWMG.
          YEKBNK-NAWMG = 0 - YEKBNK-NAWMG.
          YEKBNK-FRWMG = 0 - YEKBNK-FRWMG.
        ENDIF.
        INSERT YEKBNK INDEX SY-TABIX.
        DATA ML00. CLEAR ML00.
        DATA ML10. CLEAR ML10.
        READ TABLE XEKBNK_CR WITH KEY EBELN = EBELN
                                      EBELP = XEKBNK-EBELP
                                      STUNR = XEKBNK-STUNR
                                      ZAEHK = XEKBNK-ZAEHK
                                      BINARY SEARCH
                                      TRANSPORTING NO FIELDS.
        LOOP AT XEKBNK_CR FROM SY-TABIX.
          IF XEKBNK_CR-EBELN NE EBELN
                OR XEKBNK_CR-EBELP NE XEKBNK-EBELP
                OR XEKBNK_CR-STUNR NE XEKBNK-STUNR
                OR XEKBNK_CR-ZAEHK NE XEKBNK-ZAEHK.
            EXIT.
          ENDIF.
          READ TABLE YEKBNK_CR WITH KEY EBELN = B-EBELN
                                        EBELP = XEKBNK_CR-EBELP
                                        STUNR = XEKBNK_CR-STUNR
                                        ZAEHK = XEKBNK_CR-ZAEHK
                                        CURTP = XEKBNK_CR-CURTP
                                        BINARY SEARCH
                                        TRANSPORTING NO FIELDS.
          IF NOT SY-SUBRC IS INITIAL.
            YEKBNK_CR = XEKBNK_CR.
            YEKBNK_CR-EBELN = B-EBELN.
            INSERT YEKBNK_CR INDEX SY-TABIX.
          ENDIF.
          IF YEKBNK_CR-CURTP = CURTP00.
            ML00 = X.
          ELSEIF YEKBNK_CR-CURTP = CURTP10.
            ML10 = X.
          ENDIF.
        ENDLOOP.
        IF NOT SY-SUBRC IS INITIAL.
          MESSAGE E001 WITH 'YEKBNK_CR' SPACE B-EBELN B-EBELP.
        ELSEIF ML00 IS INITIAL.
          MESSAGE E001 WITH 'YEKBNK_CR' '00' B-EBELN B-EBELP.
        ELSEIF ML10 IS INITIAL.
          MESSAGE E001 WITH 'YEKBNK_CR' '10' B-EBELN B-EBELP.
        ENDIF.
      ENDIF.
    ENDLOOP.

* Begin N1520698
* if late lock tcurm-mbequ = 2 then need info for all items
    READ TABLE xekbnk_kdm WITH KEY ebeln = ebeln
                                   ebelp = b-ebelp
                                   BINARY SEARCH
                                   TRANSPORTING NO FIELDS.
    LOOP AT xekbnk_kdm FROM sy-tabix.
      READ TABLE yekbnk_kdm WITH KEY ebeln = xekbnk_kdm-ebeln
                                     ebelp = xekbnk_kdm-ebelp
                                     stunr = xekbnk_kdm-stunr
                                     zaehk = xekbnk_kdm-zaehk
                                     BINARY SEARCH
                                     TRANSPORTING NO FIELDS.
      IF NOT sy-subrc IS INITIAL.
        yekbnk_kdm = xekbnk_kdm.
        INSERT yekbnk_kdm INDEX sy-tabix.
      ENDIF.
    ENDLOOP.
* End N1520698

  ENDFORM.                    "BEZUGSNEBENKOSTEN_UEBERNEHMEN