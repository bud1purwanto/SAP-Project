*----------------------------------------------------------------------*
*   INCLUDE FV50XF0B_IBDLV_OBDLV_DOCFLOW                               *
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  IBDLV_OBDLV_DOCFLOW
*&---------------------------------------------------------------------*
*       Create a doc flow for scenario
*       Inbound delivery from outbound delivery
*----------------------------------------------------------------------*
FORM IBDLV_OBDLV_DOCFLOW TABLES IS_KOMDLGN STRUCTURE KOMDLGN
                                IS_LIKP STRUCTURE LIKPVB.
  DATA: LF_REF_VBTYP LIKE LIKP-VBTYP.
  DATA: LF_REF_FOLAR LIKE LIKP-FOLAR.
  FIELD-SYMBOLS: <ls_komdlgn> TYPE komdlgn,
                 <ls_lips>    TYPE lipsvb.
  DATA: lv_ebeln TYPE ebeln,
        lv_ebelp TYPE ebelp.
* scenario : inbound delivery from outbound delivery
* create a document flow

* check actual delivery is inbound
  CHECK IS_LIKP-VBTYP CA VBTYP_LIAV.
* check reference delivery exists
  CHECK NOT IS_KOMDLGN-RFBEL IS INITIAL.
* check delivery type exists
  CHECK NOT IS_KOMDLGN-LFART IS INITIAL.
* check reference delivery is outbound, and has a next delivery type.
  SELECT SINGLE VBTYP FOLAR INTO (LF_REF_VBTYP, LF_REF_FOLAR) FROM LIKP
                                         WHERE VBELN = IS_KOMDLGN-RFBEL.
  CHECK SY-SUBRC EQ 0.
  CHECK LF_REF_VBTYP CA VBTYP_LIEF.
  CHECK LF_REF_FOLAR EQ IS_KOMDLGN-LFART
        OR LF_REF_FOLAR IS INITIAL.

  CLEAR VBFA.
  VBFA-MANDT = IS_LIKP-MANDT.
  VBFA-VBELV = IS_KOMDLGN-RFBEL.
* vbfa-posnv = ckomdlgn-rfpos.
  VBFA-VBELN = IS_LIKP-VBELN.
* vbfa-posnn = xlips-posnr.

  VBFA-VBTYP_V = LF_REF_VBTYP.
  VBFA-VBTYP_N = IS_LIKP-VBTYP.
* vbfa-rfmng = xlips_lgmng.
* vbfa-rfmng_flt = xlips-lgmng_flo.
* vbfa-rfmng_flo = xlips-lfimg_flo.
* vbfa-vrkme = xlips-vrkme.
* vbfa-meins = xlips-meins.
* vbfa-bwart = xlips-bwart.
* vbfa-matnr = xlips-matnr.

  CALL FUNCTION 'RV_XVBFA_MAINTAIN'
       EXPORTING
            F_VORGANG = 'H'
            FVBFA     = VBFA
            FVBFAD    = VBFAD
       TABLES
            FXVBFA    = XVBFA
            FYVBFA    = YVBFA
            FXVBAPF   = XVBAPF.

* SIT: Enhance document flow with entries containing the item numbers
  IF cl_ops_switch_check=>mm_sfws_sit( ) IS NOT INITIAL.
    LOOP AT is_komdlgn ASSIGNING <ls_komdlgn> WHERE vgbel IS NOT INITIAL
                                              AND   vgtyp = vbtyp_bestell
                                              AND   rfbel IS NOT INITIAL.
      lv_ebeln = <ls_komdlgn>-vgbel.
      lv_ebelp = <ls_komdlgn>-vgpos.
      IF cl_mm_im_sit_info=>get_sit_info_item(
             iv_ebeln = lv_ebeln
             iv_ebelp = lv_ebelp ) IS NOT INITIAL.
        READ TABLE xlips ASSIGNING <ls_lips>
                         WITH KEY rfbel = <ls_komdlgn>-rfbel
                                  rfpos = <ls_komdlgn>-rfpos.
        IF sy-subrc = 0.
*         Insert item numbers and add document flow entry
          vbfa-posnv = <ls_komdlgn>-rfpos.
          vbfa-posnn = <ls_lips>-posnr.
          CALL FUNCTION 'RV_XVBFA_MAINTAIN'
               EXPORTING
                    F_VORGANG = 'H'
                    FVBFA     = VBFA
                    FVBFAD    = VBFAD
               TABLES
                    FXVBFA    = XVBFA
                    FYVBFA    = YVBFA
                    FXVBAPF   = XVBAPF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    " IBDLV_OBDLV_DOCFLOW