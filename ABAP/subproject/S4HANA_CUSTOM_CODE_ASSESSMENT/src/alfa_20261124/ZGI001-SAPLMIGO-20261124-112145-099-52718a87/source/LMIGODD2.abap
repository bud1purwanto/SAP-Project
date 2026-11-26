*----------------------------------------------------------------------*
*   INCLUDE LMIGODD2                                                   *
*----------------------------------------------------------------------*
CLASS lcl_migo_detail_dest IMPLEMENTATION.

  METHOD pbo_subscreen_select.
  DATA: l_status       TYPE migo_fs_status.
    CASE goitem-sobkz.
       WHEN 'E'.
          g_sub_stock_identifier = '0326'.    "sales order
       WHEN 'Q'.
          g_sub_stock_identifier = '0327'.    "project
       WHEN 'P' OR 'K' OR 'M' OR 'O'.
          g_sub_stock_identifier = '0328'.    "supplier
       WHEN 'T'.
          g_sub_stock_identifier = '0332'.    "SIT
       WHEN 'V' OR 'W'.
          g_sub_stock_identifier = '0329'.    "customer
       WHEN OTHERS.
          g_sub_stock_identifier = '2099'.    "dummy... no
                                              "special stock indicator
          IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL AND
            goitem-bustr = '559'.
            CALL METHOD lcl_migo_screenmodification=>get
              EXPORTING
                i_field          = 'GOITEM-VLIEF_AVIS' "l_goitemname
                i_global_counter = goitem-global_counter
              RECEIVING
                r_status         = l_status.
            IF l_status = 6.
              g_sub_stock_identifier = '0332'.    "SIT
            ENDIF.
          ENDIF.
    ENDCASE.

ENHANCEMENT-POINT EHP604_PBO_SUBSCREEN_SELECT_01 SPOTS ES_SAPLMIGO .

  ENDMETHOD.

  METHOD pai_subscr_chk_sobkz.                                  "1583699
    DATA: lv_vbtyp    TYPE vbtyp,
          lv_sobkz    TYPE sobkz,
          lv_ebeln    TYPE ebeln,
          lv_ebelp    TYPE ebelp,
          lv_sitkz    TYPE sitkz,
          lv_msg      TYPE char50.
    IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL
    AND goitem-bustr = '559'
    AND goitem-vlief_avis IS NOT INITIAL
    AND goitem-vbelp_avis IS NOT INITIAL
    AND ( goitem-sobkz = 'Q' OR goitem-sobkz = 'E' ).
      SELECT SINGLE h~vbtyp i~sobkz i~vgbel i~vgpos i~sitkz
             INTO (lv_vbtyp, lv_sobkz, lv_ebeln, lv_ebelp, lv_sitkz)
             FROM likp AS h INNER JOIN lips AS i
               ON h~vbeln = i~vbeln
             WHERE h~vbeln = goitem-vlief_avis
             AND   i~posnr = goitem-vbelp_avis.
      IF sy-subrc = 0 AND lv_sobkz IS NOT INITIAL.
        CONCATENATE 'Posting will be done with SOBKZ' lv_sobkz
                    INTO lv_msg.
        IF lv_vbtyp = 'J'            "Outbound delivery
        AND ( lv_sitkz = '1' OR lv_sitkz = '2' OR lv_sitkz = 'X' ).
          MESSAGE s468(m7) WITH goitem-sobkz.
          CLEAR goitem-sobkz.
        ELSEIF lv_vbtyp = '7'        "Inbound delivery
        AND cl_mm_im_sit_info=>get_sit_info_item(
               iv_ebeln = lv_ebeln
               iv_ebelp = lv_ebelp ) IS NOT INITIAL.
          MESSAGE s468(m7) WITH goitem-sobkz.
          CLEAR goitem-sobkz.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.

ENDCLASS.