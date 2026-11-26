*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_HEAD_PBO
*&---------------------------------------------------------------------*

form lord_hvstat_pbo.

  data:
    lt_text   type table of textpool,

    ls_text   type textpool.

  field-symbols:
    <lv_data> type data.

  perform xvbuk_uebersicht_vorbereiten(sapfv45k).
  perform status_text_edit(sapfv45p) using vbak-objnr.
  perform vbak_bearbeiten_vorbereiten.

  lt_text = cl_lord_services=>get_textpool( iv_program = 'SAPLSLS_LORD' iv_langu = sy-langu ).

* Fill empty overall status text
  if vbstt-gbsta_bez is initial.
    read table lt_text into ls_text with key key = '010'.
    vbstt-gbsta_bez = ls_text-entry.
  endif.

* Fill all remaining empty texts with fallback text
  read table lt_text into ls_text with key key = '009'.
  do.
    assign component sy-index of structure vbstt to <lv_data>.
    if not sy-subrc is initial.
*     Reached last component
      exit.
    endif.
    if <lv_data> is initial.
*     Text is empty
      <lv_data> = ls_text-entry.
    endif.
  enddo.

endform.                    "lord_hvstat_pbo
*&---------------------------------------------------------------------*
*&      Form  lord_hvstat_pbo_cum
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_hvstat_pbo_cum changing cs_lord_vbuk_cum     like gs_lord_vbuk_cum
                                  cs_lord_vbuk_cum_bez like gs_lord_vbuk_cum_bez.

  data: lt_text type table of textpool,
        ls_text type textpool.

  data: lt_vbfa  type vbfa_t,
        ls_vbfa  type vbfa,
        ls_vbuk type vbuk,
        ls_tvbst type tvbst,
        lv_wbstk type wbstk,
        lv_fkstk type fkstk.

  clear gs_lord_vbuk_cum.
  clear gs_lord_vbuk_cum_bez.

  if cs_lord_vbuk_cum     is initial or
     cs_lord_vbuk_cum_bez is initial.

    clear cs_lord_vbuk_cum.
    clear cs_lord_vbuk_cum_bez.

*   fill necessary information
    cs_lord_vbuk_cum-vbeln = cs_lord_vbuk_cum_bez-vbeln = vbak-vbeln.

    lt_vbfa = xvbfa[].

*   for delivery relevance detmerine wbstk
    if ( not xvbuk-lfstk is initial and
         not vbak-vbtyp  eq 'W'         ).

*     read necessary texts
      lt_text = cl_lord_services=>get_textpool( iv_program = 'SAPLV75S' iv_langu = sy-langu ).

      loop at lt_vbfa into ls_vbfa where
                           vbelv   = vbak-vbeln and
                           vbtyp_v = vbak-vbtyp.
        check ls_vbfa-vbtyp_n ca vbtyp_lief.
        clear ls_vbuk.
        call function 'SD_VBUK_SINGLE_READ'
          exporting
            i_vbeln = ls_vbfa-vbeln
          importing
            e_vbuk  = ls_vbuk
          exceptions
            others  = 1.
        if sy-subrc = 0.
          perform gi_fk_status in program saplv75s using ls_vbuk-wbstk ls_vbuk-fkstk
                                 changing lv_wbstk
                                          lv_fkstk.
        endif.
      endloop.
      move lv_wbstk to cs_lord_vbuk_cum-wbstk.
      case cs_lord_vbuk_cum-wbstk.
        when chara.
          read table lt_text into ls_text with key key = 'S48'.
        when charb.
          read table lt_text into ls_text with key key = 'S49'.
        when charc.
          read table lt_text into ls_text with key key = 'S50'.
        when space.
          ls_text-entry = vbstt-wbsta_bez.
      endcase.
      cs_lord_vbuk_cum_bez-wbstk_bez = ls_text-entry.
    else.
*     if not delivery-relevant take xvbuk values
      cs_lord_vbuk_cum-wbstk = xvbuk-wbstk.
      cs_lord_vbuk_cum_bez-wbstk_bez = vbstt-wbsta_bez.
    endif.

    move lv_fkstk to cs_lord_vbuk_cum-fkstk.
    if not cs_lord_vbuk_cum-fkstk is initial.
      ls_tvbst-tbnam = 'VBUK'.
      ls_tvbst-fdnam = 'FKSTK'.
      ls_tvbst-spras = sy-langu.
      ls_tvbst-statu = cs_lord_vbuk_cum-fkstk.
      call function 'RV_DOCUMENT_STATUS_TEXTS'
        exporting
          tvbst_wa = ls_tvbst
        importing
          text     = cs_lord_vbuk_cum_bez-fkstk_bez.
    else.
      cs_lord_vbuk_cum_bez-fkstk_bez = vbstt-fksta_bez.
    endif.
  endif.

  gs_lord_vbuk_cum = cs_lord_vbuk_cum.
  gs_lord_vbuk_cum_bez = cs_lord_vbuk_cum_bez.

endform.                    "lord_hvstat_pbo_cum
*&---------------------------------------------------------------------*
*&      Form  lord_gruko_pbo_single
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TABIX   text
*----------------------------------------------------------------------*
form lord_gruko_pbo_single using uv_tabix like sy-tabix.

* set gruko_tabix_aktuell to LORD tabbix value
  gruko_tabix_aktuell = uv_tabix.

  perform gruko_lesen.

endform.                    "lord_gruko_pbo_single
*&---------------------------------------------------------------------*
*&      Form  lord_gruko_fill_tabix
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->LS_OBJKEY     text
*      -->GT_OBJ_TABIX  text
*----------------------------------------------------------------------*
form lord_gruko_fill_tabix using ls_objkey type any
                                 gt_obj_tabix type any table.

  data: ls_gruko type rv46g_doc.

  loop at gruko into ls_gruko.
    clear ls_objkey.
    move-corresponding ls_gruko to ls_objkey.
    insert ls_objkey into table gt_obj_tabix.
  endloop.

endform.                    "lord_gruko_fill_tabix


*&---------------------------------------------------------------------*
*&      Form  get_head_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_NAME    text
*      -->UR_DATA    text
*----------------------------------------------------------------------*
form get_head_data using uv_name ur_data.

  field-symbols:
        <lr_data> type any.

  assign (uv_name) to <lr_data>.
  if sy-subrc = 0.
    try.
        ur_data = <lr_data>.
      catch cx_root.
    endtry.
  endif.

endform.                    "get_head_data