*---------------------------------------------------------------------*
*       FORM MAT_AUF_HINWEIS_PRUEFEN                                  *
*---------------------------------------------------------------------*
*       ........                                                      *
*---------------------------------------------------------------------*
*  -->  CH_SUBRC                                                      *
*---------------------------------------------------------------------*
form mat_auf_hinweis_pruefen changing ch_subrc.

  data: da_length type i.
  local: vbup,
         vapma,
         tvak.

  data: da_ang_item_exist(1) type c value ' ',
        da_kon_item_exist(1) type c value ' ',
        da_answer            type c,
        da_vbeln             like vbak-vbeln,
        da_posnr             like vbap-posnr,
        da_matnr             like vbap-matnr,
        da_lines             like sy-tfill,
        localvbap            like vbap,
        localrv45a           like rv45a,
        da_diagnosetext(50)  type c,
        lv_sc1               type boole_d.

  data: da_no_dialog(1).

  data: lr_badi_sd_ref_doc_cust type ref to badi_sd_ref_doc_cust.

* Get state of EHP2 SD-BF
  lv_sc1 = cl_ops_switch_check=>sd_sfws_sc1( ).

enhancement-point mat_auf_hinweis_pruefen_01 spots es_sapmv45a static.
enhancement-point mat_auf_hinweis_pruefen_02 spots es_sapmv45a.

* LO API behaviour depends on state of EHP2 SD-BF in LV_SC1
  check     call_function      is initial                or
        (   call_activity      eq gc_activity_lord and
            gf_no_messages_doc is initial          and
          ( tvak-hnwkm         is initial   or
            lv_sc1             eq abap_true    )       ).

  check ( ( sy-batch eq space and
        ( sy-binpt eq space or not cattaktiv is initial ) ) or
        ( tvak-hnwag eq 'D' or
        tvak-hnwkm eq 'D' ) ) and
        vbap-stlnr is initial and
        vbap-uepos eq space.

  if call_activity eq gc_activity_lord and
     not vbap-vgbel is initial and
     not vbap-vgpos is initial and
     not gv_vbeln_ref_ext is initial and
     vbap-vgbel = gv_vbeln_ref_ext.
    return.
  endif.

  if       call_activity            eq gc_activity_lord      and
       not mat_auf_hinweis_geprueft is initial               and
     (     lv_sc1                   eq abap_false         or
       (   lv_sc1                   eq abap_true  and
           gf_sapgui_mode           is initial        ) ).
*   LO API behaviour depends on state of EHP2 SD-BF in LV_SC1
    check not gv_message_vbeln_ref is initial and
          not gv_message_posnr_ref is initial.
    clear mat_auf_hinweis_geprueft.
  endif.

* Mehrfachaufruf des Hinweisdialogs verhinden
  if not mat_auf_hinweis_geprueft is initial.
    return.
  endif.
  mat_auf_hinweis_geprueft = charx.

  localvbap = vbap.
  localrv45a = rv45a.
*----------------------------------------------------------------------*
* Auf Positionsebene pruefen
*----------------------------------------------------------------------*

* Pruefung nur wenn nicht im 'Anlegen mit Bezug' oder Material geändert
* Pruefung auch wenn 'Pos. vorschlagen' ausgeführt wird
  check ( ( vbap-vgbel eq space and *vbap-posnr = 0 or
            not matnr_changed is initial or
            *vbap-matnr ne vbap-matnr ) and
        kopieren = space ) or
        ( not positionsvorschlag is initial or
        ( not kopieren is initial and cvbak-vbtyp eq vbtyp_sort ) ).

  refresh hnw_vbap.
  clear hnw_vbap.

  if tvak-hnwag ca 'BDF'.
*   Angebote zum Material lesen
    perform vapma_select using vbap-matnr
                               vbak-vkorg
                               '2'     " TRVOG = Angebote
                               vbak-vtweg
                               vbak-spart
                               kuagv-kunnr
                               da_ang_item_exist.
  endif.

ENHANCEMENT-SECTION MAT_AUF_HINWEIS_PRUEFEN_03 SPOTS ES_SAPMV45A .
  if tvak-hnwkm ca 'BDF'.
*   Kontrakte zum Material lesen
    perform vapma_select using vbap-matnr
                               vbak-vkorg
                               '4'     " TRVOG = Kontrakte
                               vbak-vtweg
                               vbak-spart
                               kuagv-kunnr
                               da_kon_item_exist.

    perform vapma_select using vbap-matnr
                               vbak-vkorg
                               '3'     " TRVOG = Lieferpläne
                               vbak-vtweg
                               vbak-spart
                               kuagv-kunnr
                               da_kon_item_exist.
  endif.
END-ENHANCEMENT-SECTION.


* Wenn man im 'Pos. vorschlagen' ist soll eine variable Message kommen
  if ( not positionsvorschlag is initial or
     ( not kopieren is initial and cvbak-vbtyp eq vbtyp_sort ) ).
    if da_ang_item_exist ne space.
      if da_kon_item_exist ne space.
        perform message_variabel in program sapfv45l
                                 using 'V4' '228' rv45z-msgvs
                                       charx vbap-matnr space space space.
      else.
        perform message_variabel in program sapfv45l
                                 using 'V4' '226' rv45z-msgvs
                                       charx vbap-matnr space space space.
      endif.
    else.
      if da_kon_item_exist ne space.
        perform message_variabel in program sapfv45l
                                 using 'V4' '227' rv45z-msgvs
                                       charx vbap-matnr space space space.
      endif.
    endif.
* ... und Routine vorzeitig verlassen
    return.
  endif.

* Advanced Returns Management: automatic check for reference item
  try.
      get badi lr_badi_sd_ref_doc_cust.

      call badi lr_badi_sd_ref_doc_cust->search_for_ref_doc
        exporting
          is_tvak           = tvak
          is_tvap           = tvap
          is_vbak           = vbak
          is_vbap           = vbap
        changing
          cs_hnw_vbap       = hnw_vbap
          ct_hnw_vbap       = hnw_vbap[]
          cv_ang_item_exist = da_ang_item_exist
          cv_kon_item_exist = da_kon_item_exist
          cv_answer         = da_answer.

    catch cx_badi_not_implemented .
  endtry.

* Bestimme die Anzahl der gefundenen offenen Belege
  describe table hnw_vbap lines da_lines.

* Hinweis in Abhängigkeit der beiden Schalter anzeigen
  if da_ang_item_exist ne space.
    if da_kon_item_exist ne space.
      if tvak-hnwag       eq 'F'                    or
         tvak-hnwkm       eq 'F'                    or
         ( lv_sc1         eq abap_true        and
           call_activity  eq gc_activity_lord and
           gf_sapgui_mode is initial              ).
*       LO API behaviour depends on state of EHP2 SD-BF in LV_SC1
        da_answer = 2.
      else.
*       No popup in CALL TRANSACTION background process
        if not idoc_number    is initial and
           bi_info-ctu_amodus eq charn.
          write text-214 to da_diagnosetext.
          message e185(v2) with vbap-matnr
                                da_diagnosetext.
        endif.
*       Hinweis, dass zum Material mind. ein Angebot und ein Kontrakt
*       existiert
        move text-217 to da_diagnosetext.
        da_length = strlen( da_diagnosetext ) + 1.
        write vbap-matnr to da_diagnosetext+da_length.
        call function 'POPUP_TO_DECIDE_WITH_MESSAGE'
          exporting
            defaultoption = '1'
            diagnosetext1 = da_diagnosetext
            diagnosetext2 = text-211
            diagnosetext3 = text-223
            textline1     = ' '
            text_option1  = text-212
            text_option2  = text-213
            titel         = text-220
          importing
            answer        = da_answer.
      endif.
    else.
      if ( tvak-hnwag     eq 'D' and
           da_lines       eq 1       )              or
           tvak-hnwag     eq 'F'                    or
         ( call_activity  eq gc_activity_lord and
           lv_sc1         eq abap_false           ) or
         ( call_activity  eq gc_activity_lord and
           lv_sc1         eq abap_true        and
           gf_sapgui_mode is initial              ).
*       LO API behaviour depends on state of EHP2 SD-BF in LV_SC1
        da_answer = 2.
      else.
*       Hinweis, dass zum Material mind. ein Angebot existiert
        if call_bapi = 'X'.
          call function 'DIALOG_GET_STATUS'
            importing
              dialog_status = da_no_dialog.
        endif.
*       No popup in CALL TRANSACTION background process
        if not idoc_number is initial and
          bi_info-ctu_amodus eq charn.
          write text-216 to da_diagnosetext.
          message e185(v2) with vbap-matnr
                                da_diagnosetext.
        endif.
        if da_no_dialog is initial.
          write vbap-matnr to da_diagnosetext.
          call function 'POPUP_TO_DECIDE_WITH_MESSAGE'
            exporting
              defaultoption = '1'
              diagnosetext1 = text-217
              diagnosetext2 = da_diagnosetext
              diagnosetext3 = text-215
              textline1     = ' '
              text_option1  = text-212
              text_option2  = text-213
              titel         = text-221
            importing
              answer        = da_answer.
        else.
          return.
        endif.
      endif.
    endif.
  else.
    if da_kon_item_exist ne space.
      if ( tvak-hnwkm = 'D' and da_lines = 1 ) or tvak-hnwkm = 'F' or
         ( cl_ops_switch_check=>sd_sfws_sc1( ) eq abap_true and
           call_activity eq gc_activity_lord and
           gf_sapgui_mode is initial ).
        da_answer = 2.
      else.
*       Hinweis, dass zum Material mind. ein Kontrakt existiert
        if call_bapi = 'X'.
          call function 'DIALOG_GET_STATUS'
            importing
              dialog_status = da_no_dialog.
        endif.
*       No popup in CALL TRANSACTION background process
        if not idoc_number is initial and
          bi_info-ctu_amodus eq charn.
          write text-219 to da_diagnosetext.
          message e185(v2) with vbap-matnr
                                da_diagnosetext.
        endif.
        if da_no_dialog is initial.
          write vbap-matnr to da_diagnosetext.
          call function 'POPUP_TO_DECIDE_WITH_MESSAGE'
            exporting
              defaultoption = '1'
              diagnosetext1 = text-217
              diagnosetext2 = da_diagnosetext
              diagnosetext3 = text-218
              textline1     = ' '
              text_option1  = text-212
              text_option2  = text-213
              titel         = text-222
            importing
              answer        = da_answer.
        else.
          return.
        endif.
      endif.
    endif.
  endif.

  if da_answer = '2' and da_lines > 0.
    if da_lines = 1.
      da_vbeln = hnw_vbap-vbeln.
      da_posnr = hnw_vbap-posnr.
    endif.
    if da_lines > 1 or
      ( da_lines = 1 and da_ang_item_exist = charx and
                         tvak-hnwag ca 'BF' ) or             "Angebot
      ( da_lines = 1 and da_kon_item_exist = charx and
                         tvak-hnwkm ca 'BF' ).   "Kontrakt/Lieferplan
      if lv_sc1 eq abap_false.
*       EHP2 SD-BF off
        if call_activity eq gc_activity_lord.
          message e017(sls_lord) with vbap-matnr.
        endif.
*       Es existieren Referenzbelege --> Anzeigen
        call function 'SD_LIST_REFERENCE_DOCUMENT'
          exporting
            kopf_ebene = ' '
            i_kunnr    = kuagv-kunnr
            i_matnr    = vbap-matnr
          importing
            e_vbeln    = da_vbeln
            e_posnr    = da_posnr
          tables
            list_vapma = hnw_vbap
            list_vakpa = hnw_vbak.
      else.
*       EHP2 SD-BF on
        if call_activity  eq gc_activity_lord and
           gf_sapgui_mode is initial.
          if gv_message_vbeln_ref is initial and
             gv_message_posnr_ref is initial.
            message e017(sls_lord) with vbap-matnr.
          else.
            da_vbeln = gv_message_vbeln_ref.
            da_posnr = gv_message_posnr_ref.
            clear gv_message_vbeln_ref.
            clear gv_message_posnr_ref.
          endif.
        else.
*         Display reference documents
          call function 'SD_LIST_REFERENCE_DOCUMENT'
            exporting
              kopf_ebene = ' '
              i_kunnr    = kuagv-kunnr
              i_matnr    = vbap-matnr
            importing
              e_vbeln    = da_vbeln
              e_posnr    = da_posnr
            tables
              list_vapma = hnw_vbap
              list_vakpa = hnw_vbak.
        endif.
      endif.
    endif.
    if not da_vbeln is initial.
      da_matnr = vbap-matnr.
*     aus der angezeigten Liste wurde ein Beleg zum Kopieren gewählt
      mat_auf_hinweis_copy = charx.
      if *vbap-posnr is initial.
        new_item_to_scroll = charx.
      endif.
      perform beleg_pos_kopieren_aus_liste using      da_vbeln
                                                      da_posnr
                                             changing ch_subrc.
      clear mat_auf_hinweis_copy.
      if ch_subrc = 4.
*       no copy of item because of copy requirement routine
        vbap = localvbap.
        rv45a-kwmeng = localrv45a-kwmeng.
        return.
      endif.
*     bei genau einem Vorlagebeleg wird eine S-Meldung ausgegeben
      if da_lines = 1 and ( tvak-hnwag ne 'B' or tvak-hnwkm ne 'B' ).
        if da_ang_item_exist = charx.
          message s727 with da_matnr da_vbeln.
          if lv_sc1 eq abap_true.
            message_collect_lord.
          endif.
        endif.
        if da_kon_item_exist = charx.
          message s728 with da_matnr da_vbeln.
          if lv_sc1 eq abap_true.
            message_collect_lord.
          endif.
        endif.
      endif.
      perform xvbap_lesen_direkt          in program sapfv45p using vbap-posnr svbap-tabix.
      perform vbap_bearbeiten_vorbereiten in program sapfv45p.
      perform xvbep_lesen_erste           in program sapfv45e using space.
      perform vbep_bearbeiten_vorbereiten in program sapfv45e.
      if call_bapi is initial and
        call_function is initial and
        not rv45a-etdat is initial and
        not rv45a-prgbz is initial.
        call function 'PERIOD_AND_DATE_CONVERT_INPUT'
          exporting
            dialog_date_is_in_the_past = space
            external_date              = rv45a-etdat
            external_period            = rv45a-prgbz
          importing
            internal_date              = vbep-edatu
            internal_period            = vbep-prgrs
          exceptions
            no_data                    = 1
            period_invalid             = 2
            date_invalid               = 3.
        case sy-subrc.
          when 1.
            message e394.
          when 2.
            message e346 with rv45a-prgbz.
          when 3.
            message e345 with rv45a-etdat rv45a-prgbz.
        endcase.
         *vbep = vbep .
      endif.
    else.
*     es wird nicht kopiert -> alten Zustand der Pos setzen
      vbap = localvbap.
    endif.
  else.
*    es wird nicht kopiert -> alten Zustand der Pos setzen
    vbap = localvbap.
  endif.
enhancement-point mat_auf_hinweis_pruefen_04 spots es_sapmv45a.
endform.                    "MAT_AUF_HINWEIS_PRUEFEN