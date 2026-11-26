*eject
*---------------------------------------------------------------------*
*       FORM T459K_LESEN                                              *
*---------------------------------------------------------------------*
*       Bedarfssteuerung lesen, verwendet wird VBAP                   *
*---------------------------------------------------------------------*
FORM t459k_lesen.

  LOCAL: xvbep, ivbep1, vbep.
  DATA:  da_bedar LIKE t459k-bedar,
         da_bedae LIKE t459a-bedae,
         da_bedae_non_val LIKE t459a-bedae,                 "EHP606
         da_mntga LIKE t459k-mntga,
         da_lesen.

ENHANCEMENT-POINT T459K_LESEN_01 SPOTS ES_SAPMV45A STATIC.
  PERFORM tvap_select(sapmv45a) USING vbap-pstyv
                                      charx
                                      sy-subrc.
ENHANCEMENT-SECTION     T459K_LESEN_02 SPOTS ES_SAPMV45A.
  IF vbap-werks IS INITIAL OR
    vbap-matnr IS INITIAL.
    CLEAR: t459k, t163k, t459a.
  ELSE.
* Werksdaten aus Material bei Neuanlegen der Position
    IF vbap-bedae IS INITIAL OR
       redetermine_bedae NE space.
      IF *vbap-bedae EQ vbap-bedae AND " = initial
         *vbap-matnr EQ vbap-matnr AND
         matnr_changed IS INITIAL  AND
         *vbap-werks EQ vbap-werks AND
         werks_changed IS INITIAL  AND
         *vbap-pstyv EQ vbap-pstyv.
        IF vbep-posnr NE vbap-posnr.
          READ TABLE ivbep1 WITH KEY vbap-posnr BINARY SEARCH.
          IF sy-subrc = 0.
            READ TABLE xvbep INDEX ivbep1-tabix.
            IF sy-subrc = 0.
              da_bedar+0(2)   = xvbep-bdart.
              da_bedar+2(1)   = xvbep-plart.
            ENDIF.
          ENDIF.
        ELSE.
          da_bedar+0(2)       = vbep-bdart.
          da_bedar+2(1)       = vbep-plart.
        ENDIF.
      ELSE.
*       IF *VBAP-BEDAE IS INITIAL.
        IF *vbap-matnr NE vbap-matnr OR
           NOT matnr_changed IS INITIAL OR
           *vbap-werks NE vbap-werks OR
           NOT werks_changed IS INITIAL OR
           *vbap-pstyv NE vbap-pstyv.
          da_lesen            = charx.
        ENDIF.
      ENDIF.
      IF da_lesen NE space OR
         redetermine_bedae NE space.
        PERFORM maapv_select(sapfv45p) USING vbap-matnr
                                             vbak-vkorg
                                             vbak-vtweg
                                             space
                                             sy-subrc.
        PERFORM maepv_select(sapfv45p) USING vbap-matnr
                                             vbap-werks
                                             vbap-berid
                                             vbap-lgort
                                             space
                                             space
                                             sy-subrc.
        CALL FUNCTION 'RV_SCHEDULING_TYPE_DETERMINE'
          EXPORTING
            f_werks     = vbap-werks
            f_mtart     = maapv-mtart
            f_disgr     = maepv-disgr
            f_strgr     = maepv-strgr
            f_dismm     = maepv-dismm
            f_eterl     = tvap-eterl
            f_pstyv     = vbap-pstyv
            f_vgtyp     = vbap-vgtyp
          IMPORTING
            e_bedae     = da_bedae
            e_msr_bedae = da_bedae_non_val.                 "EHP606

        IF gr_msr_sales IS BOUND.                           "EHP606
          IF cl_ops_switch_check=>ops_sfws_sc_advret2( ) EQ charx AND
             da_bedae_non_val IS NOT INITIAL.
            IF gr_msr_sales->use_non_valuated_stock(
                  iv_fu_code        = gs_msr_sales_item-fu_code
                  iv_refund_control = gs_msr_sales_item-refund_control
                  iv_bukrs_vf       = vbak-bukrs_vf
                  iv_plant          = vbap-werks
                  iv_next_plant     = gs_msr_sales_item-next_plant ) EQ abap_true.
              "use non valuated stock -> change bedae, e.g. 'KE'
              da_bedae = da_bedae_non_val.
            ENDIF.
          ENDIF.
        ENDIF.                                              "EHP606

        CLEAR redetermine_bedae.
      ENDIF.
    ELSE.
      da_bedae = vbap-bedae.
    ENDIF.

    PERFORM t459a_select USING da_bedae
                               charx
                               sy-subrc.
    IF da_bedar IS INITIAL.
      da_bedar                = t459a-bedar.
    ENDIF.
    PERFORM t459k_select(sapfv45v) USING da_bedar
                                         charx
                                         sy-subrc.
    PERFORM t163k_select(sapmv45a) USING t459k-knttp
                                         charx
                                         sy-subrc.

  ENDIF.
END-ENHANCEMENT-SECTION.

ENDFORM.