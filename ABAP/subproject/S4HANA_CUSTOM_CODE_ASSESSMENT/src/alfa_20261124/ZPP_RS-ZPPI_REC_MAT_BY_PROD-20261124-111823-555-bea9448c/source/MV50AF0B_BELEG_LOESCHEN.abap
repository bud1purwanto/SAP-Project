*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BELEG_LOESCHEN                                    *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BELEG_LOESCHEN                                           *
*---------------------------------------------------------------------*
*       Der Beleg wird gelöscht.                                      *
*---------------------------------------------------------------------*
form beleg_loeschen.

  data: bl_tfill like sy-tfill,
        bl_answer.
  data: lf_subrc like sy-subrc.

  data: lf_outb_delivery   type vbeln_vl,                   "v_n_1144740
        lf_vbfa_tabix      type sy-tabix,
        ls_xvbfa           like line of xvbfa,
        ls_vbfa            type vbfa.                       "^_n_1144740

enhancement-point mv50af0b_beleg_loeschen_01 spots es_sapmv50a static.


enhancement-point mv50af0b_beleg_loeschen_02 spots es_sapmv50a.

  if t180-trtyp = charh.
    message s075.
    exit.
  endif.

enhancement-point beleg_loeschen_01 spots es_sapmv50a.
  if sy-binpt eq charx.                                     "v_n_686037
* can only occur in batch input
    if t180-trtyp = chara or
     ( v50agl-dlv_change is initial and
     ( likp-vlstk na ' A' or
     ( likp-vlstk eq chara and not likp-verursys is initial ) ) ).
enhancement-section     mv50af0b_beleg_loeschen_08 spots es_sapmv50a.
      message s066.
      leave program.
end-enhancement-section.
    endif.
  endif.                                                    "^_n_686037

  if t180-bldgr(1) eq 'E' and                               "v_n_521409
     v50agl-new_del_mode ne space.
    perform delete_delivery_complete.
    exit.
  endif.                                                    "^_n_521409
*---------------------------------------------------------------------*
*    Pruefen ob alle Positionen löschbar sind.                        *
*---------------------------------------------------------------------*
  perform xlips_loeschen_pruefen_alle(sapfv50p) using lf_subrc.

enhancement-point mv50af0b_beleg_loeschen_03 spots es_sapmv50a.


  case lf_subrc.
    when 0.
      bl_answer = charj.
    when 4.
* Wenn das Löschen über den Funktionsbaustein WS_DELIVERY_UPDATE
* erfolgt, muß hier eine Error-Message ausgegeben werden, damit nicht
* in die Dialogverarbeitung verzweigt wird. Die Error-Message kann
* dann durch eine Exception abgefangen werden.
      if v50agl-kommirueckmeldung = charx.
        message e066.
      endif.
      if sy-batch = space and sy-binpt = space.
        call function 'POPUP_TO_CONFIRM_WITH_MESSAGE'
          exporting
            titel         = text-007
            diagnosetext1 = text-008
            diagnosetext2 = text-009
            textline1     = text-010
            textline2     = text-011
          importing
            answer        = bl_answer.
      else.
        bl_answer = charj.
      endif.
      if bl_answer ne charj.
        exit.
      else.
      endif.
    when 8.
* Wenn das Löschen über den Funktionsbaustein WS_DELIVERY_UPDATE
* erfolgt, muß hier eine Error-Message ausgegeben werden, damit nicht
* in die Dialogverarbeitung verzweigt wird. Die Error-Message kann
* dann durch eine Exception abgefangen werden.
      if v50agl-kommirueckmeldung = charx.
        message e066.
      endif.
      bl_answer = charn.
      message s066.
      if sy-calld = charx.
        leave.
      endif.
      if sy-binpt eq charx.                                 "n_533866
        leave program.
      endif.
*     New dialog: Do not leave current screen, if no deletion can be
*     done. In the old dialog the system must react as before due to
*     backward compatibility.
      if t180-bldgr eq gc_new_dialog_outb or
         t180-bldgr eq gc_new_dialog_inb.
        exit.
      endif.
  endcase.
*---------------------------------------------------------------------*
*    Löschvorgang                                                     *
*---------------------------------------------------------------------*
  if bl_answer = charj.
    perform xlips_markieren_alle(sapfv50p).
*   Delete batch split items and subitems with priority
    loop at xlips where updkz ne updkz_delete
                    and not uecha is initial.
      lips = xlips.
       *lips = xlips.
      perform xlips_loeschen(sapfv50p) using charx tabix_0.
    endloop.
    loop at xlips where updkz ne updkz_delete
                    and not uepos is initial.
      lips = xlips.
       *lips = xlips.
      perform xlips_loeschen(sapfv50p) using charx tabix_0.
    endloop.
    loop at xlips where updkz ne updkz_delete
                    and uecha is initial
                    and uepos is initial.
      lips = xlips.
       *lips = xlips.
      perform xlips_loeschen(sapfv50p) using charx tabix_0.
    endloop.

enhancement-point mv50af0b_beleg_loeschen_04 spots es_sapmv50a.

    loop at xlips where updkz ne 'D'.
      exit.
    endloop.
*---------------------------------------------------------------------*
*    Der Beleg wird komplett gelöscht                                 *
*---------------------------------------------------------------------*
    if sy-subrc = 4.
      perform likp_loeschen(sapfv50k).
    else.
*---------------------------------------------------------------------*
*    Der Beleg wird teilweise gelöscht                                *
*---------------------------------------------------------------------*
enhancement-point mv50af0b_beleg_loeschen_06 spots es_sapmv50a.
*     If document can not be saved exit to dialog processing again
      perform beleg_sichern_01 using    charx               "470
                                        charx
                                        charx
                                        charx
                               changing lf_subrc.
      if lf_subrc ne 0.
        exit.
      endif.
    endif.
  endif.
enhancement-point mv50af0b_beleg_loeschen_07 spots es_sapmv50a.

  if xlikp_updkz ne updkz_delete.
*---------------------------------------------------------------------*
*    Der Beleg wurde teilweise gelöscht bzw. das Löschen abgebrochen  *
*---------------------------------------------------------------------*
    if t180-bldgr eq gc_new_dialog_outb or
       t180-bldgr eq gc_new_dialog_inb.
      fcode = 'ABBR_T'.
      perform funktion_ausfuehren.
    else.
      fcode = fcode_uebersicht_einzeilig.
      perform funktion_ausfuehren.
    endif.
  else.
*---------------------------------------------------------------------*
*    Der Beleg wird komplett gelöscht                                 *
*---------------------------------------------------------------------*

*   Nachrichten löschen
    move xobjky         to xobjky_to.
    move '9999999999'   to xobjky_to+10.
    call function 'RV_MESSAGES_DELETE'
      exporting
        msg_objky         = xobjky
        msg_objky_to      = xobjky_to
        delete_all_status = 'X'.

* Loeschen Termine
    if likp-ternr ne space.
      call function 'SD_DEADLINE_DELETE'
        exporting
          deadline_no_in = likp-ternr
        exceptions                                          "v_n_568823
          not_found      = 0
          delete_error   = 0
          others         = 0.                               "^_n_568823
    endif.
* Löschen von Torbelegungen
    if likp-vbtyp ca vbtyp_mmli.
      if not likp-lgnum is initial
         and not likp-lgtor is initial
         and not likp-wadat is initial.
        call function 'W_APPOINTMENT_SN_DELETE'
          exporting
            i_vbeln = likp-vbeln
            i_vbtyp = likp-vbtyp
          exceptions
            others  = 0.
      endif.

enhancement-point mv50af0b_beleg_loeschen_05 spots es_sapmv50a.

    endif.

*   Delete entry in cross-docking document flow
    call method /spe/cl_cd_docflow=>delete
      exporting
        if_delivery   = likp-vbeln
      exceptions
        no_cd_process = 0
        others        = 0.

* Delete document flow record to preceding outbound delivery
  if likp-lifex ne space and                                "v_n_1144740
     ( LIKP-SPE_LIFEX_TYPE EQ GC_LIFEX_TYPE-STOCKTRANSFER OR
       LIKP-SPE_LIFEX_TYPE EQ GC_LIFEX_TYPE-NOSTOTRANSFER ).  "n_1364822
    lf_outb_delivery = likp-lifex.
    read table xvbfa into ls_xvbfa
                     with key vbelv = lf_outb_delivery
                              posnv = posnr_low
                              vbeln = likp-vbeln
                              posnn = posnr_low
                              vbtyp_n = likp-vbtyp
                     binary search.
    lf_vbfa_tabix = sy-tabix.
    if sy-subrc eq 0.
      move-corresponding ls_xvbfa to ls_vbfa.
    else.
      select single * from vbfa
                      into ls_vbfa
                      where vbelv eq lf_outb_delivery
                        and posnv eq posnr_low
                        and vbeln eq likp-vbeln
                        and posnn eq posnr_low
                        and vbtyp_n eq likp-vbtyp.
      if sy-subrc eq 0.
        move-corresponding ls_vbfa to ls_xvbfa.
        insert ls_xvbfa into xvbfa index lf_vbfa_tabix.
      else.
        lf_vbfa_tabix = 0.
      endif.
    endif.
    if lf_vbfa_tabix ne 0.
      call function 'RV_XVBFA_MAINTAIN'
        exporting
          fvbfa                  = ls_vbfa
          f_vorgang              = 'L'
          i_do_not_rebuild_vbapf = 'X'
        tables
          fxvbfa                 = xvbfa
          fyvbfa                 = yvbfa.
    endif.
  endif.                                                    "^_n_1144740

    if not gi_badi_delivery is initial.            "n_530754/n_637289
      call method gi_badi_delivery->delivery_deletion
        exporting
          is_likp        = likp
          is_likpd       = likpd
          it_yvbuk       = yvbuk[]
          it_yvbup       = yvbup[]
          it_ylikp       = ylikp[]
          it_xlips       = xlips[]
          it_ylips       = ylips[]
          it_yvbpa       = yvbpa[]
          it_xvbfa       = xvbfa[]
          it_yvbfa       = yvbfa[]
          it_xvbadr      = xvbadr[]
          is_v50agl      = v50agl
          if_trtyp       = t180-trtyp
          if_tcode       = t180-tcode
        changing
          cs_v50agl_cust = v50agl_cust.
    endif.                                                  "n_530754

*   Userexit
    perform userexit_delete_document.

*   If document can not be saved terminate processing to avoid
*   inconsistencies
    perform beleg_sichern_01 using    charx               "470
                                      charx
                                      charx
                                      charx
                             changing lf_subrc.
    if lf_subrc ne 0.
*     If the decentral warehouse management scenario is active show log
*     of simulation before leaving transaction
      if likp-vlstk ne space and
         not cvbfs[] is initial.
        perform fcode_feaz.
      endif.
      message a066.
    endif.
  endif.
*-clear APO Delta before leave to transaction:
  if v50agl-no_commit eq space.
    perform nmodul_for_tcode_apo.
  endif.

endform.                    "beleg_loeschen