*----------------------------------------------------------------------*
*   INCLUDE MV50AF0B_BESTELLUNG_EKES_FUELL                             *
*----------------------------------------------------------------------*
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_EKES_FUELLEN                                  *
*---------------------------------------------------------------------*
*       Aus dem Lieferavis wird die Bestellung via EKES informiert    *
*---------------------------------------------------------------------*
form bestellung_ekes_fuellen
                  using is_enhancement type isu_bestellung_ekes_fuellen."IS2ERP

  constants: lc_ibtyp_9        type t163d-ibtyp  value '9'.

  data: ekes_pos like sy-tfill value 0,
        kz_kopf_geaendert(1)   value ' ',                   "571740
        l_msg(1)               value 'X',                   "571740
        l_upd_from_hold        type c,                          "hold
        lv_create_ekes         type c,                      "n_1531243
        lf_badi_me_conf        type ref to /spe/cd_me_confirmation,
        ls_ekpo                type ekpo.

  data: t_ekes_upd like uekes occurs 0
                              with header line.
  data: lf_ebelp type ebelp.                                "n_1286659

  data: lt_apodlv_pro TYPE TABLE OF vsrdlv_pro,
        ls_apodlv_pro TYPE vsrdlv_pro,
        lv_trguid     TYPE cs_guidc.

  data: lt_ekes       TYPE mmpr_uekes,                      "v_n_1679467
        ls_ekes       TYPE uekes,
        ls_lips       TYPE lipsvb,
        xlips_tabix   LIKE sy-tabix.                        "^_n_1679467

* IS2ERP
  data: ls_best_ekes_aus_lips type isu_best_ekes_aus_lips.
enhancement-point mv50af0b_bestellung_ekes_fue_5 spots es_sapmv50a static .

  check: v50agl-no_ekes_update eq space.                    "n_1013824

* For Transportation Cross-Docking for STO's multiple Inbound Deliveries
* are created. However only one (the last one) should be a confirmation
* for table EKES. In all other cases, the following BADI is supposed to
* clear lfart_besttyp - or at least change it to a different confirmation
* type (not '1')
  data: lf_no_po_update type xfeld.                         "n_987077
  get badi lf_badi_me_conf.
  call badi lf_badi_me_conf->change_ibtyp
    exporting
      it_likp         = xlikp[]
      it_lips         = xlips[]
      it_vbpa         = xvbpa[]
    changing
      cv_ibtyp        = lfart_besttyp
      cv_no_po_update = lf_no_po_update.                    "v_n_987077

  check: lf_no_po_update is initial.                        "^_n_987077
  check: v50agl-spe_auto_gr ne /spe/cl_id_handling=>c_auto_gr-posting. "2
*                                                      note 1503583/1517780

* Zurücksetzen der Kommunikationsdatei
  refresh: xuekes.
  refresh: xekes_conv_qty.                                  "457360
  refresh: xekesu.                                          "713023

* prüfen, ob sich im Lieferkopf relevante Daten geändert haben
* if xlikp-updkz eq updkz_update.                               "438392
  if xlikp-updkz eq updkz_update or                         "455748
     ( xlikp-updkz eq updkz_new and xlikp-vbtyp na vbtyp_grwe ).
    read table ylikp with key xlikp(13).
enhancement-section     mv50af0b_bestellung_ekes_fue_1 spots es_sapmv50a.
    if xlikp-lfdat ne ylikp-lfdat or
       xlikp-lfuhr ne ylikp-lfuhr or
       xlikp-vbeln ne ylikp-vbeln or                        "438392
       xlikp-imwrk ne ylikp-imwrk or                        "n_605460
       xlikp-lifex ne ylikp-lifex.
      kz_kopf_geaendert = charx.
    endif.

end-enhancement-section.

  endif.

* Cross-Docking: Goods Receipt for CD Inbound Delivery is not communicated via
*                MM document to APO (ME_CONFIRMATION_MAINTAIN_GR.
*                Instead we need to communicate it here directly.
  if lfart_besttyp eq lc_ibtyp_9 and
     not v50agl-confirm_central is initial.
    kz_kopf_geaendert = charx.
  endif.

*---------------------------------------------------------------------*
*       Löschen von Positionen                                        *
*---------------------------------------------------------------------*
  break-point id /spe/inb_hold.

enhancement-point mv50af0b_bestellung_ekes_fue_2 spots es_sapmv50a.

  loop at ylips where vbeln eq xlikp-vbeln.
    if ylips-updkz = updkz_delete and
       ylips-vgtyp = charv.
      read table xlips with key vbeln = ylips-vbeln          "n_1229227
                                posnr = ylips-posnr.         "n_1229227
      perform best_ekes_aus_lips using ylips-updkz
                                       ls_best_ekes_aus_lips."IS2ERP
*   SPE INB RG delivery in hold status 17.11.2003
    elseif ylips-vgtyp = charv.
*     Delete wrong lines from EKES
      read table xlips with key vbeln = ylips-vbeln
                                posnr = ylips-posnr.
      if sy-subrc = 0 and
         ( xlips-vgbel <> ylips-vgbel or
           xlips-vgpos <> ylips-vgpos or
           xlips-matnr <> ylips-matnr ).                    "AP624077
        perform best_ekes_aus_lips using updkz_delete
                                         ls_best_ekes_aus_lips."IS2ERP
        .
      endif.
    endif.
  endloop.

*---------------------------------------------------------------------*
*       Hinzufügen oder verändern von Positionen                      *
*---------------------------------------------------------------------*
  loop at xlips where vbeln eq xlikp-vbeln.
    xlips_tabix = sy-tabix + 1.                               "n_1679467

    if v50agl-force_po_update ne space and                  "v_n_1286659
       xlips-vgtyp eq vbtyp_bestell    and
       xlips-vgbel ne space.
*     Skip purchase order update if PO is already archived and inbound
*     delivery should be closed through transaction VL_COMPLETE
      lf_ebelp = xlips-vgpos.                                 "n_1451838
      call function 'ME_EKPO_SINGLE_READ'
        exporting
          pi_ebeln         = xlips-vgbel
          pi_ebelp         = lf_ebelp
        exceptions
          no_records_found = 1
          others           = 2.
      if sy-subrc ne 0.
        continue.
      endif.
    endif.                                                  "^_n_1286659

*   SPE INB RG hold status on item level
    break-point id /spe/inb_hold.
*   Read VBUP for the LIPS. (VBUP is used for the HOLD items)
    read table xvbup with key vbeln = xlips-vbeln
                              posnr = xlips-posnr
                     binary search.
    assert id /spe/inb_hold condition sy-subrc = 0.

* no changes on item level => no warning messages               "571740
    if xlips-updkz is initial or ( xlips-uecha is initial "571740 "597817
                               and sy-tcode(2) = 'VL' ).      "n_1417723
      clear l_msg.                                          "571740
    else.                                                   "571740
      l_msg = 'X'.                                          "571740
    endif.                                                  "571740
    clear l_upd_from_hold.
enhancement-point mv50af0b_bestellung_ekes_fue_6 spots es_sapmv50a.

* By changing of "On hold" delivery, "On hold" delivery     "v_1531243
* positions are to be deleted and new positions are to be
* created. Entries in table EKES which correspond to
* "On hold" delivery are deleted, for the new positions
* new EKES entries should get created. Call of Form routine
* best_ekes_aus_lips is therefore necessary for creation of
* new EKES entries
    clear lv_create_ekes.
    if xlips-updkz eq updkz_new.
      read table yvbup with key vbeln = xlips-vbeln
                                posnr = xlips-posnr
                       binary search.
      if ( sy-subrc is initial and xvbup-hdall ne yvbup-hdall )
                                     " 'On hold' changed to 'non hold';
         or not sy-subrc is initial. " new added position
                                     " which has no yvbup entry
        lv_create_ekes = 'X'.
      endif.
    endif.                                                  "^ 1531243

    if xlips-updkz eq updkz_new  and   "Position wird hinzugefügt
       ( kz_kopf_geaendert ne charx   or                    "n_438392
         xlikp-vbtyp ca vbtyp_grwe    or                    "n_455748
         not lv_create_ekes is initial or                   "n_1531243
         xlikp-lfdat eq ylikp-lfdat ) and                   "n_692687
       xlips-vgtyp = charv.

enhancement-section     mv50af0b_bestellung_ekes_fue_3 spots es_sapmv50a.
      perform best_ekes_aus_lips using xlips-updkz
                                       ls_best_ekes_aus_lips."IS2ERP
end-enhancement-section.
      check 1 = 2.
    endif.
    if ( xlips-updkz eq updkz_update  or   "Position oder Kopf wird
         kz_kopf_geaendert eq charx ) and  "verändert
         xlips-vgtyp = charv and
         v50agl-warenausg_storno is initial.                "760011
*     delivery header or item is marked for update
      read table ylips with key vbeln = xlikp-vbeln
                                posnr = xlips-posnr
                                updkz = updkz_delete
                                transporting no fields
                                binary search.
      if sy-subrc ne 0.
*       delivery item is not marked for deletion
*       SPE INB RG 19.11.2004 HOLD
        break-point id /spe/inb_hold.
*       set update indicator for the EKES line

enhancement-point mv50af0b_bestellung_ekes_fue_4 spots es_sapmv50a.

        clear l_upd_from_hold.
        read table ylips with key vbeln = xlikp-vbeln
                                  posnr = xlips-posnr
                                  binary search.
        if sy-subrc = 0 and
          ( xlips-vgbel <> ylips-vgbel or
            xlips-vgpos <> ylips-vgpos or
            xlips-matnr <> ylips-matnr ).
*         new ekes line is needed because ref.doc. changed
          l_upd_from_hold = updkz_new.
        endif.
*       create EKES line from the LIPS
        if kz_kopf_geaendert ne charx or                    "577161
           not xlips-updkz is initial.                      "577161
          if l_upd_from_hold is initial.
            perform best_ekes_aus_lips using xlips-updkz    "577161
                                             ls_best_ekes_aus_lips."IS2ERP
          else.
            perform best_ekes_aus_lips using l_upd_from_hold
                                             ls_best_ekes_aus_lips."IS2ERP
          endif.
        else.                                               "577161
          if l_upd_from_hold is initial.
            perform best_ekes_aus_lips using updkz_update   "577161
                                             ls_best_ekes_aus_lips."IS2ERP
          else.
            perform best_ekes_aus_lips using l_upd_from_hold
                                             ls_best_ekes_aus_lips."IS2ERP
          endif.
        endif.                                              "577161
      endif.
    endif.
*   if kz_kopf_geaendert eq charx and xlips-vgtyp = charv.      "575627
    break-point id /spe/inb_hold.
    if ( kz_kopf_geaendert eq charx or                      "575627
         xlips-updkz = 'U'  )                           "575627 "597817
*      SPE INB RG hold status on item level
       and xlips-updkz <> 'D'                               "650463
       and xlips-vgtyp = charv.                             "575627
      xuekes-ebeln = xlips-vgbel.
      xuekes-ebelp = xlips-vgpos.
*   Bei Änderung von relevanten Kopffeldern (Lieferdatum, Lieferuhrzeit
*   und Lieferungsnummer der Lieferanten muß für die Bestellbestätigung
*   die Umrechnung der Lieferavis-ME in Bestell-ME erfolgen. Achtung:
*   XUEKES steht zur Verfügung, da die vorherige Routine in diesem Fall
*   abläuft. Dieser Vorgang ist nur relevant bei Änderung, da bei
*   Anlegen KZ_KOPF_GEAENDERT nicht gesetzt ist.
      sort xuekes by mandt ebeln ebelp vbeln vbelp.
      data: l_vbeln like likp-vbeln.                        "v 438392
*     SPE INB RG hold status on item level                  "541798
      break-point id /spe/inb_hold.
      if xlips-updkz     eq updkz_new or
         l_upd_from_hold eq updkz_new or                   "v_1080444
         lfart_besttyp   eq lc_ibtyp_9.                    "^_1080444
        clear l_vbeln.
      else.
        l_vbeln = xlikp-vbeln.
      endif.                                                "^ 438392
      data: l_umvkz like lips-umvkz,                        "457360
            l_umvkn like lips-umvkn.                        "457360

      if ( xlips-umvkz = xlips-umrez and               "v566027 "611487
           xlips-umvkn = xlips-umren ) or xlips-kzfme ca 'AB'."611487
* same conversion factors
        l_umvkz = 1.
        l_umvkn = 1.
      elseif xlips-umvkz = 1 and xlips-umvkn = 1.
* base unit in delivery
        l_umvkz = xlips-umrez.
        l_umvkn = xlips-umren.
      elseif xlips-umrez = 1 and xlips-umren = 1.
* base unit in purchase order
        l_umvkz = xlips-umvkn.
        l_umvkn = xlips-umvkz.
      elseif xlips-umvkn = 1 and xlips-umren = 1.
* whole-numbered multiples
        l_umvkz = xlips-umrez.                              "589711
        l_umvkn = xlips-umvkz.                              "589711
      else.
        call function 'ME_CONVERSION_MULTIPLY'              "v_879083
          exporting
            i_umren1       = xlips-umvkn
            i_umren2       = xlips-umren
            i_umrez1       = xlips-umvkz
            i_umrez2       = xlips-umrez
          importing
            umren          = l_umvkn
            umrez          = l_umvkz.                       "^_879083
* lines deleted
      endif.                                                "^566027

*     SPE INB RG 17.11.2004 TMPID / HOLD
*     Do not check the temporary or hold deliveriess
      break-point id /spe/inb_hold.
      break-point id /spe/inb_tmpid.
      if xvbuk-spe_tmpid is initial and
         xvbuk-hdall     is initial and
         xvbup-hdall     is initial.

        refresh lt_ekes.                                  "v_n_1679467
        lt_ekes[] = xuekes[].
        ls_lips = xlips.
        LOOP AT xlips FROM xlips_tabix.
          IF xlips-vgbel <> xuekes-ebeln OR
             xlips-vgpos <> xuekes-ebelp.
            EXIT.
          ENDIF.
          CHECK xlips-updkz CA 'IUD'.
          ls_ekes-ebeln = xlips-vgbel.
          ls_ekes-ebelp = xlips-vgpos.
          ls_ekes-vbeln = xlips-vbeln.
          ls_ekes-vbelp = xlips-posnr.
          ls_ekes-menge = xlips-lfimg.
          ls_ekes-kz    = xlips-updkz.
          APPEND ls_ekes TO lt_ekes.
        ENDLOOP.
        xlips = ls_lips.                                  "^_n_1679467

        call function 'ME_CONFIRMATION_CHECK_QUANTITY'
             exporting
                  i_ebeln = xuekes-ebeln
                  i_ebelp = xuekes-ebelp
                  i_meins = xlips-vrkme
                  i_menge = xlips-lfimg
*               i_vbeln = xlikp-vbeln                           "438392
                  i_vbeln = l_vbeln                         "438392
                  i_vbelp = xlips-posnr
                  i_date  = xlikp-lfdat
                  i_umrez = l_umvkz                         "457360
                  i_umren = l_umvkn                         "457360
                  i_msg   = l_msg                           "571740
             tables                                         "v_n_671298
*                 t_ekes  = xuekes                          "^_n_671298
                  t_ekes  = lt_ekes                         "n_1679467
             exceptions
                  error_message  = 2
                  others  = 1.
        if sy-subrc = 2.
          message id sy-msgid type sy-msgty number sy-msgno
                with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
        elseif sy-subrc <> 0..
          message e158.
        endif.
      endif.
    endif.

  endloop.
* MM erwartet sortierte Tabelle: FB Me_Confirmation_Maintain_Avis
  sort xuekes by mandt ebeln ebelp vbeln vbelp.

*---------------------------------------------------------------------*
*       Falls notwendig, wird die Bestellentwicklung verbucht         *
*---------------------------------------------------------------------*
  describe table xuekes lines ekes_pos.
  if ekes_pos > 0.

    data: l_trguid type cs_guidc.
    l_trguid = v50agl-apotrguid.

    call function 'ND_EXITS_ACTIVE_CHECK'
      exceptions
        exits_not_active = 1
        others           = 2.

*-- APO is active
    if sy-subrc eq 0 and not
       l_trguid is initial.

*     Information about delivery creation from TP/VS
      IMPORT it_apodlv_process = lt_apodlv_pro FROM MEMORY ID 'FU_ID_TO_DLV'.

      IF NOT lt_apodlv_pro IS INITIAL.
*       Delivery creation by TP/VS
*       Create information about each delivered freight unit
*       This functionality requires note 1392971 in SCM to work correctly
        LOOP AT lt_apodlv_pro INTO ls_apodlv_pro.
          READ TABLE xuekes TRANSPORTING NO FIELDS
            WITH KEY ebeln = ls_apodlv_pro-doc_ext
                     ebelp = ls_apodlv_pro-doc_pos_ext
            BINARY SEARCH.
          CHECK sy-subrc IS INITIAL.
          CHECK ls_apodlv_pro-shp_id NE l_trguid.
*         Collect only entries for the current shipment
          CHECK ls_apodlv_pro-shp_id+10(10) EQ l_trguid+10(10).
*         save TRGUID for APO transfer of PO
          lv_trguid = ls_apodlv_pro-shp_id.
          CALL FUNCTION 'OUTBOUND_CALL_01000791_E' IN UPDATE TASK
            EXPORTING
              i_trguid = lv_trguid
            EXCEPTIONS
              OTHERS   = 0.

        ENDLOOP.
      ENDIF.

*     save GUID for APO transfer of PO
*     Use l_trguid for the last call so it's stored in g_trguid
*     This ensures that other applications using g_trguid are not affected
      call function 'OUTBOUND_CALL_01000791_E' in update task
        exporting
          i_trguid = l_trguid
        exceptions
          others   = 0.

    endif.

* SPE100 ST 22.03.2005
* Collect selected delivery data for CIF
    data: lt_inb_cifext type table of /spe/inb_cifext.
      call function '/SPE/CIF_IBDLV_INFO_GET'
        exporting
          i_likp        = xlikp
        tables
          it_xuekes     = xuekes
          it_xlips      = xlips
          ot_inb_cifext = lt_inb_cifext.

*   Parameters for Auto GR function
    data: l_no_ekes_update type xfeld,
          l_insert_on_gr type xfeld.
*   Auto GR function is active
    if v50agl-spe_auto_gr = /spe/cl_id_handling=>c_auto_gr-creating. "1.
*     special processes for automatic GR posting
*     (Auto GR: create delivery and post GR in the same LUW)
*     EKES update is not needed (The EKES entry will created later)
      l_no_ekes_update = 'X'.
*     Instead of update inser for the EKES because EKES entry does not exist
      l_insert_on_gr   = 'X'.
    endif.

    call function 'ME_CONFIRMATION_MAINTAIN_AVIS'
       exporting
            i_ibtyp           = lfart_besttyp
            if_no_ekes_update = l_no_ekes_update  "EKES update is needed?
            if_insert_on_gr   = l_insert_on_gr    "Insert EKES instead of update
       tables
            t_ekes = xuekes
            t_ekes_upd = t_ekes_upd
            t_ekes_conv_qty = xekes_conv_qty                "457360
            t_ekesu = xekesu                                "713023
* SPE ST 22.03.2005 pass collect selected delivery data for CIF
            /spe/t_inb_cifext = lt_inb_cifext
       exceptions
            conversion_not_possible = 1
            others = 2.
    if sy-subrc = 1.
* conversion is not possible
      message e254.
    elseif sy-subrc = 2.
* purchase order update failed
      message e255.
    endif.
*   Update LIS notwendig?
    describe table t_ekes_upd lines sy-tfill.
    if sy-tfill > 0.
*     ja
      call function 'ME_STATISTICS_LF_EKES_LIS'
        exporting
          i_likp_new = xlikp
          i_likp_old = ylikp
        tables
          t_ekes     = t_ekes_upd
          t_lips_new = xlips
          t_lips_old = ylips.
    endif.                             "Update LIS notwendig?
ENHANCEMENT-POINT MV50AF0B_BESTELLUNG_EKES_FUE_7 SPOTS ES_SAPMV50A.
  else.
ENHANCEMENT-POINT MV50AF0B_BESTELLUNG_EKES_FUE_8 SPOTS ES_SAPMV50A .

  endif.

endform.                    "bestellung_ekes_fuellen