*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_FCODE_ANZA                                        *
*----------------------------------------------------------------------*
* Form routine to switch between the change and the display mode

form fcode_anza.

  data: lf_docnumber(10) type c,
        lf_save_likp_vbeln type vbeln_vl,
        lf_save_posnr_chmult type posnr_vl,
        lf_save_chargensplitbild like v50agl-chargensplitbild,
        lf_user  type symsgv,                                 "n_557750
        lf_dynnr type i,
        lf_flag_exit type c,
        begin of lt_purchase occurs 0,
          vgbel type lips-vgbel,
          vgsys type lips-vgsys,                              "n_1392034
        end of lt_purchase,
        begin of lt_sales_order occurs 0,
          vgbel type lips-vgbel,
          vgsys type lips-vgsys,                              "n_1302592
        end of lt_sales_order,
        lf_textline1(50) type c,
        lf_textline2(50) type c,
        lf_title(50) type c,
        lf_answer type c,
        lt_enqueue like seqg3 occurs 0 with header line,
        lf_enqueue_arg like seqg3-garg,
        lf_enqueue_number like sy-tabix,
        lf_save_fcode type fcode,
        i_dnact like rdgdnact.

  field-symbols: <ls_xlips> type lipsvb,
                 <ls_ilips> type shp_ilips,
                 <ls_ilips_main> type shp_ilips.

* On the initial screen: LEAVE TO TRANSACTION must be performed
* At this point, screen sequence control is not yet initialized
  lf_dynnr = sy-dynnr.
  if lf_dynnr gt 4000.
    case t180-tcode.
      when 'VL02N'.
        leave to transaction 'VL03N'.
      when 'VL03N'.
        leave to transaction 'VL02N'.
      when 'VLODAR'.
        leave to transaction 'VLODAR'.
      when 'VL32N'.
        leave to transaction 'VL33N'.
      when 'VL33N'.
        leave to transaction 'VL32N'.
      when 'VLPOD'.
        leave to transaction 'VLPODA'.
      when 'VLPODA'.
        leave to transaction 'VLPOD'.
      when others.
        exit.
    endcase.
  endif.

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


* If current mode is 'change'...
  if t180-trtyp eq charv.

*   Check for authorisation
    authority-check object 'V_LIKP_VST'
                    id 'VSTEL' field likp-vstel
                    id 'ACTVT' field actvt_03.
    if sy-subrc ne 0.
      message i082 with likp-vstel.
      exit.
    endif.

*   Check for possible data loss
    if r185d-dataloss ne space.
      lf_textline1 = 'Lieferung &1 wurde verändert.'(064).
      lf_textline2 = 'Wollen Sie die Daten sichern?'(065).
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
          fcode = lf_save_fcode.
        when 'A'.
          exit.
        when 'N'.
          call function 'DEQUEUE_ALL'.
      endcase.
    else.
      call function 'DEQUEUE_ALL'.
    endif.

*   Dataloss flag not necessary in display mode.
    clear r185d-dataloss.
*   Set new internal transaction code
    if t180-tcode = 'VL32N'.
      t180-tcode = 'VL33N'.
    elseif t180-tcode = 'VL02N'.
      t180-tcode = 'VL03N'.
    elseif t180-tcode = 'VLPOD'.
      t180-tcode = 'VLPODA'.
    endif.

*   Initialization for the 'new' Transaction code
    select single * from t180 where tcode = t180-tcode.
    if sy-subrc ne 0.
      message e015 with t180-tcode.
    endif.
*   Set second parameter for the title
    rv50a-txt_titcua = text-005.
    refresh cua_exclude.
    perform exclude_function_trtyp.
    perform cua_exclude_static.

*   If current screen is the partner screen then it has to be
*   initialized again since display mode has been changed
    if taxi_panel eq 'HPAR'.
      perform prepare_partner_screen.
    endif.

*   Deadline screen must be prepared with new display mode
    clear v50agl-deadline_init.

*   Screen sequence control must be initialized with the new parameters
    call function 'LOCATION_EXTRACT'
      importing
        bild       = t185-panel
        bildgruppe = t185-bldgr.

    call function 'SCREEN_SEQUENCE_CONTROL_INIT'
      exporting
        bild            = t185-panel
        bildgruppe      = t185-bldgr
        funktion        = fcode_gleiche_seite
        kopfgruppe      = tvlk-kopgr
        positionsgruppe = tvlp-posgr
        programm        = 'SAPMV50A'
        typ             = t180-trtyp.

* If current mode is 'display'...
  elseif t180-trtyp eq chara.

*   Check for authorisation
    authority-check object 'V_LIKP_VST'
                    id 'VSTEL' field likp-vstel
                    id 'ACTVT' field actvt_02.
    if sy-subrc ne 0.
      message i081 with likp-vstel.
      exit.
    endif.

*   Store current document number and the item number for which the
*   batch split structure is shown
    lf_save_likp_vbeln = likp-vbeln.
    if xlips_umfang eq xlips_umfang_ucha.
      loop at xlips assigning <ls_xlips>
                    where chmult eq gc_batch_minus.
        lf_save_posnr_chmult = <ls_xlips>-posnr.
      endloop.
    endif.
    lf_save_chargensplitbild = v50agl-chargensplitbild.
*   Before changing anything try to block the deliveries and the sales
*   orders (or the purchase orders) belonging to the current delivery
*   1. Block delivery
    call function 'SHP_ENQUEUE_EVVBLKE'
      exporting
        vbeln             = likp-vbeln
      exceptions
        foreign_lock      = 1
        system_failure    = 2
        csl_no_connection = 3
        csl_inconsistency = 4
        others            = 5.
    case sy-subrc.
      when 0.
*       Check whether document is locked by calling application
        concatenate sy-mandt likp-vbeln into lf_enqueue_arg.
        call function 'ENQUEUE_READ'
          exporting
            gclient               = sy-mandt
            gname                 = 'LIKP'
            garg                  = lf_enqueue_arg
            guname                = sy-uname
          tables
            enq                   = lt_enqueue
          exceptions
            communication_failure = 1
            system_failure        = 2
            others                = 3.
        read table lt_enqueue index 1.
        lf_enqueue_number = lt_enqueue-gusetxt + lt_enqueue-gusevbt.
        if lf_enqueue_number gt 1.
          write likp-vbeln to lf_docnumber no-zero.
          write sy-uname to lf_user.
          message i046 with lf_docnumber lf_user.
          exit.
        endif.
      when 2.
        write likp-vbeln to lf_docnumber no-zero.
        write sy-msgv1 to lf_user.
        message i046 with lf_docnumber lf_user.
        exit.
      when 3.
        message i047.
        exit.
      when others.
        message id sy-msgid type 'I' number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        exit.
    endcase.

*   2. Extract preceding document numbers
    loop at xlips assigning <ls_xlips>
                  where updkz ne updkz_delete.
      check not <ls_xlips>-vgbel is initial.
      if <ls_xlips>-vgtyp eq charv.
        lt_purchase-vgbel = <ls_xlips>-vgbel.
        lt_purchase-vgsys = <ls_xlips>-vgsys.                 "n_1392034
        collect lt_purchase.
      else.
        lt_sales_order-vgbel = <ls_xlips>-vgbel.
        lt_sales_order-vgsys = <ls_xlips>-vgsys.              "n_1302592
        collect lt_sales_order.
      endif.
    endloop.

*   3. Block purchase orders
    clear lf_flag_exit.
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
          write sy-msgv1 to lf_user.
          message i247 with lt_purchase-vgbel lf_user.
          lf_flag_exit = charx.
          call function 'SHP_DEQUEUE_EVVBLKE'               "v_n_1674159
               exporting
               vbeln           = likp-vbeln.                "^_n_1674159

          exit.
        when 3.
          message i047.
          lf_flag_exit = charx.
          exit.
      endcase.
      if lt_purchase-vgsys is initial.                       "n_1392034
*     Check if the document is on the database             "v_n_1169039
        select single * from EKKO where ebeln = lt_purchase-vgbel.
        if sy-subrc ne 0.
          call function 'DEQUEUE_ALL'.
          message s650(vl) with lt_purchase-vgbel.
          lf_flag_exit = charx.
          exit.
        endif.                                             "^_n_1169039
      endif.                                                 "n_1392034
    endloop.
    if lf_flag_exit ne space.
      exit.
    endif.

*   4. Block sales orders
    clear lf_flag_exit.
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
          lf_flag_exit = charx.
          call function 'SHP_DEQUEUE_EVVBLKE'               "v_n_1417234
               exporting
               vbeln           = likp-vbeln.                "^_n_1417234
          exit.
        when 3.
          message i047.
          lf_flag_exit = charx.
          exit.
      endcase.
      if lt_sales_order-vgsys is initial.                    "n_1302592
*     Check if the document is on the database             "v_n_1169039
        select single * from VBAK where vbeln = lt_sales_order-vgbel.
        if sy-subrc ne 0.
          call function 'DEQUEUE_ALL'.
          message s303(vl) with lt_sales_order-vgbel.
          lf_flag_exit = charx.
          exit.
        endif.                                             "^_n_1169039
      endif.                                                 "n_1302592
    endloop.
    if lf_flag_exit ne space.
      exit.
    endif.

*   All documents could be blocked successfully: set new transaction cd.
    if t180-tcode = 'VL33N'.
      t180-tcode = 'VL32N'.
    elseif t180-tcode = 'VL03N'.
      t180-tcode = 'VL02N'.
    elseif t180-tcode = 'VLPODA'.
      t180-tcode = 'VLPOD'.
    endif.

*   Initialization for the 'new' Transaction code
    perform beleg_initialisieren.

*   Reset delivery buffer                                   "v_n_614505
    call function 'LE_DELIVERY_REFRESH_BUFFER'
      exporting
        if_vbeln         = lf_save_likp_vbeln
      exceptions
        no_key_specified = 0
        others           = 0.                               "^_n_614505

    call function 'SD_WORD_PROCESSING_INIT'.

*   Foreign trade initializations
    call function 'RV_FOR_TRADE_PROTOCOL_INIT'
      exceptions
        others = 1.
    call function 'FT_SLS_PARTNER_ADDR_MEM_INIT'
      exporting
        i_base_document = '2LI'.

*   Initialization for the 'new' Transaction code
    select single * from t180 where tcode = t180-tcode.
    if sy-subrc ne 0.
      message e015 with t180-tcode.
    endif.
*   Set second parameter for the title
    rv50a-txt_titcua = text-004.

*   Screen sequence control must be initialized with the new parameters
    call function 'LOCATION_EXTRACT'
      importing
        bild       = t185-panel
        bildgruppe = t185-bldgr.

    call function 'SCREEN_SEQUENCE_CONTROL_INIT'
      exporting
        bild            = t185-panel
        bildgruppe      = t185-bldgr
        funktion        = fcode_gleiche_seite
        kopfgruppe      = tvlk-kopgr
        positionsgruppe = tvlp-posgr
        programm        = 'SAPMV50A'
        typ             = t180-trtyp.

*   Re-read delivery document
    likp-vbeln = lf_save_likp_vbeln.
    perform beleg_lesen_simple using likp-vbeln.            "n_943466

*   Re-fill navigation tables with re-read data          "v_n_1079145
    if not gs_lips_main is initial.
      read table xlips with key vbeln = gs_lips_main-vbeln
                                posnr = gs_lips_main-posnr.
      move-CORRESPONDING xlips to gs_lips_main.
      move xlips to gs_xlips_main.
    endif.
    if not gs_lips_chsp is initial.
      read table xlips with key vbeln = gs_lips_chsp-vbeln
                                posnr = gs_lips_chsp-posnr.
      move-CORRESPONDING xlips to gs_lips_chsp.
      move xlips to gs_xlips_chsp.
    endif.                                                 "^_n_1079145

*   Disable certain function codes depending on the document status
    refresh cua_exclude.
    perform exclude_function_trtyp.
    perform cua_exclude_static.

*   Set item numer for which the batch split structure is shown
    if xlips_umfang eq xlips_umfang_ucha.
      xlips-posnr = lf_save_posnr_chmult.
    endif.
    perform ilips_aufbauen(sapfv50p).

*   Initialize callback handling for partner processing
    perform partner_initialize_callback.

*   Check whether toggle function is released on a item detail screen
*   or the navigation was performed through an item detail screen
    if not gt_ilips_main[] is initial.
      loop at gt_ilips_main assigning <ls_ilips_main>.
        read table ilips assigning <ls_ilips>
                         with key posnr = <ls_ilips_main>-posnr
                         binary search.
        if sy-subrc eq 0.
          <ls_ilips>-selkz = <ls_ilips_main>-selkz.
        endif.
      endloop.
      refresh gt_ilips_main.
      gt_ilips_main[] = ilips[].

*     Refresh table of items already visited
      refresh gt_wlips_main.

*     Current item has to be prepared for being displayed
*     (Get workareas XLIPS, LIPS, ILIPS)
      read table ilips with key gs_lips_main-posnr
                       binary search.
      perform read_item_and_mark(sapfv50p) tables gt_wlips_main.

*     If toggle function has been released on the batch split screen...
      if lf_save_chargensplitbild ne space.
        perform xlips_chsp_nd(sapfv50p).
*       Toggle function has been released on a batch item detail...
        if taxi_screen_group(1) eq c_taxi_scrgrp_batch(1).
          perform xlips_i0_to_c0_chsp(sapfv50p).
        endif.
      endif.

    endif.

*   If current screen is the partner screen then it has to be
*   initialized again since display mode has been changed
    if taxi_panel eq 'HPAR'.
      perform prepare_partner_screen.
    endif.

*   Build short form of address for display on overview screen
    perform build_address_dialog.                       "n_575199

    perform status_message_cm.                          "n_539607

  endif.

endform.                    "fcode_anza