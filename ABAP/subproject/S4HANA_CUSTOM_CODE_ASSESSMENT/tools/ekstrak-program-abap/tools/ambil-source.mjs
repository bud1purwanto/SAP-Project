import { draftAlur } from './alur-abap.mjs';
import { createRequire } from 'node:module';
import { parseEnv } from 'node:util';
import { readFileSync, writeFileSync } from 'node:fs';
import { join, delimiter } from 'node:path';
import { analyzeAbapSource, inventoryDeclarations } from './abap-source-analyzer.mjs';

const [input, folder] = process.argv.slice(2);
const namePattern = /^(?=.{1,40}$)(?:\/[A-Z0-9_]+\/)?[A-Z0-9_=]+$/;
async function download() {
  if (!namePattern.test(input)) throw Error('Nama program atau T-code tidak valid.');
  const file = new URL('../.env', import.meta.url);
  let profile;
  try { profile = parseEnv(readFileSync(file, 'utf8')); }
  catch { throw Error('Isi file .env di samping peluncur menggunakan contoh .env.example.'); }
  const required = ['CLIENT', 'USER', 'PASSWORD', ...(profile.SAP_DEV_AIX_ASHOST ? ['ASHOST','SYSNR'] : ['MSHOST','R3NAME','GROUP'])];
  if (required.some(key => !profile['SAP_DEV_AIX_' + key])) throw Error('Profil SAP_DEV_AIX di .env belum lengkap. Periksa .env.example.');
  process.env.PATH = join(process.env.SAPNWRFC_HOME || 'C:/nwrfcsdk', 'lib') + delimiter + process.env.PATH;
  const require = createRequire(process.env.ABAP_RFC_PACKAGE || import.meta.url);
  let Client;
  try { ({ Client } = require('node-rfc')); }
  catch { throw Error('Driver RFC belum siap. Periksa Node.js, node-rfc, dan SAP NW RFC SDK sesuai PETUNJUK.txt.'); }
  const config = {};
  for (const [field, suffix] of Object.entries({ashost:'ASHOST', sysnr:'SYSNR', client:'CLIENT', user:'USER', passwd:'PASSWORD', mshost:'MSHOST', r3name:'R3NAME', group:'GROUP'})) {
    const value = profile['SAP_DEV_AIX_' + suffix];
    if (value) config[field] = value;
  }
  if (config.ashost) {
    delete config.mshost;
    delete config.r3name;
    delete config.group;
  }
  const sap = new Client(config);
  await sap.open();
  try {
    async function lookup(table, key, value, fields) {
      if (!namePattern.test(value)) throw Error('Nama repository tidak didukung: ' + value);
      const result = await sap.call('RFC_READ_TABLE', {QUERY_TABLE:table, DELIMITER:'|',
        FIELDS:fields.map(FIELDNAME=>({FIELDNAME})), OPTIONS:[{TEXT:key+" = '"+value+"'"}], ROWCOUNT:1});
      return result.DATA[0]?.WA.split('|').map(part=>part.trim());
    }
    const log = ['','DEEP SCAN SAP: hubungan statis dan objek yang berhasil dibaca'];
    async function resolve(name, kind, chain = new Set()) {
      if (chain.has(name)) throw Error('Siklus pemetaan transaksi: ' + name);
      chain.add(name);
      if (kind === 'auto' || kind === 'transaksi') {
        const row = await lookup('TSTC','TCODE',name,['PGMNA']);
        if (row?.[0]) return row[0];
        if (row) {
          const param = (await lookup('TSTCP','TCODE',name,['PARAM']))?.[0] || '';
          const target = param.match(/^(?:@@|\/[*N]?)([A-Z0-9_]+)(?:\s|$)/i)?.[1];
          if (target) return resolve(target,'transaksi',chain);
          throw Error('Definisi transaksi belum dapat dipetakan: ' + name);
        }
        if (kind === 'transaksi') throw Error('T-code belum ditemukan');
      }
      if (kind === 'auto' && await lookup('TRDIR','NAME',name,['NAME'])) return name;
      if (kind === 'auto' || kind === 'fungsi') {
        const fm = await lookup('TFDIR','FUNCNAME',name,['PNAME','INCLUDE']);
        if (fm && /^SAPL/.test(fm[0])) return 'L'+fm[0].slice(4)+'U'+fm[1];
      }
      if (kind === 'auto' && name.length <= 30) {
        const pool = name.padEnd(30,'=')+'CP';
        if (await lookup('TRDIR','NAME',pool,['NAME'])) return pool;
      }
      throw Error('Objek source tidak terpetakan: ' + name);
    }
    const root = await resolve(input,'auto');
    const pending = [root], seen = new Set(), resolved = new Map();
    let count = 0;
    const sources = new Map();
    while (pending.length) {
      const program = pending.pop();
      if (seen.has(program)) continue;
      seen.add(program);
      try {
        if (!namePattern.test(program)) throw Error('Format nama belum didukung');
        const result = await sap.call('ZRFC_READ_REPORT',{PROGRAM:program});
        if (!result.QTAB?.length) throw Error('Source tidak tersedia');
        const lines = result.QTAB.map((row,i)=>({text:String(row.LINE ?? ''),lineNumber:i+1}));
        writeFileSync(join(folder,program.replaceAll('/','%')+'.abap'),lines.map(row=>row.text).join('\n'),'utf8');
        count++;
        sources.set(program, lines.map(row => row.text));
        const analysis = analyzeAbapSource(lines);
        log.push('','Objek '+program+' ('+lines.length+' baris)');
        for (const {type,lineNumber,value} of inventoryDeclarations(lines)) {
          log.push('  '+lineNumber+' | '+type+' | '+value);
        }
        for (const key of ['includes','submitPrograms','callFunctions','callTransactions','tableReads','databaseWrites']) {
          for (const {value,lineNumber} of analysis[key]) {
            log.push('  '+lineNumber+' | '+key+' | '+value);
            if (key === 'includes') pending.push(value);
            if (!/^(?:Z|Y|\/)/.test(value)) continue;
            if (key === 'submitPrograms') pending.push(value);
            if (key === 'callFunctions' || key === 'callTransactions') {
              const id = key+':'+value;
              if (!resolved.has(id)) {
                try { resolved.set(id,await resolve(value,key==='callFunctions'?'fungsi':'transaksi')); }
                catch (error) { resolved.set(id,null);log.push('  Belum terurai: '+value+' | '+error.message); }
              }
              if (resolved.get(id)) pending.push(resolved.get(id));
            }
          }
        }
      } catch (error) {
        if (program === root) throw error;
        log.push('Belum terbaca: '+program+' | '+error.message);
      }
    }
    log.push('Jumlah source terbaca: '+count);
    writeFileSync(join(folder,'scan.txt'),(draftAlur(sources) + log.join('\n')),'utf8');
    console.log(root.replaceAll('/','%'));
  } finally { await sap.close(); }
}
download().catch(error=>{console.error('Gagal membaca SAP:', error.message); process.exitCode=1;});
