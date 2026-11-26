*&---------------------------------------------------------------------*
*&      Form  AG_GRUKO_AUF_HINWEIS_PRUEFEN
*&---------------------------------------------------------------------*
*       Es wird geprüft, ob bereits Gruppenkontrakte zum Auftraggeber
*       vorhanden sind. Liegt mindestens ein Verkaufsbeleg vor,
*       wird ein Hinweis darüber angezeigt.
*----------------------------------------------------------------------*
form ag_gruko_auf_hinweis_pruefen.

  data: da_gruko_header_exist(1)  type c value space,
        da_trvog                  like tvak-trvog,
        da_answer                 type c,
        da_vbeln                  like vbak-vbeln.
  data: da_bapiflag(1) type c,
        da_nodialog(1) type c.

  LOCAL: VAKPA_REF.

* call the dialogue flag
  if call_bapi = charx.
     call function 'DIALOG_GET_STATUS'
          importing
             dialog_status = da_bapiflag.
  endif.
  if call_function = charx.
     if call_bapi = charx.
        if da_bapiflag = charx.
           da_nodialog = charx.
        else.
           da_nodialog = space.
        endif.
     else.
        da_nodialog = charx.
     endif.
  endif.

  CHECK SY-BATCH EQ SPACE AND
        ( SY-BINPT EQ SPACE OR NOT CATTAKTIV IS INITIAL ) AND
        da_nodialog EQ SPACE.

* no messages about quotations and contracts if Lean Order Processing
  check call_activity ne gc_activity_lord.

* Hinweis darf nur einmal und nur beim Anlegen der VBAK erfolgen
  check vbak-vbtyp ne vbtyp_gruko and
        vbak-vbtyp eq vbtyp_kont and
        t180-trtyp eq charh.
  check hinweis_grp_show is initial.
  hinweis_grp_show = nein.

* Nachlesen ob Gruppenkontraktnummer schon eingegeben wurde
  if vbak-vbeln_grp is initial.
    perform dynp_values_read(sapmv45a) using 'SAPMV45A'
                                             taxi_body_subscreen
                                             'VBAK-VBELN_GRP'
                                    changing vbak-vbeln_grp
                                             sy-subrc.
  endif.

* Nur prüfen wenn Referenz nicht schon eingetragen wurde
  check: vbak-vbeln_grp is initial.

  refresh hnw_vbak.
  clear hnw_vbak.

* Gruppenkontrakte zum Auftraggeber lesen
  check tvak-hnwgk ca 'ABC'.

  perform vakpa_gruko_select using vbtyp_gruko
                                   kuagv-kunnr
                                   'AG'" Partnerrolle = AG
                                   vbak-vkorg
                                   '4' " TRVOG = Kontrakt
                                   vbak-vtweg
                                   vbak-spart
                                   kuagv-kunnr
                                   da_gruko_header_exist.

* Hinweis anzeigen wenn mind. ein Gruppenkontrakt existiert
  if da_gruko_header_exist ne space.
    if tvak-hnwgk ca 'BC'.
*     Direkt auf Liste verzweigen
      da_answer = '2'.
    else.
      call function 'POPUP_TO_DECIDE_WITH_MESSAGE'
        exporting
          defaultoption = '1'
          diagnosetext1 = text-210
          diagnosetext2 = kuagv-kunnr
          diagnosetext3 = text-230
          textline1     = ' '
          text_option1  = text-212
          text_option2  = text-213
          titel         = text-231
        importing
          answer        = da_answer.
    endif.

*   Liste gefundener Gruppenkontrakte anzeigen
    if da_answer = '2'.
      describe table hnw_vbak lines sy-tfill.
      if sy-tfill = 1 and tvak-hnwgk ca 'B'.
*       Bei Eindeutigkeit direkt übernehmen
        vbak-vbeln_grp = hnw_vbak-vbeln.
      else.
        call function 'SD_LIST_REFERENCE_DOCUMENT'
          exporting
            kopf_ebene = 'C'
            i_kunnr    = kuagv-kunnr
          importing
            e_vbeln    = da_vbeln
            e_trvog    = da_trvog
          tables
            list_vapma = hnw_vbap
            list_vakpa = hnw_vbak.

*       Gruppenkontraktnummer in Beleg übernehmen
        if not da_vbeln is initial.
          vbak-vbeln_grp = da_vbeln.
        endif.
      endif.
    endif.
  endif.

endform.                    "AG_GRUKO_AUF_HINWEIS_PRUEFEN