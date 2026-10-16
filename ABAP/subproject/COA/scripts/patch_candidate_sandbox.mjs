import { readFileSync, writeFileSync } from 'node:fs';

const filePath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_candidate_sandbox.abap';
let content = readFileSync(filePath, 'utf8');

// 1. Perbaikan pada FORM GET_MIC: Simpan hasil rata-rata ke GT_LOT_AVG untuk semua lot di LT_SRLOTS
const oldAvgBlock = `      IF L_ACNT > 0.
        CLEAR GS_LOT_AVG.
        GS_LOT_AVG-INSLOT = LOT_SR_CONV.
        GS_LOT_AVG-MERKNR = LT_QU-MERKNR.
        GS_LOT_AVG-MITTELWERT = L_ASUM / L_ACNT.
        GS_LOT_AVG-ANZWERTG = 1.
        APPEND GS_LOT_AVG TO GT_LOT_AVG.
      ENDIF.`;

const newAvgBlock = `      IF L_ACNT > 0.
        CLEAR GS_LOT_AVG.
        GS_LOT_AVG-INSLOT = LOT_SR_CONV.
        GS_LOT_AVG-MERKNR = LT_QU-MERKNR.
        GS_LOT_AVG-MITTELWERT = L_ASUM / L_ACNT.
        GS_LOT_AVG-ANZWERTG = 1.
        APPEND GS_LOT_AVG TO GT_LOT_AVG.
        " Sinkronisasi juga ke semua lot anggota agar match saat lookup INS
        LOOP AT LT_SRLOTS.
          IF LT_SRLOTS-LOT <> LOT_SR_CONV.
            GS_LOT_AVG-INSLOT = LT_SRLOTS-LOT.
            APPEND GS_LOT_AVG TO GT_LOT_AVG.
          ENDIF.
        ENDLOOP.
      ENDIF.`;

if (!content.includes(oldAvgBlock)) {
  throw new Error('oldAvgBlock not found');
}
content = content.replace(oldAvgBlock, newAvgBlock);

// 2. Perbaikan pada FORM GET_TRACED_LOTS (Enhancement Alpaca Multi-Tier Loop DO 10 TIMES):
// Tangani transisi intermediate MCH1-LICHA dan AFPO-MILL_OC_AUFNR_U
const oldTreeLoop = `    SELECT SINGLE MATNR LICHA INTO (LV_TREE_MATNR, LV_TREE_LICHA) FROM MCH1
      WHERE CHARG = LV_TREE_CHARG.
    IF SY-SUBRC <> 0. EXIT. ENDIF.

    LV_TREE_LEN = STRLEN( LV_TREE_MATNR ).
    LV_TREE_TMP = LV_TREE_LEN - 1.
    IF LV_TREE_MATNR(2) = 'SR' AND
       ( LV_TREE_MATNR+LV_TREE_TMP(1) = 'A' OR LV_TREE_MATNR+LV_TREE_TMP(1) = 'O' ).
      IF LV_TREE_LICHA IS NOT INITIAL.
        LV_TREE_CHARG = LV_TREE_LICHA.
      ENDIF.
    ENDIF.`;

const newTreeLoop = `    SELECT SINGLE MATNR LICHA INTO (LV_TREE_MATNR, LV_TREE_LICHA) FROM MCH1
      WHERE CHARG = LV_TREE_CHARG.
    IF SY-SUBRC <> 0. EXIT. ENDIF.

    LV_TREE_LEN = STRLEN( LV_TREE_MATNR ).
    LV_TREE_TMP = LV_TREE_LEN - 1.
    IF LV_TREE_MATNR(2) = 'SR' AND
       ( LV_TREE_MATNR+LV_TREE_TMP(1) = 'A' OR LV_TREE_MATNR+LV_TREE_TMP(1) = 'O' ).
      IF LV_TREE_LICHA IS NOT INITIAL.
        LV_TREE_CHARG = LV_TREE_LICHA.
        LT_TREE_VISITED = LV_TREE_CHARG. APPEND LT_TREE_VISITED.
      ENDIF.
    ENDIF.`;

if (!content.includes(oldTreeLoop)) {
  throw new Error('oldTreeLoop not found');
}
content = content.replace(oldTreeLoop, newTreeLoop);

// Perbaikan transisi komponen 261 di FORM GET_TRACED_LOTS
const oldTreeComp = `        CLEAR LV_TREE_AUFNR.
        SELECT SINGLE AUFNR INTO LV_TREE_AUFNR FROM MSEG
          WHERE BWART = '101' AND CHARG = LV_TREE_JR.
        IF LV_TREE_AUFNR IS NOT INITIAL.
          CLEAR LV_TREE_COMP.
          SELECT SINGLE CHARG INTO LV_TREE_COMP FROM MSEG
            WHERE BWART = '261' AND AUFNR = LV_TREE_AUFNR AND CHARG <> SPACE.
          IF LV_TREE_COMP IS NOT INITIAL.
            LV_TREE_CHARG = LV_TREE_COMP.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.`;

const newTreeComp = `        CLEAR LV_TREE_AUFNR.
        SELECT SINGLE AUFNR INTO LV_TREE_AUFNR FROM MSEG
          WHERE BWART = '101' AND CHARG = LV_TREE_JR.
        IF LV_TREE_AUFNR IS NOT INITIAL.
          CLEAR LV_TREE_COMP.
          SELECT SINGLE CHARG INTO LV_TREE_COMP FROM MSEG
            WHERE BWART = '261' AND AUFNR = LV_TREE_AUFNR AND CHARG <> SPACE.
          IF LV_TREE_COMP IS NOT INITIAL.
            " Jika komponen adalah batch intermediate, periksa master batch LICHA
            DATA: LV_SUB_MAT TYPE MCH1-MATNR, LV_SUB_LICHA TYPE MCH1-LICHA, LV_SUB_L TYPE I, LV_SUB_T TYPE I.
            CLEAR: LV_SUB_MAT, LV_SUB_LICHA.
            SELECT SINGLE MATNR LICHA INTO (LV_SUB_MAT, LV_SUB_LICHA) FROM MCH1
              WHERE CHARG = LV_TREE_COMP.
            LV_SUB_L = STRLEN( LV_SUB_MAT ).
            LV_SUB_T = LV_SUB_L - 1.
            IF LV_SUB_MAT(2) = 'SR' AND ( LV_SUB_MAT+LV_SUB_T(1) = 'A' OR LV_SUB_MAT+LV_SUB_T(1) = 'O' ).
              IF LV_SUB_LICHA IS NOT INITIAL.
                LV_TREE_COMP = LV_SUB_LICHA.
              ENDIF.
            ENDIF.
            LV_TREE_CHARG = LV_TREE_COMP.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          EXIT.
        ENDIF.`;

if (!content.includes(oldTreeComp)) {
  throw new Error('oldTreeComp not found');
}
content = content.replace(oldTreeComp, newTreeComp);

writeFileSync(filePath, content, 'utf8');
console.log('Successfully patched candidate sandbox file!');
