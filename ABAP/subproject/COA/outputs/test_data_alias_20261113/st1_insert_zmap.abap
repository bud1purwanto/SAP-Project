REPORT ZZST1ZMAP.
* Tahap 1 data uji alias: ZMAP_COA baru untuk SRAACI (PLE-22)
DATA: LS TYPE ZMAP_COA, LV_N TYPE I.
SELECT COUNT(*) INTO LV_N FROM ZMAP_COA WHERE MATNR = 'SRAACI'.
IF LV_N > 0.
  WRITE: / 'ABORT: SRAACI sudah ada', LV_N. EXIT.
ENDIF.
DEFINE ADDM.
  CLEAR LS.
  LS-MATNR = 'SRAACI'. LS-MIC = &1. LS-METHOD = &2.
  LS-MAPPING = 'JR Base Film'. LS-UOM = &3. LS-MIC_DESC = &4.
  LS-SEQ_NO = &5. LS-USNAM = SY-UNAME. LS-CPUDT = SY-DATUM.
  LS-CPUTM = SY-UZEIT.
  INSERT ZMAP_COA FROM LS.
  WRITE: / &1, SY-SUBRC.
END-OF-DEFINITION.
ADDM 'PAACTH00' 'ASTM D 374'  'um'     'Thickness'           '001'.
ADDM 'PAACTSMD' 'ASTM D 882'  'kg/mm2' 'Tensile Strength MD' '002'.
ADDM 'PAACTSTD' 'ASTM D 882'  'kg/mm2' 'Tensile Strength TD' '003'.
ADDM 'PAACELMD' 'ASTM D 882'  '%'      'Elongation MD'       '004'.
ADDM 'PAACELTD' 'ASTM D 882'  '%'      'Elongation TD'       '005'.
ADDM 'PAACSHMD' 'ASTM D 1204' '%'      'Shrinkage MD'        '006'.
ADDM 'PAACSHTD' 'ASTM D 1204' '%'      'Shrinkage TD'        '007'.
ADDM 'PAACHZ00' 'ASTM D 1003' '%'      'Haze'                '008'.
ADDM 'PAACG400' 'ASTM D 2457' '%'      'Gloss 45'            '009'.
COMMIT WORK.
WRITE: / 'DONE'.
