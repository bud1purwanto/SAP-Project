*&--------------------------------------------------------------------*
*&      Form  WK_ABRUF_PRUEFEN_SICHERN
*&--------------------------------------------------------------------*
*       Bei Wertkontraktabrufen wird überprüft, ob der Zielwert       *
*       bereits überschritten ist.                                    *
*---------------------------------------------------------------------*
form  wk_abruf_pruefen_sichern using us_subrc.

  data: da_abrufwert like vbapd-awert,
        da_abruf_s135 like vbapd-awert,
        da_zielwert like s135-zwert,
        da_differenz like s135-zwert,
        da_diff1(13) type c,
        da_wkwaehrung like vbkd-wkwae,
        da_answer(1) type c,
        da_pstyv like tvap-pstyv,
        da_rktio like tvap-rktio.
enhancement-point wk_abruf_pruefen_sichern_01 spots es_sapmv45a static.
enhancement-point wk_abruf_pruefen_sichern_02 spots es_sapmv45a.

* Nur weiter, wenn mind. eine Position Abruf zum Wertkontrakt ist
  loop at xvbap where updkz ne updkz_delete and
                      not wktnr is initial and
                      shkzg is initial.
    exit.
  endloop.

  check sy-subrc = 0.

*   Fortschreibungsdaten ermitteln
  perform offene_werte_wk_ermitteln.
* Interne Tabelle der Fortschreibungsdaten durchlaufen
  loop at wk_open_values.
*   Abrufdaten von der Datenbank lesen
    call function 'SD_READ_CALL_OFF_VALUE'
      exporting
        i_vbeln = wk_open_values-wktnr
        i_posnr = wk_open_values-wktps
      importing
        e_awert = da_abruf_s135
        e_zwert = da_zielwert.
*   Abrufdaten aufsummieren
    da_abrufwert = da_abruf_s135 + wk_open_values-oaauwe +
                wk_open_values-oaliwe + wk_open_values-afakwe.
*   Vergleich des Abrufwertes mit dem Zielwert
    if da_abrufwert > da_zielwert and da_abrufwert > da_abruf_s135.
      da_differenz = da_abrufwert - da_zielwert.
      write da_differenz to da_diff1 currency wk_open_values-waerk.

* Reaktionsregel aus Positionstypen des Wertkontraktes ermitteln
      select single pstyv into (da_pstyv) from vbap
       where vbeln = wk_open_values-wktnr and
             posnr = wk_open_values-wktps.
      select single rktio into (da_rktio) from tvap
       where pstyv = da_pstyv.

* Kein Batch-Input und kein Aufruf per Call Function --> Popups
      if ( sy-binpt = space or not cattaktiv is initial ) and
         call_function = space.

        case da_rktio.
          when chara.
*         Warnung bei Überschreitung des Zielwertes
            call function 'POPUP_TO_DECIDE_COMPL_QUEST'
              exporting
                title          = text-250
                txt01          = text-251
                txt02          = text-252
                txt03          = text-253
                par01          = wk_open_values-wktnr
                par02          = wk_open_values-wktps
                par03          = da_diff1
                par04          = wk_open_values-waerk
                new_line1      = charx
                new_line2      = charx
                qtext          = text-254
                answer01       = text-255
                answer02       = text-256
                default_answer = charj
                length         = 100
              importing
                answer         = da_answer.
            case da_answer.
*           'Sichern'
              when charj.
                us_subrc = 0.
                exit.
*           'Bearbeiten'
              when charn.
                fcode = fcode_gleiche_seite.
                perform fcode_bearbeiten.
                us_subrc = 4.
                exit.
*           'Abbrechen'
              when chara.
                fcode = fcode_gleiche_seite.
                perform fcode_bearbeiten.
                us_subrc = 4.
                exit.
            endcase.
*       Error bei Überschreitung des Zielwertes
          when charb.
            call function 'POPUP_TO_DECIDE_COMPL_QUEST'
              exporting
                title          = text-250
                txt01          = text-251
                txt02          = text-252
                txt03          = text-253
                par01          = wk_open_values-wktnr
                par02          = wk_open_values-wktps
                par03          = da_diff1
                par04          = wk_open_values-waerk
                new_line1      = charx
                new_line2      = charx
                qtext          = text-257
                answer01       = text-212
                answer02       = char*
                answer03       = char*
                default_answer = charj
                length         = 100
              importing
                answer         = da_answer.
            fcode = fcode_gleiche_seite.
            perform fcode_bearbeiten.
            us_subrc = 4.
            exit.
*       Warnung bei erster Zielwertüberschreitung
          when charc.
            if da_abrufwert > da_zielwert.
              if da_abruf_s135 < da_zielwert.
                call function 'POPUP_TO_DECIDE_COMPL_QUEST'
                  exporting
                    title          = text-250
                    txt01          = text-251
                    txt02          = text-252
                    txt03          = text-253
                    par01          = wk_open_values-wktnr
                    par02          = wk_open_values-wktps
                    par03          = da_diff1
                    par04          = wk_open_values-waerk
                    new_line1      = charx
                    new_line2      = charx
                    qtext          = text-254
                    answer01       = text-255
                    answer02       = text-256
                    default_answer = charj
                    length         = 100
                  importing
                    answer         = da_answer.
                case da_answer.
*             'Sichern'
                  when charj.
                    us_subrc = 0.
                    exit.
*             'Bearbeiten'
                  when charn.
                    fcode = fcode_gleiche_seite.
                    perform fcode_bearbeiten.
                    us_subrc = 4.
                    exit.
*             'Abbrechen'
                  when chara.
                    fcode = fcode_gleiche_seite.
                    perform fcode_bearbeiten.
                    us_subrc = 4.
                    exit.
                endcase.
              else.
                call function 'POPUP_TO_DECIDE_COMPL_QUEST'
                  exporting
                    title          = text-250
                    txt01          = text-251
                    txt02          = text-252
                    txt03          = text-253
                    par01          = wk_open_values-wktnr
                    par02          = wk_open_values-wktps
                    par03          = da_diff1
                    par04          = wk_open_values-waerk
                    new_line1      = charx
                    new_line2      = charx
                    qtext          = text-257
                    answer01       = text-212
                    answer02       = char*
                    answer03       = char*
                    default_answer = charj
                    length         = 100
                  importing
                    answer         = da_answer.
                fcode = fcode_gleiche_seite.
                perform fcode_bearbeiten.
                us_subrc = 4.
                exit.
              endif.
            endif.
          when chard.
*         Warnung bei Überschreitung des Zielwertes
            call function 'POPUP_TO_DECIDE_COMPL_QUEST'
              exporting
                title          = text-250
                txt01          = text-251
                txt02          = text-252
                txt03          = text-253
                par01          = wk_open_values-wktnr
                par02          = wk_open_values-wktps
                par03          = da_diff1
                par04          = wk_open_values-waerk
                new_line1      = charx
                new_line2      = charx
                qtext          = text-254
                answer01       = text-255
                answer02       = text-256
                default_answer = charj
                length         = 100
              importing
                answer         = da_answer.
            case da_answer.
*           'Sichern'
              when charj.
                us_subrc = 0.
                exit.
*           'Bearbeiten'
              when charn.
                fcode = fcode_gleiche_seite.
                perform fcode_bearbeiten.
                us_subrc = 4.
                exit.
*           'Abbrechen'
              when chara.
                fcode = fcode_gleiche_seite.
                perform fcode_bearbeiten.
                us_subrc = 4.
                exit.
            endcase.
        endcase.
      else.
        case da_rktio.
*         Error bei Überschreitung des Zielwertes
          when charb.
            us_subrc = 4.
            if not call_function is initial.
              if call_activity eq gc_activity_lord.
                message w675(v1) with wk_open_values-wktnr
                                      wk_open_values-wktps.
                message_collect_lord.
              else.
                message e675(v1) with wk_open_values-wktnr
                                      wk_open_values-wktps.
              endif.
            endif.
            exit.
*         Warnung bei erster Zielwertüberschreitung
          when charc.
            if da_abruf_s135 >= da_zielwert and
               da_abrufwert > da_zielwert.
              us_subrc = 4.
              if not call_function is initial.
                message w675(v1) with wk_open_values-wktnr
                                      wk_open_values-wktps.
                message_collect_lord.
              endif.
              exit.
            endif.
        endcase.
      endif.
    endif.
  endloop.

endform.                    "WK_ABRUF_PRUEFEN_SICHERN