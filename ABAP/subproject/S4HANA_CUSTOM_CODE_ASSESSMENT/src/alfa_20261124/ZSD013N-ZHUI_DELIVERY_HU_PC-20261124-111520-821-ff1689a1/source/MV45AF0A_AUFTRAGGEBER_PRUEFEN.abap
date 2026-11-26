*---------------------------------------------------------------------*
*       FORM AUFTRAGGEBER_PRUEFEN                                     *
*---------------------------------------------------------------------*
*       Der eingegeben Auftraggeber wird geprüft.                     *
*       Die Partner des Auftraggebers werden vorgeschlagen.           *
*       Der Auftragskopf und die kaufmännischen Daten werden          *
*       gefüllt.                                                      *
*---------------------------------------------------------------------*
form auftraggeber_pruefen.

  check fcode ne fcode_abbrechen.      "Für Kopieren ohne Kunde

* Auftraggeber anlegen
  perform auftraggeber_anlegen.

* Zur Prüfung, welche Partnerrolle geändert wurde bei Ändern
* Auftraggeber
  data: begin of da_xvbpa occurs 0.
          include structure vbpavb.
  data: end of da_xvbpa.

  DATA: DA_VBPA LIKE VBPAVB.

  if call_function ne space and
     call_activity ne gc_activity_lord and
     call_activity ne gc_activity_latp.
* Bei Call-Function ist XVBPA schon gefüllt.
    perform kuagv_select_xvbpa.
  endif.
* Nach einem Reset der Auftraggebernummer sitzt der NAME1 noch
  if kuagv-name1 ne space and
     kuagv-kunnr is initial.
    kuagv-name1 = space.
    kuagv-ort01 = space.
  endif.

  if not rv02p-agupd is initial or
     vbak-kunnr is initial.
* Damit der Auftraggeber geändert werden
* kann, ohne daß die Partner dann doppelt in XVBPA stehen
    da_xvbpa[] = xvbpa[].
    if call_function = space or
       call_activity eq gc_activity_lord or
       call_activity eq gc_activity_latp.
      perform xvbpa_vorbereiten(sapfv45k).
    endif.
* Auftraggeber lesen - Parameter für Zusatzanzeigen in anderen Windows
    set parameter id 'VAG' field kuagv-kunnr.
    set parameter id 'KUN' field kuagv-kunnr.
    if call_function = space or
       call_activity eq gc_activity_lord or
       call_activity eq gc_activity_latp.
* Auftraggeber lesen und Partner vorschlagen
      perform kuagv_select using kuagv-kunnr kuwev-kunnr.
    endif.
    if not kuagv-kunnr is initial.
* Warenempfänger lesen
      clear vtcomwe.
      perform kuwev_select_xvbpa.
* Regulierer lesen
      clear vtcomrg.
      perform kurgv_select_xvbpa.
* Produktvorschlag zum Auftraggeber ermitteln
      perform produktvorschlag_ermitteln(sapfv45k).
* Cross-Selling Profil ermitteln
      perform cross_sell_ermitteln.
    endif.
  endif.
  if svbak-tabix = 0 or
    not rv02p-agupd is initial.
    perform partner_pruefen using charx
                                  sy-subrc.
  endif.

* When changing Ship-to and Sold-to at the same time set relevant flags
  if ( ( not rv02p-agupd is initial ) and
       ( not rv02p-weupd is initial ) ).
    if not da_xvbpa[] is initial.
      loop at da_xvbpa.
      if da_xvbpa-parvw = 'RG' and
        ( da_xvbpa-kunnr ne kurgv-kunnr or
          da_xvbpa-kunnr ne kuwev-kunnr ).
         rv02p-rgupd = charx.
        endif.
      endloop.
    else.
      loop at xvbpa into da_vbpa.
        if da_vbpa-parvw = 'RG' and
          ( da_vbpa-kunnr ne kurgv-kunnr or
            da_vbpa-kunnr ne kuwev-kunnr ).
          rv02p-rgupd = charx.
        endif.
      endloop.
    endif.
    rv02p-sbupd = charx.
  else.
* When changing the Sold-to set relevant change flags
    if not rv02p-agupd is initial.
      clear: rv02p-weupd, rv02p-rgupd.
      loop at da_xvbpa.
        if da_xvbpa-parvw = 'WE' and
           ( da_xvbpa-kunnr ne kuwev-kunnr ).
          rv02p-weupd = charx.
        endif.
        if da_xvbpa-parvw = 'RG' and
        ( da_xvbpa-kunnr ne kurgv-kunnr or
          da_xvbpa-kunnr ne kuwev-kunnr ).
          rv02p-rgupd = charx.
        endif.
      endloop.
      rv02p-sbupd = charx.
    endif.
  endif.

endform.                    "AUFTRAGGEBER_PRUEFEN