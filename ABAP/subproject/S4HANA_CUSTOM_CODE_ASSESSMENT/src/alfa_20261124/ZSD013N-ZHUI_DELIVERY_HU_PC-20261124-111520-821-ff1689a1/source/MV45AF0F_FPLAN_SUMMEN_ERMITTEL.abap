*---------------------------------------------------------------------*
*       FORM FPLAN_SUMMEN_ERMITTELN                                   *
*---------------------------------------------------------------------*
FORM FPLAN_SUMMEN_ERMITTELN CHANGING CH_KOMPAX STRUCTURE KOMPAX.
  TABLES: KOMPAXA.
  DATA: TVAP_FPLA LIKE TVAP.
  DATA: LS_XVBAP TYPE VBAPVB.
*
  IF NOT TVAK-FPART IS INITIAL.
    PERFORM XVBKD_LESEN(SAPFV45K) USING POSNR_LOW.
    PERFORM FPLANART_ERMITTELN_KOPF CHANGING TVAK-FPART.
*   Ermitteln Summe der Positionsnettowerte aller Positionen, die auf
*   Kopffakturierungsplan zeigen
    CLEAR: CH_KOMPAX, KOMPAXA.
*   Aktuelle TVAP Positionsdaten merken
    MOVE-CORRESPONDING TVAP TO TVAP_FPLA.
    LOOP AT XVBAP INTO LS_XVBAP WHERE UPDKZ NE UPDKZ_DELETE.
      IF NOT LS_XVBAP-ABGRU IS INITIAL.
*       Bei abgesagter Position muß festgestellt werden, ob die
*       Summen kumuliert werden dürfen.
        PERFORM TVAG_SELECT USING LS_XVBAP-ABGRU
                                  TVAG-DRAGR
                                  SPACE
                                  SY-SUBRC.
*       nur wenn das Statistik-Kennzeichen initial ist, darf addiert
*       werden
        CHECK TVAG-KOWRR IS INITIAL.
      ENDIF.
      PERFORM TVAP_SELECT USING LS_XVBAP-PSTYV
                                SPACE
                                SY-SUBRC.
*     Ist Position fakturierungsplanrelevant ?
      CHECK LS_XVBAP-FKREL EQ CON_FKREL_FPLAN OR
            ( LS_XVBAP-FKREL IS INITIAL AND       "oder Angebote
              NOT TVAP-FPART IS INITIAL ).
*
*     Ermitteln, ob Positionsfakturierungsplan auf Kopffakturierungsplan
*     zeigt
      PERFORM XVBKD_LESEN(SAPFV45K) USING LS_XVBAP-POSNR.
      PERFORM FPLANART_ERMITTELN CHANGING TVAP-FPART.
      PERFORM FPLAN_POS_KOPFRELEVANT USING    LS_XVBAP-POSNR
                                              TVAP-FPART TVAK-FPART
                                     CHANGING SY-SUBRC.

*     if the item billing plan already exists OR if it does not exist
*     yet but the item has the same billing plan type as the header
      IF SY-SUBRC EQ 0 OR
         ( XVBKD-FPLNR IS INITIAL AND
             TVAP-FPART EQ TVAK-FPART ).
*       Summieren
        KOMPAXA-NETWR = KOMPAXA-NETWR + LS_XVBAP-NETWR.
        MOVE-CORRESPONDING KOMPAXA TO CH_KOMPAX.
      ENDIF.
    ENDLOOP.
    MOVE-CORRESPONDING TVAP_FPLA TO TVAP.
  ENDIF.
ENDFORM.