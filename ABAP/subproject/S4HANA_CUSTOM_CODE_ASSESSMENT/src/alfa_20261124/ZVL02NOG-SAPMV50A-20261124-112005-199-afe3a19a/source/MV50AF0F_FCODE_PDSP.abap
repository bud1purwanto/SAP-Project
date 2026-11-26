***INCLUDE MV50AF0F_FCODE_PDSP.
*---------------------------------------------------------------------*
*       FORM FCODE_PDSP.                                             *
*---------------------------------------------------------------------*
*       Display of delivery item output                               *
*---------------------------------------------------------------------*
form fcode_pdsp.

  data: da_vbeln like likp-vbeln,
        da_message_printed(1) type c.

  data: da_xnast like vnast occurs 0 with header line,
        da_ynast like nast occurs 0 with header line,
        da_xvbfa like vbfa occurs 0 with header line.

  data: da_updat.

  data: xxtrtyp         like t185f-trtyp,
        da_subrc        like sy-subrc,
        lv_objtype      like nast-objtype,
        lv_objtype_item like nast-objtype.

* Nachrichtenfindung durchführen
  data: begin of vbkd_key,
          mandt like vbkd-mandt,
          vbeln like vbkd-vbeln,
          posnr like vbkd-posnr,
        end   of vbkd_key.

* get marked lines
  perform xlips_detail_nd(sapfv50p).

* marked item line mandatory
  if lips-posnr is initial.

    message s323.
    leave.

  else.

* Objektkey aufbauen
    move  likp-vbeln to xobjky_pos.
    write lips-posnr to xobjky_pos+10.

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
    if t185f-trtyp ne 'A'.
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

    call function 'RV_MESSAGES_GET'
      exporting
        msg_kappl      = tvlk-kappl
        msg_objky_from = xobjky_pos
      tables
        tab_xnast      = da_xnast
        tab_ynast      = da_ynast.

* prüfen, ob überhaupt relevante Nachrichten zur Druckanzeige da sind
    loop at da_xnast where nacha eq char1.
      exit.
    endloop.
    if sy-subrc eq 0.

* Ausgabe aufrufen
      call function 'RV_MESSAGE_DIALOG'
        exporting
          pi_kappl              = tvlk-kappl
          pi_objky              = xobjky_pos
          pi_kschl              = tvlk-kschl
          pi_data_from_buffer   = charx
        importing
          message_printed       = da_message_printed
        exceptions
          cancel                = 1
          message_not_printable = 2
          no_message            = 2
          print_error           = 3
          others                = 4.

      case sy-subrc.
        when 0.
          if da_message_printed eq charx.
            commit work.
          endif.
          message s084.
          leave.
        when 1.
          leave.
        when 2.
          message s085.
          leave.
        when 3.
          if da_message_printed eq charx.
            commit work.
          endif.
          message s086.
          leave.
        when others.
          leave.
      endcase.

* update marked lines
      perform xlips_detail_back(sapfv50p).
    else.
      message s085.
    endif.
  endif.

endform.                    "fcode_pdsp