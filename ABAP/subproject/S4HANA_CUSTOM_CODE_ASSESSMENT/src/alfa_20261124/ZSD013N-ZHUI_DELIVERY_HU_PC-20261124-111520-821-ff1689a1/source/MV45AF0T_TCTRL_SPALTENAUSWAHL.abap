*&---------------------------------------------------------------------*
*&      Form  TCTRL_SPALTENAUSWAHL.
*&---------------------------------------------------------------------*
*       Im Tablecontrol werden bestimmte Spalten ausgeblendet.
*       Dazu wird die Feldauswahl interpretiert.
*       Die Verarbeitung wird auf Ebene der Spaltenüberschrift
*       durchgeführt. Dort ist sy-stepl = 0.
*       Wenn die Spaltenüberschrift ausgeblendet ist, dann entfällt
*       die ganze Spalte
*----------------------------------------------------------------------*
FORM tctrl_spaltenauswahl.

  CHECK: sy-stepl = 0 AND
         ( sy-dynnr(2) EQ '49' OR
           sy-dynnr(4) EQ '4422' OR
         ( sy-dynnr(4) EQ '4500' AND screen-name EQ '*VBEP-ROMS1' ) ).

  DATA: da_name LIKE screen-name,
        da_lfdst TYPE lfdst,
        da_invisible.


* Umsetzung Name des Überschriftsfelds -> Name der Spalte
  da_name = screen-name.
* Überschrift ist *-Feld zum eigentlichen Spaltennamen
  IF da_name(1) = '*'.
    SHIFT da_name LEFT.
  ENDIF.
* Überschrift der Status-Ankreuzfelder
  IF da_name CP 'STTXT-T++'.
    MOVE da_name TO da_lfdst.
    CONCATENATE 'RV45A-STAT' da_lfdst INTO da_name.
  ENDIF.

* Advanced Returns related table control fields
  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) EQ charx.
    IF tctrl_name = 'TCTRL_U_ERF_AUFTRAG'.
      IF screen-group4 = 'MSR'.
        IF screen-invisible = 1.
          da_invisible = charx.
        ENDIF.
        IF da_name CS if_msr_trc_c=>gc_scr_name_sd_column AND NOT
         ( da_name CS '_SALES_ITEM-REPLACE_MATNR' OR da_name CS '_SALES_ITEM-PAYING_PLANT' ).
          REPLACE if_msr_trc_c=>gc_scr_name_sd_column IN da_name WITH if_msr_trc_c=>gc_scr_name_sd_field IN CHARACTER MODE.
        ENDIF.
        PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_auftrag-cols
                                   USING  da_name
                                          da_invisible.
      ENDIF.
      IF da_name EQ 'VBAP-KWMENG' OR
         da_name EQ 'VBAP-VRKME'.
        CLEAR da_invisible.
        IF tvak-kopgr EQ 'GA'.
          da_invisible = charx.
        ENDIF.
        IF da_name EQ 'VBAP-KWMENG'.
          da_name = 'RV45A-KWMENG'.
        ENDIF.
        PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_auftrag-cols
                                   USING da_name
                                         da_invisible.
      ENDIF.
      IF da_name EQ 'VBAP-ZMENG' OR
         da_name EQ 'VBAP-ZIEME'.
        CLEAR da_invisible.
        IF tvak-kopgr NE 'GA'.
          da_invisible = charx.
        ENDIF.
        PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_auftrag-cols
                                   USING da_name
                                         da_invisible.
      ENDIF.
    ENDIF.
  ENDIF.

* Predefined Price Elements
  IF da_name(10) = 'TDS_VA_PPE'.
    IF NOT cl_sd_switch_check=>sd_sfws_ui3_o2c( ) IS INITIAL.
      IF screen-active = 0.
        da_invisible = charx.
      ENDIF.
      IF tctrl_name = 'TCTRL_U_ERF_AUFTRAG'.
        PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_auftrag-cols
                                   USING  da_name
                                          da_invisible.
      ENDIF.
    ENDIF.
  ENDIF.

* Nur für bestimmte Felder werden die Spalten beeinflußt:
ENHANCEMENT-SECTION     TCTRL_SPALTENAUSWAHL_10 SPOTS ES_SAPMV45A.
  CHECK: ( da_name = 'VBKD-WAKTION' OR
           da_name = 'VBKD-ZTERM' OR
           da_name = 'VBAP-VRKME' OR
           da_name = 'VBAP-ABLFZ' OR
           da_name = 'VBAP-KZTLF' OR
           da_name = 'VBEP-SERNR' OR
           da_name = 'VBEP-ROMS1' OR
           da_name = 'VBAP-SKOPF' OR
           da_name = 'VBAP-PRODH' OR
           da_name = 'VBAPD-MATNR_G' OR
           da_name = 'VBAPD-ARKTX_G' OR
           da_name = 'VBAPD-MENGE_G' OR
           da_name = 'MATERW' OR
           da_name = 'VBEPD-OLFMNG' OR
           da_name = 'VBAP-MATNR' OR
           da_name = 'VBAP-IUID_RELEVANT' OR     "EHP3, no need to switch
           da_name = 'VBKD-WMINR' OR
           da_name = 'RV45A-CCODE' ) OR
* In der Versandübersicht bei Lieferplänen müssen die Einteilungsdaten
* ausgeblendet werden
         ( vbak-vbtyp CA vbtyp_lp AND
           tctrl_name EQ 'TCTRL_UEIN_VERSAND' AND
           da_name(4) = 'VBEP' ) OR
           da_name CP 'RV45A-STAT++' OR
           da_name(9) = 'RV45A-PVS'  OR
           da_name(9) = 'VBAPD-PVH'.
END-ENHANCEMENT-SECTION.

* Produktvorschlag
  IF da_name(9) = 'RV45A-PVS'.
    REPLACE 'RV45A-PVS' WITH 'VBAPD-PVMNG' INTO da_name.
  ENDIF.

  IF screen-active = 0 OR
     screen-invisible = 1.
    da_invisible = charx.
  ENDIF.

  CASE tctrl_name.
    WHEN: 'TCTRL_U_ERF_AUFTRAG'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_auftrag-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_BEST_AUFTRAG'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_best_auftrag-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_GUTLAST'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_gutlast-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_BEST_GUTLAST'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_best_gutlast-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_MAIS'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_mais-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_LIEFERPLAN'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_lieferplan-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_KONTRAKT'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_kontrakt-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_WERTKONTRAKT'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_wertkontrakt-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_WKONTRAKT_OS'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_wkontrakt_os-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_ANGEBOT'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_angebot-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_KDPRBD'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_kdprbd-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_ERF_LPZULI'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_erf_lpzuli-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_UEIN_BESCHAFFUNG'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_uein_beschaffung-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_UEIN_VERSAND'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_uein_versand-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_UPOS_ABSAGE'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_upos_absage-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_PEIN'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_pein-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_PEIN_ABRUF'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_pein_abruf-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_POS_STRUKTUR'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_pos_struktur-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_TEXTE'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_texte-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_SORTIMENT'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_sortiment-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_KOPIEREN'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_kopieren-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_RELEV_POS'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_relev_pos-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_GRUKO'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_gruko-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_WSOP'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_wsop-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_WK_KOPIER'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_wk_kopier-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_WK_KOPIER_EING'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_wk_kopier_eing-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_P_AENDST_DT'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_p_aendst_dt-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_P_AENDST_FZ'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_p_aendst_fz-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_BST_WERTKONTRAKT'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_bst_wertkontrakt-cols
                             USING  da_name
                                    da_invisible.
    WHEN: 'TCTRL_U_BST_WKONTRAKT_OS'.
      PERFORM tctrl_spaltenmodif TABLES tctrl_u_bst_wkontrakt_os-cols
                             USING  da_name
                                    da_invisible.
  ENDCASE.

ENHANCEMENT-POINT TCTRL_SPALTENAUSWAHL_03 SPOTS ES_SAPMV45A.

ENDFORM.                    "TCTRL_SPALTENAUSWAHL