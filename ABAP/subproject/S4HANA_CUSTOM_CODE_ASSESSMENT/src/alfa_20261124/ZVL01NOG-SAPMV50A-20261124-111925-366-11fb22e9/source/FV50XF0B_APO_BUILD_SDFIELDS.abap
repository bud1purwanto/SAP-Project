*---------------------------------------------------------------------*
*        FORM APO_BUILD_SDFIELDS
*---------------------------------------------------------------------*
form apo_build_sdfields tables et_sdfields   structure atpfield
                        using  iv_shpapoorig type      shpapoorig.
* SHP APO ORIG = B -> reverse goods issue -> process delivery doc only

  data:
    kssk_tab        type rmclkssk occurs 0 with header line,
    lv_timestamp    type timestamp,
    lv_timezone     like ttzdata-tzone,
    lv_is_sto       type xfeld.

  DATA: BEGIN OF lt_sales OCCURS 0,
    vbeln TYPE vbeln,
    posnr TYPE posnr.
  DATA: END OF  lt_sales.
  DATA:
    ls_sales     LIKE lt_sales,
    ls_atpfield  TYPE atpfield,
    et_atpfield  TYPE atpfield OCCURS 0,
    et_atpfield2 TYPE atpfield OCCURS 0.

  include shp_atp_val.

  local:
    xvbuk,
    xvbup,
    vbuk.

  call function 'CLFM_GET_INTERNAL_TABLES'
    exporting
      i_allkssk    = charx
    tables
      exp_kssk_tab = kssk_tab.

  loop at xlips.

*   Check/Read Header data
    if xlikp-vbeln ne xlips-vbeln.
      read table xlikp with key mandt = xlips-mandt
                                vbeln = xlips-vbeln.
    endif.
    likp = xlikp.
    if vbuk-vbeln ne likp-vbeln.
      perform xvbuk_lesen(sapfv50k) using likp-vbeln.
    endif.

*   Process the delivery document:
    if xlips-updkz    eq updkz_new                   "Create delivery
    or xlips-updkz    eq updkz_update                "Change delivery
    or iv_shpapoorig  eq charb                       "Reverse goods movement
    or ( xlips-posguid+c_pg-char0-o(c_pg-char0-l) eq space and   "NOREQ-update
         xlips-posguid+c_pg-apo_upd_no_req-o(c_pg-apo_upd_no_req-l) eq charx ).

*     Fill CUOBJ_CH (KFDNA = APO_SD_LIPS_CUOBJ_CH)
      if not xlips-cuobj_ch is initial.
        call function 'VBXD_CUOBJ_CBATP_CHECK_AND_SET'
          exporting
            i_material       = xlips-matnr
            i_batch          = xlips-charg
            i_plant          = xlips-werks
          changing
            c_cuobj_ch       = xlips-cuobj_ch  "input & output
          exceptions
            unknown_cuobj_ch = 4.
        if sy-subrc ne 0.
          clear xlips-cuobj_ch. "note: CUOBJ_CH will not be transferred
        endif. "sy-subrc
      endif. "NOT VALUE_CUOBJ_CH IS INITIAL.

      perform apo_sdfields
           tables et_sdfields
                  kssk_tab
           using  xlips-vbeln           "Beleg
                  xlips-posnr           "Position
                  likp-vbtyp            "Belegtyp
                  updkz_new             "Methode
                  'APO_SD_LIPS_CUOBJ'   "KFDNA_CUOBJ
                  'APO_SD_LIPS_CUOBJ_CH'"KFDNA_CUOBJ_CH
                  xlips-cuobj           "VALUE_CUOBJ
                  xlips-cuobj_ch.       "VALUE_CUOBJ_CH

*     Shipping information for TP/VS
      perform ship_info_to_atpfield tables et_sdfields
                                    using  xlips-vbeln
                                           xlips-posnr.

*     One-time Ship-To party Address
      perform apo_sdfields_osta tables et_sdfields
                                using  xlips-vbeln
                                       xlips-posnr.

*     SPE OUTB - ship data for bop_guid, roc etc.
      perform spe_ship_data_to_atpfield tables et_sdfields[]
                                        using  xlips-vbeln
                                               xlips-posnr.

*     SPE STO - additional ROC filter criteria
      call function '/SPE/STO_REPL_DELIV_CHECK'
        exporting
          is_likpvb       = xlikp
          is_lipsvb       = xlips
        importing
          e_is_repl_deliv = lv_is_sto.

      if lv_is_sto eq charx.
        perform /spe/add_filter_criteria
             tables et_sdfields[]
             using  xlips-vbeln
                    xlips-posnr.
      endif.

*     EhP 3: Direct outbound delivery processing            "v_n_1356261
*     DIRDLV additional ROC filter criteria
      if likp-spe_le_scenario eq gc_le_scenario-dircus.
        perform /spe/dirdlv_add_filter_crit
              tables
                 et_sdfields
              using
                 xlips-vbeln
                 xlips-posnr.
      endif.                                                "^_n_1356261

*     SPE Posting Change Delivery - add scrap indicator to field catalog
      if not xlips-spe_scrap_ind is initial.
        perform /spe/sse_append_scrap_ind tables et_sdfields
                                          using  xlips-vbeln
                                                 xlips-posnr
                                                 xlips-spe_scrap_ind.
      endif.

*     SPE OUTB fill atpfield information for requirement update
      perform spe_add_field_for_requirement tables et_sdfields
                                                   ylikp
                                                   ylips
                                            using  likp
                                                   xlips
                                                   v50agl.

    endif. "IF XLIPS-UPDKZ   EQ UPDKZ_NEW      "Create delivery
    "OR XLIPS-UPDKZ   EQ UPDKZ_UPDATE   "Change delivery
    "OR IV_SHPAPOORIG EQ CHARB.         "Reverse goods movement
    "OR XLIPS-POSGUID ...               "NOREQ-update

    IF XLIPS-UPDKZ   EQ UPDKZ_DELETE OR
       IV_SHPAPOORIG EQ CHARA.
*     Update Shipping information for TP/VS also in this case
      perform ship_info_to_atpfield tables et_sdfields
                                    using  xlips-vbeln
                                           xlips-posnr.
    endif.

*   Process the sales document:
*   (if preceeding document exists and is a sales document):
    if not xlips-vgbel is initial
    and xlips-vgtyp ca vbtyp_verk.

      read table xvbap with key mandt = xlips-mandt
                                vbeln = xlips-vgbel
                                posnr = xlips-vgpos.
      if sy-subrc eq 0.

        if  xlips-updkz eq updkz_new
         or xlips-updkz eq updkz_update
         or xlips-updkz eq updkz_delete.

          perform xvbup_lesen(sapfv50p) using xlips-vgbel
                                            xlips-vgpos.
          if xvbup-lfgsa ca 'AB'.

            perform apo_sdfields
                 tables et_sdfields
                        kssk_tab
                 using  xlips-vgbel         "Beleg
                        xlips-vgpos         "Position
                        xlips-vgtyp         "Belegtyp
                        updkz_update        "Methode
                        'APO_SD_CUOBJ'      "KFDNA_CUOBJ
                        'APO_SD_CUOBJ_CH'   "KFDNA_CUOBJ_CH
                        xvbap-cuobj         "VALUE_CUOBJ
                        xvbap-cuobj_ch.     "VALUE_CUOBJ_CH

          endif.

*         Determine goods issue dates for sales document
*         (APO_SD_GID_EXT....GOISSUE_DATE) per schedule line
          call function 'SD_TZONE_ADDRESS'
            exporting
              if_plant    = xlips-werks
            importing
              ef_timezone = lv_timezone
            exceptions
              others      = 7.
          if sy-subrc ne 0.
            lv_timezone = sy-zonlo.
          endif. "IF SY-SUBRC NE 0.
          loop at xvbep where vbeln eq xlips-vgbel
                      and   posnr eq xlips-vgpos
                      and   not wadat is initial.
            clear lv_timestamp.
            convert date xvbep-wadat
                  time xvbep-wauhr
             into time stamp lv_timestamp
                  time zone  lv_timezone.
            et_sdfields-delnr        = xlips-vgbel.
            et_sdfields-delps        = xlips-vgpos.
            et_sdfields-kfdna(14)    = 'APO_SD_GID_EXT'.
            et_sdfields-kfdna+14(4)  = xvbep-etenr.
            et_sdfields-kfdna+18(12) = 'GOISSUE_DATE'.
            et_sdfields-value        = lv_timestamp.
            append et_sdfields.
          endloop.

*         Add BSTNK from preceding sales document also for delivery
          if vbak-vbeln = xlips-vgbel.
            et_sdfields-delnr = xlips-vbeln.
            et_sdfields-delps = xlips-posnr.
            et_sdfields-kfdna = 'BSTNK'.
            et_sdfields-value = vbak-bstnk.
            append et_sdfields.
          endif.

        endif. "IF  XLIPS-UPDKZ EQ UPDKZ_NEW
        " OR XLIPS-UPDKZ EQ UPDKZ_UPDATE
        " OR XLIPS-UPDKZ EQ UPDKZ_DELETE.

*       Information for TP/VS is always needed (also during GI
*       or reverse GI)

*       Shipping information for TP/VS
        perform ship_info_to_atpfield tables et_sdfields
                                      using  xlips-vgbel
                                             xlips-vgpos.

*       One-time Ship-To party Address
        perform apo_sdfields_osta tables et_sdfields
                                  using  xlips-vgbel
                                         xlips-vgpos.

        IF IV_SHPAPOORIG = 'B'.
*         when posting goods issue storno sales order VBBE can be rebuild
*         if so then all sales order data has to be send back to SCM
*         a) collect sales order and item number
          ls_sales-vbeln = XLIPS-VGBEL.
          ls_sales-posnr = XLIPS-VGPOS.
          APPEND ls_sales TO lt_sales.
        ENDIF.

      endif. "SY-SUBRC EQ 0.

*     Process also subitems of preceding documents
      loop at xvbap where mandt = xlips-mandt and
                          vbeln = xlips-vgbel and
                          uepos = xlips-vgpos.

        perform xvbup_lesen(sapfv50p) using xvbap-vbeln
                                            xvbap-posnr.

*       Only if the subitem is not deliverable itself
        check xvbup-lfgsa is initial.

*       Only if requirements are transfered to APO
        read table xvbbe with key vbeln = xvbap-vbeln
                                  posnr = xvbap-posnr
                         transporting no fields.
        check sy-subrc is initial.

*       Build minimal catalogue (only TP/VS-information)
        perform ship_info_to_atpfield tables et_sdfields
                                      using  xvbap-vbeln
                                             xvbap-posnr.

      endloop.

    endif. "IF NOT XLIPS-VGBEL IS INITIAL
    "   AND XLIPS-VGTYP CA VBTYP_VERK.

  endloop. "LOOP AT XLIPS

  IF NOT lt_sales[] IS INITIAL.
*   b) add field catalog for predecessor sales document
    SORT lt_sales.
    DELETE ADJACENT DUPLICATES FROM lt_sales.
    LOOP AT lt_sales INTO ls_sales.
      AT NEW vbeln.
        CALL FUNCTION 'ATP_CATALOGUE_EXTRACT_NEW'
          EXPORTING
            iv_vbeln     = ls_sales-vbeln
          TABLES
            et_atpfield  = et_atpfield.
        APPEND LINES OF et_atpfield TO et_atpfield2.
        REFRESH et_atpfield[].
      ENDAT.
    ENDLOOP.
    SORT et_atpfield2 BY delnr delps kfdna.
    DELETE et_atpfield2 WHERE value IS INITIAL.
    DELETE ADJACENT DUPLICATES FROM et_atpfield2.
    LOOP AT lt_sales INTO ls_sales.
      READ TABLE et_atpfield2
        WITH KEY delnr = ls_sales-vbeln
                 delps = ls_sales-posnr
        TRANSPORTING NO FIELDS
        BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        LOOP AT et_atpfield2 INTO ls_atpfield FROM sy-tabix.
          IF ls_atpfield-delnr <> ls_sales-vbeln OR
            ( ls_atpfield-delnr = ls_sales-vbeln AND
              ls_atpfield-delps <> ls_sales-posnr ).
            EXIT.
          ENDIF.
          APPEND ls_atpfield TO et_sdfields.
        ENDLOOP.
      ENDIF.
    ENDLOOP.
    REFRESH et_atpfield2[].
    SORT et_sdfields BY delnr delps kfdna.
  ENDIF.

endform.                    "APO_BUILD_SDFIELDS