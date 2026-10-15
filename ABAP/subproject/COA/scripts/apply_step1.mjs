import { readFileSync, writeFileSync } from 'node:fs';

const filePath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F01_sandbox-new_fresh.abap';
let source = readFileSync(filePath, 'utf8');

// 1. Sisipkan deklarasi GT_STAGE_LOTS setelah baris 'DATA: LOT_SR_CONV2 TYPE QALS-PRUEFLOS.'
const targetDecl = '  DATA: LOT_SR_CONV2 TYPE QALS-PRUEFLOS.';
const stageLotsDecl = `  DATA: LOT_SR_CONV2 TYPE QALS-PRUEFLOS.
* Enhancement Alpaca: Struktur Pohon Genealogi Dinamis Multi-Tier
  TYPES: BEGIN OF TY_STAGE_LOT,
           STAGE_TYPE TYPE C LENGTH 2,   " 'JR' atau 'SR'
           CATEGORY   TYPE C LENGTH 4,   " 'CONV' atau 'BASE'
           MATNR      TYPE MCH1-MATNR,
           CHARG      TYPE MCH1-CHARG,
           INSLOT     TYPE QALS-PRUEFLOS,
         END OF TY_STAGE_LOT.
  DATA: GT_STAGE_LOTS TYPE TABLE OF TY_STAGE_LOT WITH HEADER LINE.`;

if (!source.includes(targetDecl)) {
  throw new Error('Target declaration LOT_SR_CONV2 not found');
}
source = source.replace(targetDecl, stageLotsDecl);

// 2. Tambahkan FORM GET_JR_SIBLING_BY_ORDER di paling akhir file
const siblingSubroutine = `
*&---------------------------------------------------------------------*
*&      Form  GET_JR_SIBLING_BY_ORDER
*&---------------------------------------------------------------------*
* Cari Lot Inspeksi Roll Sibling dalam Order Produksi yang sama
* yang memiliki nilai hasil uji di QAMR (ANZWERTG > 0)
*----------------------------------------------------------------------*
FORM GET_JR_SIBLING_BY_ORDER USING P_CHARG TYPE CHARG_D
                             CHANGING P_LOT TYPE QALS-PRUEFLOS.
  DATA: LV_AUFNR TYPE MSEG-AUFNR,
        LT_BCH TYPE TABLE OF MSEG-CHARG WITH HEADER LINE,
        LV_L TYPE QALS-PRUEFLOS,
        LV_AZ TYPE QAMR-ANZWERTG.
  CLEAR P_LOT.
  IF P_CHARG IS INITIAL. RETURN. ENDIF.
  SELECT SINGLE AUFNR INTO LV_AUFNR FROM MSEG
    WHERE BWART = '101' AND CHARG = P_CHARG.
  IF LV_AUFNR IS NOT INITIAL.
    SELECT CHARG INTO TABLE LT_BCH FROM MSEG
      WHERE BWART = '101' AND AUFNR = LV_AUFNR.
    SORT LT_BCH. DELETE ADJACENT DUPLICATES FROM LT_BCH.
    LOOP AT LT_BCH.
      CLEAR: LV_L, LV_AZ.
      SELECT SINGLE PRUEFLOS INTO LV_L FROM QALS
        WHERE CHARG = LT_BCH AND ( ART = 'Z01' OR ART = 'Z02' OR ART = 'Z03' ).
      IF LV_L IS NOT INITIAL.
        SELECT SINGLE ANZWERTG INTO LV_AZ FROM QAMR
          WHERE PRUEFLOS = LV_L AND ANZWERTG > 0.
        IF LV_AZ > 0.
          P_LOT = LV_L.
          RETURN.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.
ENDFORM.                    "GET_JR_SIBLING_BY_ORDER
`;
source = source + '\n' + siblingSubroutine;

writeFileSync(filePath, source, 'utf8');
console.log('Tahap 1 sukses: Deklarasi dan FORM GET_JR_SIBLING_BY_ORDER berhasil disisipkan.');
