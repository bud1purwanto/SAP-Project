*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_NEWD                                        *
*----------------------------------------------------------------------*
* Form routine to get new delivery document. The new document comes
* up in display mode when it can not be blocked.

form fcode_newd.

  data: lf_save_fcode type fcode,
        lf_save_likp_vbeln type vbeln_vl,
        ls_likp type likp,
        ls_vbuk type vbuk,
        lf_docnumber(10) type c,
        lf_user type symsgv,                                  "n_557750
        begin of lt_preceding_doc occurs 0,
          vbeln type vbeln_vl,
          posnr type posnr_vl,
          vgtyp like lips-vgtyp,
          vgbel like lips-vgbel,
        end of lt_preceding_doc,
        begin of lt_purchase occurs 0,
          vgbel type lips-vgbel,
        end of lt_purchase,
        begin of lt_sales_order occurs 0,
          vgbel type lips-vgbel,
        end of lt_sales_order,
        lf_display_flag type c,
        lf_textline1(50) type c,
        lf_textline2(50) type c,
        lf_title(50) type c,
        lf_answer type c,
        lf_read_from_archive type c,                        "n_574894
        lf_old_likp_vbeln    like likp-vbeln,
        lf_v50agl_display_from_archive type c,
        lf_subrc type sysubrc,
        i_dnact like rdgdnact,
        lf_erdat type erdat.

  clear: lf_erdat.

  field-symbols: <ls_comm_area> TYPE ANY.                 "n_1471318

* Ask for new document number first and check existence
  lf_save_fcode = fcode.
  lf_old_likp_vbeln = likp-vbeln.                           "n_574894
  lf_v50agl_display_from_archive = v50agl-display_from_archive.
  if t180-bldgr eq gc_new_dialog_inb.
    call screen 4103 starting at 20 10.
  else.
    call screen 4003 starting at 20 10.
  endif.
  fcode = lf_save_fcode.
  check not rv50a-vbeln is initial.
  check rv50a-vbeln ne likp-vbeln.

  select single * from likp
                  into ls_likp
                  where vbeln eq rv50a-vbeln.
  if sy-subrc ne 0.
    if t180-tcode cs 'VLPOD'.                               "v_n_574894
      message s302 display like 'E' with rv50a-vbeln.
      exit.
    else.
      lf_read_from_archive = charx.
    endif.                                                  "^_n_574894
  elseif ls_likp-spe_loekz = charx.                        "v_n_1381383
    message s008(/spe/id_handling) display like 'E' with rv50a-vbeln.
    exit.                                                  "^_n_1381383
  endif.
* POD: New delivery relevant for POD?
  if t180-tcode cs 'VLPOD'.
    select single * from vbuk
                    into ls_vbuk
                    where vbeln eq rv50a-vbeln.
    if ls_vbuk-pdstk eq space.
      message s646 with rv50a-vbeln.
      exit.
    endif.
  endif.

* check for valid combination:
* outbound dlvs may only be processed with tcode VL01-VL03,
* inbound dlvs may only be processed with tcode Vl31-VL33
* and rough-GR with tcode VL41-VL43
  if ls_likp-vbtyp ca vbtyp_liav and t180-trvog ne chard or
     ls_likp-vbtyp ca vbtyp_grwe and t180-trvog ne charg or
     ls_likp-vbtyp ca vbtyp_lief and t180-trvog ne char6.
*     message e143.
     message id 'VL' type 'I' number '143'
         display like 'E'.
     exit.
  endif.

  if ls_likp-vbtyp ca vbtyp_lief.                            "v_n_870661
*   Check Authority VSTEL
    data: lf_actvt like tact-actvt,
          lf_msgno like sy-msgno.
*   set activity
    case t180-trtyp.
      when charh.
*      'other delivery' in change mode
        lf_actvt = actvt_02.
      when charv.
*       change
        lf_actvt = actvt_02.
      when chara.
*       display
        lf_actvt = actvt_03.
    endcase.

    AUTHORITY-CHECK OBJECT 'V_LIKP_VST'
         ID 'VSTEL' FIELD LS_LIKP-VSTEL
         ID 'ACTVT' FIELD lf_ACTVT.

*   no authority
    if sy-subrc ne 0.
      case lf_actvt.
        when actvt_02.
          lf_msgno = '081'.
        when actvt_03.
          lf_msgno = '082'.
      endcase.
      perform message_handling(sapmv50a) using cvbap-posnr
                                                  lf_msgno
                                                  'E'
                                                  'VL'
                                                  ls_likp-vstel
                                                  space
                                                  space
                                                  space.
      exit.
    endif.
  endif.                                                     "^_n_870661

  lf_save_likp_vbeln = rv50a-vbeln.
* If current mode is 'change' or 'create'...
  if t180-trtyp eq charv or t180-trtyp eq charh.

*  Check for possible data loss first
    if r185d-dataloss ne space.
      lf_textline1 = 'Lieferung &1 wurde verändert.'(064).
      lf_textline2 = 'Vor dem Lesen des neuen Belegs sichern?'(067).
      lf_title = 'Belegbearbeitung beenden'(066).
      write likp-vbeln to lf_docnumber no-zero.
      replace '&1' with lf_docnumber into lf_textline1.
      condense lf_textline1.
      call function 'POPUP_TO_CONFIRM_STEP'
        exporting
          defaultoption  = 'Y'
          textline1      = lf_textline1
          textline2      = lf_textline2
          titel          = lf_title
          start_column   = 25
          start_row      = 6
          cancel_display = 'X'
        importing
          answer         = lf_answer.

      case lf_answer.
        when 'J'.
          lf_save_fcode = fcode.
          fcode = 'SAVE&EXIT'.
          perform beleg_sichern using charx.
          IF LIKP-VBTYP EQ CHARJ.                           "v_n_1105631
            GET PARAMETER ID 'VL' FIELD LF_OLD_LIKP_VBELN.     "n_993005
          ELSEIF LIKP-VBTYP EQ CHAR7.
            GET PARAMETER ID 'VLM' FIELD LF_OLD_LIKP_VBELN.
          ENDIF.                                            "^_n_1105631

*         rename the SD-monitor-protocol, but only if protocol is to be
*         saved and not in CHANGE-mode because then the document number
*         is known
          if t180-trtyp = charh.
            if xsdctrlflag is initial.
              call function 'SD_MONITOR_CONTROL_FLAGS_GET'
                importing
                  fsdctrlflag = xsdctrlflag
                exceptions
                  others      = 1.
            endif.
            if xsdctrlflag-protsave = yes.
              call function 'SD_MONITOR_PROTOCOL_RENAME'
                exporting
                  fpappl = protocolcaller-sdl
                  fvbeln = likp-vbeln
                exceptions
                  others = 1.
              call function 'SD_MONITOR_PROTOCOL_EXPORT'
                exporting
                  fpappl = protocolcaller-sdl
                  fvbeln = likp-vbeln
                exceptions
                  others = 1.
            endif.
          endif.
          fcode = lf_save_fcode.
        when 'A'.
          exit.
        when 'N'.
          call function 'DEQUEUE_ALL'.
      endcase.
    else.
      call function 'DEQUEUE_ALL'.
    endif.

*   The new document and its related preceding documents have to be
*   blocked first. If blocking is not possible then the delivery
*   processing switches to display mode
*   1. Block delivery document
    if lf_read_from_archive eq space.                       "n_574894
      call function 'ENQUEUE_EVVBLKE'
        exporting
          vbeln          = ls_likp-vbeln
        exceptions
          foreign_lock   = 2
          system_failure = 3.
      case sy-subrc.
        when 2.
          write ls_likp-vbeln to lf_docnumber no-zero.
          write sy-msgv1 to lf_user.
          message s046 with lf_docnumber lf_user.
          lf_display_flag = charx.
        when 3.
          message s047.
          lf_display_flag = charx.
      endcase.
    else.                                                   "v_n_574894
      lf_display_flag = charx.
    endif.                                                  "^_n_574894

    if lf_display_flag is initial.
*     2. Check whether delivery has related preceding documents
      perform tvlk_select using ls_likp-lfart
                                charx
                                lf_subrc.

      if tvlk-aufer ca 'XB'.
        select vbeln posnr vgtyp vgbel from lips
                                 into table lt_preceding_doc
                                 where vbeln eq ls_likp-vbeln.
*       Extract preceding document numbers
        loop at lt_preceding_doc.
          check not lt_preceding_doc-vgbel is initial.
          if lt_preceding_doc-vgtyp eq charv.
            lt_purchase-vgbel = lt_preceding_doc-vgbel.
            collect lt_purchase.
          else.
            lt_sales_order-vgbel = lt_preceding_doc-vgbel.
            collect lt_sales_order.
          endif.
        endloop.

*       Block preceding documents
        loop at lt_purchase.
          call function 'ENQUEUE_EMEKKOE'
            exporting
              mandt          = sy-mandt
              ebeln          = lt_purchase-vgbel
            exceptions
              foreign_lock   = 2
              system_failure = 3.
          case sy-subrc.
            when 2.
              write lt_purchase-vgbel to lf_docnumber no-zero.
              write sy-msgv1 to lf_user.
              message i247 with lf_docnumber lf_user.
              lf_display_flag = charx.
              exit.
            when 3.
              message i047.
              lf_display_flag = charx.
              exit.
          endcase.
*         Check if the document is on the database         "v_n_1169039
          select single * from EKKO where ebeln = lt_purchase-vgbel.
          if sy-subrc ne 0.
            call function 'DEQUEUE_ALL'.
            message s650(vl) with lt_purchase-vgbel.
            lf_display_flag = charx.
            exit.
          endif.                                           "^_n_1169039
        endloop.
        if lf_display_flag is initial.
          loop at lt_sales_order.
            call function 'SD_SALES_DOCUMENT_ENQUEUE'
              exporting
                vbeln          = lt_sales_order-vgbel
              exceptions
                foreign_lock   = 2
                system_failure = 3.

            case sy-subrc.
              when 2.
                write lt_sales_order-vgbel to lf_docnumber no-zero.
                write sy-msgv1 to lf_user.
                message i045 with lf_docnumber lf_user.
                lf_display_flag = charx.
                exit.
              when 3.
                message i047.
                lf_display_flag = charx.
                exit.
            endcase.
*           Check if the document is on the database       "v_n_1169039
            select single * from VBAK where vbeln = lt_sales_order-vgbel.
            if sy-subrc ne 0.
              call function 'DEQUEUE_ALL'.
              message s303(vl) with lt_sales_order-vgbel.
              lf_display_flag = charx.
              exit.
            endif.                                         "^_n_1169039
          endloop.
        endif.
      endif.
    endif.
*   POD: Switch to display mode if goods issue has not been posted yet
    if lf_display_flag is initial and
       t180-tcode eq 'VLPOD'      and
       ls_vbuk-wbstk ne charc.
      lf_display_flag = charx.
      message s058(vla) with rv50a-vbeln.
    endif.

*   Switch to display mode if new document can not be blocked
    if lf_display_flag eq charx.
      call function 'DEQUEUE_ALL'.
      if t180-tcode eq 'VL32N'.
        t180-tcode = 'VL33N'.
      elseif t180-tcode eq 'VL02N'.
        t180-tcode = 'VL03N'.
      elseif t180-tcode(5) eq 'VL01N'.
        t180-tcode = 'VL03N'.
      elseif t180-tcode eq 'VL31N'.
        t180-tcode = 'VL33N'.
      elseif t180-tcode eq 'VLPOD'.
        t180-tcode = 'VLPODA'.
      endif.
    else.
*     Switch from creation to change mode
      if t180-tcode(5) eq 'VL01N'.
        t180-tcode = 'VL02N'.
      elseif t180-tcode eq 'VL31N'.
        t180-tcode = 'VL32N'.
      endif.
    endif.

*   Initialization for the 'new' Transaction code
    select single * from t180 where tcode = t180-tcode.
    if sy-subrc ne 0.
      message e015 with t180-tcode.
    endif.
    refresh cua_exclude.
    refresh taxi_inactive_fcodes.                           "v_n_574894
    perform exclude_function_trtyp.
  else.
    refresh cua_exclude.
    refresh taxi_inactive_fcodes.
    perform exclude_function_trtyp.                         "^_n_574894
  endif.

* Deactivate generic system services for current document
  perform wf_object_restore using likp-vbtyp                "v_n_533596
                                  likp-vbeln
                                  likp-lfart.               "^_n_533596

* Initialization for the new delivery document
  perform beleg_initialisieren.
* initialize output structure KOMKBE1 containing previous delivery
  ASSIGN ('(SAPLV61B)KOMKBE1') TO <ls_comm_area>           "v_n_1471318
                               CASTING TYPE komkbe1.
  IF sy-subrc = 0.
    CLEAR <ls_comm_area>.
  ENDIF.                                                   "^_n_1471318

  if t180-tcode cs 'VLPOD'.
    call function 'LE_POD_TVPOD_REFRESH'.
  endif.

* Initialize help workareas and tables
  refresh gt_ilips_main[].
  clear gs_ilips_main.
  clear gs_xlips_main.
  clear gs_lips_main.
  clear gf_loopc_main.
  clear gf_umfang_main.
  clear gf_tabix_zeile_1_main.

  refresh gt_ilips_chsp[].
  clear gs_ilips_chsp.
  clear gs_xlips_chsp.
  clear gs_lips_chsp.
  clear gf_loopc_chsp.
  clear gf_tabix_zeile_1_chsp.


* Foreign trade initializations
  call function 'RV_FOR_TRADE_PROTOCOL_INIT'
    exceptions
      others = 1.
  call function 'FT_SLS_PARTNER_ADDR_MEM_INIT'
    exporting
      i_base_document = '2LI'.

* Read delivery document
  likp-vbeln = lf_save_likp_vbeln.
  if lf_read_from_archive ne space.                         "v_n_574894
    perform read_delivery_from_archive using    likp-vbeln
                                                lf_erdat
                                       changing lf_subrc.
    if lf_subrc ne 0.
*     If delivery could not be retrieved from archive at least show
*     previous document
      message id sy-msgid type 'I' number sy-msgno
              display like 'E'
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*     exit if no previous document/delivery is available
      IF LF_OLD_LIKP_VBELN    IS INITIAL OR                 "v_n_993005
         LF_OLD_LIKP_VBELN(1) EQ CHAR$.                      "n_1105631
        leave to transaction sy-tcode.
      endif.                                                "^_n_993005
      if lf_v50agl_display_from_archive ne space.
        perform read_delivery_from_archive using    lf_old_likp_vbeln
                                                    lf_erdat
                                           changing lf_subrc.
        if lf_subrc ne 0.
          message id sy-msgid type 'A' number sy-msgno
                  with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        endif.
      else.
        likp-vbeln = lf_old_likp_vbeln.
        perform beleg_lesen_simple using likp-vbeln.        "n_943466
      endif.
    endif.
  else.
    perform beleg_lesen_simple using likp-vbeln.            "n_943466
  endif.                                                    "^_n_574894
  if t180-tcode cs 'VLPOD'.
    perform pod_segment_lesen.
  endif.
  perform xlips_umfang_setzen(sapfv50p) using tvlk-umfng.
  perform ilips_aufbauen(sapfv50p).

* Initialize callback handling for partner processing
  perform partner_initialize_callback.                      "HP_377171
  call function 'SD_WORD_PROCESSING_INIT'.                  "n_582099

* When a new document is read the transaction always starts on the
* item overview screen
  if t180-tcode cs 'VLPOD'.
    fcode = 'UPOD_T'.
  else.
    fcode = 'OVER_T'.
  endif.
  t185-bldgr  = t180-bldgr.
  t185-panel  = t180-panel.
  t185f-agidv = t180-agidv.
  modul-pool+3(5) = t180-agidv.
  t185f-trtyp = t180-trtyp.
  t185f-aktyp = t180-aktyp.
  case t180-trtyp.
    when chara.
      rv50a-txt_titcua = text-005.
    when charv.
      rv50a-txt_titcua = text-004.
  endcase.
  gf_process_view = gc_view_general.
* Check if templatematerial processing should be processed
  move-corresponding likp to i_dnact.
  call function 'EHS003_CHECK_TPPR_ACTIVE'
    exporting
      i_dnact     = i_dnact
      i_vbtyp     = likp-vbtyp
    exceptions
      tppr_active = 1
      others      = 2.

  if sy-subrc = 1.
* EH&S functionality is active
    v50agl-tppr_active = charx.
  endif.

  perform cua_exclude_static(sapmv50a).
  call function 'STACK_RESET'.
  perform call_badi_activate_tab_page(sapmv50a).
* Activate generic system services for new document
  perform wf_object_publish using likp-vbtyp                "v_n_533596
                                  likp-vbeln
                                  likp-lfart.               "^_n_533596
  perform fcode_anforderung.

* Do not process flow logic of current dynpro, just switch to PBO
* leave screen.                                             "HP_375327

* Build short form of address for display on overview screen
  perform build_address_dialog.                               "n_575199

  perform status_message_cm.                                  "n_539607

endform.                               "fcode_newd