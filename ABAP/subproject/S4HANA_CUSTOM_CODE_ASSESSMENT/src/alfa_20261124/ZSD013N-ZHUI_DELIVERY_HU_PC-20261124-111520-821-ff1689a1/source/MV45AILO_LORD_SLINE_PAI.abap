*&---------------------------------------------------------------------*
*&  Include           MV45AILO_LORD_SLINE_PAI
*&---------------------------------------------------------------------*


*&---------------------------------------------------------------------*
*&      Form  vbep_unterlegen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbep_unterlegen using uv_tabix.

  if fcode eq fcode_xvbap_loeschen.
*   continue, if item is not marked for deleteion
    check rv45a-vbap_selkz ne selektiert.
  endif.
  if fcode eq fcode_xvbep_loeschen.
*   continue, if item is not marked for deleteion
    check rv45a-vbep_selkz ne selektiert.
  endif.

  read table svbep index uv_tabix.
  if sy-subrc ne 0 or
     svbep-tabix = 0.
    svbep-tabix = 0.
  else.
    read table xvbep index svbep-tabix.
    if sy-subrc ne 0.
      message e322(v1) with 'SVBEP'.
    endif.
    if xvbep-updkz eq updkz_delete.
      svbep-tabix = 0.
    endif.
  endif.
* prepare workarea of schedule line
  perform vbep_bearbeiten_vorbereiten(sapfv45e).

endform.                    "vbep_unterlegen


*&---------------------------------------------------------------------*
*&      Form  vbep_fuellen
*&---------------------------------------------------------------------*
form vbep_fuellen.

  if vbap-pstyv ne *vbap-pstyv or
     vbap-bedae ne *vbap-bedae.
    if vbep-ettyp eq *vbep-ettyp.
      clear vbep-ettyp.
    endif.
  endif.

  perform vbep_fuellen(sapfv45e).

endform.                    " vbep_fuellen


*&---------------------------------------------------------------------*
*&      Form  anliefertermin_pruef
*&---------------------------------------------------------------------*
form anliefertermin_pruef.

  data: da_ezeit like vbep-ezeit,
        da_edatu like vbep-edatu.

  if svbep-tabix > 0.
* Beim Anlegen läuft die Routine aus VBEP_FUELLEN.
    perform anliefertermin_pruefen(sapfv45e) using vbep-prgrs
                                                   vbep-edatu
                                                   vbep-ezeit
                                                   vbep-cmeng
                                                   vbep-bmeng
                                                   charx
                                                   da_edatu
                                                   da_ezeit
                                                   sy-subrc.
  endif.
  perform teillieferung_pruefen(sapfv45e).

endform.                    " anliefertermin_pruef


*&---------------------------------------------------------------------*
*&      Form  vbep-wmeng_pruefen
*&---------------------------------------------------------------------*
form vbep-wmeng_pruefen.

  perform vbep-wmeng_pruefen(sapfv45e) using charx
                        changing sy-subrc sy-msgid sy-msgty sy-msgno
                                 sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.

endform.                    "vbep-wmeng_pruefen


*&---------------------------------------------------------------------*
*&      Form  rv45a-etdat_pruefen
*&---------------------------------------------------------------------*
form rv45a-etdat_pruefen.

  if vbep-edatu is initial and
     tvap-eterl ne space.
    set cursor field 'RV45A-ETDAT' line sy-stepl.
    message e394(v1).
  endif.

endform.                    " rv45a-etdat_pruefen


*&---------------------------------------------------------------------*
*&      Form  vbep_edatu_on_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
form vbep_edatu_on_changed.

  vbep-prgrs = char1.

  call function 'PERIOD_AND_DATE_CONVERT_OUTPUT'
    exporting
      internal_date   = vbep-edatu
      internal_period = vbep-prgrs
    importing
      external_date   = rv45a-etdat
      external_period = rv45a-prgbz.

endform.                    "vbep_edatu_on_changed


*&---------------------------------------------------------------------*
*&      Form  sline_delete_by_key
*&---------------------------------------------------------------------*
*       Deletion of single schedule line
*----------------------------------------------------------------------*
form sline_delete_by_key using iv_posnr
                               iv_etenr.

  local: fcode.

  data:
    lt_ivbep   like table of ivbep,

    ls_ivbep   like line of ivbep.

  field-symbols:
    <ls_ivbep> like line of ivbep.

* Store and invalidate the current selections
  lt_ivbep = ivbep[].
  modify ivbep
         from ls_ivbep
         transporting selkz
         where posnr = iv_posnr.

* Mark the schedule line to be deleted
  read table ivbep
       assigning <ls_ivbep>
       with key posnr = iv_posnr
                etenr = iv_etenr.
  check sy-subrc is initial.
  <ls_ivbep>-selkz = 'X'.

  fcode = fcode_xvbep_loeschen.

* Call BE for deletion
  perform xvbep_loeschen_loop(sapfv45e).

* Reset above selections in IVBEP as far as possible (including the
* one that was forced to be deleted)
  loop at lt_ivbep
       into ls_ivbep
       where not selkz is initial.
    read table ivbep
         assigning <ls_ivbep>
         with key posnr = ls_ivbep-posnr
                  etenr = ls_ivbep-etenr.
    check sy-subrc is initial.
*   Reset selection
    <ls_ivbep>-selkz = ls_ivbep-selkz.
  endloop.

endform.                    " sline_delete_by_key