*----------------------------------------------------------------------*
*   INCLUDE MV50AF0F_VERP_HU                                           *
*----------------------------------------------------------------------*
*       perFORM FCODE_VERP.
*       perFORM FCODE_VERP_GEN_HU.
*       perFORM INIT_COMPLETE_PACKING.
*       perFORM DELIVERY_PACKING.
*       perFORM AUTOMATIC_PACKING_DELIVERY.
*       perFORM GET_PRINTING_DATA_FOR_HU.
*       perFORM DELIVERY_REHANG_HU.
*       perForm CHECK_UNIQUE_HU.
*       perForm ASSIGN_HANDLING_UNITS_QM.
*       perFORM DELIVERY_REPACK_HU.
*       perFORM ASSIGN_HU_TO_DELIVERY.
*       perFORM DELETE_DELIVERY_HUS.
*       perFORM DELETE_DELIVERY_HUS_PGR.                    "n_1302585
*---------------------------------------------------------------------*
*       FORM FCODE_VERP                                               *
*---------------------------------------------------------------------*
* Verpackungsdialog
*---------------------------------------------------------------------*
FORM fcode_verp.
  DATA: ls_likp LIKE likpvb, ls_packing TYPE vse_s_v51h.

  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.
  DATA         : lf_tabix LIKE sy-tabix,
                 ls_clips_save LIKE clips,
                 ls_ilips_main LIKE LINE OF gt_ilips_main.

  ls_packing-display = t180-trtyp.               "Anlegen,Ändern,Anz.
  CLEAR: ls_packing-init, ls_packing-object,      "Dialogverarbeitung
         ls_packing-endrunde.
  ls_likp = likp.
  IF NOT clips IS INITIAL.
    ls_clips_save = clips.
  ENDIF.
  PERFORM init_complete_packing USING    ls_likp
                                CHANGING ls_packing.

* insert generated packing items restore table gt_ilips_main
  IF NOT gt_ilips_main[] IS INITIAL           AND
         xlips_umfang    NE xlips_umfang_ucha.
    LOOP AT xlips ASSIGNING <ls_xlips>
                  WHERE posar EQ gc_posar-packing AND
                        updkz EQ updkz_new.
      lf_tabix = sy-tabix.
      READ TABLE gt_ilips_main TRANSPORTING NO FIELDS
                               WITH KEY posnr = <ls_xlips>-posnr
                               BINARY SEARCH.
      CASE sy-subrc.
        WHEN 4.
          CLEAR ls_ilips_main.
          ls_ilips_main-posnr = <ls_xlips>-posnr.
          ls_ilips_main-tabix = lf_tabix.
          INSERT ls_ilips_main INTO gt_ilips_main INDEX sy-tabix.
        WHEN 8.
          CLEAR ls_ilips_main.
          ls_ilips_main-posnr = <ls_xlips>-posnr.
          ls_ilips_main-tabix = lf_tabix.
          APPEND ls_ilips_main TO gt_ilips_main.
      ENDCASE.
    ENDLOOP.
  ENDIF.
* Restore main item of a batch split if it was active before packing
  IF NOT ls_clips_save IS INITIAL.                          "HP_385937
    LOOP AT xlips INTO clips
                  WHERE vbeln EQ ls_clips_save-vbeln
                    AND posnr EQ ls_clips_save-posnr
                    AND updkz NE updkz_delete.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.                    "fcode_verp
*---------------------------------------------------------------------*
*       FORM FCODE_VERP_GEN.                                          *
*---------------------------------------------------------------------*
*       Aufruf Verpacken Generieren aus Lieferplan                    *
*---------------------------------------------------------------------*
FORM fcode_verp_gen_hu TABLES it_vbap STRUCTURE vbapvb.
  DATA: ls_likp LIKE likpvb, lf_anzpk LIKE sy-tabix,
        ls_packing TYPE vse_s_v51h.

  CLEAR flag_vfp_packen.
  ls_likp = likp.
  ls_packing-display = t180-trtyp.
  ls_packing-init = charx.

  PERFORM init_complete_packing USING    ls_likp
                                CHANGING ls_packing.

  CALL FUNCTION 'HU_CREATE_FROM_SALES_PROPOSAL'
    EXPORTING
      is_vbak         = cvbak
      is_v50agl       = v50agl
      is_likp         = ls_likp
      it_vbap         = it_vbap[]
      it_vbfa_tab     = xvbfa[]
    IMPORTING
      ef_data_changed = packdaten_verbuchen
    CHANGING
      ct_xvbfa        = xpackvbfa[]
      ct_yvbfa        = ypackvbfa[]
      ct_xvbapf       = xvbapf[].
  ls_packing-endrunde = charx.
  PERFORM init_complete_packing USING    ls_likp
                                CHANGING ls_packing.

ENDFORM.                    "fcode_verp_gen_hu

*---------------------------------------------------------------------*
*       FORM INIT_COMPLETE_PACKING
*---------------------------------------------------------------------*
*       XPACKVBFA enthält die Zeilen der XVBFA, bei denen der         *
*       Nachfolger ein Versandelement ist.                            *
*       Nach dem Verpacken wird die PACKVBFA aktualisiert zurück-     *
*       gegeben. Danach müssen die Tabellen VBFA, VBUK und VBUP       *
*       aktualisiert werden.                                          *
*---------------------------------------------------------------------*
FORM init_complete_packing USING is_likp LIKE likpvb
                           CHANGING cs_packing TYPE vse_s_v51h.
  DATA: ls_likp LIKE likpvb, lf_anzpk LIKE sy-tabix,
        lf_fcode LIKE sy-ucomm, lf_data_changed TYPE xfeld.

* Field holding switch position (used for EHS dangerous goods)
  DATA: lv_switchpos TYPE sfw_switchpos.

  cs_packing-conf_dec = v50agl-confirm_central.
  cs_packing-tvlk_aufer = tvlk-aufer.                       "HP_431695
  cs_packing-sammelgang = v50agl-sammelgang.                "n_876227
  cs_packing-tvlk_pmpos_gen = tvlk-pm_item_gen.             "HP_431863
  IF cs_packing-endrunde IS INITIAL.
    PERFORM create_xpackvbfa_ypackvbfa USING is_likp
                                       CHANGING cs_packing.
  ENDIF.

* Only call form routine if switch is on
  CALL FUNCTION 'SFW_GET_SW_STATUS'
    EXPORTING
      SWITCH          = 'EHS_DG_SC_03'
    IMPORTING
      STATUS          = lv_switchpos.

  IF ( lv_switchpos = 'T' )  " T = on
  AND NOT ( NOT v50agl-spe_auto_gr IS INITIAL AND is_likp-vbeln(1) = '$' ).
*   process specific source code for EHS (dangerous goods)
*   In case of automatic GR filling of buffer only with final VBELN
    PERFORM move_delivery_to_buffer(sapfv50w). "(FV50WF0W).
  ENDIF.

  CALL FUNCTION 'HU_PACKING_DELIVERY'
    EXPORTING
      is_delivery     = cs_packing
      is_likp         = is_likp
      it_xlips        = xlips[]
      it_xvbuk        = xvbuk[]
      it_xvbup        = xvbup[]
      it_xvbpa        = xvbpa[]
      if_ar_hus       = v50agl-display_from_archive
    IMPORTING
      ef_data_changed = lf_data_changed                     "SP_606963
      ef_fcode        = lf_fcode
      ef_number_hus   = lf_anzpk
    CHANGING
      ct_xvbfa        = xpackvbfa[]
      ct_yvbfa        = ypackvbfa[]
      ct_xvbapf       = xvbapf[].
  IF NOT lf_data_changed IS INITIAL.
    packdaten_verbuchen = charx.
  ENDIF.
  IF NOT packdaten_verbuchen IS INITIAL.
    IF NOT lf_data_changed IS INITIAL OR
       NOT cs_packing-endrunde IS INITIAL.
      READ TABLE xlikp INTO ls_likp WITH KEY vbeln = is_likp-vbeln.
      IF sy-subrc IS INITIAL.
        ls_likp-anzpk = lf_anzpk.
        IF ls_likp-updkz = updkz_old.
          ls_likp-updkz = updkz_update.
        ENDIF.
        IF likp-vbeln = ls_likp-vbeln.
          likp-anzpk = ls_likp-anzpk.
          xlikp-anzpk = ls_likp-anzpk.
        ENDIF.
ENHANCEMENT-POINT mv50af0f_verp_hu_11 SPOTS es_sapmv50a.
        MODIFY xlikp FROM ls_likp INDEX sy-tabix.
      ELSE.
        likp-anzpk = lf_anzpk.
        IF likpd-updkz = updkz_old. likpd-updkz = updkz_update. ENDIF.
      ENDIF.
    ENDIF.
*    PERFORM PACKFLUSS_UEBERNEHMEN. "del note 134119
    PERFORM packfluss_uebernehmen USING likp-vbeln 'X'. "ins note 134119
    r185d-dataloss = charx.
  ENDIF.
* incompletion check if packing data changed
  IF NOT lf_data_changed IS INITIAL.                        "v_n_743920
    FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.

    IF t180-trtyp NE chara.
      LOOP AT xlips ASSIGNING <ls_xlips>
                    WHERE updkz NE chard.
        PERFORM uc_upd_request(sapfv50u) USING charx
                                               <ls_xlips>-posnr
                                               <ls_xlips>-uepos
                                               <ls_xlips>-uecha.
      ENDLOOP.
      IF uc_process EQ space.
        PERFORM uc_internal_update(sapfv50u).
      ELSE.
        PERFORM uc_recalc(sapfv50u).
      ENDIF.
    ENDIF.
  ENDIF.                                                    "^_n_743920

  CASE lf_fcode.
    WHEN 'WABU'.
      PERFORM cua_fcode_allow USING 'WABU' no.
      lf_fcode = 'ENT1'.
    WHEN 'SICH'.
      IF t180-bldgr = gc_new_dialog_outb OR
         t180-bldgr = gc_new_dialog_inb.
        lf_fcode = 'SICH_T'.
      ENDIF.
    WHEN 'BABA'.
      IF t180-bldgr = gc_new_dialog_outb OR
         t180-bldgr = gc_new_dialog_inb.
*        lf_fcode = 'BABA_T'.                               "v_n_1235992
         lf_fcode = 'ENT1'.                                 "^_n_1235992
      ELSE.
        lf_fcode = 'BAC1'.
      ENDIF.
    WHEN OTHERS.
      lf_fcode = 'ENT1'.
  ENDCASE.
  IF cs_packing-init IS INITIAL.
    IF flag_vfp_packen = charx AND v50agl-sammelgang = space
                               AND sy-binpt = space.
      fcode = 'ENT1'.
      IF v50agl-sammelgang = space AND sy-binpt = space.
        MESSAGE i160.
      ENDIF.
    ENDIF.
    fcode = lf_fcode.
    IF lf_fcode = 'BABA_T'.
      PERFORM funktion_ausfuehren.
    ELSE.
      PERFORM fcode_bearbeiten.
    ENDIF.
  ENDIF.

ENDFORM.                           "INIT_COMPLETE_PACKING
*---------------------------------------------------------------------*
*                FORM DELIVERY_PACKING
*---------------------------------------------------------------------*
FORM delivery_packing USING    if_convert TYPE xfeld
                               is_likp LIKE likpvb
                      CHANGING ct_verko TYPE vsep_t_verko
                               ct_verpo TYPE vsep_t_verpo
                               ct_sernr TYPE vsep_t_husernr
                               ef_rcode TYPE sysubrc.
  DATA: lt_hdr_pro TYPE hum_hdr_proposal_t,
        lt_header_cap TYPE huhdr_cap, lt_hu_items   TYPE huitm_prop,
        lt_header_tra TYPE huhdr_tra,  lt_header_add TYPE huhdr_add,
        lt_messages   TYPE huitem_messages_t.
  DATA: ls_verko TYPE verko, ls_verpo TYPE verpo,
        ls_hdr_pro TYPE hum_hdr_proposal,
        ls_header_cap TYPE huhdr_capacity,
        ls_header_tra TYPE huhdr_transport,
        ls_header_add TYPE huhdr_additional_data,
        ls_huitem_pro TYPE huitm_proposal.
  DATA: ls_lips LIKE lipsvb, ls_object TYPE hum_object,
        ls_convt TYPE vse_s_convt, ls_sernr TYPE hum_verpo_sernr,
        lt_convt TYPE vse_t_convt, lf_local_memory(1),
        ls_packing TYPE vse_s_v51h, ls_message TYPE huitem_messages,
        ls_husernr TYPE hum_rep_sernr, lt_sernr TYPE hum_rep_sernr_t.
  DATA: lf_vbeln LIKE likp-vbeln.                           " 682506
*       Reference is VBELN/POSNR
  DATA: l_ref_vbeln TYPE xfeld.
* -PDI- 02/07 begin RFID data
  data: lt_header_hu type  hum_hu_header_t.
* -PDI- end

  DATA: lf_msgty_134 TYPE symsgty,                          "n_1278049
        lf_subrc type sysubrc.

  FIELD-SYMBOLS: <huitem> TYPE huitm_proposal,
                 <lips> TYPE lipsvb.

ENHANCEMENT-POINT mv50af0f_verp_hu_02 SPOTS es_sapmv50a STATIC.


ENHANCEMENT-POINT mv50af0f_verp_hu_03 SPOTS es_sapmv50a.
  lf_vbeln = is_likp-vbeln.                                 " 682506

  IF NOT xvbuk-vbeln = lf_vbeln .                           " 779895
    READ TABLE xvbuk WITH KEY vbeln = lf_vbeln.
  ENDIF.

  IF xvbuk-wbstk = 'C'.
*   message e018(hudialog).
    PERFORM message_handling USING posnr_low '018' 'E' 'HUDIALOG'
                                   space space space space.
    EXIT.
  ENDIF.

* add missing data
  If v50agl-confirm_central is not initial.                   "v_n_1351733
    PERFORM add_missing_data TABLES ct_verpo[]
                                    xlips.
  endif.                                                      "^_n_1351733

* check invalid item number
  PERFORM chk_item_num TABLES ct_verpo[]
                              xlips.
* check invalid unit of measure
  PERFORM chk_unit_of_measure TABLES ct_verko[].

* check sales unit
*  PERFORM CHK_SALES_UNIT TABLES CT_VERPO[]
*                                XLIPS.

  IF is_likp-vbtyp CA vbtyp_mmli OR is_likp-vbtyp CA vbtyp_lire.
    ls_object-object = '03'.
  ELSE.
    ls_object-object = '01'.
  ENDIF.
  IF NOT if_convert IS INITIAL.
* Convertion should only be done once for the current set of deliveries
    read table xlikp transporting no fields with key vbeln = lf_vbeln.
    if sy-tabix = '1'.
    LOOP AT xlips INTO ls_lips WHERE NOT updkz = updkz_delete.
      CLEAR ls_convt.
      ls_convt-vbeln = ls_lips-vbeln.
      ls_convt-posnr = ls_lips-posnr.
      IF ls_lips-vgtyp CA vbtyp_verk.
        ls_convt-rfbel = ls_lips-vgbel.
        ls_convt-rfpos = ls_lips-vgpos.
      ELSE.
        ls_convt-rfbel = ls_lips-rfbel.
        ls_convt-rfpos = ls_lips-rfpos.
      ENDIF.
      APPEND ls_convt TO lt_convt.
    ENDLOOP.
    endif.
    IF NOT lt_convt[] IS INITIAL.
*     For the ID Handling class the referenc is the LIPS-VEBLN/POSNR
*     and not the PO Nr / PO item
      l_ref_vbeln = v50agl-spe_inb_dlv.
      CALL FUNCTION 'PACKING_CONVERT'
        EXPORTING
          f_vpobj                   = ls_object-object
          t_convt                   = lt_convt
          if_ref_vbeln              = l_ref_vbeln
        CHANGING
          t_verko                   = ct_verko[]
          t_verpo                   = ct_verpo[]
          ct_husernr                = ct_sernr
        EXCEPTIONS
          nothing_to_do             = 0
          shipping_units_deleted    = 1
          delivery_items_not_unique = 2
          delivery_item_missing     = 2
          shipping_units_not_unique = 2
          OTHERS                    = 3.
      IF sy-subrc <> 0.
* convert W message to I message to be stored in the protocoll
        IF sy-subrc = 1.
          sy-msgty = 'I'.
        ELSE.
          PERFORM MESSAGE_STEUERUNG                         "v_n_1379225
                     USING   GS_MHPAR
                             V50AGL-MSGVS
                             'HUFUNCTIONS'
                             '134'
                    CHANGING LF_MSGTY_134
                             LF_SUBRC.
*         Ignore all HU messages if HUFUNCTIONS134 is ignored
          IF LF_SUBRC IS INITIAL.
            SY-MSGTY = LF_MSGTY_134.
          ELSE.
            SY-MSGTY = 'E'.
          ENDIF.                                            "^_n_1379225
        ENDIF.
        PERFORM message_handling(sapmv50a)
                USING posnr_low sy-msgno sy-msgty
                      sy-msgid sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
    ENDIF.
  ELSE.
    LOOP AT ct_verpo INTO ls_verpo WHERE velin CA ' 1' AND
                                         NOT matnr IS INITIAL.
      IF ls_verpo-vbeln IS INITIAL OR ls_verpo-posnr IS INITIAL.
        READ TABLE xlips ASSIGNING <lips>
                         WITH KEY matnr = ls_verpo-matnr
                                  charg = ls_verpo-charg
                                  werks = ls_verpo-werks
                                  lgort = ls_verpo-lgort
                                  bestq = ls_verpo-bestq.
        IF NOT sy-subrc IS INITIAL.
          READ TABLE xlips ASSIGNING <lips>
                           WITH KEY matnr = ls_verpo-matnr
                                    charg = ls_verpo-charg.
        ENDIF.
      ELSE.
        READ TABLE xlips ASSIGNING <lips>
                         WITH KEY vbeln = ls_verpo-vbeln
                                  posnr = ls_verpo-posnr
                                  matnr = ls_verpo-matnr
                                  charg = ls_verpo-charg.
        IF NOT sy-subrc IS INITIAL.                         "v_n_653444
          IF NOT ls_verpo-charg IS INITIAL.
            READ TABLE xlips ASSIGNING <lips>
                             WITH KEY vbeln = ls_verpo-vbeln
                                      charg = ls_verpo-charg
                                      uecha = ls_verpo-posnr.
            IF SY-SUBRC IS NOT INITIAL.
* material might be split valuated, instead of batch managed
                 READ TABLE XLIPS ASSIGNING <LIPS>           "n_1414468
                             WITH KEY VBELN = LS_VERPO-VBELN
                                      POSNR = LS_VERPO-POSNR
                                      BWTAR = LS_VERPO-CHARG
                                      XCHAR = 'X'
                                      XCHPF = ' '
                                      BWTEX = 'X'.
            ENDIF.
          ELSE.
            READ TABLE xlips ASSIGNING <lips>
                             WITH KEY vbeln = ls_verpo-vbeln
                                      posnr = ls_verpo-posnr.
            IF sy-subrc EQ 0.
              IF <lips>-chhpv IS INITIAL OR NOT <lips>-hupos IS INITIAL.
                sy-subrc = 4.
              ENDIF.
            ENDIF.
          ENDIF.                                            "^_n_653444
        ENDIF.
      ENDIF.
      IF sy-subrc IS INITIAL.
        ls_verpo-vbeln = <lips>-vbeln.
        ls_verpo-posnr = <lips>-posnr.
        MODIFY ct_verpo FROM ls_verpo.
      ELSE.
*        message e042(hugeneral).
        sy-msgid = 'HUGENERAL'.
        PERFORM message_handling(sapmv50a)
                USING posnr_low '042' 'E'
                      sy-msgid space space space space.
        REFRESH: ct_verko.
        EXIT.
      ENDIF.
    ENDLOOP.
    IF ct_verko IS INITIAL.
      REFRESH: ct_verpo.
    ENDIF.
  ENDIF.
  ls_packing-display = t180-trtyp.
  ls_packing-init    = charx.
  ls_packing-object  = ls_object-object.
  PERFORM init_complete_packing USING    is_likp
                                CHANGING ls_packing.
  CLEAR ls_verko-status.
  MODIFY ct_verko FROM ls_verko TRANSPORTING status
                                WHERE status NE '0001' AND
                                      status NE '0010'.
*........ fill new tables from VERKO/VERPO ...................
  INCLUDE incl_mv50a_packing_create.
  SORT lt_hu_items BY exidv belnr posnr.
  LOOP AT ct_sernr INTO ls_sernr.
    READ TABLE lt_hu_items ASSIGNING <huitem>
                           WITH KEY exidv = ls_sernr-exidv_ob
                                    belnr = ls_sernr-belnr
                                    posnr = ls_sernr-posnr
                           BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      ADD 1 TO <huitem>-anzsn.
      ls_husernr-zeile = sy-tabix.
      ls_husernr-sernr = ls_sernr-sernr.
ENHANCEMENT-POINT EHP603_MV50AF0F_VERP_HU_01 SPOTS ES_SAPMV50A.
      APPEND ls_husernr TO lt_sernr.
    ENDIF.
  ENDLOOP.

ENHANCEMENT-SECTION     mv50af0f_verp_hu_04 SPOTS es_sapmv50a.

*.SPE PARTIAL GOODS RECEIPT                             "n_v_del_1090134
*  IF ( NOT v50agl-confirm_central IS INITIAL OR
*       NOT v50agl-reinitialize    IS INITIAL ) AND
*     ( NOT v50agl-confirm_central IS INITIAL AND
*           v50agl-spe_partial_confirm IS INITIAL ).
*   IF NOT v50agl-confirm_central IS INITIAL.            "n_^_del_1090134

*--------------------------------------------------------*
*  Delete Handling Units in case of:                     |
*--------------------+---------------+-------------------*
*    Confirm central |  reinitialize | partial_confirm   |
*--------------------+---------------+-------------------+
*         X          |               |                   |
*--------------------+---------------+-------------------+
*                    |       X       |                   |
*--------------------+---------------+-------------------+

  IF   NOT v50agl-reinitialize IS INITIAL  OR                 "_v_1090134
     ( NOT v50agl-confirm_central IS INITIAL AND
           v50agl-spe_partial_confirm IS INITIAL ).           "_^_1090134
    ls_object-objkey = is_likp-vbeln.
*      PERFORM delete_delivery_hus USING ls_object.           "n_1302585
  ENDIF.

  CALL FUNCTION 'V51F_PACKING_CREATE'
    EXPORTING
      it_header_prop = lt_hdr_pro
      it_header_capa = lt_header_cap
      it_header_add  = lt_header_add
      it_header_tra  = lt_header_tra
      it_items       = lt_hu_items
      it_item_sernr  = lt_sernr
      i_temphu       = xvbuk-spe_tmpid "RG N:1080908
    CHANGING
      ct_messages    = lt_messages
    EXCEPTIONS
      fatal_error    = 1
      OTHERS         = 99.
  IF NOT sy-subrc IS INITIAL.
    clear packdaten_verbuchen.                              "1391748
  ELSE.                                                     "v_n_1302585
    IF cl_ops_switch_check=>le_sfws_sc3( ) EQ charx.
      CALL FUNCTION '/SPE/HU_EPC_VENUM_UPDATE'
        EXPORTING
          it_header       = lt_header_hu.
    ENDIF.
    packdaten_verbuchen = charx.                             "1391748                           "^_n_1302585
  ENDIF.
  IF NOT lt_messages IS INITIAL.
*   In case of error messages from packing: Check whether they can be
*   ignored so that delivery can be saved w/o HUs   "v_n_912470/1278049
    lf_msgty_134 = 'E'.
    PERFORM message_steuerung USING    gs_mhpar
                                       v50agl-msgvs
                                       'HUFUNCTIONS'
                                       '134'
                              CHANGING lf_msgty_134
                                       lf_subrc.
    LOOP AT lt_messages INTO ls_message WHERE NOT msgid IS INITIAL.
      IF ls_message-msgty CA 'AEX' AND
         lf_msgty_134 EQ 'E'.
*       Log contains error messages which should not be suppressed:
*       Set return code so that delivery cannot be saved
        ef_rcode = 1.
        PERFORM message_handling USING ls_message-posnr
                                       ls_message-msgno 'E'
                                       ls_message-msgid ls_message-msgv1
                                       ls_message-msgv2 ls_message-msgv3
                                       ls_message-msgv4.
      ELSE.
*       Log contains information messages or packaging errors shall be
*       ignored: Just add message as information to log
*       (delivery will be saved, but w/o HUs)
        PERFORM message_handling USING ls_message-posnr
                                       ls_message-msgno 'I'
                                       ls_message-msgid ls_message-msgv1
                                       ls_message-msgv2 ls_message-msgv3
                                       ls_message-msgv4.
      ENDIF.
    ENDLOOP.
*   In case of errors: add HUFUNCTIONS134 as error message to the log
    IF ef_rcode EQ 1.
      PERFORM message_handling USING posnr_low
                                     '134'
                                     'E'
                                     'HUFUNCTIONS'
                                     space
                                     space
                                     space
                                     space.
      clear packdaten_verbuchen.                            "1391748
    ELSE.
      PERFORM message_handling USING posnr_low
                                     '134'
                                     'I'
                                     'HUFUNCTIONS'
                                     space
                                     space
                                     space
                                     space.
    ENDIF.
  ENDIF.
  if packdaten_verbuchen eq space.
    return.
  endif.
END-ENHANCEMENT-SECTION.
  ls_packing-endrunde = charx.

  PERFORM init_complete_packing USING    is_likp
                                CHANGING ls_packing.
ENDFORM.                    "delivery_packing

*---------------------------------------------------------------------*
*            FORM AUTOMATIC_PACKING_DELIVERY
*---------------------------------------------------------------------*
FORM automatic_packing_delivery USING is_likp LIKE likpvb.
  DATA: lt_messages TYPE huitem_messages_t.
  DATA: ls_packing TYPE vse_s_v51h, ls_message TYPE huitem_messages,
        ls_vbak type vbak,                                     "n_990207
        lf_data_changed TYPE xfeld.

  DATA : ls_vbuk TYPE vbukvb, ls_likp TYPE likp.

*....If Credit block is actif on the delivery, automatic packing should
*....not be available - n_1030361
   READ TABLE xvbuk INTO ls_vbuk WITH KEY vbeln = is_likp-vbeln.
    ls_likp = is_likp.

    CALL FUNCTION 'SD_DELIVERY_SUBSEQUENT_ALLOWED'
      EXPORTING
        blikp   = ls_likp
        bvbuk   = ls_vbuk
        fofun   = '12'
      EXCEPTIONS
        error   = 01
        warning = 02
        OTHERS  = 99.
    IF sy-subrc NE 0.
      IF sy-msgno ne SPACE.
        perform message_handling using ls_message-posnr sy-msgno 'S'
                        sy-msgid sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        EXIT.
      ENDIF.
    ENDIF.

  ls_packing-init = 'X'.
  PERFORM init_complete_packing USING    is_likp
                                CHANGING ls_packing.
ENHANCEMENT-POINT automatic_packing_delivery SPOTS es_sapmv50a.

  IF NOT v50agl-sammelgang IS INITIAL.                      "v_n_876227
* In case of Collective processing clear CVBAK not to get incorrect SD
* reference in the error log.
    ls_vbak = cvbak.                                           "n_990207
    CLEAR cvbak.
  ENDIF.                                                    "^_n_876227

  CALL FUNCTION 'V51P_PACKING_DETERMINATION'
    EXPORTING
      if_call          = 'A'
    IMPORTING
      ef_existing_data = lf_data_changed
      et_messages      = lt_messages
    EXCEPTIONS
      OTHERS           = 99.
  IF NOT sy-subrc IS INITIAL.
    PERFORM message_handling USING posnr_low sy-msgno sy-msgty sy-msgid
                                   sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF NOT lt_messages IS INITIAL.
    LOOP AT lt_messages INTO ls_message WHERE NOT msgid IS INITIAL.
      PERFORM message_handling USING ls_message-posnr
                                     ls_message-msgno ls_message-msgty
                                     ls_message-msgid ls_message-msgv1
                                     ls_message-msgv2 ls_message-msgv3
                                     ls_message-msgv4.
    ENDLOOP.
  ENDIF.
  if not v50agl-sammelgang is initial.                         "n_990207
    cvbak = ls_vbak.
  endif.
  CHECK NOT lf_data_changed IS INITIAL.
  packdaten_verbuchen = charx.
  ls_packing-endrunde = 'X'.
*<<< begin of insert note 356001
  IF is_likp-vbtyp CA vbtyp_mmli OR likp-vbtyp CA vbtyp_lire.
    ls_packing-object = '03'.
  ELSE.
    ls_packing-object = '01'.
  ENDIF.
  PERFORM init_complete_packing USING    is_likp
                                CHANGING ls_packing.
ENDFORM.                    "automatic_packing_delivery
*.....................................................................*
FORM get_printing_data_for_hu USING    if_vbeln LIKE likp-vbeln
                              CHANGING es_vbuk LIKE vbuk.

  READ TABLE xvbuk  WITH KEY mandt = sy-mandt
                             vbeln = if_vbeln.
  es_vbuk = xvbuk.
ENDFORM.                               " GET_VBUK
*&---------------------------------------------------------------------*
*&      Form  DELIVERY_REHANG_HU
*&---------------------------------------------------------------------*
FORM delivery_rehang_hu USING  is_likp           TYPE likpvb
                               it_handling_units TYPE hum_rehang_hu_t
                        CHANGING ef_rcode TYPE sysubrc.

  DATA: lt_messages     TYPE huitem_messages_t,
        lt_hus          TYPE hum_rehang_hu_t,
        lt_handlingunit TYPE hum_rehang_hu_t,
        lt_xhu_items    TYPE vsep_t_vepo,
        lt_hu_heads     TYPE hum_venum_t.                     "n_1072781
  DATA: ls_message  TYPE huitem_messages,
        ls_hu       TYPE hum_rehang_hu,
        ls_packing  TYPE vse_s_v51h,
        ls_object   TYPE hum_object,
        ls_header51 TYPE header51.
  DATA: lf_exidv TYPE exidv,
        lf_venum TYPE venum,
        lf_rcode TYPE sysubrc,
        lf_enh_active TYPE xflag VALUE 'X'.
  FIELD-SYMBOLS: <lips>   TYPE lipsvb,
                 <ls_hus> TYPE hum_rehang_hu.

  IF is_likp-vbtyp CA vbtyp_mmli OR is_likp-vbtyp CA vbtyp_lire.
    ls_object-object = '03'.
  ELSE.
    ls_object-object = '01'.
  ENDIF.
  ls_object-objkey = is_likp-vbeln.
  lt_hus = it_handling_units.
*.... rename document and item number and storage location....
ENHANCEMENT-SECTION     mv50af0f_verp_hu_01 SPOTS es_sapmv50a.
  lf_enh_active = space.
  IF is_likp-updkz = updkz_new.
    LOOP AT xlips ASSIGNING <lips> WHERE vbeln = is_likp-vbeln AND
                                         updkz = updkz_new.
      ls_hu-rfbel = <lips>-vbeln.
      ls_hu-rfpos = <lips>-posnr.
      IF <lips>-vgtyp CA vbtyp_verk AND <lips>-rfbel IS INITIAL.
        CHECK NOT <lips>-vgpos IS INITIAL.
        MODIFY lt_hus FROM ls_hu TRANSPORTING rfbel rfpos
                                 WHERE rfbel = <lips>-vgbel AND
                                       rfpos = <lips>-vgpos.
      ELSE.
        IF <lips>-rfpos IS NOT INITIAL OR
* Always set reference item during repetitive manufacturing confirmation
           ( cl_ewm_switch_check=>le_sfws_sc_ewm_man( ) = gc_true AND
             is_likp-spe_le_scenario = gc_le_scenario-rem ).
          MODIFY lt_hus FROM ls_hu TRANSPORTING rfbel rfpos
                                   WHERE rfbel = <lips>-rfbel AND
                                         rfpos = <lips>-rfpos.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
END-ENHANCEMENT-SECTION.
  SORT lt_hus BY top_hu_internal.

* The following duplicated coding is done because of IS-Automotive.
* As soon as Automotive is switched on, the coding above (in the Enhancement
* Section) is entirely deactivated and relapced by Automotive coding.
* The Automotive Coding however only handles the situation, that LT_HUS-RFBEL
* is filled with LIPS-VGBEL. If LT_HUS-RFBEL is filled with LIPS-RFBEL (for SDP CatFord)
* we would receive a HUGENERAL error, as the rehang fails to replace the delivery number
* here.
  IF lf_enh_active <> space.
    IF is_likp-updkz = updkz_new.
      LOOP AT xlips ASSIGNING <lips> WHERE vbeln = is_likp-vbeln AND
                                           updkz = updkz_new.
        ls_hu-rfbel = <lips>-vbeln.
        ls_hu-rfpos = <lips>-posnr.
        IF <lips>-vgtyp CA vbtyp_verk AND <lips>-rfbel IS INITIAL.
        ELSE.
          CHECK NOT <lips>-rfpos IS INITIAL.
          MODIFY lt_hus FROM ls_hu TRANSPORTING rfbel rfpos
                                   WHERE rfbel = <lips>-rfbel AND
                                         rfpos = <lips>-rfpos.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.
* XC0K005573 - temporary

  LOOP AT lt_hus INTO ls_hu.
    IF lf_exidv NE ls_hu-top_hu_internal.
      PERFORM check_unique_hu USING lt_handlingunit
                           CHANGING lf_rcode.
      IF NOT lf_rcode IS INITIAL.
        EXIT.
      ENDIF.
      REFRESH: lt_handlingunit.
    ENDIF.
    lf_venum = ls_hu-top_hu_internal.
    APPEND ls_hu TO lt_handlingunit.
  ENDLOOP.
  IF NOT lt_handlingunit IS INITIAL.
    PERFORM check_unique_hu USING lt_handlingunit
                         CHANGING lf_rcode.
    REFRESH: lt_handlingunit.
  ENDIF.
  IF NOT lf_rcode IS INITIAL.
*........... HU kann nicht an zwei Lieferungen übergeben werden!
*........... one HU cannot be added to more than one delivery
    MESSAGE e181(hufunctions).
  ENDIF.
  ls_packing-display = t180-trtyp.
  ls_packing-init    = charx.
  ls_packing-object  = ls_object-object.
  PERFORM init_complete_packing USING  is_likp
                                CHANGING ls_packing.
  READ TABLE xlips ASSIGNING <lips> WITH KEY vbeln = is_likp-vbeln.
  IF NOT sy-subrc IS INITIAL.
    EXIT.
  ELSE.
    IF <lips>-updkz = 'D'.
      LOOP AT xlips ASSIGNING <lips> WHERE vbeln = is_likp-vbeln AND
                                           updkz <> 'D'.
        EXIT.
      ENDLOOP.
      IF NOT sy-subrc IS INITIAL. EXIT. ENDIF.
    ENDIF.
  ENDIF.

* SPE: Since X-HUs are not rehanged but copied, it is neccessary to
* unpack HUs from X-HUs
  PERFORM spe_xhu_items_determine TABLES lt_hus
                                         lt_xhu_items
                                         lt_hu_heads.         "n_1072781

  CALL FUNCTION 'HU_ASSIGN_HUS_TO_OBJECT'
    EXPORTING
      is_object         = ls_object
      it_handling_units = lt_hus
    IMPORTING
      et_messages       = lt_messages
    EXCEPTIONS
      error             = 1.
  IF sy-subrc IS INITIAL.                                   "wbr 4.6c
    packdaten_verbuchen = charx.
    ls_packing-endrunde = charx.
    IF NOT lt_messages IS INITIAL.
      LOOP AT lt_messages INTO ls_message WHERE NOT msgid IS INITIAL.
        PERFORM message_handling USING ls_message-posnr
                               ls_message-msgno ls_message-msgty
                               ls_message-msgid ls_message-msgv1
                               ls_message-msgv2 ls_message-msgv3
                               ls_message-msgv4.
      ENDLOOP.
    ENDIF.

* SPE: Now delete the corresponding items in the X-HUs
    PERFORM spe_items_delete TABLES lt_xhu_items
                                    lt_hu_heads.              "n_1072781

    PERFORM init_complete_packing USING    is_likp
                                  CHANGING ls_packing.
  ELSE.
    MESSAGE ID     sy-msgid TYPE   sy-msgty NUMBER sy-msgno
            WITH   sy-msgv1  sy-msgv2  sy-msgv3  sy-msgv4.
  ENDIF.
ENDFORM.                    " DELIVERY_REHANG_HU
*&---------------------------------------------------------------------*
*&      Form  CHECK_UNIQUE_HU
*&---------------------------------------------------------------------*
FORM check_unique_hu USING    it_hus TYPE hum_rehang_hu_t
                     CHANGING ef_rcode TYPE sysubrc.
  DATA: ls_hu TYPE hum_rehang_hu, lf_rfbel TYPE rfbel_vl.

  LOOP AT it_hus INTO ls_hu.
    IF lf_rfbel IS INITIAL.
      lf_rfbel = ls_hu-rfbel.
      CONTINUE.
    ENDIF.
    IF NOT ls_hu-rfbel = lf_rfbel.
      ef_rcode = 4.
      EXIT.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " CHECK_UNIQUE
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_HANDLING_UNITS_QM
*&---------------------------------------------------------------------*
FORM assign_handling_units_qm USING is_likp TYPE likpvb.
  DATA: lt_items TYPE hum_hu_item_t, lt_hum_qm TYPE qmhumtab,
        lt_messages TYPE huitem_messages_t.
  DATA: ls_packing TYPE vse_s_v51h, ls_object TYPE hum_object,
        ls_likp TYPE likpvb, ls_message TYPE huitem_messages.
  DATA: lf_qplos TYPE qplos, lf_vbeln TYPE vbeln_vl.
  FIELD-SYMBOLS: <lips> TYPE lipsvb.

  IF is_likp-vbtyp CA vbtyp_mmli OR is_likp-vbtyp CA vbtyp_lire.
    ls_object-object = '03'.
  ELSE.
    ls_object-object = '01'.
  ENDIF.
  CHECK is_likp-vlstk IS INITIAL.
  ls_likp = is_likp.
  ls_packing-display = t180-trtyp.
  ls_packing-init    = charx.
  ls_packing-object  = ls_object-object.
  LOOP AT xlips ASSIGNING <lips> WHERE NOT qplos IS INITIAL AND
                                       NOT updkz = updkz_delete.
    CHECK <lips>-komkz CA ' ADB'.
    IF NOT <lips>-vbeln = lf_vbeln.
      IF NOT lf_vbeln IS INITIAL.
        ls_packing-endrunde = charx.
        PERFORM init_complete_packing USING    ls_likp
                                      CHANGING ls_packing.
        CLEAR ls_packing-endrunde.
      ENDIF.
      ls_packing-display = t180-trtyp.
      ls_packing-init    = charx.
      ls_packing-object  = ls_object-object.
      READ TABLE xlikp INTO ls_likp WITH KEY vbeln = <lips>-vbeln.
      PERFORM init_complete_packing USING    ls_likp
                                    CHANGING ls_packing.
      lf_vbeln = <lips>-vbeln.
    ENDIF.
    IF NOT <lips>-qplos = lf_qplos AND NOT lf_qplos IS INITIAL.
      CALL FUNCTION 'QHUG_GET_HU'
        EXPORTING
          i_prueflos = lf_qplos
        IMPORTING
          e_hulist   = lt_hum_qm
        EXCEPTIONS
          no_entry   = 1
          OTHERS     = 99.
      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.
      lf_qplos = <lips>-qplos.
      ls_object-objkey = lf_vbeln.
      CALL FUNCTION 'HU_ASSIGN_HUS_TO_OBJECT'
        EXPORTING
          is_object   = ls_object
          it_hum_qm   = lt_hum_qm
        IMPORTING
          et_messages = lt_messages
        EXCEPTIONS
          error       = 01.
      IF sy-subrc <> 0.
        PERFORM message_handling USING <lips>-posnr
                                 sy-msgno sy-msgty sy-msgid sy-msgv1
                                 sy-msgv2 sy-msgv3 sy-msgv4.
      ELSE.
        IF NOT lt_messages IS INITIAL.
          LOOP AT lt_messages INTO ls_message WHERE NOT msgid IS INITIAL.
            PERFORM message_handling USING ls_message-posnr
                                     ls_message-msgno ls_message-msgty
                                     ls_message-msgid ls_message-msgv1
                                     ls_message-msgv2 ls_message-msgv3
                                     ls_message-msgv4.
          ENDLOOP.
        ENDIF.
        packdaten_verbuchen = charx.
      ENDIF.
    ELSE.
      lf_qplos = <lips>-qplos.
      CONTINUE.
    ENDIF.
  ENDLOOP.
  IF NOT lf_qplos IS INITIAL.
    CALL FUNCTION 'QHUG_GET_HU'
      EXPORTING
        i_prueflos = lf_qplos
      IMPORTING
        e_hulist   = lt_hum_qm
      EXCEPTIONS
        no_entry   = 1
        OTHERS     = 99.
    IF sy-subrc <> 0.
      EXIT.
    ENDIF.
    lf_qplos = <lips>-qplos.
    ls_object-objkey = lf_vbeln.
    CALL FUNCTION 'HU_ASSIGN_HUS_TO_OBJECT'
      EXPORTING
        is_object   = ls_object
        it_hum_qm   = lt_hum_qm
      IMPORTING
        et_messages = lt_messages
      EXCEPTIONS
        error       = 01.
    IF sy-subrc <> 0.
      PERFORM message_handling USING <lips>-posnr
                               sy-msgno sy-msgty sy-msgid sy-msgv1
                               sy-msgv2 sy-msgv3 sy-msgv4.
    ELSE.
      IF NOT lt_messages IS INITIAL.
        LOOP AT lt_messages INTO ls_message WHERE NOT msgid IS INITIAL.
          PERFORM message_handling USING ls_message-posnr
                                   ls_message-msgno ls_message-msgty
                                   ls_message-msgid ls_message-msgv1
                                   ls_message-msgv2 ls_message-msgv3
                                   ls_message-msgv4.
        ENDLOOP.
      ENDIF.
      packdaten_verbuchen = charx.
    ENDIF.
    ls_packing-endrunde = charx.
    PERFORM init_complete_packing USING    ls_likp
                                  CHANGING ls_packing.
  ENDIF.
ENDFORM.                    "ASSIGN_HANDLING_UNITS
*----------------------------------------------------------------------*
FORM delivery_repack_hu USING is_likp LIKE likpvb
                              it_repack TYPE hum_repack_t
                              it_repack_sernr TYPE vsep_t_zsernr.
  DATA: lt_messages TYPE huitem_messages_t.
  DATA: ls_init TYPE vse_s_v51h, ls_message TYPE huitem_messages.

  IF NOT xvbuk-vbeln = is_likp-vbeln.                       " 779895
    READ TABLE xvbuk WITH KEY vbeln = is_likp-vbeln.
  ENDIF.

  IF xvbuk-wbstk = 'C'.
*   message e018(hudialog).
    PERFORM message_handling USING posnr_low '018' 'E' 'HUDIALOG'
                                   space space space space.
    EXIT.
  ENDIF.

  ls_init-init = charx.
  PERFORM init_complete_packing USING  is_likp
                                CHANGING ls_init.

  CALL FUNCTION 'HU_REPACK'
    EXPORTING
      it_repack       = it_repack
      it_repack_sernr = it_repack_sernr
    IMPORTING
      et_messages     = lt_messages
    EXCEPTIONS
      not_possible    = 1
      OTHERS          = 99.
  IF NOT sy-subrc IS INITIAL.
    PERFORM message_handling(sapmv50a) USING posnr_low sy-msgno sy-msgty
                          sy-msgid sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF NOT lt_messages IS INITIAL.
      LOOP AT lt_messages INTO ls_message WHERE NOT msgid IS INITIAL.
        PERFORM message_handling USING ls_message-posnr
                               ls_message-msgno ls_message-msgty
                               ls_message-msgid ls_message-msgv1
                               ls_message-msgv2 ls_message-msgv3
                               ls_message-msgv4.
      ENDLOOP.
    ENDIF.
    ls_init-endrunde = 'X'.
    PERFORM init_complete_packing(sapmv50a) USING    is_likp
                                            CHANGING ls_init.
  ENDIF.

ENDFORM.                    "delivery_repack_hu
*&---------------------------------------------------------------------*
*&      Form  ASSIGN_HU_TO_DELIVERY
*&---------------------------------------------------------------------*
FORM assign_hu_to_delivery USING is_likp TYPE likpvb
                                 it_handling_units TYPE hum_rehang_hu_t.
  DATA: lt_messages TYPE huitem_messages_t.
  DATA: ls_exidv TYPE hum_exidv, lt_exidv TYPE hum_exidv_t,
        ls_hu TYPE hum_rehang_hu, ls_message TYPE huitem_messages,
        ls_packing TYPE vse_s_v51h.
  DATA: lf_rcode TYPE sysubrc.

  IF NOT xvbuk-vbeln = is_likp-vbeln.                       " 779895
    READ TABLE xvbuk WITH KEY vbeln = is_likp-vbeln.
  ENDIF.

  IF xvbuk-wbstk = 'C'.
*   message e018(hudialog).
    PERFORM message_handling USING posnr_low '018' 'E' 'HUDIALOG'
                                   space space space space.
    EXIT.
  ENDIF.
  IF is_likp-vbtyp CA vbtyp_mmli OR is_likp-vbtyp CA vbtyp_lire.
    ls_packing-object = '03'.
  ELSE.
    ls_packing-object = '01'.
  ENDIF.
  ls_packing-display = t180-trtyp.
  ls_packing-init    = charx.
  PERFORM init_complete_packing USING    is_likp
                                CHANGING ls_packing.
  LOOP AT it_handling_units INTO ls_hu.
    CHECK NOT ls_hu-top_hu_external IS INITIAL.
    ls_exidv-exidv = ls_hu-top_hu_external.
    APPEND ls_exidv TO lt_exidv.
  ENDLOOP.
  CALL FUNCTION 'V51P_ADD_HU_TO_OBJEKT'
    EXPORTING
      it_hus        = lt_exidv
    IMPORTING
      ef_rcode      = lf_rcode
      et_messages   = lt_messages
    EXCEPTIONS
      hus_locked    = 1
      not_possible  = 2
      nothing_found = 3
      fatal_error   = 4
      OTHERS        = 99.

  IF sy-subrc <> 0.
    PERFORM message_handling USING posnr_low
                           sy-msgno sy-msgty sy-msgid sy-msgv1
                           sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
  IF NOT lt_messages IS INITIAL.
    LOOP AT lt_messages INTO ls_message WHERE NOT msgid IS INITIAL.
      PERFORM message_handling USING ls_message-posnr
                             ls_message-msgno ls_message-msgty
                             ls_message-msgid ls_message-msgv1
                             ls_message-msgv2 ls_message-msgv3
                             ls_message-msgv4.
    ENDLOOP.
  ELSE.
    IF sy-subrc IS INITIAL.
      packdaten_verbuchen = charx.
    ENDIF.
  ENDIF.
  CHECK sy-subrc IS INITIAL.
  ls_packing-endrunde = charx.
  PERFORM init_complete_packing USING    is_likp
                                CHANGING ls_packing.
ENDFORM.                    " ASSIGN_HU_TO_DELIVERY
*&---------------------------------------------------------------------*
*&      Form  DELETE_DELIVERY_HUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM delete_delivery_hus USING is_object TYPE hum_object.

  DATA: lt_header           TYPE hum_hu_header_t,
        lt_highest          TYPE hum_venum_t,
        lt_items            TYPE hum_hu_item_t,
        ls_venum            TYPE hum_venum,
        lv_delete_hierarchy TYPE xflag.
  FIELD-SYMBOLS: <header> TYPE vekpvb,
                 <item>   TYPE vepovb.

*.... get all HU from memory
  CALL FUNCTION 'V51P_GET_TABLES'
    EXPORTING
      if_object        = is_object-object
    IMPORTING
      et_xvekp         = lt_header
      et_xvepo         = lt_items
      et_highest_level = lt_highest
    EXCEPTIONS
      OTHERS           = 0.
  IF v50agl-confirm_central = charx.
    lv_delete_hierarchy = charx.
  ENDIF.
  CALL FUNCTION '/SPE/HU_X_DLVRY_DELETE_HUITEM'
    EXPORTING
      is_object           = is_object
      iv_delete_hierarchy = lv_delete_hierarchy
      it_xvbfa            = xvbfa[]
    CHANGING
      ct_header           = lt_header
      ct_item             = lt_items.

  SORT lt_highest BY venum.
  SORT lt_items BY venum.

  LOOP AT lt_header ASSIGNING <header>
                    WHERE vpobjkey =  is_object-objkey
* No deletion of X-delivery HUs
                    AND   vpobj    <> gc_pacobj-x_obdlvry
                    AND   vpobj    <> gc_pacobj-x_ibdlvry.

    IF <header>-uevel IS INITIAL.
      READ TABLE lt_highest TRANSPORTING NO FIELDS
                            WITH KEY venum = <header>-venum
                            BINARY SEARCH.
      IF NOT sy-subrc IS INITIAL.     "HU im Transport verpackt
        LOOP AT lt_items ASSIGNING <item> WHERE unvel = <header>-venum.
          CALL FUNCTION 'V51P_XVEPO_YVEPO_UPDATE'
            EXPORTING
              if_updkz = 'D'
              is_vepo  = <item>
            EXCEPTIONS
              OTHERS   = 0.
        ENDLOOP.
      ENDIF.
    ENDIF.
    READ TABLE lt_items TRANSPORTING NO FIELDS
                        WITH KEY venum = <header>-venum
                        BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      LOOP AT lt_items ASSIGNING <item> FROM sy-tabix.
        IF NOT <item>-venum = <header>-venum. EXIT. ENDIF.
* adopt QMHU if necessary
        IF NOT <item>-qplos IS INITIAL.                     "SP_559628
          <item>-updkz = 'D'.
          PERFORM actualize_qmhu(saplv51p) USING <header>-exidv <item>
                                                 space.
        ENDIF.
        CALL FUNCTION 'V51P_XVEPO_YVEPO_UPDATE'
          EXPORTING
            if_updkz = 'D'
            is_vepo  = <item>
          EXCEPTIONS
            OTHERS   = 0.
      ENDLOOP.
    ENDIF.
    CALL FUNCTION 'V51P_XVEKP_YVEKP_UPDATE'
      EXPORTING
        if_updkz = 'D'
        is_vekp  = <header>
      EXCEPTIONS
        OTHERS   = 0.
  ENDLOOP.
ENDFORM.                    " DELETE_DELIVERY_HUS
*&---------------------------------------------------------------------*
*&      Form  create_xpackvbfa_ypackvbfa
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM create_xpackvbfa_ypackvbfa USING is_likp LIKE likpvb
                                CHANGING cs_packing TYPE vse_s_v51h.
  CLEAR vpobj.
  IF likp-vbtyp CA vbtyp_mmli OR likp-vbtyp CA vbtyp_lire.
    cs_packing-object = '03'.
  ELSE.
    cs_packing-object = '01'.
  ENDIF.
  vpobj = cs_packing-object.
  REFRESH xpackvbfa.
  CLEAR xpackvbfa.
  REFRESH ypackvbfa.
  CLEAR ypackvbfa.
  READ TABLE xvbfa TRANSPORTING NO FIELDS
                   WITH KEY vbelv = is_likp-vbeln
                            vbtyp_n = charx.
  IF sy-subrc IS INITIAL.
    LOOP AT xvbfa FROM sy-tabix.
      IF xvbfa-vbelv NE is_likp-vbeln.
        EXIT.
      ENDIF.
      IF xvbfa-vbtyp_n NE charx.
        CONTINUE.
      ENDIF.
      xpackvbfa = xvbfa. APPEND xpackvbfa.
    ENDLOOP.
  ENDIF.
  READ TABLE xvbfa WITH KEY vbelv = is_likp-vbeln
                            vbtyp_n = '8'.                "note 773858
  IF sy-subrc IS INITIAL.
* Store all Shipments that contain this delivery. Useful     "n_v_897997
* to check if delivery-HUs are packed in Transport.
    LOOP AT xvbfa FROM sy-tabix.
* ....According to the LOOP above, it seems XVBFA is sorted by VBELN.
      IF xvbfa-vbelv NE is_likp-vbeln.
        EXIT.
      ENDIF.
      CHECK xvbfa-vbtyp_n = '8'.
      xpackvbfa = xvbfa.
      APPEND xpackvbfa.
    ENDLOOP.                                                "n_^_897997
      sort xpackvbfa.                                          "n_936951
  ENDIF.
  LOOP AT yvbfa WHERE vbtyp_n = 'X'.
    ypackvbfa = yvbfa. APPEND ypackvbfa.
  ENDLOOP.
*-prepare tvfo call in function group:
*   PERFORM UC_INTERNAL_UPDATE(SAPFV50U).

  IF status_transport EQ 3.                   "shipping units freight
    cs_packing-display = chara.
    IF cs_packing-init IS INITIAL.
      MESSAGE ID 'VW' TYPE 'I' NUMBER 298.
    ENDIF.
  ENDIF.
  CASE is_likp-vbtyp.
    WHEN 'J'.
      cs_packing-profile = '0002'.
    WHEN '7' OR 'g'.
      cs_packing-profile = '0001'.
    WHEN 'T'.
      cs_packing-profile = '0003'.
  ENDCASE.
ENDFORM.                    " create_xpackvbfa_ypackvbfa
*&---------------------------------------------------------------------*
*&      Form  DELETE_DELIVERY_HUS_PGR
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
FORM delete_delivery_hus_pgr                                 "n_1302585
                            TABLES it_verko STRUCTURE verko
                                   it_verpo STRUCTURE verpo
                            USING is_object TYPE hum_object.

  DATA: lt_header           TYPE hum_hu_header_t,
        lt_highest          TYPE hum_venum_t,
        lt_items            TYPE hum_hu_item_t,
        ls_venum            TYPE hum_venum,
        ls_item             TYPE vepovb,
        lv_delete_hierarchy TYPE xflag.
  FIELD-SYMBOLS: <header> TYPE vekpvb,
                 <item>   TYPE vepovb,
                 <headerprop> TYPE verko,
                 <itemprop>   TYPE verpo.                 .

*.... get all HU from memory
  CALL FUNCTION 'V51P_GET_TABLES'
    EXPORTING
      if_object        = is_object-object
    IMPORTING
      et_xvekp         = lt_header
      et_xvepo         = lt_items
      et_highest_level = lt_highest
    EXCEPTIONS
      OTHERS           = 0.
  IF v50agl-confirm_central = charx.
    lv_delete_hierarchy = charx.
  ENDIF.
  CALL FUNCTION '/SPE/HU_X_DLVRY_DELETE_HUITEM'
    EXPORTING
      is_object           = is_object
      iv_delete_hierarchy = lv_delete_hierarchy
      it_xvbfa            = xvbfa[]
    CHANGING
      ct_header           = lt_header
      ct_item             = lt_items.

  SORT lt_highest BY venum.
  SORT lt_items BY venum.

  LOOP AT it_verko  ASSIGNING <headerprop>.
    READ TABLE lt_header ASSIGNING <header>
                      WITH KEY vpobjkey =  is_object-objkey
                               exidv    = <headerprop>-exidv.
    IF sy-subrc IS INITIAL.
* No deletion of X-delivery HUs
    CHECK <header>-vpobj <> gc_pacobj-x_obdlvry.
    CHECK <header>-vpobj <> gc_pacobj-x_ibdlvry.

      IF <header>-uevel IS INITIAL.
        READ TABLE lt_highest TRANSPORTING NO FIELDS
                              WITH KEY venum = <header>-venum
                              BINARY SEARCH.
        IF NOT sy-subrc IS INITIAL.     "HU im Transport verpackt
* delete HU reference in transport HU
          LOOP AT lt_items ASSIGNING <item> WHERE unvel = <header>-venum.
            CALL FUNCTION 'V51P_XVEPO_YVEPO_UPDATE'
              EXPORTING
                if_updkz = 'D'
                is_vepo  = <item>
              EXCEPTIONS
                OTHERS   = 0.
          ENDLOOP.
          DELETE lt_items WHERE unvel = <header>-venum.
        ENDIF.
      ENDIF.
      READ TABLE lt_items TRANSPORTING NO FIELDS
                          WITH KEY venum = <header>-venum
                          BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        LOOP AT lt_items ASSIGNING <item> FROM sy-tabix.
          IF NOT <item>-venum = <header>-venum. EXIT. ENDIF.
* adopt QMHU if necessary
          IF NOT <item>-qplos IS INITIAL.                     "SP_559628
            <item>-updkz = 'D'.
            PERFORM actualize_qmhu(saplv51p) USING <header>-exidv <item>
                                                   space.
          ENDIF.
          CALL FUNCTION 'V51P_XVEPO_YVEPO_UPDATE'
            EXPORTING
              if_updkz = 'D'
              is_vepo  = <item>
            EXCEPTIONS
              OTHERS   = 0.
        ENDLOOP.
        DELETE lt_items WHERE venum = <header>-venum.
      ENDIF.

      CALL FUNCTION 'V51P_XVEKP_YVEKP_UPDATE'
        EXPORTING
          if_updkz = 'D'
          is_vekp  = <header>
        EXCEPTIONS
          OTHERS   = 0.
    ENDIF.
* we also have to check whether cofirmed items are already packed somewhere else than into
* the HU just coming for confirmation - then need to unpack that item
      LOOP AT it_verpo ASSIGNING <itemprop> WHERE exidv_ob = <headerprop>-exidv.
        READ TABLE lt_items WITH KEY vbeln = <itemprop>-vbeln
                                     posnr = <itemprop>-posnr
                            INTO ls_item.
        IF sy-subrc IS INITIAL.
          LOOP AT lt_items ASSIGNING <item> FROM sy-tabix.
            IF <item>-vbeln = <itemprop>-vbeln AND <item>-posnr = <itemprop>-posnr.
* adopt QMHU if necessary
              IF NOT <item>-qplos IS INITIAL.                     "SP_559628
                <item>-updkz = 'D'.
                PERFORM actualize_qmhu(saplv51p) USING <headerprop>-exidv <item>   "n_1360546
                                                       space.
              ENDIF.
              CALL FUNCTION 'V51P_XVEPO_YVEPO_UPDATE'
                EXPORTING
                  if_updkz = 'D'
                  is_vepo  = <item>
                EXCEPTIONS
                  OTHERS   = 0.
            ENDIF.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
  ENDLOOP.
ENDFORM.                    " DELETE_DELIVERY_HUS_PGR

FORM add_missing_data TABLES   IT_VERPO STRUCTURE VERPO             "v_n_1351733
                               IT_XLIPS STRUCTURE XLIPS.

field-symbols: <fs_verpo> type VERPO,
               <fs_xlips> type lipsvb.

 LOOP AT IT_VERPO assigning <fs_verpo> WHERE matnr is initial and velin = '1'.
   READ TABLE IT_XLIPS assigning <fs_xlips> WITH KEY VBELN = IT_VERPO-VBELN
                                                     POSNR = IT_VERPO-POSNR.
      IF SY-SUBRC eq 0.
       <fs_verpo>-matnr = <fs_xlips>-matnr.
      ENDIF.
 ENDLOOP.
endform.                                                            "^_n_1351733
*&---------------------------------------------------------------------*
*&      Form  REHANG_REJECTED_HUS
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REHANG_REJECTED_HUS
                            TABLES it_vbpok STRUCTURE vbpok
                            USING  is_object TYPE hum_object
                            CHANGING lf_reject TYPE xfeld.

* if all positions of a two-step stock transfer inbound delivery
* are sent with qty 0
* -> we suppose that it is a rejection and rehang all the
* HUs to the outbound delivery

* if it is a one-step posting, the HU has to be unassigned
* note 1389719

 DATA: lt_header           TYPE hum_hu_header_t,
       lt_highest          TYPE hum_venum_t,
       lt_items            TYPE hum_hu_item_t,
       lt_messages         TYPE HUITEM_MESSAGES_T.

 FIELD-SYMBOLS: <lips> type lipsvb.
                                                             "n_1389719
 READ TABLE XLIPS ASSIGNING <LIPS> WITH KEY POSTING_CHANGE = 'C'.

* check that this is a two-step stock transfer
 check xlikp-spe_lifex_type
               = gc_lifex_type-nostotransfer or
       xlikp-spe_lifex_type
               =  GC_LIFEX_TYPE-STOCKTRANSFER OR
       SY-SUBRC = 0.

 lf_reject ='X'.
 loop at xlips assigning <lips>.
   read table it_vbpok with key
                    VBELN_VL = <lips>-vbeln
                    POSNR_VL = <lips>-posnr
                    LFIMG = '0'.
   if sy-subrc ne 0.
     clear lf_reject.
   endif.
 endloop.
 check lf_reject = 'X'.
*.... get all HU from memory
  CALL FUNCTION 'V51P_GET_TABLES'
    EXPORTING
      if_object        = is_object-object
    IMPORTING
      et_xvekp         = lt_header
      et_xvepo         = lt_items
      et_highest_level = lt_highest
    EXCEPTIONS
      OTHERS           = 0.

 CALL FUNCTION 'V51P_DELETE_RELATIONSHIP'
   EXPORTING
     IT_HUS            = lt_highest
     IF_CONTROL        = CHARX                              "n_1442312
  IMPORTING
*    ET_NEW_HUS        =
     ET_MESSAGES       = lt_messages
  EXCEPTIONS
    FATAL_ERROR       = 1
    OTHERS            = 2
           .
 IF SY-SUBRC <> 0 or lt_messages is not initial.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
   clear lf_reject.
 ENDIF.
ENDFORM.