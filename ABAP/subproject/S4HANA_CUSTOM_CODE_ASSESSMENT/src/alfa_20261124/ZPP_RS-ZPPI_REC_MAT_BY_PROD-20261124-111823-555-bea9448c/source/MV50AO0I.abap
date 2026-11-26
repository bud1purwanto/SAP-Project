
************************************************************************
*                                                                      *
* PBO Module zur Ablaufsteuerung - Versand                             *
*     Module alphabetisch geordnet; hier beginnend mit "I"             *
*                                                                      *
************************************************************************

*---------------------------------------------------------------------*
*       MODULE INITIALISIEREN OUTPUT                                  *
*---------------------------------------------------------------------*
module initialisieren output.

  if t180-bldgr eq gc_new_dialog_outb
     or t180-bldgr eq gc_new_dialog_inb.
    perform taxi_read_location.
  endif.
  perform cua_setzen.
  perform cursor_setzen.
  clear gf_fcode_processing_active.                         "n_608056

endmodule.                    "INITIALISIEREN OUTPUT
*eject

module initialisieren_chsp output.

  data: da_chsp_fcode like fcode.

  if save_cua_exclude[] is initial.
    save_cua_exclude[] = cua_exclude[].
  endif.
  do 99 times varying da_chsp_fcode from cua_exclu_chsp-f01
                               next cua_exclu_chsp-f02.
    if da_chsp_fcode(4) = '9999'.
      exit.
    endif.
    perform cua_fcode_allow using da_chsp_fcode no.
  enddo.
  if xvbup-lvsta = charb or xvbup-koqua = charb.
    perform cua_fcode_allow using 'CHSL' no.
    perform cua_fcode_allow using 'CHFD' no.
    perform cua_fcode_allow using 'CHKO' no.
    perform cua_fcode_allow using 'POLO' no.
  endif.

endmodule.                    "INITIALISIEREN_CHSP OUTPUT
*eject
*&---------------------------------------------------------------------*
*&      Module  INITIALISIEREN_POD  OUTPUT
*&---------------------------------------------------------------------*
*       POD Daten initialisieren
*----------------------------------------------------------------------*
module initialisieren_pod output.

  clear: gf_anz_pod, gf_lines_pod, gt_check_pod.
  refresh: gt_check_pod.

endmodule.                             " INITIALISIEREN_POD  OUTPUT

*&---------------------------------------------------------------------*
*&      Module  INIT_NEWD  OUTPUT
*&---------------------------------------------------------------------*
module init_newd output.

  set pf-status 'NEWD'.
  set titlebar 'NEWD'.

endmodule.                             " INIT_NEWD  OUTPUT
*&---------------------------------------------------------------------*
*&      Module  inbound_default_values  OUTPUT
*&---------------------------------------------------------------------*
module inbound_default_values output.

  likp-mandt = sy-mandt.
  rv50a-lfdat_la = sy-datlo.

endmodule.                 " inbound_default_values  OUTPUT