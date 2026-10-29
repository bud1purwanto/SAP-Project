import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';
import * as fs from 'fs';

async function main() {
  await serverManager.loadConfig();
  await serverManager.setActiveServer('sandbox-new');
  
  // Baca include ZQMI_COA_F02 via RPY_PROGRAM_READ
  const readRes = await call_function({
    function_name: 'RPY_PROGRAM_READ',
    parameters: {
      PROGRAM_NAME: 'ZQMI_COA_F02'
    }
  });

  const sourceLines = readRes.result?.SOURCE_EXTENDED_LINES?.map(s => s.LINE) || 
                      readRes.result?.SOURCE_EXTENDED?.map(s => s.LINE) || 
                      readRes.result?.SOURCE_LINES?.map(s => s.LINE) ||
                      readRes.result?.SOURCE?.map(s => s.LINE) || [];
  
  console.log('Result keys:', Object.keys(readRes.result || {}));
  console.log('Read ZQMI_COA_F02 lines via RPY_PROGRAM_READ:', sourceLines.length);

  if (sourceLines.length === 0) {
    console.log('Sample result:', JSON.stringify(readRes.result).substring(0, 500));
    return;
  }

  // Backup file source live asli
  fs.writeFileSync('/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F02_sandbox_live_exact.abap', sourceLines.join('\n'));

  let foundModify = false;
  let modifyIdx = -1;
  for (let i = 0; i < sourceLines.length; i++) {
    if (sourceLines[i].includes('MICMITV = MICMIT / CTR.')) {
      for (let j = i; j < i + 15; j++) {
        if (sourceLines[j].trim() === 'MODIFY IT_DETAIL.') {
          modifyIdx = j;
          foundModify = true;
          break;
        }
      }
      break;
    }
  }

  console.log('Found MODIFY IT_DETAIL. at line index:', modifyIdx, 'Content:', sourceLines[modifyIdx]);

  if (!foundModify) {
    throw new Error('Tidak menemukan baris MODIFY IT_DETAIL. di dalam IF CTR > 1.');
  }

  sourceLines[modifyIdx] = '                MODIFY IT_DETAIL TRANSPORTING CMICMIT.';

  let callScreenIdx = -1;
  for (let i = modifyIdx; i < modifyIdx + 30; i++) {
    if (sourceLines[i].includes('CALL SCREEN 0200.')) {
      callScreenIdx = i;
      break;
    }
  }

  console.log('Found CALL SCREEN 0200. at line index:', callScreenIdx, 'Content:', sourceLines[callScreenIdx]);

  if (callScreenIdx === -1) {
    throw new Error('Tidak menemukan baris CALL SCREEN 0200.');
  }

  const patchInjection = [
    '            LOOP AT IT_DETAIL.',
    '              READ TABLE IT_DATA WITH KEY MIC = IT_DETAIL-MIC.',
    '              IF SY-SUBRC = 0 AND IT_DATA-MICDES IS NOT INITIAL.',
    '                IT_DETAIL-MICDES = IT_DATA-MICDES.',
    '                MODIFY IT_DETAIL TRANSPORTING MICDES.',
    '              ENDIF.',
    '            ENDLOOP.'
  ];

  sourceLines.splice(callScreenIdx, 0, ...patchInjection);

  fs.writeFileSync('/data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F02_sandbox_patched.abap', sourceLines.join('\n'));
  console.log('Saved patched source to /data/Projects/SAP/ABAP/subproject/COA/outputs/ZQMI_COA_F02_sandbox_patched.abap');
}
main().catch(console.error);
