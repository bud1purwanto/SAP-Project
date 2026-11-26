*&---------------------------------------------------------------------*
*&  Include           MV45AOLO_LORD_TEXT_PBO
*&---------------------------------------------------------------------*
form dummy_text.
endform.                    "dummy_text


*&---------------------------------------------------------------------*
*&      Form  get_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UT_ITHEAD  text
*----------------------------------------------------------------------*
form get_text using ut_ithead type tdt_ithead.

  data: ls_text type tgs_text_v45a,
        ls_ithead type tds_ithead,
        ls_t002 type t002,
        ls_t002t type t002t,
        lv_tabix type sy-tabix.

  statics:
        st_t002 type table of t002,
        st_t002t type table of t002t.

  refresh gt_text_v45a.
  delete ut_ithead where tdspras eq space.
  loop at ut_ithead into ls_ithead.
    clear ls_text.
    ls_text-id = ls_ithead-tdid.
    ls_text-spras = ls_ithead-tdspras.
    ls_text-tabix = ls_ithead-tabix.
    ls_text-selkz = ls_ithead-selkz.
    clear lv_tabix.
    clear ls_t002.
    read table st_t002 into ls_t002
         with key spras = ls_text-spras
                  binary search.
    lv_tabix = sy-tabix.
    if sy-subrc <> 0.
      select single *
             from t002
             into ls_t002
             where spras = ls_text-spras.
      if sy-subrc = 0.
        insert ls_t002 into st_t002 index lv_tabix.
      endif.
    endif.
    ls_text-spras_iso = ls_t002-laiso.
    if not ls_t002-spras is initial.
      clear lv_tabix.
      read table st_t002t into ls_t002t
           with key spras = sy-langu
                    sprsl = ls_t002-spras
                    binary search.
      lv_tabix = sy-tabix.
      if sy-subrc <> 0.
        select single *
               from t002t
               into ls_t002t
               where spras = sy-langu
                 and sprsl = ls_t002-spras.
        if sy-subrc = 0.
          insert ls_t002t into st_t002t index lv_tabix.
        endif.
      endif.
    endif.
    ls_text-spras_t = ls_t002t-sptxt.
    read table xthead index ls_ithead-tabix.
    ls_text-id_t = xthead-tdtext.
    ls_text-object = xthead-tdobject.
    ls_text-name = xthead-tdname.
    ls_text-type = xthead-tdtexttype.
    append ls_text to gt_text_v45a.
  endloop.

  call function 'SD_TEXT_DEFAULT_LANGUAGE'
    exporting
      fi_object           = tvcom-tdobject
      fi_group            = tvcom-txtgn
      fi_caller           = chara
      fi_vkorg_spras      = tvcom-vkosp
      fit_xvbpa           = xvbpa[]
    importing
      fe_default_language = gv_text_deflangu
    exceptions
      others              = 1.
  if not sy-subrc is initial.
    gv_text_deflangu = sy-langu.
  endif.
  if gv_text_deflangu is initial.
    clear:
      gv_text_deflangu_iso,
      gv_text_deflangu_t.
  else.
    clear lv_tabix.
    clear ls_t002.
    read table st_t002 into ls_t002
         with key spras = gv_text_deflangu
                  binary search.
    lv_tabix = sy-tabix.
    if sy-subrc <> 0.
      select single *
             from t002
             into ls_t002
             where spras = gv_text_deflangu.
      if sy-subrc = 0.
        insert ls_t002 into st_t002 index lv_tabix.
      endif.
    endif.
    gv_text_deflangu_iso = ls_t002-laiso.
    if not ls_t002-spras is initial.
      clear lv_tabix.
      clear ls_t002t.
      read table st_t002t into ls_t002t
           with key spras = sy-langu
                    sprsl = ls_t002-spras
                    binary search.
      lv_tabix = sy-tabix.
      if sy-subrc <> 0.
        select single *
               from t002t
               into ls_t002t
               where spras = sy-langu
                 and sprsl = ls_t002-spras.
        if sy-subrc = 0.
          insert ls_t002t into st_t002t index lv_tabix.
        endif.
      endif.
    endif.
    gv_text_deflangu_t = ls_t002t-sptxt.
  endif.

endform.                    " get_text


*&---------------------------------------------------------------------*
*&      Form  lord_text_pbo_multi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form lord_text_pbo_multi.

  data: lt_ithead type tdt_ithead.
  data: lf_display type flag.

  if cl_ops_switch_check=>sd_sfws_sc4( ) eq abap_true and
     t180-trtyp eq charv and
     vbak-sppaym eq cv_sppaym01 and
     gr_paysp is bound.
    if tvcom-tdobject eq tdobject_vbbp.
      call method gr_paysp->get_change_mode_group
        exporting
          iv_group_id   = cl_sls_paysp_integration=>cv_group_id_text
          iv_trtyp      = t180-trtyp
          is_vbak       = vbak
          is_vbap       = vbap
          is_vbkd       = vbkd
          is_tvak       = tvak
          is_tvap       = tvap
        importing
          ev_no_changes = lf_display.
    else.
      call method gr_paysp->get_change_mode_group
        exporting
          iv_group_id   = cl_sls_paysp_integration=>cv_group_id_text
          iv_trtyp      = t180-trtyp
          is_vbak       = vbak
          is_vbkd       = vbkd
          is_tvak       = tvak
        importing
          ev_no_changes = lf_display.
    endif.
  endif.

  clear gv_tdname_v45a.
  call function 'SD_TEXT_PREPARE'
    exporting
      is_tvcom   = tvcom
      if_display = lf_display
    importing
      et_ithead  = lt_ithead
      ev_tdname  = gv_tdname_v45a
    changing
      ct_xthead  = xthead[].

  perform get_text using lt_ithead.

endform.                    "lord_text_pbo_multi


*&---------------------------------------------------------------------*
*&      Form  lord_text_pbo_single
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TABIX   text
*      -->UV_HANDLE  text
*----------------------------------------------------------------------*
form lord_text_pbo_single using uv_tabix
                                uv_handle type guid_32.

  clear gs_text_v45a.
  clear gf_text_display_only.
  clear gf_xtext_display_only.

  read table gt_text_v45a
       into gs_text_v45a
       index uv_tabix.
  if not sy-subrc is initial.
    if not gv_text_deflangu is initial.
      gs_text_v45a-spras     = gv_text_deflangu.
      gs_text_v45a-spras_iso = gv_text_deflangu_iso.
      gs_text_v45a-spras_t   = gv_text_deflangu_t.
    endif.
  else.
*   Check for old logic or EHP3 XSTRING development
    if cl_ops_switch_check=>sd_sfws_sc2( ) eq abap_false or
       gs_text_v45a-type is initial.
*     Old logic or new logic with SAPScript
      call function 'SD_TEXT_GET_STRING'
        exporting
          iv_id             = gs_text_v45a-id
          iv_spras          = gs_text_v45a-spras
        importing
          ev_first_tline    = gs_text_v45a-first_tline
          ev_text_string    = gs_text_v45a-text_string
          ef_multiple_lines = gs_text_v45a-multiple_lines
          ef_only_display   = gf_text_display_only
          ef_with_format    = gs_text_v45a-formatted.
      gf_xtext_display_only = charx.
      clear gs_text_v45a-text_xstring.
    else.
*     New logic with DOC/RTF
      gs_text_v45a-handle = uv_handle.
      call function 'SD_TEXT_GET_XSTRING'
        exporting
          iv_id           = gs_text_v45a-id
          iv_spras        = gs_text_v45a-spras
          iv_handle       = gs_text_v45a-handle
        importing
          ev_text_xstring = gs_text_v45a-text_xstring
          ef_only_display = gf_xtext_display_only.
      gf_text_display_only = charx.
      gs_text_v45a-formatted = charx.
      clear gs_text_v45a-first_tline.
      clear gs_text_v45a-text_string.
    endif.
  endif.

endform.                    "lord_text_pbo_single


*&---------------------------------------------------------------------*
*&      Form  feldasuwahl_lord_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UF_STORED  text
*----------------------------------------------------------------------*
form feldauswahl_lord_text using uf_stored.

  case screen-name.
    when 'GS_TEXT_V45A-SELKZ'.
      if uf_stored is initial.
        screen-input = 0.
      else.
        screen-input = 1.
      endif.
    when 'GS_TEXT_V45A-ID_T' or
         'GS_TEXT_V45A-SPRAS_T' or
         'GS_TEXT_V45A-TYPE'.
      screen-input = 0.
      screen-display_3d = 0.
    when 'GS_TEXT_V45A-ID' or
         'GS_TEXT_V45A-SPRAS' or
         'GS_TEXT_V45A-SPRAS_ISO'.
      if uf_stored is initial.
        screen-input = 1.
      else.
        screen-input = 0.
      endif.
      if t180-trtyp eq 'A'.
        screen-input = 0.
      endif.
    when 'GS_TEXT_V45A-TEXT_STRING' or
         'GS_TEXT_V45A-FIRST_TLINE'.
      if gf_text_display_only is initial.
        screen-input = 1.
      else.
        screen-input = 0.
      endif.
      if t180-trtyp eq 'A'.
        screen-input = 0.
      endif.
      if screen-name eq 'GS_TEXT_V45A-FIRST_TLINE' and
         screen-input eq 1.
        if not gs_text_v45a-multiple_lines is initial.
          screen-input = 0.
        endif.
      endif.
    when 'GS_TEXT_V45A-TEXT_XSTRING'.
      if t180-trtyp eq 'A'.
        screen-input = 0.
      else.
        if gf_xtext_display_only is initial.
          screen-input = 1.
        else.
          screen-input = 0.
        endif.
      endif.
  endcase.

endform.                    "feldauswahl_lord_text


*&---------------------------------------------------------------------*
*&      Form  text_wa_prepare
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->UV_TABIX   text
*      -->UV_HANDLE  text
*----------------------------------------------------------------------*
form text_wa_prepare using uv_tabix
                           uv_handle type guid_32.

  clear gs_text_v45a.
  read table gt_text_v45a
       into gs_text_v45a
       index uv_tabix.
  if sy-subrc <> 0.
    clear gs_text_v45a.
    if not gv_text_deflangu is initial.
      gs_text_v45a-spras     = gv_text_deflangu.
      gs_text_v45a-spras_iso = gv_text_deflangu_iso.
      gs_text_v45a-spras_t   = gv_text_deflangu_t.
    endif.
  endif.
* Key HANDLE cannot be dynamically field exported and has to be set
* within here
  gs_text_v45a-handle = uv_handle.

endform.                    "text_wa_prepare