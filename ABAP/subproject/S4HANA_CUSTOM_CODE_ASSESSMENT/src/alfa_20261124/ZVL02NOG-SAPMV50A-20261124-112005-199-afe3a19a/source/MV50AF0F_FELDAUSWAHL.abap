*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FELDAUSWAHL                                       *
*----------------------------------------------------------------------*
FORM feldauswahl.

  CONSTANTS: lc_loop(3) TYPE c VALUE 'LOO'.

  TYPE-POOLS: vrm.                                        "SIT

  DATA: lt_dlfld LIKE dlfld OCCURS 0 WITH HEADER LINE,
        lf_dyngr TYPE sydyngr,
        lt_field_attrib TYPE shp_screen_attributes_t,
        ls_field_attrib TYPE shp_screen_attributes,
        lf_badi_active  TYPE c,
        lf_exit_flag    TYPE c,
        lf_hu_flag TYPE xfeld,                              "n_609445
        lf_rescheduling_active TYPE c,
        lf_cmact TYPE xfeld,                                "n_921209
        it_value_tab TYPE vrm_values,                        "SIT
        wa_value_tab TYPE vrm_value,                         "SIT
        lf_ettyp LIKE vbep-ettyp,                            "SIT
        lv_sitbw LIKE lips-bwart,                            "SIT
        lv_bwart LIKE lips-bwart,                            "SIT
        lv_outin TYPE flag.                                  "SIT
  DATA: lv_ebeln TYPE ebeln,                                 "SIT2
        lv_ebelp TYPE ebelp,
        ls_ekpo  TYPE ekpo,
        lv_bustr TYPE bustr,
        lv_bwcnt TYPE i,
        lt_tvep  TYPE STANDARD TABLE OF tvep,
        ls_t156  TYPE t156,
        ls_t156o TYPE t156.
  FIELD-SYMBOLS: <ls_vbfa> LIKE LINE OF xvbfa,               "SIT
                 <ls_lips> LIKE LINE OF xlips,
                 <ls_tvep> TYPE tvep.

  lf_dyngr = sy-dyngr.


ENHANCEMENT-POINT MV50AF0F_FELDAUSWAHL_01 SPOTS ES_SAPMV50A.


* For empty step loop lines the field properties need not to be
* determined in all cases
ENHANCEMENT-SECTION     MV50AF0F_FELDAUSWAHL_02 SPOTS ES_SAPMV50A.
  IF sy-stepl NE 0                     AND                  "v_n_530542
     lips-posnr IS INITIAL             AND
     ( xlips_umfang NE xlips_umfang_ucha OR
       taxi_screen_group(1) NE 'W' )   AND
     likp-vlstk EQ space               AND
     vbuk-wbstk CA ' A'                AND
     vbuk-fkstk CA ' A'                AND
     vbuk-fkivk CA ' A'                AND
* SPE Returns
     likp-vbtyp NE vbtyp_lire          AND
     taxi_panel NE 'CHSP'              AND                  "n_572888
     t180-trtyp CA 'HV'.
    EXIT.
  ENDIF.                                                    "^_n_530542
END-ENHANCEMENT-SECTION.

* change management active for this delivery?               "v_n_921209
  IF NOT v50agl-dlv_change IS INITIAL AND
         v50agl-dlv_change_off IS INITIAL AND
     ( ( NOT likp-verursys IS INITIAL AND likp-vlstk EQ chara ) OR
       (     likp-verursys IS INITIAL AND likp-vlstk EQ charb ) ).
    lf_cmact = 'X'.
  ENDIF.                                                    "^_n_921209

* Distributed delivery: read not-changeable fields if change management
* is not active
  IF NOT likp-verursys IS INITIAL AND
     lf_cmact IS INITIAL.                                   "n_921209
    PERFORM dlfld_data_read TABLES lt_dlfld
                            USING  likp-handle.
  ENDIF.

* Call BAdI for influencing field attributes
  PERFORM call_badi_change_field_attrib CHANGING lt_field_attrib.
  IF NOT lt_field_attrib[] IS INITIAL.
    lf_badi_active = charx.
  ENDIF.

  LOOP AT SCREEN.

*   If field is one of the tab strip buttons: always active
    IF screen-group4 EQ 'TAB'.
      CONTINUE.
    ENDIF.

*   Exit if field is on the step loop and step loop is not active
    IF screen-group2 EQ lc_loop.
      CHECK sy-stepl NE 0.
    ELSE.
      CHECK sy-stepl EQ 0.
    ENDIF.

*   Check for fields that need no modification
    IF lf_dyngr EQ 'LIST'   AND
       ( screen-name(5) = '*LIPS' OR
         screen-name(5) = 'D301T' OR
         screen-name(5) = 'FCODE' OR
         screen-name(6) = 'STRICH' ).
      IF screen-name <> '*LIPS-LICHN'.
        CONTINUE.
      ENDIF.
    ENDIF.

    IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.          "v_SIT

      IF screen-name = 'GV_XSIT' AND NOT gv_sit_flag IS INITIAL AND
        gv_sit_cancel_flag IS INITIAL.

        IF vbuk-wbstk  = charc AND vbuk-pdstk = charc AND fcode = gc_fcode_podquit.
          screen-invisible = 0.
          screen-input = 0.
        ENDIF.

        IF vbuk-wbstk  = charc AND vbuk-pdstk = chara  AND fcode = gc_fcode_podstor.
          screen-invisible = 0.
        ENDIF.

        IF vbuk-wbstk  = chara AND vbuk-pdstk = chara  AND fcode = gc_fcode_podstor
        AND likp-vbtyp = vbtyp_lire.
          screen-invisible = 0.
        ENDIF.

        IF vbuk-wbstk  = charc AND vbuk-pdstk = chara  AND fcode = 'ENT1' OR fcode = 'UPOD_T'.
          screen-invisible = 0.
        ENDIF.

      ENDIF.

      IF screen-name = 'LIKP-PODAT'.

        IF LINES( gt_sitbw[] ) = 0.
          LOOP AT xlips ASSIGNING <ls_lips>
                        WHERE matnr IS NOT INITIAL
                        AND   werks IS NOT INITIAL
                        AND   sitkz IS NOT INITIAL            "n_1662007
                        AND   posar IS INITIAL.                 "1567998
            CLEAR lv_sitbw.
*           Get the schedule line category
            CALL FUNCTION 'SHP_SIT_SCHEDULE_LINE_CAT_DET'
              EXPORTING
                iv_matnr                    = <ls_lips>-matnr
                iv_werks                    = <ls_lips>-werks
                iv_lgort                    = <ls_lips>-lgort
                iv_berid                    = <ls_lips>-berid
                iv_pstyv                    = <ls_lips>-pstyv
              IMPORTING
                ev_ettyp                    = lf_ettyp
              EXCEPTIONS
                schedule_line_cat_not_found = 1
                OTHERS                      = 2.
            IF sy-subrc = 0.
*             Get the SIT movement type defined in the customizing of
*             the schedule line category
              CALL FUNCTION 'SIT_INFO_GET'
                EXPORTING
                  iv_ettyp    = lf_ettyp
                IMPORTING
                  ev_sit_flag = gv_sit_flag
                  ev_out_in   = lv_outin
                  ev_retpo    = gv_sit_retpo
                  ev_bwart    = lv_bwart
                  ev_sitbw    = lv_sitbw
                  ev_sitkz    = gv_xsit.
*             Set the combobox corresponding to the LIPS-SITKZ
              IF <ls_lips>-sitkz CA '12' AND <ls_lips>-sitkz <> gv_xsit.
                gv_xsit = <ls_lips>-sitkz.
*               Now determine the right SIT movement type to the changed
*               LIPS-SITKZ value...
                SELECT SINGLE * FROM t156 INTO ls_t156o
                       WHERE bwart = lv_sitbw.
                IF sy-subrc = 0.
*                 Read the schedule line categories to find the possible
*                 movement types
                  SELECT * FROM tvep INTO TABLE lt_tvep
                           WHERE sitkz = gv_xsit
                           AND   sitbw <> lv_sitbw.
                  IF sy-subrc = 0.
*                   Check the found movement types and pick the right one
                    LOOP AT lt_tvep ASSIGNING <ls_tvep>.
                      SELECT SINGLE * FROM t156 INTO ls_t156
                             WHERE bwart = <ls_tvep>-sitbw.
                      IF sy-subrc = 0.
                        IF  ls_t156-shkzg = ls_t156o-shkzg
                        AND ls_t156-kzbwa = ls_t156o-kzbwa.
                          lv_sitbw = <ls_tvep>-sitbw.
                          EXIT.
                        ENDIF.
                      ELSE.
                        MESSAGE e001(mick) WITH <ls_tvep>-sitbw.
                      ENDIF.
                    ENDLOOP.
                  ELSE.
                    MESSAGE e873(m7) WITH lv_sitbw.
                  ENDIF.
                ENDIF.
              ENDIF.
*             Fill the SIT buffer for follow on activities
              lv_ebeln = <ls_lips>-vgbel.
              lv_ebelp = <ls_lips>-vgpos+1.
              cl_mm_im_sit_info=>fill_sit_buffer(
                  iv_ebeln    = lv_ebeln
                  iv_ebelp    = lv_ebelp
                  iv_sit_flag = gv_sit_flag
                  iv_out_in   = lv_outin
                  iv_retpo    = gv_sit_retpo
                  iv_bwart    = lv_bwart
                  iv_sitbw    = lv_sitbw
                  iv_sitkz    = gv_xsit ).
            ENDIF.
*           Fill the table with SIT movement types corresponding to the
*           delivery item
            IF gv_sit_flag IS NOT INITIAL AND
               lv_sitbw    IS NOT INITIAL.
              gt_sitbw-bwart = lv_sitbw.
              gt_sitbw-vbeln = <ls_lips>-vbeln.
              gt_sitbw-posnr = <ls_lips>-posnr.
              APPEND gt_sitbw TO gt_sitbw.
            ENDIF.
          ENDLOOP.
        ENDIF.

* Reset SIT-Flag if for no delivery item a SIT movement type is found
        IF gt_sitbw[] IS INITIAL.
          CLEAR gv_sit_flag.
        ENDIF.
      ENDIF.

*      IF screen-name = 'GV_XSIT' AND gv_sit_flag IS INITIAL.
      IF screen-name = 'GV_XSIT' AND gv_sit_flag IS NOT INITIAL AND gv_sit_flag_cont IS INITIAL.

        IF ( vbuk-wbstk = charc OR ( vbuk-wbstk <> charc AND gv_sit_retpo IS NOT INITIAL ) )
        AND vbuk-pdstk = charc.
**          gv_sit_flag = charx.
          gv_sit_flag_cont = charx.
          gv_sit_cancel_flag = charx.
        ELSE.

*        IF vbuk-wbstk <> charc OR vbuk-pdstk <> charc.

*        READ TABLE xlips WITH KEY vbeln = vbuk-vbeln.



          screen-invisible = 0.
          CLEAR it_value_tab.

          IF xlips-vgtyp = 'C'.
            wa_value_tab-key = '3'.
            wa_value_tab-text = text-103.
            APPEND wa_value_tab TO it_value_tab.
            screen-input = 0.

          ELSE.
            wa_value_tab-key = '1'.
            wa_value_tab-text = text-101.
            APPEND wa_value_tab TO it_value_tab.

*           SIT2: If the return process have SITKZ = '2' with no stock
*           in the receiving plant but with stock posted unplanned then
*           the option '2' is no longer possible.
            CLEAR lv_bwcnt.
            IF gv_sit_retpo IS NOT INITIAL AND likp-vbtyp = vbtyp_lire.
              LOOP AT xvbfa ASSIGNING <ls_vbfa> WHERE bwart IS NOT INITIAL.
                SELECT SINGLE bustr FROM t156 INTO lv_bustr
                       WHERE bwart = <ls_vbfa>-bwart.
                IF sy-subrc = 0 AND lv_bustr = '169'.
                  IF <ls_vbfa>-plmin = '+'.
                    lv_bwcnt = lv_bwcnt + 1.
                  ELSEIF <ls_vbfa>-plmin = '-'.
                    lv_bwcnt = lv_bwcnt - 1.
                  ENDIF.
                ENDIF.
              ENDLOOP.
            ENDIF.

*           SIT2: If the PO has an confirmation control key then direct
*           posting into the unrestricted stock is not allowed
            CLEAR ls_ekpo.
            lv_ebeln = xlips-vgbel.
            lv_ebelp = xlips-vgpos.
            CALL FUNCTION 'ME_EKPO_SINGLE_READ'
              EXPORTING
                pi_ebeln = lv_ebeln
                pi_ebelp = lv_ebelp
              IMPORTING
                po_ekpo  = ls_ekpo
              EXCEPTIONS
                OTHERS   = 1.
            IF ls_ekpo-bstae IS INITIAL.
              wa_value_tab-key = '2'.
              wa_value_tab-text = text-102.
              APPEND wa_value_tab TO it_value_tab.
            ELSE.
              gv_xsit = '1'.
            ENDIF.
          ENDIF.

          CALL FUNCTION 'VRM_SET_VALUES'
            EXPORTING
              id                    = 'GV_XSIT'
              values                = it_value_tab
*     EXCEPTIONS
*       ID_ILLEGAL_NAME       = 1
*       OTHERS                = 2
        .
          IF sy-subrc = 0.
*            gv_sit_flag = 'X'.
            gv_sit_flag_cont = charx.
          ELSE.
* Implement suitable error handling here
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.                                                    "^_SIT

*   Clear flag for leaving the loop immediately
    CLEAR lf_exit_flag.

*   Dummy loop to speed up processing if screen attributes are
*   determined. On EXIT the MODIFY SCREEN command is processed
*   immediately.
    DO 1 TIMES.

*     Settings from the BAdI are treated with priority
      IF lf_badi_active NE space.
        READ TABLE lt_field_attrib INTO ls_field_attrib
                                   WITH KEY name = screen-name
                                   BINARY SEARCH.
        IF sy-subrc EQ 0.
          screen-active      = ls_field_attrib-active.
          screen-input       = ls_field_attrib-input.
          screen-invisible   = ls_field_attrib-invisible.
          screen-intensified = ls_field_attrib-intensified. "v_n_605460
*         Status 'In plant' must not be changed in dialog
          IF screen-name EQ 'LIKP-IMWRK'.
            screen-input = 0.
          ENDIF.                                            "^_n_605460
          EXIT.
        ENDIF.
      ENDIF.

ENHANCEMENT-POINT MV50AF0F_FELDAUSWAHL_10 SPOTS ES_SAPMV50A.

*     If field is a push button: check only if function code is
*     deactivated
      IF screen-group2 EQ 'BTN'.
*       Push buttons on dummy batch split screen are inactive anyway
        IF screen-group1 = 'CHS' AND
           v50agl-chargensplitbild EQ space.
          screen-input = 0.
        ELSE.
          PERFORM cua_deactivate_pushbutton CHANGING lf_exit_flag.
          CHECK lf_exit_flag EQ space.
        ENDIF.
        EXIT.
      ENDIF.

*     Special for goods-movement-screen (overview)
      IF screen-group4 EQ 'GMF'.
        IF tvlk-aufer CN 'HO'.
          screen-input = 0.
          EXIT.
        ENDIF.
      ENDIF.

      PERFORM feldauswahl_sonderregeln CHANGING lf_exit_flag.
      CHECK lf_exit_flag EQ space.

      PERFORM feldauswahl_bezug_auftrag CHANGING lf_exit_flag.
      CHECK lf_exit_flag EQ space.

      IF NOT likp-vlstk IS INITIAL.                         "n_671468
        PERFORM feldauswahl_stat_verteilt TABLES lt_dlfld
                                          USING lf_cmact    "n_921209
                                          CHANGING lf_exit_flag.
        CHECK lf_exit_flag EQ space.
      ENDIF.

      IF tvlk-aufer EQ charw.                                 "HUM
        PERFORM feldauswahl_pp_lieferung CHANGING lf_exit_flag.
        CHECK lf_exit_flag EQ space.
      ENDIF.

ENHANCEMENT-POINT MV50AF0F_FELDAUSWAHL_03 SPOTS ES_SAPMV50A.


      CASE lf_dyngr.
        WHEN 'KOPF'.
          IF xvbuk-pdstk CA 'AB'.
            PERFORM feldauswahl_stat_pod CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
          IF xvbuk-pdstk CA 'C '.
            PERFORM feldauswahl_stat_pod_displ CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
          PERFORM feldauswahl_stat_lvs_head CHANGING lf_exit_flag.
          CHECK lf_exit_flag EQ space.

          IF xvbuk-kostk EQ charb OR
             xvbuk-kostk EQ charc OR
             xvbuk-lvstk EQ charb.
            PERFORM feldauswahl_stat_kommission CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
ENHANCEMENT-SECTION     MV50AF0F_FELDAUSWAHL_04 SPOTS ES_SAPMV50A.
          IF xvbuk-wbstk EQ charb OR
             xvbuk-wbstk EQ charc OR
            ( likp-vlstk EQ charb AND v50agl-dlv_change IS INITIAL ) OR
            ( likp-vlstk EQ chare AND likp-verursys IS INITIAL ) OR
              likp-vlstk EQ charc.
            PERFORM feldauswahl_stat_warenausgang CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
END-ENHANCEMENT-SECTION.
          IF xvbuk-fkstk EQ charb OR
             xvbuk-fkstk EQ charc.
            PERFORM feldauswahl_stat_faktura CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
          IF screen-name EQ 'LIKP-FAKSK'.
            IF xvbuk-fkstk EQ space AND
               xvbuk-fkivk EQ space.
              screen-input = 0.
              EXIT.
            ENDIF.
          ENDIF.
          IF screen-name EQ 'RV50A-LFDAT_LA' OR             "v_n_605460
             screen-name EQ 'RV50A-LFUHR_LA'.
            IF likp-imwrk NE space.
              screen-input = 0.
              EXIT.
            ENDIF.
          ENDIF.                                            "^_n_605460
        WHEN 'POSI'.
*                                                              n_684700
          PERFORM feldauswahl_stat_lvs_head CHANGING lf_exit_flag.
          PERFORM feldauswahl_charge_bwtar CHANGING lf_exit_flag.
          PERFORM feldauswahl_docubatch CHANGING lf_exit_flag.
          CHECK lf_exit_flag EQ space.
          IF xvbup-kosta EQ charb OR
             xvbup-kosta EQ charc OR
             xvbup-lvsta EQ charb.
            PERFORM feldauswahl_stat_kommission CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
ENHANCEMENT-SECTION     MV50AF0F_FELDAUSWAHL_05 SPOTS ES_SAPMV50A.
          IF xvbup-wbsta EQ charb OR
             xvbup-wbsta EQ charc OR
          ( likp-vlstk EQ charb AND v50agl-dlv_change EQ space ) OR
          ( likp-vlstk EQ chare AND likp-verursys IS INITIAL ) OR
              likp-vlstk EQ charc.
            PERFORM feldauswahl_stat_warenausgang
                    CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
END-ENHANCEMENT-SECTION.
          IF xvbup-fksta EQ charb OR
             xvbup-fksta EQ charc.
            PERFORM feldauswahl_stat_faktura CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
          ENDIF.
          IF screen-name EQ 'LIPS-FAKSP'.
            IF xvbup-fksta EQ space AND
               xvbup-fkivp EQ space.
              screen-input = 0.
              EXIT.
            ENDIF.
          ENDIF.
          IF screen-name EQ 'LIPS-MATNR' OR
             screen-name EQ 'LIPS-UMVKZ' OR
             screen-name EQ 'LIPS-UMVKN' OR
             screen-name EQ 'LIPS-VRKME'.
            IF xvbup-pksta CA 'BC'.                         "n_609445
              screen-input = 0.
              EXIT.
            ENDIF.
          ENDIF.
          IF screen-name EQ 'LIPS-WERKS' OR                 "v_n_609445
             screen-name EQ 'LIPS-LGORT'.                   "n_645488
            IF xvbup-pksta CA 'BC' AND
               tvshp-exidv_unique EQ charx.
              CALL FUNCTION 'V51S_HU_LGORT'
                EXPORTING
                  if_werks        = lips-werks
                  if_lgort        = lips-lgort
                IMPORTING
                  ef_hu_managed   = lf_hu_flag
                EXCEPTIONS
                  lgort_not_exist = 0
                  OTHERS          = 0.
              IF lf_hu_flag NE space.
                screen-input = 0.
                EXIT.
              ENDIF.
            ENDIF.
          ENDIF.                                            "^_n_609445
        WHEN 'PUSH'.                     "push buttons
          PERFORM cua_deactivate_pushbutton CHANGING lf_exit_flag.
          CHECK lf_exit_flag EQ space.
          IF screen-group1 = 'CHS' AND
             v50agl-chargensplitbild EQ space.
            screen-input = 0.
            EXIT.
          ENDIF.
        WHEN 'CHSP'.                     "batch split screen (or dummy)
          IF v50agl-chargensplitbild EQ charx.
            PERFORM feldauswahl_vrkme_kzfme_chsp
                    CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.

            IF NOT lips-posnr IS INITIAL.
              PERFORM feldauswahl_lgort_chsp CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            IF xvbuk-kostk EQ charb OR
               xvbuk-kostk EQ charc OR
               xvbuk-lvstk EQ charb OR
               xvbup-kosta EQ charb OR
               xvbup-kosta EQ charc OR
               xvbup-lvsta EQ charb.
              PERFORM feldauswahl_stat_kommission
                      CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
ENHANCEMENT-SECTION     MV50AF0F_FELDAUSWAHL_06 SPOTS ES_SAPMV50A.
            IF ( xvbuk-wbstk EQ charb AND
                 likp-vbtyp CA vbtyp_lief ) OR              "n_576616
               xvbuk-wbstk EQ charc OR
               xvbup-wbsta EQ charb OR
               xvbup-wbsta EQ charc OR
            ( likp-vlstk EQ charb AND v50agl-dlv_change EQ space ) OR
            ( likp-vlstk EQ chare AND likp-verursys IS INITIAL ) OR
                likp-vlstk EQ charc.
              PERFORM feldauswahl_stat_warenausgang
                                    CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
END-ENHANCEMENT-SECTION.
            IF xvbuk-fkstk EQ charb OR
               xvbuk-fkstk EQ charc OR
               xvbup-fksta EQ charb OR
               xvbup-fksta EQ charc.
              PERFORM feldauswahl_stat_faktura CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
          ENDIF.
        WHEN OTHERS.
*         No new items can be created if the change management is active
          IF likp-vlstk NE space        AND
             v50agl-dlv_change NE space AND
             lips-matnr EQ space        AND
             lips-pstyv EQ space        AND
             lf_dyngr   EQ 'LIST'       AND
             sy-stepl GT 0.
            screen-input = 0.
            EXIT.
          ENDIF.
          IF lips-posnr NE space.
            IF xvbuk-pdstk CA 'AB' OR
               xvbup-pdsta CA 'AB'.
              PERFORM feldauswahl_stat_pod CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            IF xvbuk-pdstk CA 'C ' OR
               xvbup-pdsta CA 'C '.
              PERFORM feldauswahl_stat_pod_displ
                      CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            PERFORM feldauswahl_charge_bwtar CHANGING lf_exit_flag.
            PERFORM feldauswahl_docubatch CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
            IF xvbuk-kostk EQ charb OR
               xvbuk-kostk EQ charc OR
               xvbuk-lvstk EQ charb OR
               xvbup-kosta EQ charb OR
               xvbup-kosta EQ charc OR
               xvbup-lvsta EQ charb.
              PERFORM feldauswahl_stat_kommission
                      CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
ENHANCEMENT-SECTION     MV50AF0F_FELDAUSWAHL_07 SPOTS ES_SAPMV50A.
            IF xvbup-wbsta EQ charb OR
               xvbup-wbsta EQ charc OR
               ( likp-vlstk EQ charb AND
                 v50agl-dlv_change EQ space ) OR
               ( likp-vlstk EQ chare AND
                 likp-verursys IS INITIAL ) OR
               likp-vlstk EQ charc.
              PERFORM feldauswahl_stat_warenausgang
                      CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
END-ENHANCEMENT-SECTION.
            IF xvbuk-fkstk EQ charb OR
               xvbuk-fkstk EQ charc OR
               xvbup-fksta EQ charb OR
               xvbup-fksta EQ charc.
              PERFORM feldauswahl_stat_faktura CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            IF xvbup-pksta CA 'BC' AND
               ( screen-name EQ 'LIPS-MATNR' OR
                 screen-name EQ 'LIPS-VRKME' ).
              screen-input = 0.
              EXIT.
            ENDIF.
            IF screen-name EQ 'LIPS-WERKS' OR               "v_n_609445
               screen-name EQ 'LIPS-LGORT'.                 "n_645488
              IF xvbup-pksta CA 'BC' AND
                 tvshp-exidv_unique EQ charx.
                CALL FUNCTION 'V51S_HU_LGORT'
                  EXPORTING
                    if_werks        = lips-werks
                    if_lgort        = lips-lgort
                  IMPORTING
                    ef_hu_managed   = lf_hu_flag
                  EXCEPTIONS
                    lgort_not_exist = 0
                    OTHERS          = 0.
                IF lf_hu_flag NE space.
                  screen-input = 0.
                  EXIT.
                ENDIF.
              ENDIF.
            ENDIF.                                          "^_n_609445
            IF v50agl-chargensplitbild = charx.
              PERFORM feldauswahl_lgort_chsp CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
          ELSE.
            PERFORM feldauswahl_docubatch CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
            IF xvbuk-pdstk CA 'AB'.
              PERFORM feldauswahl_stat_pod CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            IF xvbuk-pdstk CA 'C '.
              PERFORM feldauswahl_stat_pod_displ
                      CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            PERFORM feldauswahl_stat_lvs_head CHANGING lf_exit_flag.
            CHECK lf_exit_flag EQ space.
ENHANCEMENT-SECTION     MV50AF0F_FELDAUSWAHL_08 SPOTS ES_SAPMV50A.
            IF xvbuk-wbstk EQ charb OR
               xvbuk-wbstk EQ charc OR
               ( likp-vlstk EQ charb AND
                 v50agl-dlv_change EQ space ) OR
               ( likp-vlstk EQ chare AND
                 likp-verursys IS INITIAL ) OR
               likp-vlstk EQ charc.
              PERFORM feldauswahl_stat_warenausgang
                      CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
END-ENHANCEMENT-SECTION.
            IF xvbuk-kostk EQ charb OR
               xvbuk-kostk EQ charc OR
               xvbuk-lvstk EQ charb.
              PERFORM feldauswahl_stat_kommission CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            IF xvbuk-fkstk EQ charb OR
               xvbuk-fkstk EQ charc.
              PERFORM feldauswahl_stat_faktura CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            IF v50agl-chargensplitbild = charx
               AND NOT lips-lgort IS INITIAL.
*               Anteils-/variable Mengeneinheiten
              PERFORM feldauswahl_vrkme_kzfme_chsp
                      CHANGING lf_exit_flag.
              CHECK lf_exit_flag EQ space.
            ENDIF.
            IF xlips_umfang EQ xlips_umfang_ucha AND
               v50agl-chargensplitbild EQ space  AND
               sy-stepl GT 0.
              screen-input = 0.
              EXIT.
            ENDIF.
            IF screen-name EQ 'RV50A-LFDAT_LA' OR           "v_n_605460
               screen-name EQ 'RV50A-LFUHR_LA'.
              IF likp-imwrk NE space.
                screen-input = 0.
                EXIT.
              ENDIF.
            ENDIF.                                          "^_n_605460
          ENDIF.
      ENDCASE.

    ENDDO.

ENHANCEMENT-POINT MV50AF0F_FELDAUSWAHL_09 SPOTS ES_SAPMV50A.

    IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.        "v_SIT
      IF xlips-sitkz IS NOT INITIAL                             "1617182
      AND ( xlips-anzsn IS NOT INITIAL OR xvbup-pksta IS NOT INITIAL
         OR /spe/cl_ctrl=>is_ewm( i_lgnum = likp-lgnum ) = gc_true )
      AND ( screen-name = 'TVPODVB-GRUND'
         OR screen-name = 'TVPODVB-LFIMG_DIFF' OR screen-name = 'TVPODVB-LGMNG_DIFF' ).
*       SIT: In case of serial numbers respectively packing or EWM
*            relevance no quantity differences are allowed
        screen-input = 0.
      ENDIF.

      IF gv_sit_cancel_flag IS NOT INITIAL.
        IF ( screen-name = 'TVPODVB-GRUND' OR
          screen-name = 'TVPODVB-LFIMG_DIFF' OR screen-name = 'TVPODVB-LGMNG_DIFF' )
          AND gv_sit_retpo IS INITIAL.
          screen-input = 0.
        ENDIF.
        IF  screen-name = 'GV_XSIT'.
          screen-invisible = 1.
        ENDIF.
      ENDIF.

    ENDIF.                                                    "^_SIT

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.                    "feldauswahl

*----------------------------------------------------------------------*
*  Form screen_input_initial_screen                                    *
*   used on init screens:                                              *
*   SAPMV50A 4004   outbound initial screen                            *
*   SAPMV50A 4004   inbound initial screen                             *
*----------------------------------------------------------------------*

Form screen_input_initial_screen.

 loop at screen.

*    Modify initial screen in case of archive
     IF screen-group4 = 'ARC' and
      (  t180-panel <> 'ARID' and   t180-panel <> 'AROD' ).
         screen-input = 0.
         screen-invisible = 1.
     ENDIF.
    MODIFY SCREEN.
 endloop.

endform.