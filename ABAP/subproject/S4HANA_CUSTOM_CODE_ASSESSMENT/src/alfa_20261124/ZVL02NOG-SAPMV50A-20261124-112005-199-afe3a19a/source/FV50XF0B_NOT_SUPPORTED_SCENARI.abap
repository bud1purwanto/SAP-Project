*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_NOT_SUPPORTED_SCENARI                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  NOT_SUPPORTED_SCENARIO_CHECK
*&---------------------------------------------------------------------*
*       Some scenarios are not supported to be executed via
*       WMS. The are stopped here.
*----------------------------------------------------------------------*
FORM not_supported_scenario_check USING is_likp LIKE likpvb.

  DATA: lf_subrc LIKE sy-subrc,
        lf_not_supported LIKE sy-subrc,
        lt_components TYPE stpob OCCURS 0,
        lf_cmact      TYPE t340d_cmact.

  lf_subrc = 0.

  DO 1 TIMES.

*   Restriction regarding change management removed ERP 600

*   CSL does not work with old transaction VL31
    IF sy-tcode EQ 'VL31' AND
       likp-vlstk EQ 'A'.
      IF t340d-lgnum NE likp-lgnum.
        SELECT SINGLE * FROM t340d
                        WHERE lgnum EQ likp-lgnum.
        IF sy-subrc NE 0.
          CLEAR t340d.
        ENDIF.
      ENDIF.
      IF t340d-cmact NE space.
        lf_not_supported = 5.
        EXIT.
      ENDIF.
    ENDIF.

    IF is_likp-vbtyp EQ vbtyp_liav AND
       is_likp-vlstk EQ chara.

      LOOP AT xlips WHERE vbeln EQ is_likp-vbeln
                      AND vgtyp CA 'V '    "Bestellungen/MB11
                      AND NOT ( lgnum IS INITIAL )
                      AND updkz NE updkz_delete.

*       Purchase orders having an account assignment category
*        if not xlips-knttp is initial and xlips-vgtyp eq charv.
*          lf_not_supported = 1.
*          exit.
*        endif.
*       Structured articles (purple cows)
        PERFORM mt06a_select(sapfv50p) USING xlips-matnr
                                             lf_subrc.
        if not cvbfs[] is initial.                         "v_n_1157470
*          gs_komdlgn-vupos = xlips-posnr.                   "n_1580720
*          PERFORM /spe/fill_spe_vbfs(saplv50s).             "n_1580720
           PERFORM /spe/fill_spe_vbfs_new(saplv50s).         "n_1580720
        endif.                                             "^_n_1157470
        IF maapv-attyp EQ '10' OR
           maapv-attyp EQ '11' OR
           maapv-attyp EQ '12'.

          DATA: lt_wsos_zlt LIKE wsos_zlt OCCURS 0 WITH HEADER LINE.

          CALL FUNCTION 'STRUCT_ARTICLE_KEY_DETERMINED'
            EXPORTING
              pi_matnr       = xlips-matnr
              pi_werks       = xlips-werks
              pi_attyp       = maapv-attyp
              pi_key         = '200'
            TABLES
              artl_with_todo = lt_wsos_zlt
            EXCEPTIONS
              no_carrier     = 1
              no_twzla_found = 2
              OTHERS         = 3.
          IF sy-subrc <> 0.                "wird nicht aufgelöst
          ELSE.
            READ TABLE lt_wsos_zlt INDEX 1.
            IF lt_wsos_zlt-zhead = '1'.
              lf_not_supported = 2.        "wird aufgelöst
              EXIT.
            ENDIF.
          ENDIF.
        ENDIF.

*     lines deleted                                            n_938962

      ENDLOOP.
    ENDIF.
  ENDDO.

  CASE lf_not_supported.
    WHEN 0.
    WHEN 4. "Change management not released
      PERFORM finchdel_handling(sapfv50p) USING
                                  is_likp-vbeln '01' 'E' 'VL' '585'
                                  space space space space gt_finchdel.
    WHEN 5. "VL31 not supported
      PERFORM finchdel_handling(sapfv50p) USING
                                  is_likp-vbeln '01' 'E' 'VL' '586'
                                  space space space space gt_finchdel.
    WHEN OTHERS. "certain inbound scenarios not supported
      PERFORM finchdel_handling(sapfv50p) USING
                                  is_likp-vbeln '01' 'E' 'VL' '583'
                                  space space space space gt_finchdel.
  ENDCASE.
ENDFORM.                               " NOT_SUPPORTED_SCENARIO_CHECK