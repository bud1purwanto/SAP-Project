*----------------------------------------------------------------------*
*   INCLUDE MV45AF0W_WE_PRUEFEN                                        *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  WE_PRUEFEN
*&---------------------------------------------------------------------*
* Prüfungen zum Warenempfänger
*----------------------------------------------------------------------*
form we_pruefen using us_dialog
                        changing value(ch_subrc).

  ch_subrc = 0.

* Warenempfänger
  if not kuwev-kunnr is initial.
    vtcomwe-kunnr = kuwev-kunnr.
    vtcomwe-vkorg = vbak-vkorg.
    vtcomwe-vtweg = vbak-vtweg.
    vtcomwe-spart = vbak-spart.
    vtcomwe-ablad = kuwev-ablad.
    vtcomwe-auart = vbak-auart.
    vtcomwe-msgkz = 'U'.
    call function 'VIEW_KUWE2'
      exporting
        comwa   = vtcomwe
      importing
        wewa    = kuwev
      exceptions
        no_kna1 = 1
        no_knvv = 2.

* If exception is caught (Customer does not exist), generate relevant
* error message.
    if sy-subrc = 1.
      message id sy-msgid type sy-msgty number sy-msgno
         with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4
      raising no_kna1 .
    endif.

    if sy-subrc = 2.
      message id sy-msgid type sy-msgty number sy-msgno
        with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 raising no_knvv.
    endif.

    perform kuwev-txtpa_ermitteln.
* Warenempfänger für Aufträge gesperrt ?
    perform tvasp_select using kuwev-kunnr
                               kuwev-aufsd
                               vbak-auart
                               us_dialog
                               ch_subrc.
    check ch_subrc = 0.
* Hinweis auf Liefersperre
    if kuwev-lifsd ne space.
      perform tvlst_select using kuwev-lifsd
                                 space
                                 sy-subrc.
      if us_dialog ne space.
        message w040 with kuwev-kunnr tvlst-vtext.
        message_collect_lord.
      else.
        message i040 with kuwev-kunnr tvlst-vtext.
        message_collect_lord.
      endif.
    endif.
* Partner auf Boykottlisten-Zugehörigkeit pruefen
    if t180-trtyp ne chara.
      perform boykott_kopf using kuagv-kunnr
                                 kuwev-kunnr
                                 kurgv-kunnr
                                 us_dialog
                                 ch_subrc.
      check ch_subrc = 0.
    endif.
  endif.

endform.                    " WE_PRUEFEN