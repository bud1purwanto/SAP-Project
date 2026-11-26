***INCLUDE MV50AF0F_FCODE_PDOK .
*---------------------------------------------------------------------*
*       FORM FCODE_PDOK                                               *
*---------------------------------------------------------------------*
*       Aufruf des Dialogbausteins zur Nachrichtenbearbeitung auf     *
*       Positionsebene                                                *
*---------------------------------------------------------------------*

form fcode_pdok using h185f structure t185f
                      h185  structure t185
                      h185v structure t185v.

  data: da_updat,
        lv_objtype      like nast-objtype,
        lf_subrc        like sy-subrc,
        lv_objtype_item like nast-objtype.

* New dialog: if output maintenance is called from the batch
* split screen the marked item has to be moved to the workarea:
  if taxi_screen_group(1) eq c_taxi_scrgrp_item(1) and      "470
     taxi_panel           eq gc_panel_chsp         and
     v50agl-chargensplitbild eq charx.
    perform read_first_marked_item(sapfv50p) tables gt_wlips_chsp
                                             using  space
                                             changing lf_subrc.
    if lf_subrc ne 0.               "Exit if no item marked
      h185f-fcode = 'BACK_T'.
      exit.
    endif.

*   Fill tables and workareas with well-defined values
    gt_ilips_chsp[] = ilips[].
    gs_ilips_chsp = ilips.
    gs_xlips_chsp = xlips.
    gs_lips_chsp  = lips.
    gf_loopc_chsp = ilips_loopc.
    gf_tabix_zeile_1_chsp = ilips_tabix_zeile_1.
  endif.

* Objektkey aufbauen
  move  likp-vbeln to xobjky_pos.
  write lips-posnr to xobjky_pos+10.
* Bildtext für Dialogbaustein aufbauen
  bildtext    = rv50a-txt_vbeln.
  bildtext+21 = likp-vbeln.
  write text-063 to bildtext+40(20).
  write lips-posnr to bildtext+61(06).
* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
  call function 'SD_OBJECT_TYPE_DETERMINE'
    exporting
      i_document_type        = likp-vbtyp
    importing
      e_business_object      = lv_objtype
      e_business_object_item = lv_objtype_item
    exceptions
      others                 = 0.
* Kommunikationsblock Kopf aufbauen
  perform xvbuk_pflegen in program sapfv50k.
  vbuk = xvbuk.
* Füllt aktuelle Workarea KOMKBV2
  call function 'COMMUNICATION_AREA_KOMKBV2'
    exporting
      msg_likp  = likp
      msg_old   = ' '
      msg_rv50a = rv50a
      msg_vbuk  = vbuk
      msg_trtyp = t180-trtyp
    tables
      tab_part  = part
      tab_lips  = xlips
      tab_vbpa  = xvbpa.
* Nachrichtenfindung durchführen
  if t180-trtyp ne 'A'.
    perform xvbup_lesen(sapfv50p) using likp-vbeln
                                        lips-posnr.
    vbup = xvbup.
* Kommunikationsblock Position aufbauen
    call function 'COMMUNICATION_AREA_KOMPBV2'
      exporting
        msg_lips = lips
        msg_vbup = vbup
      tables
        tab_vbpa = xvbpa
        tab_part = part.
* Kommunikationsblock alt aufbauen
    if t180-trtyp ne 'H'.
      if xlips-updkz eq updkz_update.
        clear ylips.
        read table ylips with key vbeln = lips-vbeln
                                  posnr = lips-posnr.
        if sy-subrc > 0.
           *lips = xlips.
        else.
           *lips = ylips.
        endif.
        clear yvbup.
        read table yvbup with key vbeln = lips-vbeln
                                  posnr = lips-posnr.
        if sy-subrc > 0.
           *vbup = xvbup.
        else.
           *vbup = yvbup.
        endif.
        call function 'COMMUNICATION_AREA_KOMPBV2'
          exporting
            msg_lips = *lips
            msg_old  = 'X'
            msg_vbup = *vbup
          tables
            tab_part = part
            tab_vbpa = xvbpa.
      else.
        call function 'COMMUNICATION_AREA_KOMPBV2'
          exporting
            msg_lips = lips
            msg_old  = 'X'
            msg_vbup = vbup
          tables
            tab_part = part
            tab_vbpa = xvbpa.
      endif.
    else.
      call function 'COMMUNICATION_AREA_KOMPBV2'
        exporting
          msg_lips = lips
          msg_old  = 'X'
          msg_vbup = vbup
        tables
          tab_part = part
          tab_vbpa = xvbpa.
    endif.
    call function 'COMMUNICATION_AREA_KOMPBV2'
      exporting
        msg_lips = lips
        msg_old  = ' '
        msg_vbup = vbup
      tables
        tab_part = part
        tab_vbpa = xvbpa.
* Nachrichtenfindung durchführen
    call function 'MESSAGING'
      exporting
        applikation = tvlk-kappl
        msg_objky   = xobjky_pos
        schema      = tvlp-kalsm
        pi_objtype  = lv_objtype_item
        pi_item     = charx
      tables
        msg_part    = part.
  endif.
* Dialogbaustein zur Nachrichtenbearbeitung aufrufen.
  t185f = h185f.
  t185  = h185.
  t185v = h185v.
  call function 'RV_MESSAGES_MAINTENANCE'
    exporting
      min_t185     = t185
      min_t185f    = t185f
      min_t185v    = t185v
      min_objky    = xobjky_pos
      min_kappl    = tvlk-kappl
      min_kalsm    = tvlp-kalsm
      min_btext    = bildtext
      min_cua_text = tvlkt-vtext
      pi_objtype   = lv_objtype_item
    importing
      mex_fcode    = fcode
      mex_t185f    = t185f
      mex_t185v    = t185v
      mex_updat    = da_updat
    tables
      mtb_part     = part.
  if da_updat ne space.
    r185d-dataloss = charx.
  endif.
  perform transform_fcode changing t185f-fcode.             "46A BEY
  perform transform_fcode changing fcode.
  h185f = t185f.
  h185v = t185v.

* New dialogue: Preprare return to batch split screen
  if taxi_screen_group(1) eq c_taxi_scrgrp_item(1) and      "470
     taxi_panel           eq gc_panel_chsp         and
     v50agl-chargensplitbild eq charx.
    perform xlips_c0_to_i0_chsp(sapfv50p).
  endif.

endform.                    "FCODE_PDOK