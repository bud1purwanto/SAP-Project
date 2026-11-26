*&---------------------------------------------------------------------*
*&      Form  INCOMPL_LAST_DIALOG
*&---------------------------------------------------------------------*
*    Vor dem sichern oder dem Rücksprung zum aufrufenden Programm      *
*    wird ggf. durch ein Popup auf die Unvollständigkeit des Beleges   *
*    hingewiesen.                                                      *
*    CH_UV_SUBRC = 0  Alles OK                                         *
*                     -> Sichern oder zum Aufrufer zurückspringen      *
*                = 4  Abbrechen oder Daten bearbeiten                  *
*                     -> Die Bearbeitung wird im aktuellen Programm    *
*                        fortgesetzt.                                  *
*----------------------------------------------------------------------*
form incompl_last_dialog using ch_uv_subrc.

  data: da_lines     like sy-tfill,
        da_answer(1) type c.

  ch_uv_subrc = 0.

* Unvollständigkeitsdialog
  describe table xvbuv lines da_lines.

* special logic for call dialog cases
* don't call incompletion only for serial numbers
  if call_dialog = charx and da_lines > 0 and
     ( call_activity = activity_service_request or
       call_activity = activity_service_order ).
    loop at xvbuv transporting no fields where fdnam ne 'ANZSN'.
      exit.
    endloop.
* there are only serial numbers in incompletion log.
    if sy-subrc = 4.
      ch_uv_subrc = 0.
      message id 'V2' type 'I' number '156'.
      exit.
    endif.
  endif.

* Lean Order processing
  if call_activity eq gc_activity_lord.
    if da_lines > 0.
      if tvak-diafe ne space.
        message w012.
        message_collect_lord.
        incompletion_active = charx.
        ch_uv_subrc = 4.
        exit.
      else.
        if cl_ops_switch_check=>sd_sfws_sc1( ) eq abap_false.
*         EHP2 SD-BF is off
          message w009(sls_lord).
          message_collect_lord.
        else.
*         EHP2 SD-BF is on
          if not gf_sapgui_mode is initial.
            call function 'POPUP_TO_DECIDE'
              exporting
                titel          = text-110
                textline1      = text-111
                textline3      = text-112
                text_option1   = text-115
                text_option2   = text-116
                cancel_display = 'X'
                defaultoption  = '2'
                start_column   = 25
                start_row      = 6
              importing
                answer         = da_answer.
            if da_answer = chara or
               da_answer = char2.
              incompletion_active = charx.
              ch_uv_subrc = 4.
              exit.
            endif.
          else.
            message w009(sls_lord).
            message_collect_lord.
          endif.
        endif.
      endif.
    endif.
  endif.

  if da_lines > 0 and
    call_function = space and
    ( sy-binpt = space or
      bi_info-ctu_amodus ca 'A' or
      not cattaktiv is initial ) .
    if tvak-diafe ne space.
      message s012.
      fcode = 'FEAZ'.
      incompletion_active = charx.
      perform fcode_bearbeiten.
      ch_uv_subrc = 4.
      exit.
    endif.
    if sy-pfkey ne 'FE  '.
      call function 'POPUP_TO_DECIDE'
        exporting
          titel          = text-110
          textline1      = text-111
          textline3      = text-112
          text_option1   = text-115
          text_option2   = text-116
          cancel_display = 'X'
          defaultoption  = '2'
          start_column   = 25
          start_row      = 6
        importing
          answer         = da_answer.
*     Abbrechen
      if da_answer = chara.
        fcode = fcode_gleiche_seite.
        incompletion_active = charx.
        perform fcode_bearbeiten.
        ch_uv_subrc = 4.
        exit.
      endif.
*     Bearbeiten
      if da_answer = char2.
        fcode = 'FEAZ'.
        incompletion_active = charx.
        perform fcode_bearbeiten.
        ch_uv_subrc = 4.
        exit.
      endif.
    endif.
  endif.

endform.                               " INCOMPL_LAST_DIALOG