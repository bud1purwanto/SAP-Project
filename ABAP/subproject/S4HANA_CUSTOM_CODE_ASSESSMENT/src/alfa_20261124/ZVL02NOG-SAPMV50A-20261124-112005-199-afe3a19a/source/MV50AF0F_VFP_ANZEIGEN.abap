*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_VFP_ANZEIGEN                                      *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form verfuegbarkeit_anzeigen_neu
*&---------------------------------------------------------------------*
FORM verfuegbarkeit_anzeigen_neu.

* Includieren der Datendeklaration für die Schnittstelle
  INCLUDE shp_atp_intdata.
*>>>>>>>>>> Begin of Insertion HP_331528 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
* ensure that T001W is correctly filled because we need T001W-FABKL
    IF t001w-werks ne lips-werks.
      data: lf_error value space.
      perform t001w_select(sapmv50a) using lips-werks
                                     lf_error
                                     sy-subrc.
      IF sy-subrc <> 0.
        CLEAR t001w.
      ENDIF.
    ENDIF.
*>>>>>>>>>> End of Insertion HP_331528 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

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

  CALL FUNCTION 'LE_ATP_INT_MAP_DEL_TO_ATP'
       EXPORTING
            map_item_control      = charx
            if_handle               = lips-handle
            is_v50agl               = v50agl
*            if_positionsgenerieren  = positionsgenerieren   "not needed
*            if_kz_bedarfe_verechnen = kz_bedarfe_verrechnen "not needed
*            if_kz_pos_detailbild    = kz_chsp_posdetailbild "not needed
*            if_lipsd_updkz          = xlips-updkz           "not needed
*            if_slips_tabix          = slips-tabix           "not needed
*            if_t185f_aktyp        = t185f-aktyp       "not declared
            if_t180_trtyp         = t180-trtyp
            map_item              = charx
            is_likp               = likp
            is_lips               = lips
            is_kuwev              = kuwev
            if_save_287_menge     = save_287_menge
            if_save_287_menge_flo = save_287_menge_flo
            if_kclips_lfimg       = kclips-lfimg
            if_kclips_lgmng       = kclips-lgmng
            if_kclips_lfimg_old   = kclips-lfimg_old
            if_kclips_lgmng_old   = kclips-lgmng_old
            if_t001w_fabkl        = t001w-fabkl
            if_logsyspre          = xvbap-logsysb
            if_besta              = lf_besta
            map_vbak              = charx
            is_cvbak              = cvbak
            read_mat              = charx
       IMPORTING
            es_item_control     = ls_shp_atp_item_control
            es_item               = ls_shp_atp_item
            es_atpvbak            = ls_shp_atp_vbak
            es_mat                = ls_shp_atp_mat
       TABLES
            ftmat                 = lt_shp_atp_mat.

  CALL FUNCTION 'LE_ATP_SHOW'
       EXPORTING
            is_item      = ls_shp_atp_item
            is_i_control = ls_shp_atp_item_control
            is_vbak      = ls_shp_atp_vbak
            is_mat       = ls_shp_atp_mat
       TABLES
            lt_or_vbpa   = cvbpa
            lt_shp_vbpa  = xvbpa
            lt_ekpo      = xekpo
            lt_eket      = xeket.

ENDFORM.