*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_RETURN_EKES_FUELLEN                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  RETURN_EKES_FUELLEN
*&---------------------------------------------------------------------*
FORM return_ekes_fuellen.
  DATA: ekes_pos LIKE sy-tfill VALUE 0,
        kz_kopf_geaendert(1)   VALUE ' '.

  DATA: t_ekes_upd LIKE uekes OCCURS 0
                              WITH HEADER LINE.
  DATA: cast_ebelp LIKE ekes-ebelp.
  DATA: retdlv LIKE sy-subrc.

ENHANCEMENT-POINT MV50AF0B_RETURN_EKES_FUELLEN_1 SPOTS ES_SAPMV50A STATIC.

  READ TABLE xlips INDEX 1.                                  "n_1142408
  MOVE xlips-vgpos TO cast_ebelp.
ENHANCEMENT-SECTION     MV50AF0B_RETURN_EKES_FUELLEN_2 SPOTS ES_SAPMV50A.
  CLEAR retdlv.
* Check, if visible return deliveries are set
  CALL FUNCTION 'ME_CONFIRMATION_RETDLV'
       EXPORTING
            i_vgbel          = xlips-vgbel
            i_vgpos          = cast_ebelp
            i_etens          = xlips-etens
            i_updkz          = xlips-updkz
            i_vbeln          = xlips-vbeln
            i_vbelp          = xlips-posnr
       EXCEPTIONS
            visible_retdlv   = 1
            invisible_retdlv = 2
            OTHERS           = 3.
  retdlv = sy-subrc.
END-ENHANCEMENT-SECTION.

* Zurücksetzen der Kommunikationsdatei
  REFRESH: xuekes.
  REFRESH: xekes_conv_qty.                                  "457360

* prüfen, ob sich im Lieferkopf relevante Daten geändert haben
* if xlikp-updkz eq updkz_update.                               "438392
  IF xlikp-updkz EQ updkz_update OR                         "455748
     ( xlikp-updkz EQ updkz_new AND xlikp-vbtyp NA vbtyp_grwe ).
    READ TABLE ylikp WITH KEY xlikp(13).
    IF xlikp-lfdat NE ylikp-lfdat OR
       xlikp-lfuhr NE ylikp-lfuhr OR
       xlikp-vbeln NE ylikp-vbeln OR                        "438392
       xlikp-lifex NE ylikp-lifex.
      kz_kopf_geaendert = charx.
    ENDIF.
  ENDIF.


*---------------------------------------------------------------------*
*       Löschen von Positionen                                        *
*---------------------------------------------------------------------*
  IF t180-aktyp = charv.
    LOOP AT ylips WHERE vbeln EQ xlikp-vbeln.
      IF ylips-updkz = updkz_delete AND
         ylips-vgtyp = charv.
        PERFORM return_ekes_aus_lips USING ylips-updkz retdlv.
* WE-Dialog  hold data  RC 13.10.2000
      ELSEIF ylips-vgtyp = charv.
        READ TABLE xlips WITH KEY vbeln = ylips-vbeln
                                  posnr = ylips-posnr.
        IF sy-subrc = 0 AND
           ( xlips-vgbel <> ylips-vgbel OR
             xlips-vgpos <> ylips-vgpos ).
          PERFORM return_ekes_aus_lips USING updkz_delete retdlv.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

*---------------------------------------------------------------------*
*       Hinzufügen oder verändern von Positionen                      *
*---------------------------------------------------------------------*
  LOOP AT xlips WHERE vbeln EQ xlikp-vbeln.

    IF xlips-updkz EQ updkz_new  AND   "Position wird hinzugefügt
       ( kz_kopf_geaendert NE charx OR                      "455748
         xlikp-vbtyp CA vbtyp_grwe ) AND
       xlips-vgtyp = charv.
      PERFORM return_ekes_aus_lips USING xlips-updkz retdlv.
      CHECK 1 = 2.
    ENDIF.
    IF ( xlips-updkz EQ updkz_update  OR   "Position oder Kopf wird
         kz_kopf_geaendert EQ charx ) AND  "verändert
         xlips-vgtyp = charv.
*     delivery header or item is marked for update
      READ TABLE ylips WITH KEY vbeln = xlikp-vbeln
                                posnr = xlips-posnr
                                updkz = updkz_delete
                                TRANSPORTING NO FIELDS
                                BINARY SEARCH.
      IF sy-subrc NE 0.
*       Start of note 504329 -> reference to note 496322
*       perform best_ekes_aus_lips using xlips-updkz ormng_table.
        IF kz_kopf_geaendert NE charx.
          PERFORM return_ekes_aus_lips USING xlips-updkz retdlv.
        ELSEIF xlikp-updkz NE updkz_new.
          PERFORM return_ekes_aus_lips USING updkz_update retdlv.
        ELSE.
          PERFORM return_ekes_aus_lips USING updkz_new retdlv.
        ENDIF.
*       End of note 504329
      ENDIF.
    ENDIF.
  ENDLOOP.
* MM erwartet sortierte Tabelle: FB Me_Confirmation_Maintain_Avis
  SORT xuekes BY mandt ebeln ebelp vbeln vbelp.

*---------------------------------------------------------------------*
*       Falls notwendg, wird die Bestellentwicklung verbucht          *
*---------------------------------------------------------------------*
  DESCRIBE TABLE xuekes LINES ekes_pos.
  IF ekes_pos > 0.

    DATA: l_trguid TYPE cs_guidc.
    l_trguid = v50agl-apotrguid.

    CALL FUNCTION 'ND_EXITS_ACTIVE_CHECK'
         EXCEPTIONS
              exits_not_active = 1
              OTHERS           = 2.

*-- APO is active
    IF sy-subrc EQ 0 AND NOT
       l_trguid IS INITIAL.

*-- save GUID for APO transfer of PO
      CALL FUNCTION 'OUTBOUND_CALL_01000791_E' IN UPDATE TASK
           EXPORTING
                i_trguid = l_trguid
           EXCEPTIONS
                OTHERS   = 1.

    ENDIF.

    CALL FUNCTION 'ME_CONFIRMATION_MAINTAIN_AVIS'
*##001-anf
       EXPORTING
            i_ibtyp = lfart_besttyp
*##001-end
       TABLES
            t_ekes = xuekes
            t_ekes_upd = t_ekes_upd
            t_ekes_conv_qty = xekes_conv_qty                "457360
       EXCEPTIONS
            conversion_not_possible = 1
            OTHERS = 2.
    IF sy-subrc = 1.
* conversion is not possible
      MESSAGE e254.
    ELSEIF sy-subrc = 2.
* purchase order update failed
      MESSAGE e255.
    ENDIF.
*   Update LIS notwendig?
    DESCRIBE TABLE t_ekes_upd LINES sy-tfill.
    IF sy-tfill > 0.
*     ja
      CALL FUNCTION 'ME_STATISTICS_LF_EKES_LIS'
           EXPORTING
                i_likp_new = xlikp
                i_likp_old = ylikp
           TABLES
                t_ekes     = t_ekes_upd
                t_lips_new = xlips
                t_lips_old = ylips.
    ENDIF.                             "Update LIS notwendig?
  ENDIF.




ENDFORM.                               " RETURN_EKES_FUELLEN
**&---------------------------------
**&      Form  RETURN_EKES_AUS_LIPS
**&---------------------------------
**       text
**------------------------------------*
**      -->P_YLIPS_UPDKZ  text
**------------------------------------*
FORM return_ekes_aus_lips USING    lep_vorgang retdlv.

  CLEAR xuekes.
  CHECK retdlv = 1.
*
  CASE lep_vorgang.
    WHEN updkz_new.                    "Position wird hinzugefügt
        xuekes-mandt = xlips-mandt.
        xuekes-ebeln = xlips-vgbel.
        xuekes-ebelp = xlips-vgpos.
        xuekes-eindt = xlikp-lfdat.
        xuekes-lpein = '1'.
        xuekes-uzeit = xlikp-lfuhr.
        xuekes-estkz = '4'.
        xuekes-ref_etens = xlips-etens.
        xuekes-erdat = xlips-erdat.
        xuekes-ezeit = xlips-erzet.
        xuekes-menge = xlips-lfimg.
        xuekes-vbeln = xlips-vbeln.
        xuekes-vbelp = xlips-posnr.
        xuekes-xblnr = xlikp-lifex.
        xuekes-ematn = xlips-ematn.
        xuekes-ekpomeins = xlips-vrkme.
        xuekes-charg = xlips-charg.
        xuekes-uecha = xlips-uecha.
        xuekes-kz    = lep_vorgang.
        xuekes-werks = xlips-werks.                           "n_905551
        xuekes-lgort = xlips-lgort.                           "n_905551
    WHEN updkz_update.                 "Position wurde verändert
      xuekes-mandt = xlips-mandt.
      xuekes-ebeln = xlips-vgbel.
      xuekes-ebelp = xlips-vgpos.
      xuekes-eindt = xlikp-lfdat.
      xuekes-lpein = '1'.
      xuekes-uzeit = xlikp-lfuhr.
      xuekes-estkz = '4'.
      xuekes-erdat = xlips-erdat.
      xuekes-ezeit = xlips-erzet.
      xuekes-menge = xlips-lfimg.
      xuekes-vbeln = xlips-vbeln.
      xuekes-vbelp = xlips-posnr.
      xuekes-xblnr = xlikp-lifex.
      xuekes-ematn = xlips-ematn.
      xuekes-ekpomeins = xlips-vrkme.
      xuekes-charg = xlips-charg.
      xuekes-uecha = xlips-uecha.
      xuekes-kz    = lep_vorgang.
      xuekes-werks = xlips-werks.                           "n_905551
      xuekes-lgort = xlips-lgort.                           "n_905551
    WHEN updkz_delete.                 "Position wurde gelöscht
      xuekes-mandt = ylips-mandt.
      xuekes-ebeln = ylips-vgbel.
      xuekes-ebelp = ylips-vgpos.
      xuekes-eindt = xlikp-lfdat.
      xuekes-lpein = '1'.
      xuekes-uzeit = xlikp-lfuhr.
      xuekes-estkz = '4'.
      xuekes-erdat = ylips-erdat.
      xuekes-ezeit = ylips-erzet.
      xuekes-menge = ylips-lfimg.
      xuekes-vbeln = ylips-vbeln.
      xuekes-vbelp = ylips-posnr.
      xuekes-xblnr = xlikp-lifex.
      xuekes-ematn = xlips-ematn.
      xuekes-charg = xlips-charg.
      xuekes-uecha = xlips-uecha.
      xuekes-werks = xlips-werks.                           "n_905551
      xuekes-lgort = xlips-lgort.                           "n_905551
      CLEAR xuekes-menge.
ENHANCEMENT-SECTION     MV50AF0B_RETURN_EKES_FUELLEN_3 SPOTS ES_SAPMV50A.
      xuekes-kz    = lep_vorgang.                           "n_1086786
END-ENHANCEMENT-SECTION.
  ENDCASE.

  APPEND xuekes.

* conversion factors                                           "v457360
  CLEAR xekes_conv_qty.

  xekes_conv_qty-ebeln = xlips-vgbel.
  xekes_conv_qty-ebelp = xlips-vgpos.
  xekes_conv_qty-eindt = xlikp-lfdat.
  xekes_conv_qty-vbeln = xlips-vbeln.
  xekes_conv_qty-vbelp = xlips-posnr.
  IF xlips-umrez > xlips-umvkz.
    xekes_conv_qty-umrez = xlips-umvkn.
    xekes_conv_qty-umren = xlips-umvkz * xlips-umren
                                       / xlips-umrez.
  ELSE.
    xekes_conv_qty-umrez = xlips-umvkn * xlips-umrez
                                       / xlips-umvkz.
    xekes_conv_qty-umren = xlips-umren.
  ENDIF.

  APPEND xekes_conv_qty.               "^457360

ENDFORM.                               " RETURN_EKES_AUS_LIPS