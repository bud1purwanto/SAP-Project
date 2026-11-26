*&---------------------------------------------------------------------*
*&      Form  apo_update_without_requ
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM apo_update_without_requ.

* This FORM checks if an update to APO has to be triggered even without
* a requirement relevant change. If there should be an update it creates
* a line in AVBBD; afterwards there will automatically be an update of
* requirements in R/3 and APO

  INCLUDE shp_atp_val.

  DATA: BEGIN OF wa_xlips_update,
          vbeln LIKE xlips-vbeln,
          posnr LIKE xlips-posnr,
        END OF wa_xlips_update.

  DATA lt_xlips_update LIKE SORTED TABLE OF
                wa_xlips_update WITH UNIQUE DEFAULT KEY.

  DATA: lv_update    TYPE xfeld,
        lv_tabix     TYPE sy-tabix,
        lf_help_lips TYPE lips,
        ls_read      TYPE les_shp_atp_req_read,
        ls_marc      TYPE marc.
  LOCAL: xlikp,
         ylikp,
         likp,
         xvbuk,
         yvbuk.
  FIELD-SYMBOLS <ls_xlips>       LIKE LINE OF xlips.

* - check for active plugin
  CALL FUNCTION 'ND_EXITS_ACTIVE_CHECK'
    EXCEPTIONS
      exits_not_active = 1
      OTHERS           = 2.
  CHECK sy-subrc IS INITIAL.

  LOOP AT xlikp INTO likp
     WHERE updkz NE updkz_new    AND
           updkz NE updkz_delete.

    REFRESH lt_xlips_update.
    CLEAR wa_xlips_update.

*   Check for relevant header changes
    IF NOT ( ylikp[] IS INITIAL AND
             yvbuk[] IS INITIAL ).
      PERFORM check_apo_updtrigger
        USING
          likp-vbeln
          wa_xlips_update-posnr
        CHANGING
          lv_update.
    ENDIF.

    IF NOT lv_update IS INITIAL.
*     Header data changed: send all items to APO
      LOOP AT xlips
         WHERE vbeln EQ likp-vbeln   AND
               updkz NE updkz_new    AND
               updkz NE updkz_delete.

*       check for APO relevant material
        CALL FUNCTION 'MARC_SINGLE_READ'
          EXPORTING
            matnr             = xlips-matnr
            werks             = xlips-werks
          IMPORTING
            wmarc             = ls_marc
          EXCEPTIONS
            lock_on_marc      = 1
            lock_system_error = 2
            wrong_call        = 3
            not_found         = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          CLEAR ls_marc.
        ENDIF.

        CHECK NOT ls_marc-apokz IS INITIAL.

        wa_xlips_update-vbeln = xlips-vbeln.
        wa_xlips_update-posnr = xlips-posnr.
        COLLECT wa_xlips_update INTO lt_xlips_update.
      ENDLOOP.
    ELSE.
*     Check each item individually
      LOOP AT xlips
         WHERE vbeln EQ likp-vbeln   AND
               updkz NE updkz_new    AND
               updkz NE updkz_delete.

*       check for APO relevant material
        CALL FUNCTION 'MARC_SINGLE_READ'
          EXPORTING
            matnr             = xlips-matnr
            werks             = xlips-werks
          IMPORTING
            wmarc             = ls_marc
          EXCEPTIONS
            lock_on_marc      = 1
            lock_system_error = 2
            wrong_call        = 3
            not_found         = 4
            OTHERS            = 5.
        IF sy-subrc <> 0.
          CLEAR ls_marc.
        ENDIF.

        CHECK NOT ls_marc-apokz IS INITIAL.

        PERFORM check_apo_updtrigger
          USING
            likp-vbeln
            xlips-posnr
          CHANGING
            lv_update.

        IF NOT lv_update IS INITIAL.
          wa_xlips_update-vbeln = xlips-vbeln.
          wa_xlips_update-posnr = xlips-posnr.
          COLLECT wa_xlips_update INTO lt_xlips_update.
        ENDIF.

      ENDLOOP.
    ENDIF.

    CHECK lt_xlips_update[] IS NOT INITIAL.
* Starting from here, this design is supposed not to work fine, if several deliveries are
* changed in one transaction (delivery split), because in:
* perform bedarf_aufbauen_versand(saplv03v).
* the avbbd is only read by newpos and e.g. a correct avbbd-kunnr
* is needed to provide a correct vbbe-kunnr.
* After this assumed error during delivery split has been corrected, also this design can be
* extended to comply with several changed deliveries in one transaction.
    LOOP AT xlips ASSIGNING <ls_xlips>
      WHERE updkz NE updkz_delete.

      lv_tabix = sy-tabix.

      READ TABLE lt_xlips_update TRANSPORTING NO FIELDS WITH KEY
        vbeln = <ls_xlips>-vbeln
        posnr = <ls_xlips>-posnr BINARY SEARCH.

      CHECK sy-subrc EQ 0.
      <ls_xlips>-posguid = space.
      <ls_xlips>-posguid+c_pg-apo_upd_no_req-o(c_pg-apo_upd_no_req-l) = charx.

      CALL FUNCTION 'LE_ATP_AVBBD_TESTEXIST'
        EXPORTING
          if_posnr  = <ls_xlips>-posnr
        EXCEPTIONS
          not_found = 1
          OTHERS    = 2.

      CHECK sy-subrc NE 0.

      xlips =  <ls_xlips>.
        slips-tabix = lv_tabix.
        ilips-tabix = lv_tabix.
        lips = xlips.
         *lips = lips.
        PERFORM lips_referenz_lesen(sapfv50p).
        PERFORM lips_bearbeiten_vorbereiten(sapfv50p).

      PERFORM avbbd_fill_new.
    ENDLOOP. "lt_xlips_update
  ENDLOOP. "xlikp

* YLIPS has been updated/appended and so needs to be re-sorted
  SORT YLIPS BY MANDT VBELN POSNR.

ENDFORM.                    "APO_UPDATE_WITHOUT_REQU
*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_APO_UPDATE_WITHOUT_RE                   *
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  AVBBD_FILL_NEW
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM avbbd_fill_new.

*-------this is mainly a copy of
* perform avbbd_fuellen_neu(sapfv50w). " and of
* perform  avbbd_fill_new(saplv53s).

* Datendeklaration für die ATP/Bedarfe Schnittstelle
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


*   zuerst müssen die Lieferdaten auf die ATP Strukturen gemapped werden.
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
            map_vbak                = charx
            is_cvbak                = cvbak
            map_vbapf               = charx
            is_xvbapf               = xvbapf
            read_xvbep              = charx
            is_xvbap                = xvbap
            read_mat                = charx
       IMPORTING
            es_item_control         = ls_shp_atp_item_control
            es_item                 = ls_shp_atp_item
            es_item_old             = ls_shp_atp_item_old
            es_atpvbak              = ls_shp_atp_vbak
            es_atpvbapf             = ls_shp_atp_vbapf
            es_mat                  = ls_shp_atp_mat
       TABLES
            fxvbep                  = xvbep
            ftmat                   = lt_shp_atp_mat
            ftcvbap                 = cvbap.

  CALL FUNCTION 'LE_ATP_INT_MAP_DEL_TO_ATP'
       EXPORTING
            is_likp    = likp
            is_lips    = lips
            read_prosa = charx
       TABLES
            fxvbep     = xvbep
            ftmat      = lt_shp_atp_mat
            ftcvbap    = cvbap.

  CALL FUNCTION 'LE_ATP_AVBBD_FILL'
       EXPORTING
            is_item               = ls_shp_atp_item
            is_item_old           = ls_shp_atp_item_old
            is_vbapf              = ls_shp_atp_vbapf
            is_vbak               = ls_shp_atp_vbak
            is_i_control          = ls_shp_atp_item_control
            is_xvbap              = xvbap
            is_cvbap              = cvbap
            is_mat                = ls_shp_atp_mat
       IMPORTING
            ef_bedarfe_verrechnen = kz_bedarfe_verrechnen
            ef_vbak_vbtyp         = cvbak-vbtyp
       TABLES
            lt_xvbap              = xvbap
            lt_cvbap              = cvbap
            lt_vbep               = xvbep
            lt_vbup               = xvbup
            lt_or_vbpa            = cvbpa
            lt_shp_vbpa           = xvbpa
            lt_vbfa               = xvbfa
            lt_mat                = lt_shp_atp_mat.

ENDFORM.