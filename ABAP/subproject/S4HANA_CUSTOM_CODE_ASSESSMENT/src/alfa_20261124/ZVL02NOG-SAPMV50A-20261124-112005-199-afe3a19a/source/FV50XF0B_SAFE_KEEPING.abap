*&---------------------------------------------------------------------*
*&  Include           FV50XF0B_SAFE_KEEPING
*&---------------------------------------------------------------------*

*&--------------------------------------------------------------------*
*&      Form  safe_keeping_stat_det
*&--------------------------------------------------------------------*
*       Determine the safe keeping status for a inbound delivery.
*       The status is used to restrict the processing for a delivery
*       in case of an import of goods (SAP Global Trade Services)
*---------------------------------------------------------------------*
*      -->IV_GOODS_MVtext
*      -->IV_TRTYP   text
*      -->CS_LIKP    text
*---------------------------------------------------------------------*
FORM safe_keeping_stat_det USING    iv_goods_mvmnt TYPE boolean
                                    iv_trtyp       TYPE trtyp
                           CHANGING cs_likp        TYPE likp.

  data: li_SLL_PI_TEMP_STORAGE type ref to SLL_PI_TEMP_STORAGE.

  get badi li_SLL_PI_TEMP_STORAGE.

  if li_SLL_PI_TEMP_STORAGE is bound.

    CALL badi li_SLL_PI_TEMP_STORAGE->TEMP_STORAGE_STATUS_DET
      EXPORTING
        IV_TRANSACTION_TYPE = iv_trtyp
        IV_GOODS_MVMNT      = iv_goods_mvmnt
      CHANGING
        CS_LIKP             = cs_likp.

  endif.

ENDFORM.                    "safe_keeping_stat_det

*&--------------------------------------------------------------------*
*&      Form  safe_keeping_stat_det_gm
*&--------------------------------------------------------------------*
*       Determine temporary storage status for GM simulation with
*       transfer to SAP GTS
*---------------------------------------------------------------------*
*      -->IV_GOODS_MVtext
*      -->IV_TRTYP   text
*      -->IT_XLIPS   text
*      -->IT_IMSEG   text
*      -->CS_LIKP    text
*---------------------------------------------------------------------*
FORM safe_keeping_stat_det_gm USING    iv_goods_mvmnt TYPE boolean
                                       iv_trtyp       TYPE trtyp
                                       it_xlips       TYPE shp_lips_t
                                       it_imseg       TYPE shp_imsegvb_t
                              CHANGING cs_likp        TYPE likp.

  data: lv_sakes               type GTS_SAKES,
        li_SLL_PI_TEMP_STORAGE type ref to SLL_PI_TEMP_STORAGE.

  lv_sakes = cs_likp-sakes.

  get badi li_SLL_PI_TEMP_STORAGE.

  if li_SLL_PI_TEMP_STORAGE is bound.

    CALL badi li_SLL_PI_TEMP_STORAGE->TEMP_STORAGE_STATUS_DET_GM
      EXPORTING
        IV_TRANSACTION_TYPE = iv_trtyp
        IV_GOODS_MVMNT      = iv_goods_mvmnt
      CHANGING
        CS_LIKP             = cs_likp.

    IF cs_likp-sakes NE lv_sakes AND
       cs_likp-sakes EQ charb.

      CALL badi li_SLL_PI_TEMP_STORAGE->TEMP_STORAGE_DELIVERY_TRANSFER
        EXPORTING
          IS_LIKP  = cs_likp
          IT_XLIPS = it_xlips
          IT_IMSEG = it_imseg.

    endif.

  endif.

ENDFORM.                    "safe_keeping_stat_det_gm

*&--------------------------------------------------------------------*
*&      Form  safe_keeping_stat_det_all
*&--------------------------------------------------------------------*
*       Determine the safe keeping status for all deliveries in XLIKP
*---------------------------------------------------------------------*
*      -->IV_GOODS_MVtext
*      -->IV_TRTYP   text
*---------------------------------------------------------------------*
FORM safe_keeping_stat_det_all USING iv_goods_mvmnt TYPE boolean
                                     iv_trtyp       TYPE trtyp.

  FIELD-SYMBOLS: <ls_xlikp> TYPE likpvb,
                 <ls_likp>.

  ASSIGN xlikp TO <ls_likp> CASTING TYPE likp.
  PERFORM safe_keeping_stat_det USING    iv_goods_mvmnt
                                         iv_trtyp
                                CHANGING <ls_likp>.

  LOOP AT xlikp ASSIGNING <ls_xlikp> WHERE updkz NE updkz_delete.
    ASSIGN <ls_xlikp> TO <ls_likp> CASTING TYPE likp.
    PERFORM safe_keeping_stat_det USING    iv_goods_mvmnt
                                           iv_trtyp
                                  CHANGING <ls_likp>.
  ENDLOOP.

ENDFORM.                    "safe_keeping_stat_det

*&--------------------------------------------------------------------*
*&      Form  safe_keeping_mode_det
*&--------------------------------------------------------------------*
*       text
*---------------------------------------------------------------------*
*      -->CV_MODE_DIStext
*---------------------------------------------------------------------*
FORM safe_keeping_mode_det CHANGING cv_display_mode TYPE boolean.

  data: li_SLL_PI_TEMP_STORAGE type ref to SLL_PI_TEMP_STORAGE.

  get badi li_SLL_PI_TEMP_STORAGE.

  if li_SLL_PI_TEMP_STORAGE is bound.

    CALL badi li_SLL_PI_TEMP_STORAGE->TEMP_STORAGE_MODE_DET
      CHANGING
        CV_DISPLAY_MODE = cv_display_mode.

  endif.

ENDFORM.                    "safe_keeping_mode_det