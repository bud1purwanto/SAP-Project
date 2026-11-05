// Proxy lokal ADT untuk SAP_BASIS 731 SP4.
// CL_REST_HTTP_HANDLER SP4 menolak POST/PUT/DELETE (403 kosong) bila header
// X-Requested-With tidak ada. Extension VSCode ABAP FS tidak mengirim header itu,
// jadi proxy ini menyisipkannya.
// Pemakaian: node adt_proxy.mjs [listenPort] [targetUrl]
//   default: 127.0.0.1:8100 -> http://192.168.6.243:8000 (sandbox-new)
import http from 'node:http';

const LISTEN = Number(process.argv[2] || 8100);
const TARGET = new URL(process.argv[3] || 'http://192.168.6.243:8000');

http.createServer((req, res) => {
  const headers = { ...req.headers, host: TARGET.host };
  if (!headers['x-requested-with']) headers['x-requested-with'] = 'XMLHttpRequest';
  const up = http.request({
    hostname: TARGET.hostname,
    port: TARGET.port || 80,
    path: req.url,
    method: req.method,
    headers
  }, (r) => {
    res.writeHead(r.statusCode, r.headers);
    r.pipe(res);
  });
  up.on('error', (e) => {
    res.writeHead(502, { 'content-type': 'text/plain' });
    res.end('ADT proxy error: ' + e.message);
  });
  req.pipe(up);
}).listen(LISTEN, '127.0.0.1', () => {
  console.log(`ADT proxy 127.0.0.1:${LISTEN} -> ${TARGET.origin}`);
});
