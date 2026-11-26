*&---------------------------------------------------------------------*
*&      FORM  WK_ABRUF_PRUEFEN_KOPIEREN
*&---------------------------------------------------------------------*
*       Es wird geprüft, ob der Zielwert bereits erreicht ist und      *
*       es wird eine entsprechende Meldung ausgegeben                  *
*----------------------------------------------------------------------*
form wk_abruf_pruefen_kopieren using us_subrc
                                     us_vbap like vbap.

  data: da_abrufwert like vbapd-awert,
        da_zielwert  like s135-zwert,
        da_differenz like s135-zwert,
        da_diff1(13) type c,
        da_answer(1) type c.

  call function 'SD_READ_CALL_OFF_VALUE'
    exporting
      i_vbeln = us_vbap-vbeln
      i_posnr = us_vbap-posnr
    importing
      e_awert = da_abrufwert
      e_zwert = da_zielwert.

  if da_abrufwert >= da_zielwert.
    da_differenz = da_abrufwert - da_zielwert.
    write da_differenz to da_diff1 currency us_vbap-waerk.
    perform tvap_select(sapmv45a) using us_vbap-pstyv
                                        space
                                        sy-subrc.
    case tvap-rktio.
      when chara.
* Warnung bezüglich Zielwertüberschreitung
* Kein Batch-Input und kein Aufruf per Call Function --> Popups
        if ( sy-binpt = space or not cattaktiv is initial ) and
           call_function = space.
          call function 'POPUP_TO_DECIDE_COMPL_QUEST'
            exporting
              title          = text-250
              txt01          = text-251
              txt02          = text-252
              txt03          = text-253
              par01          = us_vbap-vbeln
              par02          = us_vbap-posnr
              par03          = da_diff1
              par04          = us_vbap-waerk
              new_line1      = charx
              new_line2      = charx
              qtext          = text-258
              default_answer = charj
              length         = 100
            importing
              answer         = da_answer.
        else.
          da_answer = charj.
        endif.
        case da_answer.
          when charj.
            if call_activity eq gc_activity_lord.
              message w675(v1) with us_vbap-vbeln us_vbap-posnr.
              message_collect_lord.
            endif.
            us_subrc = 0.
            exit.
          when charn.
            us_subrc = 1.
            exit.
          when chara.
            us_subrc = 4.
            exit.
        endcase.
*     Fehler bei Zielwertüberschreitung
      when charb.
* Kein Batch-Input und kein Aufruf per Call Function --> Popups
        if ( sy-binpt = space or not cattaktiv is initial ) and
           call_function = space.
          call function 'POPUP_TO_DECIDE_COMPL_QUEST'
            exporting
              title          = text-250
              txt01          = text-251
              txt02          = text-252
              txt03          = text-253
              par01          = us_vbap-vbeln
              par02          = us_vbap-posnr
              par03          = da_diff1
              par04          = us_vbap-waerk
              new_line1      = charx
              new_line2      = charx
              qtext          = text-259
              answer01       = text-212
              answer02       = char*
              answer03       = char*
              default_answer = charj
              length         = 100
            importing
              answer         = da_answer.
        endif.
        if call_activity eq gc_activity_lord.
          message w675(v1) with us_vbap-vbeln us_vbap-posnr.
          message_collect_lord.
        endif.
        us_subrc = 1.
        exit.
*     Nur erste Abrufüberschreitung erlaubt --> Fehler
      when charc.
* Kein Batch-Input und kein Aufruf per Call Function --> Popups
        if ( sy-binpt = space or not cattaktiv is initial ) and
           call_function = space.
          call function 'POPUP_TO_DECIDE_COMPL_QUEST'
            exporting
              title          = text-250
              txt01          = text-251
              txt02          = text-252
              txt03          = text-253
              par01          = us_vbap-vbeln
              par02          = us_vbap-posnr
              par03          = da_diff1
              par04          = us_vbap-waerk
              new_line1      = charx
              new_line2      = charx
              qtext          = text-259
              answer01       = text-212
              answer02       = char*
              answer03       = char*
              default_answer = charj
              length         = 100
            importing
              answer         = da_answer.
        endif.
        if call_activity eq gc_activity_lord.
          message w675(v1) with us_vbap-vbeln us_vbap-posnr.
          message_collect_lord.
        endif.
        us_subrc = 1.
        exit.
      when chard.
* Warnung bezüglich Zielwertüberschreitung
* Kein Batch-Input und kein Aufruf per Call Function --> Popups
        if ( sy-binpt = space or not cattaktiv is initial ) and
           call_function = space.
          call function 'POPUP_TO_DECIDE_COMPL_QUEST'
            exporting
              title          = text-250
              txt01          = text-251
              txt02          = text-252
              txt03          = text-253
              par01          = us_vbap-vbeln
              par02          = us_vbap-posnr
              par03          = da_diff1
              par04          = us_vbap-waerk
              new_line1      = charx
              new_line2      = charx
              qtext          = text-258
              default_answer = charj
              length         = 100
            importing
              answer         = da_answer.
        else.
          da_answer = charj.
        endif.
        case da_answer.
          when charj.
            if call_activity eq gc_activity_lord.
              message w675(v1) with us_vbap-vbeln us_vbap-posnr.
              message_collect_lord.
            endif.
            us_subrc = 0.
            exit.
          when charn.
            us_subrc = 1.
            exit.
          when chara.
            us_subrc = 4.
            exit.
        endcase.
    endcase.
  endif.


endform.                    "WK_ABRUF_PRUEFEN_KOPIEREN