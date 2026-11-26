report ZMMC_EXT_CLASS.

INCLUDE ZMMC_EXT_CLASS_TOP.

INCLUDE ZMMC_EXT_CLASS_F01.

*start-of-selection.
*CLEAR : ITAB, ITAB2.
*  REFRESH : ITAB, ITAB2.
*
*  CALL FUNCTION 'UPLOAD'
*    EXPORTING
*      FILETYPE = 'DAT'
*    TABLES
*      DATA_TAB = ITAB.
*
*  ITAB2[] = ITAB[].
*  DELETE ADJACENT DUPLICATES FROM ITAB COMPARING MATNR KLART1 KLART2.
**  SORT ITAB ASCENDING BY MATNR KLART1 KLART2.
*
*
**perform open_group.
*
*LOOP AT ITAB.
*    perform bdc_dynpro      using 'SAPLMGMM' '0060'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'RMMG1-MATNR'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '=ENTR'.
*    perform bdc_field       using 'RMMG1-MATNR'
*                                   ITAB-MATNR.  "'LSMW41'.
*    perform bdc_field       using 'RMMG1-MBRSH'
*                                   ITAB-MBRSH.  "'M'.
*    perform bdc_field       using 'RMMG1-MTART'
*                                   ITAB-MTART.  "'ZSFG'.
*
*
*    perform bdc_dynpro      using 'SAPLMGMM' '0070'.
*    perform bdc_field       using 'BDC_CURSOR'
*                                  'MSICHTAUSW-DYTXT(03)'.
*    perform bdc_field       using 'BDC_OKCODE'
*                                  '=ENTR'.
*    perform bdc_field       using 'MSICHTAUSW-KZSEL(03)'
*                                  'X'.
*
*    IF ITAB-KLART2 = ' '.
*      LOOP AT ITAB2 WHERE MATNR = ITAB-MATNR AND KLART1 = ITAB-KLART1 AND KLART2 = ITAB-KLART2.
*          perform bdc_dynpro      using 'SAPLCLCA' '0602'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-KLART'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=ENTE'.
*          perform bdc_field       using 'RMCLF-KLART'
*                                         ITAB2-KLART1. "'023'.
*
*
*          perform bdc_dynpro      using 'SAPLCLFM' '0500'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-CLASS(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '/00'.
*          perform bdc_field       using 'RMCLF-CLASS(01)'
*                                         ITAB2-CLASS1. "'ZZJRBOPET'.
*
*
*          perform bdc_dynpro      using 'SAPLCTMS' '0109'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RCTMS-MWERT(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=BACK'.
*          perform bdc_field       using 'RCTMS-MNAME(01)'
*                                         ITAB2-MNAME1.  "'ZZCODE'.
*          perform bdc_field       using 'RCTMS-MWERT(01)'
*                                         ITAB2-MWERT1. "'VPC'.
*
*          perform bdc_dynpro      using 'SAPLCLFM' '0500'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-CLASS(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=SAVE'.
**          perform bdc_field       using 'RMCLF-PAGPOS'
**                                        '1'.
*        ENDLOOP.
*    ELSE.
*      LOOP AT ITAB2 WHERE MATNR = ITAB-MATNR AND KLART1 = ITAB-KLART1 AND KLART2 = ITAB-KLART2.
*          perform bdc_dynpro      using 'SAPLCLCA' '0602'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-KLART'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=ENTE'.
*          perform bdc_field       using 'RMCLF-KLART'
*                                         ITAB2-KLART1. "'023'.
*
*
*          perform bdc_dynpro      using 'SAPLCLFM' '0500'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-CLASS(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '/00'.
*          perform bdc_field       using 'RMCLF-CLASS(01)'
*                                         ITAB2-CLASS1. "'ZZJRBOPET'.
*
*
*          perform bdc_dynpro      using 'SAPLCTMS' '0109'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RCTMS-MWERT(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=BACK'.
*          perform bdc_field       using 'RCTMS-MNAME(01)'
*                                         ITAB2-MNAME1.  "'ZZCODE'.
*          perform bdc_field       using 'RCTMS-MWERT(01)'
*                                         ITAB2-MWERT1. "'VPC'.
*
*
*          perform bdc_dynpro      using 'SAPLCLFM' '0500'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-CLASS(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=WECH'.
*          perform bdc_field       using 'RMCLF-PAGPOS'
*                                        '1'.
*
*
*          perform bdc_dynpro      using 'SAPLCLCA' '0602'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-KLART'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=ENTE'.
*          perform bdc_field       using 'RMCLF-KLART'
*                                         ITAB2-KLART2. "'300'.
*
*
*          perform bdc_dynpro      using 'SAPLCLFM' '0500'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-CLASS(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '/00'.
*          perform bdc_field       using 'RMCLF-CLASS(01)'
*                                         ITAB2-CLASS2. "'ZZSRNORM'.
*
*
*          perform bdc_dynpro      using 'SAPLCTMS' '0109'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RCTMS-MWERT(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=BACK'.
*          perform bdc_field       using 'RCTMS-MNAME(01)'
*                                         ITAB2-MNAME2. "'ZZCODE'.
*          perform bdc_field       using 'RCTMS-MWERT(01)'
*                                         ITAB2-MWERT2. "'PEO'.
*
*
*          perform bdc_dynpro      using 'SAPLCLFM' '0500'.
*          perform bdc_field       using 'BDC_CURSOR'
*                                        'RMCLF-CLASS(01)'.
*          perform bdc_field       using 'BDC_OKCODE'
*                                        '=SAVE'.
*          perform bdc_field       using 'RMCLF-PAGPOS'
*                                        '1'.
*        ENDLOOP.
*    ENDIF.
*
*    perform bdc_transaction using 'MM01'.
*ENDLOOP.

*perform close_group.