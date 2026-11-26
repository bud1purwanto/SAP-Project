*----------------------------------------------------------------------*
*   INCLUDE MV50AF0T_TEXT_ITEM_SET_DATA                                *
*----------------------------------------------------------------------*
form text_item_set_data.

  data: lf_display_flag type c.
  data: lf_language like sy-langu.                            "HP_212368

  clear tvcom.

* Do not start text processing if no text procedure is maintained
  if tvlp-txtgr is initial.                                 "HP_380503
    message s345.
    gf_text_program = 'SAPMV50A'.
    gf_text_screen  = '2900'.
    exit.
  endif.

* number of document = delivery number
  move-corresponding likp to tvcom.
  move-corresponding lips to tvcom.

  tvcom-ernamv = lips-ernam.

  if lips-vgtyp ca vbtyp_auft                "HP_327568     "v_n_1304158
     or lips-vgtyp eq vbtyp_bestell.                        "^_n_1304158
    tvcom-vbelv = lips-vgbel.
    tvcom-posnv = lips-vgpos.                               "HP_331594
  endif.

  tvcom-vbeln = likp-vbeln.
  tvcom-posnn = lips-posnr.
  tvcom-txtgn = tvlp-txtgr.
  tvcom-vkorg = likp-vkorg.
  tvcom-sd_caller = 'L'.                                      "HP_212368

* In case of inbound deliveries the language can not be determined from
* the ship-to party or the sales organisation. Take system language as
* default in this case.
  if likp-vbtyp ca vbtyp_mmli.                                "HP_212368
    lf_language = sy-langu.
  else.
    clear lf_language.
  endif.


* Set flag for only displaying the text or changing it
  if t180-trtyp = 'A' or vbuk-wbstk eq charc.   "n_1565880
    lf_display_flag = 'X'.
  else.
    lf_display_flag = ' '.
  endif.

* Userexit                                    "v_n_1657178
  PERFORM userexit_text_input_change(SAPMV50A)
        CHANGING lf_display_flag.             "^_n_1657178

* Avoid multiple processing of internal fcodes of the text processing
  if sy-ucomm(3) eq 'TP_'.                                  "HP_319745
    clear sy-ucomm.
  endif.

  call function 'SD_WORD_PROCESSING_PUT'
       exporting
           fi_application_data  = tvcom
           fi_display_flag      = lf_display_flag
           fi_display_language  = '*'
           fi_group             = tvlp-txtgr
*         FI_INCOMPLETE_FLAG   = ' '
           fi_new_text_language = lf_language                 "HP_212368
           fi_object            = 'VBBP'
*         FI_RESET_FLAG        = ' '
*          fi_appl_object_ident = tp_ident
*          fi_appl_object_descr = tp_descr
           fi_default_fcode     = 'ENT1'
           fi_subscreen_number  = '2100'
*          fit_excl_fcode       = i_lv70t_ty_excl_table
           fit_xvbpa            = xvbpa[]
       changing
           fct_xthead           = xthead[]
           fct_xvbuv            = xvbuv[]
       exceptions
           error_occured        = 1
           others               = 2
              .
  if sy-subrc ne 0.                                         "HP_380503
    message id sy-msgid type 'S'     number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    gf_text_program = 'SAPMV50A'.
    gf_text_screen  = '2900'.
  else.
    gf_text_program = 'SAPLV70T'.
    gf_text_screen  = '2100'.
  endif.


endform.