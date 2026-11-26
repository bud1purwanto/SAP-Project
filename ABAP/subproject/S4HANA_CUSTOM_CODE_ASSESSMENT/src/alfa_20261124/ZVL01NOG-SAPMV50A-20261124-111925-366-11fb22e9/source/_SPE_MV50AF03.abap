*&---------------------------------------------------------------------*
*&  Include           /SPE/MV50AF03
*&---------------------------------------------------------------------*
*FORM spe_sub_struc_set CHANGING ct_xlips TYPE shp_lips_t.
*
*  DATA: lv_vbeln TYPE lips-vbeln,
*        lv_posnr TYPE lips-posnr.
*
*  FIELD-SYMBOLS: <fs_sub_item> TYPE lipsvb,
*                 <fs_head>     TYPE lipsvb.
*
** For all sub-items the indicator spe_sub_struc has to be
** set in the corresponding superior item
*  LOOP AT ct_xlips ASSIGNING <fs_sub_item>
*                   WHERE uepos IS NOT INITIAL.
*
*    IF lv_vbeln <> <fs_sub_item>-vbeln OR
*       lv_posnr <> <fs_sub_item>-uepos.
*      lv_vbeln = <fs_sub_item>-vbeln.
*      lv_posnr = <fs_sub_item>-uepos.
*      READ TABLE ct_xlips ASSIGNING <fs_head>
*                          WITH KEY vbeln = lv_vbeln
*                                   posnr = lv_posnr.
*      CHECK sy-subrc = 0.
*      <fs_head>-spe_sub_struc = gc_true.
*    ENDIF.
*
*  ENDLOOP.
*
*ENDFORM.                    "spe_sub_struc_set