*----------------------------------------------------------------------*
*   INCLUDE FV50DF0L_AVBBD_PROSA_VERR                                  *
*----------------------------------------------------------------------*
FORM avbbd_prosa_verrechnen_neu.

* Includieren der Deklaration der ATP/Bedarfe Schnittstellenstrukturen
  INCLUDE shp_atp_intdata.

  PERFORM xvbapf_lesen(sapfv50p) USING lips-vgbel
                                     lips-vgpos
                                     sy-subrc.

* Bedarf der ungeprüften Lieferung
  CALL FUNCTION 'LE_ATP_INT_PREPARE_FOR_UCDEL'
       EXPORTING
            ip_create_uclief = v50agl-create_uclief
            ip_ucdel_to_del  = v50agl-ucdel_to_del
            if_mandt         = lips-mandt
            if_vbeln         = lips-vbeln
            if_posnr         = lips-posnr
       IMPORTING
            ef_besta         = lf_besta
            ef_besta_old     = lf_besta_old
       TABLES
            it_xvbup         = xvbup
            it_yvbup         = yvbup.
* Ende der Vorbereitungen für die ungeprüfte Lieferung


*   zuerst müßen die Lieferdaten auf die ATP Strukturen gemapped werden.
  CALL FUNCTION 'LE_ATP_INT_MAP_DEL_TO_ATP'
       EXPORTING
            map_item_control        = charx
            if_handle               = lips-handle
            is_v50agl               = v50agl
            if_positionsgenerieren  = positionsgenerieren
            if_kz_bedarfe_verechnen = kz_bedarfe_verrechnen
            if_kz_pos_detailbild    = kz_chsp_posdetailbild
            if_lipsd_updkz          = xlips-updkz
            if_slips_tabix          = slips-tabix
            if_t185f_aktyp          = t185f-aktyp
            if_t180_trtyp           = t180-trtyp
            map_item                = charx
            is_likp                 = likp
            is_lips                 = lips
            if_save_287_menge       = save_287_menge
            if_save_287_menge_flo   = save_287_menge_flo
            if_kclips_lfimg         = kclips-lfimg
            if_kclips_lgmng         = kclips-lgmng
            if_kclips_lfimg_old     = kclips-lfimg_old
            if_kclips_lgmng_old     = kclips-lgmng_old
*            if_t001w_fabkl          = t001w-fabkl        "not needed
            if_besta                = lf_besta
            map_item_old            = charx
            is_lips_old             = *lips
            is_likp_old             = *likp
            if_besta_old            = lf_besta_old
            map_vbapf               = charx
            is_xvbapf               = xvbapf
       IMPORTING
            es_item_control         = ls_shp_atp_item_control
            es_item                 = ls_shp_atp_item
            es_item_old             = ls_shp_atp_item_old
            es_atpvbapf             = ls_shp_atp_vbapf.

  CALL FUNCTION 'LE_ATP_AVBBD_MAINTAIN'
       EXPORTING
            is_item          = ls_shp_atp_item
            is_item_old      = ls_shp_atp_item_old
            is_i_control     = ls_shp_atp_item_control
            if_maintain_type = charp
            is_vbapf         = ls_shp_atp_vbapf
            is_xvbap         = xvbap.

ENDFORM.