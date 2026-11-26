***INCLUDE FV50XFSN .
*---------------------------------------------------------------------*
*        FORM SERIALNUMBER_AUTOMATICALLY
*---------------------------------------------------------------------*
form serialnumber_automatically.

  data: xanzsn     like risa0-anzahl,
        xtrtyp     like t180-trtyp,
        XOPERA(04) TYPE C,
* lines deleted                                                 n_999927
        lf_subrc type sysubrc,                                 "n_999927
        LF_VORGANG(04)  TYPE C,
        lf_nopopup type xfeld.                                 "n_998953

  check v50agl-no_auto_serial_number is initial.                  "AIP

* lines deleted                                                 n_999927
* lines deleted                                                n_1008721

  loop at xlikp where updkz ne updkz_delete and                    "4.70
                      klief is initial         .
    likp = xlikp.
    perform xvbuk_lesen(sapfv50k) using likp-vbeln.
    check not vbuk-wbstk = charc.
    loop at xlips where vbeln  =  xlikp-vbeln
                  and   serail <> space
                  and   updkz  <> updkz_delete.
* Lieferungsposition zur weiteren Verarbeitung vorbereiten
      slips-tabix = sy-tabix.
      ilips-tabix = sy-tabix.
      perform lips_bearbeiten_vorbereiten(sapfv50p).

      xanzsn = lips-lgmng.
ENHANCEMENT-POINT SERIALNUMBER_AUTOMATICALLY_05 SPOTS ES_FV50XFSN STATIC INCLUDE BOUND .

ENHANCEMENT-SECTION     SERIALNUMBER_AUTOMATICALLY_01 SPOTS ES_FV50XFSN INCLUDE BOUND.
      if likp-vbtyp ca vbtyp_retour.
        xopera = 'SDRE'.
      else.
        xopera = 'SDLS'.
      endif.

*     Make sure the right activity category per item is passed
      IF XLIPS-UPDKZ CA ' U'.                               "v_n_1008721
        XTRTYP = CHARV.                         "Change
      ELSEIF XLIPS-UPDKZ EQ 'I'.
        XTRTYP = CHARH.                         "Add
      ENDIF.                                                "^_n_1008721

*     lines deleted                                             n_999927
      perform messages_init changing lf_nopopup.               "n_999927


      PERFORM SN_STATUS_OPERATION_DETERMINE(SAPFV50W)        "v_n_599939
                                    USING    LIKP-VBTYP
                                             TVLK-AUFER
                                             LIPS              "n_933408
                                             SPACE
                                    CHANGING LF_VORGANG.     "^_n_599939

      call function 'SERIALPROFILE_CHECK'
           exporting
                operation     = xopera
                j_vorgang     = LF_VORGANG
                activity      = xtrtyp
                document      = likp-vbeln
                item          = lips-posnr
                material      = lips-matnr
                m_charge      = lips-charg
                profile       = lips-serail
                quantity      = xanzsn
                debitor       = likp-kunnr
                cuobj         = lips-cuobj
                vbtyp         = likp-vbtyp
                bwart         = lips-bwart
                automatic     = 'X'
                BAPI          = lf_nopopup                     "n_998953
           IMPORTING
                ANZSN         = LIPS-ANZSN
           EXCEPTIONS
                OTHERS        = 1.
*     lines replaced                                          v_n_999927
      lf_subrc = sy-subrc.

      if not lf_nopopup is initial.
        perform messages_give.
      endif.

      check lf_subrc is initial.                             "^_n_999927
END-ENHANCEMENT-SECTION.

*     update sales order number in XVBAPF in case of rush order
      if not v50agl-SOFAUFTRAG is initial.
        loop at xvbapf where vbeln is initial    and
                             vbtyp eq lips-vgtyp .
          xvbapf-vbeln = lips-vgbel.
          modify xvbapf.
        endloop.
      endif.

      perform lips_bearbeiten(sapfv50p).
    endloop.
  endloop.
ENHANCEMENT-POINT SERIALNUMBER_AUTOMATICALLY_06 SPOTS ES_FV50XFSN STATIC INCLUDE BOUND .

ENHANCEMENT-POINT SERIALNUMBER_AUTOMATICALLY_07 SPOTS ES_FV50XFSN INCLUDE BOUND .

endform.
*---------------------------------------------------------------------*
*        FORM SERIALNUMBER_REFRESH
*---------------------------------------------------------------------*
form serialnumber_refresh.

    call function 'SERIALPROFILE_CHECK'
         exporting
              operation = 'SNCL'.

endform.
*---------------------------------------------------------------------*
*        FORM SERIALNUMBER_UPDATE
*---------------------------------------------------------------------*
form serialnumber_update.
* lines replaced                                             v_n_999927
  data lf_nopopup type xfeld.

ENHANCEMENT-POINT SERIALNUMBER_AUTOMATICALLY_02 SPOTS ES_FV50XFSN STATIC INCLUDE BOUND.

ENHANCEMENT-POINT SERIALNUMBER_AUTOMATICALLY_04 SPOTS ES_FV50XFSN INCLUDE BOUND.
  check aufrufer ne chart.

  perform messages_init changing lf_nopopup.

*  CHECK V50AGL-WARENAUSG_STORNO NE CHARX.
ENHANCEMENT-POINT SERIALNUMBER_AUTOMATICALLY_03 SPOTS ES_FV50XFSN INCLUDE BOUND.

ENHANCEMENT-SECTION     SERIALNUMBER_UPDATE_01 SPOTS ES_FV50XFSN INCLUDE BOUND .
  call function 'SERIALPROFILE_CHECK'
       exporting
            operation = 'SDLP'
            bapi      = lf_nopopup.

  if not lf_nopopup is initial.
    perform messages_give.
  endif.                                                    "^_n_999927

END-ENHANCEMENT-SECTION.

endform.
*---------------------------------------------------------------------*
*        FORM SERIALNUMBER_RENAME
*---------------------------------------------------------------------*
form serialnumber_rename using value(if_temp_vbeln) like likp-vbeln
                               value(if_vbeln)      like likp-vbeln.

  call function 'SERIALPROFILE_CHECK'
       exporting
            operation = 'SDR1'
            doc_old   = if_temp_vbeln
            doc_new   = if_vbeln.

endform.

*---------------------------------------------------------------------*
*        FORM MESSAGES_INIT                                  v_n_999927
*---------------------------------------------------------------------*
form messages_init changing cf_init type xfeld.
  data lf_ident like sy-uzeit.

  if v50agl-dialog is initial.
    cf_init = 'X'.
  else.
    clear cf_init.
    exit.
  endif.

  clear lf_ident.
  call function 'MESSAGES_INITIALIZE'
       exporting
            i_identification = lf_ident
       importing
            e_identification = lf_ident
       exceptions
            OTHERS           = 0.

endform.                                                    "^_n_999927

*---------------------------------------------------------------------*
*        FORM MESSAGES_GIVE                                  v_n_999927
*---------------------------------------------------------------------*
form messages_give.
  data: lt_msg   type tsmesg,
        ls_msg   like line of lt_msg,
        lv_msgty like sy-msgty,                               "n_1667576
        lf_msgno like sy-msgno.

  call function 'MESSAGES_GIVE'
       tables
            t_mesg = lt_msg.

  loop at lt_msg into ls_msg.
    lf_msgno = ls_msg-txtnr.
*   Info or warnings should be collected into CVBFS and       "v_1667576
*   should not be poped one after another
    lv_msgty = ls_msg-msgty.
    if lv_msgty = chari or lv_msgty = charw.
       vbsk-ernum = vbsk-ernum + 1.
       perform message_vbfs_aufbauen using vbsk-sammg
                                             lips-posnr
                                             lf_msgno
                                             lv_msgty
                                             ls_msg-arbgb
                                             ls_msg-msgv1
                                             ls_msg-msgv2
                                             ls_msg-msgv3
                                             ls_msg-msgv4.

    else.                                                     "^_1667576
       perform message_handling(sapmv50a) using lips-posnr
                                             lf_msgno
                                             lv_msgty         "n_1667576
                                             ls_msg-arbgb
                                             ls_msg-msgv1
                                             ls_msg-msgv2
                                             ls_msg-msgv3
                                             ls_msg-msgv4.

    endif.                                                    "n_1667576
  endloop.

endform.                                                    "^_n_999927