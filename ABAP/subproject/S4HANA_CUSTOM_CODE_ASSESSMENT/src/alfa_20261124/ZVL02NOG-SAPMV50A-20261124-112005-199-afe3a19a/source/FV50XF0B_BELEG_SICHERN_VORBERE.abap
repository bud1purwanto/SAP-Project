***INCLUDE FV50XF0B_BELEG_SICHERN_VORBERE .
*---------------------------------------------------------------------*
*       FORM BELEG_SICHERN_VORBEREITEN                                *
*---------------------------------------------------------------------*
* Umschlüsselung der Adressnummern jetzt nach der Belegnummernvergabe
*---------------------------------------------------------------------*
FORM beleg_sichern_vorbereiten.

  local: xvbapf[].
*---------------------------------------------------------------------*
*   Beim Hinzufügen können gelöschte Positionen entfernt werden       *
*   Beim Verändern werden die alten Tabellen sortiert                 *
*   aktuelle Tabellen werden sortiert                                 *
*---------------------------------------------------------------------*
  DATA: inri_rcode TYPE c.
  DATA: lv_pbed_reduzieren.

* ******** Für Bedarfsneuaufbau im Sammelgang
  DATA: da_count LIKE sy-tabix,
        da_tabix LIKE sy-tabix,
        da_tabix1 LIKE sy-tabix,
        da_trtyp  LIKE t180-trtyp,
        da_vbeln LIKE vbap-vbeln,
        da_perftune TYPE c VALUE 'X'.

  DATA: BEGIN OF da_xlips OCCURS 0.
          INCLUDE STRUCTURE lipsvb.
  DATA: END OF da_xlips.

  DATA: BEGIN OF da_ylips OCCURS 0.
          INCLUDE STRUCTURE lipsvb.
  DATA: END OF da_ylips.

  DATA: BEGIN OF da_xvbap OCCURS 0.
          INCLUDE STRUCTURE vbapvb.
  DATA: END OF da_xvbap.

  DATA: BEGIN OF da_xvbep OCCURS 0.
          INCLUDE STRUCTURE vbepvb.
  DATA: END OF da_xvbep.

  DATA: BEGIN OF da2_xvbap OCCURS 0.
          INCLUDE STRUCTURE vbapvb.
  DATA: END OF da2_xvbap.

  DATA: BEGIN OF da2_xvbep OCCURS 0.
          INCLUDE STRUCTURE vbepvb.
  DATA: END OF da2_xvbep.

  DATA: ls_atpdi LIKE atpdi.
* ******** Für Bedarfsneuaufbau im Sammelgang

*---------------------------------------------------------------------*
*    Beim Hinzufügen können gelöschte Positionen entfernt werden      *
*---------------------------------------------------------------------*
* AIP:In case YLIPS data exists we have to keep the xlips data
  IF t180-trtyp = charh AND ylips[] IS INITIAL.      "AIP/HOLD
    LOOP AT xlips.
      IF  xlips-updkz = updkz_delete.
        DELETE xlips.
      ENDIF.
    ENDLOOP.
*---------------------------------------------------------------------*
*    Beim Verändern werden die alten Tabellen sortiert                *
*---------------------------------------------------------------------*
  ELSE.

    SORT ylips BY mandt vbeln posnr.
    SORT yvbfa BY mandt vbelv posnv vbeln posnn vbtyp_n.
    SORT yvbpa BY mandt vbeln posnr parvw.

  ENDIF.

*---------------------------------------------------------------------*
*    aktuelle Tabellen werden sortiert                                *
*---------------------------------------------------------------------*

  SORT xlips BY mandt vbeln posnr.
  SORT xvbfa BY mandt vbelv posnv vbeln posnn vbtyp_n.
  SORT xvbpa BY mandt vbeln posnr parvw.
  SORT xvbuk BY mandt vbeln.
  SORT xvbup BY mandt vbeln posnr.

  SORT ylikp BY mandt vbeln.                                 "n_1107402
  SORT yvbuk BY mandt vbeln.
  SORT yvbup BY mandt vbeln posnr.

* Rebuild ILIPS after deleting and sorting items (useful only when a
* single delivery is processed)
  IF v50agl-sammelgang EQ space AND
     v50agl-mult       EQ space.
    REFRESH ilips. CLEAR ilips.

    LOOP AT xlips.
      lips = xlips.
      PERFORM ilips_anlegen(sapfv50p) USING sy-tabix.
    ENDLOOP.
  ENDIF.

* Maintain change date on delivery header and items
  PERFORM maintain_aedat.

* no requirement update with POD
  CHECK sy-tcode NS 'VLPOD'.                                "n_735176

* Wurde für alle anzulegenden Positionen das NOATP-Flag gesetzt?
* Falls ja, ist der Neuaufbau der Bedarfe nicht nötig
  LOOP AT xlips WHERE noatp CA gc_atp_do_req.                "n_876751
    EXIT.
  ENDLOOP.
  CHECK sy-subrc EQ 0.  "mindestens eine Position hat das Flag nicht

  IF v50agl-synchron NE space.
*-reset deltas stored during ATP check, since the delta_put
*-for the final requirements will be called in the same task
    ls_atpdi-atptr = 'DE'.
    CALL FUNCTION 'DELTA_INITIALIZE'
      EXPORTING
        p_atpdi = ls_atpdi
      EXCEPTIONS
        OTHERS  = 1.
  ENDIF.
  ENHANCEMENT-POINT beleg_sichern_vorbereiten_10 SPOTS es_fv50xf0b_beleg_sichern_vorb INCLUDE BOUND.

* Dynamische Felder in XVBAP der Sourcing Hauptpositionen setzen
* für einen Aufbau der Bedarfstabellen und späteren Transfer zum APO.
  PERFORM apo_build_sdsourcing.

* Trigger requirement update in case of APO-relevant changes
  if likp-vbtyp na vbtyp_mmli.
    PERFORM apo_update_without_requ.
  endif.

* Vor dem Neuaufbau der Bedarfe muß die LES-ATP Version abgefragt werden
  DATA atp_type TYPE les_atp_type.
  CALL FUNCTION 'LE_ATP_GET_VERSION'
    IMPORTING
      atp_type = atp_type.

* resorting YLIPS after call of apo_update_without_requ       "n_1226389
  SORT YLIPS BY MANDT VBELN POSNR.                            "n_1226389

  data:          lt_vgbel_lp like xlips-vgbel occurs 0 with header line.
  field-symbols: <ls_xlips>  like line of xlips.
  field-symbols: <ls_xlikp>  like line of xlikp.

  loop at xlikp assigning <ls_xlikp> where klief is initial.
    loop at xlips assigning <ls_xlips> where
                  vbeln eq <ls_xlikp>-vbeln and
                  vgtyp ca vbtyp_lp.

      collect <ls_xlips>-vgbel into lt_vgbel_lp.
    endloop.
  endloop.

  loop at lt_vgbel_lp.

    CALL FUNCTION 'RV_XVBAPF_CREATE'
      EXPORTING
        VBELN                    = lt_vgbel_lp
      TABLES
        FXVBAPF                  = xvbapf
        FXVBFA                   = xvbfa
              .
  endloop.
* Neuaufbau der Vertriebsbedarfe
* Wenn es ein Sammelgang mit mehreren Lieferungen ist muss jeder
* Lieferbeleg einzeln an den RV_REQUIREMENT_GENERAT weitergegeben werden
  DESCRIBE TABLE xlikp LINES da_count.
  IF da_count = 1.
    IF xlikp_updkz NE updkz_delete.                         "n_569626
      IF atp_type EQ charo.
        CALL FUNCTION 'RV_REQUIREMENT_GENERATE'
          EXPORTING
            flikp       = likp
            vkorg_spras = tvko_sadr-spras
          TABLES
            xvbapf      = xvbapf
            yvbfa       = yvbfa
            xvbup       = xvbup
            yvbup       = yvbup
            xvbap       = xvbap
            xvbep       = xvbep
            xlips       = xlips
            ylips       = ylips
            xvbpa       = xvbpa
            avbbd       = avbbd.
      ELSE.
        CALL FUNCTION 'LE_ATP_RV_REQUIREMENT_GENERATE'
          EXPORTING
            flikp       = likp
            vkorg_spras = tvko_sadr-spras
          TABLES
            xvbapf      = xvbapf
            yvbfa       = yvbfa
            xvbup       = xvbup
            yvbup       = yvbup
            xvbap       = xvbap
            xvbep       = xvbep
            xlips       = xlips
            ylips       = ylips
            xvbpa       = xvbpa.
      ENDIF.
    ELSE.                                                   "v_n_569626
      IF atp_type EQ charo.
        CALL FUNCTION 'RV_REQUIREMENT_GENERATE'
          EXPORTING
            flikp       = likp
            vkorg_spras = tvko_sadr-spras
          TABLES
            xvbapf      = xvbapf
            yvbfa       = yvbfa
            xvbup       = xvbup
            yvbup       = yvbup
            xvbap       = xvbap
            xvbep       = xvbep
            xlips       = xlips
            ylips       = ylips
            xvbpa       = yvbpa
            avbbd       = avbbd.
      ELSE.
        CALL FUNCTION 'LE_ATP_RV_REQUIREMENT_GENERATE'
          EXPORTING
            flikp       = likp
            vkorg_spras = tvko_sadr-spras
          TABLES
            xvbapf      = xvbapf
            yvbfa       = yvbfa
            xvbup       = xvbup
            yvbup       = yvbup
            xvbap       = xvbap
            xvbep       = xvbep
            xlips       = xlips
            ylips       = ylips
            xvbpa       = yvbpa.
      ENDIF.
    ENDIF.                                                  "^_n_569626
* Einzel- und Summenbedarfssätze abrufen, die Tabellen sind sortiert
* INCLUDE LV03VC04.
    IF v50agl-warenausg_storno NE space.
      lv_pbed_reduzieren = 'S'.
    ENDIF.
    IF ATP_TYPE EQ CHARO.
      CALL FUNCTION 'RV_REQUIREMENT_SEPARATE'
        EXPORTING
          pbed_reduzieren = lv_pbed_reduzieren
              trtyp           = da_trtyp
        TABLES
          xvbbe           = xvbbe
          xvbbs           = xvbbs
          yvbbe           = yvbbe
          yvbbs           = yvbbs.
    ELSE.
      CALL FUNCTION 'LE_ATP_RV_REQUIREMENT_SEPERATE'
        EXPORTING
          pbed_reduzieren = lv_pbed_reduzieren
              trtyp           = da_trtyp
        TABLES
          xvbbe           = xvbbe
          xvbbs           = xvbbs
          yvbbe           = yvbbe
          yvbbs           = yvbbs.
    ENDIF.
  ELSE.

* XVBAP sortieren
    SORT xvbap BY mandt vbeln posnr.

* Bedarfsneuaufbau pro Lieferbeleg
    LOOP AT xlikp.
      CLEAR:   da_xlips, da_ylips, da_xvbap, da_xvbep, da_vbeln,
               da2_xvbap, da2_xvbep.
      REFRESH: da_xlips, da_ylips , da_xvbap, da_xvbep,
               da2_xvbap, da2_xvbep.

* Wenn mehr als eine Lieferung erzeugt wird, dann darf LV03VU04 nicht
* initialisieren, weil sonst die alten Bedarfe weg sind und deswegen
* der Auftragsbedarf nicht abgebaut wird
      da_trtyp                = t180-trtyp.
      IF SY-TABIX NE DA_COUNT.
        da_trtyp              = charx.
      ENDIF.

* Alle XLIPS-Sätze zu diesem Lieferbeleg
      READ TABLE xlips WITH KEY vbeln = xlikp-vbeln BINARY SEARCH.
      da_tabix = sy-tabix.
      WHILE sy-subrc IS INITIAL AND xlips-vbeln EQ xlikp-vbeln.
        da_tabix = da_tabix + 1.
        MOVE xlips TO da_xlips.
        APPEND da_xlips.
* Alle Auftragspositionen / Einteilungen zu diesem Lieferbeleg, wenn
* nicht schon gelesen
*       SPE OUTB do not read xvbap in case of no order in R/3
        IF da_vbeln NE xlips-vgbel AND NOT xvbap[] IS INITIAL."n_929718
          da_vbeln = xlips-vgbel.
          READ TABLE da_xvbap WITH KEY vbeln = da_vbeln.
          IF sy-subrc NE 0.
            READ TABLE xvbap WITH KEY vbeln = da_vbeln BINARY SEARCH.
            da_tabix1 = sy-tabix.
            WHILE sy-subrc IS INITIAL AND xvbap-vbeln EQ da_vbeln.
              da_tabix1 = da_tabix1 + 1.
              MOVE xvbap TO da_xvbap.
              APPEND da_xvbap.
              READ TABLE xvbap INDEX da_tabix1.
            ENDWHILE.
            READ TABLE xvbep WITH KEY vbeln = da_vbeln BINARY SEARCH.
            da_tabix1 = sy-tabix.
            WHILE sy-subrc IS INITIAL AND xvbep-vbeln EQ da_vbeln.
              da_tabix1 = da_tabix1 + 1.
              MOVE xvbep TO da_xvbep.
              APPEND da_xvbep.
              READ TABLE xvbep INDEX da_tabix1.
            ENDWHILE.

          ENDIF.
        ENDIF.                         "DA_VBELN NE XLIPS-VGBEL
        READ TABLE xlips INDEX da_tabix.
      ENDWHILE.                        "xlips

* Alle YLIPS-Sätze zu diesem Lieferbeleg
      READ TABLE ylips WITH KEY vbeln = xlikp-vbeln BINARY SEARCH.
      da_tabix = sy-tabix.
      WHILE sy-subrc IS INITIAL AND ylips-vbeln EQ xlikp-vbeln.
        da_tabix = da_tabix + 1.
        MOVE ylips TO da_ylips.
        APPEND da_ylips.
        READ TABLE ylips INDEX da_tabix.
      ENDWHILE.                        "ylips

* Bei Sofortauftrag nur den relevanten XVBAP-Satz übergeben
      IF v50agl-sofauftrag EQ charx.
        LOOP AT da_xvbap.
          READ TABLE da_xlips WITH KEY vgbel = da_xvbap-vbeln
                                       vgpos = da_xvbap-posnr.
          IF sy-subrc NE 0.
            LOOP AT da_xvbep WHERE  vbeln = da_xvbap-vbeln AND
                                    posnr = da_xvbap-posnr.
              DELETE da_xvbep.
            ENDLOOP.
            DELETE da_xvbap.
          ENDIF.
        ENDLOOP.
      ENDIF.

* im Fall des Sammelganges sollen aus Performancegründen die
* Schnittstellentabellen so klein wie möglich sein. Bisher
* sind ALLE Positionen und Einteilungen des VorgängerBELEGES
* in der Schnittstelle !
* Der Split wird ausgenommen, da die Bedarfsverrechnung beim Split
* auf den Reorg angewiesen ist und Seiteneffekte vermieden werden sollen
      IF da_perftune EQ charx                AND
         NOT v50agl-sammelgang IS INITIAL    AND
             v50agl-split      IS INITIAL.
* Tabelle der Auftragspositionen verdichten auf die aus Bedarfssicht
* tatsächlich notwendigen.
        SORT da_xvbap BY mandt vbeln posnr.
        LOOP AT da_xlips WHERE vgtyp NE charv.
* direkte Vorgängerposition
          READ TABLE da_xvbap WITH KEY vbeln = da_xlips-vgbel
                                       posnr = da_xlips-vgpos
                                   BINARY SEARCH.
          IF sy-subrc = 0.
            MOVE da_xvbap TO da2_xvbap.
            APPEND da_xvbap TO da2_xvbap.
          ENDIF.
* Spezialfall Produktselektion: nicht nur die Vorgängerposition
* sonder alle Auftrags-UnterPositionen
          IF da_xlips-prosa EQ chara.
            LOOP AT da_xvbap WHERE vbeln EQ da_xlips-vgbel AND
                                   uepos EQ da_xlips-vgpos.
              APPEND da_xvbap TO da2_xvbap.
            ENDLOOP.
          ENDIF.
        ENDLOOP.
* Duplikate löschen welche aufgrund mehrerer Lieferpositionen
* zu unterschiedlichen Einteilungen der selben Auftragsposition
* entstehen können.
        SORT da2_xvbap BY mandt vbeln posnr.
        DELETE ADJACENT DUPLICATES FROM da2_xvbap
            COMPARING mandt vbeln posnr.
* Tabelle der Einteilungen verdichten.
        LOOP AT da_xvbep.
          READ TABLE da2_xvbap WITH KEY vbeln = da_xvbep-vbeln
                                        posnr = da_xvbep-posnr
                                    BINARY SEARCH.
          IF sy-subrc = 0.
            APPEND da_xvbep TO da2_xvbep.
          ENDIF.
        ENDLOOP.
* verdichtete Tabellen als Schnittstelle übernehmen.
        da_xvbap[] = da2_xvbap[].
        da_xvbep[] = da2_xvbep[].
      ENDIF.                          " End of performance interface

      MOVE xlikp TO likp.
      IF atp_type EQ charo.
        CALL FUNCTION 'RV_REQUIREMENT_GENERATE'
          EXPORTING
            flikp       = likp
            vkorg_spras = tvko_sadr-spras
          TABLES
            xvbapf      = xvbapf
            yvbfa       = yvbfa
            xvbup       = xvbup
            yvbup       = yvbup
            xvbap       = da_xvbap
            xvbep       = da_xvbep
            xlips       = da_xlips
            ylips       = da_ylips
            xvbpa       = xvbpa
            avbbd       = avbbd.
      ELSE.
        CALL FUNCTION 'LE_ATP_RV_REQUIREMENT_GENERATE'
          EXPORTING
            flikp       = likp
            vkorg_spras = tvko_sadr-spras
          TABLES
            xvbapf      = xvbapf
            yvbfa       = yvbfa
            xvbup       = xvbup
            yvbup       = yvbup
            xvbap       = da_xvbap
            xvbep       = da_xvbep
            xlips       = da_xlips
            ylips       = da_ylips
            xvbpa       = xvbpa.
      ENDIF.

* Einzel- und Summenbedarfssätze abrufen, die Tabellen sind sortiert
* INCLUDE LV03VC04.

      IF atp_type EQ charo.
        CALL FUNCTION 'RV_REQUIREMENT_SEPARATE'
          EXPORTING
            trtyp = da_trtyp
          TABLES
            xvbbe = xvbbe
            xvbbs = xvbbs
            yvbbe = yvbbe
            yvbbs = yvbbs.
      ELSE.
        CALL FUNCTION 'LE_ATP_RV_REQUIREMENT_SEPERATE'
          EXPORTING
            trtyp = da_trtyp
          TABLES
            xvbbe = xvbbe
            xvbbs = xvbbs
            yvbbe = yvbbe
            yvbbs = yvbbs.
      ENDIF.

    ENDLOOP.                           " xlikp
  ENDIF.
  ENHANCEMENT-POINT beleg_sichern_vorbereiten_11 SPOTS es_fv50xf0b_beleg_sichern_vorb INCLUDE BOUND.


ENDFORM.                    "BELEG_SICHERN_VORBEREITEN