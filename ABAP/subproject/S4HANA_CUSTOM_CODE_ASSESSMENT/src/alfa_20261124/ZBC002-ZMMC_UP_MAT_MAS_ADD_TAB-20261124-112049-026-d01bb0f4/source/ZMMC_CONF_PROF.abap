report ZMMC_CONF_PROF.
*       no standard page heading line-size 255.

INCLUDE ZMMC_CONF_PROF_TOP.

INCLUDE ZMMC_CONF_PROF_F01.
*include bdcrecx1.


*start-of-selection.
*  CALL FUNCTION 'UPLOAD'
*    EXPORTING
*      FILETYPE = 'DAT'
*    TABLES
*      DATA_TAB = ITAB.
*
**perform open_group.
*LOOP AT ITAB.
*
*  perform bdc_dynpro      using 'SAPLCUCO' '0110'.
*  perform bdc_field       using 'BDC_CURSOR'
*                                'RCUCO-MATNR'.
*  perform bdc_field       using 'BDC_OKCODE'
*                                '/00'.
*  perform bdc_field       using 'RCUCO-MATNR'
*                                ITAB-MATNR. "'IRM01'.
*  perform bdc_field       using 'RCUCO-DATUM'
*                                ITAB-DATUM. "'30.10.2012'.
*  perform bdc_dynpro      using 'SAPLCUCO' '0200'.
*  perform bdc_field       using 'BDC_CURSOR'
*                                'RCUCO-KLART(01)'.
*  perform bdc_field       using 'BDC_OKCODE'
*                                '/00'.
*  perform bdc_field       using 'RCUCO-PRIO(01)'
*                                ITAB-PRIO. "'01'.
*  perform bdc_field       using 'RCUCO-PRFID(01)'
*                                ITAB-PRFID. "'PROFILE 01'.
*  perform bdc_field       using 'RCUCO-KLART(01)'
*                                ITAB-KLART. "'300'.
*  perform bdc_dynpro      using 'SAPLCUCO' '0200'.
*  perform bdc_field       using 'BDC_CURSOR'
*                                'RCUCO-PRIO(01)'.
*  perform bdc_field       using 'BDC_OKCODE'
*                                '=SAVE'.
*  perform bdc_transaction using 'CU41'.
*ENDLOOP.
**perform close_group.