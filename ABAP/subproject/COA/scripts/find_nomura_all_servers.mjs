import { serverManager } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/server-manager.js';
import { call_function } from 'file:///var/www/MCP/MCP%20SAP/sap-leader-mcp/src/tools/query-tools.js';

async function main() {
  await serverManager.loadConfig();
  for (const s of serverManager.config.servers) {
    if (s.name.includes('Production')) continue;
    try {
      await serverManager.setActiveServer(s.name);
      const prog = [
        'REPORT ZFIND_NOMURA.',
        'DATA: LT_KNA1 TYPE TABLE OF KNA1 WITH HEADER LINE.',
        'SELECT * FROM KNA1 INTO TABLE LT_KNA1 UP TO 5 ROWS',
        '  WHERE NAME1 LIKE \'%NOMURA%\'.',
        'LOOP AT LT_KNA1.',
        '  DATA: LV_CNT TYPE I.',
        '  SELECT COUNT(*) INTO LV_CNT FROM LIKP WHERE KUNNR = LT_KNA1-KUNNR.',
        '  WRITE: / SY-MANDT, SY-SYSID, LT_KNA1-KUNNR, LT_KNA1-NAME1, \'DO count:\', LV_CNT.',
        'ENDLOOP.'
      ];
      const res = await call_function({
        function_name: 'RFC_ABAP_INSTALL_AND_RUN',
        parameters: { PROGRAM: prog.map(l => ({ LINE: l })) }
      });
      console.log(s.name, res.result?.WRITES);
    } catch (e) {
      console.log(s.name, 'ERR:', e.message);
    }
  }
}
main().catch(console.error);
