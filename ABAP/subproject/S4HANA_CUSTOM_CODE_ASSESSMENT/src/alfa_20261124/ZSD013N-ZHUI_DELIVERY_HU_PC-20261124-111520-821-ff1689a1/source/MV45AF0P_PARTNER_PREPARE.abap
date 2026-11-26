*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_PARTNER_PREPARE                                   *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  PARTNER_PREPARE
*&---------------------------------------------------------------------*
*       Partner-Subscreen wird vorbereitet
*----------------------------------------------------------------------*
FORM partner_prepare USING us_level TYPE c.

  DATA: lf_objectkey TYPE swo_typeid,
        lf_objecttype TYPE nast-objtype,
        lf_objecttype_item TYPE nast-objtype,
        lf_partner_objecttype TYPE swo_objtyp,
        lf_partner_objecttype_item TYPE swo_objtyp,
        ls_sdorgdata TYPE sdorgdata,
        lf_active TYPE xfeld,
        lt_filter LIKE tpafilter OCCURS 0,
        da_vbuv LIKE vbuvvb,
        da_call_back_memory_wa TYPE lv09a_ty_call_back_memory_wa,
        da_call_back_memory TYPE lv09a_ty_call_back_memory.
  DATA: lv_no_changes TYPE xfeld.

  CLEAR: rv02p-weupd, rv02p-rgupd, rv02p-sbupd.

  mv45a_dataloss_par_sub = r185d-dataloss.

  lf_objectkey = vbak-vbeln.
  ls_sdorgdata-vkorg = vbak-vkorg.
  ls_sdorgdata-vtweg = vbak-vtweg.
  ls_sdorgdata-doctype = vbak-auart.

  CALL FUNCTION 'SD_OBJECT_TYPE_DETERMINE'
    EXPORTING
      i_document_type        = vbak-vbtyp
      i_tvak                 = tvak
    IMPORTING
      e_business_object      = lf_objecttype
      e_business_object_item = lf_objecttype_item.
  lf_partner_objecttype = lf_objecttype.
  lf_partner_objecttype_item = lf_objecttype_item.

* Define call-back-functions
  da_call_back_memory_wa-objecttype = lf_partner_objecttype.
  da_call_back_memory_wa-objectkey = lf_objectkey.
  da_call_back_memory_wa-program = part_call_back_prog_sales.
  da_call_back_memory_wa-subroutine = part_call_back_form_sales.
  da_call_back_memory_wa-fieldname = space.

  da_call_back_memory_wa-event = part_call_back_event_new.
  APPEND da_call_back_memory_wa TO da_call_back_memory.
  da_call_back_memory_wa-event = part_call_back_event_change.
  APPEND da_call_back_memory_wa TO da_call_back_memory.
  da_call_back_memory_wa-event = part_call_back_event_delete.
  APPEND da_call_back_memory_wa TO da_call_back_memory.

  CALL FUNCTION 'SD_PARTNER_CALL_BACK_SET_EVENT'
    EXPORTING
      fic_objecttype       = lf_partner_objecttype
      fic_objectkey        = lf_objectkey
      fif_program          = part_call_back_prog_sales
      fif_subroutine       = part_call_back_form_sales
*     FIF_EVENT            =
*     FIF_ROLETYPE         =
*     FIF_FIELDNAME        =
    TABLES
      fit_event_table      = da_call_back_memory
    EXCEPTIONS
      parameter_incomplete = 1
      OTHERS               = 2.
  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


* Read defined filters from customizing
  SELECT * FROM tpafilter INTO TABLE lt_filter
  WHERE spras EQ sy-langu.

* Partners are not changeable in display mode
  IF t180-trtyp EQ charh OR
     t180-trtyp EQ charv.
    lf_active = charx.
  ELSE.
    lf_active = space.
  ENDIF.

* Payment Service Provider
  IF cl_ops_switch_check=>sd_sfws_sc4( ) EQ abap_true.
    IF t180-trtyp EQ charv AND
    vbak-sppaym EQ cv_sppaym01 AND
    gr_paysp IS BOUND.
      CALL METHOD gr_paysp->get_change_mode_group
        EXPORTING
          iv_group_id   = cl_sls_paysp_integration=>cv_group_id_party
          iv_trtyp      = t180-trtyp
          is_vbak       = vbak
          is_vbap       = vbap
          is_vbkd       = vbkd
          is_tvak       = tvak
          is_tvap       = tvap
        IMPORTING
          ev_no_changes  = lv_no_changes.
      IF lv_no_changes EQ abap_true.
        lf_active = space.
      ENDIF.
    ENDIF.
  ENDIF.

  da_vbuv = xvbuv.

  CALL FUNCTION 'SD_PARTNER_DATA_PUT'
    EXPORTING
      fic_objecttype      = lf_partner_objecttype
      fic_objectkey       = lf_objectkey
    TABLES
      frt_xvbpa           = xvbpa
      frt_yvbpa           = yvbpa
      frt_xvbuv           = xvbuv
      frt_hvbuv           = yvbuv
      frt_xvbadr          = xvbadr
      frt_yvbadr          = yvbadr
    EXCEPTIONS
      no_object_specified = 1
      OTHERS              = 2.
  IF sy-subrc NE 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.


  IF us_level EQ charh.

    ls_sdorgdata-spart = vbak-spart.

    IF fehler EQ charx.
* incompletion dialog
      CALL FUNCTION 'SD_PARTNER_SUBSCREEN_1000_INIT'
        EXPORTING
          fif_active           = lf_active
          fif_standard         = charx
          fif_telef            = charx
          fif_faxf             = space
          fif_master           = charx
          fif_altern           = charx
          fif_info             = charx
          fif_determ_log       = charx
          fif_incompletion_log = space
          fif_filter_lbox      = charx
          fif_act_filter       = 'PARALL'
          fif_var              = 'VAR_1'
          fif_pos              = posnr_low
          fif_paproc_h         = tvak-pargr
          fif_paproc_i         = space
          fis_vbuv             = da_vbuv
          fic_objecttype       = lf_partner_objecttype
          fic_objectkey        = lf_objectkey
          fis_sdorgdata        = ls_sdorgdata
        TABLES
*         FIT_FUNC             = ' ' "FUNC
          fit_filter           = lt_filter.
    ELSE.
      CALL FUNCTION 'SD_PARTNER_SUBSCREEN_1000_INIT'
        EXPORTING
          fif_active           = lf_active
          fif_standard         = charx
          fif_telef            = charx
          fif_faxf             = space
          fif_master           = charx
          fif_altern           = charx
          fif_info             = charx
          fif_determ_log       = charx
          fif_incompletion_log = space
          fif_filter_lbox      = charx
          fif_act_filter       = 'PARALL'
          fif_var              = 'VAR_1'
          fif_pos              = posnr_low
          fif_paproc_h         = tvak-pargr
          fif_paproc_i         = space
          fic_objecttype       = lf_partner_objecttype
          fic_objectkey        = lf_objectkey
          fis_sdorgdata        = ls_sdorgdata
        TABLES
*         FIT_FUNC             = ' ' "FUNC
          fit_filter           = lt_filter.
    ENDIF.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ELSEIF us_level EQ chari.

    ls_sdorgdata-spart = vbap-spart.

* Bei Product Selection dürfen die Partner auf der Position nicht
* geändert werden (Problem Abgleich HPOS - UPOS)
    IF xvbap-prosa NE space OR
       xvbap-uepvw CA naturalrabatt.
      lf_active = space.
    ENDIF.

    IF fehler EQ charx.
* incompletion dialog
      da_vbuv = xvbuv.
      CALL FUNCTION 'SD_PARTNER_SUBSCREEN_1000_INIT'
        EXPORTING
          fif_active           = lf_active
          fif_standard         = charx
          fif_telef            = charx
          fif_faxf             = space
          fif_master           = charx
          fif_altern           = charx
          fif_info             = charx
          fif_determ_log       = charx
          fif_incompletion_log = space
          fif_filter_lbox      = charx
          fif_act_filter       = 'PARALL'
          fif_var              = 'VAR_1'
          fif_pos              = vbap-posnr
          fif_paproc_h         = tvak-pargr
          fif_paproc_i         = tvap-pargr
          fis_vbuv             = da_vbuv
          fic_objecttype       = lf_partner_objecttype
          fic_objectkey        = lf_objectkey
          fis_sdorgdata        = ls_sdorgdata
        TABLES
*         FIT_FUNC             = ' ' "FUNC
          fit_filter           = lt_filter.
    ELSE.
      CALL FUNCTION 'SD_PARTNER_SUBSCREEN_1000_INIT'
        EXPORTING
          fif_active           = lf_active
          fif_standard         = charx
          fif_telef            = charx
          fif_faxf             = space
          fif_master           = charx
          fif_altern           = charx
          fif_info             = charx
          fif_determ_log       = charx
          fif_incompletion_log = space
          fif_filter_lbox      = charx
          fif_act_filter       = 'PARALL'
          fif_var              = 'VAR_1'
          fif_pos              = vbap-posnr
          fif_paproc_h         = tvak-pargr
          fif_paproc_i         = tvap-pargr
          fic_objecttype       = lf_partner_objecttype
          fic_objectkey        = lf_objectkey
          fis_sdorgdata        = ls_sdorgdata
        TABLES
*         FIT_FUNC             = ' ' "FUNC
          fit_filter           = lt_filter.
    ENDIF.
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

ENDFORM.                               " PARTNER_PREPARE