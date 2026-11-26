***INCLUDE FV50XF0B_BELEG_NACHRICHTEN_V2 .
*---------------------------------------------------------------------*
*       FORM BELEG_NACHRICHTEN_V2                                     *
*---------------------------------------------------------------------*
*  -->  I_VBELN                                                       *
*---------------------------------------------------------------------*
form beleg_nachrichten_v2 using i_vbeln like likp-vbeln.

  data: temp_vbeln      like likp-vbeln,
        xobjky          like nast-objky,
        xobjky_pos      like nast-objky,
        lv_objtype      like nast-objtype,
        lv_objtype_item like nast-objtype.

  field-symbols: <ls_comm_area> type any.                   "n_1274613

  check xlikp_updkz ne updkz_delete.
  check no_messages_update = space.

  temp_vbeln = i_vbeln.
  if temp_vbeln = space   or
    temp_vbeln(1) = '$'.
    xobjky = temp_vbeln.
  else.
    xobjky = xlikp-vbeln.
  endif.
  "Die folgenden 6 Zeilen wurde eingebaut weil die Bezugsstruktur
  "des folgenden Funktionsbaustein LIKP statt LIKPVB ist und weil
  "RV50A-VTWEG und RV50A-SPART aus der ersten Lieferposition
  "versorgt werden müssen. Diese beiden Felder sollten Kopffelder
  "werden.
  likp = xlikp.                        "oder andere Struktur
  perform tvlk_select(sapmv50a) using likp-lfart
                                      space
                                      sy-subrc.

* Ermitteln des Businessobjekts aus dem Vertriebsbelegtyp
  call function 'SD_OBJECT_TYPE_DETERMINE'
    exporting
      i_document_type        = likp-vbtyp
      i_tvlk                 = tvlk
    importing
      e_business_object      = lv_objtype
      e_business_object_item = lv_objtype_item
    exceptions
      others                 = 0.

* CvB/4.0c (
*  Additionals ("Verkaufshilfsmittel") in Lieferungen, Lieferavisen
*  und Grob-WE's.
*  Aufruf muss vor dem Füllen der Kommunikationsstrukturen erfolgen,
*  weil dort auf globale Additionalstabellen geguckt wird.
  call function 'WTAD_ADDIS_IN_DELIVERIES'
    exporting
      fi_status                     = t180-trtyp
      fi_updkz                      = ylikp_updkz
    tables
      fit_likp                      = xlikp[]
      fit_likp_old                  = ylikp
      fit_lips                      = xlips
      fit_lips_old                  = ylips
      fit_vbuk                      = xvbuk
      fit_vbuk_old                  = yvbuk
      fit_vbup                      = xvbup
      fit_vbup_old                  = yvbup
    exceptions
      addis_not_active              = 1
      addis_irrelevant_for_delivery = 2
      general_error                 = 3
      others                        = 4.
  if sy-subrc <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  endif.
*  CvB/4.0c )

  loop at xlips where vbeln = xlikp-vbeln.
    rv50a-vtweg = xlips-vtweg.
    rv50a-spart = xlips-spart.
    exit.
  endloop.
  vbukkey-mandt = xlikp-mandt.
  vbukkey-vbeln = xlikp-vbeln.
  read table xvbuk with key vbukkey binary search.
  vbuk = xvbuk.
  if likp-vbtyp ca vbtyp_lief.
    assign ('(SAPLV61B)KOMKBE1') to <ls_comm_area>          "v_n_1274613
                                 casting type komkbe1.
    if sy-subrc eq 0.
      clear <ls_comm_area>.
    endif.                                                  "^_n_1274613
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
  endif.
  if likp-vbtyp ca vbtyp_liav.
    assign ('(SAPLV61B)KOMKBV2') to <ls_comm_area>          "v_n_1274613
                                 casting type komkbv2.
    if sy-subrc eq 0.
      clear <ls_comm_area>.
    endif.                                                  "^_n_1274613
    call function 'COMMUNICATION_AREA_KOMKBE1'
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
  endif.
  if likp-vbtyp ca vbtyp_grwe.
    call function 'COMMUNICATION_AREA_KOMKBM1'
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
  endif.
  call function 'MESSAGING'
    exporting
      applikation = tvlk-kappl
      msg_objky   = xobjky
      schema      = tvlk-kalsm
      pi_objtype  = lv_objtype
    tables
      msg_part    = part.
* Nachrichten auf Positionsebene
  if xlikp-vbtyp na vbtyp_mmli.
    loop at xlips where vbeln = xlikp-vbeln
                    and updkz ne updkz_delete.
      lips = xlips.
      perform tvlp_select(sapmv50a) using lips-pstyv sy-subrc.
      check sy-subrc = 0.
      check tvlp-kalsm ne space.
      perform xvbup_lesen(sapfv50p) using lips-vbeln lips-posnr.
      vbup = xvbup.
      if t180-trtyp ne 'H'.
        if xlips-updkz eq updkz_update.
          clear ylips.
          read table ylips with key vbeln = lips-vbeln
                                    posnr = lips-posnr.
          if sy-subrc > 0.
            ylips = xlips.
          endif.
           *lips = ylips.
          clear yvbup.
          read table yvbup with key vbeln = lips-vbeln
                                    posnr = lips-posnr.
          if sy-subrc > 0.
            yvbup = xvbup.
          endif.
           *vbup = yvbup.
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
      endif.
      call function 'COMMUNICATION_AREA_KOMPBV2'
        exporting
          msg_lips = lips
          msg_old  = ' '
          msg_vbup = vbup
        tables
          tab_part = part
          tab_vbpa = xvbpa.
*     Objektkey aufbauen
      move  xobjky     to xobjky_pos.
      write lips-posnr to xobjky_pos+10.
*     Nachrichtenfindung durchführen
      call function 'MESSAGING'
        exporting
          applikation = tvlk-kappl
          msg_objky   = xobjky_pos
          schema      = tvlp-kalsm
          pi_objtype  = lv_objtype_item
          pi_item     = charx
        tables
          msg_part    = part.

      call function 'RV_MESSAGES_MAIL_REPLACE'              "v_n_601864
           exporting
                msg_kappl = tvlk-kappl
                msg_objky = xobjky_pos
           exceptions
                no_mail_message_found = 01.                 "^_n_601864

    endloop.
  endif.

endform.                    "BELEG_NACHRICHTEN_V2