*&---------------------------------------------------------------------*
*&  Include           MV50AF0C_CUA_FCODE_TCODE (HP_378423)             *
*&---------------------------------------------------------------------*

form cua_fcode_tcode.

  data: lf_subrc like sy-subrc.

* New delivery dialogue
  if    t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.

    perform check_tcode_authorization using 'VL01N'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'CRMA_T' no.
    endif.

    perform check_tcode_authorization using 'VL01NO'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'CROA_T' no.
    endif.

    perform check_tcode_authorization using 'VL02N'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL02_T' no.
    endif.

    perform check_tcode_authorization using 'VL03N'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL03_T' no.
    endif.

    perform check_tcode_authorization using 'VL31N'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL31_T' no.
    endif.

    perform check_tcode_authorization using 'VL32N'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL32_T' no.
    endif.

    perform check_tcode_authorization using 'VL33N'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL33_T' no.
    endif.

    perform check_tcode_authorization using 'VL10'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL04_T' no.
    endif.

    perform check_tcode_authorization using 'VL06O'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL06_T' no.
    endif.

    perform check_tcode_authorization using 'VL06I'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL06I_T' no.
    endif.

    perform check_tcode_authorization using 'VL70'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL70_T' no.
    endif.

    perform check_tcode_authorization using 'VL71'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL71_T' no.
    endif.

    perform check_tcode_authorization using 'VL72'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL72_T' no.
    endif.

    perform check_tcode_authorization using 'VL75'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL75_T' no.
    endif.

    perform check_tcode_authorization using 'LT03'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'FT41_T' no.
    endif.

    perform check_tcode_authorization using 'VL22N'           "n_1426712
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'IAEN_T' no.
    endif.

* Old delivery dialogue
  else.
    perform check_tcode_authorization using 'VL01'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL01' no.
    endif.

    perform check_tcode_authorization using 'VL02'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL02' no.
    endif.

    perform check_tcode_authorization using 'VL03'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL03' no.
    endif.

    perform check_tcode_authorization using 'VL04'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL04' no.
    endif.

    perform check_tcode_authorization using 'VL70'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL70' no.
    endif.

    perform check_tcode_authorization using 'VL71'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL71' no.
    endif.

    perform check_tcode_authorization using 'LT03'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'FT41' no.
    endif.

    perform check_tcode_authorization using 'VL06O'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'VL06' no.
    endif.

    perform check_tcode_authorization using 'VL22'
                                      changing lf_subrc.
    if lf_subrc ne 0.
      perform cua_fcode_allow using 'IAEN' no.
    endif.

  endif.

endform.                    "cua_fcode_tcode