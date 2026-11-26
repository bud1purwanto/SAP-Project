*----------------------------------------------------------------------*
*   INCLUDE FV50XFIN                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  DELIVERY_FINAL_CHECK
*&---------------------------------------------------------------------*
*       Dies ist die letzte Möglichkeit in der Lieferungserstellung,
*       die Daten zu prüfen und bei negativem Ausgang im Dialog
*       eine Message an den Bildschirm zu schicken.
*       Es sollten nur in begründeten Ausnahmefällen andere Anweisungen
*       als PERFORM aufgenommen werden.
*----------------------------------------------------------------------*
FORM delivery_final_check USING ev_beleg_sichern_abbrechen LIKE sy-subrc
                                iv_wa_buchen_aktiv         TYPE c
                                ip_wadat_ist_clear TYPE xfeld. "n_979614

  DATA: l_idx LIKE sy-tabix,
        ls_vbuk like xvbuk,                                   "n_1610710
        lf_change_requested TYPE xfeld.                     "n_539326
  CLEAR ev_beleg_sichern_abbrechen.
  REFRESH: gt_finchdel.
  REFRESH: gt_r_autlf_del.

  PERFORM xlikp_aus_likp_fuellen.

* In case of lean delivery update recalculate incompleteness status only
  IF aufrufer EQ chart.
    PERFORM uc_internal_update(sapfv50u).
    EXIT.
  ENDIF.

*-----------------------------------------------------------------------
* 1. Teil der Prüfungen: Prüfungen pro Lieferung im LOOP
*-----------------------------------------------------------------------
  LOOP AT xlikp.

    l_idx = sy-tabix.                                       "n_760460

    IF NOT v50agl-ucdel_to_del_comb IS INITIAL.             "v_n_1610710
      READ TABLE xvbuk WITH KEY vbeln = xlikp-vbeln
                       INTO ls_vbuk
                       BINARY SEARCH.
    ENDIF.
    IF xlikp-updkz NE updkz_delete AND
        ls_vbuk-bestk IS INITIAL.                           "^_n_1610710

*     Gefahrgut: Template-Material-Abwicklung
*   Ermittl. von Gefahrgutstammsätzen, muß vor Gefahrgutprüfungen laufen
      PERFORM dgmsd_determine USING ev_beleg_sichern_abbrechen
                                    l_idx.
*     Prüfung auf Gefahrgut, muß vor Unvollständigkeit laufen
      PERFORM gg_final_check USING ev_beleg_sichern_abbrechen
                                   l_idx.                   "n_760460
*     Prüfung auf Komplettlieferung
      PERFORM beleg_komplettlieferungscheck USING xlikp-vbeln.

*     Checks if the delivery is already billed
      PERFORM billing_check USING xlikp.

*     Prüfung auf untersch. Kommissioniertechniken im dez. Fall
*     -> läuft später, Lieferung muß trotzdem gesichert werden können
*     PERFORM delivery_final_check_lgnum USING xlikp.

*     Prüfung auf Vorhandensein einer Warenannahmestelle falls
*     Anlieferung verteilungsrelevant
      PERFORM inb_deliv_rec_point_check USING xlikp.

*     Prüfung auf unvollständigen Chargensplit bei
*     verteilungsrelevanten Lieferungen
      PERFORM batchsplit_incomplete_check USING xlikp.

*     Prüfung auf Szenarien, die im verteilten System nicht unterstützt
*     werden und deshalb hier abgefangen werden müssen
      PERFORM not_supported_scenario_check USING xlikp.

*     Check whether wheight and volume of the created deliveries exceed
*     the maximum capacity of the used means of transport. In case of
*     overcapacity a warning is sent; the warning does NOT prevent the
*     delivery from saving
      PERFORM mot_capacity_check USING xlikp.

*     Check whether packing information is consistent
      PERFORM packing_consistency_check USING xlikp.

*     Decentral WMS: Check whether picking has already been performed
      PERFORM decentral_picking_check USING xlikp.

    ENDIF.
*   Check for distributed scenario, if change request can be executed
    PERFORM bapi_dlv_change_simulate
            USING    xlikp
            CHANGING lf_change_requested.

*   Check for temporary deactivation of the change management
    IF NOT lf_change_requested IS INITIAL.
      PERFORM check_change_management USING xlikp.
    ENDIF.

*   SPE OUTB check for incomplete conversion and crit. limit
*   only for process 'check and combine'
    PERFORM spe_delivery_final_check(saplv50s)
                          TABLES  xlips
                                  xlikp
                           USING  v50agl-ucdel_comb_crit_limit
                                  v50agl-ucdel_crit_unit
                                  xlikp-vbeln.


*   Check Incompletion
    IF xlikp-updkz EQ updkz_new.
      MOVE-CORRESPONDING xlikp TO likp.
      PERFORM tvlk_select(sapmv50a) USING xlikp-lfart
                                          space
                                          sy-subrc.

      PERFORM uc_upd_request(sapfv50u) USING charx posnr_low
                                       posnr_low posnr_low.
    ENDIF.

*Check, whether returns delivery (SPM) is for consolidator portal
*and LIPS-SPE_FOLLOW_UP CA '12' --> that case is not valid, as:
*consolidator portal cannnot perform putaway(1) and scrapping(2)
    IF xlikp-spe_le_scenario EQ 'R'.
      PERFORM spe_check_consolidator_portal TABLES xlikp
                                                   xlips.
    ENDIF.
*   Prüfung auf ...
*   PERFORM ...

  ENDLOOP.


*-----------------------------------------------------------------------
* 2. Teil der Prüfungen: Prüfungen pro Päckchen
*-----------------------------------------------------------------------

* Prüfung auf Kreditlimit
  IF v50agl-confirm_central IS INITIAL AND
     v50agl-split           EQ space.  "no credit check

    PERFORM kreditcheck_from_beleg_sichern(sapfv50k)
            USING    iv_wa_buchen_aktiv
            CHANGING gt_finchdel.
  ENDIF.

* Prüfung auf Unvollständigkeit
  PERFORM uc_from_final_check.

* Prüfung auf ...
* PERFORM ...

ENHANCEMENT-POINT fv50xfin_01 SPOTS es_fv50xfin INCLUDE BOUND.

* Customer check
  IF NOT gi_badi_delivery IS INITIAL.              "n_530754/n_637289
    CALL METHOD gi_badi_delivery->delivery_final_check
      EXPORTING
        it_xlikp       = xlikp[]
        it_ylikp       = ylikp[]
        it_xlips       = xlips[]
        it_ylips       = ylips[]
        it_xvbpa       = xvbpa[]
        it_yvbpa       = yvbpa[]
        it_xvbfa       = xvbfa[]
        it_yvbfa       = yvbfa[]
        it_xvbuk       = xvbuk[]
        it_yvbuk       = yvbuk[]
        it_xvbup       = xvbup[]
        it_yvbup       = yvbup[]
        it_xvbadr      = xvbadr[]
        is_v50agl      = v50agl
        if_trtyp       = t180-trtyp
        if_tcode       = t180-tcode
      CHANGING
        cs_v50agl_cust = v50agl_cust
        ct_finchdel    = gt_finchdel.
  ENDIF.                                                    "n_530754

  IF NOT ip_wadat_ist_clear IS INITIAL.                     "v_n_979614
    READ TABLE gt_finchdel WITH KEY msgty = chare
                           TRANSPORTING NO FIELDS.
    IF sy-subrc IS INITIAL.
      CLEAR likp-wadat_ist.
    ENDIF.
  ENDIF.                                                    "^_n_979614

*-----------------------------------------------------------------------
* Hier keine weiteren Prüfungen aufnehmen. Ausführung der Prüfergebnisse
*-----------------------------------------------------------------------
  PERFORM final_check_execute USING ev_beleg_sichern_abbrechen.

ENDFORM.                    "delivery_final_check



*&---------------------------------------------------------------------*
*&      Form  FINAL_CHECK_EXECUTE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM final_check_execute USING ev_beleg_sichern_abbrechen LIKE sy-subrc.

  DATA: ls_finchdel TYPE vlikp_s_finchdel.
  DATA: ls_mark_for_del LIKE LINE OF gt_mark_for_del.
  DATA: lv_msgty LIKE sy-msgty,
        lv_rcode LIKE sy-subrc.
  DATA: lt_r_likp_del LIKE gt_r_autlf_del OCCURS 0 WITH HEADER LINE,
        lf_lips_tabix LIKE sy-tabix,
        lf_likp_tabix LIKE sy-tabix.
  DATA: lt_autlf_del TYPE TABLE OF vbak-vbeln,
        ls_autlf TYPE vbak-vbeln.

  DATA: lf_xvbuk_pflegen.

  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips.

  FIELD-SYMBOLS: <ls_xvbuk> LIKE LINE OF xvbuk.             "n_1164959

  IF NOT v50agl-sammelgang IS INITIAL AND
         v50agl-extend_delivery IS INITIAL.                 "n_521676


*Problem: bereits verpackte Lieferungen müssen erst ausgepackt werden
* sonst gibt es $-HUs auf der Datenbank
* in lt_r_likp_del stehen verpackte Lieferungen die gelöscht werden
    lt_r_likp_del-sign = 'I'.
    lt_r_likp_del-option = 'EQ'.

    lt_r_likp_del-low = gc_impossible.
    APPEND lt_r_likp_del TO lt_r_likp_del.
* in gt_finchdel -> Lieferungen, die komplett gelöscht werden
    LOOP AT gt_finchdel INTO ls_finchdel
                        WHERE msgty = chare.
      READ TABLE xvbuk WITH KEY vbeln = ls_finchdel-vbeln.
      IF xvbuk-pkstk CA 'BCD'.
        lt_r_likp_del-low = ls_finchdel-vbeln.
        COLLECT lt_r_likp_del INTO lt_r_likp_del.
      ENDIF.
    ENDLOOP.

* gt_r_autlf_del: Lieferpos. soll gelöscht werden
    IF NOT gt_r_autlf_del[] IS INITIAL.
      LOOP AT xlips WHERE vgbel IN gt_r_autlf_del AND
                          updkz NE updkz_delete      .
        READ TABLE xvbup WITH KEY vbeln = xlips-vbeln
                                  posnr = xlips-posnr.
        IF xvbup-pksta CA 'BC'.
          lt_r_likp_del-low = xlips-vbeln.
          COLLECT lt_r_likp_del INTO lt_r_likp_del. "lieferung merken
*         Auftrag merken
          COLLECT xlips-vgbel INTO lt_autlf_del.
          READ TABLE gt_finchdel WITH TABLE KEY vbeln = xlips-vbeln
                          TRANSPORTING NO FIELDS.
          CHECK NOT sy-subrc IS INITIAL.
* Die Lieferung soll jetzt auch komplett gelöscht werden, weil sie auch
* komplett ausgepackt wird
          PERFORM finchdel_handling(sapfv50p) USING
          xlips-vbeln    '01' 'E' space space
          space space space space gt_finchdel.
        ENDIF.
      ENDLOOP.
    ENDIF.
* in lt_r_likp_del stehen jetzt alle zu löschenden und verpackten Lief.
    LOOP AT xlikp WHERE updkz NE updkz_delete AND   "xlikp needed !!!
                        vbeln IN lt_r_likp_del   .
      MOVE-CORRESPONDING xlikp TO likp.
      PERFORM delete_hus_of_delivery(sapfv50p)
            IF FOUND USING xlikp.
    ENDLOOP.
    REFRESH lt_r_likp_del.
    CLEAR lt_r_likp_del-low.
  ENDIF.

*-complete delivery check is seperated from finchdel-handling !!!
  IF NOT gt_r_autlf_del[] IS INITIAL AND
         v50agl-extend_delivery IS INITIAL.                 "n_521676
    REFRESH lt_r_likp_del.
    CLEAR   lt_r_likp_del.
    lt_r_likp_del-sign = 'I'.
    lt_r_likp_del-option = 'EQ'.
*   delete items
    LOOP AT xlips WHERE updkz NE updkz_delete   AND
                        vgbel IN gt_r_autlf_del     .
      lf_lips_tabix = sy-tabix.
      MOVE-CORRESPONDING xlips TO lips.
      READ TABLE xlikp WITH KEY vbeln = xlips-vbeln.
      lf_likp_tabix = sy-tabix.
      MOVE-CORRESPONDING xlikp TO likp.
      PERFORM xlips_loeschen(sapfv50p) USING charx lf_lips_tabix.
      MOVE-CORRESPONDING likp TO xlikp.
      MODIFY xlikp INDEX lf_likp_tabix.

      lt_r_likp_del-low = xlikp-vbeln.
      APPEND lt_r_likp_del TO lt_r_likp_del.
      lf_xvbuk_pflegen = charx.
    ENDLOOP.

*   delete empty headers
    SORT lt_r_likp_del.
    DELETE ADJACENT DUPLICATES FROM lt_r_likp_del.
    LOOP AT xlikp WHERE updkz NE updkz_delete AND   "xlikp needed !!!
                        vbeln IN lt_r_likp_del   .
      LOOP AT xlips TRANSPORTING NO FIELDS
                    WHERE vbeln EQ xlikp-vbeln  AND
                          posar NE gc_posar-packing AND     "n_818304
                          updkz NE updkz_delete    .
        EXIT.
      ENDLOOP.
      IF sy-subrc NE 0.
*     delete associated HUs if any                           "v_n_725526
        MOVE-CORRESPONDING xlikp TO likp.
        PERFORM delete_hus_of_delivery(sapfv50p)
                IF FOUND USING xlikp.                       "^_n_725526
        PERFORM lieferkopf_loeschen(saplv50s).
        CLEAR lf_xvbuk_pflegen.
      ENDIF.
    ENDLOOP.
*   update status - necessary for sales order header status
    IF NOT lf_xvbuk_pflegen IS INITIAL.
      LOOP AT xlikp WHERE updkz NE updkz_delete.
        MOVE-CORRESPONDING xlikp TO likp.
        EXIT.
      ENDLOOP.
      PERFORM xvbuk_pflegen(sapfv50k).
    ENDIF.
*   delete sales orders from log and insert correct message into log
    DELETE cvbls WHERE vbeln IN gt_r_autlf_del.
    LOOP AT gt_r_autlf_del.
      cvbak-vbeln = gt_r_autlf_del-low.
      PERFORM message_handling USING posnr_low
                                     '049'
                                     'E'
                                     'VL'
                                     space
                                     space
                                     space
                                     space.
    ENDLOOP.
    REFRESH gt_r_autlf_del.
    REFRESH lt_r_likp_del.
  ENDIF.

  LOOP AT gt_finchdel INTO ls_finchdel.
    CASE v50agl-sammelgang.
      WHEN charx.
        IF ls_finchdel-msgty = chare.
          LOOP AT cvbls WHERE vbeln_lif EQ ls_finchdel-vbeln.
            cvbak-vbeln = cvbls-vbeln.
            PERFORM message_handling(sapmv50a)
                                          USING posnr_low
                                                ls_finchdel-msgno
                                                chare
                                                ls_finchdel-msgid
                                                ls_finchdel-msgv1
                                                ls_finchdel-msgv2
                                                ls_finchdel-msgv3
                                                ls_finchdel-msgv4.
          ENDLOOP.
          IF sy-subrc NE 0.
            CLEAR cvbak-vbeln.
            PERFORM message_handling(sapmv50a)
                                          USING posnr_low
                                                ls_finchdel-msgno
                                                chare
                                                ls_finchdel-msgid
                                                ls_finchdel-msgv1
                                                ls_finchdel-msgv2
                                                ls_finchdel-msgv3
                                                ls_finchdel-msgv4.
          ENDIF.

          IF t180-trtyp = 'H' AND
             v50agl-extend_delivery IS INITIAL.             "n_521676
*           Es darf nur gelöscht werden, wenn die Lieferung angelegt
*           wird.
*           Bei Änderungen an bestehenden Lieferungen darf es hier nicht
*           zum Löschen aller Lieferpositionen kommen !

*           lines deleted by note 643279

*           Inbound deliveries which are created through BORGR and which
*           are foreseen to be put "on hold" should be created with this
*           status rather than being deleted                "v_n_1164959
            READ TABLE xvbuk ASSIGNING <ls_xvbuk>
                             WITH KEY vbeln = ls_finchdel-vbeln
                             BINARY SEARCH.
            IF sy-subrc = 0.                                "n_1282174
              IF <ls_xvbuk>-updkz EQ UPDKZ_NEW.             "v_n_1610710
                PERFORM restore_uc_delivery USING ls_finchdel-vbeln.
              ENDIF.                                        "^_n_1610710
              IF <ls_xvbuk>-hdall EQ space AND
               <ls_xvbuk>-hdals EQ space.
                ls_mark_for_del-vbeln = ls_finchdel-vbeln.
                COLLECT ls_mark_for_del INTO gt_mark_for_del.
              ENDIF.                                        "^_n_1164959
            ELSE.                                           "v_n_1282174
              ls_mark_for_del-vbeln = ls_finchdel-vbeln.
              COLLECT ls_mark_for_del INTO gt_mark_for_del.
            ENDIF.                                          "^n_1282174

          ENDIF.

          IF NOT v50agl-extend_delivery IS INITIAL.
            ev_beleg_sichern_abbrechen = 4.
            LOOP AT xlips ASSIGNING <ls_xlips>
                          WHERE vbeln EQ ls_finchdel-vbeln AND
                                updkz NE space.
              CLEAR <ls_xlips>-updkz.
              CLEAR <ls_xlips>-id.
            ENDLOOP.
          ENDIF.

        ENDIF.
      WHEN space.
        IF ls_finchdel-msgty = chare.
          ev_beleg_sichern_abbrechen = 4.
        ENDIF.
        IF  gs_mhpar-glomd NA gc_glomd-backgr_all
            OR sy-tcode EQ 'VL11'.
          IF ls_finchdel-msgty = chare.
            fcode = fcode_gleiche_seite.
          ENDIF.
          PERFORM message_handling IN PROGRAM (programmname)
                                   USING posnr_low
                                         ls_finchdel-msgno
                                         ls_finchdel-msgty
                                         ls_finchdel-msgid
                                         ls_finchdel-msgv1
                                         ls_finchdel-msgv2
                                         ls_finchdel-msgv3
                                         ls_finchdel-msgv4.

          IF ls_finchdel-msgty = chare.
            PERFORM fcode_bearbeiten(sapmv50a).
          ENDIF.
        ENDIF.
    ENDCASE.
  ENDLOOP.

* in gt_mark_for_del -> Lieferungen, die komplett gelöscht werden
  LOOP AT gt_mark_for_del INTO ls_mark_for_del.
    READ TABLE xlikp WITH KEY mandt = sy-mandt
                              vbeln = ls_mark_for_del-vbeln.
    likp = xlikp.
    REFRESH ilips.
*   SPE partial conversion - posnr filled
    IF ls_mark_for_del-posnr <> posnr_low.
      LOOP AT xlips WHERE updkz NE updkz_delete
                      AND vbeln EQ ls_mark_for_del-vbeln
                      AND posnr EQ ls_mark_for_del-posnr.
        lips = xlips.
        CLEAR v50agl-no_xlips_loeschen.       "SPE: delete marked items
        PERFORM xlips_loeschen(sapfv50p) USING charx sy-tabix.
        EXIT.                   "there is only one item with this posnr
      ENDLOOP.

*     find out if header of partial deletion should be cleared, too
      AT END OF vbeln.             "last posnr
        LOOP AT xlips WHERE vbeln EQ ls_mark_for_del-vbeln
                        AND updkz NE updkz_delete.
          EXIT.
        ENDLOOP.
*       Do not delete header if remaining items still present
        IF sy-subrc <> 0.
          LOOP AT xlikp WHERE vbeln EQ ls_mark_for_del-vbeln.
            PERFORM lieferkopf_loeschen(saplv50s).
          ENDLOOP.
        ENDIF.
      ENDAT.

    ELSE.
*     delete all items and the header
      LOOP AT xlips WHERE updkz NE updkz_delete
                      AND vbeln EQ ls_mark_for_del-vbeln.
        lips = xlips.
        CLEAR v50agl-no_xlips_loeschen.       "SPE: delete marked items
        PERFORM xlips_loeschen(sapfv50p) USING charx sy-tabix.
      ENDLOOP.
      LOOP AT xlikp WHERE vbeln EQ ls_mark_for_del-vbeln.
        PERFORM lieferkopf_loeschen(saplv50s).
      ENDLOOP.
    ENDIF.
  ENDLOOP.


  REFRESH gt_mark_for_del.

ENDFORM.                               " FINAL_CHECK_EXECUTE

*&---------------------------------------------------------------------*
*&      Form  RESTORE_UC_DELIVERY
*&---------------------------------------------------------------------*
*   Do not delete the UC delivery if checked delivery creation fails!
*----------------------------------------------------------------------*
FORM restore_uc_delivery USING if_vbeln TYPE vbeln.           "n_1610710

  FIELD-SYMBOLS: <ls_xlips> LIKE LINE OF xlips,
                 <ls_xlips_uc> LIKE LINE OF xlips,
                 <ls_xvbuk_uc>  LIKE LINE OF xvbuk.

  CHECK NOT v50agl-ucdel_to_del_comb IS INITIAL.
  CHECK if_vbeln(1) = '$'.

  READ TABLE xlips ASSIGNING <ls_xlips>
                   WITH KEY vbeln = if_vbeln
                   BINARY SEARCH.
  CHECK sy-subrc IS INITIAL.

  LOOP AT xlips ASSIGNING <ls_xlips> FROM sy-tabix.
    IF <ls_xlips>-vbeln NE if_vbeln.
      EXIT.
    ENDIF.
    AT NEW vgbel.
      LOOP AT xlips ASSIGNING <ls_xlips_uc>
                    WHERE vbeln NE if_vbeln
                      AND vgbel = <ls_xlips>-vgbel.
        READ TABLE xvbuk ASSIGNING <ls_xvbuk_uc>
                         WITH KEY vbeln = <ls_xlips_uc>-vbeln
                         BINARY SEARCH.
        CHECK NOT <ls_xvbuk_uc>-bestk IS INITIAL.
        DELETE gt_mark_for_del WHERE vbeln = <ls_xlips_uc>-vbeln.
        EXIT.
      ENDLOOP.
    ENDAT.
  ENDLOOP.

ENDFORM.