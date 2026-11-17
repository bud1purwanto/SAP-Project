REPORT ZZST13ZMAP.
* Data uji TTA: ZMAP_COA SRCBUX umum (MIC dari plan SRCBUX EP12X)
DATA: LS TYPE ZMAP_COA, LV_N TYPE I.
SELECT COUNT(*) INTO LV_N FROM ZMAP_COA WHERE MATNR = 'SRCBUX'.
IF LV_N > 0.
  WRITE: / 'ABORT: SRCBUX sudah ada', LV_N. EXIT.
ENDIF.
DEFINE ADDM.
  CLEAR LS.
  LS-MATNR = 'SRCBUX'. LS-MIC = &1. LS-METHOD = &2.
  LS-MAPPING = &6. LS-UOM = &3. LS-MIC_DESC = &4.
  LS-SEQ_NO = &5. LS-USNAM = SY-UNAME. LS-CPUDT = SY-DATUM.
  LS-CPUTM = SY-UZEIT.
  INSERT ZMAP_COA FROM LS.
  WRITE: / &1, SY-SUBRC.
END-OF-DEFINITION.
ADDM 'PCADTH00' 'ASTM D 374' 'um' 'Thickness' '001' 'JR Base Film'.
ADDM 'PCADTSMD' 'ASTM D 882' 'kg/mm2' 'Tensile Strength MD' '002'
     'JR Base Film'.
ADDM 'PCADTSTD' 'ASTM D 882' 'kg/mm2' 'Tensile Strength TD' '003'
     'JR Base Film'.
ADDM 'PCADELMD' 'ASTM D 882' '%' 'Elongation MD' '004' 'JR Base Film'.
ADDM 'PCADELTD' 'ASTM D 882' '%' 'Elongation TD' '005' 'JR Base Film'.
ADDM 'PCADSHMD' 'ASTM D 1204' '%' 'Shrinkage MD' '006' 'JR Base Film'.
ADDM 'PCADSHTD' 'ASTM D 1204' '%' 'Shrinkage TD' '007' 'JR Base Film'.
ADDM 'PCADHZ00' 'ASTM D 1003' '%' 'Haze' '008' 'JR Base Film'.
ADDM 'PCADG400' 'ASTM D 2457' '%' 'Gloss 45' '009' 'JR Base Film'.
ADDM 'PCADSTNT' 'ASTM D 2578' 'dyne/cm'
     'Surface Tension Untreated Side' '010' 'SR Base Film'.
COMMIT WORK.
WRITE: / 'DONE'.
