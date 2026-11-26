*----------------------------------------------------------------------*
***INCLUDE MV50A_SIT_BUCHENF01 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SIT_BUCHEN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM sit_buchen .

  FIELD-SYMBOLS: <ls_xlips>  TYPE lipsvb.

  DATA: ls_vbfa TYPE vbfavb,                                    "1546322
        lt_vbfa TYPE STANDARD TABLE OF vbfavb,
        emseg TYPE emseg OCCURS 2 WITH HEADER LINE.

  DATA: lf_billing_started_already TYPE c.
  DATA: BEGIN OF xv134w OCCURS 0.
          INCLUDE STRUCTURE v134w.
  DATA: END OF xv134w.
  DATA:   kz_berel   TYPE c VALUE ' ',
          ls_tvpod   TYPE tvpodvb,
          lv_sitflag TYPE flag,                                  "1554198
          lv_bwart   TYPE bwart.

  FIELD-SYMBOLS: <ls_tvpod> TYPE tvpodvb,
                 <ls_xvbfa> TYPE vbfavb.

* In case of a removal of the POD data the inbound delivery must get its
* origin quantity again
  IF ( vbuk-pdstk = 'A' OR vbuk-pdstk = 'B' ) AND gv_sit_flag = 'X'
  AND gv_sit_cancel_flag IS INITIAL AND gv_sit_retpo IS INITIAL.
    PERFORM sit_idblv_prepare_update.
  ENDIF.

  CHECK ( vbuk-pdstk = 'C' AND gv_sit_flag = 'X' AND gv_sit_cancel_flag IS INITIAL ) OR
        ( ( vbuk-pdstk = 'A' OR vbuk-pdstk = 'B' ) AND gv_sit_flag = 'X' AND
          gv_sit_cancel_flag = 'X' ) OR
        ( vbuk-pdstk = 'C' AND gv_sit_flag = 'X' AND gv_sit_retpo = 'X' ).


  IF gv_sit_flag IS NOT INITIAL AND gv_sit_cancel_flag IS INITIAL.
    PERFORM warenausgang_buchen(sapfv50w).
    gv_sit_doc_num = emkpf-mblnr.
*   Trigger an inbound delivery update if required
    IF emkpf-mblnr IS NOT INITIAL AND
      cl_mm_im_sit_info=>check_update_ibdlv(
          it_tvpod = gt_tvpod[]
          it_xvbfa = xvbfa[] ) IS NOT INITIAL.
      CLEAR: gt_tvpod_sit, gt_tvpod_sit[].
      LOOP AT gt_tvpod ASSIGNING <ls_tvpod> WHERE updkz = 'I'
                                            OR    updkz = 'U'.
ENHANCEMENT-POINT EHP605_SIT_BUCHEN_02 SPOTS ES_SAPMV50A .
        IF <ls_tvpod>-lfimg <> <ls_tvpod>-podmg.
*         Loop to get the last inbound delivery                 "1538627
          LOOP AT xvbfa ASSIGNING <ls_xvbfa> WHERE vbelv = <ls_tvpod>-vbeln
                                             AND   posnv = <ls_tvpod>-posnr
                                             AND   vbtyp_n = '7'.
          ENDLOOP.
          IF sy-subrc = 0.
*           Move the inbound delivery into the POD structure using the
*           document flow fields <ls_xvbfa>-vbeln and <ls_xvbfa>-posnn
            READ TABLE gt_tvpod_sit WITH KEY vbeln = <ls_xvbfa>-vbeln
                                             posnr = <ls_xvbfa>-posnn
                                    TRANSPORTING NO FIELDS.
            IF sy-subrc <> 0.
              MOVE-CORRESPONDING <ls_tvpod> TO ls_tvpod.
*             Transport the batch number if required
              CLEAR ls_tvpod-arktx.                             "1548374
              READ TABLE xlips ASSIGNING <ls_xlips>
                               WITH KEY vbeln = <ls_tvpod>-vbeln
                                        posnr = <ls_tvpod>-posnr.
              IF sy-subrc = 0.
                IF <ls_xlips>-charg IS NOT INITIAL.
                  ls_tvpod-arktx = <ls_xlips>-charg.
                ENDIF.
              ENDIF.
              ls_tvpod-vbeln = <ls_xvbfa>-vbeln.
              ls_tvpod-posnr = <ls_xvbfa>-posnn.
              APPEND ls_tvpod TO gt_tvpod_sit.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDLOOP.
*     Trigger the update of the inbound delivery
      IF LINES( gt_tvpod_sit[] ) > 0.
        PERFORM sit_ibdlv_update ON COMMIT LEVEL 9000.
      ENDIF.
    ELSEIF emkpf-mblnr IS NOT INITIAL AND LINES( gt_tvpod[] ) = 0.
      PERFORM sit_idblv_prepare_update.
    ENDIF.
  ENDIF.

*---Storno
  IF gv_sit_cancel_flag IS NOT INITIAL.

*--- Check whether invoice already exists
    PERFORM determine_fkstk(saplv51w)
                  USING xvbuk
                        xlikp
                        xlips[]
                        space
                  CHANGING lf_billing_started_already.

    IF lf_billing_started_already = 'X'.
      MESSAGE e186(vl).
    ENDIF.

*--- Read document flow
    CLEAR: lv_sitflag, lv_bwart.                                "1554198
    LOOP AT xvbfa ASSIGNING <ls_xvbfa> WHERE sobkz = 'T'.       "1546322
      IF <ls_xvbfa>-bwart <> lv_bwart.
*       Check whether the movement type is relevant for SIT
        lv_bwart = <ls_xvbfa>-bwart.
        CALL FUNCTION 'SIT_INFO_GET'
          EXPORTING
            iv_bwart    = lv_bwart
            iv_sobkz    = <ls_xvbfa>-sobkz
          IMPORTING
            ev_sit_flag = lv_sitflag.
      ENDIF.
      IF lv_sitflag = 'X'.
        MOVE-CORRESPONDING <ls_xvbfa> TO ls_vbfa.
        APPEND ls_vbfa TO lt_vbfa.
      ENDIF.
    ENDLOOP.

*--- Find the last document in the document flow with SOBKZ = 'T'
    SORT lt_vbfa BY erdat DESCENDING erzet DESCENDING.
    CLEAR ls_vbfa.
    LOOP AT lt_vbfa INTO ls_vbfa.
      EXIT.
    ENDLOOP.
*--- Is there a relevant VLPOD posting to be cancelled?     "v_n_1650505
    CHECK ( NOT ls_vbfa-vbeln IS INITIAL AND
            ls_vbfa-plmin = '+' ).                          "^_n_1650505

    CALL FUNCTION 'MB_CANCEL_GOODS_MOVEMENT'
      EXPORTING
        budat       = xlikp-podat                               "1546322
        mblnr       = ls_vbfa-vbeln
        mjahr       = ls_vbfa-mjahr
        tcode       = 'VL09'
        called_by   = 'VL09'
        bfwms       = char2
        if_le_vbeln = xlikp-vbeln
      IMPORTING
        emkpf       = emkpf
      TABLES
        emseg       = emseg.

    gv_sit_doc_num = emkpf-mblnr.

*--> Prüfen, ob allg. Fehler bei Storno entstanden sind
    IF emkpf-subrc NE 1.  "früher: ne 0, dann ne 3!
      IF NOT emkpf-msgid IS INITIAL AND
         NOT emkpf-msgty IS INITIAL AND
         NOT emkpf-msgno IS INITIAL.
        " Meldung ausgeben falls Returnwerte (EMKPF) gefüllt
        MESSAGE ID     emkpf-msgid    " Message ausgeben
                TYPE   emkpf-msgty
                NUMBER emkpf-msgno
                WITH   emkpf-msgv1
                       emkpf-msgv2
                       emkpf-msgv3
                       emkpf-msgv4.
      ENDIF.
    ENDIF.
*--> Prüfen, ob Fehler bei der Stornierung der Belgegpos. entstanden
    LOOP AT emseg WHERE msgty EQ chare OR msgty EQ chara.
      MESSAGE ID     emseg-msgid    " Message ausgeben
              TYPE   emseg-msgty
              NUMBER emseg-msgno
              WITH   emseg-msgv1
                     emseg-msgv2
                     emseg-msgv3
                     emseg-msgv4.
    ENDLOOP.

    CALL FUNCTION 'MB_POST_GOODS_MOVEMENT'
      EXPORTING
        xblnr_sd = xlikp-vbeln
      IMPORTING
        emkpf    = emkpf
      EXCEPTIONS
        OTHERS   = 0.

*-- Update document flow, code from WS_REVERSE_GOODS_ISSUE
    DATA: merk_tabix   LIKE sy-tabix,
          lf_canc_serv TYPE xfeld.                          "n_1361685

    SORT xlips BY mandt vbeln posnr.

    REFRESH ilips.
    LOOP AT xlips WHERE updkz NE chard.
      lips = xlips.
      PERFORM ilips_anlegen(sapfv50p) USING sy-tabix.
    ENDLOOP.

    SORT ilips BY posnr.

    SORT xvbfa BY mandt vbelv posnv vbeln posnn vbtyp_n.
    zvbfa[] = xvbfa[].


    CALL FUNCTION 'RV_XVBAPF_CREATE'
      EXPORTING
        vbeln   = likp-vbeln
      TABLES
        fxvbapf = xvbapf
        fxvbfa  = xvbfa.

*... Folgebewegungsarten lesen
    SELECT * INTO TABLE xt156n FROM t156n WHERE fcode = 'ST'.
    SORT xt156n BY fcode bwart.

*... die view v134w wird zur performanceverbesserung gepuffert
    SELECT * FROM v134w INTO TABLE xv134w FOR ALL ENTRIES IN xlips
                                          WHERE werks = xlips-werks
                                          AND   mtart = xlips-mtart.
    SORT xv134w BY werks mtart.

    LOOP AT xlips WHERE posar IS INITIAL.                   "n_1567998

      CLEAR: kz_berel, lf_canc_serv.                        "n_1361685

*... Material document or confirmation of service?!

*    IF NOT xlips-mtart IS INITIAL AND                       "v_n_883024
      IF ( NOT xlips-mtart IS INITIAL OR
           ( likp-vbtyp  = '7' AND
             xlips-vgtyp = 'V' AND                          "^_n_883024
             xlips-matnr IS INITIAL ) ) AND                 "n_1361685
           NOT xlips-bwart IS INITIAL   AND
               xlips-nowab EQ space     AND
               xlips-lfimg GT 0.
        IF NOT ( likp-vbtyp  EQ '7' AND
                 xlips-vgtyp EQ 'V' AND                     "v_n_883024
                 xlips-matnr IS INITIAL ).                  "n_1361685
          READ TABLE xv134w WITH KEY werks = xlips-werks
                                     mtart = xlips-mtart BINARY SEARCH.
*       No cancellation without XV134W entry!
          IF sy-subrc NE 0.
            MESSAGE a607(vl) WITH xlips-werks xlips-mtart.
          ENDIF.
        ENDIF.                                              "^_n_883024
        IF ( xv134w-mengu = charx   OR
             xv134w-wertu = charx ) OR
           ( likp-vbtyp  EQ '7' AND
             xlips-vgtyp EQ 'V' AND                         "n_883024
             xlips-matnr IS INITIAL ) OR                    "n_1361685
             xlips-sobkz CA 'EQ'.
          READ TABLE gt_tvpod ASSIGNING <ls_tvpod>        "v_n_1650505
               WITH KEY handle_lips = xlips-handle.
          IF SY-SUBRC = 0.
*       No cancellation with POD zero quantities
            CHECK <ls_tvpod>-podmg > 0.
          ENDIF.                                          "^_n_1650505
*...    Material document needed
          kz_berel = charx.
          READ TABLE zvbfa WITH KEY vbelv   = xlips-vbeln
                                    posnv   = xlips-posnr
                                    vbeln   = ls_vbfa-vbeln.
          IF NOT sy-subrc IS INITIAL.
            MESSAGE a634(vl) WITH xlips-vbeln.
          ELSE.
            merk_tabix = ( sy-tabix + 1 ).
            PERFORM vbfa_erzeugen USING kz_berel.
            CALL FUNCTION 'RV_XVBFA_MAINTAIN'
              EXPORTING
                f_vorgang = 'V'
                fvbfa     = vbfa
              TABLES
                fxvbfa    = xvbfa
                fyvbfa    = yvbfa
                fxvbapf   = xvbapf.

*         Are there related items?!
            WHILE NOT merk_tabix IS INITIAL.
              READ TABLE zvbfa INDEX merk_tabix.
              IF sy-subrc EQ 0 AND zvbfa-vbelv EQ xlips-vbeln AND
                                   zvbfa-posnv EQ xlips-posnr AND
                                   zvbfa-vbeln EQ ls_vbfa-vbeln AND
                                   zvbfa-vbtyp_n EQ 'p'.        "1548374
                merk_tabix = ( sy-tabix + 1 ).
                PERFORM vbfa_erzeugen USING kz_berel.
                CALL FUNCTION 'RV_XVBFA_MAINTAIN'
                  EXPORTING
                    f_vorgang = 'V'
                    fvbfa     = vbfa
                  TABLES
                    fxvbfa    = xvbfa
                    fyvbfa    = yvbfa
                    fxvbapf   = xvbapf.
              ELSE.
                CLEAR merk_tabix.
                CHECK NOT merk_tabix IS INITIAL.
              ENDIF.
            ENDWHILE.
          ENDIF.
        ELSE.
          lf_canc_serv = charx.                               "v_n_1361685
        ENDIF.
      ELSE.
        lf_canc_serv = charx.
      ENDIF.
      IF lf_canc_serv = charx.
*     Cancellation of service
        READ TABLE xvbup WITH KEY vbeln = xlips-vbeln
                                  posnr = xlips-posnr
                                  BINARY SEARCH.
        IF sy-subrc    IS INITIAL AND
           xvbup-wbsta EQ charc.
*       Only if item has status posted
          CLEAR kz_berel.
          PERFORM vbfa_erzeugen USING kz_berel.
          CALL FUNCTION 'RV_XVBFA_MAINTAIN'
            EXPORTING
              f_vorgang = 'V'
              fvbfa     = vbfa
            TABLES
              fxvbfa    = xvbfa
              fyvbfa    = yvbfa
              fxvbapf   = xvbapf.
        ELSE.
*       No Document flow if it's already there!
          CHECK 1 = 2.
        ENDIF.
      ENDIF.                                                  "^_n_1361685
    ENDLOOP.
*   Update of corresponding inbound delivery                    "1538627
    IF emkpf-mblnr IS NOT INITIAL AND LINES( gt_tvpod[] ) = 0.
      PERFORM sit_idblv_prepare_update.
    ENDIF.
  ENDIF.
ENDFORM.                    " SIT_BUCHEN

*&---------------------------------------------------------------------*
*&      Form  SIT_IBDLV_UPDATE
*&---------------------------------------------------------------------*
*       Inbound delivery update in update task
*----------------------------------------------------------------------*
FORM sit_ibdlv_update.

  CALL FUNCTION 'SIT_IBDLV_UPDATE' IN UPDATE TASK
    EXPORTING
      it_tvpod = gt_tvpod_sit[].
  CLEAR: gt_tvpod_sit, gt_tvpod_sit[].

ENDFORM.                    " SIT_IBDLV_UPDATE

*&---------------------------------------------------------------------*
*&      Form  SIT_IBDLV_PREPARE_UPDATE
*&---------------------------------------------------------------------*
*       Preparation of inbound delivery update
*----------------------------------------------------------------------*
FORM sit_idblv_prepare_update.

  FIELD-SYMBOLS: <ls_tvpod> TYPE tvpodvb,
                 <ls_xvbfa> TYPE vbfavb,
                 <ls_xlips> TYPE lipsvb.

  CLEAR: gt_tvpod_sit, gt_tvpod_sit[].
  CALL FUNCTION 'LE_POD_TVPOD_READ'
    EXPORTING
      get_deleted = 'X'
    TABLES
      it_lips     = xlips
      et_tvpod    = gt_tvpod_sit.
* In case of deleted items in the POD data then the inbound delivery
* must be updated
  IF cl_mm_im_sit_info=>check_update_ibdlv(
        it_tvpod = gt_tvpod_sit[]
        it_xvbfa = xvbfa[] ) IS NOT INITIAL.
    LOOP AT gt_tvpod_sit ASSIGNING <ls_tvpod>.
ENHANCEMENT-POINT EHP605_SIT_IBDLV_PREPARE_UPD01 SPOTS ES_SAPMV50A .
      IF <ls_tvpod>-updkz = 'D' AND <ls_tvpod>-lfimg <> <ls_tvpod>-podmg.
*       Loop to get the last inbound delivery                   "1538627
        LOOP AT xvbfa ASSIGNING <ls_xvbfa> WHERE vbelv = <ls_tvpod>-vbeln
                                           AND   posnv = <ls_tvpod>-posnr
                                           AND   vbtyp_n = '7'.
        ENDLOOP.
        IF sy-subrc = 0.
*         Transport the batch number if required
          CLEAR <ls_tvpod>-arktx.                               "1548374
          READ TABLE xlips ASSIGNING <ls_xlips>
                           WITH KEY vbeln = <ls_tvpod>-vbeln
                                    posnr = <ls_tvpod>-posnr.
          IF sy-subrc = 0.
            IF <ls_xlips>-charg IS NOT INITIAL.
              <ls_tvpod>-arktx = <ls_xlips>-charg.
            ENDIF.
          ENDIF.
*         Move the inbound delivery into the POD structure using the
*         document flow fields <ls_xvbfa>-vbeln and <ls_xvbfa>-posnn
          <ls_tvpod>-vbeln = <ls_xvbfa>-vbeln.
          <ls_tvpod>-posnr = <ls_xvbfa>-posnn.
        ELSE.
          DELETE gt_tvpod_sit.
        ENDIF.
      ELSE.
        DELETE gt_tvpod_sit.
      ENDIF.
    ENDLOOP.
*   Trigger the update of the inbound delivery
    IF LINES( gt_tvpod_sit[] ) > 0.
      SORT gt_tvpod_sit BY handle_lips.
      DELETE ADJACENT DUPLICATES FROM gt_tvpod_sit COMPARING handle_lips.
      PERFORM sit_ibdlv_update ON COMMIT LEVEL 9000.
    ENDIF.
  ENDIF.

ENDFORM.