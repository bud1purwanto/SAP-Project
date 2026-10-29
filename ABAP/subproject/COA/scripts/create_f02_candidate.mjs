import { readFileSync, writeFileSync } from 'node:fs';

const liveSrcPath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F02_sandbox-new_live_now.abap';
const candidatePath = '/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F02_candidate_sandbox.abap';

let src = readFileSync(liveSrcPath, 'utf8');

const oldTcerti = `MODULE TCTIMB_MODIFY INPUT.
  CONDENSE IT_DATA-CMICMIT.
  PERFORM SET_COA_RANGE_FLAG
    USING IT_DATA-TYPE IT_DATA-MICMIN IT_DATA-MICMAX
          IT_DATA-RAW_MICMIN IT_DATA-RAW_MICMAX
          IT_DATA-CMICMIT
    CHANGING IT_DATA-RANGE_FLAG.
  MODIFY IT_DATA
*    FROM WA_TIMBANG
    INDEX TCERTI-CURRENT_LINE.
ENDMODULE.                 " TCTIMB_MODIFY  INPUT`;

const newTcerti = `MODULE TCTIMB_MODIFY INPUT.
  CONDENSE IT_DATA-CMICMIT.
  PERFORM SET_COA_RANGE_FLAG
    USING IT_DATA-TYPE IT_DATA-MICMIN IT_DATA-MICMAX
          IT_DATA-RAW_MICMIN IT_DATA-RAW_MICMAX
          IT_DATA-CMICMIT
    CHANGING IT_DATA-RANGE_FLAG.
  MODIFY IT_DATA
    INDEX TCERTI-CURRENT_LINE
    TRANSPORTING CHK CMICMIT RANGE_FLAG.
ENDMODULE.                 " TCTIMB_MODIFY  INPUT`;

const oldTdetail = `MODULE TDETAIL_MODIFY INPUT.
  PERFORM SET_COA_RANGE_FLAG
    USING IT_DETAIL-TYPE IT_DETAIL-MICMIN
          IT_DETAIL-MICMAX IT_DETAIL-RAW_MICMIN
          IT_DETAIL-RAW_MICMAX IT_DETAIL-CMICMIT
    CHANGING IT_DETAIL-RANGE_FLAG.
  MODIFY IT_DETAIL
*    FROM WA_TIMBANG
    INDEX TDETAIL-CURRENT_LINE.
ENDMODULE.                 " TDETAIL_MODIFY  INPUT`;

const newTdetail = `MODULE TDETAIL_MODIFY INPUT.
  PERFORM SET_COA_RANGE_FLAG
    USING IT_DETAIL-TYPE IT_DETAIL-MICMIN
          IT_DETAIL-MICMAX IT_DETAIL-RAW_MICMIN
          IT_DETAIL-RAW_MICMAX IT_DETAIL-CMICMIT
    CHANGING IT_DETAIL-RANGE_FLAG.
  MODIFY IT_DETAIL
    INDEX TDETAIL-CURRENT_LINE
    TRANSPORTING CHK CMICMIT RANGE_FLAG.
ENDMODULE.                 " TDETAIL_MODIFY  INPUT`;

if (!src.includes(oldTcerti)) {
  throw new Error('oldTcerti snippet not found in live source');
}
if (!src.includes(oldTdetail)) {
  throw new Error('oldTdetail snippet not found in live source');
}

src = src.replace(oldTcerti, newTcerti);
src = src.replace(oldTdetail, newTdetail);

writeFileSync(candidatePath, src, 'utf8');
console.log('Successfully created candidate:', candidatePath);
