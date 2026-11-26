report ZMMC_EXT_SLOC.
*       no standard page heading line-size 255.

INCLUDE ZMMC_EXT_SLOC_TOP.

INCLUDE ZMMC_EXT_SLOC_F01.

*include bdcrecx1.

*start-of-selection.
*
*CALL FUNCTION 'UPLOAD'
*    EXPORTING
*      FILETYPE = 'DAT'
*    TABLES
*      DATA_TAB = ITAB.
*
**perform open_group.
*LOOP AT ITAB.
*  perform bdc_dynpro      using 'SAPMM03M' '0105'.
*  perform bdc_field       using 'BDC_CURSOR'
*                                'RM03M-NFLAG'.
*  perform bdc_field       using 'BDC_OKCODE'
*                                '/00'.
*  perform bdc_field       using 'RM03M-MATNR'
*                                 ITAB-MATNR. "'IRM03'.
*  perform bdc_field       using 'RM03M-WERKS'
*                                 ITAB-WERKS. "'2000'.
*  perform bdc_field       using 'RM03M-LFLAG'
*                                 ITAB-LFLAG. "''.
*  perform bdc_field       using 'RM03M-NFLAG'
*                                 ITAB-NFLAG. "'X'.
*  perform bdc_dynpro      using 'SAPMM03M' '0195'.
*  perform bdc_field       using 'BDC_CURSOR'
*                                'RM03M-LGORT(01)'.
*  perform bdc_field       using 'BDC_OKCODE'
*                                '=BU'.
*  perform bdc_field       using 'RM03M-LGORT(01)'
*                                ITAB-LGORT. "'2002'.
*  perform bdc_transaction using 'MMSC'.
*
*ENDLOOP.
*perform close_group.