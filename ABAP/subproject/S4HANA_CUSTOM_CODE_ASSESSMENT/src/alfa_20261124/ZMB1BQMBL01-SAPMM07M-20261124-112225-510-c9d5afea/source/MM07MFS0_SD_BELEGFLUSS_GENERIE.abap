*---------------------------------------------------------------------*
*       FORM SD_BELEGFLUSS_GENERIEREN                                 *
*---------------------------------------------------------------------*
*       Die Daten für die Belegflußschreibung im SD werden erzeugt.   *
*---------------------------------------------------------------------*
form sd_belegfluss_generieren.

*** Begin of OSS-Note 579926

  DATA: p_mtcom LIKE mtcom,
        p_mtcor LIKE mtcor,
        p_mbefu LIKE mbefu.

  CLEAR p_mtcom.

* SPE ST 28.01.2005
* VL-MM Consistency
  DATA: l_append_ok(1) TYPE c VALUE space,
        ls_t156        TYPE t156,
        l_dm07m        LIKE LINE OF zdm07m,
        index_a1       like index_l,
        index_a2       like index_l,
        l_subrc        LIKE sy-subrc,
        ls_ekpo        TYPE ekpo.                        "N1082145

  DATA: lf_vbeln TYPE vbeln_vl,
        lf_posnr TYPE posnr_vl,
        lv_vbtyp TYPE vbtyp_n,
        lv_ebeln TYPE ebeln,
        lv_ebelp TYPE ebelp,
        lv_vrkme TYPE vrkme.

ENHANCEMENT-POINT MM07MFS0_SD_BELEGFLUSS_GENE_02 SPOTS ES_SAPMM07M.

*** End of OSS-Note 579926

ENHANCEMENT-SECTION     SD_BELEGFLUSS_GENERIEREN_01 SPOTS ES_SAPMM07M.
* check if form is called by SD
  check im_process <> l.
END-ENHANCEMENT-SECTION.
  if not xvm07m-vbeln is initial and not xvm07m-vbelp is initial
                                 and not xmseg-xauto = x
                                 and not xmseg-umsok = 'T'.   "1657162

* No deliver flow update in case of transaction MBSU             "423743
    check T158-FCODE <> fcod-su.                              "423743
    move-corresponding xmseg to xvbfa.
    xvbfa-vbelv = xvm07m-vbeln.
    xvbfa-posnv = xvm07m-vbelp.
    xvbfa-posnn = xmseg-zeile.
    if dm07m-xstbw = x.
      xvbfa-plmin = minus.
    else.
      xvbfa-plmin = plus.
    endif.
    xvbfa-rfwrt = xmseg-dmbtr.
    xvbfa-vbtyp_n = 'i'.
* For a return delivery the VBTYP_V must be 'T', otherwise       "498152
* it is always 'J' (outbound delivery).                          "498152
    if xvm07m-retpo is initial.                               "498152
      xvbfa-vbtyp_v = j.                                      "498152
    else.                                                     "498152
      xvbfa-vbtyp_v = t.                                      "498152
    endif.                                                    "498152
    l_append_ok = 'X'.
  endif.

* SPE ST 28.01.2005
* VL-MM Consistency
  if /spe/cl_cust=>is_vl_mm_active( ) = 'X'
  OR ( xmseg-ebeln IS NOT INITIAL                               "1576541
   AND cl_mm_im_sit_info=>get_sit_info_weora(
                          iv_ebeln = xmseg-ebeln ) IS NOT INITIAL ).
* UpPort note 881890 2006-02-01
*    if xmigo = 'X'.
    IF xmigo = 'X' OR ( xmbwl = 'X' and xbapi = space ).
*   Different handling when not all items where posted.
      DESCRIBE TABLE zdm07m LINES INDEX_A1.
      DESCRIBE TABLE xmseg LINES INDEX_A2.
*      if INDEX_A1 > INDEX_A2.                                "AP780155
      if INDEX_A1 NE INDEX_A2.                                "1462154
        read table zdm07m into l_dm07m with key zeild = ymbuz-zeilz.
        else.
        read table zdm07m into l_dm07m with key zeild = xmseg-zeile.
      endif.
      l_subrc = sy-subrc.
    elseif xbapi = 'X'.
*     read table zdm07m into l_dm07m with key zeild = xmseg-line_id.      "n_1059116
      read table zdm07m into l_dm07m with key zeild = xmseg-zeile.        "n_1059116
      l_subrc = sy-subrc.
    elseif sy-tcode = 'MB01' or sy-tcode = 'MB0A'.
      read table zdm07m into l_dm07m with key zeild = xmseg-line_id.
      l_subrc = sy-subrc.
    elseif sy-tcode = 'MBST' or sy-tcode = 'MBRL'.
* lines deleted notes 722750, 905827, 1173526                             "n_1179096
      read table zdm07m into l_dm07m with key zeild = xmseg-zeile.        "n_1179096
      l_subrc = sy-subrc.
    endif.

    if l_subrc = 0 and not ( l_dm07m-vbeln_vl is initial ) and
      not ( l_dm07m-vbelp_vl is initial ) and not ( xmseg-xauto = x ).
*   No deliver flow update in case of transaction MBSU      "423743
      check t158-fcode <> fcod-su.                            "423743
      read table gt_likp with key vbeln = l_dm07m-vbeln_vl.
      if sy-subrc = 0 AND gt_likp-vbtyp = '7'. "Inbound delivery
        read table gt_lips with key vbeln = l_dm07m-vbeln_vl
                                    posnr = l_dm07m-vbelp_vl.
        if sy-subrc = 0.
*  For Subcontracting components no VBFA entry allowed: note 770237
        IF l_dm07m-xstbw = 'X'.                                  "770237
            IF l_dm07m-wamng > 0.                                  "N1082145
              CALL FUNCTION 'ME_EKPO_SINGLE_READ'
                EXPORTING
                  pi_ebeln         = xmseg-ebeln                   "N1082145
                  pi_ebelp         = xmseg-ebelp
                IMPORTING
                  po_ekpo          = ls_ekpo                       "N1082145
                EXCEPTIONS
                  NO_RECORDS_FOUND = 1
                  OTHERS           = 2.
              IF sy-subrc = 0 AND ls_ekpo-pstyp = '3'.
                CHECK l_dm07m-wamng = 0.                           "770237
              ENDIF.
            ENDIF.                                                 "N1082145
        ENDIF.                                                   "770237

*    Data has been selected
          move-corresponding xmseg TO xvbfa.
          xvbfa-vbtyp_v = '7'. "Anlieferung
          xvbfa-vrkme = gt_lips-vrkme.
          xvbfa-vbelv = l_dm07m-vbeln_vl.
          xvbfa-posnv = l_dm07m-vbelp_vl.
          xvbfa-posnn = xmseg-zeile.
          xvbfa-rfwrt = xmseg-dmbtr.
          xvbfa-vbtyp_n = 'R'. "Goods movement
          CLEAR xvbfa-lgnum.                                     "923841
          l_append_ok = 'X'.
*       Read T156
          clear ls_t156.
          CALL FUNCTION '/SPE/GEN_T156_GET'
            EXPORTING
              IF_BWART       = xvbfa-bwart
           IMPORTING
             ES_T156         = ls_t156
           EXCEPTIONS
             NOT_FOUND       = 1
             OTHERS          = 2.
*       PLMIN
          if not ls_t156-shkzg is initial.
            if ls_t156-shkzg = 'H'.
              xvbfa-plmin = minus.
            else.
              xvbfa-plmin = plus.
            endif.
          else.
            if dm07m-xstbw = x.
              xvbfa-plmin = minus.
            else.
              xvbfa-plmin = plus.
            endif. "XSTBW
          endif."SHKZG is initial
        endif. "subrc gt_lips
      endif. "subrc gt_likp
     endif. "subrc  zdm07m
  endif.

* Delivery Document Flow Update
  PERFORM SPE_additional_doc_flow_update
      CHANGING xvbfa-plmin
               xvbfa-vbtyp_n
               xvbfa-vbtyp_v.

* Delivery flow update for SIT
  IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.
    IF ( t156-bustr = '559'
    OR ( t156-bustr = '335' OR t156-bustr = '417' ) AND xmseg-sobkz = 'T' )
    AND xmseg-ebeln IS INITIAL
      OR ( xmseg-ebeln IS NOT INITIAL
      AND ( xmseg-sobkz = 'T' OR xmseg-umsok = 'T' ) ).
      SELECT SINGLE vbtyp FROM likp INTO (lv_vbtyp)
             WHERE vbeln = xvm07m-vbeln.
      IF lv_vbtyp CA 'JT'.                                      "1657162
*       Outbound delivery number entered
        SELECT SINGLE vgbel vgpos vrkme FROM lips
               INTO (lv_ebeln, lv_ebelp, lv_vrkme)
               WHERE vbeln = xvm07m-vbeln
               AND   posnr = xvm07m-vbelp.
      ELSEIF lv_vbtyp = '7'.
*       Get the assigned outbound delivery                      "1657162
        SELECT SINGLE vbeln_st vbelp_st FROM ekes  "#EC WARNOK "#EC CI_NOFIRST
               INTO (lf_vbeln, lf_posnr)
               WHERE vbeln = xvm07m-vbeln
               AND   vbelp = xvm07m-vbelp.
        IF sy-subrc = 0.
          SELECT SINGLE vgbel vgpos vrkme FROM lips
                 INTO (lv_ebeln, lv_ebelp, lv_vrkme)
                 WHERE vbeln = lf_vbeln
                 AND   posnr = lf_posnr.
        ENDIF.
      ENDIF.
      IF sy-subrc <> 0 AND l_append_ok IS NOT INITIAL.          "1583699
        CLEAR l_append_ok.
      ENDIF.
      IF sy-subrc = 0 AND lv_ebeln IS NOT INITIAL AND
         cl_mm_im_sit_info=>get_sit_info_item(
            iv_ebeln = lv_ebeln
            iv_ebelp = lv_ebelp ) IS NOT INITIAL.
        MOVE-CORRESPONDING xmseg TO xvbfa.
        xvbfa-vbelv = xvm07m-vbeln.
        xvbfa-posnv = xvm07m-vbelp.
        xvbfa-posnn = xmseg-zeile.
        xvbfa-rfwrt = xmseg-dmbtr.
        xvbfa-vrkme = lv_vrkme.
        xvbfa-vbtyp_v = lv_vbtyp.                               "1554198
        xvbfa-vbtyp_n = 'p'. "Goods movement (documentation)
        CLEAR xvbfa-lgnum.
        IF xmseg-shkzg = 'H'.
          xvbfa-plmin = minus.
        ELSE.
          xvbfa-plmin = plus.
        ENDIF.
        l_append_ok = 'X'.
      ENDIF.
    ENDIF.
  ENDIF.                                                      "1602566

* Check for 'Acceptance At Origin' -> Movement types 107 + 109
  IF t156-bustr = '559' AND l_dm07m-vbeln_vl IS NOT INITIAL.     "1657162
    SELECT SINGLE vgbel vrkme FROM lips INTO (lv_ebeln, lv_vrkme)"1657162
           WHERE vbeln = l_dm07m-vbeln_vl                        "1657162
           AND   posnr = l_dm07m-vbelp_vl.                       "1657162
  ENDIF.
  IF ( t156-bustr = '107' OR t156-bustr = '109' )             "1576541
  AND xmseg-ebeln IS NOT INITIAL AND l_dm07m-vbeln_vl IS NOT INITIAL
  AND cl_mm_im_sit_info=>get_sit_info_weora(
                         iv_ebeln = xmseg-ebeln ) IS NOT INITIAL
  OR ( t156-bustr = '559' AND l_dm07m-vbeln_vl IS NOT INITIAL    "1657162
  AND cl_mm_im_sit_info=>get_sit_info_weora(                     "1657162
                         iv_ebeln = lv_ebeln ) IS NOT INITIAL ). "1657162

*   Get the sales UOM
    SELECT SINGLE vrkme FROM lips INTO lv_vrkme
           WHERE vbeln = l_dm07m-vbeln_vl
           AND   posnr = l_dm07m-vbelp_vl.
    MOVE-CORRESPONDING xmseg TO xvbfa.
    xvbfa-vbelv = l_dm07m-vbeln_vl.
    xvbfa-posnv = l_dm07m-vbelp_vl.
    xvbfa-posnn = xmseg-zeile.
    xvbfa-rfwrt = xmseg-dmbtr.
    xvbfa-vrkme = lv_vrkme.
    xvbfa-vbtyp_v = '7'.    "Inbound delivery
    IF t156-bustr = '107' OR t156-bustr = '559'.                 "1657162
      xvbfa-vbtyp_n = 'p'. "Goods movement (documentation)
    ELSE.
      xvbfa-vbtyp_n = 'R'. "Goods movement
    ENDIF.
    CLEAR xvbfa-lgnum.
    IF xmseg-shkzg = 'H'.
      xvbfa-plmin = minus.
    ELSE.
      xvbfa-plmin = plus.
    ENDIF.
    l_append_ok = 'X'.
  ENDIF.

* Store information about delivery category for later call   "n_941879
* of FM SD_DELIVERY_WE_FLOW_UPDATE                           "n_941879
  g_vbtyp_v =  xvbfa-vbtyp_v.                                "n_941879

*** Begin of OSS-Note 579926

* Abfrage auf Wertartikel
  if l_append_ok = 'X'.
    if gt_lips-vbeln <> l_dm07m-vbeln_vl or               "v_n_1308586
       gt_lips-posnr <> l_dm07m-vbelp_vl.
      read table gt_lips with key vbeln = l_dm07m-vbeln_vl
                                  posnr = l_dm07m-vbelp_vl.
    endif.                                                "^_n_1308586
    if xmseg-mengu is initial and NOT xmseg-wertu is initial.
*   Nachlesen der Basismengeneinheit -> Aufruf MATERIAL_READ
      move: xmseg-werks       TO p_mtcom-werks,
            xmseg-lgort       TO p_mtcom-lgort,
            xmseg-matnr       TO p_mtcom-matnr,
            'MBEFU'           TO p_mtcom-kenng,
            sy-langu          TO p_mtcom-spras.

      CALL FUNCTION 'MATERIAL_READ'
        EXPORTING
          schluessel      = p_mtcom
        IMPORTING
          matdaten        = p_mbefu
          return          = p_mtcor
        TABLES
          seqmat01        = dummy
        EXCEPTIONS
          plant_not_found = 1.

      if sy-subrc is initial.
*     Basismengeneinheit in xvbfa-meins übernehmen
        xvbfa-meins = p_mbefu-meins.
*     Erfassungsmengeneinheit = Basismengeneinheit
        if xmseg-erfme = p_mbefu-meins.
*       Übernahme xmseg-erfmg
          xvbfa-rfmng = xmseg-erfmg.
*         xvbfa-rfmng_flo = xvbfa-rfmng / 1000.             "n_1308586
          if xmseg-erfme = gt_lips-vrkme and xmseg-erfmg > 0. "v_n_1342935
            xvbfa-rfmng_flo = xmseg-erfmg / 1000.               "n_1352857
          else.
            xvbfa-rfmng_flo =
                     xvbfa-rfmng / 1000 * gt_lips-umvkn / gt_lips-umvkz.
          endif.                                              "^_n_1342935
        else.
*       Erfassungsmengeneinheit != Basismengeneinheit
*       Umrechnen Erfassungsmengeneinheit in Basismengeneinheit
          xvbfa-rfmng = xmseg-erfmg * xvm07m-bumrz / xvm07m-bumrn.
*         xvbfa-rfmng_flo = xvbfa-rfmng / 1000.             "n_1308586
          if xmseg-erfme = gt_lips-vrkme and xmseg-erfmg > 0. "v_n_1342935
            xvbfa-rfmng_flo = xmseg-erfmg / 1000.               "n_1352857
          else.
            xvbfa-rfmng_flo =
                     xvbfa-rfmng / 1000 * gt_lips-umvkn / gt_lips-umvkz.
          endif.                                              "^_n_1342935
        endif.
      elseif sy-subrc = 1.
        sy-msgid = 'M3'.
        sy-msgno = '351'.
        sy-msgty = 'E'.
        sy-msgv1 = xmseg-matnr.
        sy-msgv2 = xmseg-werks.
      endif.
    else.
      xvbfa-rfmng = xmseg-menge.
*     xvbfa-rfmng_flo = xvbfa-rfmng / 1000.                 "n_1308586
      if ( xmseg-erfme = gt_lips-vrkme or xvbfa-vbtyp_n = 'p' ) "SIT
      and xmseg-erfmg > 0.
        xvbfa-rfmng_flo = xmseg-erfmg / 1000.                   "n_1352857
      else.
        xvbfa-rfmng_flo =
                 xvbfa-rfmng / 1000 * gt_lips-umvkn / gt_lips-umvkz.
      endif.                                                  "^_n_1342935
    endif.

*  xvbfa-rfmng = xmseg-menge.

*** End of OSS-Note 579926

* SPE ST 28.01.2005
* VL-MM Consistency
    If /spe/cl_cust=>is_vl_mm_active( ) = 'X'.
      if xmseg-menge is initial and xmseg-matnr is initial.
        xvbfa-rfmng = xmseg-erfmg.
        xvbfa-rfmng_flo = xvbfa-rfmng / 1000.
        xvbfa-meins = xmseg-erfme.
      endif.
    endif.

    append xvbfa.
  endif.
endform.                    "sd_belegfluss_generieren