*----------------------------------------------------------------------*
*   INCLUDE MV50AF0C_CUA_FCODE_HEAD                                    *
*----------------------------------------------------------------------*
form cua_fcode_head.

* Default: all header function codes are active
  perform cua_fcode_allow using 'HDET_T' yes.
  perform cua_fcode_allow using 'HABW_T' yes.
  perform cua_fcode_allow using 'HPIC_T' yes.
  perform cua_fcode_allow using 'HLOA_T' yes.
  perform cua_fcode_allow using 'HTRA_T' yes.
  perform cua_fcode_allow using 'HFOR_T' yes.
  perform cua_fcode_allow using 'HFIN_T' yes.
  perform cua_fcode_allow using 'HADM_T' yes.
  perform cua_fcode_allow using 'HPAR_T' yes.
  perform cua_fcode_allow using 'HTEX_T' yes.
  perform cua_fcode_allow using 'HKON_T' yes.
  perform cua_fcode_allow using 'HTER_T' yes.               "v_n_574849
  if v50agl-display_from_archive eq space.
    perform cua_fcode_allow using 'VXSI_T' yes.
  else.
    perform cua_fcode_allow using 'VXSI_T' no.
  endif.                                                    "^_n_574894

* Deactivate function on current tabstrip
  check taxi_screen_group(1) eq c_taxi_scrgrp_head(1).
  perform cua_fcode_allow using 'HDET_T' no.
  case taxi_panel.
    when 'HABW'.
      perform cua_fcode_allow using 'HABW_T' no.
    when 'HPIC'.
      perform cua_fcode_allow using 'HPIC_T' no.
    when 'HLOA'.
      perform cua_fcode_allow using 'HLOA_T' no.
    when 'HTRA'.
      perform cua_fcode_allow using 'HTRA_T' no.
    when 'HFOR'.
      perform cua_fcode_allow using 'HFOR_T' no.
    when 'HFIN'.
      perform cua_fcode_allow using 'HFIN_T' no.
    when 'HADM'.
      perform cua_fcode_allow using 'HADM_T' no.
    when 'HPAR'.
      perform cua_fcode_allow using 'HPAR_T' no.
    when 'HTEX'.
      perform cua_fcode_allow using 'HTEX_T' no.
    when 'HKON'.
      perform cua_fcode_allow using 'HKON_T' no.
    when 'HTER'.                                            "n_574894
      perform cua_fcode_allow using 'HTER_T' no.
    when 'VXSI'.
      perform cua_fcode_allow using 'VXSI_T' no.
  endcase.

endform.