*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PREPARE_PARTNER_SCREE                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PREPARE_PARTNER_SCREEN
*&---------------------------------------------------------------------*
form prepare_partner_screen.

  data: lf_objectkey type swo_typeid,
        ls_sdorgdata type sdorgdata,
        lf_active type c,
        lt_filter type tpafilter occurs 0.

  lf_objectkey = likp-vbeln.
  ls_sdorgdata-vkorg = likp-vkorg.
  ls_sdorgdata-vtweg = rv50a-vtweg.
  ls_sdorgdata-spart = rv50a-spart.

* Partners are not changeable in display mode or when goods issue has
* been posted or when document has been sent to a decentral WMS
ENHANCEMENT-SECTION     MV50AF0P_PREPARE_PARTNER_SCR_1 SPOTS ES_SAPMV50A.
  if t180-trtyp eq chara or
     vbuk-wbstk eq charc or
     ( likp-vlstk eq charb and v50agl-dlv_change eq space ) or
     ( likp-vlstk eq chare and likp-verursys is initial ) or
       likp-vlstk eq charc or
       likp-sakes eq charb.                 "GTS Safe Keeping Status
    lf_active = space.
  else.
    lf_active = charx.
  endif.
END-ENHANCEMENT-SECTION.

  call function 'SD_PARTNER_DATA_PUT'
    exporting
      fic_objecttype      = 'LIKP'
      fic_objectkey       = lf_objectkey
    tables
      frt_xvbpa           = xvbpa
      frt_yvbpa           = yvbpa
      frt_xvbuv           = xvbuv
      frt_hvbuv           = hvbuv
      frt_xvbadr          = xvbadr
      frt_yvbadr          = yvbadr
    exceptions
      no_object_specified = 1
      others              = 2.
  if sy-subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

* Read defined filters from customizing
  select * from tpafilter
           into table lt_filter.
  call function 'SD_PARTNER_SUBSCREEN_1000_INIT'
       exporting
          fif_active                   = lf_active
           fif_standard                 = 'X'
           fif_telef                    = 'X'
           fif_faxf                     = 'X'
           fif_master                   = 'X'
           fif_altern                   = 'X'
           fif_info                     = 'X'
           fif_determ_log               = 'X'
           fif_incompletion_log         = ' '
           fif_filter_lbox              = 'X'
           fif_act_filter               = 'PARALL'
           fif_pos                      = '000000'
           fif_var                      = 'VAR_1'
           fif_paproc_h                 = tvlk-pargr
*          FIF_PAPROC_I                 = ' '
*          FIS_VBUV                     = ' '
           fif_pos_display_only         = ' '
           fic_objecttype               = 'LIKP'
           fic_objectkey                = lf_objectkey
           fis_sdorgdata                = ls_sdorgdata
*          FIF_NO_ERROR_MESSAGES        = ' '
*          FIF_KNREF_PARNR              = ' '
       tables
*          FIT_FUNC                     =
           fit_filter                   = lt_filter
      exceptions
           partner_proc_header_required = 1
           partner_procedures_required  = 2
           missing_required_values      = 3
           others                       = 4
            .
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

endform.                               " PREPARE_PARTNER_SCREEN