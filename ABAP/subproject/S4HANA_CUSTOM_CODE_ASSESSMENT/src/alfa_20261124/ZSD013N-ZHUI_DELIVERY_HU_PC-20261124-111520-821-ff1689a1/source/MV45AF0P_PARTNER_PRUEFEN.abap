*eject
*----------------------------------------------------------------------*
*          FORM PARTNER_PRUEFEN                                        *
*----------------------------------------------------------------------*
* Die festen Partnerrollen des Belegkopfes: Auftraggeber,              *
* Warenempfänger und Regulierer werden geprüft.                        *
* Input: KUAGV, KUWEV, KURGV.                                          *
*----------------------------------------------------------------------*
form partner_pruefen using us_dialog
                           changing value(ch_subrc).

  ch_subrc = 0.

* Auftraggeber
  if not rv02p-agupd is initial.
    read table xvbpa with key parvw = parvw_ag.
  endif.
  if rv02p-agupd is initial or
     ( not rv02p-agupd is initial and
       sy-subrc ne 0 ).
    perform ag_pruefen using us_dialog
                       changing ch_subrc.
    if us_dialog is initial and
       not ch_subrc is initial.
      exit.
    endif.
  endif.
* Hinweis auf Liefersperre
  if not kuagv-kunnr is initial and
     not kuagv-kunnr(1) = '?'.
    if kuwev-lifsd ne kuagv-lifsd and
       kuagv-lifsd ne space.
      perform tvlst_select using kuagv-lifsd
                                 space
                                 sy-subrc.
      if us_dialog ne space.
        message w040 with kuagv-kunnr tvlst-vtext.
        message_collect_lord.
      else.
        message i040 with kuagv-kunnr tvlst-vtext.
        message_collect_lord.
      endif.
    endif.
  endif.

* Warenempfänger
  if rv02p-weupd is initial.
    perform we_pruefen using us_dialog
                       changing ch_subrc.
    if us_dialog is initial and
       not ch_subrc is initial.
      exit.
    endif.
  endif.

* Regulierer
  if not kurgv-kunnr is initial.
* Regulierer für Aufträge gesperrt ?
    perform tvasp_select using kurgv-kunnr
                               kurgv-aufsd
                               vbak-auart
                               us_dialog
                               ch_subrc.
    check ch_subrc = 0.
  endif.

endform.                    "PARTNER_PRUEFEN