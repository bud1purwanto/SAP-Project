*----------------------------------------------------------------------*
*   INCLUDE MV45AF0P_SUB_PROCESS                                       *
*----------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  SUB_PROCESS
*&---------------------------------------------------------------------*
*       Eingabedaten des Partner-Subscreens werden verarbeitet
*----------------------------------------------------------------------*
  form sub_process using us_level.

    data: lf_objectkey type swo_typeid,
          lf_objecttype type nast-objtype,
          lf_objecttype_item type nast-objtype,
          lf_partner_objecttype type swo_objtyp,
          lf_partner_objecttype_item type swo_objtyp,
          lf_partner_changed type xfeld,
          lvf_action_done type c.

    call function 'SD_OBJECT_TYPE_DETERMINE'
      exporting
        i_document_type        = vbak-vbtyp
        i_tvak                 = tvak
      importing
        e_business_object      = lf_objecttype
        e_business_object_item = lf_objecttype_item.

    lf_partner_objecttype = lf_objecttype.
    lf_objectkey = vbak-vbeln.

    if us_level eq charh.
      call function 'SD_PARTNER_DATA_GET'
        exporting
          fic_objecttype      = lf_partner_objecttype
          fic_objectkey       = lf_objectkey
          fic_xvbuv_merged    = 'X'
          fic_hvbuv_merged    = 'X'
           IMPORTING
                FEV_ACTION_DONE     = LVF_ACTION_DONE
        tables
          fet_xvbpa           = xvbpa
          fet_yvbpa           = yvbpa
          fet_xvbuv           = xvbuv
          fet_hvbuv           = yvbuv
          fet_xvbadr          = xvbadr
          fet_yvbadr          = yvbadr
        exceptions
          no_object_specified = 1
          no_object_found     = 2
          merge_failed        = 3
          others              = 4.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

      if   not yvbpa[]  is initial or
           not yvbadr[] is initial or
           not yvbuv[]  is initial or
           lvf_action_done ca 'IUD'.
        lf_partner_changed = charx.
      else.
        lf_partner_changed = space.
      endif.

      if r185d-dataloss is initial and
         lf_partner_changed = charx.
        r185d-dataloss = charx.
      endif.

      if mv45a_dataloss_par_sub ne space and r185d-dataloss eq space.
        r185d-dataloss = mv45a_dataloss_par_sub.
      endif.

      perform vbak_partner_aendern(sapfv45k) using lf_partner_changed.

    elseif us_level eq chari.
      call function 'SD_PARTNER_DATA_GET'
        exporting
          fic_objecttype      = lf_partner_objecttype
          fic_objectkey       = lf_objectkey
          fic_xvbuv_merged    = 'X'
          fic_hvbuv_merged    = 'X'
        tables
          fet_xvbpa           = xvbpa
          fet_yvbpa           = yvbpa
          fet_xvbuv           = xvbuv
          fet_hvbuv           = yvbuv
          fet_xvbadr          = xvbadr
          fet_yvbadr          = yvbadr
        exceptions
          no_object_specified = 1
          no_object_found     = 2
          merge_failed        = 3
          others              = 4.
      if sy-subrc <> 0.
        message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      endif.

      if r185d-dataloss is initial.
        if not yvbpa[]  is initial or
           not yvbadr[] is initial or
           not yvbuv[]  is initial.
          r185d-dataloss = charx.
        endif.
      endif.

      if mv45a_dataloss_par_sub ne space and r185d-dataloss eq space.
        r185d-dataloss = mv45a_dataloss_par_sub.
      endif.

      perform vbap_partner_aendern(sapfv45p) using space.
      if rv02p-sbupd ne space or fcode eq 'PORE'.
        perform vbap_bearbeiten_vorbereiten(sapfv45p).
        perform sb_pruefen_position(sapfv45v) using xvbap-vbeln
                                                    xvbap-posnr.
      endif.

    endif.

    call function 'FT_SLS_PARTNER_ADDR_MEM_FILL'
      tables
        i_t_vbpavb_partner_new = xvbpa
        i_t_vbpavb_partner_old = yvbpa
        i_t_sadrvb_address_new = xvbadr
        i_t_sadrvb_address_old = yvbadr.

    clear: rv02p-weupd, rv02p-rgupd, rv02p-sbupd.

  endform.                             " SUB_PROCESS