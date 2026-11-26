*eject
*&---------------------------------------------------------------------*
*&      Form  VTBER_BESTIMMEN
*&---------------------------------------------------------------------*
*       Vertriebsbereiche bestimmen, für die der Kunde angelegt ist
*       bzw. eingegebenen Vertriebsbereich prüfen
*----------------------------------------------------------------------*
form vtber_bestimmen using us_kunnr like kna1-kunnr.

  data: h_check_only_flag,
        da_activity(2) value actvt_01,
        da_authority_flag.

ENHANCEMENT-POINT VTBER_BESTIMMEN_01 SPOTS ES_SAPMV45A STATIC.
* Vertriebsbereiche zum Kunden
  data: begin of hknvv.
          include structure knvv.
  data: end of hknvv.

  if call_activity eq gc_activity_lord.
    perform determine_sales_area using us_kunnr.
    exit.
  endif.

  clear hknvv.

* Berechtigungsprüfung: Flag setzen oder nicht
  if no_authority_check is initial.
    da_authority_flag = charx.
  else.
    clear da_authority_flag.
  endif.

  move us_kunnr to hknvv-kunnr.
  if xvbak-agupda is initial.
    move default_vkorg to hknvv-vkorg.
    move default_vtweg to hknvv-vtweg.
    move default_spart to hknvv-spart.
    clear h_check_only_flag.
  else.
    move save-vkorg to hknvv-vkorg.
    move save-vtweg to hknvv-vtweg.
    move save-spart to hknvv-spart.
    h_check_only_flag = 'X'.
  endif.

  call function 'SD_PARTNER_SALES_AREA_CHECK'
    exporting
      caller_id         = 'SAPMV45A'
      check_only_flag   = h_check_only_flag
      activity          = da_activity
      authority_flag    = da_authority_flag
      auart             = vbak-auart
    changing
      c_knvv            = hknvv
    exceptions
      no_knvv           = 1
      no_kna1           = 2
      no_vtber_selected = 3
      no_valid_knvv     = 4
      others            = 5.

  if sy-subrc = 0.
    if ( hknvv-vkorg ne default_vkorg and
         not default_vkorg is initial ) or
       ( hknvv-vtweg ne default_vtweg and
         not default_vtweg is initial ) or
       ( hknvv-spart ne default_spart and
         not default_spart is initial ).
      message i101(vp) with hknvv-vkorg hknvv-vtweg hknvv-spart.
ENHANCEMENT-POINT VTBER_BESTIMMEN_02 SPOTS ES_SAPMV45A.
    endif.
    move hknvv-vkorg to: vbak-vkorg,
                         save-vkorg.
    move hknvv-vtweg to: vbak-vtweg,
                         save-vtweg.
    move hknvv-spart to: vbak-spart,
                         save-spart.

ENHANCEMENT-POINT VTBER_BESTIMMEN_03 SPOTS ES_SAPMV45A.
    if not vbak-vkbur is initial.
      perform tvkbz_select(sapmv45a) using vbak-vkorg
                                           vbak-vtweg
                                           vbak-spart
                                           vbak-vkbur
                                           space
                                           sy-subrc.

      if sy-subrc ne 0.
        message s051(v1) with vbak-vkbur vbak-vkorg vbak-vtweg vbak-spart.
        clear vbak-vkbur.
        xvbak-agupda = charx.
      endif.
    endif.
    if not vbak-vkgrp is initial.
      perform tvbvk_select(sapmv45a) using vbak-vkbur
                                           vbak-vkgrp
                                           space
                                           sy-subrc.

      if sy-subrc ne 0.
        message s052(v1) with vbak-vkgrp vbak-vkbur.
        clear vbak-vkgrp.
        xvbak-agupda = charx.
      endif.
    endif.
  else.
    if sy-subrc ne 4.
      message e102(vp).
    else.
      message e423(v1) with us_kunnr.
    endif.
  endif.

endform.                               " VTBER_BESTIMMEN


*&--------------------------------------------------------------------*
*&      Form  determine_sales_area
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->US_KUNNR   text
*---------------------------------------------------------------------*
form determine_sales_area using us_kunnr like kna1-kunnr.

  data: lt_knvv type table of knvv,
        ls_knvv type knvv,
        lf_authority_check type xfeld,
        lf_check_only type xfeld,
        lv_vkorg type vkorg,
        lv_vtweg type vtweg,
        lv_spart type spart,
        lv_vkorg_def type vkorg,
        lv_vtweg_def type vtweg,
        lv_spart_def type spart,
        lv_count type i.
  data: lv_table_auth type char1.

* authority check
  if no_authority_check is initial.
    lf_authority_check = charx.
    if call_activity eq gc_activity_lord.
      lv_table_auth = charx.
    endif.
  endif.

  lv_vkorg_def = gs_vtber_ext-vkorg.
  lv_vtweg_def = gs_vtber_ext-vtweg.
  lv_spart_def = gs_vtber_ext-spart.

  move us_kunnr to ls_knvv-kunnr.
  if xvbak-agupda is initial.
    move lv_vkorg_def to ls_knvv-vkorg.
    move lv_vtweg_def to ls_knvv-vtweg.
    move lv_spart_def to ls_knvv-spart.
  else.
    move save-vkorg to ls_knvv-vkorg.
    move save-vtweg to ls_knvv-vtweg.
    move save-spart to ls_knvv-spart.
    lf_check_only = charx.
  endif.

  call function 'SD_PARTNER_SALES_AREA_CHECK'
    exporting
      caller_id         = 'SAPMV45A'
      check_only_flag   = lf_check_only
      activity          = '01'
      authority_flag    = lf_authority_check
      auart             = vbak-auart
      fif_only_table    = charx
      fif_only_table_auth = lv_table_auth
    tables
      frt_knvv          = lt_knvv
    changing
      c_knvv            = ls_knvv
    exceptions
      no_knvv           = 1
      no_kna1           = 2
      no_vtber_selected = 3
      no_valid_knvv     = 4
      others            = 5.
  if sy-subrc = 0 and
       not lt_knvv[] is initial.
    read table lt_knvv
         into ls_knvv
         with key kunnr = us_kunnr
                  vkorg = lv_vkorg_def
                  vtweg = lv_vtweg_def
                  spart = lv_spart_def.
    if sy-subrc = 0.
      lv_vkorg = ls_knvv-vkorg.
      lv_vtweg = ls_knvv-vtweg.
      lv_spart = ls_knvv-spart.
      clear gs_vtber_ext-vkorg.
      clear gs_vtber_ext-vtweg.
      clear gs_vtber_ext-spart.
    else.
      if not lv_vkorg_def is initial.
        delete lt_knvv where vkorg ne lv_vkorg_def.
      endif.
      if not lv_vtweg_def is initial.
        delete lt_knvv where vtweg ne lv_vtweg_def.
      endif.
      if not lv_spart_def is initial.
        delete lt_knvv where spart ne lv_spart_def.
      endif.
      describe table lt_knvv lines lv_count.
      if lv_count = 1.
        read table lt_knvv into ls_knvv index 1.
        lv_vkorg = ls_knvv-vkorg.
        lv_vtweg = ls_knvv-vtweg.
        lv_spart = ls_knvv-spart.
        clear gs_vtber_ext-vkorg.
        clear gs_vtber_ext-vtweg.
        clear gs_vtber_ext-spart.
      else.
        gs_vtber_ext-kunnr = us_kunnr.
        gs_vtber_ext-vkorg = lv_vkorg_def.
        gs_vtber_ext-vtweg = lv_vtweg_def.
        gs_vtber_ext-spart = lv_spart_def.
        message e102(vp).
      endif.
    endif.
    if ( lv_vkorg ne lv_vkorg_def and
         not lv_vkorg_def is initial ) or
       ( lv_vtweg ne lv_vtweg_def and
         not lv_vtweg_def is initial ) or
       ( lv_spart ne lv_spart_def and
         not lv_spart_def is initial ).
      message i101(vp) with lv_vkorg lv_vtweg lv_spart.
    endif.
    move lv_vkorg to: vbak-vkorg,
                      save-vkorg.
    move lv_vtweg to: vbak-vtweg,
                      save-vtweg.
    move lv_spart to: vbak-spart,
                      save-spart.
    if not vbak-vkbur is initial.
      perform tvkbz_select(sapmv45a) using vbak-vkorg
                                           vbak-vtweg
                                           vbak-spart
                                           vbak-vkbur
                                           space
                                           sy-subrc.
      if sy-subrc ne 0.
        message s051(v1) with vbak-vkbur vbak-vkorg vbak-vtweg vbak-spart.
        clear vbak-vkbur.
        xvbak-agupda = charx.
      endif.
    endif.
    if not vbak-vkgrp is initial.
      perform tvbvk_select(sapmv45a) using vbak-vkbur
                                           vbak-vkgrp
                                           space
                                           sy-subrc.
      if sy-subrc ne 0.
        message s052(v1) with vbak-vkgrp vbak-vkbur.
        clear vbak-vkgrp.
        xvbak-agupda = charx.
      endif.
    endif.
  else.
    if sy-subrc ne 4.
      message e102(vp).
    else.
      message e423(v1) with us_kunnr.
    endif.
  endif.

endform.                    "determine_sales_area