***********************************************************************
*  Unterroutinen RV-Versand alphabetisch sortiert:                    *
*  -----------------------------------------------                    *
*  Buchstabe D:                                                       *
*                                                                     *
***********************************************************************


*---------------------------------------------------------------------*
*       FORM D031T_SELECT                                             *
*---------------------------------------------------------------------*
*       Lesen der Dictionary-Tabelle D301T: Fcodes                    *
*---------------------------------------------------------------------*
*  -->  DS_FCODE       Funktionscode                                  *
*  <--  D301T-LONGTEXT Text zum Funktionscode                         *
*---------------------------------------------------------------------*

form d301t_select using value(ds_fcode) type cua_code.

  data: cua_long(20).

  call function 'CUABUFFER_READ'
    exporting
      function = ds_fcode
    importing
      l_text   = cua_long
    exceptions
      others   = 01.
  if sy-subrc gt 0.
    message e328 with ds_fcode.
  endif.
  rv50a-ltext = cua_long.

endform.                    "d301t_select
*eject
*&---------------------------------------------------------------------*
*&      Form  DLFLD_DATA_READ   (4.0C WMS)
*&---------------------------------------------------------------------*
*       Read DLFLD data for the delivery
*----------------------------------------------------------------------*
form dlfld_data_read tables ct_dlfld structure dlfld
                     using  if_handle like likp-handle.

  data: ls_dlfld_key type v50b_dlfld_key_s,
        lt_dlfld_key type v50b_dlfld_key_t.

  ls_dlfld_key-handle_obj = likp-handle.
  append ls_dlfld_key to lt_dlfld_key.

  call function 'SHP_DLFLD_GET_COMPLETE'
    exporting
      it_dlfld_key = lt_dlfld_key
    tables
      ct_dlfld     = ct_dlfld.

endform.                               " DLFLD_DATA_READ
*&---------------------------------------------------------------------*
*&      Form  delivery_schedule_data (HP_373580)
*&---------------------------------------------------------------------*
*       Read forecast delivery schedule data for current item
*----------------------------------------------------------------------*
form delivery_schedule_data using    if_vgbel like lips-vgbel
                                     if_vgpos like lips-vgpos
                                     if_abart like lips-abart
                            changing cf_vblb  like vblb.

  data: lf_vblbvb like vblbvb.

  if not cf_vblb is initial    and
     cf_vblb-vbeln eq if_vgbel and
     cf_vblb-posnr eq if_vgpos and
     cf_vblb-abart eq if_abart.
    exit.
  endif.

  call function 'SD_VBLB_SELECT'
    exporting
      i_document_number = if_vgbel
      i_item_number     = if_vgpos
      i_type            = if_abart
    importing
      e_vblb            = lf_vblbvb.

  if not lf_vblbvb is initial.
    move-corresponding lf_vblbvb to cf_vblb.
  else.
    clear cf_vblb.
  endif.

endform.                               " delivery_schedule_data
*&---------------------------------------------------------------------*
*&      Form  date_consistency_check (470)
*&---------------------------------------------------------------------*
*       If the APO is connected the material availability date of all
*       items must not be later than the delivery date.
*----------------------------------------------------------------------*
form date_consistency_check
     using    if_complete_check type c             "check all items?
              if_posnr          like lips-posnr    "relevant if single
              if_mbdat          like lips-mbdat    "item is to be
              if_mbuhr          like lips-mbuhr    "checked
     changing cf_subrc          like sy-subrc.

  data: lf_tzone_we        like ttzz-tzone,
        lf_tzone_sp        like ttzz-tzone,
        lf_lfdat_sp        like likp-lfdat,
        lf_lfuhr_sp        like likp-lfuhr,
        lf_mbdat           like lips-mbdat,
        lf_mbuhr           like lips-mbuhr,
        lf_posnr           like lips-posnr,
        lf_timestamp_mbdat type timestamp,
        lf_timestamp_lfdat type timestamp,
        lf_posnr_txt       like sy-msgv1,
        lf_date_txt        like sy-msgv1,
        lf_time_txt        like sy-msgv1,
        lf_tzone_txt       like sy-msgv1,
        lf_msgv1           like sy-msgv1,
        lf_msgv2           like sy-msgv2,
        lf_msgty           like sy-msgty value 'W',
        lf_rcode           like sy-subrc,
        lf_msgtxt          type c.

  field-symbols: <ls_xlips> like line of xlips.

  cf_subrc = 0.

  check likp-vbtyp ca vbtyp_lief.

* Perform check only if APO plug-in is active to ensure a maximum of
* backward compatibility (existence of PI is necessary but not
* sufficient)
  call function 'ND_EXITS_ACTIVE_CHECK'
    exceptions
      exits_not_active = 1
      others           = 2.

  check sy-subrc eq 0.

* Determine time zone of ship-to party
  read table xvbpa with key vbeln = likp-vbeln
                            posnr = posnr_low
                            parvw = parvw_we.
  if sy-subrc ne 0.
    exit.
  endif.
  call function 'SD_TZONE_CUSTOBJECT'
    exporting
      adrnr              = xvbpa-adrnr
      country            = kuwev-land1
      region             = kuwev-regio
    changing
      timezone           = lf_tzone_we
    exceptions
      invalid_parameters = 0
      missing_parameters = 0
      others             = 0.

* Determine time zone of the shipping-point
  call function 'SD_TZONE_CUSTOBJECT'
    exporting
      country            = tvst-aland
      adrnr              = tvst-adrnr
    changing
      timezone           = lf_tzone_sp
    exceptions
      invalid_parameters = 0
      missing_parameters = 0
      others             = 0.

* Convert delivery date to UTC time zone
  convert date likp-lfdat time likp-lfuhr
          into time stamp lf_timestamp_lfdat
          time zone lf_tzone_we.

  if if_complete_check ne space.
*   Check of all items is requested
    loop at xlips assigning <ls_xlips>
                  where vbeln eq likp-vbeln
                    and updkz ne updkz_delete.

*     Check whether LIPS-MBDAT is not initial
      if <ls_xlips>-mbdat is initial.
        lf_posnr = <ls_xlips>-posnr.
        cf_subrc = 8.
        exit.
      endif.

*     Convert material availability date to UTC time zone
*     and compare with converted delivery date
      convert date <ls_xlips>-mbdat time <ls_xlips>-mbuhr
              into time stamp lf_timestamp_mbdat
              time zone lf_tzone_sp.

      if lf_timestamp_mbdat gt lf_timestamp_lfdat.
        lf_posnr = <ls_xlips>-posnr.
        lf_mbdat = <ls_xlips>-mbdat.
        lf_mbuhr = <ls_xlips>-mbuhr.
        cf_subrc = 4.
        exit.
      endif.

    endloop.

  else.
*   Check MBDAT and MBUHR only for requested item
    do 1 times.

*     Check whether LIPS-MBDAT is not initial
      if if_mbdat is initial.
        lf_posnr = if_posnr.
        cf_subrc = 8.
        exit.
      endif.

      convert date if_mbdat time if_mbuhr
              into time stamp lf_timestamp_mbdat
              time zone lf_tzone_sp.

      if lf_timestamp_mbdat gt lf_timestamp_lfdat.
        lf_posnr = if_posnr.
        lf_mbdat = if_mbdat.
        lf_mbuhr = if_mbuhr.
        cf_subrc = 4.
      endif.

    enddo.

  endif.

  if cf_subrc ne 0.
*   Determine type of message (default is 'W' warning)
    perform message_steuerung using  gs_mhpar
                                     v50agl-msgvs
                                     'VL'
                                     '394'
                            changing lf_msgty
                                     lf_rcode.
*   Exit if no message desired
    if lf_msgty eq space.
      cf_subrc = 0.
      exit.
    endif.

*   Prepare message output
    write lf_posnr to lf_posnr_txt no-zero left-justified.
    condense lf_posnr_txt.

    case cf_subrc.
      when 4.
        write: lf_mbdat dd/mm/yyyy to lf_date_txt,
               lf_mbuhr(4) using edit mask '__:__'
                                   to lf_time_txt.
        concatenate '(' lf_tzone_sp ')' into lf_tzone_txt.
        concatenate lf_date_txt lf_time_txt lf_tzone_txt
                    into lf_msgv1
                    separated by space.

        convert time stamp lf_timestamp_lfdat
                time zone lf_tzone_sp
                into date lf_lfdat_sp time lf_lfuhr_sp.
        write: lf_lfdat_sp dd/mm/yyyy to lf_date_txt,
               lf_lfuhr_sp(4) using edit mask '__:__'
                              to lf_time_txt.
        concatenate '(' lf_tzone_we ')' into lf_tzone_txt.

        concatenate lf_date_txt lf_time_txt lf_tzone_txt
                    into lf_msgv2
                    separated by space.

*       Fill SYST fields for external message handling
        message id 'VL' type lf_msgty number '394'
                with lf_posnr_txt lf_msgv1 lf_msgv2
                into lf_msgtxt.
      when 8.
        message id 'VL' type lf_msgty number '401'
                with lf_posnr_txt
                into lf_msgtxt.
    endcase.


  endif.

endform.                    " date_consistency_check

*&---------------------------------------------------------------------*
*&      Form  deliver_purchase_order
*&---------------------------------------------------------------------*
form deliver_purchase_order.

  data: lt_wueb       type standard table of wueb,
        ls_wueb       like wueb,
        lt_komdlgn    type standard table of komdlgn with header line,
        lt_errors     type standard table of wuebs,
        ls_errors     like wuebs,
        ls_lfa1       type lfa1,
        lf_selscreen  type c,
        lf_likp_lines like sy-tfill,
        lf_ibtyp      like t163d-ibtyp,
        lf_subrc      like sy-subrc,
        lv_sit_flag   type xfeld.                             "n_1576541

ENHANCEMENT-POINT mv50af0d_02 SPOTS es_sapmv50a STATIC.
  check fcode(4) ne fcode_fehlerprotokoll
    and fcode(4) ne fcode_abbrechen
    and fcode(4) ne fcode_ende
    and fcode ne 'VL32_T'
    and fcode ne 'VL33_T'
    and fcode ne 'VL06I_T'.

* Vendor or PO number are mandatory
  if likp-lifnr is initial  and
     lv50c-bstnr is initial and
     fcode ne 'BESE_T'.
    message e138.
  endif.

* Determine delivery type from confirmation control
  lf_ibtyp = '2'.
  if cl_ops_switch_check=>mm_sfws_sit( ) is not initial.    "n_v_1576541
    lv_sit_flag = cl_mm_im_sit_info=>get_sit_info_weora(
                                     iv_ebeln = lv50c-bstnr ).
  endif.
  call function 'ME_CONFIRMATION_DELIVERY_TYPE'
    exporting
      i_func              = '1'
      iv_sit              = lv_sit_flag                     "n_^_1576541
    changing
      c_ibtyp             = lf_ibtyp
      c_lfart             = likp-lfart
    exceptions
      function_not_valid  = 1
      param_value_missing = 2
      no_item_found       = 3.

  if sy-subrc eq 0.
    if likp-lfart eq space.
      message e665 with '2'.
    endif.
  else.
    message e664 with '2'.
  endif.

  perform tvlk_select using likp-lfart
                            charx
                            lf_subrc.
  if tvlk-vbtyp ne '7'.
    message e227 with tvlk-lfart.
  endif.

* Check vendor
  if not likp-lifnr is initial.
    select single * from lfa1
           into ls_lfa1
           where lifnr eq likp-lifnr.
    if sy-subrc ne 0.
      message e140 with likp-lifnr.
    endif.
  endif.

* Transfer data from dynpro structure to LIKP
  likp-lfdat = rv50a-lfdat_la.
  likp-lfuhr = rv50a-lfuhr_la.
  likp-verur = rv50a-verur_la.
  likp-lifex = rv50a-verur_la.

ENHANCEMENT-POINT mv50af0d_04 SPOTS es_sapmv50a STATIC.


ENHANCEMENT-POINT mv50af0d_03 SPOTS es_sapmv50a.


* Select purchase orders if necessary
  if not lv50c-bstnr is initial and
     fcode ne 'BESE_T'.
    ls_wueb-ebeln = lv50c-bstnr.
    append ls_wueb to lt_wueb.
  else.
    if fcode eq 'BESE_T'.
      lf_selscreen = space.
      clear fcode.
    else.
      lf_selscreen = charx.
    endif.
    perform select_purchase_orders tables   lt_wueb
                                   using    likp-lifnr
                                            lf_selscreen
                                   changing lf_subrc.
    if lf_subrc ne 0.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    endif.
  endif.

* Fill interface table KOMDLGN with PO data
  call function 'ME_CONFIRMATION_READ_AVIS'
    exporting
      ldate  = likp-lfdat
    tables
      t_kom  = lt_komdlgn
      t_wueb = lt_wueb
      errors = lt_errors.

  if lt_komdlgn[] is initial.
    message e148.
  endif.

* Add own data to interface table KOMDLGN
  loop at lt_komdlgn.
    lt_komdlgn-lfart = likp-lfart.
    lt_komdlgn-auart = tvlk-daart.
    lt_komdlgn-vgtyp = 'V'.
    lt_komdlgn-lfdat = likp-lfdat.
    lt_komdlgn-lfuhr = likp-lfuhr.
    lt_komdlgn-bolnr = likp-bolnr.
    lt_komdlgn-verur = likp-verur.
    lt_komdlgn-lifex = likp-verur.
    lt_komdlgn-traty = likp-traty.
    lt_komdlgn-traid = likp-traid.
    lt_komdlgn-kzazu = charx.
    modify lt_komdlgn.
  endloop.

* Call creation of inbound delivery via dialog module. This ensures that
* a different roll area is used for the delivery creation and that there
* is no interference between the dialog and the delivery creation
* through function group V50S. In contrast to the former construction
* where the delivery dialog is running in a dialog module
* (SD_LIEFERAVIS), the complete posting procedure now runs in the roll
* area of the dialog so that PERFORM ... ON COMMIT statements work as
* intended
* Note that the flag KZ_LIEFERAVIS is NOT set. Use T180-TCODE if you
* need to know that you are in the creation mode via VL31N
  call dialog 'LE_INBOUND_DELIVERY_CREATE'
    exporting
      ckomdlgn from lt_komdlgn
    importing
      cvbfs    to cvbfs
      cvbls    to cvbls
      xlikp    to xlikp
      xlips    to xlips
      xvbfa    to xvbfa
      xvbpa    to xvbpa
      xvbuk    to xvbuk
      xvbup    to xvbup
      xvbuv    to xvbuv
      yvbuk    to yvbuk
      yvbup    to yvbup.

* Error log from purchase order (delivery completed for certain items)
  loop at lt_errors into ls_errors
                    where msgid eq 'ME'
                      and msgno eq '632'.
    clear cvbfs.
    cvbfs-vbeln = ls_errors-ebeln.
    cvbfs-posnr = ls_errors-ebelp.
    cvbfs-msgid = ls_errors-msgid.
    cvbfs-msgno = ls_errors-msgno.
    cvbfs-msgty = ls_errors-msgty.
    cvbfs-msgv1 = ls_errors-msgv1.
    cvbfs-msgv2 = ls_errors-msgv2.
    cvbfs-msgv3 = ls_errors-msgv3.
    cvbfs-msgv4 = ls_errors-msgv4.
    append cvbfs.
  endloop.

* If no delivery could be created switch to the error log otherwise
* call the item overview
  if xlikp[] is initial.
    message s141.
    fcode = 'FEAZ_T'.
    exit.
  else.
    fcode = 'OVER_T'.
  endif.

* Write number of created deliveries to the log
  describe table xlikp lines lf_likp_lines.
  if lf_likp_lines gt 1.
    clear cvbfs.
    cvbfs-vbeln = space.
    cvbfs-posnr = space.
    cvbfs-msgid = 'VL'.
    cvbfs-msgno = '142'.
    cvbfs-msgty = 'I'.
    write lf_likp_lines to cvbfs-msgv1 left-justified.
    condense cvbfs-msgv1.
    insert cvbfs index 1.
  endif.

* Erweiterung für Cross-docking mit prepacking
* in Enhancement Spot ES_ME_IBD_SPLIT_WMD
  data: gv_me_ibd_split_wmd type ref to me_ibd_split_wmd.
  try.
      get badi gv_me_ibd_split_wmd.
      call badi gv_me_ibd_split_wmd->save_messages
        changing
          ct_message = lt_errors[]
          ct_vbfs    = cvbfs[].
    catch cx_badi_not_implemented.                      "#EC NO_HANDLER
*...no implementation found
  endtry.

  r185d-dataloss = charx.

ENHANCEMENT-POINT mv50af0d_08 SPOTS es_sapmv50a STATIC.


ENHANCEMENT-POINT mv50af0d_01 SPOTS es_sapmv50a.


* Prepare processing of the first created delivery in the dialog
  perform lieferavis_vorbereiten.

* Hint to the error log
  if not cvbfs[] is initial.
    message s016.
  endif.

endform.                    " deliver_purchase_order
*&---------------------------------------------------------------------*
*&      Form  delete_delivery_items_dialog (n_521409)
*&---------------------------------------------------------------------*
form delete_delivery_items_dialog.

  data: lt_admin    type standard table of shp_del_admin,
        ls_admin    type shp_del_admin,
        lf_subrc    like sy-subrc,
        lf_tabix    like sy-tabix,
        lf_dependent_items  type c,
        lf_save_clips_posnr like lips-posnr,
        lt_reasons  type standard table of shp_del_reason
                         with header line.

* Check function code 'Delete marked items' is active
  check fcode(4) = fcode_xlips_loeschen_einzeln.

* If deletion is performed on the batch split screen save main item
* number
  if v50agl-chargensplitbild ne space.
    lf_save_clips_posnr = clips-posnr.
  endif.

* Check marked items for deletion
  perform delete_items_check tables   lt_admin
                                      lt_reasons
                             changing lf_dependent_items.

* Check violation of the complete delivery condition
  perform delete_items_compl_del tables lt_admin
                                        lt_reasons.

* Check for incompletely deleted delivery groups            "v_n_587009
  perform delete_items_del_group tables lt_admin
                                        lt_reasons.         "^_n_587009

* User decision for the check results
  perform delete_items_results tables   lt_admin
                                        lt_reasons
                               using    space               "n_645416
                               changing lf_subrc.
  if lf_subrc ne 0.
    exit.
  endif.

* Start physical deletion of delivery items
  perform delete_items_exceute tables lt_admin
                                      lt_reasons.

* Restore table ILIPS depending on the screen where the deletion
* started; restore CLIPS if necessary
  if v50agl-chargensplitbild eq space.
    if tvlk-umfng = 'UHAU'.                                 "v_n_661495
      xlips_umfang = xlips_umfang_uhau.
    else.                                                   "^_n_661495
      xlips_umfang = xlips_umfang_uall.
    endif.                                                  "n_661495
    perform ilips_aufbauen(sapfv50p).
  else.
    perform xlips_lesen_direkt(sapfv50p) using    lf_save_clips_posnr
                                         changing lf_tabix.
    clips = xlips.
    perform ilips_aufbauen_struktur_chsp(sapfv50p) using clips-posnr.
  endif.

* Issue message if dependent items were deleted
  if lf_dependent_items ne space.
    message s179 display like 'W'.
  endif.

endform.                        "delete_delivery_items_dialog

*&---------------------------------------------------------------------*
*&      Form  move_resaons_to_cvbfs (n_521409)
*&---------------------------------------------------------------------*
*       This form translates the reason codes in table IT_REASONS into
*       messages for the error log. The reason codes are taken from
*       XLIPS_LOESCHEN_PRUEFEN.
*----------------------------------------------------------------------*
form move_reasons_to_cvbfs tables it_reasons structure shp_del_reason.

  data: lf_msgtxt        type c,
        lf_tabix         like sy-tabix,
        lf_lstanr        like sy-msgv1,                     "n_571048
        lf_posnr_txt(6)  type c,
        lf_quan_text(15) type c.

  field-symbols: <ls_xvbap> like line of xvbap.             "n_571048

  sort it_reasons by posnr reason.
  refresh cvbfs.

  loop at it_reasons.
    at new posnr.
      perform xlips_lesen_direkt(sapfv50p) using    it_reasons-posnr
                                           changing lf_tabix.
      write xlips-posnr to lf_posnr_txt no-zero.
      condense lf_posnr_txt.
    endat.
    case it_reasons-reason.
      when chara.
        message id 'VL' type it_reasons-msgty
                number '108'
                with lf_posnr_txt into lf_msgtxt.
      when charb.
        message id 'VL' type it_reasons-msgty
                number '109'
                with lf_posnr_txt into lf_msgtxt.
      when charc.
        message id 'VL' type it_reasons-msgty
                number '110'
                with lf_posnr_txt into lf_msgtxt.
      when chard.
        message id 'VL' type it_reasons-msgty
                number '111'
                with lf_posnr_txt into lf_msgtxt.
      when chare.
        message id 'VL' type it_reasons-msgty
                number '122'
                with lf_posnr_txt into lf_msgtxt.
      when charf.
        message id 'VL' type it_reasons-msgty
                number '617'
                with lf_posnr_txt into lf_msgtxt.
      when charg.
        message id 'VL' type it_reasons-msgty
                number '223'
                with lf_posnr_txt into lf_msgtxt.
      when charh.
        if xlips-kzfme ca kzfme_ws.
          write xlips-kcmengvme to lf_quan_text unit xlips-vrkme.
          condense lf_quan_text.
          message id 'VL' type it_reasons-msgty
                  number '224'
                  with lf_posnr_txt lf_quan_text xlips-vrkme
                  into lf_msgtxt.
        else.
          write xlips-kcmeng to lf_quan_text unit xlips-meins.
          condense lf_quan_text.
          message id 'VL' type it_reasons-msgty
                  number '224'
                  with lf_posnr_txt lf_quan_text xlips-meins
                  into lf_msgtxt.
        endif.
      when chari.
        message id 'VL' type it_reasons-msgty
                number '128'
                with xlips-qplos xlips-qtlos into lf_msgtxt.
      when charj.
        message id 'VL' type it_reasons-msgty
                number '219'
                with lf_posnr_txt into lf_msgtxt.
      when chark.
        write xlips-kcmeng to lf_quan_text unit xlips-meins.
        condense lf_quan_text.
        message id 'VL' type it_reasons-msgty
                number '224'
                with lf_posnr_txt lf_quan_text xlips-meins
                into lf_msgtxt.
      when charl.
        message id 'VL' type it_reasons-msgty
                number '164'
                into lf_msgtxt.
      when charm.
        if not it_reasons-msgid is initial and
           not it_reasons-msgno is initial.
          message id it_reasons-msgid type it_reasons-msgty
                  number it_reasons-msgno
                  with it_reasons-msgv1 it_reasons-msgv2
                       it_reasons-msgv3 it_reasons-msgv4
                  into lf_msgtxt.
        else.
          message id 'VL' type it_reasons-msgty
                  number '399'
                  into lf_msgtxt.
        endif.
      when charn.
        message id 'VL' type it_reasons-msgty
                number '444'
                with lf_posnr_txt into lf_msgtxt.
      when charo.
        message id 'VL' type it_reasons-msgty
                number '475'
                with lf_posnr_txt into lf_msgtxt.
      when charp.
        message id 'VL' type it_reasons-msgty
                number '173'
                with lf_posnr_txt into lf_msgtxt.
      when charq.                                           "v_n_542906
        message id 'VL' type it_reasons-msgty
                number '491'
                with lf_posnr_txt into lf_msgtxt.           "^_n_542906
      when charr.                                           "v_n_550349
        message id 'VL' type it_reasons-msgty
                number '494'
                with lf_posnr_txt into lf_msgtxt.           "^_n_550349
      when chars.                                           "v_n_571048
        read table xvbap assigning <ls_xvbap>
                         with key vbeln = xlips-vgbel
                                  posnr = xlips-vgpos.
        if sy-subrc eq 0.
          concatenate '''' <ls_xvbap>-lstanr '''' into lf_lstanr.
        else.
          clear lf_lstanr.
        endif.
        message id 'VL' type it_reasons-msgty
                number '271'
                with space lf_posnr_txt lf_lstanr
                into lf_msgtxt.                             "^_n_571048
      when charu.                                           "v_n_1224871
        message id 'VL' type it_reasons-msgty
                number '896' with xlips-posnr
                into lf_msgtxt.                             "^_n_1224871
      when charw.
        message id 'VL' type it_reasons-msgty
                number '049'
                into lf_msgtxt.
      when others.                                          "v_n_587009
        message id     it_reasons-msgid
                type   it_reasons-msgty
                number it_reasons-msgno
                with   it_reasons-msgv1
                       it_reasons-msgv2
                       it_reasons-msgv3
                       it_reasons-msgv4
                into   lf_msgtxt.                           "^_n_587009
    endcase.

    cvbfs-vbeln = xlips-vbeln.
    cvbfs-posnr = xlips-posnr.
    cvbfs-msgid = sy-msgid.
    cvbfs-msgno = sy-msgno.
    cvbfs-msgty = sy-msgty.
    cvbfs-msgv1 = sy-msgv1.
    cvbfs-msgv2 = sy-msgv2.
    cvbfs-msgv3 = sy-msgv3.
    cvbfs-msgv4 = sy-msgv4.
    append cvbfs.

  endloop.

endform.                    " move_reasons_to_cvbfs

*&---------------------------------------------------------------------*
*&      Form  delete_items_check (n_521409)
*&---------------------------------------------------------------------*
*       This form checks whether the items marked in table ILIPS can be
*       deleted. The result of the checks is reported via table
*       CT_ADMIN. Dependent subitems are taken into account. CT_REASONS
*       contains the reason codes for the non-deletable items (same
*       codes as in XLIPS_LOESCHEN_PRUEFEN)
*----------------------------------------------------------------------*
form delete_items_check
     tables   ct_admin           structure shp_del_admin
              ct_reasons         structure shp_del_reason
     changing cf_dependent_items type c.

  data: ls_admin    type shp_del_admin,
        ls_admin_ue type shp_del_admin,
        lf_exit     type c,
        lf_msgty    like sy-msgty,
        lf_subrc    like sy-subrc,
        lf_tabix    like sy-tabix,                          "n_587009
        lf_invoice_exists  type c,                          "n_550349
        lf_delete_flag     type c,                          "n_571048
        lf_uepos_check     type c.

  field-symbols: <ls_xlips> like line of xlips,
                 <ls_xvbfa> like line of xvbfa.             "n_550349

* Get all marked items
  loop at ilips where selkz eq selektiert.
    read table xlips assigning <ls_xlips>
                     index ilips-tabix.
    if sy-subrc eq 0.
      ls_admin-posnr = <ls_xlips>-posnr.
      ls_admin-uepos = <ls_xlips>-uepos.
      ls_admin-uecha = <ls_xlips>-uecha.
      ls_admin-grkor = <ls_xlips>-grkor.                    "n_587009
      append ls_admin to ct_admin.
    endif.
  endloop.

* Ignore further steps if nothing is marked
  check not ct_admin[] is initial.

  sort ct_admin by posnr.

* Add items that are dependent
  loop at xlips assigning <ls_xlips>
                where updkz ne updkz_delete.

    if not <ls_xlips>-uecha is initial.
      read table ct_admin into ls_admin_ue
                          with key posnr = <ls_xlips>-uecha
                          binary search.
      if sy-subrc eq 0.
*       Mark main item
        ls_admin_ue-batch_main = charx.
        modify ct_admin from ls_admin_ue index sy-tabix.
*       Main item of the batch split is marked for deletion, add batch
*       split item
        read table ct_admin with key posnr = <ls_xlips>-posnr
                            binary search
                            transporting no fields.
        if sy-subrc ne 0.
          ls_admin-posnr = <ls_xlips>-posnr.
          ls_admin-uepos = <ls_xlips>-uepos.
          ls_admin-uecha = <ls_xlips>-uecha.
          ls_admin-grkor = <ls_xlips>-grkor.                "n_587009
          insert ls_admin into ct_admin index sy-tabix.
        endif.
      endif.
    endif.

    if not <ls_xlips>-uepos is initial.
      read table ct_admin into ls_admin_ue
                          with key posnr = <ls_xlips>-uepos
                          binary search.
      if sy-subrc eq 0.
*       Mark main item
        ls_admin_ue-bom_main = charx.
        modify ct_admin from ls_admin_ue index sy-tabix.
*       Main item of the BOM is marked for deletion, add subitem
        read table ct_admin with key posnr = <ls_xlips>-posnr
                            binary search
                            transporting no fields.
        lf_tabix = sy-tabix.                                "n_587009
        if sy-subrc ne 0.
*         Additional check in case of free goods            "v_n_571048
          if <ls_xlips>-uepvw na gc_uepvw-check_lstanr.
            lf_delete_flag = charx.
          else.
            perform delete_free_goods_item_check
                    using    <ls_xlips>-posnr
                             <ls_xlips>-vgbel
                             <ls_xlips>-vgpos
                    changing lf_delete_flag.
            if lf_delete_flag ne space.
*             If dependent free goods item will be deleted send warning
*             message to log
              clear ct_reasons.
              ct_reasons-posnr  = <ls_xlips>-posnr.
              ct_reasons-reason = chars.
              ct_reasons-msgty  = 'W'.
              append ct_reasons.
            endif.
          endif.
          if lf_delete_flag ne space.
            ls_admin-posnr = <ls_xlips>-posnr.
            ls_admin-uepos = <ls_xlips>-uepos.
            ls_admin-uecha = <ls_xlips>-uecha.
            ls_admin-grkor = <ls_xlips>-grkor.              "v_n_587009
            insert ls_admin into ct_admin index lf_tabix.   "^_n_587009
          endif.                                            "^_n_571048
        endif.
      endif.
    endif.

  endloop.

* Check whether items are deletable
  loop at ct_admin into ls_admin.

    perform xlips_loeschen_pruefen(sapfv50p) tables   ct_reasons
                                             using    ls_admin-posnr
                                                      space
                                                      space
                                                      'GHK' "n_766525
                                             changing lf_exit.
    if lf_exit ne space.
      if not ls_admin-uecha is initial.
*       Ignore checks on existing batch split quantity
        delete ct_reasons where posnr eq ls_admin-posnr
                            and reason ca 'G'.
      endif.
      if ls_admin-batch_main ne space.
*       Ignore checks on existing batch split
        delete ct_reasons where posnr eq ls_admin-posnr
                            and reason ca 'HK'.
      endif.
*     Ignore errors due to SD picked items (control with output
*     properties of message VL173)
      delete ct_reasons where posnr eq ls_admin-posnr
                         and reason eq 'B'.
*     Are there remaining reasons to prevent deletion?
      read table ct_reasons with key posnr = ls_admin-posnr
                            transporting no fields.
      if sy-subrc ne 0.
        lf_exit = space.
      endif.
    endif.
*   Special check for picked quantity
    if xvbup-kosta ca 'BC' and                              "n_887085
       xvbup-lvsta ca ' C'.
*     Posting change item is not deletable if TO is confirmed
      if xvbup-lvsta     eq 'C' and                         "n_567666
         xlips-hupos     ca 'BC' and                        "n_928962
         xlips-gmcontrol eq 'A' and
         tvlk-aufer      ca 'OH'.                           "n_765219
        lf_msgty = 'E'.
      else.
        perform message_steuerung(sapmv50a) using    gs_mhpar
                                                     v50agl-msgvs
                                                     'VL'
                                                     '173'
                                            changing lf_msgty
                                                     lf_subrc.
      endif.                                                "n_567666
      if lf_msgty ne space.
*       At least add a warning to the error log
        clear ct_reasons.
        ct_reasons-posnr  = ls_admin-posnr.
        ct_reasons-reason = charp.
        ct_reasons-msgty  = lf_msgty.
        append ct_reasons.
        if lf_msgty eq 'E'.
*         Picking status prevents item from being deleted
          lf_exit = charx.
        endif.
      endif.
    endif.
*   Special check for subsequent billing documents          "v_n_550349
    if t180-trtyp eq charv and
       xlips-fkrel ne space.                                "n_572576
      clear lf_invoice_exists.
      read table xvbfa with key vbelv = likp-vbeln
                                posnv = ls_admin-posnr
                       binary search
                       transporting no fields.
      if sy-subrc eq 0.
        loop at xvbfa assigning <ls_xvbfa>
                      from sy-tabix.
          if <ls_xvbfa>-vbelv ne likp-vbeln or
             <ls_xvbfa>-posnv ne ls_admin-posnr.
            exit.
          endif.
          if <ls_xvbfa>-vbtyp_n ca vbtyp_fakt and
             <ls_xvbfa>-vbtyp_n na vbtyp_prof.              "n_572576
            lf_invoice_exists = charx.
            exit.
          endif.
        endloop.
      endif.
      if lf_invoice_exists ne space.
        lf_msgty = 'W'.
        perform message_steuerung(sapmv50a) using    gs_mhpar
                                                     v50agl-msgvs
                                                     'VL'
                                                     '494'
                                            changing lf_msgty
                                                     lf_subrc.
        if lf_msgty ne space.
*         At least add a warning to the error log
          clear ct_reasons.
          ct_reasons-posnr  = ls_admin-posnr.
          ct_reasons-reason = charr.
          ct_reasons-msgty  = lf_msgty.
          append ct_reasons.
          if lf_msgty eq 'E'.
*           Existing invoices prevent item from being deleted
            lf_exit = charx.
          endif.
        endif.
      endif.
    endif.                                                  "^_n_550349
    ls_admin-nondel = lf_exit.
    modify ct_admin from ls_admin.

  endloop.

ENHANCEMENT-POINT mv50af0d_05 SPOTS es_sapmv50a STATIC.

ENHANCEMENT-POINT mv50af0d_06 SPOTS es_sapmv50a.


* If one item of a batch split is not deletable the complete batch split
* can not be deleted; the same applies to a BOM
* Take into account that BOMs can be nested (recursion necessary)
  lf_uepos_check = charx.
  while ( lf_uepos_check ne space ).
    lf_uepos_check = space.
    loop at ct_admin into ls_admin
                     where nondel ne space.

      if not ls_admin-uecha is initial.
*       Mark the main item as not deletable
        read table ct_admin into ls_admin_ue
                            with key posnr = ls_admin-uecha
                            binary search.
        if sy-subrc eq 0 and ls_admin_ue-nondel eq space.
          ls_admin_ue-nondel = charx.
          modify ct_admin from ls_admin_ue index sy-tabix.
        endif.
      endif.

      if not ls_admin-uepos is initial.
*       Mark the main item as not deletable
        read table ct_admin into ls_admin_ue
                            with key posnr = ls_admin-uepos
                            binary search.
        if sy-subrc eq 0 and ls_admin_ue-nondel eq space.
          ls_admin_ue-nondel = charx.
          modify ct_admin from ls_admin_ue index sy-tabix.
          lf_uepos_check = charx.
        endif.
      endif.

    endloop.
  endwhile.

* The main items are now marked as non-deletable, transfer the flag to
* all dependent items
  loop at ct_admin into ls_admin_ue
                   where nondel ne space
                     and ( batch_main ne space or
                           bom_main   ne space ).

    if ls_admin_ue-batch_main ne space.
      loop at ct_admin into ls_admin
                       where uecha  eq ls_admin_ue-posnr
                       and   nondel eq space.
        ls_admin-nondel = charx.
        modify ct_admin from ls_admin.
      endloop.
    endif.

    if ls_admin_ue-bom_main ne space.
      loop at ct_admin into ls_admin
                       where uepos  eq ls_admin_ue-posnr
                       and   nondel eq space.
        ls_admin-nondel = charx.
        modify ct_admin from ls_admin.
      endloop.
    endif.

  endloop.

* Check whether dependent items are to be deleted
  loop at ct_admin transporting no fields
                   where ( bom_main ne space or
                           batch_main ne space )
                     and nondel eq space.
    cf_dependent_items = charx.
    exit.
  endloop.

endform.                    " delete_items_check

*&---------------------------------------------------------------------*
*&      Form  delete_items_results (n_521409)
*&---------------------------------------------------------------------*
*       Sends a user dialog depending on the results of the deletion
*       checks.
*----------------------------------------------------------------------*
form delete_items_results
     tables   ct_admin   structure shp_del_admin
              ct_reasons structure shp_del_reason
     using    if_nopopup type xfeld                         "n_645416
     changing cf_subrc   like sy-subrc.

  data: lf_status   type c,
        lf_answer   type c,
        lf_textline1(40)   type c,
        lf_textline2(40)   type c.

  cf_subrc = 0.

* Reaction depending on the status of the checks
  loop at ct_admin transporting no fields
                   where nondel ne space.
    exit.
  endloop.
  if sy-subrc eq 0.
    loop at ct_admin transporting no fields
                     where nondel eq space.
      exit.
    endloop.
    if sy-subrc ne 0.
*     All items are not deletable
      lf_status = 'A'.
    else.
*     Some items are not deletable
      lf_status = 'B'.
    endif.
  else.
*   All items deletable, but warnings in the error log
    if not ct_reasons[] is initial.
      lf_status = 'C'.
    endif.
  endif.

  case lf_status.
    when 'A'.
      message s482 display like 'E'.
      perform move_reasons_to_cvbfs tables ct_reasons.
      fcode = 'FEAZ_T'.
      cf_subrc = 4.
    when 'B' or 'C'.
      perform move_reasons_to_cvbfs tables ct_reasons.
      if sy-batch is initial and                            "n_900016
         sy-binpt is initial and                            "n_900016
         if_nopopup is initial and                          "v_n_645416
         v50agl-dialog eq charx.                            "n_837032
        if lf_status eq 'B'.
*         "Not all items are deletable"
*         "Delete deletable items?"
          lf_textline1 = text-090.
          lf_textline2 = text-091.
        else.
*         "Warnings exist"
*         "Delete items anyway?"
          lf_textline1 = text-092.
          lf_textline2 = text-093.
        endif.
        call function 'POPUP_TO_DECIDE'
          exporting
            defaultoption     = '2'
            textline1         = lf_textline1
            textline2         = lf_textline2
            text_option1      = text-094 "Delete"
            text_option2      = text-095 "Error log"
            icon_text_option1 = '@11@'   "ICON_DELETE
            icon_text_option2 = '@DR@'   "ICON_ERROR_PROTOCOL
            titel             = text-096 "Delete items"
            cancel_display    = 'X'
          importing
            answer            = lf_answer.
        case lf_answer.
          when '1'.
            cf_subrc = 0.  "continue deletion procedure
          when '2'.
            fcode = 'FEAZ_T'.
            cf_subrc = 8.  "cancel deletion procedure; show error log
          when others.
            cf_subrc = 12. "cancel deletion procedure
        endcase.
      else.
        if lf_status eq 'B'.                                "n_705611
          cf_subrc = 12. "cancel deletion procedure
        endif.                                              "n_705611
      endif.                                         "^_n_645416/"n_900016
  endcase.

endform.                    " delete_items_results

*&---------------------------------------------------------------------*
*&      Form  delete_items_exceute (n_521409)
*&---------------------------------------------------------------------*
*       Performs the deletion of the items in table CT_ADMIN.
*       Note that table ILIPS is changed and must be restored by the
*       caller!
*----------------------------------------------------------------------*
form delete_items_exceute
     tables ct_admin structure shp_del_admin
            ct_reasons structure shp_del_reason.

  data: ls_admin                 type shp_del_admin,
        lf_counter               like sy-tabix,
        lf_subrc                 like sy-subrc,
        lf_old_uecha             like lips-uecha,
        lf_save_panel            like t185v-panel,
        lf_quan_no_check         like v50agl-quan_no_check,   "n_1661384
        lf_save_umfang           like xlips_umfang,         "n_717981
        lf_save_chargensplitbild like v50agl-chargensplitbild.

* Start deletions with the batch split items if available
* Simulate processing on the batch split screen
  lf_save_chargensplitbild = v50agl-chargensplitbild.
  lf_save_panel            = t185v-panel.
  v50agl-chargensplitbild  = charx.
  t185v-panel              = gc_panel_chsp.

  sort ct_admin by uecha posnr.
  lf_old_uecha = posnr_low.
  lf_counter = 0.
  lf_save_umfang = xlips_umfang.                            "n_717981

  loop at ct_admin into ls_admin
                   where not uecha is initial
                     and nondel eq space.

    add 1 to lf_counter.

    if ls_admin-uecha ne lf_old_uecha.

*     Update of last processed main item (not in first loop)
      if lf_counter gt 1.
        perform position_gewichtsupdate_chsp(sapfv50p) using chard.
      endif.

*     Prepare new main item of batch split
      perform xlips_lesen_direkt(sapfv50p) using    ls_admin-uecha
                                           changing ilips-tabix.
*     Same logic as in FV50PFLP_XLIPS_CHSP_ND
      clips = xlips.
ENHANCEMENT-SECTION     MV50AF0D_12 SPOTS ES_SAPMV50A.
      if clips-kzfme na kzfme_ws.
        if clips-umrev ne 0.
          clips-kcmeng_vme = clips-kcmeng_flo * clips-umrev.
        else.
          clips-kcmeng_vme = clips-kcmeng_flo * clips-umvkn
                                              / clips-umvkz.
        endif.
        clips-g_lfimg = clips-kcmeng_vme + clips-lfimg_flo.
      endif.
END-ENHANCEMENT-SECTION.
      save_clips = clips.

      xlips_umfang = xlips_umfang_ucha.
      perform ilips_aufbauen(sapfv50p).
    endif.

*   Prepare batch split item
    perform xlips_lesen_direkt(sapfv50p) using    ls_admin-posnr
                                         changing ilips-tabix.
    slips-tabix = ilips-tabix.
    perform lips_bearbeiten_vorbereiten(sapfv50p).

*   Set quantity to zero
    lips-lfimg = 0.

    lf_quan_no_check = v50agl-quan_no_check.                  "n_1661384
    v50agl-quan_no_check = charx.                             "n_1661384

    perform lips_quan_set(sapfv50p) using 'A' space.

    perform lips_chargen_split_bearbeiten(sapfv50p) using space.

    v50agl-quan_no_check = lf_quan_no_check.                  "n_1661384

    lf_old_uecha = ls_admin-uecha.

  endloop.
  if sy-subrc eq 0.
    perform position_gewichtsupdate_chsp(sapfv50p) using chard.
  endif.

* Ensure that all items are in table ILIPS
  xlips_umfang = xlips_umfang_unor.
  perform ilips_aufbauen(sapfv50p).

* Restore original values of control flags
  v50agl-chargensplitbild = lf_save_chargensplitbild.
  t185v-panel             = lf_save_panel.

* Delete batch split items
  loop at ct_admin into ls_admin
                   where not uecha is initial
                     and nondel eq space.

    perform xlips_lesen_direkt(sapfv50p) using    ls_admin-posnr
                                         changing ilips-tabix.
    slips-tabix = ilips-tabix.
    move-corresponding xlips to lips.
    move-corresponding xlips to lipsd.
     *lips = lips.

    perform xlips_loeschen_rc(sapfv50p) using    space
                                                 ilips-tabix
                                                 charx
                                        changing lf_subrc.
    delete ct_admin.
  endloop.

* ...proceed with the dependent subitems...
  sort ct_admin by posnr descending.                        "n_667161
  loop at ct_admin into ls_admin
                   where not uepos is initial
                     and nondel eq space.

    perform xlips_lesen_direkt(sapfv50p) using    ls_admin-posnr
                                         changing ilips-tabix.
    move-corresponding xlips to lips.
    move-corresponding xlips to lipsd.
     *lips = lips.

    perform xlips_loeschen_rc(sapfv50p) using    space
                                                 ilips-tabix
                                                 charx
                                        changing lf_subrc.
    delete ct_admin.
  endloop.

* ...finish with the regular items
  loop at ct_admin into ls_admin
                   where nondel eq space.

    perform xlips_lesen_direkt(sapfv50p) using    ls_admin-posnr
                                         changing ilips-tabix.
    move-corresponding xlips to lips.
    move-corresponding xlips to lipsd.
     *lips = lips.

    perform xlips_loeschen_rc(sapfv50p) using    space
                                                 ilips-tabix
                                                 charx
                                        changing lf_subrc.
    delete ct_admin.
  endloop.

* Finally: Correct XLIPS-UEPOS of the remaining sub-items   "v_n_571048
  loop at xlips where updkz ne updkz_delete
                  and uepos ne posnr_low.
    slips-tabix = sy-tabix.
    loop at xlips transporting no fields
                  where posnr eq xlips-uepos
                    and updkz ne updkz_delete.
      exit.
    endloop.
    if sy-subrc ne 0.
*     Reset LIPS-UEPOS if main item does not exist any more
      move-corresponding xlips to lips.
      move-corresponding xlips to lipsd.
       *lips  = lips.
       *lipsd = lipsd.
      lips-uepos = posnr_low.
      perform xlips_aendern(sapfv50p).
    endif.
  endloop.                                                  "^_n_571048
  xlips_umfang = lf_save_umfang.                            "n_717981

endform.                    " delete_items_exceute
*&---------------------------------------------------------------------*
*&      Form  delete_delivery_complete (n_521409)
*&---------------------------------------------------------------------*
form delete_delivery_complete.

  data: lt_admin           type standard table of shp_del_admin,
        lf_subrc           like sy-subrc,
        lf_dependent_items type c,
        ls_save_ilips      like line of ilips,
        lt_reasons         type standard table of shp_del_reason
                                with header line.

  data: lf_outb_delivery   type vbeln_vl,                   "v_n_1144740
        lf_vbfa_tabix      type sy-tabix,
        ls_xvbfa           like line of xvbfa,
        ls_vbfa            type vbfa.                       "^_n_1144740

ENHANCEMENT-POINT mv50af0d_07 SPOTS es_sapmv50a STATIC.


* Check assignment of delivery to a shipment
  if xvbuk-trsta eq charc or xvbuk-trsta eq charb.
    perform transport_int_pruefen(sapfv50p) using lf_subrc.
    if lf_subrc = 0.
      message i164 display like 'E'.
      if v50agl-kommirueckmeldung ne space.                 "v_n_618283
        message e066.
      endif.                                                "^_n_618283
      exit.
    endif.
  endif.

* Enable decentral system to delete distributed delivery    v_n_694160
* when HUs are still assigned in the central system.
  if likp-vlstk eq 'B' and
     likp-verursys is initial and
     v50agl-confirm_central is initial and
     v50agl-no_rmsys_dlv_chg eq charx and
     xvbuk-pkstk ca 'BCD'.
    v50agl-confirm_central = 'X'.                           "n_992450
    perform hu_confirm_central(saplv50s) using xlikp.
    clear v50agl-confirm_central.                           "n_992450
  endif.                                                    "^_n_694160

* Check packing status
  if xvbuk-pkstk ca 'BCD'.
    message i639 display like 'E'.
    if v50agl-kommirueckmeldung ne space.                   "v_n_618283
      message e066.
    endif.                                                  "^_n_618283
    exit.
  endif.

  ls_save_ilips = ilips.

* Mark all items for deletion
  perform ilips_aufbauen_alle(sapfv50p).
  loop at ilips.
    ilips-selkz = charx.
    modify ilips transporting selkz.
  endloop.

ENHANCEMENT-SECTION     MV50AF0D_09 SPOTS ES_SAPMV50A.
* Check marked items for deletion
  perform delete_items_check tables   lt_admin
                                      lt_reasons
                             changing lf_dependent_items.
END-ENHANCEMENT-SECTION.

* Background processing and not all items are deletable: error message
* (to be handled by the caller)
  loop at lt_admin transporting no fields
                   where nondel ne space.
    exit.
  endloop.
  if sy-subrc eq 0 and
     v50agl-kommirueckmeldung ne space.
    message e066.
  endif.

* User decision for the check results (not in BI mode)
  if sy-batch eq space and sy-binpt eq space.

*   Check violation of the complete delivery condition
    perform delete_items_compl_del tables lt_admin
                                          lt_reasons.

    perform delete_items_results tables   lt_admin
                                          lt_reasons
                                 using    space             "n_645416
                                 changing lf_subrc.
    if lf_subrc ne 0.

ENHANCEMENT-POINT mv50af0d_10 SPOTS es_sapmv50a.

*     Restore original state of table ILIPS
      xlips_umfang = xlips_umfang_uall.
      perform ilips_aufbauen(sapfv50p).
      ilips = ls_save_ilips.
      if lf_subrc eq 4.
*       Message: Delivery document can not be deleted
        message s066 display like 'E'.
      endif.
*     Switch to error log if requested
      if fcode eq 'FEAZ_T'.
        perform fcode_bearbeiten.
      endif.
      exit.
    endif.
  endif.

* Physical deletion of the items
* Start physical deletion of delivery items
  v50agl-no_lfimg_check_all = charx.                        "n_848294
  perform delete_items_exceute tables lt_admin
                                      lt_reasons.
  clear v50agl-no_lfimg_check_all.                          "n_848294
ENHANCEMENT-POINT mv50af0d_11 SPOTS es_sapmv50a.


* If not all items could be deleted save rest of the delivery
  loop at xlips transporting no fields
                where updkz ne updkz_delete.
    exit.
  endloop.
  if sy-subrc eq 0.
*   Save delivery after partial deletion of items
*   If the document can not be saved exit to dialog processing again
    perform beleg_sichern_01 using    charx
                                      charx
                                      charx
                                      charx
                             changing lf_subrc.
    if lf_subrc ne 0.
      perform ilips_aufbauen(sapfv50p).
      ilips = ls_save_ilips.
      exit.
    else.
      fcode = 'ABBR_T'.
      perform funktion_ausfuehren.
      exit.
    endif.
  endif.

* Complete deletion of the document
  perform likp_loeschen(sapfv50k).

  move xobjky         to xobjky_to.
  move '9999999999'   to xobjky_to+10.
  call function 'RV_MESSAGES_DELETE'
    exporting
      msg_objky         = xobjky
      msg_objky_to      = xobjky_to
      delete_all_status = 'X'.

* Delete deadlines
  if likp-ternr ne space.
    call function 'SD_DEADLINE_DELETE'
      exporting
        deadline_no_in = likp-ternr
      exceptions                                            "v_n_568823
        not_found      = 0
        delete_error   = 0
        others         = 0.                                 "^_n_568823
  endif.

* Delete appointments
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
  endif.

* Delete entry in cross-docking document flow
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

  if not gi_badi_delivery is initial.              "n_530754/n_637289
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
  endif.                                                    "n_530754

  perform userexit_delete_document.

* If document can not be saved terminate processing to avoid
* inconsistencies
  perform beleg_sichern_01 using    charx
                                    charx
                                    charx
                                    charx
                           changing lf_subrc.
  if lf_subrc ne 0.
*   If the decentral warehouse management scenario is active show log
*   of simulation before leaving transaction
    if likp-vlstk ne space and
       not cvbfs[] is initial.
      perform fcode_feaz.
    endif.
    message a066.
  endif.

* Clear APO Delta before leave to transaction:
  if v50agl-no_commit eq space.
    perform nmodul_for_tcode_apo.
  endif.

endform.                    " delete_delivery_complete

*&---------------------------------------------------------------------*
*&      Form  delete_items_compl_del (n_521409)
*&---------------------------------------------------------------------*
*       This form appends a warning to the table CT_REASONS if the
*       deletion of a delivery item violates the complete delivery
*       condition.
*----------------------------------------------------------------------*
form delete_items_compl_del
     tables ct_admin   structure shp_del_admin
            ct_reasons structure shp_del_reason.

  data: lf_admin_lines like sy-tfill,
        lf_xlips_lines like sy-tfill.

  field-symbols: <ls_xlips> like line of xlips.

* Check violation of the complete delivery condition
  check likp-autlf ne space.

  describe table ct_admin lines lf_admin_lines.
  describe table xlips    lines lf_xlips_lines.

* No warning if all items are going to be deleted
  if lf_xlips_lines eq lf_admin_lines.
    loop at ct_admin where nondel ne space.
      exit.
    endloop.
    if sy-subrc ne 0.
*     All items are deletable -> no warning
      exit.
    endif.
  endif.

  loop at xlips assigning <ls_xlips>
                where not vgbel is initial
                  and uecha is initial
                  and posar ne charc
                  and uepvw ne chara.
    read table ct_admin with key posnr = <ls_xlips>-posnr
                        binary search.
    if sy-subrc eq 0 and
       ct_admin-nondel eq space.
*     At least one items with reference to a sales order is going ot be
*     deleted -> send warning
      ct_reasons-posnr  = <ls_xlips>-posnr.
      ct_reasons-reason = 'W'.
      ct_reasons-msgty  = 'W'.
      append ct_reasons.
    endif.
  endloop.

endform.                    " delete_items_compl_del
*&---------------------------------------------------------------------*
*&      Form  delete_free_goods_item_check (n_571048)
*&---------------------------------------------------------------------*
form delete_free_goods_item_check
     using    value(if_posnr) like lips-posnr
              value(if_vgbel) like lips-vgbel
              value(if_vgpos) like lips-vgpos
     changing cf_delete_flag  type c.

  data: lt_xvbfa_uepos  type standard table of vbfavb with header line,
        lt_xvbapf_uepos type standard table of vbapf  with header line,
        lt_xvbup_uepos  type standard table of vbupvb with header line,
        lt_xvbuv        type standard table of vbuvvb with header line,
        lt_yvbup        type standard table of vbupvb with header line,
        lt_xvbep        type standard table of vbepvb with header line.

  field-symbols: <ls_xvbap> like line of xvbap,
                 <ls_xvbfa> like line of xvbfa.

* Get preceding sales order item
  read table xvbap assigning <ls_xvbap>
                   with key vbeln = if_vgbel
                            posnr = if_vgpos.
  if sy-subrc ne 0.
    cf_delete_flag = charx.
    exit.
  endif.

* In order to avoid the free goods recursion in XLIPS_LOESCHEN_RC the
* deletion of the corresponding main item in the delivery is simulated
* and it is checked, based on the settings of the flag LSTANR, whether
* the deletion of the sub item is also allowed
  if <ls_xvbap>-lstanr ca 'ABC'.
*   Extract document flow for corresponding main item in the
*   sales order
    read table xvbfa with key vbelv = <ls_xvbap>-vbeln
                              posnv = <ls_xvbap>-uepos
                     binary search
                     transporting no fields.
    if sy-subrc ne 0.
      cf_delete_flag = charx.
      exit.
    endif.
    loop at xvbfa assigning <ls_xvbfa>
                  from sy-tabix.
      if <ls_xvbfa>-vbelv ne <ls_xvbap>-vbeln or
         <ls_xvbfa>-posnv ne <ls_xvbap>-uepos.
        exit.
      endif.
      append <ls_xvbfa> to lt_xvbfa_uepos.
    endloop.

*   Simulate that the main item in the current delivery was already
*   deleted
    delete lt_xvbfa_uepos where vbelv eq <ls_xvbap>-vbeln
                            and posnv eq <ls_xvbap>-uepos
                            and vbeln eq likp-vbeln
                            and vbtyp_n eq likp-vbtyp.

*   Build cumulated flow and calculate sales order status (simulation!)
    call function 'RV_XVBAPF_CREATE'
      exporting
        vbeln   = <ls_xvbap>-vbeln
      tables
        fxvbapf = lt_xvbapf_uepos
        fxvbfa  = lt_xvbfa_uepos.

    call function 'RV_XVBUP_MAINTAIN'
      exporting
        f_posnr                  = <ls_xvbap>-uepos
        f_vbeln                  = <ls_xvbap>-vbeln
        f_xvbap_sortiert         = space
        f_xvbuv_beruecksichtigen = space
      tables
        fxvbap                   = xvbap
        fxvbapf                  = lt_xvbapf_uepos
        fxvbep                   = lt_xvbep
        fxvbup                   = lt_xvbup_uepos
        fxvbuv                   = lt_xvbuv
        fyvbup                   = lt_yvbup.

    read table lt_xvbup_uepos with key vbeln = <ls_xvbap>-vbeln
                                       posnr = <ls_xvbap>-uepos
                              binary search.
  endif.

* Logic corresponds to FORM NATRB_LOESCHEN (FV50XF0N) but avoids the
* nested loop
  case <ls_xvbap>-lstanr.
    when 'A'.
*     Delivery only if main item partially delivered
*     -> item can only be deleted if main item is not delivered
      if lt_xvbup_uepos-lfgsa eq 'A'.
        cf_delete_flag = charx.
      endif.
    when 'B'.
*     Delivery only if main item completely delivered
*     -> item can only be deleted if main item is not or partially
*        delivered
      if lt_xvbup_uepos-lfgsa ca 'AB'.
        cf_delete_flag = charx.
      endif.
    when 'C'.
*     Delivery only together with main item if main item if partially
*     delivered
      if lt_xvbup_uepos-lfgsa eq 'A'.
        cf_delete_flag = charx.
      else.
*       Check whether main item of the sales order item is included in
*       the current delivery
        read table xvbfa with key mandt   = <ls_xvbap>-mandt
                                  vbelv   = <ls_xvbap>-vbeln
                                  posnv   = <ls_xvbap>-uepos
                                  vbeln   = likp-vbeln
                                  vbtyp_n = likp-vbtyp
                         binary search
                         transporting no fields.
        if sy-subrc eq 0.
          cf_delete_flag = charx.
        endif.
      endif.
    when 'E'.
*     Delivery quantity of the subitem corresponds to the quantity of
*     the main item
      cf_delete_flag = charx.
    when space.
*     Delivery of subitem is indendent of main item
*     -> do not delete subitem automatically
  endcase.

endform.                    " delete_free_goods_item_check
*&---------------------------------------------------------------------*
*&      Form  delete_items_del_group (n_587009)
*&---------------------------------------------------------------------*
*       Checks whether delivery groups are deleted completely and
*       issues a warning message if not.
*----------------------------------------------------------------------*
form delete_items_del_group
     tables ct_admin   structure shp_del_admin
            ct_reasons structure shp_del_reason.

  data: begin of lt_grkor occurs 0,
          vgbel like lips-vgbel,                            "n_853925
          grkor like lips-grkor,
        end   of lt_grkor,
        lf_grkor_incomplete type c,
        ls_admin            type shp_del_admin,
        lf_posnr_txt(6)     type c,
        lf_msgty            type c,                         "v_n_705611
        lf_rc               type sysubrc.

  field-symbols: <ls_xlips> like line of xlips,
                 <ls_admin> type shp_del_admin.

* get VL119 message type (default is 'W' warning)
  lf_msgty = 'W'.
  perform message_steuerung using  gs_mhpar
                                   v50agl-msgvs
                                   'VL'
                                   '119'
                          changing lf_msgty
                                   lf_rc.
* check VL119 is not suppressed
  check not lf_msgty is initial.                            "^_n_705611

* Check for items assigned to a delivery groups among the items to be
* deleted
  loop at ct_admin into ls_admin
                   where not grkor is initial.
    read table xlips assigning <ls_xlips>                   "v_n_853925
                     with key posnr = ls_admin-posnr.
    check <ls_xlips>-updkz ne updkz_delete.
    lt_grkor-vgbel = <ls_xlips>-vgbel.                      "^_n_853925
    lt_grkor-grkor = ls_admin-grkor.
    collect lt_grkor.
  endloop.

  if sy-subrc ne 0.
    exit.
  endif.

* Check whether ALL items belong to a certain delivery group should be
* deleted.
  loop at lt_grkor.
    clear lf_grkor_incomplete.
    loop at xlips assigning <ls_xlips>
                  where updkz ne updkz_delete
                    and grkor eq lt_grkor-grkor
                    and vgbel eq lt_grkor-vgbel.            "n_853925
      read table ct_admin transporting no fields
                          with key posnr = <ls_xlips>-posnr
                          binary search.
      if sy-subrc ne 0.
        lf_grkor_incomplete = 'X'.
        exit.
      endif.
    endloop.
    if lf_grkor_incomplete ne space.
* lines replaced                                              v_n_705611
*     Not all items should be deleted
      loop at ct_admin assigning <ls_admin>
                       where grkor eq lt_grkor-grkor.
        write <ls_admin>-posnr to lf_posnr_txt no-zero.
        condense lf_posnr_txt.
        clear ct_reasons.
        ct_reasons-posnr = <ls_admin>-posnr.
        ct_reasons-msgty = lf_msgty.
        ct_reasons-msgid = 'VL'.
        ct_reasons-msgno = '119'.
        ct_reasons-msgv1 = lf_posnr_txt.
        ct_reasons-msgv2 = <ls_admin>-grkor.
        append ct_reasons.
        if lf_msgty = 'E'.
          <ls_admin>-nondel = charx.
        endif.                                              "^_n_705611
      endloop.
    endif.
  endloop.

endform.                    " delete_items_del_group