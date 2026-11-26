***INCLUDE FV50XFPD
*----------------------------------------------------------------------*
*   INCLUDE FV50XFPD                                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  POD_TVPOD_READ
*&---------------------------------------------------------------------*
*       Einlesen der TVPOD
*----------------------------------------------------------------------*
FORM pod_tvpod_read.

*    CALL FUNCTION 'LE_POD_TVPOD_READ'
*        TABLES
*             IT_LIPS  = XLIPS
*             ET_TVPOD = XTVPOD.


ENDFORM.                               " POD_TVPOD_READ

*&---------------------------------------------------------------------*
*&      Form  POD_DATEN_UPDATE
*&---------------------------------------------------------------------*
*       Update TVPOD data
*----------------------------------------------------------------------*
FORM pod_daten_update.

  DATA: BEGIN OF lt_tvpod OCCURS 100.
          INCLUDE STRUCTURE tvpodvb.
  DATA: END OF lt_tvpod.
  DATA: gf_step LIKE sy-tabix.

ENHANCEMENT-POINT POD_DATEN_UPDATE_01 SPOTS ES_FV50XFPD INCLUDE BOUND .

  lt_tvpod[] = gt_tvpod[].


  CALL FUNCTION 'LE_POD_TVPOD_UPDATE'
    EXPORTING
      it_likp           = likp
    TABLES
      it_lips           = xlips
      it_tvpod          = lt_tvpod
    EXCEPTIONS
      no_entry_lips     = 1      "Keine LIPS vorhanden
      zero_quantities   = 2      "Keine Abweichungen
      no_reason_found   = 3      "Kein Grund angegeben
      diff_error        = 4      "Abweichende Differenzmengen
      diff_round_error  = 5      "Rundungsfehler
      undefined_reason  = 6      "Grund nicht vorhanden
      negative_quantity = 7      "POD Menge wurde negativ
      OTHERS            = 8.     "sonstige

  IF sy-subrc NE 0.
    gf_error_pod = sy-subrc.
    gs_error_pod-msgno = sy-msgno.
    gs_error_pod-msgty = sy-msgty.
    gs_error_pod-msgid = sy-msgid.
    gs_error_pod-msgv1 = sy-msgv1.
    gs_error_pod-msgv2 = sy-msgv2.
    gs_error_pod-msgv3 = sy-msgv3.
    gs_error_pod-msgv4 = sy-msgv4.
  ELSE.
    CLEAR gf_error_pod.
    CLEAR gs_error_pod.
    REFRESH: gt_tvpod, gt_ytvpod.
    CLEAR: gt_tvpod, gt_ytvpod.
    gt_tvpod[] = gt_ytvpod[] = lt_tvpod[].
  ENDIF.

* Remember step for the following processes
  MOVE char1 TO gf_step.
  EXPORT gf_step TO MEMORY ID 'GF_STEP'.

ENDFORM.                               " POD_DATEN_UPDATE

*&---------------------------------------------------------------------*
*&      Form  POD_DATEN_UPDATE_DETAIL
*&---------------------------------------------------------------------*
*       Update GT_TVPOD on detail screen
*----------------------------------------------------------------------*
FORM pod_daten_update_detail.

  DATA: BEGIN OF lt_tvpod OCCURS 100.
          INCLUDE STRUCTURE tvpodvb.
  DATA: END OF lt_tvpod.

  IF NOT fcode EQ gc_fcode_podcanc.
    lt_tvpod[] = gt_tvpod[].
    CALL FUNCTION 'LE_POD_TVPOD_UPDATE'
      EXPORTING
        it_likp           = likp
      TABLES
        it_lips           = xlips
        it_tvpod          = lt_tvpod
      EXCEPTIONS
        no_entry_lips     = 1    "Keine LIPS vorhanden
        zero_quantities   = 2    "Keine Abweichungen
        no_reason_found   = 3    "Kein Grund angegeben
        diff_error        = 4    "Abweichende Differenzmengen
        diff_round_error  = 5    "Rundungsfehler
        undefined_reason  = 6    "Grund nicht vorhanden
        negative_quantity = 7    "POD Menge wurde negativ
        OTHERS            = 8.   "sonstige

    IF sy-subrc NE 0.
      gf_error_pod = sy-subrc.
      gs_error_pod-msgno = sy-msgno.
      gs_error_pod-msgty = sy-msgty.
      gs_error_pod-msgid = sy-msgid.
      gs_error_pod-msgv1 = sy-msgv1.
      gs_error_pod-msgv2 = sy-msgv2.
      gs_error_pod-msgv3 = sy-msgv3.
      gs_error_pod-msgv4 = sy-msgv4.
    ELSE.
      CLEAR gf_error_pod.
      REFRESH gt_tvpod.  CLEAR gt_tvpod.
      REFRESH gt_ytvpod. CLEAR gt_ytvpod.
      CLEAR gs_error_pod.
      gt_tvpod[] = lt_tvpod[].
    ENDIF.
  ELSE.
*Before-Image of GT_TVPOD when user leaves Dynpro 260 with 'CANCEL'
    CLEAR gt_tvpod. REFRESH gt_tvpod.
    gt_tvpod[] = gt_ytvpod[].
    CALL FUNCTION 'LE_POD_TVPOD_BUFFER_RESET'
      TABLES
        it_tvpod = gt_ytvpod[].

    CLEAR gt_ytvpod. REFRESH gt_ytvpod.
  ENDIF.

ENDFORM.                               " POD_DATEN_UPDATE_DETAIL

*&---------------------------------------------------------------------*
*&      Form  POD_MESSAGE_HANDLING
*&---------------------------------------------------------------------*
*       Message handling for POD
*----------------------------------------------------------------------*
*      -->LF_SUBRC
*      -->LF_PANEL
*----------------------------------------------------------------------*
FORM pod_message_handling USING lf_subrc LIKE sy-subrc
                                lf_panel LIKE t185v-panel.

  CHECK NOT fcode EQ gc_fcode_podcanc.

  CASE lf_subrc.
    WHEN char1.
      MESSAGE i216(vl) WITH gs_error_pod-msgv2.

    WHEN char2.
      MESSAGE i684(vl) WITH gs_error_pod-msgv2 gs_error_pod-msgv3.

    WHEN char3.
      MESSAGE i685(vl) WITH gs_error_pod-msgv2.

    WHEN char4.
      MESSAGE i686(vl) WITH gs_error_pod-msgv2.

    WHEN char5.
      MESSAGE i687(vl) WITH gs_error_pod-msgv2.

    WHEN char6.
      MESSAGE i058(00) WITH gs_error_pod-msgv2 space space space.

    WHEN char7.
      MESSAGE i689(vl).

    WHEN char8.
      PERFORM message_senden(sapmv50a) USING  " LIPS-POSNR
                                               gs_error_pod-msgno
*                                               GS_ERROR_POD-MSGTY
                                               'I'
                                               gs_error_pod-msgid
                                               gs_error_pod-msgv1
                                               gs_error_pod-msgv2
                                               gs_error_pod-msgv3
                                               gs_error_pod-msgv4.
  ENDCASE.

*... in case of any errors POD split screen may not be left
  IF lf_subrc NE 0.
    MOVE space TO fcode.
  ENDIF.

ENDFORM.                               " POD_MESSAGE_HANDLING
*&---------------------------------------------------------------------*
*&      Form  POD_KZPOD_DETERMINE
*&---------------------------------------------------------------------*
*       LIPS-KZPOD ermitteln
*----------------------------------------------------------------------*
*      -->P_LIPS_KZPOD
*----------------------------------------------------------------------*
FORM pod_kzpod_determine USING    cf_lips-kzpod LIKE lips-kzpod
                                  cf_vbup-pdsta LIKE vbup-pdsta.
* change KZPOD back after the LIPS-related TVPOD item has been deleted
  CASE cf_vbup-pdsta.
    WHEN charc.
      IF fcode EQ gc_fcode_podstor AND xvbuk-fkstk NA 'BC'. "n_778789
        IF cf_lips-kzpod EQ chara.
          MOVE charx TO cf_lips-kzpod.
        ELSE.
          MOVE chara TO cf_lips-kzpod.
        ENDIF.
      ENDIF.
    WHEN chara OR charb.
      IF fcode EQ gc_fcode_podquit.
        MOVE chara TO cf_lips-kzpod.
      ELSE.
        MOVE charx TO cf_lips-kzpod.
      ENDIF.
    WHEN space.
      MOVE space TO cf_lips-kzpod.
  ENDCASE.

ENDFORM.                               " POD_KZPOD_DETERMINE

*&---------------------------------------------------------------------*
*&      Form  POD_CONFIRM
*&---------------------------------------------------------------------*
*       Confirmation or reversal of POD
*----------------------------------------------------------------------*
FORM pod_confirm.

  DATA: gf_fcode LIKE sy-ucomm.
  DATA: reaction(1) TYPE c.
  DATA: lf_msgty LIKE sy-msgty VALUE 'E',                   "n_642497
        lf_rcode LIKE sy-subrc.                             "n_642497

  CHECK: gf_error_pod IS INITIAL.

  CASE fcode.
    WHEN gc_fcode_podquit.
      READ TABLE xvbuk WITH KEY vbeln = likp-vbeln.
      IF sy-subrc EQ 0 AND xvbuk-wbstk NE charc AND gv_sit_retpo IS INITIAL.
        fcode = gc_fcode_podenter.
        MESSAGE e612(vl).
        CHECK 1 = 2.
      ENDIF.
      IF xvbuk-pdstk CA 'AB' AND xvbuk-fkstk CA 'BC'.
        CLEAR reaction.
        CALL FUNCTION 'POPUP_TO_DECIDE_INFO'
          EXPORTING
            defaultoption = charn
            titel         = text-072
            textline1     = text-073
            textline2     = text-074
            start_column  = 25
            start_row     = 6
          IMPORTING
            answer        = reaction
          EXCEPTIONS
            OTHERS        = 1.
        IF reaction EQ chara.
          fcode = gc_fcode_podenter.
          CHECK 1 = 2.
        ENDIF.
      ENDIF.


ENHANCEMENT-POINT FV50XFPD_01 SPOTS ES_FV50XFPD INCLUDE BOUND.
      IF likp-podat IS INITIAL.
        likp-podat = sy-datlo.
      ENDIF.
      IF likp-potim IS INITIAL.
        likp-potim = sy-timlo.
      ENDIF.

      CALL FUNCTION 'LE_POD_TVPOD_CONFIRM'
        EXPORTING
          it_likp               = likp
        TABLES
          xtvpod                = gt_tvpod
        EXCEPTIONS
          is_confirmed          = 1
          subs_activity_started = 2
          OTHERS                = 3.

      gf_error_pod = sy-subrc.
      CASE sy-subrc.
        WHEN char0.
* Status update (LIPS and VBUP)
          gf_fcode = gc_fcode_podquit.
          EXPORT gf_fcode TO MEMORY ID 'GF_FCODE'.
          PERFORM pod_confirmation_status_update.
        WHEN char1.
          MESSAGE e691(vl).
        WHEN char2.
          MESSAGE e693(vl).
        WHEN OTHERS.
          MESSAGE e679(vl).
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDCASE.

    WHEN gc_fcode_podstor.
      READ TABLE xvbuk WITH KEY vbeln = likp-vbeln.
      IF sy-subrc EQ 0 AND xvbuk-fkstk CA 'BC'.
*        FCODE = GC_FCODE_PODENTER.
                                                            "v_n_642497
        PERFORM message_handling_variabel
                                 USING lips-posnr
                                       '186'
                                       lf_msgty
                                       'VL'
                                       space
                                       space
                                       space
                                       space
                                       gs_mhpar
                                       v50agl-msgvs
                              CHANGING lf_msgty
                                       lf_rcode.
                                                            "^_n_642497
*        CHECK 1 = 2.
      ENDIF.
      CALL FUNCTION 'LE_POD_TVPOD_CONFIRM_CANCEL'
        TABLES
          xtvpod                = gt_tvpod
        EXCEPTIONS
          is_not_confirmed      = 1
          subs_activity_started = 2
          OTHERS                = 3.

      gf_error_pod = sy-subrc.
      CASE sy-subrc.
        WHEN char0.
*         CLEAR LIKP-PODAT.
*         CLEAR LIKP-POTIM.
          gf_fcode = gc_fcode_podstor.
          EXPORT gf_fcode TO MEMORY ID 'GF_FCODE'.
          PERFORM pod_confirmation_status_update.
        WHEN char1.
          MESSAGE e692(vl).
        WHEN char2.
          MESSAGE a693(vl).                                 "n_607430
        WHEN OTHERS.
          MESSAGE e679(vl).
*          MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*                  WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
      ENDCASE.

  ENDCASE.

ENDFORM.                               " POD_CONFIRM

*&---------------------------------------------------------------------*
*&      Form  POD_ICON_CALC_DETERMINE
*&---------------------------------------------------------------------*
*       Determine Icon for panel PPOD
*----------------------------------------------------------------------*
*      -->P_GT_TVPOD_CALCU  (Plus, Minus, SPACE)
*      -->P_TVPODVB_CALCU   (Icon )
*----------------------------------------------------------------------*
FORM pod_icon_calc_determine USING lf_gt_tvpod_calcu TYPE c
                                   lf_tvpodvb_podmul LIKE tvpodvb-podmul
                                   lf_panel          LIKE t185v-panel.

  CHECK lf_panel EQ 'PPOD'.

  CASE lf_gt_tvpod_calcu.
    WHEN char_plus.
      MOVE gc_pod_quantity_plus  TO lf_tvpodvb_podmul.

    WHEN char-.
      MOVE gc_pod_quantity_minus TO lf_tvpodvb_podmul.

    WHEN OTHERS.
      MOVE space TO lf_tvpodvb_podmul.
  ENDCASE.

ENDFORM.                               " POD_ICON_CALC_DETERMINE

*&---------------------------------------------------------------------*
*&      Form  POD_CONFIRMATION_STATUS_UPDATE
*&---------------------------------------------------------------------*
*       Determine status for POD confirmation / cancellation
*----------------------------------------------------------------------*
FORM pod_confirmation_status_update.

  DATA: lf_count_pod   LIKE sy-tabix,
        lf_xlips_tabix LIKE sy-tabix.
  DATA: ls_ylips LIKE LINE OF ylips.                    "<< note 313290

  LOOP AT xlips.
    ls_ylips = xlips.                                   "<< note 313290
    lf_xlips_tabix = sy-tabix.
    READ TABLE xvbup WITH KEY vbeln = xlips-vbeln
                              posnr = xlips-posnr.
*      LIPS = XLIPS.
*       *LIPS = LIPS.
*      MOVE-CORRESPONDING XLIPS TO LIPSD.
*       *LIPSD = LIPSD.
*    ENDIF.
* Determine KZPOD for all cases (update, confirmation, cancellation) -*
    LOOP AT gt_tvpod WHERE handle_lips = xlips-handle.
      IF ( xlips-xchpf EQ charx   AND
           xlips-xchar EQ charx   AND
           xlips-charg IS INITIAL AND
*          XLIPS-UECHA IS INITIAL ).               "<<< delete HP_316719
           xlips-uecha IS INITIAL AND NOT          "<<< insert HP_316719
           xlips-kcmeng IS INITIAL ).              "<<< insert HP_316719

* Do not select a batch main item, otherwise it gets KZPOD = B
      ELSE.
        IF NOT xvbup-pdsta CA ' C'.
          xlips-kzpod = charb.
        ENDIF.
        ADD 1 TO lf_count_pod.
        IF lf_count_pod GT char1.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lf_count_pod IS INITIAL.
      PERFORM pod_kzpod_determine(sapmv50a) USING xlips-kzpod
                                                  xvbup-pdsta.
    ELSE.
      CLEAR lf_count_pod.
    ENDIF.
*    XLIPS-UPDKZ = CHARU.                            "<< note 313290
    IF xlips-updkz EQ updkz_old.                     "<< note 313290
      ylips = ls_ylips.                              "<< note 313290
      APPEND ylips.                                  "<< note 313290
      xlips-updkz = updkz_update.                    "<< note 313290
    ENDIF.                                           "<< note 313290
    MODIFY xlips INDEX lf_xlips_tabix.
ENHANCEMENT-SECTION     FV50XFPD_05 SPOTS ES_FV50XFPD INCLUDE BOUND .
    CALL FUNCTION 'LIPS_STATUS_MAINTAIN'
      EXPORTING
        f_likp   = likp
        f_posnr  = xlips-posnr
*       LAND1_WE =
      TABLES
        fxlips   = xlips
        fxvbapf  = xvbapf
        fxvbup   = xvbup
        fyvbup   = yvbup.
END-ENHANCEMENT-SECTION.

  ENDLOOP.
  PERFORM xvbuk_pflegen(sapfv50k).

ENDFORM.                               " POD_CONFIRMATION_STATUS_UPDATE
*&---------------------------------------------------------------------*
*&      Form  POD_READ_RESONCODE_TEXT
*&---------------------------------------------------------------------*
*      -->P_GT_TVPOD_GRUND
*      -->P_TVPODGT_GTEXT
*----------------------------------------------------------------------*
FORM pod_read_resoncode_text USING if_gt_tvpod-grund LIKE tvpod-grund
                                   cs_tvpodgt-gtext  LIKE tvpodgt-gtext.

  DATA: es_tvpodgt LIKE tvpodgt.
  CALL FUNCTION 'LE_POD_TVPODGT_READ_TEXT'
    EXPORTING
      if_grund          = if_gt_tvpod-grund
    IMPORTING
      es_tvpodgt        = es_tvpodgt
    EXCEPTIONS
      no_key_specified  = 1
      no_value_selected = 2
      OTHERS            = 3.
  IF sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    cs_tvpodgt-gtext =  es_tvpodgt-gtext.
  ENDIF.


ENDFORM.                               " POD_READ_RESONCODE_TEXT

*&---------------------------------------------------------------------*
*&      Form  POD_INBOUND_DATA_PROCESSING
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM pod_inbound_data_processing.

  DATA: lf_kzpod  LIKE lips-kzpod,
        lf_lfimg  LIKE lips-lfimg,
        lf_podrel LIKE lips-podrel,
        lf_podau  LIKE tvlp-podau.

ENHANCEMENT-POINT FV50XFPD_02 SPOTS ES_FV50XFPD STATIC INCLUDE BOUND.

*... Uom must not be changed in POD scenario
  IF ( lips-vrkme NE *lips-vrkme   OR
       lips-meins NE *lips-meins ) AND NOT
       lips-kzpod IS INITIAL.
    MESSAGE i655(vl).
    CHECK 1 = 2.
  ENDIF.

  IF *lips-lfimg NE lips-lfimg AND NOT
      lips-kzpod EQ space.
    CHECK lips-posnr = xlips-posnr AND xlips-chmult IS INITIAL.
    lf_podau = tvlp-podau.
    IF v50agl-kommirueckmeldung EQ charx.
      CASE lf_podau.
        WHEN space OR charm.
          CHECK 1 = 2.
        WHEN chart.
          MOVE charv TO lf_podau.
        WHEN charv.

        WHEN OTHERS.
      ENDCASE.
    ENDIF.

    CALL FUNCTION 'LE_POD_DATA_PROCESSING'
      EXPORTING
        it_likp                     = likp
        is_lips                     = lips
        if_podau                    = lf_podau
        if_trtyp                    = t180-trtyp
        if_dialog                   = space
      IMPORTING
        ef_lips_kzpod               = lf_kzpod
        ef_lips_lfimg               = lf_lfimg
        ef_lips_podrel              = lf_podrel
      TABLES
        it_xlips                    = xlips
        it_ylips                    = ylips
      EXCEPTIONS
        error_tvpod_update          = 1
        no_default_reason_found     = 2
        pod_processing_data_missing = 3
        item_not_pod_relevant       = 4
        OTHERS                      = 5.
    CHECK sy-subrc EQ 0.

ENHANCEMENT-POINT FV50XFPD_03 SPOTS ES_FV50XFPD INCLUDE BOUND.


    CHECK lips-kzpod NE space.
    IF ( lf_kzpod NE lips-kzpod   OR
         lf_lfimg NE lips-lfimg ) AND NOT
       tvlp-podau EQ space.
      lips-kzpod  = lf_kzpod.
      lips-lfimg  = lf_lfimg.
      lips-podrel = lf_podrel.
      CALL FUNCTION 'SHP_QUANTITY_SET'
        EXPORTING
          if_action              = 'A'
*         IF_RATIO               = ' '
        CHANGING
          cf_lfimg               = lips-lfimg
          cf_lgmng               = lips-lgmng
          cf_lfimg_flo           = lips-lfimg_flo
          cf_lgmng_flo           = lips-lgmng_flo
          cf_umvkz               = lips-umvkz
          cf_umvkn               = lips-umvkn
          cf_umrev               = lips-umrev
          cf_akmng               = lips-akmng
        EXCEPTIONS
          conversion_overflow    = 1
          essential_data_missing = 2
          error                  = 3
          OTHERS                 = 4.
      CASE sy-subrc.
        WHEN 1. RAISE conversion_overflow.
        WHEN 2. RAISE essential_data_missing.
        WHEN 3. RAISE error.
      ENDCASE.
    ENDIF.
  ENDIF.
ENHANCEMENT-POINT FV50XFPD_06 SPOTS ES_FV50XFPD STATIC INCLUDE BOUND .

ENHANCEMENT-POINT FV50XFPD_04 SPOTS ES_FV50XFPD INCLUDE BOUND.

ENDFORM.                               " POD_INBOUND_DATA_PROCESSING
*&---------------------------------------------------------------------*
*&      Form  POD_STATUS_MAINTAIN
*&---------------------------------------------------------------------*
*       Maintains POD status
*----------------------------------------------------------------------*
FORM pod_status_maintain.                                   "v_n_569399

  DATA: lf_pod_count LIKE sy-tabix.
  DATA: lt_tvep     TYPE STANDARD TABLE OF tvep,
        ls_t156     TYPE t156,
        ls_t156_old TYPE t156,
        lv_tabix    TYPE sytabix.
  FIELD-SYMBOLS: <ls_tvep> TYPE tvep.

  CLEAR lf_pod_count.
  IF NOT lips-posnr IS INITIAL.
* Determine KZPOD for all cases (update, confirmation, cancellation) -*
    LOOP AT gt_tvpod WHERE handle_lips = lips-handle.
      IF ( lips-xchpf EQ charx   AND
            lips-xchar EQ charx   AND
            lips-charg IS INITIAL AND
            lips-uecha IS INITIAL ).
* Do not select a batch main item, otherwise it gets KZPOD = B
      ELSE.
        READ TABLE xvbup WITH KEY vbeln = lips-vbeln
                                  posnr = lips-posnr
                         BINARY SEARCH.
        IF NOT xvbup-pdsta CA ' C'.
          lips-kzpod = charb.
        ENDIF.
        ADD 1 TO lf_pod_count.
        IF lf_pod_count GT 1.
          EXIT.
        ENDIF.
      ENDIF.
    ENDLOOP.
    IF lf_pod_count IS INITIAL.
      PERFORM pod_kzpod_determine(sapmv50a) USING lips-kzpod
                                                  xvbup-pdsta.
    ENDIF.

*   SIT: Change movement type if required
    IF gv_sit_flag IS NOT INITIAL AND lips-posar IS INITIAL     "1567998
    AND not lips-sitkz IS INITIAL                             "n_1662007
    AND ( ( lips-sitkz <> gv_xsit     AND fcode = gc_fcode_podquit )
       OR ( lips-sitkz <> ylips-sitkz AND ylips-sitkz IS NOT INITIAL
        AND fcode = gc_fcode_podstor ) ).
*     Read the customizing of the movement type in GT_SITBW-BWART
      READ TABLE gt_sitbw WITH KEY vbeln = lips-vbeln
                                   posnr = lips-posnr.
      IF sy-subrc = 0.
        lv_tabix = sy-tabix.
        SELECT SINGLE * FROM t156 INTO ls_t156_old
               WHERE bwart = gt_sitbw-bwart.
        IF sy-subrc = 0.
*         In case of a POD cancellation set the SIT combobox value
*         back to the old value
          IF fcode = gc_fcode_podstor.
            gv_xsit = ylips-sitkz.
          ENDIF.
*         Read the schedule line categories to find the possible
*         movement types
          SELECT * FROM tvep INTO TABLE lt_tvep
                   WHERE sitkz = gv_xsit
                   AND   sitbw <> gt_sitbw-bwart.
          IF sy-subrc = 0.
*           Check the found movement types and pick the right one
            LOOP AT lt_tvep ASSIGNING <ls_tvep>.
              SELECT SINGLE * FROM t156 INTO ls_t156
                     WHERE bwart = <ls_tvep>-sitbw.
              IF sy-subrc = 0.
                IF  ls_t156-shkzg = ls_t156_old-shkzg
                AND ls_t156-kzbwa = ls_t156_old-kzbwa.
                  gt_sitbw-bwart = <ls_tvep>-sitbw.
                  MODIFY gt_sitbw INDEX lv_tabix.
                  lips-sitkz = gv_xsit.
                  EXIT.
                ENDIF.
              ELSE.
                MESSAGE e001(mick) WITH <ls_tvep>-sitbw.
              ENDIF.
            ENDLOOP.
          ELSE.
            MESSAGE e873(m7) WITH gt_sitbw-bwart.
          ENDIF.
        ENDIF.
      ELSE.
        MESSAGE e000(m7) WITH lips-vbeln lips-posnr space 'GT_SITBW'.
      ENDIF.
    ENDIF.

*   perform lips_bearbeiten(sapfv50p).                       "v_n_812904
    PERFORM lips_referenz_lesen(sapfv50p).
    PERFORM xlips_aendern(sapfv50p).
    CALL FUNCTION 'LIPS_STATUS_MAINTAIN'
      EXPORTING
        f_likp   = likp
        f_posnr  = lips-posnr
        land1_we = kuwev-land1
      TABLES
        fxlips   = xlips
        fxvbapf  = xvbapf
        fxvbup   = xvbup
        fyvbup   = yvbup                                    "^_n_812904
        fxvbfa   = xvbfa.                                 "XAN-SPE

  ENDIF.

ENDFORM.                    " POD_STATUS_MAINTAIN             ^_n_569399