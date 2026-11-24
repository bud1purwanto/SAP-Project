*&---------------------------------------------------------------------*
*& Report  ZPPI_JR_EXEC_BDC
*&
*&---------------------------------------------------------------------*
*&
*&
*&---------------------------------------------------------------------*

REPORT  ZPPI_JR_EXEC_BDC
       NO STANDARD PAGE HEADING LINE-SIZE 255.

INCLUDE ZBDCREX1.

PARAMETERS : PMATNR LIKE MAKT-MATNR,
             PWERKS LIKE AUFK-WERKS,
             PLGORT LIKE MCHB-LGORT,
             PTEXT TYPE C LENGTH 40,
             DLINE LIKE AUFK-ZLINE,
             DCODE LIKE AUFK-ZCODE,
             DWIDTH TYPE C LENGTH 18,
             DTREAT LIKE AUFK-ZTREAT,
             DSPEED TYPE C LENGTH 18.

START-OF-SELECTION.
PERFORM OPEN_GROUP.
*DO.
  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'DFBATCH-LGORT'.
  PERFORM BDC_FIELD       USING 'DFBATCH-MATNR'
                                PMATNR."record-MATNR_001.
  PERFORM BDC_FIELD       USING 'DFBATCH-WERKS'
                                PWERKS."record-WERKS_002.
  PERFORM BDC_FIELD       USING 'DFBATCH-LGORT'
                                PLGORT.

  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SNST'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'MCHA-HSDAT'.

  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=CLAS'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'DFBATCH-KZTXT'.
  PERFORM BDC_FIELD       USING 'DFBATCH-SPRAS'
                                SY-LANGU.
  PERFORM BDC_FIELD       USING 'DFBATCH-KZTXT'
                                PTEXT."record-KZTXT_005.

  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(02)'.
  PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                DLINE."record-MWERT_01_006.
  PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'
                                DCODE."record-MWERT_02_007.
  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(07)'.
  PERFORM BDC_FIELD       USING 'RCTMS-MWERT(07)'
                                DWIDTH."record-MWERT_07_008.

  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=P+'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(07)'.
  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=ENTR'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM BDC_FIELD       USING 'RCTMS-MWERT(01)'
                                DTREAT.
  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=P+'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(01)'.
  PERFORM BDC_DYNPRO      USING 'SAPLCHRG' '1000'.
  PERFORM BDC_FIELD       USING 'BDC_OKCODE'
                                '=SAVE'.
  PERFORM BDC_FIELD       USING 'BDC_CURSOR'
                                'RCTMS-MWERT(02)'.
  PERFORM BDC_FIELD       USING 'RCTMS-MWERT(02)'
                                DSPEED."ecord-MWERT_02_010.
  PERFORM BDC_TRANSACTION USING 'MSC1N'.

*enddo.

PERFORM CLOSE_GROUP.