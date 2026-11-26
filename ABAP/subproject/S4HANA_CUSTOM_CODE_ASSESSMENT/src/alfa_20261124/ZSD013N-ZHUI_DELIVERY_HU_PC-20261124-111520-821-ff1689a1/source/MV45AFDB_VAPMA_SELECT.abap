*&---------------------------------------------------------------------*
*&      Form  VAPMA_SELECT
*&---------------------------------------------------------------------*
*       Lesen von vorangegangenen Verkaufsbelegen zu einem Material.  *
*       Vorangegangene Verkaufsbelege können Angebote oder            *
*       Kontrakte sein. Wird ein solcher Verkaufsbeleg gefunden und   *
*       ist er noch nicht vollständig bearbeitet, wird ein Schalter   *
*       gesetzt und die Verarbeitung verlassen.
*----------------------------------------------------------------------*
FORM VAPMA_SELECT USING US_MATNR
                        US_VKORG
                        US_TRVOG
                        US_VTWEG
                        US_SPART
                        US_KUNNR
                        CH_POSITION_EXIST.

  LOCAL: VBAP,
         VBUP,
         VBFA.

  DATA: DA_REFMENG  LIKE VBFA-RFMNG_FLT,
        DA_REFMENGV LIKE VBFA-RFMNG_FLO,
        DA_VRKME    LIKE VBAP-VRKME,
        DA_UMVKZ    LIKE VBAP-UMVKZ,
        DA_UMVKN    LIKE VBAP-UMVKN,
        DA_KWMENG   LIKE VBAP-KWMENG.

  SELECT * FROM VAPMA WHERE MATNR = US_MATNR AND
                            VKORG = US_VKORG AND
                            TRVOG = US_TRVOG AND
                            VTWEG = US_VTWEG AND
                            SPART = US_SPART AND
                            KUNNR = US_KUNNR.

*   Gültigkeitszeitraum prüfen
    IF VBAK-VDATU IS INITIAL.
      CHECK VAPMA-DATAB <= SY-DATLO AND
            VAPMA-DATBI >= SY-DATLO.
    ELSE.
      CHECK VAPMA-DATAB <= VBAK-VDATU AND
      VAPMA-DATBI >= VBAK-VDATU.
    ENDIF.

*   Status des Verkaufsbelegs lesen
    SELECT SINGLE * FROM VBUP WHERE VBELN = VAPMA-VBELN AND
                                    POSNR = VAPMA-POSNR.
    IF SY-SUBRC EQ 0.
*     Lesen der ITAB XVBUP, da ein Hinweis mehrmals angezeigt werden
*     kann und somit nur einmal angezeigt werden darf
      XVBUP-MANDT = SY-MANDT.
      XVBUP-VBELN = VAPMA-VBELN.
      XVBUP-POSNR = VAPMA-POSNR.
      READ TABLE XVBUP WITH KEY XVBUP(19).
*     Wenn der Eintrag nicht gefunden wird passen die Status nicht
*     zu XVBUP-MANDT, XVBUP-VBELN und XVBUP-POSNR.
      IF SY-SUBRC NE 0.
        XVBUP = VBUP.
      ENDIF.

      IF XVBUP-GBSTA CO ' AB'.
*       Auftrag wurde nicht vollständig bearbeitet

        SELECT SINGLE * FROM VBAP WHERE VBELN = VAPMA-VBELN AND
                                        POSNR = VAPMA-POSNR.
*       bei untergeordneten Positionen kein Hinweis
        CHECK VBAP-UEPOS IS INITIAL.

*       offene Menge ermitteln
        CLEAR: DA_REFMENG, DA_REFMENGV.
        loop at xvbfa where vbelv = vapma-vbeln and
                            posnv = vapma-posnr and
                            vbeln = vbak-vbeln  and
                          ( plmin = char_plus or
                            plmin = char- ).
*         fakturierte Menge nicht berücksichtigen sondern nur
*         bereits abgerufene
          if xvbfa-vbtyp_n na vbtyp_fakt.
            if xvbfa-plmin eq char_plus.
              da_refmeng  = da_refmeng  + xvbfa-rfmng_flt.
              da_refmengv = da_refmengv + xvbfa-rfmng_flo.
            else.
              da_refmeng  = da_refmeng  - xvbfa-rfmng_flt.
              da_refmengv = da_refmengv - xvbfa-rfmng_flo.
            endif.
          endif.
        endloop.
        SELECT VBTYP_N PLMIN RFMNG_FLT RFMNG_FLO FROM VBFA
               INTO (VBFA-VBTYP_N, VBFA-PLMIN,
                     VBFA-RFMNG_FLT, VBFA-RFMNG_FLO)
               WHERE VBELV EQ VAPMA-VBELN
                 AND POSNV EQ VAPMA-POSNR
                 AND VBELN NE VBAK-VBELN
                 AND PLMIN IN (CHAR_PLUS, CHAR-).
*         fakturierte Menge nicht berücksichtigen sondern nur
*         bereits abgerufene
          IF VBFA-VBTYP_N NA VBTYP_FAKT.
            IF VBFA-PLMIN EQ CHAR_PLUS.
              DA_REFMENG  = DA_REFMENG  + VBFA-RFMNG_FLT.
              DA_REFMENGV = DA_REFMENGV + VBFA-RFMNG_FLO.
            ELSE.
              DA_REFMENG  = DA_REFMENG  - VBFA-RFMNG_FLT.
              DA_REFMENGV = DA_REFMENGV - VBFA-RFMNG_FLO.
            ENDIF.
          ENDIF.
        ENDSELECT.
        CLEAR VBFA.

        CH_POSITION_EXIST = CHARX.
        HNW_VBAP-VBELN = VAPMA-VBELN.
        HNW_VBAP-POSNR = VAPMA-POSNR.
        HNW_VBAP-MATNR = VAPMA-MATNR.
        IF US_TRVOG = '2'.
*         Auftragsmenge in Basismenge umrechnen
          DA_VRKME  = VBAP-VRKME.
          DA_KWMENG = VBAP-KWMENG.
          DA_UMVKZ  = VBAP-UMVKZ.
          DA_UMVKN  = VBAP-UMVKN.
        ELSE.
*         Zielmenge in Basismenge umrechnen
          DA_VRKME  = VBAP-ZIEME.
          DA_KWMENG = VBAP-ZMENG.
          DA_UMVKZ  = VBAP-UMZIZ.
          DA_UMVKN  = VBAP-UMZIN.
        ENDIF.
        HNW_VBAP-MEINS = DA_VRKME.
        IF VBAP-KZFME IS INITIAL.
          HNW_VBAP-KWMENG = DA_KWMENG
                          - DA_REFMENG  * QUAN_1 * DA_UMVKN / DA_UMVKZ.
        ELSE.
          HNW_VBAP-KWMENG = DA_KWMENG
                          - DA_REFMENGV * QUAN_1.
        ENDIF.
        HNW_VBAP-WAERK = VBAP-WAERK.
        IF DA_KWMENG NE 0.
          HNW_VBAP-NETWR = VBAP-NETWR * HNW_VBAP-KWMENG / DA_KWMENG.
        ELSE.
          HNW_VBAP-NETWR = VBAP-NETWR.
        ENDIF.
        HNW_VBAP-AUART = VAPMA-AUART.
        HNW_VBAP-DATAB = VAPMA-DATAB.
        HNW_VBAP-DATBI = VAPMA-DATBI.
        APPEND HNW_VBAP.

      ENDIF.
    ENDIF.

  ENDSELECT.

ENDFORM.                    "VAPMA_SELECT