*&---------------------------------------------------------------------*
*&  Include           /SPE/RET_MV50AF0S03                              *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  spe_update_delivery_header
*&---------------------------------------------------------------------*
FORM spe_update_delivery_header
     USING  value(it_verko)    TYPE vsep_t_verko
            value(it_verpo)    TYPE vsep_t_verpo
            is_delivery_update TYPE /spe/ret_delivery_update
            value(it_delivery_batch) TYPE /spe/batch_spljoi_t "v_XAN-SPM
            value(it_delivery_sernr) TYPE /spe/sernr_spljoi_t "^_XAN-SPM
     CHANGING cf_rcode           TYPE sysubrc.           "#EC CI_VALPAR

  DATA: ls_lfa1     TYPE lfa1,
        ls_knvv     TYPE knvv,
        lt_hu_sernr TYPE vsep_t_husernr,
        ls_partner_update TYPE shp_partner_update,
        lt_partner_update TYPE shp_partner_update_t,
        lf_no_lfimg_check_all TYPE c,
        ls_xvbpa_sp TYPE vbpavb,
        ls_xvbpa_we TYPE vbpavb,
        ls_vtcom    TYPE vtcom,
        lf_subrc    TYPE sysubrc,
        lf_msgtxt   TYPE c,
        lv_ca_badi TYPE REF TO /spe/ret_carrier_portal,
        lv_no_badi TYPE REF TO cx_badi_not_implemented,
        lv_mult_impl TYPE REF TO cx_badi_multiply_implemented.

  DATA:   ls_hu_sernr TYPE hum_verpo_sernr,                   "v_XAN-SPM
          ls_rserob TYPE rserob,
          ls_del_anzsn_spli TYPE /spe/delivery_anzsn.

  DATA:   lt_rserob TYPE rserob_t,
          lt_del_anzsn_spli TYPE /spe/delivery_anzsn_t,
          lt_sernos TYPE sernr_t.

  DATA:   lf_status_error TYPE c,
          lf_anzsn TYPE anzsn.

  DATA:   ls_likp TYPE likp,
          ls_likpd TYPE likpd.


  FIELD-SYMBOLS: <ls_xlips> TYPE lipsvb.
  FIELD-SYMBOLS: <fs_delivery_sernr> TYPE /spe/ret_sernr_spljoi.
  FIELD-SYMBOLS: <fs_hu_sernr> TYPE hum_verpo_sernr.
  FIELD-SYMBOLS: <fs_del_anzsn_spli> TYPE /spe/delivery_anzsn.
  FIELD-SYMBOLS: <fs_rserob> TYPE rserob.                     "^_XAN-SPM


  PERFORM likp_bearbeiten_vorbereiten(sapfv50k).

* Get sales area from first delivery item
  LOOP AT xlips ASSIGNING <ls_xlips>
                WHERE vbeln EQ likp-vbeln
                  AND updkz NE updkz_delete.
    rv50a-vtweg = <ls_xlips>-vtweg.
    rv50a-spart = <ls_xlips>-spart.
    EXIT.
  ENDLOOP.

* Change or add forwarding agent of delivery
  IF is_delivery_update-spdnr_upd NE space.
    ls_partner_update-vbeln_vl  = likp-vbeln.
    ls_partner_update-parvw     = 'SP'.
    ls_partner_update-parnr     = is_delivery_update-spdnr.
    READ TABLE xvbpa WITH KEY vbeln = likp-vbeln
                              posnr = '000000'
                              parvw = 'SP'
                     TRANSPORTING NO FIELDS.
    IF sy-subrc NE 0.
      ls_partner_update-updkz_par = 'I'.
    ELSE.
      ls_partner_update-updkz_par = 'U'.
    ENDIF.
    APPEND ls_partner_update TO lt_partner_update.

    CALL FUNCTION 'SHP_DELIVERY_PARTNER_UPDATE'
      EXPORTING
        it_partner_update          = lt_partner_update
        if_vbtyp                   = likp-vbtyp
        if_pargr                   = tvlk-pargr
        if_vkorg                   = likp-vkorg
        if_vtweg                   = rv50a-vtweg
        if_spart                   = rv50a-spart
        if_ignore_update_errors    = space
      TABLES
        ct_xvbpa                   = xvbpa
        ct_yvbpa                   = yvbpa
        ct_xvbadr                  = xvbadr
        ct_yvbadr                  = yvbadr
        ct_xvbuv                   = xvbuv
      EXCEPTIONS
        missing_partner_scheme     = 1
        partner_change_not_allowed = 2
        error_on_partner_change    = 3
        OTHERS                     = 4.
    IF sy-subrc NE 0.
      cf_rcode = 1.
      RETURN.
    ENDIF.
  ENDIF.

* Update delivery after message from ICH portal
  IF is_delivery_update-ich_upd NE space.
*   Delivery confirmed by dealer
    likp-spe_acc_app_sts = gc_spe_ret-acc_app_received.
*Shipment Info Status is always space in standard
    likp-spe_shp_inf_sts = space.

*Shipment Info Status can be changed in CA  --> BEGIN
    TRY.
        GET BADI lv_ca_badi.
      CATCH cx_badi_not_implemented INTO lv_no_badi.
      CATCH cx_badi_multiply_implemented INTO lv_mult_impl.
    ENDTRY.

    IF lv_ca_badi IS BOUND.
      DATA: lt_xvbpa TYPE shp_vbpavb_t.
      APPEND LINES OF xvbpa TO lt_xvbpa.

      CALL BADI lv_ca_badi->determine_distr_to_scem
        EXPORTING
          ip_xvbpa           = lt_xvbpa
          ip_likp            = likp
          ip_rv50a           = rv50a
        IMPORTING
          ep_spe_shp_inf_sts = likp-spe_shp_inf_sts
        EXCEPTIONS
          invalid_carrier    = 1
          invalid_customer   = 2.
      REFRESH lt_xvbpa.
      IF sy-subrc <> 0.
        cf_rcode = 1.
        RETURN.
      ENDIF.
    ENDIF.
*Shipment Info Status can be changed in CA  <-- END

*   Copy accepted quantity to lips-ormng
    lf_no_lfimg_check_all     = v50agl-no_lfimg_check_all.
    v50agl-no_lfimg_check_all = charx.

    LOOP AT xlips WHERE vbeln EQ likp-vbeln
                    AND updkz NE updkz_delete.

      ilips-tabix = sy-tabix.
      slips-tabix = sy-tabix.

      PERFORM lips_bearbeiten_vorbereiten(sapfv50p).
*     If Lean WM is activated to force delivery split by warehouse
*     number ensure that item is not relevant for picking and can
*     be processed in Consolidator Portal
*     Full WM can not be supported in the process
      IF lips-komkz EQ chard.
        lips-nopck = charx.
        lips-komkz = space.
      ENDIF.
      lips-ormng = lips-lfimg.


*     Always delete LIPS-ANZSN for split deliveries           "v_XAN-SPM
*     Serial numbers managed material
      IF NOT xlips-serail IS INITIAL AND
             xlips-updkz = chari     AND
             xlips-anzsn <> 0.
        CLEAR lips-anzsn.
      ENDIF.                                                  "^_XAN-SPM

*     batch creation + update of LIPS-LICHN, LIPS-CHARG       "v_XAN-SPM
*     This should run only in case of a batch managed material
      IF xlips-xchar = charx AND
         xlips-xchpf = charx AND
*        xlips-charg IS INITIAL AND                           "n_1620662
         xlips-updkz = chari.

        PERFORM batch_creation_for_ich USING
                                             likp
                                             xlips
                                    CHANGING it_delivery_batch[]
                                             it_verpo[]
                                             lips-charg
                                             lips-lichn
                                             lf_subrc.
        IF lf_subrc <> 0.
          cf_rcode = 4.
          MESSAGE e131(/spe/ret).
          RETURN.
        ENDIF.
      ENDIF.                                                  "^_XAN-SPM

      PERFORM lips_bearbeiten(sapfv50p).

    ENDLOOP.
    v50agl-no_lfimg_check_all = lf_no_lfimg_check_all.

  ENDIF.

* Update delivery after message from SCEM portal
* If last location is reached no further messages from SCEM are expected
* If no intermediate locations are assigned the distribution to EWM
* should be triggered immediately after first message from SCEM
  IF is_delivery_update-scem_upd NE space.
    IF is_delivery_update-last_location NE space OR
       likp-spe_loc_seq EQ space.
      likp-spe_shp_inf_sts = gc_spe_ret-shp_inf_received.
    ENDIF.
  ENDIF.

* Update truck info
  IF is_delivery_update-traid_upd NE space.
    likp-traid = is_delivery_update-traid.
  ENDIF.

* Update external delivery number
  IF is_delivery_update-lifex_upd NE space.
    likp-lifex = is_delivery_update-lifex.
    likp-spe_lifex_type = gc_lifex_type-returns.
  ENDIF.

* Update planned delivery date
  IF is_delivery_update-lfdat_upd NE space.
    likp-lfdat = is_delivery_update-lfdat.
    likp-lfuhr = is_delivery_update-lfuhr.
  ENDIF.

* Update distribution status of delivery
  PERFORM beleg_verteilung_pruefen USING likp-lgnum
                                         likp-verursys
                                         tvlk-dbtch
                                         likp-vbtyp
                                         likp-spe_acc_app_sts
                                         likp-spe_shp_inf_sts
                                CHANGING likp-vlstk.

* Update delivery header in internal table
  PERFORM likp_bearbeiten(sapfv50k).

* Add packing information to delivery
  IF is_delivery_update-packing_upd NE space.

* Add serial numbers for handling units if available
    IF NOT it_delivery_sernr IS INITIAL.                      "v_XAN-SPM

* Save workareas before serinal number processing
      ls_likp  = likp.
      ls_likpd = likpd.

* Prepare table for handling unit creation & serial numbers creation
* add serial number to the new document (HU'S)
      LOOP AT it_delivery_sernr ASSIGNING <fs_delivery_sernr>.
        ls_hu_sernr-exidv_ob = <fs_delivery_sernr>-exidv_ob.
        ls_hu_sernr-belnr    = <fs_delivery_sernr>-vbeln_new.
        ls_hu_sernr-posnr    = <fs_delivery_sernr>-item_new.
        ls_hu_sernr-sernr    = <fs_delivery_sernr>-sernr.

        APPEND ls_hu_sernr TO lt_hu_sernr.

        MOVE-CORRESPONDING <fs_delivery_sernr> TO ls_del_anzsn_spli.

        ls_del_anzsn_spli-anzsn = 1.

        COLLECT ls_del_anzsn_spli INTO lt_del_anzsn_spli.

      ENDLOOP.

* serial number for HU creation, have to be deleted from original
* delivery document
      LOOP AT lt_del_anzsn_spli ASSIGNING <fs_del_anzsn_spli>.

        CLEAR:  ls_rserob.
        CLEAR:  lt_rserob.
        CLEAR:  lt_sernos.


        ls_rserob-taser    = 'SER01'.
        ls_rserob-lief_nr  = <fs_del_anzsn_spli>-vbeln_old.
        ls_rserob-posnr    = <fs_del_anzsn_spli>-item_old.

* provide assigned serial number per delivery item
        CALL FUNCTION 'GET_SERNOS_OF_DOCUMENT'
          EXPORTING
            key_data            = ls_rserob
            status_pre_read     = ' '
          TABLES
            sernos              = lt_rserob
          EXCEPTIONS
            key_parameter_error = 1
            no_supported_access = 2
            no_data_found       = 3
            OTHERS              = 4.

* reset ANZSN (quantity of serial numbers)

        CLEAR: lf_anzsn.

* Loop over assigned serial numbers of original delivery item
        LOOP AT lt_rserob ASSIGNING <fs_rserob>.

* Read if such a serial number will be assigned to a new document
          READ TABLE lt_hu_sernr TRANSPORTING NO FIELDS WITH KEY
                                      sernr = <fs_rserob>-sernr.

* if serial number won't be assigned to a new document it must be
* reassigned to the original document
          IF sy-subrc <> 0.
            lf_anzsn = lf_anzsn + 1.
            APPEND <fs_rserob>-sernr TO lt_sernos.
          ENDIF.
        ENDLOOP.

* delete all serial numbers of original delivery item
        CALL FUNCTION 'DELETE_SERNR_LS'
          EXPORTING
            j_vorgang          = 'PMSA'
            vbeln              = <fs_del_anzsn_spli>-vbeln_old
            posnr              = <fs_del_anzsn_spli>-item_old
          IMPORTING
            status_not_allowed = lf_status_error.

* read original delivery item for update of field ANZSN
*         READ TABLE xlips ASSIGNING <ls_xlips> WITH KEY
*                                vbeln = <fs_del_anzsn_spli>-vbeln_old
*                                posnr = <fs_del_anzsn_spli>-item_old.


        LOOP AT xlips WHERE vbeln = <fs_del_anzsn_spli>-vbeln_old AND
                            posnr = <fs_del_anzsn_spli>-item_old.

          IF sy-subrc = 0.
            ilips-tabix = sy-tabix.
            slips-tabix = sy-tabix.

*...fill the correct delivery header to the workareas, we need the old
*   one
            LOOP AT xlikp WHERE vbeln = <fs_del_anzsn_spli>-vbeln_old.
              MOVE-CORRESPONDING xlikp TO likp.
              MOVE-CORRESPONDING xlikp TO likpd.
            ENDLOOP.


            PERFORM lips_bearbeiten_vorbereiten(sapfv50p).

            lips-anzsn = lf_anzsn.
            CLEAR: lf_anzsn.

* reassign remaining serial numbers to original delivery item
* update field lips-anzsn

            CALL FUNCTION 'SERNR_ADD_TO_LS'
              EXPORTING
                profile               = lips-serail
                material              = lips-matnr
                m_charge              = lips-charg
                quantity              = lips-anzsn
                j_vorgang             = 'PMS3'
                cuobj                 = lips-cuobj
                document              = lips-vbeln
                item                  = lips-posnr
                debitor               = likp-kunnr
                vbtyp                 = likp-vbtyp
                bwart                 = lips-bwart
              IMPORTING
                anzsn                 = lips-anzsn
*             zeilen_id             = lf_line_id
              TABLES
                sernos                = lt_sernos
              EXCEPTIONS
                serialnumber_errors   = 1
                serialnumber_warnings = 2.

            IF cf_rcode NE 0.
              cf_rcode = 5.
              RETURN.
            ENDIF.

            PERFORM lips_bearbeiten(sapfv50p).
          ENDIF.
        ENDLOOP.
      ENDLOOP.
    ENDIF.

    IF NOT ls_likp IS INITIAL.
      MOVE-CORRESPONDING ls_likp  TO xlikp.
      MOVE-CORRESPONDING ls_likpd TO xlikp.
*RS 20050915 Begin of 879699
      likp  = ls_likp.
      likpd = ls_likpd.
*RS 20050915 End of 879699
    ENDIF.                                                    "^_XAN-SPM

    PERFORM delivery_packing(sapmv50a) USING    space
                                                xlikp
                                       CHANGING it_verko[]
                                                it_verpo[]
                                                lt_hu_sernr
                                                cf_rcode.
    IF cf_rcode NE 0.
      cf_rcode = 2.
      MESSAGE e135(/spe/ret).
      RETURN.
    ENDIF.
*   Check packing status of items
    LOOP AT xvbup TRANSPORTING NO FIELDS
                  WHERE vbeln EQ likp-vbeln
                    AND pksta NA ' C'.
      EXIT.
    ENDLOOP.
    IF sy-subrc EQ 0.
      cf_rcode = 6.
      MESSAGE e615(vl).
      RETURN.
    ENDIF.
  ENDIF.

ENDFORM.                    " spe_update_delivery_header