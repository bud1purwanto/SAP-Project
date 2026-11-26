*----------------------------------------------------------------------*
*   INCLUDE FV50XFWC                                                   *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELIVERY                       (ULa, 4.6c)
*&---------------------------------------------------------------------*
*       Call all Routines for BAPI calls/IDoc sending
*       Moved from BELEG_SICHERN_POST, so it looks a little bit nicer:-)
*----------------------------------------------------------------------*
FORM call_bapi_delivery.

  DATA: lf_vbeln_old         TYPE vbeln_vl
       ,lf_vbeln_new         TYPE vbeln_vl
       ,lf_vbeln_root        TYPE vbeln_vl
       ,lf_items_belong_to   TYPE ledspd_items_belong_to
       ,lf_split_profile     TYPE ledspd_pmode
       ,lf_obj_type          LIKE serial-obj_type VALUE 'LIKP'
       ,lf_ale_serial_id     TYPE chnum
       ,LT_VBPA_OLD          TYPE SHP_VL10_VBPA_T             "n_1487129
       ,LT_LIPS_ADD          TYPE SHP_LIPS_T
       ,LF_SPM_DISP          TYPE XFELD.                      "n_1349622

  DATA:
        lb_badi_dispatch     TYPE REF TO badi_ibdlv_dispatch_se.

  FIELD-SYMBOLS: <LFS_LIKP> TYPE LIKPVB.                      "n_1349622

  LOOP AT XLIKP ASSIGNING <LFS_LIKP>                        "v_n_1349622
                WHERE NOT LGNUM IS INITIAL.
*   Check whether SPM processes are involved in any inbound delivery
*   (EWM related, VL60 dispatching is active or TPOP scenario)
    IF ( /SPE/CL_CTRL=>IS_EWM(
             I_LGNUM = <LFS_LIKP>-LGNUM ) = GC_TRUE OR
         /SPE/CL_CTRL=>IS_ACTIVE_VL60_DISPATCH(
             I_LGNUM = <LFS_LIKP>-LGNUM ) = GC_TRUE )         "n_1069172
       AND <LFS_LIKP>-VBTYP CA VBTYP_LIAV
       OR <LFS_LIKP>-SPE_LE_SCENARIO EQ GC_LE_SCENARIO-TPOP.
      READ TABLE XVBFA TRANSPORTING NO FIELDS               "v_n_1589557
                    WITH KEY VBELV   = <LFS_LIKP>-VBELN
                             VBTYP_N = 'p'
                             UPDKZ   = 'I'.
      IF NOT SY-SUBRC IS INITIAL.                           "^_n_1589557
        LF_SPM_DISP = CHARX.
      ELSE.                                                 "v_n_1589557
*       Transfer posting ROD=>AFS (no dispatching)
      ENDIF.
      CONTINUE.                                             "^_n_1589557
    ENDIF.
  ENDLOOP.

* ---- Call the new dispatching ----
  IF NOT LF_SPM_DISP IS INITIAL .                           "^_n_1349622
    LT_VBPA_OLD = YVBPA[].                                    "n_1487129
*   Call Dispatching
    CALL METHOD /spe/cl_dlv_dispatch=>dlv_dispatch
      EXPORTING
        is_v50agl           = v50agl
        if_det_extra_tables = charx
        it_lips             = xlips[]
        it_lips_old         = ylips[]
        it_vbuk             = xvbuk[]
        it_vbup             = xvbup[]
        it_vbuv             = xvbuv[]
        it_vbfa             = xvbfa[]
        it_vbpa             = xvbpa[]
        IT_VBPA_OLD         = LT_VBPA_OLD                     "n_1487129
        it_vbadr            = xvbadr[]
        it_likp_old         = ylikp[]
      CHANGING
        xt_likp             = xlikp[]
        xt_vbfs             = cvbfs[].

   ENDIF.

* ---- Call the new dispatching for SE ----
  GET BADI lb_badi_dispatch.
  CALL BADI lb_badi_dispatch->ibdlv_dispatch_se
    EXPORTING
      iv_lgnum            = xlikp-lgnum
      iv_vbtyp            = xlikp-vbtyp
      is_v50agl           = v50agl
      if_det_extra_tables = charx
      it_lips             = xlips[]
      it_lips_old         = ylips[]
      it_vbuk             = xvbuk[]
      it_vbup             = xvbup[]
      it_vbuv             = xvbuv[]
      it_vbfa             = xvbfa[]
      it_vbpa             = xvbpa[]
      it_vbadr            = xvbadr[]
      it_likp_old         = ylikp[]
    CHANGING
      xt_likp             = xlikp[]
      xt_vbfs             = cvbfs[].

* BAPI for delivery change (before Replicate because of VLSTK
  PERFORM call_bapi_delivery_change USING lf_ale_serial_id.

*BAPI für Lieferungsverteilung aufrufen
  PERFORM call_bapi_delivery_replicate.

***SPM Returns:                                                    --> BEGIN
*a) Send Returns Instruction to ICH Dealer Portal
*b) Send Cancellation of Confirmation to Returns Instruction to ICH Dealer Portal
ENHANCEMENT-SECTION     EHP603_CALL_BAPI_DELIVERY_01 SPOTS ES_FV50XFWC INCLUDE BOUND .
  IF likp-spe_le_scenario EQ gc_le_scenario-return
      OR likp-spe_le_scenario EQ gc_le_scenario-tpop.
    BREAK-POINT ID /spe/idoc_output_spe_delvry.
    PERFORM spe_idoc_ret_erp_ich.
  ENDIF.
END-ENHANCEMENT-SECTION.
***SPM Returns:                                                    <-- END

*ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*CALL_BAPI_DELIVERY_SPLIT_DEC has to be called in advance of
*CALL_BAPI_DELIVERY_CONFIRM_DEC because of dependencies to VLSTK
*The pre step is necessary to calculate a serial id for IDoc processing
*And to do it only once.
*ULa, 4.6c
*!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  PERFORM call_bapi_delivery_prestep CHANGING lf_vbeln_old
                                              lf_vbeln_new
                                              lf_vbeln_root
                                              lf_items_belong_to
                                              lf_split_profile
                                              lf_ale_serial_id
                                              .
  PERFORM call_bapi_delivery_split_dec  USING lf_vbeln_old
                                              lf_vbeln_new
                                              lf_vbeln_root
                                              lf_items_belong_to
                                              lf_split_profile
                                              lf_ale_serial_id
                                     CHANGING lt_lips_add
                                              .

*-Serialization only for subsequent delivery split:
* in case of initial lf_obj_type no serialization is done for
* IDOC confirm_decentral
  IF lf_vbeln_root IS INITIAL.
    CLEAR lf_obj_type.
  ELSE.
    lf_obj_type = 'LIKP'.
  ENDIF.

  PERFORM call_bapi_inb_pgr_prestep CHANGING lf_obj_type       "v_YG_PGR
                                             lf_ale_serial_id. "^_YG_PGR

*Always after call_bapi_delivery_split_dec
  PERFORM call_bapi_delivery_confirm_dec USING lf_obj_type
                                               lf_ale_serial_id
                                               lt_lips_add
                                               .

ENDFORM.                               " CALL_BAPI_DELIVERY

*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELIVERY_PRESTEP               (ULa, 4.6c)
*&---------------------------------------------------------------------*
*       Get serial number
*       If this delivery (XLIKP) was splitted or created by split
*       EF_VBELN_XXX and EF_VBELN_ROOT won't be initial.
*       If this is the last splitted delivery to post goods issue
*       EF_VBELN_XXX have the same value
*----------------------------------------------------------------------*
FORM call_bapi_delivery_prestep
                 CHANGING ef_vbeln_old       TYPE vbeln_vl
                          ef_vbeln_new       TYPE vbeln_vl
                          ef_vbeln_root      TYPE vbeln_vl
                          ef_items_belong_to TYPE ledspd_items_belong_to
                          ef_split_profile   TYPE ledspd_pmode
                          ef_ale_serial_id   TYPE chnum
                          .

* ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* This FM has to be called in advance of all CALL_BAPI_DELIVERY_XXXXX
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  DATA: lt_split_flow_tree     TYPE ledspd_flow_tree_t
       ,lt_split_flow          TYPE ledspd_flow_t
       ,lf_vbeln_ref           TYPE vbeln_vl
       ,lf_appl_key            TYPE char30
       .

* Don't do it if called by transport management
  CHECK aufrufer NE chart.

  READ TABLE xlikp INDEX 1.
* send the BAPI only in LE System/Component
  CHECK NOT xlikp-verursys IS INITIAL.

* Do it only for deliveries posted goods issue
  PERFORM xvbuk_lesen(sapfv50k) USING xlikp-vbeln.
  CHECK xvbuk-wbstk = 'C'.

* Only outbound deliveries can be splitted!
  CHECK xlikp-vbtyp CA vbtyp_lief.

  CLEAR: ef_vbeln_old
        ,ef_vbeln_new
        ,ef_items_belong_to
        ,ef_split_profile
        .

* Check if split happened for this outbound(!) delivery.
* The FM comes up with some parameters to do split in ERP system
* This is done here so we doesn't need to read it twice
  CALL FUNCTION 'LE_DSP_READ_FLOW'
    EXPORTING
      if_vbeln              = xlikp-vbeln
      if_check_goods_issue  = 'X'
    IMPORTING
      et_ledspd_flow_tree   = lt_split_flow_tree
      et_ledspd_flow        = lt_split_flow
      ef_reference_delivery = lf_vbeln_ref
      ef_root_delivery      = ef_vbeln_root
      ef_items_belong_to    = ef_items_belong_to
      ef_split_profile      = ef_split_profile
    EXCEPTIONS
      internal_error        = 01
      OTHERS                = 99.

  IF sy-subrc <> 0.
    MESSAGE a591(vl) WITH xlikp-vbeln.                      "n_683627
  ENDIF.

  IF ef_vbeln_root IS INITIAL.
* no split -> clear all exporting parameters
    CLEAR: ef_items_belong_to
          ,ef_split_profile
          .
* The serialisation isn't necessary but '0' is a valid serial id/channel
* number and all deliveries are serialised over this channel. In case of
* an error all further IDocs will be blocked. So minimize the
* possibility and serialise over delivery number
    lf_appl_key = xlikp-vbeln.
  ELSE.
* Serialization of IDocs for one delivery especially SPLIT_DECENTRAL and
* CONFIRM_DECENTRAL  (ULa, 4.6c)
* The serialisation is always done with the original delivery
    lf_appl_key = ef_vbeln_root.

* no split but fill the parameters for later decision on sending IDoc
* SplitDecentral
    ef_vbeln_old = xlikp-vbeln.
    ef_vbeln_new = xlikp-vbeln.

* no split if this is last open delivery or no split happened
    IF NOT lf_vbeln_ref IS INITIAL.

*   'O'(ld) means that the current delivery (xlikp-vbeln) to be posted
*   goods issue is that one which is 'open' at ERP system. This means
*   it is the original delivery or that one which is nearest to the
*   original delivery. So LF_VBELN_REF is the new open delivery and
*   tooks over the role of the current delivery.
*   'N'(ew) means that the original or that one which is nearest to it
*   (LF_VBELN_REF) is still open and the current delivery is a newly
*   created delivery at LE system.

      IF ef_items_belong_to = gc_belongs_to-old.
        ef_vbeln_old = xlikp-vbeln.
        ef_vbeln_new = lf_vbeln_ref.
      ELSE.
        ef_vbeln_old = lf_vbeln_ref.
        ef_vbeln_new = xlikp-vbeln.
      ENDIF.
    ENDIF.
  ENDIF.

  CALL FUNCTION 'ALE_SERIAL_KEY2CHANNEL'
    EXPORTING
      appl_key = lf_appl_key
    IMPORTING
      chnum    = ef_ale_serial_id.

ENDFORM.                               " CALL_BAPI_DELIVERY_PRESTEP
*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELIVERY_REPLICATE
*&---------------------------------------------------------------------*
*       Verteilung von Lieferungsdaten
*----------------------------------------------------------------------*
FORM call_bapi_delivery_replicate.

  DATA: ls_packing           TYPE vse_s_v51h
       ,ls_object            TYPE hum_object
       ,ls_vbpa              TYPE vbpa
       ,ls_vbfs              TYPE vbfs
       ,lt_vbfs              TYPE STANDARD TABLE OF vbfs
       ,ls_vbadr             TYPE vbadr
       ,lf_msgno             LIKE sy-msgno
       .
  FIELD-SYMBOLS:
        <ls_likp>            TYPE likpvb
       ,<ls_vbuk>            TYPE vbukvb
       ,<ls_xvbpa>           TYPE vbpavb
       .

* Für eine Lieferung wird überprüft, ob ein eindeutige Lagernummer
* vorhanden ist und ob Werk/Lagerort einer Position dezentral ist
* (T320-CENSY, damit gilt LIPS-KOMKZ = 'E').
* Problem: Eventuell noch KOQUA/KOQUK setzen, damit die Lieferung
* gegen WA/WE gesperrt ist. Gibt es keine weitere Einschränkungen,
* dann sollte das in die Systembedingung für den WA/WE fließen.

  CHECK aufrufer NE chart.

  LOOP AT xvbpa ASSIGNING <ls_xvbpa>.

    READ TABLE xvbadr WITH KEY adrnr = <ls_xvbpa>-adrnr.
    IF sy-subrc NE 0.
      MOVE-CORRESPONDING <ls_xvbpa> TO ls_vbpa.
      CALL FUNCTION 'VIEW_VBADR'
        EXPORTING
          input   = ls_vbpa
        IMPORTING
          adresse = ls_vbadr
        EXCEPTIONS
          error   = 1
          OTHERS  = 2.
      IF sy-subrc EQ 0.
        CLEAR xvbadr.
        MOVE-CORRESPONDING ls_vbadr TO xvbadr.
        APPEND xvbadr.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF v50agl-sofauftrag = 'X'.
    CALL FUNCTION 'SHP_BAPI_DELIVERY_REPLICA'
      EXPORTING
        if_synchron       = v50agl-synchron
        if_rmsys_dlv_crea = v50agl-rmsys_dlv_crea
        is_v50agl         = v50agl
      TABLES
        ct_likp           = xlikp
        ct_ylikp          = ylikp                           "n_1001999
        it_lips           = xlips
        it_vbfa           = xvbfa
        it_vbpa           = xvbpa
        it_vbadr          = xvbadr
        it_vbuk           = xvbuk
        it_vbak           = cvbak
        it_vbap           = cvbap
        it_vbkd           = cvbkd
        ct_vbfs           = lt_vbfs
        it_serno_change   = gt_serno_change.
  ELSE.
    CALL FUNCTION 'SHP_BAPI_DELIVERY_REPLICA'
      EXPORTING
        if_synchron       = v50agl-synchron
        if_rmsys_dlv_crea = v50agl-rmsys_dlv_crea
        is_v50agl         = v50agl
      TABLES
        ct_likp           = xlikp
        ct_ylikp          = ylikp                           "n_1001999
        it_lips           = xlips
        it_vbfa           = xvbfa
        it_vbpa           = xvbpa
        it_vbadr          = xvbadr
        it_vbuk           = xvbuk
        ct_vbfs           = lt_vbfs
        it_serno_change   = gt_serno_change.
  ENDIF.

* lines replaced                                            "v_n_704387
* Take over error log of distribution check
  IF v50agl-rmsys_dlv_crea IS INITIAL.
    LOOP AT lt_vbfs INTO ls_vbfs.
      cvbak-vbeln = ls_vbfs-vbeln.
      ADD 1 TO vbsk-ernum.                                  "n_566523
      lf_msgno = ls_vbfs-msgno.
      ls_vbfs-msgty = 'I'.                                  "n_579235
      PERFORM message_vbfs_aufbauen(sapmv50a) USING vbsk-sammg
                                                    ls_vbfs-posnr
                                                    lf_msgno
                                                    ls_vbfs-msgty
                                                    ls_vbfs-msgid
                                                    ls_vbfs-msgv1
                                                    ls_vbfs-msgv2
                                                    ls_vbfs-msgv3
                                                    ls_vbfs-msgv4.
    ENDLOOP.
  ELSE.
    APPEND LINES OF lt_vbfs TO cvbfs.
  ENDIF.                                                    "^_n_704387

  IF t180-aktyp = aktyp-change.
    READ TABLE xlikp INDEX 1.
    likp-vlstk = xlikp-vlstk.
  ENDIF.

* If the delivery is replicated it is neccessary to delete the packing
* of the delivery if the user want to use the delivery split in the WM
* system.
* Without delivery split the packing is deleted either in advance of
* confirmation of the delivery. But if the delivery was splitted the
* split is redone before confirmation. So we decided to delete the
* packing already now.     "ULa, 4.6c
  CHECK likp-vbtyp CA vbtyp_lief.
* Do not delete HU VBFA records for SPE returns                 "XAN-SPM
  CHECK likp-spe_le_scenario <> charr.                          "XAN-SPM
  CHECK NOT tvshp-allow_dec_dsp IS INITIAL.

  CLEAR ls_packing.
  ls_packing-display = t180-trtyp.
  ls_packing-init    = charx.
  ls_packing-object  = gc_pacobj-obdlvry.
  ls_object-object   = gc_pacobj-obdlvry.

  LOOP AT xlikp ASSIGNING <ls_likp>.
    CHECK likp-vlstk = 'B'.
    READ TABLE xvbuk ASSIGNING <ls_vbuk>
                     WITH KEY  vbeln = <ls_likp>-vbeln.
    IF sy-subrc IS INITIAL.
      CHECK <ls_vbuk>-pkstk CA 'BC'.
    ENDIF.

    CLEAR ls_packing-endrunde.
    PERFORM init_complete_packing(sapmv50a) USING <ls_likp>
                                         CHANGING ls_packing
                                                  .
    ls_object-objkey = <ls_likp>-vbeln.
    PERFORM delete_delivery_hus(sapmv50a) USING ls_object.

    ls_packing-endrunde = charx.
    PERFORM init_complete_packing(sapmv50a) USING <ls_likp>
                                         CHANGING ls_packing
                                                  .
  ENDLOOP.

ENDFORM.                               " CALL_BAPI_DELIVERY_REPLICATE
*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELIVERY_CONFIRM_DEC
*&---------------------------------------------------------------------*
*       Rückmeldung Lieferungsdaten
*----------------------------------------------------------------------*
FORM call_bapi_delivery_confirm_dec
             USING if_obj_type      LIKE serial-obj_type
                   if_ale_serial_id TYPE chnum
                   it_lips_add      TYPE shp_lips_t         "ULa, 4.6c
                 .
  DATA: lt_vbpa TYPE STANDARD TABLE OF vbpavb WITH HEADER LINE.
  DATA: active_item TYPE XFELD.                             "n_1236023

* keep in mind that before this routine is called the routine
* CALL_BAPI_DELIVERY_SPLIT_DEC has to run (ULa, 4.6c)

  CHECK aufrufer NE chart.

  READ TABLE xlikp INDEX 1.
  CHECK NOT xlikp-verursys IS INITIAL.
  PERFORM xvbuk_lesen(sapfv50k) USING xlikp-vbeln.


* CONFIRM_DEC must only be processed, when the final GI/GR posting
* occured. (full posting and last partial goods receipt posting)
* CHECK xvbuk-wbstk = 'C'.                                   "v_YG_PGR
* Allow post partial goods receipt (via TO confirmation with the
* option '4 - Do not take putaway qty as delivery qty, but post GR')
*** following line deleted                                  "n_1294935
* CHECK xvbuk-wbstk = 'C' OR xlikp-kzebu = 'X'.              "^_YG_PGR

  active_item = ' '.                                      "v_n_1236023
* CHECK that not only batch main items have changed GR status
  LOOP AT XVBUP WHERE VBELN = xlikp-vbeln.
    READ TABLE YVBUP WITH KEY VBELN = XVBUP-VBELN
                              POSNR = XVBUP-POSNR.
    IF SY-SUBRC IS INITIAL AND XVBUP-WBSTA <> YVBUP-WBSTA.
      IF ( XVBUP-WBSTA = CHARB AND YVBUP-WBSTA = CHARA ) OR
         ( XVBUP-WBSTA = CHARC AND YVBUP-WBSTA = CHARB ).
        active_item = 'X'.
        EXIT.
      ELSEIF XVBUP-WBSTA = CHARC AND YVBUP-WBSTA = CHARA.
        READ TABLE XLIPS WITH KEY VBELN = XVBUP-VBELN
                                  POSNR = XVBUP-POSNR.
        IF SY-SUBRC = 0 AND XLIPS-KCMENG = 0.
* not a batch main item
          active_item = 'X'.
          EXIT.
        ENDIF.
      ENDIF.
    ELSEIF SY-SUBRC IS INITIAL AND                        "v_n_1274657
           XVBUP-WBSTA = CHARB AND YVBUP-WBSTA = CHARB.
      READ TABLE XLIPS WITH KEY VBELN = XVBUP-VBELN
                                POSNR = XVBUP-POSNR.
      IF SY-SUBRC = 0 AND XLIPS-KCMENG = 0 AND XLIPS-EBUMG > 0.
        active_item = 'X'.
        EXIT.
      ENDIF.                                              "^_n_1274657
    ENDIF.
  ENDLOOP.

* Case deleted items for inb. dly updated xvbuk-wbstk to C  "n_v_1486144
  If ( ACTIVE_ITEM IS INITIAL    AND
       XLIKP-VBTYP CA VBTYP_MMLI AND
       XVBUK-WBSTK = 'C').
    LOOP AT XLIPS TRANSPORTING NO FIELDS WHERE UPDKZ EQ CHARD.
       ACTIVE_ITEM = 'X'.
       EXIT.
    ENDLOOP.
  ENDIF.                                                    "n_^_1486144

  CHECK active_item = 'X' OR XLIKP-KZEBU = 'X'  "^_n_1236023 "n_1330605
*   OR ( XLIKP-VBTYP CA VBTYP_LIEF AND XVBUK-WBSTK = 'C').   "n_1342923
    OR ( XLIKP-VBTYP CA VBTYP_LINO AND XVBUK-WBSTK = 'C').   "n_1552866

  DATA: lt_ylikp TYPE STANDARD TABLE OF likpvb WITH HEADER LINE.
  MOVE-CORRESPONDING ylikp TO lt_ylikp.
  APPEND lt_ylikp.

  PERFORM get_vbpa USING xvbpa[] yvbpa[] lt_vbpa[].

  CALL FUNCTION 'SHP_BAPI_DELIVERY_CONFIRM_DEC'
    EXPORTING
      if_synchron      = v50agl-synchron
      if_obj_type      = if_obj_type
      if_ale_serial_id = if_ale_serial_id                   "ULa, 4.6c
      it_lips_add      = it_lips_add                        "ULa, 4.6c
      is_v50agl        = v50agl
      is_xvbuk         = xvbuk                                 "YG_PGR
    TABLES
      it_likp          = xlikp
      it_likp_old      = lt_ylikp
      it_lips          = xlips
      it_vbfa          = xvbfa
      it_vbpa          = lt_vbpa
      it_vbadr         = xvbadr
      it_serno_change  = gt_serno_change
      it_yvbuk         = yvbuk
      it_xvbup         = xvbup
      it_yvbup         = yvbup.


* distribution flag must be set in YLIKP
  likp-vlstk = xlikp-vlstk.
  xlikp_updkz = updkz_old.
  PERFORM likp_aendern(sapfv50k).

ENDFORM.                               " CALL_BAPI_DELIVERY_CONFIRM_DEC

*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELIVERY_CHANGE
*&---------------------------------------------------------------------*
*       Änderung der Lieferungsdaten
*----------------------------------------------------------------------*
FORM call_bapi_delivery_change
             USING if_ale_serial_id TYPE chnum.

  DATA: lv_cmact   TYPE t340d-cmact,
        lv_proceed TYPE xflag.
  FIELD-SYMBOLS: <fs_xlikp> TYPE likpvb.

  CHECK aufrufer <> chart.

  LOOP AT xlikp ASSIGNING <fs_xlikp>
                WHERE updkz = updkz_delete
                OR  ( updkz = updkz_update
                  AND lgnum IS NOT INITIAL ).

* Warehouse number is missing, restore from YLIKP
    IF <fs_xlikp>-lgnum IS INITIAL.
      READ TABLE ylikp WITH KEY vbeln = <fs_xlikp>-vbeln.
      IF sy-subrc = 0.
        <fs_xlikp>-lgnum = ylikp-lgnum.
      ENDIF.
    ENDIF.

    IF <fs_xlikp>-lgnum IS NOT INITIAL.
      CALL FUNCTION '/SPE/DETERMINE_CMACT'
        EXPORTING
          iv_lgnum            = <fs_xlikp>-lgnum
        IMPORTING
          ev_cmact            = lv_cmact
        EXCEPTIONS
          whse_does_not_exist = 0
          OTHERS              = 0.
    ENDIF.

    IF lv_cmact = gc_cmact-async AND
* Only for outbound deliveries                               "n_1148367
       <fs_xlikp>-vbtyp = vbtyp_lino.                        "n_1148367
** Currently only the deletion of unchecked deliveries is
** sent with the Change message
*     check xlikp-updkz eq lc_delete.
      CHECK v50agl-split IS INITIAL. "Dec. delivery split
      CHECK v50agl-no_rmsys_dlv_chg  IS INITIAL
         OR v50agl-ucdel_to_del_comb =  charx
         OR v50agl-ucdel_to_del      =  charx
         OR v50agl-create_uclief     =  charx.
      lv_proceed = charx.
      EXIT.
    ELSE.
      CHECK NOT v50agl-dlv_change IS INITIAL.
* delivery change management is active
      CHECK v50agl-no_rmsys_dlv_chg IS INITIAL.
* remote delivery change is required
      lv_proceed = charx.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF sy-subrc = 0.
    CHECK lv_proceed = charx.
  ELSE.
    CHECK NOT v50agl-dlv_change IS INITIAL.
* delivery change management is active
    CHECK v50agl-no_rmsys_dlv_chg IS INITIAL.
* remote delivery change is required
  ENDIF.

*  CHANGE BAPI is active in two scenarios:
*  central ERP System or decentral WMS System:
*     DLV Distribution Status : 'Distributed'
*     DLV Goods Movement Status : 'Not executed'

  DATA: lt_ylikp TYPE STANDARD TABLE OF likpvb WITH HEADER LINE.
  DATA: lt_vbpa TYPE STANDARD TABLE OF vbpavb WITH HEADER LINE.

  PERFORM get_vbpa USING xvbpa[] yvbpa[] lt_vbpa[].

  READ TABLE xlikp INDEX 1.
  PERFORM xvbuk_lesen(sapfv50k) USING xlikp-vbeln.

* Change IDOC must be processed for following cases:
* a) changes on relevant fields, eg. delivery qty.
*    (WBSTK = 'A' )
* b) partial goods receipt posting (not the last posting)
*    (WBSTK = 'B' or 'A')
  CHECK xvbuk-wbstk <> 'C'.

* In case of PGR do not send Change IDOC to ERP              "v_YG_PGR
  CHECK xlikp-kzebu <> 'X'.                                  "^_YG_PGR

  MOVE-CORRESPONDING ylikp TO lt_ylikp.
  APPEND lt_ylikp.

* asynchronous delivery change
* process IDOC SHP_IBDLV_CHANGE/SHP_OBDLV_CHANGE output
  CALL FUNCTION 'SHP_BAPI_DELIVERY_CHANGE'
    EXPORTING
      if_synchron      = v50agl-synchron
      if_ale_serial_id = if_ale_serial_id                   "ULa, 4.6c
      if_decspli       = v50agl-split
      is_v50agl        = v50agl
    TABLES
      it_xlikp         = xlikp
      it_ylikp         = lt_ylikp
      it_xlips         = xlips
      it_ylips         = ylips
      it_vbfa          = xvbfa
      it_vbpa          = lt_vbpa
      it_vbadr         = xvbadr
      it_serno_change  = gt_serno_change
      it_yvbup         = yvbup
      it_xvbup         = xvbup
      it_yvbuk         = yvbuk
      it_xvbuk         = xvbuk.


* lines deleted                                               "n_561412

ENDFORM.                               " CALL_BAPI_DELIVERY_CHANGE

*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELIVERY_SPLIT_DEC             (ULa, 4.6c)
*&---------------------------------------------------------------------*
*       Redo split in ERP system
*----------------------------------------------------------------------*
FORM call_bapi_delivery_split_dec
                    USING if_vbeln_old       TYPE vbeln_vl
                          if_vbeln_new       TYPE vbeln_vl
                          if_vbeln_root      TYPE vbeln_vl
                          if_items_belong_to TYPE ledspd_items_belong_to
                          if_split_profile   TYPE ledspd_pmode
                          if_ale_serial_id   TYPE chnum
                 CHANGING et_lips_add        TYPE shp_lips_t
                          .
* ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* This FM has to be called in advance of CALL_BAPI_DELIVERY_CONFIRM_DEC
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  DATA: lx_deliveries          TYPE leshp_delivery_t
       ,ls_data_to_select      TYPE leshp_data
       .
  FIELD-SYMBOLS:
        <ls_delivery>          TYPE leshp_delivery_s
       ,<ls_lips>              TYPE lipsvb
       .

  REFRESH et_lips_add.

* Don't do it if called by transport management
  CHECK aufrufer NE chart.

  READ TABLE xlikp INDEX 1.
* send the BAPI only in LE System/Component
  CHECK NOT xlikp-verursys IS INITIAL.

* Do it only for deliveries posted goods issue
  PERFORM xvbuk_lesen(sapfv50k) USING xlikp-vbeln.
  CHECK xvbuk-wbstk = 'C'.

* Only outbound deliveries can be splitted!
  CHECK xlikp-vbtyp CA vbtyp_lief.

* Only if pre step found out that this is a or there are splitted
* deliveries
  CHECK NOT if_vbeln_root IS INITIAL.

  IF if_vbeln_old <> if_vbeln_new.
* Split is necessary
    CALL FUNCTION 'SHP_BAPI_DELIVERY_SPLIT_DEC'
      EXPORTING
        if_synchron        = v50agl-synchron
        if_vbeln_old       = if_vbeln_old
        if_vbeln_new       = if_vbeln_new
        if_items_belong_to = if_items_belong_to
        if_split_profile   = if_split_profile
        if_ale_serial_id   = if_ale_serial_id               "ULa, 4.6c
        it_lips            = xlips[]
      TABLES
        it_likp            = xlikp
        it_vbfa            = xvbfa.
  ELSE.
* Get all items of root delivery. The delivery in the ERP system to be
* posted goods issue contains all these items as well. It has to be
* ensured that they are set to zero quantity if they aren't contained in
* this delivery.
* The item numbers are the same. The split doesn't renumber the items.
    CLEAR ls_data_to_select.
    ls_data_to_select-item = 'X'.

    CALL FUNCTION 'LE_DELIVERY_GET_BUFFERED'
      EXPORTING
*     IF_REQUESTED_VERSION         = -1
*     IF_HANDLE                    =
        if_vbeln                     = if_vbeln_root
*     IS_DELIVERY_KEY              =
*     IT_DELIVERY_KEYS             =
        is_data                      = ls_data_to_select
*     IF_FILTER_BY_ENQUE           =
*     IF_BYPASSING_BUFFER          =
      CHANGING
        cx_deliveries                = lx_deliveries
*     CX_UNLOCKABLE                =
      EXCEPTIONS
        no_item_selected             = 01
        selected_item_enqueued       = 02
        no_key_specified             = 03
        OTHERS                       = 99
              .
    IF sy-subrc <> 0.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.

    READ TABLE lx_deliveries ASSIGNING <ls_delivery> INDEX 1.
    IF sy-subrc IS INITIAL.
      LOOP AT <ls_delivery>-item ASSIGNING <ls_lips>
              WHERE posar NE gc_posar-packing.
        READ TABLE ilips TRANSPORTING NO FIELDS
             WITH KEY posnr = <ls_lips>-posnr
             BINARY SEARCH
                      .
        IF NOT sy-subrc IS INITIAL.
          <ls_lips>-vbeln = xlikp-vbeln.
          CLEAR: <ls_lips>-lfimg
                ,<ls_lips>-lfimg_flo
                ,<ls_lips>-lgmng
                ,<ls_lips>-lgmng_flo
                ,<ls_lips>-brgew
                ,<ls_lips>-ntgew
                ,<ls_lips>-volum
                .
          APPEND <ls_lips> TO et_lips_add.
        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDIF.

ENDFORM.                               " CALL_BAPI_DELIVERY_SPLIT_DEC

*&--------------------------------------------------------------------*
*&      Form  get_vbpa
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->IT_XVBPA   text
*      -->IT_YVPBA   text
*      -->IT_VBPA    text
*---------------------------------------------------------------------*
FORM get_vbpa USING it_xvbpa TYPE shp_vbpavb_t
                    it_yvpba TYPE shp_vbpavb_t
                    it_vbpa  TYPE shp_vbpavb_t.
  DATA: ls_vbpa TYPE vbpavb.

  it_vbpa[] = it_xvbpa[].
  LOOP AT it_yvpba INTO ls_vbpa
               WHERE updkz EQ updkz_delete.
    APPEND ls_vbpa TO it_vbpa.
  ENDLOOP.
  SORT it_vbpa BY vbeln posnr parvw.

ENDFORM.                    "get_vbpa
* Begin of Serialize IDOCs for posting partial goods receipt   "v_YG_PGR
*&---------------------------------------------------------------------*
*&      Form  CALL_BAPI_DELIVERY_PRESTEP               (YG, ERP2005)
*&---------------------------------------------------------------------*
*       Get serial number for the business process GRP
*----------------------------------------------------------------------*
FORM call_bapi_inb_pgr_prestep
                  CHANGING cf_obj_type       TYPE serial-obj_type
                           cf_ale_serial_id  TYPE chnum.

* ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* This FM has to be called in advance of all CALL_BAPI_DELIVERY_XXXXX
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  DATA: ls_yvbuk      TYPE vbukvb,
        lf_appl_key   TYPE char30.
  DATA: ls_tbd53      TYPE tbd53,
        ls_tbd54      TYPE tbd54,
        ls_tbd56      TYPE tbd56.
* Don't do it if SerialID is already set for LIKP
* CHECK cf_ale_serial_id is initial.

* Don't do it if called by transport management
  CHECK aufrufer NE chart.

* ATTENTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
* If this FM were called after CALL_BAPI_DELIVERY_PRESTEP,
* it might be necessary to read XLIKP and XVBUK here
* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
*  READ TABLE xlikp INDEX 1.
** send the BAPI only in LE System/Component
  CHECK NOT xlikp-verursys IS INITIAL and
            xlikp-vlstk CA 'AEF'.                             "n_1095978
*
** Do it only for deliveries posted goods issue
*  PERFORM xvbuk_lesen(sapfv50k) USING xlikp-vbeln.

* Only do it for inbound delivery
  CHECK xlikp-vbtyp EQ vbtyp_liav.
  CHECK xvbuk-wbstk <> 'A'.            "Excluding irrelevant situtions
  READ TABLE yvbuk WITH KEY vbeln = xlikp-vbeln
       INTO  ls_yvbuk.

* several lines deleted                                     "v_n_1157427

* Serialization must be done for all IDocs of partial goods receipt
    IF NOT ( ls_yvbuk-wbstk = 'A' AND xvbuk-wbstk = 'C' ) AND
           ( xlikp-kzebu = 'X' OR
           ( ls_yvbuk-wbstk CO ' B' AND xvbuk-wbstk CO 'BC' ) )."^_n_1157427 "n_1318662

* Check settings for serialzation of the ConfirmDecentral IDOCs
        SELECT SINGLE * FROM TBD53 INTO ls_tbd53
          WHERE OBJ_TYPE = 'BUS2015'
            AND MESTYP   = 'SHP_IBDLV_CONFIRM_DECENTRAL'.
        IF sy-subrc <> 0.
* Business object Inbound delivery must be serialized!
          MESSAGE a053(vlbapi).
        ENDIF.

        SELECT SINGLE * FROM TBD54 INTO ls_tbd54
          WHERE OBJ_TYPE = 'BUS2015'.
        IF sy-subrc <> 0.
          MESSAGE a053(vlbapi).
        ENDIF.

        SELECT SINGLE * FROM tbd56 INTO ls_tbd56
          WHERE rcvprt   = 'LS'
            AND obj_type = 'BUS2015'
            AND sersw    = 'X'.
        IF sy-subrc <> 0.
          MESSAGE a053(vlbapi).
        ENDIF.

* Serialize Confirmation Decentral IDOCs:
        cf_obj_type = 'BUS2015'.
        lf_appl_key = xlikp-vbeln.
* Get a Serial-ID for the inbound delivery:
        CALL FUNCTION 'ALE_SERIAL_KEY2CHANNEL'
          EXPORTING
            appl_key = lf_appl_key
          IMPORTING
            chnum    = cf_ale_serial_id.
* 2 lines deleted                                           "v_n_1157427
  ENDIF.
ENDFORM.                    "call_bapi_inb_pgr_prestep
* End of Serialization                                         "^_YG_PGR