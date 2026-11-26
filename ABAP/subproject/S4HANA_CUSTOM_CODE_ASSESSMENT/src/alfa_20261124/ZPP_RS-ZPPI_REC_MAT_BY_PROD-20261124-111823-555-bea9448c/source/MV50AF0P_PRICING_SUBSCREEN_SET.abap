*----------------------------------------------------------------------*
*   INCLUDE MV50AF0P_PRICING_SUBSCREEN_SET                             *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  PRICING_SUBSCREEN_SET_HEAD
*&---------------------------------------------------------------------*
form pricing_subscreen_set_head.

  data: lf_display_only type c,
        lf_ctrl_grey    type c,
        ls_xvbuk        like line of xvbuk.

  if likp-kalsp is initial.
    lf_display_only = 'X'.
    lf_ctrl_grey    = 'X'.
  endif.
  if lf_display_only eq space.
    read table xvbuk into ls_xvbuk
                     with key vbeln = likp-vbeln
                     binary search.
    if ls_xvbuk-fkstk ca 'BC'.
      lf_display_only = 'X'.
    endif.
  endif.

* userexit for screen input at pricing screen                  "n_693000
  perform userexit_pricing_screen_input in program sapmv50a
                                        changing lf_display_only.

  call function 'PRICING_SUBSCREEN_SET_DATA'
    exporting
      comm_head_i  = tkomk
      comm_item_i  = tkomp
      display_only = lf_display_only
      trtyp_i      = t180-trtyp
      ctrl_grey    = lf_ctrl_grey
    tables
      tkomv        = tkomv
    exceptions
      error        = 1
      others       = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                               " PRICING_SUBSCREEN_SET_HEAD

*&---------------------------------------------------------------------*
*&      Form  PRICING_SUBSCREEN_SET_ITEM
*&---------------------------------------------------------------------*
form pricing_subscreen_set_item.

  data: lf_display_only type c,
        lf_ctrl_grey    type c,
        ls_xvbuk        like line of xvbuk.

  if tkomp-prsfd is initial.
    lf_display_only = 'X'.
  endif.
  if likp-kalsp is initial.
    lf_display_only = 'X'.
    lf_ctrl_grey    = 'X'.
  endif.
  if lf_display_only eq space.
    read table xvbuk into ls_xvbuk
                     with key vbeln = likp-vbeln
                     binary search.
    if ls_xvbuk-fkstk ca 'BC'.
      lf_display_only = 'X'.
    endif.
  endif.

* userexit for screen input at pricing screen                  "n_693000
  perform userexit_pricing_screen_input in program sapmv50a
                                        changing lf_display_only.


  call function 'PRICING_SUBSCREEN_SET_DATA'
    exporting
      comm_head_i  = tkomk
      comm_item_i  = tkomp
      display_only = lf_display_only
      trtyp_i      = t180-trtyp
      ctrl_grey    = lf_ctrl_grey
    tables
      tkomv        = tkomv
    exceptions
      error        = 1
      others       = 2.
  if sy-subrc <> 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.


endform.                               " PRICING_SUBSCREEN_SET_ITEM