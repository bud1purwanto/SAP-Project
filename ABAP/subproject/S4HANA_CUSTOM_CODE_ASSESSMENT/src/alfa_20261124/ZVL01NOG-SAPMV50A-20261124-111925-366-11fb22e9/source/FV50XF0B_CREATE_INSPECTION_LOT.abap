***INCLUDE FV50XF0B_CREATE_INSPECTION_LOT .
*---------------------------------------------------------------------*
*       FORM create_inspection_lot                                    *
*---------------------------------------------------------------------*
*  -->  IF_VBELN                                                      *
*---------------------------------------------------------------------*
form create_inspection_lot using if_vbeln like likp-vbeln.

  data: lt_hum_qm   type hum_qm occurs 0,
        lt_qm       type qmhumtab,
        lt_xvbpa    type vbpavb occurs 0,                      "n_745057
        lt_header   type vsep_t_vekp,
        lt_items    type vsep_t_vepo.
  data: ls_object   type hum_object,
        ls_packing  type vse_s_v51h,
        ls_flags    type v51p_select_flags,
        ls_header51 TYPE header51,               "n_695495
        ls_hum_qm   type hum_qm,
        ls_qmbhu    type qmbhu.
  data: lf_xlips_insmk type insmk,
        lf_xlips_qplos type qplos,
        lf_times_veo type sytabix,
        lf_xlikp_lines type i,                               "v_n_745057
        lf_xvbpa_lines type i,
        lf_total_lines type f,
        lf_tabix       like sy-tabix,                        "^_n_745057
        lf_qsshk     type qsshk,
        lf_unique    type xfeld,
        lf_insmk_wo_lot type qkz,
        lf_um        type xfeld.

  field-symbols: <likp> type likpvb, <header> type vekpvb,
        <ls_xvbpa> like line of xvbpa,                         "n_745057
        <item> type vepovb.

  call function 'HU_TVSHP_SELECT'
           importing
                ef_exidv_unique       =  lf_unique.
  check not lf_unique is initial.
  check v50agl-confirm_central is initial.

* Buffer status of GS_HEADER51                    "v_n_695495
  IF v50agl-sammelgang IS INITIAL                   "n_965159
    OR v50agl-extend_delivery IS NOT INITIAL.      "n_1059541
    CALL FUNCTION 'V51P_GET_HEADER_DATA'
            IMPORTING
              es_header51 = ls_header51.          "^_n_695495
  ENDIF.
  ls_packing-display = t180-trtyp.
  ls_packing-init    = charx.
  read table xlikp assigning <likp> with key vbeln = if_vbeln.


* if we create many deliveries we have to pass over only partners
* for the delivery which is currently processed to prevent
* memory overflow
  if <LIKP>-VBTYP eq charj and                               "v_n_745057
     ( not v50agl-sammelgang is initial or
       not v50agl-mult is initial ).                           "n_902569
    describe table xlikp lines lf_xlikp_lines.
    describe table xvbpa lines lf_xvbpa_lines.
    lf_total_lines = lf_xlikp_lines * lf_xvbpa_lines.
    if lf_total_lines gt 1000000.
      lt_xvbpa[] = xvbpa[].
      refresh xvbpa.
      read table lt_xvbpa with key vbeln = <likp>-vbeln
                                   transporting no fields.
      lf_tabix = sy-tabix.
      loop at lt_xvbpa assigning <ls_xvbpa> from lf_tabix.
        if <likp>-vbeln ne <ls_xvbpa>-vbeln.
          exit.
        else.
          append <ls_xvbpa> to xvbpa.
        endif.
      endloop.
    endif.
  endif.                                                     "^_n_745057

  perform init_complete_packing(sapmv50a) using    <likp>
                                          changing ls_packing.

  if not lt_xvbpa[] is initial.                              "v_n_745057
    xvbpa[] = lt_xvbpa[].
    refresh lt_xvbpa.
  endif.                                                     "^_n_745057

  ls_object-object = ls_packing-object.
  ls_object-objkey = if_vbeln.
  ls_flags-no_db_select = charx.
  call function 'V51P_GET_TABLES'
           exporting
                is_flags         = ls_flags
                is_object        = ls_object
           importing
                et_xvekp         = lt_header
                et_xvepo         = lt_items
           exceptions
                hus_locked       = 1
                no_hu_found      = 2
                others           = 99.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
    exit.
  endif.
  delete lt_items where velin ne '1'.
  delete lt_items where not qplos is initial.
*check not lt_items is initial.          "v_n_695495
  if not lt_items[] is initial.          "^_n_695495

  loop at xlips where vbeln = if_vbeln.
*... create only one inspection lot ............
    check xlips-qplos is initial.
*... SY-TABIX aus dem LOOP über XLIPS retten                   "1063898
    slips-tabix = sy-tabix.
    ilips-tabix = sy-tabix.
    PERFORM xvbup_lesen(sapfv50p) USING xlips-vbeln           "v_989498
                                        xlips-posnr.
*... no inspection lot if WM already activ on this item
    check xvbup-lvsta NA 'BC'.                                "^_989498
                                                               "1063898
    refresh: lt_hum_qm, lt_qm.
    clear:   ls_hum_qm, ls_qmbhu, lf_qsshk, lf_um.
    perform read_t156 using    xlips
                      changing lf_qsshk.
    check not lf_qsshk is initial.
    do.
      loop at lt_items assigning <item> where vbeln = xlips-vbeln and
                                              posnr = xlips-posnr and
                                              vemng_flo > 0.
*        check <item>-vemng_flo > 0.                          SP_662814
        clear ls_hum_qm.
        ls_hum_qm-venum = <item>-venum.
        ls_hum_qm-vepos = <item>-vepos.
        ls_hum_qm-vemng = <item>-vemng_flo.
        ls_hum_qm-vemeh = <item>-vemeh.
        read table lt_header assigning <header>
                             with key venum = <item>-venum
                             binary search.
        if sy-subrc is initial.
          ls_hum_qm-exidv = <header>-exidv.
          if ls_qmbhu-gebeh ne <header>-meins and
             not ls_qmbhu-gebeh is initial.
*            exit.                                           SP_658894
*            This was an attempt to create several inspection lots
*            for one delivery item. This is not possible as the
*            inspection lot number in the item has to be unique.
          else.
            ls_qmbhu-gebeh = <header>-meins.
          endif.
        endif.
        append ls_hum_qm to lt_hum_qm.
        delete lt_items.
      endloop.
      if not sy-subrc is initial.
        exit.
      endif.
*    describe table gt_hum_qm lines lf_times_vepo.
*    if lf_times_vepo >= 1.
      read table lt_hum_qm transporting no fields index 1.
      check sy-subrc is initial.
      move-corresponding xlikp to ls_qmbhu.
      move-corresponding xlips to ls_qmbhu.
      if tvlk-aufer ca 'OH' and not xlips-ummat is initial.
        if ( xlips-shkzg_um = '2' and not xlips-shkzg = 'S' ) or
           ( xlips-shkzg_um = '1' and xlips-shkzg = 'S' ).
        else.
          ls_qmbhu-matnr = xlips-ummat.
          ls_qmbhu-charg = xlips-umcha.
          ls_qmbhu-werks = xlips-umwrk.
          ls_qmbhu-lgort = xlips-umlgo.
          ls_qmbhu-sobkz = xlips-umsok.
          lf_um = 'X'.
          perform determine_xchpf_xchar using ls_qmbhu-matnr
                                              ls_qmbhu-werks
                                     changing ls_qmbhu-xchar
                                              ls_qmbhu-xchpf.
        endif.
      endif.
      if xlips-charg is initial and not xlips-xchar is initial
         and not xlips-bwtar is initial.
        if lf_um is initial.
          ls_qmbhu-charg = xlips-bwtar.
        else.
          ls_qmbhu-charg = xlips-UMBAR.
        endif.
      endif.
      perform lips_bearbeiten_vorbereiten(sapfv50p).        "v_n_568477
      perform lips_referenz_lesen(sapfv50p).                "^_n_568477
      ls_qmbhu-ekorg = ekko-ekorg.

      call function 'QMHU_INSPECTION_LOT_CREATE'
           exporting
                i_qmbhu    = ls_qmbhu
                i_herkunft = lf_qsshk
           importing
                e_insmk    = lf_xlips_insmk
                e_prueflos = lf_xlips_qplos
                e_insmk_wo_lot = lf_insmk_wo_lot
           tables
                t_hupos    = lt_hum_qm.
      check not lf_xlips_qplos is initial or
            not lf_insmk_wo_lot is initial.                   "SP_539516
*     Line deleted                                            "n_568477
*... Änderungen in die LIPS übernehmen, falls notwendig
      if *lips-insmk ne lf_xlips_insmk or
         *lips-qplos ne lf_xlips_qplos.
        lips-insmk = lf_xlips_insmk.

*<<<<<< Bei Umbuchungen sind oft die Nach-Daten betroffen - dh. das
*<<<<<< INSMK stimmt nicht mit dem BESTQ überein!!!
        data: lf_bestq type bestq.

*... Umbuchung oder WE/WA?
    if not xlips-ummat is initial.  "Umbuchung => bestq gilt für NACH!
*...... Daten in Lips gedreht!!!
      if ( xlips-shkzg_um = '2' and not xlips-shkzg = 'S' ) or
         ( xlips-shkzg_um = '1' and xlips-shkzg = 'S' ).
        case lf_xlips_insmk.
          when chars or char3.
            lips-bestq = chars.
          when charx or char2.
            lips-bestq = charq.
          when others.
            clear lips-bestq.
        endcase.
        lf_bestq = lips-umbsq.
      else.
        case lf_xlips_insmk.
          when chars or char3.
            lips-umbsq = chars.
          when charx or char2.
            lips-umbsq = charq.
          when others.
            clear: lips-umbsq.
        endcase.
        lf_bestq = xlips-bestq.
      endif.
    else.         "keine Umbuchung, Umlagerung
        if ls_packing-object = '01'.
* message 'Für Auslieferungen dürfen keine Prüflose angelegt werden!'
          message x099(hugeneral).
        endif.
*... Standard-Anlieferung
        case lf_xlips_insmk.
          when chars or char3.
            lips-bestq = chars.
          when charx or char2.
            lips-bestq = charq.
          when others.
            clear lips-bestq.
          endcase.
          lf_bestq = lips-bestq.
        endif.

        lips-qplos = lf_xlips_qplos.
        perform lips_bearbeiten(sapfv50p).
        check not lips-qplos is initial.
        lt_qm = lt_hum_qm[].
        call function 'HU_ITEM_QPLOS'
             exporting
                  if_qplos  = lips-qplos
                  if_bestq  = lf_bestq                         "n_839622
                  it_hum_qm = lt_qm
             exceptions
                  error     = 1.
        if not sy-subrc is initial.
          message id sy-msgid type 'A' number sy-msgid.
        endif.
      endif.
*    endif.
    enddo.
  endloop.

  ENDIF.                                  "v_n_695495
* Restore status of GS_HEADER51
  CALL FUNCTION 'V51P_FILL_GT'
       EXPORTING
            is_header51 = ls_header51.    "^_n_695495

* Posting modules have been moved to BELEG_SICHERN_POST (HP_368559)

endform.
*&---------------------------------------------------------------------*
*&      Form  READ_T156
*&---------------------------------------------------------------------*
form read_t156 using    is_lips type lipsvb
               changing ef_qsshk type t156s-qsshk.
  statics: sf_ebeln type ebeln, sf_kzzug type char1.
  data: ls_tqhu2 type tqhu2.
  data: lf_kzbew type char1, lf_tabix type sytabix,
        lf_bsakz type bsakz.

  if is_lips-vgtyp = 'V'.
    lf_kzbew = 'B'.
    if sf_ebeln <> is_lips-vgbel.
      select single ebeln bsakz from ekko into (sf_ebeln, lf_bsakz)
                                where ebeln = is_lips-vgbel.
      if lf_bsakz = 'T'.
        sf_kzzug = 'X'.
      else.                                                   "n_982519
        clear sf_kzzug.                                       "n_982519
      endif.
    endif.
  else.
    if not is_lips-aufnr is initial.
      select single * from tqhu2 into ls_tqhu2 where vpobj = '09'.
      check sy-subrc is initial.
      check not ls_tqhu2-herkunft is initial.
      lf_kzbew = 'F'.
*     clear: sf_kzzug.                                       "n_1295218
    endif.
    CLEAR: SF_KZZUG, SF_EBELN.                      "n_1295218, 1436126
  endif.
  CALL FUNCTION 'HU_QSSHK_DETERMINE'
           EXPORTING
                IF_KZBEW       = lf_kzbew
                IF_KZZUG       = sf_kzzug
                IF_KZVBR       = is_lips-kzvbr
                IF_MATNR       = is_lips-matnr
                IF_MTART       = is_lips-mtart
                IF_WERKS       = is_lips-werks
                IF_SOBKZ       = is_lips-sobkz
                IF_BWART       = is_lips-bwart
           IMPORTING
                EF_QSSHK       = ef_qsshk
           EXCEPTIONS
                ERROR          = 1
                OTHERS         = 99.
  IF SY-SUBRC <> 0.
    clear: ef_qsshk.
  ENDIF.
endform.                    " READ_T156

form determine_xchpf_xchar using if_matnr type matnr
                                 if_werks type werks_d
                        changing ef_xchar type xfeld
                                 ef_xchpf type xfeld.

  DATA: LS_MTCOM TYPE MTCOM, LS_MARC TYPE MARC.

  check not if_werks is initial.
  check not if_matnr is initial.
  LS_MTCOM-MAXTZ = 50.
  LS_MTCOM-KZMPN = 'X'.
  LS_MTCOM-SPRAS = SY-LANGU.
  LS_MTCOM-KENNG = 'MARC'.
  LS_MTCOM-MATNR = if_MATNR.
  LS_MTCOM-WERKS = if_WERKS.
  CALL FUNCTION 'MATERIAL_READ'
           EXPORTING
                SCHLUESSEL = LS_MTCOM
           IMPORTING
                MATDATEN  = LS_MARC
           EXCEPTIONS
                ERROR_MESSAGE = 98                           "SP_672873
                OTHERS = 99.
  check sy-subrc is initial.
  ef_XCHAR = LS_MARC-XCHAR.
  ef_XCHPF = LS_MARC-XCHPF.
endform.