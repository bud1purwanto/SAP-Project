*eject
*---------------------------------------------------------------------*
*       FORM BESTELLUNG_UEBERNEHMEN_01                                *
*---------------------------------------------------------------------*
*       Weitere Daten werden übernommen. Dieser Part wurde ausge-     *
*       lagert, damit auch bei WE zur Umlagerbestellung über LMBWL    *
*       diese Routine laufen kann.                                    *
*---------------------------------------------------------------------*
  FORM bestellung_uebernehmen_01.
* The following variable have no effect for the Core Code
* conditions, its value changes only in the switched code.
* This usage makes possible to avoid enh. sections.
    DATA: lv_ad_rec_po VALUE space.     "EHP604 GM080418

    IF NOT dm07m-weora IS INITIAL AND vm07m-xstor IS INITIAL   "1496472
       AND NOT ( t156-bustr = '107' OR t156-bustr = '109' ).   "1496472
      MESSAGE e429(M7).
    ENDIF.
*   note 1513367 replaces note 1095226 and note 889855 (code deletion)
    dm07m-wwmng = xebefu-wemng - xebefu-wemmg.
    dm07m-bpwwm = xebefu-bpwem - xebefu-bpwmm.
* Uebernahme der Teilmenge einer Versandelementposition
    IF NOT h_vemng IS INITIAL.
      xebefu-erfmg = h_vemng.
      xebefu-bstme = h_vemeh.                               "note 388707
      CLEAR h_vemeh.                                        "note 388707
      CLEAR h_vemng.
    ENDIF.
    IF NOT h_charg IS INITIAL.                              "note 388707
      xebefu-charg = h_charg.                               "note 388707
    ENDIF.                                                  "note 388707
    CLEAR h_charg.                                          "note 388707
    mseg-bpmng = 0.
    IF ( vm07m-kzwes NE s AND mseg-lgort IS INITIAL ) OR
       ( NOT xmbwl IS INITIAL AND NOT rm07m-lgort IS INITIAL ).
      mseg-lgort = rm07m-lgort.
    ENDIF.
ENHANCEMENT-POINT EHP604_BESTELLUNG_UEBERNEHM_01 SPOTS ES_SAPMM07M.
    IF mseg-charg is initial                                "note 399934
       AND lv_ad_rec_po IS INITIAL.                            "GM080415
      mseg-charg = xebefu-charg.                            "note 399934
*   note 639934: avoid inconsistencies between PO and material document
*   due to unexpected changes of any related document
*   delivery: responsible for not posting on a different batch if there
*   was a batch in the PO (EKPO) already; in addition, EKES as second
*   source of batch information is updated by delivery
*   => rely on delivery but refuse other postings which might cause
*   an inconsistent situation of MSEG and PO
*   risk when taking over either batch: inconsistencies of MSEG and PO
*   that would result in
*   valuation errors in case of an invoice with a different value and
*   split valuated material
*   or
*   update terminations
*   no necessity to take over batch here in case of a delivery, this is
*   already done in MB_CREATE_GOODS_ISSUE_ITEM
    ELSEIF im_process <> L AND                                  " 639934
       lv_ad_rec_po IS INITIAL.                               " GM080415
      IF NOT ( mseg-charg IS INITIAL OR xebefu-charg IS INITIAL )
           AND mseg-charg <> xebefu-charg.                      " 639934
        MESSAGE e427 WITH mseg-charg xebefu-charg.              " 639934
*       Eingegebene Charge &1 passt nicht zu Charge &2 in Bestellung.
      ENDIF.                                                    " 639934
    ENDIF.                                                  "note 399934
    IF t156-bustr = '167' AND
       mseg-charg IS NOT INITIAL AND mseg-lgort IS NOT INITIAL. "SIT
      CLEAR mseg-lgort.                                         "SIT
    ENDIF.                                                      "SIT
    IF xebefu-bsakz = t.                                         "sdp462
      mseg-kzzug = x.
      MOVE-CORRESPONDING xebefu TO msegk.
    ELSE.
      CLEAR mseg-kzzug.
    ENDIF.
    IF xebefu-erfmg IS INITIAL AND ( xebefu-noqty IS INITIAL OR
      NOT x_avis IS INITIAL ).
      CALL FUNCTION 'MB_PROPOSE_RECEIPT_QUANTITY'
           EXPORTING
                shkzg = mseg-shkzg
                retpo = vm07m-retpo
                kzwes = vm07m-kzwes
                wesbs = xebefu-wesbs
                bpwes = xebefu-bpwes
                lfbnr = mseg-lfbnr
                vlief = h_liefk
                lamng = xebefu-lamng
                lwmng = xebefu-lwmng
                lwsbs = xebefu-lwsbs
                etens = xebefu-etens
                bsakz = xebefu-bsakz   "BSAKZ on item level       sdp462
                wemng = xebefu-wemng
                wamng = xebefu-wamng
                xselp = fcausw-xselp
                bsmng = xebefu-bsmng
                bpwem = xebefu-bpwem
                webre = xebefu-webre
                wesbb = xebefu-wesbb
                bpweb = xebefu-bpweb
                lwsbb = xebefu-lwsbb
           IMPORTING
                mblmg = dm07m-mblmg
                mblbm = dm07m-mblbm
                erfmg = mseg-erfmg
                bpmng = mseg-bpmng.
    ELSE.
      mseg-erfmg = xebefu-erfmg.
      mseg-erfme = xebefu-bstme.                            "note 388707
      mseg-bpmng = xebefu-bpmng.
      IF NOT xebefu-lfbnr IS INITIAL.
        dm07m-mblmg = xebefu-erfmg.
        dm07m-mblbm = xebefu-bpmng.
      ENDIF.
    ENDIF.
*BAdI for India
   SELECT SINGLE land1 FROM t001w INTO t001w-land1
                                 WHERE werks = rm07m-werks.
    IF sy-subrc EQ 0.

      CALL FUNCTION 'SAP_TO_ISO_COUNTRY_CODE'
        EXPORTING
          sap_code    = t001w-land1
        IMPORTING
          iso_code    = t005-intca
        EXCEPTIONS
          not_found   = 1
          no_iso_code = 2
          OTHERS      = 3.
      IF sy-subrc <> 0.
        MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
      ENDIF.
      IF sy-subrc EQ 0.
        CALL FUNCTION 'SXC_EXIT_CHECK_ACTIVE'
           EXPORTING
             EXIT_NAME                = 'MB_CIN_MM07MFB7_QTY'
            FLT_VAL       = t005-intca
           EXCEPTIONS
             NOT_ACTIVE               = 1
           OTHERS                     = 2.
        IF SY-SUBRC = 0.
          CALL METHOD cl_exithandler=>get_instance
            EXPORTING
              exit_name              = 'MB_CIN_MM07MFB7_QTY'
              null_instance_accepted = x
            CHANGING instance =  mb_grqty.
          IF NOT mb_grqty IS initial.
            CALL METHOD  mb_grqty->set_quantity_in_gr
             EXPORTING
                ebeln = xebefu-ebeln
                flt_val = t005-intca
                ebelp = xebefu-ebelp
             CHANGING
                erfmg = mseg-erfmg
                bpmng = mseg-bpmng.
          ENDIF.
        ENDIF.
      ENDIF.
     ENDIF.
*BAdI for India

    CLEAR vw.
    mseg-kzbew = rm07m-kzbew.
    IF NOT mseg-matnr IS INITIAL.
      dm07m-xlort = x.
      dm07m-xchar = x.
    ENDIF.

*   note 442706
    IF x_mulko IS INITIAL.                             "442706
      x_mulko = dm07m-mulko.                           "442706
    ENDIF.                                             "442706

    IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.
      IF mkpf-fls_rsto <> abap_true.
        mkpf-fls_rsto = xebefu-fls_rsto.
      ENDIF.
    ENDIF.

  ENDFORM.