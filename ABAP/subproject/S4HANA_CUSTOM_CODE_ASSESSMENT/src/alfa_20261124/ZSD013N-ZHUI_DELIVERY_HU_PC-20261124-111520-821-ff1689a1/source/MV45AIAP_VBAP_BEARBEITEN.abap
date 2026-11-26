*---------------------------------------------------------------------*
*       MODULE VBAP_BEARBEITEN                                        *
*---------------------------------------------------------------------*
*       Bearbeiten der Auftragsposition                               *
*---------------------------------------------------------------------*
module vbap_bearbeiten.

* Verarbeitung nicht durchlaufen bei entsprechendem Fcode
  perform ende_ohne_pruefung using space
                             changing leave_without_check.
  check leave_without_check is initial.

  perform vbap_gewicht_volumen_setzen(sapfv45p).

  data: da_new_line_item.
  if svbap-tabix = 0.
    da_new_line_item = charx.
  else.
    da_new_line_item = space.
  endif.

* Do not consider the multiple route change for delivery groups
  if vbap-route  = *vbap-route  and
     yvbap-posnr = *vbap-posnr  and
     yvbap-route is not initial and
   ( vbap-grkor is not initial or
     vbak-autlf is not initial ) and
     sy-dynnr = '4921'.
    IF VBAP-VBELN IS NOT INITIAL AND
       VBAP-VBELN = YVBAP-VBELN.
      *VBAP-ROUTE = YVBAP-ROUTE.
    ENDIF.
  endif.

  if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.
    gv_msr_like_error = charx.
    if ( t185v-panel eq 'UMSR' or
         t185v-panel eq 'PMSR' ) and
       ( vbap-uepos is initial or
         vbap-stlnr is initial ).
      gv_msr_error = charx.
      "perform msr_check_item using charx space.
      perform msr_check_item using charx charx.  "only info allowed
    else.
      perform msr_check_item using space charx.  "only info allowed
    endif.
  endif.

  perform vbap_bearbeiten(sapfv45p).

  if cl_ops_switch_check=>ops_sfws_sc_advret1( ) eq charx.
    clear gv_msr_error.
  endif.

ENHANCEMENT-POINT VBAP_BEARBEITEN_10 SPOTS ES_SAPMV45A.
  if da_new_line_item = charx.
    item_detail_tabix = svbap-tabix.
  endif.

endmodule.                    "VBAP_BEARBEITEN