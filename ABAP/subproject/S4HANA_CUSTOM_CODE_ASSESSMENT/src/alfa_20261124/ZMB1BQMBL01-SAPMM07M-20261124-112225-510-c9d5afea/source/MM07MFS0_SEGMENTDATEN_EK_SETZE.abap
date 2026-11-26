*eject
*---------------------------------------------------------------------*
*       FORM SEGMENTDATEN_EK_SETZEN                                   *
*---------------------------------------------------------------------*
*       Die Einkaufsdaten werden in das Segment uebernommen.          *
*---------------------------------------------------------------------*

* MB03 : avoid error M7 187 in display mode AA of MM doc which  "n1617739
* belongs to a MAA PO item                                      "n1617739

*---------------------------------------------------------------------*

FORM segmentdaten_ek_setzen.

  DATA: l_k_mseg TYPE mseg.                                 " 979280

* --- begin ------------------------------------- MAA2
  DATA : ls_xaccounting                LIKE  LINE OF xaccounting,
         ls_xaccounting_cr_00          LIKE  LINE OF xaccounting_cr,
         ls_xaccounting_cr_10          LIKE  LINE OF xaccounting_cr.

     IF NOT xmbwl IS INITIAL.
*   look for MAA processing here not for MB* transactions
      IF NOT xebefu-xhistma        IS INITIAL     AND
         NOT mseg-zekkn            IS INITIAL.       " ingore EhP4 reference MM docs

*     check consistency of the XHISTMA flags and
*     replace the particular MAA data in structure XEBEFU
        CALL METHOD go_mmim_maa_2->copy_maa_data_to_xebefu
          EXPORTING
            it_xaccounting       = xaccounting[]
            iv_rw_vorgang        = rw_vorgang
            is_mkpf              = mkpf
            it_xaccounting_cr    = xaccounting_cr[]
          CHANGING
            cs_fuss              = fuss
            cs_xaccounting       = ls_xaccounting
            cs_xaccounting_cr_00 = ls_xaccounting_cr_00
            cs_xaccounting_cr_10 = ls_xaccounting_cr_10
            cs_xebefu            = xebefu
            cs_mseg              = mseg
            ct_message_log       = gt_message_log
            cv_flag_error        = gv_flag_error
            cs_dm07m             = dm07m
            cs_vm07m             = vm07m.

        IF gv_flag_error = abap_true.
          PERFORM              send_maa_error_message.
        ENDIF.

      ENDIF.
    ELSE.
*     check for old EHP4/5 documents, set split indicator V
      IF NOT xebefu-xhistma IS INITIAL AND
         ( NOT mseg-smbln IS INITIAL OR
               fcode = fcod-sn       OR
               fcode = fcod-sf          ) AND                 "1691340
               mseg-xmacc IS INITIAL AND NOT rm07m-xdeliv = 'X'.
        mseg-xmacc = 'V'.
*       line_id useless
        FIELD-SYMBOLS <xmseg> TYPE mseg.
        CLEAR mseg-line_id.
        IF NOT xmseg-line_id IS INITIAL.
          LOOP AT xmseg ASSIGNING <xmseg>.
            clear <xmseg>-line_id.
          ENDLOOP.
          CLEAR xmseg-line_id.
*         reset line_id counter to zero
          CALL METHOD cl_mmim_line_id_manager=>reset.
        ENDIF.
      ENDIF.
    ENDIF.
* --- end --------------------------------------- MAA2

* MAA EhP4 begin -------------------------------------------"MAA EhP4
  DATA: l_xhistma     TYPE ebefu-xhistma,
        ls_goitem_maa TYPE goitem.

  IF dm07m-xhistma = 'B'.
    l_xhistma = dm07m-xhistma.
  ENDIF.

  IF xmbwl IS INITIAL AND
     t158-trtyp = a   AND
     NOT mseg-mblnr IS INITIAL.
    MOVE-CORRESPONDING mseg  TO ls_goitem_maa.
    MOVE-CORRESPONDING vm07m TO ls_goitem_maa.
    MOVE-CORRESPONDING dm07m TO ls_goitem_maa.
    CALL FUNCTION 'MB_MAA_VALUE_SET'
      EXPORTING
        igoitem  = ls_goitem_maa
        idispval = 'X'
      IMPORTING
        emulko   = dm07m-mulko.
  ENDIF.
* MAA EhP4 end ---------------------------------------------"MAA EhP4

* --- begin ----------------------------------------------- MAA2
  IF NOT xebefu-xhistma  IS INITIAL.
*   this is a GR for a MAA PO item

    IF NOT  mseg-bustw = bustw_we06 AND NOT mseg-bustw IS INITIAL.
*     but the movement type is not MAA relevant
      CLEAR :                xebefu-xhistma.
    ENDIF.
  ENDIF.

  IF NOT xebefu-xhistma        IS INITIAL    AND
     NOT mseg-zekkn            IS INITIAL.       " ingore EhP4 reference MM docs
*   this is a MAA line, structure LS_XACCOUNTING comprises the
*   odered the ordered quantity on AA level

    IF  NOT xebefu-netwr IS INITIAL.

      IF ls_xaccounting-ebeln IS INITIAL.                      "n1617739
*       display mode AA data not filled -> check item value    "n1617739
        IF     xebefu-bsmng IS INITIAL AND                     "n1617739
           NOT xebefu-netwr IS INITIAL.                        "n1617739
*         Purchase order contains a value without a qty        "n1617739
          MESSAGE e187.                                        "n1617739
        ENDIF.                                                 "n1617739

      ELSE.                                                    "n1617739
*     PO item contains a value
      IF  ls_xaccounting-bsmng     IS INITIAL  AND
          ls_xaccounting-bsmng_abd IS INITIAL.
*       Purchase order contains a value without a qty
        MESSAGE              e187.
      ENDIF.
      ENDIF.                                                   "n1617739
    ENDIF.
  ELSE.
    IF xebefu-bsmng IS INITIAL AND NOT xebefu-netwr IS INITIAL.
      MESSAGE e187.
*      Die Bestellung enthält einen Wert ohne Menge
    ENDIF.
  ENDIF.
* --- end ------------------------------------------------- MAA2

  IF cl_ops_switch_check=>ops_sfws_sc_advret1( ) = abap_true.
    IF mkpf-msr_active IS INITIAL AND kbefu-msr_id IS NOT INITIAL.
      mkpf-msr_active = abap_true.
    ENDIF.
    IF vm07m-xstor <> 2.
      CLEAR kbefu-msr_id.
    ENDIF.
  ENDIF.

  MOVE-CORRESPONDING kbefu TO dm07m.
  MOVE-CORRESPONDING kbefu TO vm07m.
  vm07m-statuk = kbefu-estak.
  vm07m-kunwe = kbefu-kunnr.
  dm07m-maktx = xebefu-txz01.
  dm07m-xwmhd = t159l-xwmhd.
  CHECK t158-trtyp = h.

  IF ( sy-langu NE kbefu-spras OR xebefu-txz01 IS INITIAL )
     AND NOT xebefu-matnr IS INITIAL.
    PERFORM kurztext_lesen(sapfm07m) USING xebefu-matnr.
    dm07m-maktx = mbefu-maktx.
  ENDIF.
* Durchreichen des Kanbankennzeichens an das WM (D024693 MK)
* Wenn es einmal sitzt, soll es auch so bleiben
  DATA: kanba_lv LIKE dm07m-kanba.
  CLEAR kanba_lv.
  IF NOT xmbwl IS INITIAL AND NOT dm07m-kanba IS INITIAL.
    MOVE dm07m-kanba TO kanba_lv.
  ENDIF.
  MOVE-CORRESPONDING xebefu TO dm07m.

* MAA EhP4 begin -------------------------------------------"MAA EhP4
  IF NOT l_xhistma IS INITIAL.
    dm07m-xhistma = l_xhistma.
  ENDIF.
* MAA EhP4 end ---------------------------------------------"MAA EhP4

  dm07m-cuobj_refdoc = xebefu-cuobj.                        "630576
  IF NOT kanba_lv IS INITIAL.
    MOVE kanba_lv TO dm07m-kanba.
  ENDIF.

  dm07m-wwmng = xebefu-wemng - xebefu-wemmg.
  dm07m-bpwwm = xebefu-bpwem - xebefu-bpwmm.
* note 1513367 replaces note 1095226

*   return delivery via BAPI and ASSET is used  act the         "1350447
*   same as MBRL and fill XMKPF to get the BUDAT of the         "1350447
*   reference doc for xaccit-webud. See also note 1310801       "1350447
  IF xbapi = 'X' AND                                        "1350447
     xmkpf-mblnr  IS INITIAL AND                            "1350447
     xmkpf-budat  IS INITIAL AND                            "1350447
     mseg-lfbnr   IS NOT INITIAL AND                        "1350447
     mseg-lfbja   IS NOT INITIAL AND                        "1350447
     xebefu-anln1 IS NOT INITIAL AND                        "1350447
     mseg-kzbew   = 'B'.                                    "1350447
                                                            "1350447
    CALL FUNCTION 'MB_READ_MATERIAL_HEADER'                 "1350447
        EXPORTING                                           "1350447
            mblnr         = mseg-lfbnr                      "1350447
            mjahr         = mseg-lfbja                      "1350447
            trtyp         = 'A'                             "1350447
        IMPORTING                                           "1350447
            kopf          = xmkpf                           "1350447
        EXCEPTIONS                                          "1350447
            error_message = 1.                              "1350447
  ENDIF.                                                    "1350447

  IF t156n-xstor = zwei AND NOT mseg-sakto IS INITIAL.
    dm07m-konto = mseg-sakto.
  ENDIF.
  MOVE-CORRESPONDING xebefu TO vm07m.
  MOVE xebefu-abelp TO vm07m-abepl.                         " 423874
ENHANCEMENT-POINT SEGMENTDATEN_EK_SETZEN_01 SPOTS ES_SAPMM07M.
  dm07m-ek_vkwrt = xebefu-vkwrt.
  dm07m-ek_vkwra = xebefu-vkwra.
  vm07m-elikz_old = xebefu-elikz.
  dm07m-ek_exvkw  = mseg-exvkw.                             " 384238
  IF xebefu-inco1 IS INITIAL.
    dm07m-inco1 = kbefu-inco1.
  ENDIF.
  IF xebefu-inco2 IS INITIAL.
    dm07m-inco2 = kbefu-inco2.
  ENDIF.
  vm07m-ek_charg = xebefu-charg.
  vm07m-ek_lifch = kbefu-llief.
  IF vm07m-ek_lifch IS INITIAL.
    vm07m-ek_lifch = kbefu-lifnr.
  ENDIF.
  vm07m-ek_licha = xebefu-licha.
  IF dm07m-ean11_bme IS INITIAL.
    dm07m-ean11_bme = xebefu-ean11.
  ENDIF.
* Retail: value added services in MIGO
  IF xebefu-upvor = neun AND xmigo = x AND NOT vas_mseg[] IS INITIAL.
    dm07m-xvash = x.
    fuss-xvash = x.
  ENDIF.

  PERFORM segmentdaten_ek_werte.

  IF rm07m-mblnr IS INITIAL OR ( NOT rm07m-mblnr IS INITIAL
     AND xebefu-bsakz = t AND vm07m-xstor IS INITIAL ).     "sdp462
    DATA: gsber LIKE mseg-gsber,
          prctr LIKE mseg-prctr,
          insmk LIKE mseg-insmk,
          charg LIKE mseg-charg.
    gsber = mseg-gsber.
    prctr = mseg-prctr.
    charg = mseg-charg.
    insmk = mseg-insmk.
    DATA matnr LIKE mseg-matnr. matnr = mseg-matnr.
    DATA werks LIKE mseg-werks. werks = mseg-werks.
    DATA bwtar LIKE mseg-bwtar. bwtar = mseg-bwtar.
    DATA lgort LIKE mseg-lgort. lgort = mseg-lgort.
    DATA kunnr LIKE mseg-kunnr. kunnr = mseg-kunnr.
* begin note 663537 - Fashion
    PERFORM call_badi_consi_setsobkzlifnr USING  kbefu      " 663537
                                                 mseg-sobkz " 663537
                                                 mseg-lifnr. " 663537

* end note 663537 - Fashion
    MOVE-CORRESPONDING kbefu TO mseg.

    mseg-kunnr = kunnr.
ENHANCEMENT-POINT SEGMENTDATEN_EK_SETZEN_02 SPOTS ES_SAPMM07M.
*   use document data rather than PO data for doc.cancellation   "937012
    IF vm07m-xstor = 2 AND xmigo = x.                       "937012
      DATA aufnr LIKE mseg-aufnr. aufnr = mseg-aufnr.       "937012
      DATA kostl LIKE mseg-kostl. kostl = mseg-kostl.       "937012
      DATA kzvbr LIKE mseg-kzvbr. kzvbr = mseg-kzvbr.       "1382731
    ENDIF.                                                  "937012

    MOVE-CORRESPONDING mseg TO l_k_mseg.                    "979280
ENHANCEMENT-SECTION     EHP604_SEGMENTDATEN_EK_SETZ_01 SPOTS ES_SAPMM07M.
    MOVE-CORRESPONDING xebefu TO mseg.


END-ENHANCEMENT-SECTION.
    IF vm07m-xstor = 2 AND xmigo = x.                       "937012
      mseg-aufnr = aufnr.                                   "937012
      mseg-kostl = kostl.                                   "937012
      mseg-kzvbr = kzvbr.                                   "1382731
      CLEAR: aufnr, kostl, kzvbr.                           "937012
    ENDIF.                                                  "937012


ENHANCEMENT-POINT SEGMENTDATEN_EK_SETZEN_05 SPOTS ES_SAPMM07M .

*   return delivery with VL02N and not MBRL                      "965985
*   use delivery data rather than PO data                        "965985
    IF im_process = 'L' AND mseg-kzbew = 'B' AND            "965985
       xmigo IS INITIAL AND mseg-shkzg = 'H'.               "965985
      IF xebefu-bwtar IS INITIAL.                           "965985
        mseg-bwtar = bwtar.                                 "965985
      ENDIF.                                                "965985
    ENDIF.                                                  "965985

ENHANCEMENT-POINT SEGMENTDATEN_EK_SETZEN_04 SPOTS ES_SAPMM07M.
* begin note 663537 - Fashion
    PERFORM call_badi_consi_getsobkzlifnr USING kbefu       " 663537
                                                xebefu      " 663537
                                                l_k_mseg    " 979280
                                                mseg        " 663537
                                                vm07m       " 663537
                                                rm07m       " 663537
                                                wueb        " 663537
                                                mkpf        " 663537
                                           CHANGING         " 663537
                                                mseg-sobkz  " 663537
                                                mseg-lifnr. " 663537

*end note 663537 - Fashion

* RMA: goods issue must be processed before goods receipt of 2-step-transfer
    DATA: lr_mb_transfer TYPE REF TO mb_transfer,
          ls_goitem TYPE goitem,
          ls_return TYPE bapiret2.
    TRY.
        GET BADI lr_mb_transfer.
        CALL BADI lr_mb_transfer->check_order_of_steps
          EXPORTING
            is_mseg   = mseg
            is_kbefu  = kbefu
            is_ebefu  = xebefu
            is_vm07m  = vm07m
            is_rm07m  = rm07m
            is_wueb   = wueb
            is_goitem = ls_goitem
          IMPORTING
            e_return  = ls_return.
        IF NOT ls_return IS INITIAL.
          MESSAGE ID ls_return-id TYPE ls_return-type NUMBER ls_return-number
            WITH ls_return-message_v1 ls_return-message_v2
                 ls_return-message_v3 ls_return-message_v4.
        ENDIF.
      CATCH cx_badi_not_implemented.
    ENDTRY.

    IF dm07m-umkzb = b AND NOT mseg-kzbew = b
                        AND mseg-ummat IS INITIAL.
      mseg-ummat = mseg-matnr. mseg-matnr = matnr.
      mseg-umwrk = mseg-werks. mseg-werks = werks.
      mseg-umbar = mseg-bwtar. mseg-bwtar = bwtar.
      IF mseg-umlgo IS INITIAL.
        mseg-umlgo = mseg-lgort.
      ENDIF.
      mseg-lgort = lgort.
    ENDIF.
    mseg-gsber = gsber.
    mseg-prctr = prctr.
    IF NOT rm07m-mblnr IS INITIAL AND xebefu-bsakz = t.     "sdp462
      mseg-insmk = insmk.
    ENDIF.
    IF ( NOT charg IS INITIAL AND mseg-charg IS INITIAL ) OR
         im_process = l.                                    " 639934
      mseg-charg = charg.
    ENDIF.
    mseg-erfme = xebefu-bstme.
    mseg-pargb = xebefu-gsber.
    mseg-pprctr = xebefu-prctr.
    IF mseg-bwart EQ bwart_141 OR mseg-bwart EQ bwart_142.
      mseg-bwtar = bwtar.
    ENDIF.
  ELSE.
ENHANCEMENT-SECTION     EHP604_SEGMENTDATEN_EK_SETZ_02 SPOTS ES_SAPMM07M.
    mseg-bwtar = xebefu-bwtar.
END-ENHANCEMENT-SECTION.
    mseg-weunb = xebefu-weunb.
    IF fcode = fcod-sf.
      mseg-lgort = xebefu-lgort.
      IF mseg-lgort IS INITIAL.
        mseg-lgort = rm07m-lgort.
      ENDIF.
      mseg-insmk = xebefu-insmk.
    ENDIF.
ENHANCEMENT-POINT SEGMENTDATEN_EK_SETZEN_03 SPOTS ES_SAPMM07M.
  ENDIF.
* Note 1132635: GR-blocked stock and valuated GR-blocked stock
* should not influence delivery completed indicator of PO
  IF xmbwl IS INITIAL AND vm07m-xstor = '2' AND vm07m-kzwes = 'S'.
    mseg-elikz = xebefu-elikz.
  ENDIF.
  IF mseg-sobkz = e AND mseg-mat_kdauf IS INITIAL.
    mseg-mat_kdauf = mseg-kdauf.
    mseg-mat_kdpos = mseg-kdpos.
  ENDIF.
  IF mseg-sobkz = q AND mseg-mat_pspnr IS INITIAL.
    mseg-mat_pspnr = mseg-ps_psp_pnr.
  ENDIF.
* begin of SIT
  IF vm07m-vbeln IS NOT INITIAL OR mseg-sobkz = t.
    PERFORM lieferung_pruefen(sapmm07m) USING vm07m-vbeln
                                              vm07m-vbelp.
  ENDIF.
* end od SIT
  dm07m-bwtor = mseg-bwtar.
  vm07m-bumrz = dm07m-umrez.
  vm07m-bumrn = dm07m-umren.
  dm07m-bpbmg = 0.
  IF NOT mseg-bprme IS INITIAL.
    CALL FUNCTION 'MB_UNIT_CONVERSION'
      EXPORTING
        matnr                = mseg-matnr
        meins                = mseg-bprme
        erfme                = mseg-bstme
        menge                = dm07m-bpbmg
        erfmg                = dm07m-bsmng
        umrez                = dm07m-bpumz
        umren                = dm07m-bpumn
      IMPORTING
        o_menge              = dm07m-bpbmg
        o_erfmg              = dm07m-bsmng
      EXCEPTIONS
        conversion_not_found = 4.
    IF NOT sy-subrc IS INITIAL.
      MESSAGE e026 WITH mseg-bprme mseg-bstme.
    ENDIF.
  ENDIF.

* begin ----------------------------------------------------"MAA2
* check whether the content of the MAA specific fields
* in the structures MSEG, DM07M, and VM07M ore correct
  IF NOT xebefu-xhistma        IS INITIAL   AND
         mseg-bustw            = bustw_we06 AND
          NOT fuss IS INITIAL.   "for cancelation via MIGO
*     restore content of field ZEKKN
    MOVE  l_k_mseg-zekkn   TO  mseg-zekkn.

*     copy particular MAA data to stucture MSEG             "MAA2
    CALL METHOD go_mmim_maa_2->copy_maa_data_to_mseg
      EXPORTING
        is_fuss        = fuss
        is_xebefu      = xebefu
        is_xaccounting = ls_xaccounting
      CHANGING
        cs_mseg        = mseg.

*     copy particular MAA data to stucture DM07M            "MAA2
    CALL METHOD go_mmim_maa_2->copy_maa_data_to_dm07m
      EXPORTING
        is_fuss              = fuss
        is_xebefu            = xebefu
        is_xaccounting       = ls_xaccounting
        is_xaccounting_cr_00 = ls_xaccounting_cr_00
        is_xaccounting_cr_10 = ls_xaccounting_cr_10
        is_mseg              = mseg
      CHANGING
        cs_dm07m             = dm07m.

*     copy particular MAA data to stucture VM07M            "MAA2
    CALL METHOD go_mmim_maa_2->copy_maa_data_to_vm07m
      EXPORTING
        is_fuss        = fuss
        is_xebefu      = xebefu
        is_xaccounting = ls_xaccounting
      CHANGING
        cs_vm07m       = vm07m.
  ENDIF.                                                    "MAA2
*-- end ---------------------------------------------------- MAA2

* special handling for incoming GR postings for PO item with
* GR-based invoice verification
  IF NOT vm07m-webre IS INITIAL AND mseg-lfbnr IS INITIAL.
    dm07m-remng = dm07m-wemng.
    dm07m-bprem = dm07m-bpwem.
    dm07m-rewrt = dm07m-arewr = dm07m-wewrt.

    IF  mseg-bustw            = bustw_we06 AND              "MAA2
        xebefu-mulko          = gc_mulko_3.                 "MAA2
*     amount based distribution -> copy float quantities    "MAA2
      dm07m-remng_abd = ls_xaccounting-wemng_f.
      dm07m-bprem_abd = ls_xaccounting-bpwem_f.
    ENDIF.
  ENDIF.



ENHANCEMENT-POINT SEGMENTDATEN_EK_SETZE_06 SPOTS ES_SAPMM07M .

ENDFORM.                    "segmentdaten_ek_setzen