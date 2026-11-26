*&---------------------------------------------------------------------*
*&  Include           LMIGOKS5                                         *
*&---------------------------------------------------------------------*

************************************************************************
* METHOD SPECIAL_STOCK_IDENTIFIER_SET
* The sending/receiving special stock indentifier fields (frame on
* TRANSFER-Tabstrip) have the name 'UMMAT_...' rep. MAT_LIFNR and
* MAT_KUNNR.
* In the material document we don't have these fields. Therefore we have
* to fill these fields with single moves.
************************************************************************
METHOD special_stock_identifier_set.

  DATA: l_lifnr TYPE lifnr,
        l_kunnr TYPE kunnr.

  CHECK s_action-migo_mode = 'GT'.

  l_lifnr = cs_goitem-lifnr.
  l_kunnr = cs_goitem-kunnr.

  CASE cs_goitem-umsok.
    WHEN e.
      cs_goitem-ummat_kdauf = cs_goitem-kdauf.
      cs_goitem-ummat_kdpos = cs_goitem-kdpos.
      CLEAR cs_goitem-kdauf.
      CLEAR cs_goitem-kdpos.
    WHEN q.
      cs_goitem-ummat_pspnr = cs_goitem-ps_psp_pnr.
      CLEAR cs_goitem-ps_psp_pnr.
    WHEN p OR k OR m OR o.
*     EMLIF should always be filled. If not (should never happen)
*     we take LIFNR.
      IF cs_goitem-emlif IS INITIAL.
        cs_goitem-ummat_lifnr = l_lifnr.
      ELSE.
        cs_goitem-ummat_lifnr = cs_goitem-emlif.
      ENDIF.
      clear cs_goitem-lifnr.
    WHEN t.                                              "SIT
      cs_goitem-vbeln = cs_goitem-kdauf.
      cs_goitem-posnr = cs_goitem-kdpos.
      CLEAR cs_goitem-kdauf.
      CLEAR cs_goitem-kdpos.
    WHEN v OR w.
      cs_goitem-ummat_kunnr = l_kunnr .
      clear cs_goitem-kunnr.
    WHEN OTHERS.
ENHANCEMENT-POINT EHP604_SPECIAL_STOCK_IDENT_02 SPOTS ES_SAPLMIGO .
  ENDCASE.

  CASE cs_goitem-sobkz.
    WHEN p OR k OR m OR o.
ENHANCEMENT-SECTION EHP604_SPECIAL_STOCK_IDENT_03 SPOTS ES_SAPLMIGO .
      cs_goitem-mat_lifnr = l_lifnr.
      CLEAR cs_goitem-lifnr.
END-ENHANCEMENT-SECTION.
    WHEN v OR w.
      cs_goitem-mat_kunnr = l_kunnr .
      CLEAR cs_goitem-kunnr.
    WHEN OTHERS.
  ENDCASE.

ENDMETHOD.

************************************************************************
* METHOD SPECIAL_STOCK_IDENTIFIER_IMSEG_SET
* Function MB_CREATE_GOODS_MOVEMENT does not know UMMAT-fields (in table
* IMSEG). This means we have to fill the correct IMSEG-fields by single
* MOVE-statements.
* Attention:
* Transfer from one special stock identifier to another is only possible
* for E/Q. For P/K/M/O/V/W receiving/issuing field always is equal to
* the special stock identifier field.
* In case of transfer from special stock K to non special stock (411K),
* the vendor of the issuing side needs to be filled in the LIFNR as no
* UMMAT_LIFNR is available in IMSEG. Same for KUNNR... but right now no
* movements exits with UMSOK initial and special stock V or W.
* Vice versa in case of e.g. 541 O only UMSOK is filled and therefore
* the vendor needs to be filled with the UMMAT_LIFNR.
* Summarization: The following rule is valid: Use UMMAT_field in case
* UMSOK is filled with special stock vendor or customer. If SOBKZ is
* filled, we can always use the MAT-fields for vendor and customer.
************************************************************************
METHOD special_stock_imseg_set.

  CASE is_goitem-umsok.
    WHEN e.
      cs_imseg-kdauf = is_goitem-ummat_kdauf.
      cs_imseg-kdpos = is_goitem-ummat_kdpos.
    WHEN q.
      cs_imseg-ps_psp_pnr = is_goitem-ummat_pspnr.
    WHEN p OR k OR m OR o.
ENHANCEMENT-SECTION EHP604_SPECIAL_STOCK_IMSEG_03 SPOTS ES_SAPLMIGO .
      cs_imseg-lifnr = is_goitem-ummat_lifnr.
END-ENHANCEMENT-SECTION.
    WHEN t.                                                            "SIT
      cs_imseg-vbeln = is_goitem-vbeln.
      cs_imseg-posnr = is_goitem-posnr.
    WHEN v OR w.
      cs_imseg-kunnr = is_goitem-ummat_kunnr.
    WHEN OTHERS.
ENHANCEMENT-POINT EHP604_SPECIAL_STOCK_IMSEG_04 SPOTS ES_SAPLMIGO .
  ENDCASE.

  CASE is_goitem-sobkz.
    WHEN p OR k OR m OR o.
      IF is_goitem-xpoitem <> abap_true                          "573662
       OR is_goitem-sobkz <> 'O'.                                "573662
ENHANCEMENT-SECTION EHP604_SPECIAL_STOCK_IMSEG_05 SPOTS ES_SAPLMIGO .
        cs_imseg-lifnr = is_goitem-mat_lifnr.
END-ENHANCEMENT-SECTION.
      ENDIF.                                                     "573662
    WHEN t.                                                      "SIT
      cs_imseg-vbeln = is_goitem-vlief_avis.
      cs_imseg-posnr = is_goitem-vbelp_avis.
    WHEN v OR w.
      cs_imseg-kunnr = is_goitem-mat_kunnr.
    WHEN OTHERS.
ENHANCEMENT-POINT EHP604_SPECIAL_STOCK_IMSEG_06 SPOTS ES_SAPLMIGO .
  ENDCASE.

ENDMETHOD.