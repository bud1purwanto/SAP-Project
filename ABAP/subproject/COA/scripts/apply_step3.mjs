import { readFileSync, writeFileSync } from 'node:fs';

const filePath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_sandbox-new_fresh.abap';
let source = readFileSync(filePath, 'utf8');

const targetOld = `  LOOP AT IT_ZMAP.
    CLEAR INS.
    " Tentukan sumber Inspection Lot berdasarkan MAPPING
    IF IT_ZMAP-MAPPING CS 'SR Base Film'.
      INS = LOT_SR_BASE.
    ELSEIF IT_ZMAP-MAPPING CS 'JR Base Film'.
      INS = LOT_JR_BASE.
    ELSEIF IT_ZMAP-MAPPING CS 'SR Converting'.
      INS = LOT_SR_CONV.
    ELSEIF IT_ZMAP-MAPPING CS 'JR Converting'.
      INS = LOT_JR_CONV.
    ELSE.
      " Default fallback jika kosong, mungkin ambil dari SR Convert/Base
      INS = LOT_SR_CONV.
    ENDIF.`;

const targetNew = `  LOOP AT IT_ZMAP.
    CLEAR INS.
* Enhancement Alpaca: Cari Lot Inspeksi secara dinamis dari pohon silsilah GT_STAGE_LOTS
    DATA: LV_DYN_STAGE TYPE C LENGTH 2,
          LV_DYN_CAT   TYPE C LENGTH 4,
          LV_DYN_MK    TYPE QAMV-MERKNR,
          LV_DYN_MW    TYPE QAMR-MITTELWERT,
          LV_DYN_AZ    TYPE QAMR-ANZWERTG.
    CLEAR: LV_DYN_STAGE, LV_DYN_CAT.
    IF IT_ZMAP-MAPPING CS 'JR'. LV_DYN_STAGE = 'JR'.
    ELSEIF IT_ZMAP-MAPPING CS 'SR'. LV_DYN_STAGE = 'SR'. ENDIF.
    IF IT_ZMAP-MAPPING CS 'Base'. LV_DYN_CAT = 'BASE'.
    ELSEIF IT_ZMAP-MAPPING CS 'Converting'. LV_DYN_CAT = 'CONV'. ENDIF.

    IF LV_DYN_STAGE IS NOT INITIAL AND LV_DYN_CAT IS NOT INITIAL.
      LOOP AT GT_STAGE_LOTS WHERE STAGE_TYPE = LV_DYN_STAGE
                              AND CATEGORY   = LV_DYN_CAT.
        CLEAR LV_DYN_MK.
        SELECT SINGLE MERKNR INTO LV_DYN_MK FROM QAMV
          WHERE PRUEFLOS  = GT_STAGE_LOTS-INSLOT
            AND VERWMERKM = IT_ZMAP-MIC.
        IF SY-SUBRC = 0.
          CLEAR: LV_DYN_MW, LV_DYN_AZ.
          SELECT SINGLE MITTELWERT ANZWERTG INTO (LV_DYN_MW, LV_DYN_AZ) FROM QAMR
            WHERE PRUEFLOS = GT_STAGE_LOTS-INSLOT AND MERKNR = LV_DYN_MK.
          IF LV_DYN_AZ > 0 OR LV_DYN_MW IS NOT INITIAL.
            INS = GT_STAGE_LOTS-INSLOT.
            EXIT.
          ENDIF.
        ENDIF.
      ENDLOOP.
    ENDIF.

    " Fallback kompatibilitas jika belum ditemukan dari pohon silsilah
    IF INS IS INITIAL.
      IF IT_ZMAP-MAPPING CS 'SR Base Film'.
        INS = LOT_SR_BASE.
      ELSEIF IT_ZMAP-MAPPING CS 'JR Base Film'.
        INS = LOT_JR_BASE.
      ELSEIF IT_ZMAP-MAPPING CS 'SR Converting'.
        INS = LOT_SR_CONV.
      ELSEIF IT_ZMAP-MAPPING CS 'JR Converting'.
        INS = LOT_JR_CONV.
      ELSE.
        INS = LOT_SR_CONV.
      ENDIF.
    ENDIF.`;

if (!source.includes(targetOld)) throw new Error('targetOld in GET_MIC not found');
source = source.replace(targetOld, targetNew);

writeFileSync(filePath, source, 'utf8');
console.log('Tahap 3 sukses: GET_MIC dinamis berhasil dipasang.');
